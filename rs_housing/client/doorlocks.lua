local DoorData = { Loaded = false, DoorsList = {} }
local ActivePrompts = {}

local IsAuthorized = function(doorID, owned)

  local data       = DoorData.DoorsList[doorID]
  local PlayerData = GetPlayerData()

  if data.owned == 0 and Config.RealEstateJob.Job == PlayerData.job then
    return true
  end

  if data.owned == 0 then
    return false
  end

  if data.identifier == PlayerData.citizenid then
    return true
  end

  if data.keyholders then
    for keyId, _ in pairs(data.keyholders) do
      if keyId == PlayerData.citizenid then
        return true
      end
    end
  end
  return false
end

local function CreateDoorPrompt(doorIndex, locationId)
  if ActivePrompts[doorIndex] then return end

  local groupId = GetRandomIntInRange(0, 0xffffff)

  local prompt = PromptRegisterBegin()
  PromptSetControlAction(prompt, Config.DoorKey)
  local str = CreateVarString(10, 'LITERAL_STRING', Locales["DOORLOCK"])
  PromptSetText(prompt, str)
  PromptSetStandardMode(prompt, 1)
  PromptSetGroup(prompt, groupId)
  Citizen.InvokeNative(0xC5F428EE08FA7F2C, prompt, true)
  PromptRegisterEnd(prompt)

  ActivePrompts[doorIndex] = {
    promptHandle = prompt,
    groupId      = groupId,
    locationId   = locationId,
  }
end

local function RemoveDoorPrompt(doorIndex)
  if not ActivePrompts[doorIndex] then return end
  PromptDelete(ActivePrompts[doorIndex].promptHandle)
  ActivePrompts[doorIndex] = nil
end

function GetDoorData()
  return DoorData
end

CreateThread(function()
  while not LocalPlayer.state.isLoggedIn do
    Wait(20000)
  end
  TriggerServerEvent("rs_housing:server:requestDoorlocks")
end)

if Config.DevMode then
  Citizen.CreateThread(function()
    TriggerServerEvent("rs_housing:server:requestDoorlocks")
  end)
end

RegisterNetEvent("rs_housing:client:loadDoorsList")
AddEventHandler("rs_housing:client:loadDoorsList", function(data)
  DoorData.DoorsList = data
  DoorData.Loaded    = true
end)

RegisterNetEvent("rs_housing:client:setState")
AddEventHandler("rs_housing:client:setState", function(doorId, state)
  DoorData.DoorsList[doorId].locked = state
end)

RegisterNetEvent("rs_housing:client:registerNewDoorlock")
AddEventHandler('rs_housing:client:registerNewDoorlock', function(doorID, doors, canBreakIn, keyholders, owned, citizenid, locationId)

  DoorData.DoorsList[doorID]                = {}

  DoorData.DoorsList[doorID].index          = doorID
  DoorData.DoorsList[doorID].locationId     = locationId

  DoorData.DoorsList[doorID].authorizedJobs = { 'none' }
  DoorData.DoorsList[doorID].doors          = doors
  DoorData.DoorsList[doorID].locked         = true

  DoorData.DoorsList[doorID].distance       = 1.8

  DoorData.DoorsList[doorID].canBreakIn     = canBreakIn

  DoorData.DoorsList[doorID].keyholders     = keyholders

  DoorData.DoorsList[doorID].owned          = owned

  DoorData.DoorsList[doorID].identifier     = citizenid

end)

