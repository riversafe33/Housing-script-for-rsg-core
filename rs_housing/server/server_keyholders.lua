local RSGCore = exports['rsg-core']:GetCoreObject()

local function GetTableLength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

local function GetPlayerData(source)
  local _source = source
  local xPlayer = RSGCore.Functions.GetPlayer(_source)

  if not xPlayer then return nil end

  return {
    citizenid  = xPlayer.PlayerData.citizenid,
    money      = xPlayer.PlayerData.money['cash'],
    job        = xPlayer.PlayerData.job.name,
    firstname  = xPlayer.PlayerData.charinfo.firstname,
    lastname   = xPlayer.PlayerData.charinfo.lastname,
    group      = xPlayer.PlayerData.group,
    steamName  = GetPlayerName(_source),
  }
end

RegisterServerEvent("rs_housing:server:addPropertyKeyholder")
AddEventHandler("rs_housing:server:addPropertyKeyholder", function(propertyId, playerId)

    local _source  = source
    local _tsource = tonumber(playerId)

    local Properties = GetProperties()

    if not Properties[propertyId] or not _tsource then return end

    if GetPlayerName(_tsource) == nil then
        TriggerClientEvent('rs_housing:ShowAdvancedNotification', _source, Locales['HOUSING_NOTI'], Locales['PLAYER_NOT_VALID'], "menu_textures", "cross", 3000, "COLOR_RED")
        return
    end

    if _tsource == _source then
      TriggerClientEvent('rs_housing:ShowAdvancedNotification', _source, Locales['HOUSING_NOTI'], Locales['MENU_KEYHOLDERS_ADD_NEW_TO_SELF'], "menu_textures", "cross", 3000, "COLOR_RED")
      return
    end

    local property   = Properties[propertyId]
    local PlayerData = GetPlayerData(_tsource)

    if not PlayerData then
        TriggerClientEvent('rs_housing:ShowAdvancedNotification', _source, Locales['HOUSING_NOTI'], Locales['PLAYER_NOT_VALID'], "menu_textures", "cross", 3000, "COLOR_RED")
        return
    end

    local citizenid = PlayerData.citizenid

    if property.keyholders[citizenid] then
        TriggerClientEvent('rs_housing:ShowAdvancedNotification', _source, Locales['HOUSING_NOTI'], Locales['MENU_KEYHOLDERS_ALREADY_EXISTS'], "menu_textures", "cross", 3000, "COLOR_RED")
        return
    end

    local username = PlayerData.firstname .. " " .. PlayerData.lastname

    property.keyholders[citizenid] = {
        username  = username,
        citizenid = citizenid,
        permissions = {
            ledger_deposit      = 0,
            ledgerhome_deposit  = 0,
            ledgerhome_withdraw = 0,
            keyholders          = 0,
            set_wardrobe        = 0,
            set_storage         = 0,
            storage_access      = 0,
            place_furniture     = 0,
        }
    }

    exports.oxmysql:execute(
        'UPDATE properties SET keyholders = ? WHERE name = ?',
        {
            json.encode(property.keyholders),
            propertyId
        }
    )

    TriggerClientEvent('rs_housing:ShowAdvancedNotification', _source, Locales['HOUSING_NOTI'], string.format(Locales['MENU_KEYHOLDERS_ADDED'], username),"generic_textures", "tick", 3000, "COLOR_GREEN")

    if not property.hasTeleportationEntrance then
        TriggerEvent("rs_housing:server:updateDoorlockInformation", propertyId, 'REGISTER_KEYHOLDER', { citizenid, username })
    end

    TriggerClientEvent("rs_housing:client:updateProperty", -1, propertyId, 'ADDED_KEYHOLDER', { citizenid, username })

end)

RegisterServerEvent("rs_housing:server:removePropertyKeyholder")
AddEventHandler("rs_housing:server:removePropertyKeyholder", function(propertyId, citizenid, username)

  local _source = source

  local Properties = GetProperties()

  if not Properties[propertyId] then return end

  if not Properties[propertyId].keyholders[citizenid] then
    TriggerClientEvent('rs_housing:ShowAdvancedNotification', _source, Locales['HOUSING_NOTI'], Locales['MENU_KEYHOLDERS_DOES_NOT_EXISTS'], "menu_textures", "cross", 3000, "COLOR_RED")
    return
  end

  local property = Properties[propertyId]

  TriggerClientEvent('rs_housing:ShowAdvancedNotification', _source, Locales['HOUSING_NOTI'], string.format(Locales['MENU_KEYHOLDERS_REMOVED'], username), "menu_textures", "cross", 3000, "COLOR_RED")

  if not property.hasTeleportationEntrance then
    TriggerEvent("rs_housing:server:updateDoorlockInformation", propertyId, 'UNREGISTER_KEYHOLDER', { citizenid })
  end

  Properties[propertyId].keyholders[citizenid] = nil

  exports.oxmysql:execute(
    'UPDATE properties SET keyholders = ? WHERE name = ?',
    {
      json.encode(Properties[propertyId].keyholders),
      propertyId
    }
  )

  TriggerClientEvent("rs_housing:client:updateProperty", -1, propertyId, 'REMOVED_KEYHOLDER', { citizenid })

end)

RegisterServerEvent('rs_housing:server:onMembersPermissionUpdate')
AddEventHandler('rs_housing:server:onMembersPermissionUpdate', function(propertyId, citizenid, permission)

  local _source = source

  local Properties = GetProperties()

  if Properties[propertyId] == nil then return end

  local Property = Properties[propertyId]

  if Property.keyholders[citizenid] == nil then return end

  local KeyholderData = Property.keyholders[citizenid]

  KeyholderData.permissions[permission] =
  KeyholderData.permissions[permission] == 0 and 1 or 0

  local newValue = KeyholderData.permissions[permission]

  exports.oxmysql:execute(
    'UPDATE properties SET keyholders = ? WHERE name = ?',
    {
      json.encode(Property.keyholders),
      propertyId
    }
  )

  TriggerClientEvent("rs_housing:client:updateProperty", -1, propertyId, 'UPDATE_KEYHOLDER_PERMISSION', 
    {
      citizenid, 
      permission, 
      newValue
    }
  )
end)

