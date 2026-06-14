local RSGCore = exports['rsg-core']:GetCoreObject()

local DoorsList = {}

local function GetTableLength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

AddEventHandler('onResourceStop', function(resourceName)
  if GetCurrentResourceName() ~= resourceName then
    return
  end
  DoorsList = nil
end)

RegisterServerEvent("rs_housing:server:requestDoorlocks")
AddEventHandler("rs_housing:server:requestDoorlocks", function()
  local _source = source

  if GetTableLength(DoorsList) <= 0 then
    return
  end

  TriggerClientEvent("rs_housing:client:loadDoorsList", _source, DoorsList)
end)


RegisterServerEvent("rs_housing:server:registerNewDoorlock")
AddEventHandler("rs_housing:server:registerNewDoorlock", function(locationId, doors, canBreakIn, keyholders, citizenid)

  local length = GetTableLength(DoorsList)
  local doorId = length + 1

  DoorsList[doorId]            = {}

  DoorsList[doorId].index      = doorId

  DoorsList[doorId].doors      = doors
  DoorsList[doorId].locked     = true

  DoorsList[doorId].distance   = 1.8

  DoorsList[doorId].canBreakIn = canBreakIn
  DoorsList[doorId].locationId = locationId

  DoorsList[doorId].keyholders = keyholders

  local isPropertyOwned        = (not citizenid) and 0 or 1

  DoorsList[doorId].owned      = isPropertyOwned
  DoorsList[doorId].citizenid  = citizenid

  TriggerClientEvent("rs_housing:client:registerNewDoorlock", -1, doorId, doors, canBreakIn, keyholders, isPropertyOwned, citizenid, locationId)

end)


RegisterServerEvent("rs_housing:server:updateDoorlockInformation")
AddEventHandler("rs_housing:server:updateDoorlockInformation", function(locationId, actionType, data)

  for _, door in pairs(DoorsList) do

    if door.locationId == locationId then

      if actionType == 'TRANSFERRED' then

        DoorsList[_].citizenid = data[1]
        DoorsList[_].owned     = 1

      elseif actionType == 'RESET' then

        DoorsList[_].citizenid  = nil
        DoorsList[_].keyholders = {}
        DoorsList[_].owned      = 0

        if tonumber(data[1]) then
          TriggerClientEvent('rs_housing:client:setState', -1, _, false)
        end

      elseif actionType == 'REGISTER_KEYHOLDER' then

        DoorsList[_].keyholders[data[1]]          = {}
        DoorsList[_].keyholders[data[1]].username = data[2]

      elseif actionType == 'UNREGISTER_KEYHOLDER' then

        DoorsList[_].keyholders[data[1]] = nil

      end

    end

  end

  TriggerClientEvent("rs_housing:client:doors:update", -1, locationId, actionType, data)

end)


RegisterServerEvent('rs_housing:server:updateState')
AddEventHandler('rs_housing:server:updateState', function(doorID, state)

  if type(doorID) ~= 'number' then
    return
  end

  TriggerClientEvent('rs_housing:client:setState', -1, doorID, state)
end)