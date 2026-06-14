local RSGCore = exports['rsg-core']:GetCoreObject()

local Properties  = {}
local LoadedProperties = false

local function notiMainSuccess(source, title, message)
    TriggerClientEvent('ox_lib:notify', source, {
        title       = title,
        description = message,
        type        = 'success',
        duration    = 4000,
        position    = 'top'
    })
end

local function notiMainError(source, title, message)
    TriggerClientEvent('ox_lib:notify', source, {
        title       = title,
        description = message,
        type        = 'error',
        duration    = 3000,
        position    = 'top'
    })
end

local function GetTableLength(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

local function LoadProperties()
    local length = GetTableLength(Config.Properties)

    if length == 0 then
        LoadedProperties = true
        return
    end

    local loaded = 0

    for _, property in pairs(Config.Properties) do

        Properties[_] = {}
        Properties[_] = property
        Properties[_].name = _

        exports["ghmattimysql"]:execute("SELECT * FROM `properties` WHERE name = @name", { ["@name"] = _ }, function(result)

            Properties[_].citizenid   = nil
            Properties[_].storage     = {}
            Properties[_].wardrobe    = {}
            Properties[_].keyholders  = {}
            Properties[_].ledger      = 0
            Properties[_].ledgerhome  = 0
            Properties[_].owned       = 0
            Properties[_].duration    = 0
            Properties[_].paid        = 0

            if result[1] and result[1].name then

                local res = result[1]

                Properties[_].citizenid   = res.citizenid
                Properties[_].storage     = json.decode(res.storage)
                Properties[_].wardrobe    = json.decode(res.wardrobe)
                Properties[_].keyholders  = json.decode(res.keyholders)
                Properties[_].ledger      = res.ledger
                Properties[_].ledgerhome  = res.ledgerhome
                Properties[_].owned       = res.owned
                Properties[_].duration    = res.duration
                Properties[_].paid        = res.paid

            else
                exports.ghmattimysql:execute("INSERT INTO `properties` (`name`) VALUES (@name)", { ['name'] = _ })
            end

            if not property.hasTeleportationEntrance then
                for i, doors in pairs(property.doors) do
                    TriggerEvent("rs_housing:server:registerNewDoorlock", _, doors, property.canBreakIn, Properties[_].keyholders, Properties[_].citizenid)
                end
            end

            loaded = loaded + 1
            if loaded >= length then
                LoadedProperties = true
            end

        end)

    end
end

local function IsPermittedToBuy(citizenid)
    local cb = 0
    for _, property in pairs(Properties) do
        if property.citizenid == citizenid and property.owned == 1 then
            cb = cb + 1
        end
    end
    return (cb < Config.MaxHouses)
end

local function GetPlayerData(source)
    local _source = source
    local xPlayer = RSGCore.Functions.GetPlayer(_source)

    if not xPlayer then return nil end

    return {
        citizenid = xPlayer.PlayerData.citizenid,
        money     = xPlayer.PlayerData.money['cash'],
        job       = xPlayer.PlayerData.job.name,
        group     = xPlayer.PlayerData.group,
        steamName = GetPlayerName(_source),
    }
end

function GetProperties()
    return Properties
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(Config.StartQueryDelay)
    LoadProperties()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Properties = nil
end)

RegisterServerEvent("rs_housing:server:requestPlayerData")
AddEventHandler("rs_housing:server:requestPlayerData", function()
    local _source = source

    while not LoadedProperties do
        Wait(1000)
    end

    local xPlayer = RSGCore.Functions.GetPlayer(_source)
    if not xPlayer then return end

    local PlayerData = GetPlayerData(_source)
    if not PlayerData then return end

    for _, property in pairs(Properties) do
        if property.keyholders[PlayerData.citizenid] then
            property.keyholders[PlayerData.citizenid].source = _source
            print('added source on property #' .. _)
        end
    end

    TriggerClientEvent("rs_housing:client:updatePlayerData", _source, {
        PlayerData.citizenid,
        PlayerData.job,
        Properties
    })
end)

