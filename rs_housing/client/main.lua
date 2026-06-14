local RSGCore = exports['rsg-core']:GetCoreObject()

local PlayerData = {
  IsInMenu       = false,
  DisplayingUI   = false,
  IsBusy         = false,
  CitizenId      = nil,
  Job            = nil,
  Properties     = {},
  ItemsList      = {},
  Loaded         = false
}

function GetPlayerData()
  return PlayerData
end

local IsPermittedToBuy = function()

  local cb = 0

  for _, property in pairs(PlayerData.Properties) do
    if property.citizenid == PlayerData.CitizenId and property.owned == 1 then
      cb = cb + 1
    end
  end

  return (cb < Config.MaxHouses)
end

local HasPropertyAccess = function(property)

  if property.citizenid == PlayerData.CitizenId then
    return true
  end

  local found = false

  if property.keyholders then
    for _, keyholder in pairs(property.keyholders) do
      if keyholder.citizenid == PlayerData.CitizenId then
        found = true
      end
    end
  end

  return found
end

local TeleportToCoords = function(x, y, z, w)
    local player = PlayerPedId()
    DoScreenFadeOut(500)
    Wait(500)
    SetEntityCoordsNoOffset(player, x, y, z + 0.5, false, false, false)
    if w then
        SetEntityHeading(player, w)
    end
    Wait(500)
    DoScreenFadeIn(500)
end

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local player = PlayerPedId()
        local pcoords = GetEntityCoords(player)

        for propertyId, property in pairs(PlayerData.Properties) do
            if property.Locations and property.Locations.MenuActions then

                if HasPropertyAccess(property) then

                    local v = property.Locations.MenuActions
                    local dist = #(pcoords - vector3(v.x, v.y, v.z))

                    if dist < 10.0 then
                        sleep = 5
                        Citizen.InvokeNative(
                            0x2A32FAA57B937173, 
                            0x94FDAE17, 
                            v.x, v.y, v.z - 0.89, 
                            0, 0, 0, 0, 0, 0, 
                            Config.Checkpoints.size, 
                            Config.Checkpoints.size, 
                            Config.Checkpoints.height,
                            Config.Checkpoints.rgba[1], 
                            Config.Checkpoints.rgba[2], 
                            Config.Checkpoints.rgba[3], 
                            Config.Checkpoints.rgba[4], 
                            0, 0, 2, 
                            Config.Checkpoints.rotate, 
                            0, 0, 0
                        )
                    end
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

local TeleportOutsideOnJoin = function()

    local player = PlayerPedId()
    local coords = GetEntityCoords(player)

    for propertyId, property in pairs(PlayerData.Properties) do

        local coordsDist          = vector3(coords.x, coords.y, coords.z)
        local menuActionsDistance = #(coordsDist - property.Locations.MenuActions)
        local distance            = #(coordsDist - menuActionsDistance)

        if distance <= Config.TeleportOutsideOnJoin.ClosestDistance then

            FreezeEntityPosition(player, true)

            local teleportCoords = property.Locations.PrimaryEntrance

            TeleportToCoords(teleportCoords.x, teleportCoords.y, teleportCoords.z, teleportCoords.w)

            Wait(1000)
            FreezeEntityPosition(player, false)

        end

    end

end

function HasPermissionByName(propertyId, permission, citizenid)

    if PlayerData.Properties[propertyId] == nil then
        return 0
    end

    local Property = PlayerData.Properties[propertyId]

    if Property.citizenid == citizenid then
        return 1
    end

    if Property.keyholders[citizenid] == nil then
        return 0
    end

    local KeyholderData = Property.keyholders[citizenid]

    return tonumber(KeyholderData.permissions[permission])
end

CreateThread(function()
  while not LocalPlayer.state.isLoggedIn do
    Wait(20000)
  end
  TriggerServerEvent("rs_housing:server:requestPlayerData")
end)

if Config.DevMode then
  Citizen.CreateThread(function() TriggerServerEvent("rs_housing:server:requestPlayerData") end)
end

RegisterNetEvent("rsg-core:client:onJobUpdate")
AddEventHandler("rsg-core:client:onJobUpdate", function(JobInfo)
  PlayerData.Job = JobInfo.name
end)