RegisterNetEvent("rs_housing:client:doors:update")
AddEventHandler("rs_housing:client:doors:update", function(locationId, actionType, data)

  for _, door in pairs(DoorData.DoorsList) do

    if door.locationId == locationId then

      if actionType == 'TRANSFERRED' then

        DoorData.DoorsList[_].identifier = data[1]
        DoorData.DoorsList[_].owned      = 1

      elseif actionType == 'RESET' then

        DoorData.DoorsList[_].identifier = nil
        DoorData.DoorsList[_].keyholders = {}
        DoorData.DoorsList[_].owned      = 0

      elseif actionType == 'REGISTER_KEYHOLDER' then

        DoorData.DoorsList[_].keyholders[data[1]] = {}
        DoorData.DoorsList[_].keyholders[data[1]].username = data[2]

      elseif actionType == 'UNREGISTER_KEYHOLDER' then

        DoorData.DoorsList[_].keyholders[data[1]] = nil
      end
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1000)

    local playerPed = PlayerPedId()
    local coords    = GetEntityCoords(playerPed)

    for _, location in ipairs(DoorData.DoorsList) do

      for k, door in ipairs(location.doors) do

        if door ~= false and not door.object then

          local distance = #(coords - door.objCoords)

          if distance <= Config.RenderDoorStateDistance then

            local shapeTest = StartShapeTestBox(door.objCoords, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, true, 16)
            local rtnVal, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(shapeTest)

            if DoesEntityExist(entityHit) then

              local model = GetEntityModel(entityHit)

              for _, v in pairs(DOOR_HASHES) do

                if model == v[2] then

                  local doorcoords = vector3(v[4], v[5], v[6])
                  local distance   = #(doorcoords - door.objCoords)

                  if distance <= 1.8 then
                    door.object = v[1]
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end)

Citizen.CreateThread(function()

  while true do
    Citizen.Wait(0)

    local playerPed = PlayerPedId()
    local coords    = GetEntityCoords(playerPed)
    local isDead    = IsEntityDead(playerPed)

    local sleep     = true

    if not isDead and DoorData.Loaded then

      for k, v in ipairs(DoorData.DoorsList) do

        for _, door in ipairs(v.doors) do

          if door ~= false and door.object then

            local distance    = #(coords - door.objCoords)
            local maxDistance = 1.8

            if distance < Config.RenderDoorStateDistance then

              if v.locked then

                if DoorSystemGetOpenRatio(door.object) ~= 0.0 then
                  DoorSystemSetOpenRatio(door.object, 0.0, true)
                  local object = Citizen.InvokeNative(0xF7424890E4A094C0, door.object, 0)
                  SetEntityRotation(object, 0.0, 0.0, door.objYaw, 2, true)
                end

                if DoorSystemGetDoorState(door.object) ~= 3 then
                  Citizen.CreateThread(function()
                    Citizen.InvokeNative(0xD99229FE93B46286, door.object, 1, 1, 0, 0, 0, 0)
                  end)
                  local object = Citizen.InvokeNative(0xF7424890E4A094C0, door.object, 0)
                  Citizen.InvokeNative(0x6BAB9442830C7F53, door.object, 3)
                  SetEntityRotation(object, 0.0, 0.0, door.objYaw, 2, true)
                end

              else

                if DoorSystemGetDoorState(door.object) ~= 0 then
                  Citizen.CreateThread(function()
                    Citizen.InvokeNative(0xD99229FE93B46286, door.object, 1, 1, 0, 0, 0, 0)
                  end)
                  Citizen.InvokeNative(0x6BAB9442830C7F53, door.object, 0)
                end
              end
            end

            if distance < maxDistance then
              sleep = false

              if IsAuthorized(k, v.owned) then

                CreateDoorPrompt(k, v.locationId)

                local promptData = ActivePrompts[k]

                if promptData then

                  local label = CreateVarString(10, 'LITERAL_STRING', Locales["HOUSE"] .. " (" .. v.locationId .. ")")
                  PromptSetActiveGroupThisFrame(promptData.groupId, label)

                  if Citizen.InvokeNative(0xC92AC953F0A982AE, promptData.promptHandle) then
                    local entity = Citizen.InvokeNative(0xF7424890E4A094C0, v.doors[1].object, 0)
                    PerformKeyAnimation(entity)
                    TriggerServerEvent('rs_housing:server:updateState', k, (not v.locked))
                    Wait(500)
                  end
                end

              else
                RemoveDoorPrompt(k)
              end

            else
              RemoveDoorPrompt(k)
            end
          end
        end
      end
    end

    if sleep then
      Citizen.Wait(1000)
    end
  end
end)