AddEventHandler('playerDropped', function(reason)
    local _source = source
    for _, property in pairs(Properties) do
        for k, keyholder in pairs(property.keyholders) do
            if tonumber(keyholder.source) == _source then
                keyholder.source = nil
            end
        end
    end
end)

RegisterNetEvent("rs_housing:client:updateLedgerHome")
AddEventHandler("rs_housing:client:updateLedgerHome", function(propertyId, amount)
    if not PlayerData.Properties[propertyId] then return end
    PlayerData.Properties[propertyId].ledgerhome = amount
end)

RegisterServerEvent("rs_housing:server:buySelectedProperty")
AddEventHandler("rs_housing:server:buySelectedProperty", function(actionType, propertyId, target)
    local _source  = source
    local _tsource = source

    if Properties[propertyId] == nil then return end

    local xPlayer    = RSGCore.Functions.GetPlayer(_source)
    local PlayerData = GetPlayerData(_source)

    if not PlayerData then return end

    local citizenid = PlayerData.citizenid
    local steamName = PlayerData.steamName

    if target then
        _tsource = tonumber(target)
        local tPlayerData = GetPlayerData(_tsource)
        if not tPlayerData then return end
        citizenid = tPlayerData.citizenid
        steamName = tPlayerData.steamName
    end

    local tPlayer = RSGCore.Functions.GetPlayer(_tsource)
    if not tPlayer then return end

    if not IsPermittedToBuy(citizenid) then
        notiMainError(_tsource, Locales['HOUSING_NOTI'], Locales['REACHED_MAX_PROPERTIES'])
        if target then
            notiMainError(_source, Locales['HOUSING_NOTI'], Locales['TARGET_REACHED_MAX_PROPERTIES'])
        end
        return
    end

    local property     = Properties[propertyId]
    local currentMoney = tPlayer.PlayerData.money['cash']
    local cost         = property.purchaseMethods.dollars.cost
    local hasEnough    = cost <= currentMoney

    if not hasEnough then
        notiMainError(_tsource, Locales['HOUSING_NOTI'], Locales['NOT_ENOUGH_MONEY'])
        if target then
            notiMainError(_source, Locales['HOUSING_NOTI'], Locales['TARGET_NOT_ENOUGH_MONEY'])
        end
        return
    end

    if target and Config.RealEstateJob.Enabled and Config.RealEstateJob.Job == PlayerData.job then
        local rewardAmount = cost - math.floor(cost * Config.RealEstateJob.ReceivePercentage / 100)
        local notifyData   = ""
        if actionType == "BUY" then
            xPlayer.Functions.AddMoney('cash', rewardAmount)
            notifyData = Locales['REAL_ESTATE_SUCCESSFULLY_SOLD_DOLLARS']
        end
        notiMainSuccess(_source, Locales['HOUSING_NOTI'], string.format(notifyData, rewardAmount))
    end

    Properties[propertyId].citizenid = citizenid
    Properties[propertyId].owned     = 1
    Properties[propertyId].duration  = 0
    Properties[propertyId].paid      = 0

    if not Properties[propertyId].hasTeleportationEntrance then
        TriggerEvent("rs_housing:server:updateDoorlockInformation", propertyId, 'TRANSFERRED', { citizenid })
    end

    TriggerClientEvent("rs_housing:client:updateProperty", -1, propertyId, "BUY", { citizenid })

    local Parameters = {
        ['name']      = propertyId,
        ['citizenid'] = citizenid,
        ['owned']     = 1,
        ['duration']  = 0,
        ['paid']      = 0,
    }

    exports.ghmattimysql:execute("UPDATE `properties` SET `citizenid` = @citizenid, `owned` = @owned, `duration` = @duration, `paid` = @paid WHERE name = @name", Parameters)
    
    notiMainSuccess(_source, Locales['HOUSING_NOTI'], Locales['SUCCESSFULLY_BOUGHT_PROPERTY'])

    if actionType == "BUY" then
        tPlayer.Functions.RemoveMoney('cash', cost)
    end

    local webhookData = Config.Webhooking['BOUGHT']
    if webhookData.Enabled then
        local title   = "🏠`Property Bought`"
        local message = string.format("The following property with id: **`( %s )`** has been bought by: `%s`.", propertyId, steamName)
        RSGCore.Functions.TriggerCallback('rsg-core:server:DiscordWebhook', false, webhookData.Url, title, message, webhookData.Color)
    end
end)