RegisterNetEvent("rs_housing:client:updatePlayerData")
AddEventHandler("rs_housing:client:updatePlayerData", function(data)
  PlayerData.CitizenId  = data[1]
  PlayerData.Job        = data[2]
  PlayerData.Properties = data[3]

  PlayerData.Loaded     = true

  if not Config.TeleportOutsideOnJoin.Enabled then
    return
  end

  TeleportOutsideOnJoin()
end)

RegisterNetEvent("rs_housing:client:updateProperty")
AddEventHandler("rs_housing:client:updateProperty", function(propertyId, actionType, data)

  if PlayerData.Properties[propertyId] == nil then
    return
  end

  if actionType == 'BUY' then

    PlayerData.Properties[propertyId].citizenid = data[1]
    PlayerData.Properties[propertyId].owned     = 1
    PlayerData.Properties[propertyId].duration  = 0
    PlayerData.Properties[propertyId].paid      = 0

  elseif actionType == 'TRANSFERRED' then

    PlayerData.Properties[propertyId].citizenid = data[1]

  elseif actionType == 'SOLD' then

    PlayerData.Properties[propertyId].citizenid  = nil
    PlayerData.Properties[propertyId].duration   = 0
    PlayerData.Properties[propertyId].paid       = 0
    PlayerData.Properties[propertyId].owned      = 0
    PlayerData.Properties[propertyId].keyholders = {}
    PlayerData.Properties[propertyId].ledger = 0

    RemoveBlip(PlayerData.Properties[propertyId].blip)

    PlayerData.Properties[propertyId].blip     = nil
    PlayerData.Properties[propertyId].blipType = nil

  elseif actionType == 'LOCATION' then

    local locationCoords = { x = data[2].x, y = data[2].y, z = data[2].z }

    if data[1] == 'MENU_WARDROBE_LOCATION' then
      PlayerData.Properties[propertyId].wardrobe = locationCoords
    elseif data[1] == 'MENU_STORAGE_LOCATION' then
      PlayerData.Properties[propertyId].storage = locationCoords
    end

  elseif actionType == "PAID" then

    PlayerData.Properties[propertyId].paid = tonumber(data[1])

  elseif actionType == "LEDGER" then

    PlayerData.Properties[propertyId].ledger = tonumber(data[1])

  elseif actionType == "LEDGERHOME" then

    PlayerData.Properties[propertyId].ledgerhome = tonumber(data[1])

  elseif actionType == 'ADDED_KEYHOLDER' then

    local citizenid = data[1]
    local username  = data[2]

    PlayerData.Properties[propertyId].keyholders[citizenid]             = {}
    PlayerData.Properties[propertyId].keyholders[citizenid].username    = username
    PlayerData.Properties[propertyId].keyholders[citizenid].citizenid   = citizenid

    PlayerData.Properties[propertyId].keyholders[citizenid].permissions = {
      ['ledger_deposit']       = 0,
      ['keyholders']           = 0,
      ['set_wardrobe']         = 0,
      ['set_storage']          = 0,
      ['storage_access']       = 0,
      ['ledgerhome_deposit']   = 0,
      ['ledgerhome_withdraw']  = 0,
      ['place_furniture']      = 0,
    }

  elseif actionType == 'UPDATE_KEYHOLDER_PERMISSION' then

    PlayerData.Properties[propertyId].keyholders[data[1]].permissions[data[2]] = tonumber(data[3])

  elseif actionType == 'REMOVED_KEYHOLDER' then

    PlayerData.Properties[propertyId].keyholders[data[1]] = nil
    PlayerData.IsBusy = false

  end

end)

RegisterNetEvent("rs_housing:client:setBusy")
AddEventHandler("rs_housing:client:setBusy", function(cb)
  PlayerData.IsBusy = cb
end)

Citizen.CreateThread(function()

  RegisterPrompts()

  while true do
    Wait(0)

    local player            = PlayerPedId()
    local isPlayerDead      = IsEntityDead(player)
    local isPaused          = IsPauseMenuActive()
    local isInCimematicMode = Citizen.InvokeNative(0x74F1D22EFA71FAB8)

    local sleep             = true

    if PlayerData.Loaded and not PlayerData.IsBusy and not isPlayerDead and not isPaused and not isInCimematicMode then

      local coords = GetEntityCoords(player)

      for propertyId, property in pairs(PlayerData.Properties) do

        local coordsDist     = vector3(coords.x, coords.y, coords.z)
        local propertyCoords = vector3(property.Locations.PrimaryEntrance.x, property.Locations.PrimaryEntrance.y, property.Locations.PrimaryEntrance.z)
        local distance       = #(coordsDist - propertyCoords)

        if Config.PropertyBlips.OnSale ~= false and property.owned == 0 and property.blip == nil then

          if not Config.PropertyBlips.OnSale.DisplayThroughRenderingDistance or distance <= Config.PropertyBlips.OnSale.DisplayThroughRenderingDistance then
            CreatePropertyBlip(propertyId, "ON_SALE", propertyCoords)
          end

        end

        if Config.PropertyBlips.OnSale ~= false and Config.PropertyBlips.OnSale.DisplayThroughRenderingDistance ~= false and property.blip ~= nil and property.blipType == 'ON_SALE' then

          if distance > Config.PropertyBlips.OnSale.DisplayThroughRenderingDistance then
            RemoveBlip(property.blip)
            property.blip     = nil
            property.blipType = nil
          end

        end

        if property.owned == 1 then

          if property.blip and property.blipType == 'ON_SALE' then
            RemoveBlip(property.blip)
            property.blip     = nil
            property.blipType = nil
          end

          if property.citizenid == PlayerData.CitizenId and property.blip == nil then
            CreatePropertyBlip(propertyId, "OWNED", propertyCoords)
          end

          if Config.PropertyBlips.Keyholders.Enabled and property.blip == nil then
            if HasPropertyAccess(property) and property.citizenid ~= PlayerData.CitizenId then
              CreatePropertyBlip(propertyId, "KEYHOLDER", propertyCoords)
            end
          end

        end

        if distance <= property.Locations.ActionDistance and property.owned == 0 then
          sleep = false

          local purchaseMethods = property.purchaseMethods
          local promptText = ""

          if Config.TaxRepoSystem.Enabled then
            promptText = string.format(
              Locales['PROPERTY_PROMPT_FOOTER'],
              purchaseMethods.dollars.cost,
              property.tax)
          else
            promptText = string.format(
              Locales['PROPERTY_PROMPT_FOOTER_NO_TAX'],
              purchaseMethods.dollars.cost)
          end

          local label = CreateVarString(10, 'LITERAL_STRING', promptText)

          PromptSetActiveGroupThisFrame(Prompts, label)

          for i, prompt in pairs(PromptsList) do

            PromptSetVisible(prompt.prompt, 0)
            PromptSetEnabled(prompt.prompt, 0)

            if prompt.type == "SELL" and Config.RealEstateJob.Enabled and Config.RealEstateJob.Job == PlayerData.Job then
              PromptSetVisible(prompt.prompt, 1)
              PromptSetEnabled(prompt.prompt, 1)
            end

            if prompt.type == "BUY" and purchaseMethods.dollars.cost > 0 then
              PromptSetEnabled(prompt.prompt, 1)
              PromptSetVisible(prompt.prompt, 1)
            end

            if (prompt.type == "BUY") and Config.RealEstateJob.Enabled and Config.RealEstateJob.Job ~= PlayerData.Job then
              PromptSetEnabled(prompt.prompt, 0)
            end

            if PromptHasHoldModeCompleted(prompt.prompt) then

              if prompt.type == 'SELL' then
                ClearPedTasksImmediately(player)
                PlayerData.IsBusy = true

                Wait(500)
                TaskStartScenarioInPlace(player, joaat('WORLD_HUMAN_WRITE_NOTEBOOK'), -1)

                local nearestPlayers = GetNearestPlayers(3.0)
                local foundPlayer    = false

                local input = lib.inputDialog(Locales['REAL_ESTATE_SELL_TITLE'], {
                  {
                    type        = 'number',
                    label       = Locales['REAL_ESTATE_SELL_DESCRIPTION'],
                    required    = true,
                    min         = 1,
                  }
                })

                if input and input[1] then

                  local inputId = tonumber(input[1])

                  if inputId == GetPlayerServerId(PlayerId()) then
                    lib.notify({
                      title       = Locales['HOUSING_NOTI'],
                      description = Locales['REAL_ESTATE_SELL_TO_SELF'],
                      type        = 'error',
                      duration    = 3000,
                      position    = 'top'
                    })
                    PlayerData.IsBusy = false
                    ClearPedTasks(player)
                  else

                    for _, targetPlayer in pairs(nearestPlayers) do
                      if inputId == GetPlayerServerId(targetPlayer) then
                        foundPlayer = true
                      end
                    end

                    if foundPlayer then
                      TriggerServerEvent("rs_housing:server:buySelectedProperty", 'BUY', propertyId, inputId)
                      Wait(2000)
                    else
                      lib.notify({
                        title       = Locales['HOUSING_NOTI'],
                        description = Locales['PLAYER_NOT_FOUND'],
                        type        = 'error',
                        duration    = 3000,
                        position    = 'top'
                      })
                    end

                    PlayerData.IsBusy = false
                    ClearPedTasks(player)

                  end

                else
                  lib.notify({
                    title       = Locales['HOUSING_NOTI'],
                    description = Locales['INVALID_INPUT'],
                    type        = 'error',
                    duration    = 3000,
                    position    = 'top'
                  })
                  PlayerData.IsBusy = false
                  ClearPedTasks(player)
                end

              elseif prompt.type == "BUY" then

                local isPermittedToBuy = IsPermittedToBuy()

                if isPermittedToBuy then
                  TriggerServerEvent("rs_housing:server:buySelectedProperty", prompt.type, propertyId, nil)
                  Wait(2000)
                  TriggerServerEvent("rs_housing:server:requestDoorlocks")
                else
                  lib.notify({
                    title       = Locales['HOUSING_NOTI'],
                    description = Locales['REACHED_MAX_PROPERTIES'],
                    type        = 'error',
                    duration    = 3000,
                    position    = 'top'
                  })
                end

              end

              Wait(1000)

            end
          end

        end

      end

    end

    if sleep then
      Wait(1000)
    end

  end

end)