RegisterServerEvent("rs_housing:server:sell")
AddEventHandler("rs_housing:server:sell", function(propertyId)
    local _source = source

    if Properties[propertyId] == nil then return end

    local xPlayer    = RSGCore.Functions.GetPlayer(_source)
    local PlayerData = GetPlayerData(_source)

    if not PlayerData then return end

    local steamName = PlayerData.steamName

    Properties[propertyId].citizenid  = nil
    Properties[propertyId].duration   = 0
    Properties[propertyId].paid       = 0
    Properties[propertyId].owned      = 0
    Properties[propertyId].keyholders = {}
    Properties[propertyId].ledger     = 0

    local Parameters = {
        ['name']       = propertyId,
        ['citizenid']  = nil,
        ['keyholders'] = "[]",
        ['ledger']     = Properties[propertyId].ledger,
        ['duration']   = 0,
        ['paid']       = 0,
        ['owned']      = 0,
    }

    exports.ghmattimysql:execute("UPDATE `properties` SET `citizenid` = @citizenid, `keyholders` = @keyholders, `ledger` = @ledger, `duration` = @duration, `paid` = @paid, `owned` = @owned WHERE name = @name", Parameters)

    TriggerClientEvent("rs_housing:client:updateProperty", -1, propertyId, 'SOLD')

    local property      = Properties[propertyId]
    local receiveAmount = property.sell.receive

    if not Properties[propertyId].hasTeleportationEntrance then
        TriggerEvent("rs_housing:server:updateDoorlockInformation", propertyId, 'RESET', { 1 })
    end

    if receiveAmount > 0 then
        xPlayer.Functions.AddMoney('cash', receiveAmount)
        notiMainSuccess(_source, Locales['HOUSING_NOTI'], string.format(Locales['SOLD_PROPERTY_RECEIVED_DOLLARS'], receiveAmount))
    else
        notiMainSuccess(_source, Locales['HOUSING_NOTI'], Locales['SOLD_PROPERTY'])
    end

    local webhookData = Config.Webhooking['SOLD']
    if webhookData.Enabled then
        local title   = "🏠`Property Sold`"
        local message = string.format("The following property with id: **`( %s )`** has been placed for sale.\n\nPlayer `%s` received: %s dollars.", propertyId, steamName, receiveAmount)
        RSGCore.Functions.TriggerCallback('rsg-core:server:DiscordWebhook', false, webhookData.Url, title, message, webhookData.Color)
    end
end)

RegisterServerEvent('rs_housing:server:updateAccountLedgerById')
AddEventHandler('rs_housing:server:updateAccountLedgerById', function(propertyId, transactionType, amount)
    local _source = source
    local xPlayer = RSGCore.Functions.GetPlayer(_source)

    if not xPlayer then return end
    if Properties[propertyId] == nil then return end

    local propertyData = Properties[propertyId]
    local currentMoney = xPlayer.PlayerData.money['cash']

    if transactionType == 'DEPOSIT' and currentMoney < amount then
        notiMainError(_source, Locales['HOUSING_NOTI'], Locales['NOT_ENOUGH_MONEY_LEDGER_DEPOSIT'])
        return
    end

    if transactionType == 'DEPOSIT' and propertyData.tax ~= nil then
        if (propertyData.ledger + amount) > propertyData.tax then
            notiMainError(_source, Locales['HOUSING_NOTI'], Locales['MONEY_LEDGER_DEPOSIT_LIMIT'])
            return
        end
    end

    if transactionType == 'DEPOSIT' then
        xPlayer.Functions.RemoveMoney('cash', amount)
        Properties[propertyId].ledger = Properties[propertyId].ledger + amount
        notiMainSuccess(_source, Locales['HOUSING_NOTI'], string.format(Locales['LEDGER_DEPOSITED_ACCOUNT_MONEY'], amount))
    end

    Wait(500)
    TriggerClientEvent("rs_housing:client:updateProperty", _source, propertyId, 'LEDGER', { Properties[propertyId].ledger })

    if GetTableLength(Properties[propertyId].keyholders) > 0 then
        for index, keyholder in pairs(Properties[propertyId].keyholders) do
            if keyholder.source ~= nil
            and tonumber(keyholder.source) ~= 0
            and GetPlayerName(tonumber(keyholder.source)) ~= nil
            and tonumber(keyholder.source) ~= _source then
                TriggerClientEvent("rs_housing:client:updateProperty", tonumber(keyholder.source), propertyId, 'LEDGER', { Properties[propertyId].ledger })
            end
        end
    end
end)

RegisterServerEvent("rs_housing:server:transferOwnedProperty")
AddEventHandler("rs_housing:server:transferOwnedProperty", function(propertyId, targetSource)
    local _source = source

    targetSource = tonumber(targetSource)

    if Properties[propertyId] == nil then return end

    local tPlayerData = GetPlayerData(targetSource)
    if not tPlayerData then return end

    local citizenid  = tPlayerData.citizenid
    local targetName = tPlayerData.steamName

    if not IsPermittedToBuy(citizenid) then
        notiMainError(_source, Locales['HOUSING_NOTI'], Locales['TARGET_REACHED_MAX_PROPERTIES'])
        notiMainError(targetSource, Locales['HOUSING_NOTI'], Locales['REACHED_MAX_PROPERTIES'])
        return
    end

    Properties[propertyId].citizenid = citizenid

    local Parameters = {
        ['name']      = propertyId,
        ['citizenid'] = citizenid,
    }

    exports.ghmattimysql:execute("UPDATE `properties` SET `citizenid` = @citizenid WHERE name = @name", Parameters)

    TriggerClientEvent("rs_housing:client:updateProperty", _source,      propertyId, 'TRANSFERRED', { citizenid })
    TriggerClientEvent("rs_housing:client:updateProperty", targetSource, propertyId, 'TRANSFERRED', { citizenid })

    if not Properties[propertyId].hasTeleportationEntrance then
        TriggerEvent("rs_housing:server:updateDoorlockInformation", propertyId, 'TRANSFERRED', { citizenid })
    end

    notiMainSuccess(_source, Locales['HOUSING_NOTI'], Locales['TRANSFERRED_PROPERTY'])
    notiMainSuccess(targetSource, Locales['HOUSING_NOTI'], Locales['TRANSFERRED_PROPERTY_TO_SELF'])

    local webhookData = Config.Webhooking['TRANSFERRED']
    if webhookData.Enabled then
        local title   = "🏠`Property Transferred`"
        local message = string.format("The following property with id: **`( %s )`** has been transferred to: `%s`.", propertyId, targetName)
        RSGCore.Functions.TriggerCallback('rsg-core:server:DiscordWebhook', false, webhookData.Url, title, message, webhookData.Color)
    end
end)