Citizen.CreateThread(function()

  RegisterMenuPrompts()

  while true do
    Wait(0)

    local player       = PlayerPedId()
    local isPlayerDead = IsEntityDead(player)
    local sleep        = true

    if PlayerData.Loaded and not PlayerData.IsInMenu and not isPlayerDead then

      local coords     = GetEntityCoords(player)
      local coordsDist = vector3(coords.x, coords.y, coords.z)

      for propertyId, property in pairs(PlayerData.Properties) do

        local requiredDistance = property.Locations.ActionDistance
        local locationType     = nil

        if property.storage and property.storage.x then
          local storageVector   = vector3(property.storage.x, property.storage.y, property.storage.z)
          local storageDistance = #(coordsDist - storageVector)
          if storageDistance <= requiredDistance then
            locationType = "STORAGE"
          end
        end

        if property.wardrobe and property.wardrobe.x then
          local wardrobeVector   = vector3(property.wardrobe.x, property.wardrobe.y, property.wardrobe.z)
          local wardrobeDistance = #(coordsDist - wardrobeVector)
          if wardrobeDistance <= requiredDistance then
            locationType = "WARDROBE"
          end
        end

        if property.owned == 1 then
          local menuActionsDistance = #(coordsDist - property.Locations.MenuActions)
          if menuActionsDistance <= requiredDistance then
            locationType = "MENU_OPEN"
          end
        end

        if locationType then
          sleep = false

          local literalString = Locales['PROPERTY_PROMPT_' .. locationType .. '_FOOTER']
          local label         = CreateVarString(10, 'LITERAL_STRING', literalString)

          PromptSetActiveGroupThisFrame(MenuPrompts, label)

          for i, prompt in pairs(MenuPromptsList) do

            PromptSetVisible(prompt.prompt, 0)

            if prompt.type == locationType then
              PromptSetVisible(prompt.prompt, 1)
            end

            if PromptHasHoldModeCompleted(prompt.prompt) then

              if prompt.type == 'MENU_OPEN' then

                if HasPropertyAccess(property) then
                  OpenMenuManagement(propertyId)
                else
                  lib.notify({
                    title       = Locales['HOUSING_NOTI'],
                    description = Locales['INSUFFICIENT_PERMISSIONS'],
                    type        = 'error',
                    duration    = 3000,
                    position    = 'top'
                  })
                end

              elseif prompt.type == 'STORAGE' then

                local hasStoragePermissionAccess = HasPermissionByName(propertyId, 'storage_access', PlayerData.CitizenId)

                if Config.StorageAllowPublicAccess or hasStoragePermissionAccess == 1 then
                  TriggerServerEvent("rs_housing:server:openPropertyStorage", propertyId)
                else
                  lib.notify({
                    title       = Locales['HOUSING_NOTI'],
                    description = Locales['INSUFFICIENT_PERMISSIONS'],
                    type        = 'error',
                    duration    = 3000,
                    position    = 'top'
                  })
                end

              elseif prompt.type == 'WARDROBE' then
                TriggerEvent(Config.WardrobeEventTrigger)
              end

              Wait(1500)

            end

          end

        end

      end

    end

    if sleep then
      Wait(1000)
    end

  end

end)