RegisterServerEvent('rs_housing:server:updateAccountLedgerHomeById')
AddEventHandler('rs_housing:server:updateAccountLedgerHomeById', function(propertyId, transactionType, amount)
    local _source = source
    local xPlayer = RSGCore.Functions.GetPlayer(_source)

    if not xPlayer then return end
    if Properties[propertyId] == nil then return end

    local propertyData = Properties[propertyId]
    local currentMoney = xPlayer.PlayerData.money['cash']

    if transactionType == 'DEPOSIT' and currentMoney < amount then
        notiMainError(_source, Locales['HOUSING_NOTI'], Locales['NOT_ENOUGH_MONEY_LEDGER_DEPOSIT'])
        return
    end

    if transactionType == 'DEPOSIT' and propertyData.ledgerLimit ~= nil then
        if (propertyData.ledgerhome + amount) > propertyData.ledgerLimit then
            notiMainError(_source, Locales['HOUSING_NOTI'], Locales['MONEY_LEDGER_DEPOSIT_LIMIT'])
            return
        end
    end

    if transactionType == 'WITHDRAW' and propertyData.ledgerhome < amount then
        notiMainError(_source, Locales['HOUSING_NOTI'], Locales['NOT_ENOUGH_MONEY_LEDGER_WITHDRAW'])
        return
    end

    if transactionType == 'DEPOSIT' then
        xPlayer.Functions.RemoveMoney('cash', amount)
        Properties[propertyId].ledgerhome = Properties[propertyId].ledgerhome + amount
        notiMainSuccess(_source, Locales['HOUSING_NOTI'], string.format(Locales['LEDGER_DEPOSITED_ACCOUNT_MONEY'], amount))
    else
        xPlayer.Functions.AddMoney('cash', amount)
        Properties[propertyId].ledgerhome = Properties[propertyId].ledgerhome - amount
        notiMainSuccess(_source, Locales['HOUSING_NOTI'], string.format(Locales['LEDGER_WITHDREW_ACCOUNT_MONEY'], amount))
    end

    exports.ghmattimysql:execute(
        "UPDATE properties SET ledgerhome = @ledger WHERE name = @property",
        {
            ["@property"] = propertyId,
            ["@ledger"]   = Properties[propertyId].ledgerhome
        }
    )

    TriggerClientEvent("rs_housing:client:updateProperty", _source, propertyId, 'LEDGERHOME', { Properties[propertyId].ledgerhome })

    if GetTableLength(Properties[propertyId].keyholders) > 0 then
        for index, keyholder in pairs(Properties[propertyId].keyholders) do
            if keyholder.source ~= nil
            and tonumber(keyholder.source) ~= 0
            and GetPlayerName(tonumber(keyholder.source)) ~= nil
            and tonumber(keyholder.source) ~= _source then
                TriggerClientEvent("rs_housing:client:updateProperty", tonumber(keyholder.source), propertyId, 'LEDGERHOME', { Properties[propertyId].ledgerhome })
            end
        end
    end
end)

RegisterServerEvent("rs_housing:server:setPropertyLocationByType")
AddEventHandler("rs_housing:server:setPropertyLocationByType", function(propertyId, actionType, coords)
    if Properties[propertyId] == nil then return end

    local locationCoords = { x = coords.x, y = coords.y, z = coords.z }

    if actionType == 'MENU_WARDROBE_LOCATION' then
        Properties[propertyId].wardrobe = locationCoords
    elseif actionType == 'MENU_STORAGE_LOCATION' then
        Properties[propertyId].storage = locationCoords
    end

    TriggerClientEvent("rs_housing:client:updateProperty", -1, propertyId, 'LOCATION', { actionType, locationCoords })
end)

local CurrentTime = 0

Citizen.CreateThread(function()
    while true do
        Wait(60000)

        local time        = os.date("*t")
        local currentTime = table.concat({ time.hour, time.min }, ":")
        local finished    = false
        local shouldSave  = false

        for index, restartHour in pairs(Config.RestartHours) do
            if currentTime == restartHour then
                shouldSave = true
            end
            if next(Config.RestartHours, index) == nil then
                finished = true
            end
        end

        while not finished do
            Wait(1000)
        end

        CurrentTime = CurrentTime + 1

        if Config.SaveDataRepeatingTimer.Enabled and CurrentTime == Config.SaveDataRepeatingTimer.Duration then
            CurrentTime = 0
            shouldSave  = true
        end

        if shouldSave then
            local length = GetTableLength(Properties)

            if length > 0 then
                for _, property in pairs(Properties) do

                    local newKeyholdersList = property.keyholders

                    if newKeyholdersList and GetTableLength(newKeyholdersList) > 0 then
                        for index, keyholder in pairs(newKeyholdersList) do
                            keyholder.source = nil
                        end
                    end

                    local Parameters = {
                        ['name']       = property.name,
                        ['citizenid']  = property.citizenid,
                        ['storage']    = json.encode(property.storage),
                        ['wardrobe']   = json.encode(property.wardrobe),
                        ['ledger']     = property.ledger,
                        ['keyholders'] = json.encode(newKeyholdersList),
                        ['owned']      = property.owned,
                        ['duration']   = property.duration,
                        ['paid']       = property.paid,
                    }

                    exports.ghmattimysql:execute(
                        "UPDATE `properties` SET `citizenid` = @citizenid, `storage` = @storage,"
                        .. " `wardrobe` = @wardrobe, `ledger` = @ledger, `keyholders` = @keyholders,"
                        .. " `owned` = @owned, `duration` = @duration, `paid` = @paid WHERE name = @name",
                        Parameters
                    )
                end

                if Config.Debug then
                    print("Successfully saved " .. length .. ' properties.')
                end
            end
        end
    end
end)

if Config.TaxRepoSystem and Config.TaxRepoSystem.Enabled then

    local function ProcessTaxRepo()
        local length = GetTableLength(Properties)
        if length == 0 then return end

        for id, property in pairs(Properties) do
            if property.owned == 1 then

                if not property.tax or property.tax <= 0 then
                    goto continue
                end

                if property.ledger < property.tax then

                    Properties[id].citizenid  = nil
                    Properties[id].owned      = 0
                    Properties[id].keyholders = {}
                    Properties[id].ledger     = 0

                    local Parameters = {
                        ['name']       = id,
                        ['citizenid']  = nil,
                        ['keyholders'] = "[]",
                        ['ledger']     = 0,
                        ['duration']   = 0,
                        ['owned']      = 0,
                    }

                    exports.ghmattimysql:execute(
                        "UPDATE `properties` SET `citizenid` = @citizenid, `keyholders` = @keyholders,"
                        .. " `ledger` = @ledger, `duration` = @duration, `owned` = @owned WHERE name = @name",
                        Parameters
                    )

                    TriggerClientEvent("rs_housing:client:updateProperty", -1, id, 'SOLD')

                    if not Properties[id].hasTeleportationEntrance then
                        TriggerEvent("rs_housing:server:updateDoorlockInformation", id, 'RESET', { 0 })
                    end

                else
                    -- Tiene suficiente → descontar Y GUARDAR EN BD
                    Properties[id].ledger = property.ledger - property.tax

                    exports.ghmattimysql:execute(
                        "UPDATE `properties` SET `ledger` = @ledger WHERE name = @name",
                        { ['name'] = id, ['ledger'] = Properties[id].ledger }
                    )
                end

                ::continue::
            end
        end
    end

    Citizen.CreateThread(function()
        while true do
            Wait(60000)

            local now  = os.time()
            local date = os.date("*t", now)

            local day  = date.day
            local hour = date.hour
            local min  = date.min

            if Config.TaxRepoSystem.Monthly then
                if day  == Config.TaxRepoSystem.Day
                and hour == Config.TaxRepoSystem.Hour
                and min  == Config.TaxRepoSystem.Minute then
                    ProcessTaxRepo()
                end
            end

            if Config.TaxRepoSystem.Weekly then
                for _, repoDay in ipairs(Config.TaxRepoSystem.WeekDays) do
                    if day  == repoDay
                    and hour == Config.TaxRepoSystem.Hour
                    and min  == Config.TaxRepoSystem.Minute then
                        ProcessTaxRepo()
                        break
                    end
                end
            end
        end
    end)
end

RegisterServerEvent("rs_housing:server:openPropertyStorage")
AddEventHandler("rs_housing:server:openPropertyStorage", function(propertyId)
    local _source = source
    if Properties[propertyId] == nil then return end

    local property = Properties[propertyId]
    local stashId  = "inventoryhome_" .. propertyId

    exports["rsg-inventory"]:OpenInventory(_source, stashId, {
        label     = Locales['PROPERTY_INVENTORY'] .. " " .. propertyId,
        maxweight = property.defaultStorageWeight,
        slots     = property.defaultStorageSlots or 50
    })
end)