Citizen.CreateThread(function()

    RegisterTeleportPrompts()

    while true do
        Wait(0)

        local player       = PlayerPedId()
        local isPlayerDead = IsEntityDead(player)
        local sleep        = true

        if PlayerData.Loaded and not isPlayerDead then

            local coords = GetEntityCoords(player)

            for propertyId, property in pairs(PlayerData.Properties) do

                if property.hasTeleportationEntrance then

                    local distanceType    = nil
                    local coordsDist      = vector3(coords.x, coords.y, coords.z)
                    local secondaryCoords = vector3(property.Locations.SecondaryExit.x, property.Locations.SecondaryExit.y, property.Locations.SecondaryExit.z)

                    if property.owned == 1 then
                        local primaryCoords   = vector3(property.Locations.PrimaryEntrance.x, property.Locations.PrimaryEntrance.y, property.Locations.PrimaryEntrance.z)
                        local primaryDistance = #(coordsDist - primaryCoords)
                        if primaryDistance <= property.Locations.ActionDistance then
                            distanceType = "PRIMARY"
                        end
                    end

                    local secondaryDistance = #(coordsDist - secondaryCoords)
                    if secondaryDistance <= property.Locations.ActionDistance then
                        distanceType = "SECONDARY"
                    end

                    if distanceType then
                        sleep = false

                        local label = CreateVarString(10, 'LITERAL_STRING', Config.PromptKeys['TELEPORT'].label)
                        PromptSetActiveGroupThisFrame(TeleportPrompts, label)

                        local keystr = CreateVarString(10, 'LITERAL_STRING', Locales['PROPERTY_TELEPORT_PROMPT_FOOTER_' .. distanceType])
                        PromptSetText(TeleportPromptsList, keystr)

                        if PromptHasHoldModeCompleted(TeleportPromptsList) then

                            FreezeEntityPosition(PlayerPedId(), true)

                            if distanceType == "PRIMARY" then

                                if HasPropertyAccess(property) then
                                    local teleportCoords = property.Locations.SecondaryExit
                                    TeleportToCoords(teleportCoords.x, teleportCoords.y, teleportCoords.z, teleportCoords.w)
                                    Wait(1000)
                                    FreezeEntityPosition(PlayerPedId(), false)
                                else
                                    lib.notify({
                                      title       = Locales['HOUSING_NOTI'],
                                      description = Locales['NOT_ALLOWED_TO_ENTER'],
                                      type        = 'error',
                                      duration    = 3000,
                                      position    = 'top'
                                    })
                                    FreezeEntityPosition(PlayerPedId(), false)
                                    Wait(1000)
                                end

                            elseif distanceType == "SECONDARY" then

                                local teleportCoords = property.Locations.PrimaryEntrance
                                TeleportToCoords(teleportCoords.x, teleportCoords.y, teleportCoords.z, teleportCoords.w)
                                Wait(1000)
                                FreezeEntityPosition(PlayerPedId(), false)

                            end

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