local MenuData = {}

TriggerEvent("rsg-menubase:getData", function(call)
    MenuData = call
end)

local LocationType    = nil
local CurrentProperty = nil

local GetFixedString = function (string, boolean)
    
    local cb = "<font color=#8B0000>" .. string .. "</font>"

    if tonumber(boolean) == 1 then 
        cb = "<font color= rgb(46, 204, 113);>" .. string .. "</font>"
    end

    return cb
end

function OpenMenuManagement(propertyId)

    local PlayerData = GetPlayerData()

    if LocationType then
        return
    end

    MenuData.CloseAll()

    if CurrentProperty == nil then
        CurrentProperty = propertyId
    end

    PlayerData.IsInMenu = true

    local property = PlayerData.Properties[CurrentProperty]

    TaskStandStill(PlayerPedId(), -1)

    local options = {}

    for _, option in pairs(Config.ManagementMenu) do

        -- Saltamos MENU_LEDGER porque lo controlaremos manualmente
        if option.Type ~= "MENU_LEDGER" and option.Enabled then

            local description = Locales[option.Type .. "_DESCRIPTION"]

            if option.Type == 'MENU_SELL' then
                description = string.format(Locales['MENU_SELL_DESCRIPTION_DOLLARS'], property.sell.receive)
            end

            table.insert(options, {
                label = Locales[option.Type],
                value = option.Type,
                desc  = description
            })
        end
    end

    if Config.TaxRepoSystem.Enabled then
        table.insert(options, {
            label = Locales['MENU_LEDGER'],
            value = "MENU_LEDGER",
            desc  = Locales['MENU_LEDGER_DESCRIPTION']
        })
    end

    table.insert(options, {
        label = Locales['MENU_FURNITURE'],
        value = "MENU_FURNITURE",
        desc  = Locales['MENU_FURNITURE_DESCRIPTION']
    })

    table.insert(options, {
        label = Locales['MENU_EXIT'],
        value = "backup",
        desc  = ""
    })

    MenuData.Open('default', GetCurrentResourceName(), 'main',

    {
        title    = string.format(Locales['MENU_PROPERTY_TITLE'], CurrentProperty),
        subtext  = "",
        align    = "right",
        elements = options,
    },

    function(data, menu)
        if (data.current == "backup") then
            return
        end

        if (data.current.value == "backup") then
            MenuData.CloseAll()
            TaskStandStill(PlayerPedId(), 1)

            PlayerData.IsInMenu = false

            CurrentProperty = nil
            return

        elseif (data.current.value == "MENU_WARDROBE_LOCATION") then

            if HasPermissionByName(CurrentProperty, 'set_wardrobe', PlayerData.CitizenId) == 0 then
                exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'], Locales['INSUFFICIENT_PERMISSIONS'], "menu_textures", "cross", 3000, "COLOR_RED")
                return
            end

            MenuData.CloseAll()
            LocationType = string.upper(data.current.value)
            TaskStandStill(PlayerPedId(), 1)

        elseif (data.current.value == "MENU_STORAGE_LOCATION") then

            if HasPermissionByName(CurrentProperty, 'set_storage', PlayerData.CitizenId) == 0 then
                exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'], Locales['INSUFFICIENT_PERMISSIONS'], "menu_textures", "cross", 3000, "COLOR_RED")
                return
            end

            MenuData.CloseAll()
            LocationType = string.upper(data.current.value)
            TaskStandStill(PlayerPedId(), 1)

        elseif (data.current.value == "MENU_LEDGER") then

            OpenMenuLedger()

        elseif (data.current.value == "MENU_LEDGER_HOME") then

            OpenMenuLedgerHome()

        elseif (data.current.value == "MENU_SET_KEYHOLDERS") then

            if HasPermissionByName(CurrentProperty, 'keyholders', PlayerData.CitizenId) == 0 then
                exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'], Locales['INSUFFICIENT_PERMISSIONS'], "menu_textures", "cross", 3000, "COLOR_RED")
                return
            end

            OpenMenuKeyholders()

        elseif (data.current.value == "MENU_TRANSFER") then

            if property.citizenid ~= PlayerData.CitizenId then
                exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'], Locales['INSUFFICIENT_PERMISSIONS'], "menu_textures", "cross", 3000, "COLOR_RED")
                return
            end

            local input = lib.inputDialog(Locales['MENU_TRANSFER_TITLE'], {
                {
                    type     = 'number',
                    label    = Locales['MENU_TRANSFER_DESCRIPTION'],
                    required = true,
                    min      = 1,
                }
            })

            if input and input[1] then

                local inputId = tonumber(input[1])

                if inputId == GetPlayerServerId(PlayerId()) then
                    exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'], Locales['CANNOT_TRANSFER_TO_SAME_PERSON'], "menu_textures", "cross", 3000, "COLOR_RED")
                    return
                end

                local nearestPlayers = GetNearestPlayers(3.0)
                local foundPlayer    = false

                for _, targetPlayer in pairs(nearestPlayers) do
                    if inputId == GetPlayerServerId(targetPlayer) then
                        foundPlayer = true
                    end
                end

                if foundPlayer then

                    TriggerServerEvent("rs_housing:server:transferOwnedProperty", CurrentProperty, inputId)

                    TaskStandStill(PlayerPedId(), 1)

                    PlayerData.IsInMenu = false

                    CurrentProperty = nil
                    MenuData.CloseAll()

                else
                    exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'], Locales['PLAYER_NOT_FOUND'], "menu_textures", "cross", 3000, "COLOR_RED")
                end

            else
                exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'], Locales['INVALID_INPUT'], "menu_textures", "cross", 3000, "COLOR_RED")
            end

        elseif (data.current.value == "MENU_SELL") then

            if property.citizenid ~= PlayerData.CitizenId then
                exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'], Locales['INSUFFICIENT_PERMISSIONS'], "menu_textures", "cross", 3000, "COLOR_RED")
                return
            end

            OpenMenuSellProperty()

        elseif (data.current.value == "MENU_FURNITURE") then

            if HasPermissionByName(CurrentProperty, 'place_furniture', PlayerData.CitizenId) == 0 then
                exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'], Locales['INSUFFICIENT_PERMISSIONS'], "menu_textures", "cross", 3000, "COLOR_RED")
                return
            end

            MenuData.CloseAll()
            TriggerEvent('rs_furniture:open', CurrentProperty)

        end

    end,

    function(data, menu)
        TaskStandStill(PlayerPedId(), 1)
        PlayerData.IsInMenu = false
        CurrentProperty = nil
        MenuData.CloseAll()
    end)

end

function OpenMenuSellProperty()
    MenuData.CloseAll()

    local PlayerData = GetPlayerData()

    local options  = {
        {
            label = Locales['MENU_SELL_ACCEPT'], 
            value = "accept", 
            desc  = Locales['MENU_SELL_ACCEPT_DESCRIPTION'],
        },
        {
            label = Locales['MENU_BACK'],
            value = "backup", 
            desc  = "",
        },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menu_sell',

    {
        title    = string.format(Locales['MENU_PROPERTY_TITLE'], CurrentProperty),
        subtext  = "",
        align    = "right",
        elements = options,
    },

    function(data, menu)

        if (data.current.value == "backup") then
            OpenMenuManagement()

        elseif (data.current.value == "accept") then

            TriggerServerEvent("rs_housing:server:sell", CurrentProperty)

            TaskStandStill(PlayerPedId(), 1)
            PlayerData.IsInMenu = false

            CurrentProperty = nil
            MenuData.CloseAll()
        end

    end,

    function(data, menu)
        OpenMenuManagement()
    end)

end

function OpenMenuKeyholders() 
    MenuData.CloseAll()

    local options  = {
        {
            label = Locales['MENU_KEYHOLDERS_LIST'], 
            value = "list", 
            desc  = "",
        },
        {
            label = Locales['MENU_KEYHOLDERS_ADD_NEW'], 
            value = "add", 
            desc  = "",
        },
        {
            label = Locales['MENU_BACK'],
            value = "backup", 
            desc  = "",
        },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menu_keyholders_main',

    {
        title    = string.format(Locales['MENU_PROPERTY_TITLE'], CurrentProperty),
        subtext  = "",
        align    = "right",
        elements = options,
    },

    function(data, menu)

        if (data.current.value == "backup") then
            OpenMenuManagement()

        elseif (data.current.value == "list") then
            OpenMenuKeyholdersList()

        elseif (data.current.value == "add") then

            local input = lib.inputDialog(Locales['MENU_KEYHOLDERS_ADD_NEW_TITLE'], {
                {
                    type     = 'number',
                    label    = Locales['MENU_KEYHOLDERS_ADD_NEW_DESCRIPTION'],
                    required = true,
                    min      = 1,
                }
            })

            if input and input[1] then

                local inputId = tonumber(input[1])

                local PlayerData = GetPlayerData()
                local property   = PlayerData.Properties[CurrentProperty]

                if property.keyholders == nil then
                    property.keyholders = {}
                end

                local length = 0
                for _ in pairs(property.keyholders) do
                    length = length + 1
                end

                if length < Config.MaxHouseKeyHolders then
                    TriggerServerEvent("rs_housing:server:addPropertyKeyholder", CurrentProperty, inputId)
                else
                    exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'],  Locales['MENU_KEYHOLDERS_REACHED_MAX'], "menu_textures", "cross", 3000, "COLOR_RED")
                end

            else
                exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'],  Locales['INVALID_INPUT'], "menu_textures", "cross", 3000, "COLOR_RED")
            end

        end

    end,

    function(data, menu)
        OpenMenuManagement()
    end)

end

function OpenMenuKeyholdersList()
    MenuData.CloseAll()

    local PlayerData = GetPlayerData()
    local property   = PlayerData.Properties[CurrentProperty]
    
    local elements   = {}

    local length = 0
    if property.keyholders then
        for _ in pairs(property.keyholders) do
            length = length + 1
        end
    end

    if length > 0 then

        local count = 0

        for _, keyholder in pairs(property.keyholders) do
            count = count + 1
            
            table.insert(elements, { 
                label      = count .. ". " .. keyholder.username,
                citizenid  = keyholder.citizenid,
                username   = keyholder.username,
                value      = _,
                desc       = string.format(Locales['MENU_KEYHOLDERS_MANAGE'], keyholder.username)
            })

        end

    end

    table.insert(elements, { label = Locales['MENU_BACK'], value = "backup", desc = "" })

    MenuData.Open('default', GetCurrentResourceName(), 'menu_keyholders_list',

    {
        title    = string.format(Locales['MENU_PROPERTY_TITLE'], CurrentProperty),
        subtext  = "",
        align    = "right",
        elements = elements,
    },

    function(data, menu)
            
        if (data.current.value == "backup") then
            menu.close()
            OpenMenuKeyholders()
        else
            menu.close()
            OpenSelectedPlayerCatalog(data.current.citizenid, data.current.username)
        end

    end,

    function(data, menu)
        OpenMenuKeyholders()
    end)

end

function OpenSelectedPlayerCatalog(citizenid, username)

    local elements = {
        {
            label = Locales['MENU_KEYHOLDERS_PERMISSIONS_TITLE'],
            value = "permissions",
            desc  = "",
        },
        {
            label = Locales['MENU_KEYHOLDERS_REMOVE_TITLE'],
            value = "remove",
            desc  = "",
        },
        {
            label = Locales['MENU_BACK'],
            value = "back",
            desc  = ""
        },
    }

    MenuData.Open('default', GetCurrentResourceName() .. "_user_management", 'menuapi',
    {
        title    = username,
        subtext  = "",
        align    = "right",
        elements = elements,
        lastmenu = "MEMBERS"
    },

    function(data, menu)
        if (data.current == "backup" or data.current.value == "back") then
            menu.close()
            OpenMenuKeyholdersList()
        end

        if (data.current.value == 'permissions') then
            menu.close()
            OpenSelectedPlayerPermissions(citizenid, username)
        end

        if (data.current.value == "remove") then
            menu.close()

            TriggerServerEvent("rs_housing:server:removePropertyKeyholder", CurrentProperty, citizenid, username)

            Wait(1000)
            OpenMenuKeyholders()
        end

    end,
    function(data, menu)
        OpenMenuKeyholdersList()
        menu.close()
    end)

end

local function GetPermissionDescription(value)
    if tonumber(value) == 1 then
        return  Locales['YES']
    else
        return Locales['NO']
    end
end

local function GetLabel(localeKey)
    return Locales[localeKey] or localeKey
end

function OpenSelectedPlayerPermissions(citizenid, username)

    local propertyId = CurrentProperty

    local elements = {
        { 
            label = GetLabel("ledger_deposit"),
            value = "ledger_deposit",
            desc  = GetPermissionDescription(HasPermissionByName(propertyId, "ledger_deposit", citizenid))
        },
        { 
            label = GetLabel("ledgerhome_deposit"),
            value = "ledgerhome_deposit",
            desc  = GetPermissionDescription(HasPermissionByName(propertyId, "ledgerhome_deposit", citizenid))
        },
        { 
            label = GetLabel("ledgerhome_withdraw"),
            value = "ledgerhome_withdraw",
            desc  = GetPermissionDescription(HasPermissionByName(propertyId, "ledgerhome_withdraw", citizenid))
        },
        { 
            label = GetLabel("keyholders_management"),
            value = "keyholders",
            desc  = GetPermissionDescription(HasPermissionByName(propertyId, "keyholders", citizenid))
        },
        { 
            label = GetLabel("set_wardrobe"),
            value = "set_wardrobe",
            desc  = GetPermissionDescription(HasPermissionByName(propertyId, "set_wardrobe", citizenid))
        },
        { 
            label = GetLabel("set_storage"),
            value = "set_storage",
            desc  = GetPermissionDescription(HasPermissionByName(propertyId, "set_storage", citizenid))
        },
        { 
            label = GetLabel("storage_access"),
            value = "storage_access",
            desc  = GetPermissionDescription(HasPermissionByName(propertyId, "storage_access", citizenid))
        },
        { 
            label = GetLabel("place_furniture"),
            value = "place_furniture",
            desc  = GetPermissionDescription(HasPermissionByName(propertyId, "place_furniture", citizenid))
        },
        {
            label = Locales["MENU_BACK"],
            value = "back",
            desc  = ""
        },
    }

    MenuData.Open('default', GetCurrentResourceName() .. "_user_perms_management", 'menuapi',
    {
        title    = username,
        subtext  = "",
        align    = "right",
        elements = elements,
        lastmenu = "MEMBERS"
    },

    function(data, menu)
        if data.current == "backup" or (type(data.current) == "table" and data.current.value == "back") then
            MenuData.CloseAll()
            Wait(100)
            OpenSelectedPlayerCatalog(citizenid, username)
            return
        end

        TriggerServerEvent("rs_housing:server:onMembersPermissionUpdate", propertyId, citizenid, data.current.value)
        Wait(300)
        OpenSelectedPlayerPermissions(citizenid, username)
    end,

    function(data, menu)
        MenuData.CloseAll()
        Wait(100)
        OpenSelectedPlayerCatalog(citizenid, username)
    end)
end

function OpenMenuLedger()
    MenuData.CloseAll()

    local PlayerData = GetPlayerData()
    local property   = PlayerData.Properties[CurrentProperty]
    local taxInfo = ""

    if Config.TaxRepoSystem.Enabled then
        if Config.TaxRepoSystem.Monthly then
            taxInfo = string.format(
                "\n%s\n%s %s %s %02d:%02d",
                Locales['LEDGER_TAX_SYSTEM'],
                Locales['LEDGER_TAX_MONTHLY_LABEL'],
                Config.TaxRepoSystem.Day,
                Locales['LEDGER_TAX_AT'],
                Config.TaxRepoSystem.Hour,
                Config.TaxRepoSystem.Minute
            )
        end
        if Config.TaxRepoSystem.Weekly then
            local days = table.concat(Config.TaxRepoSystem.WeekDays, ", ")
            taxInfo = string.format(
                "\n%s\n%s %s %s %02d:%02d",
                Locales['LEDGER_TAX_SYSTEM'],
                Locales['LEDGER_TAX_WEEKLY_LABEL'],
                days,
                Locales['LEDGER_TAX_AT'],
                Config.TaxRepoSystem.Hour,
                Config.TaxRepoSystem.Minute
            )
        end
    end

    local options  = {
        {
            label = Locales['MENU_LEDGER_DEPOSIT_TITLE'], 
            value = "deposit", 
            desc  = taxInfo,
        },
        {
            label = Locales['MENU_BACK'],
            value = "backup", 
            desc  = "",
        },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menu_ledger_main',

    {
        title    = string.format(Locales['MENU_PROPERTY_TITLE'], CurrentProperty),
        subtext  = string.format(Locales['MENU_LEDGER_SUB_DESCRIPTION'], property.ledger),
        align    = "right",
        elements = options,
    },

    function(data, menu)

        if (data.current.value == "backup") then
            OpenMenuManagement()

        elseif (data.current.value == "deposit") then
            
            if HasPermissionByName(CurrentProperty, 'ledger_' .. data.current.value, PlayerData.CitizenId) == 0 then
                exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'], Locales['INSUFFICIENT_PERMISSIONS'], "menu_textures", "cross", 3000, "COLOR_RED")
                return
            end

            local actionType = string.upper(data.current.value)

            local input = lib.inputDialog(Locales['INPUT_' .. actionType .. '_TITLE'], {
                {
                    type     = 'number',
                    label    = Locales['INPUT_' .. actionType .. '_DESCRIPTION'],
                    required = true,
                    min      = 1,
                }
            })

            if input and input[1] then

                local numberInput = tonumber(input[1])

                if numberInput and numberInput > 0 then
                    TriggerServerEvent("rs_housing:server:updateAccountLedgerById", CurrentProperty, actionType, numberInput)
                    OpenMenuManagement()
                else
                    exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'], Locales['INVALID_QUANTITY'], "menu_textures", "cross", 3000, "COLOR_RED")
                end

            else
                exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'], Locales['INVALID_QUANTITY'], "menu_textures", "cross", 3000, "COLOR_RED")
            end

        end

    end,

    function(data, menu)
        OpenMenuManagement() 
    end)

end

function OpenMenuLedgerHome()
    MenuData.CloseAll()

    local PlayerData = GetPlayerData()
    local property   = PlayerData.Properties[CurrentProperty]

    local balance = property.ledgerhome 

    local options  = {
        {
            label = Locales['MENU_LEDGER_DEPOSIT_TITLE'], 
            value = "deposit", 
            desc  = Locales['MENU_LEDGER_DEPOSIT_DESCRIPTION'],
        },
        {
            label = Locales['MENU_LEDGER_WITHDRAW_TITLE'],
            value = "withdraw", 
            desc  = Locales['MENU_LEDGER_WITHDRAW_DESCRIPTION'],
        },
        {
            label = Locales['MENU_BACK'],
            value = "backup", 
            desc  = "",
        },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menu_ledger_home',

    {
        title    = string.format(Locales['MENU_PROPERTY_TITLE'], CurrentProperty),
        subtext  = Locales['BALANCE'].. ": " .. balance .. "$",
        align    = "right",
        elements = options,
    },

    function(data, menu)

        if (data.current.value == "backup") then
            OpenMenuManagement()

        elseif (data.current.value == "deposit") then
    
            if HasPermissionByName(CurrentProperty, 'ledgerhome_deposit', PlayerData.CitizenId) == 0 then
                exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'], Locales['INSUFFICIENT_PERMISSIONS'], "menu_textures", "cross", 3000, "COLOR_RED")
                return
            end

            local input = lib.inputDialog(Locales['INPUT_DEPOSIT_TITLE'], {
                {
                    type     = 'number',
                    label    = Locales['INPUT_DEPOSIT_DESCRIPTION'],
                    required = true,
                    min      = 1,
                }
            })

            if input and input[1] then
                TriggerServerEvent("rs_housing:server:updateAccountLedgerHomeById", CurrentProperty, "DEPOSIT", tonumber(input[1]))
                OpenMenuManagement()
            end

        elseif (data.current.value == "withdraw") then

            if HasPermissionByName(CurrentProperty, 'ledgerhome_withdraw', PlayerData.CitizenId) == 0 then
                exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'], Locales['INSUFFICIENT_PERMISSIONS'], "menu_textures", "cross", 3000, "COLOR_RED")
                return
            end

            local input = lib.inputDialog(Locales['INPUT_WITHDRAW_TITLE'], {
                {
                    type     = 'number',
                    label    = Locales['INPUT_WITHDRAW_DESCRIPTION'],
                    required = true,
                    min      = 1,
                }
            })

            if input and input[1] then
                TriggerServerEvent("rs_housing:server:updateAccountLedgerHomeById", CurrentProperty, "WITHDRAW", tonumber(input[1]))
                OpenMenuManagement()
            end
        end

    end,

    function(data, menu)
        OpenMenuManagement() 
    end)

end

Citizen.CreateThread(function()
    while true do
        
        Wait(0)

        local sleep = true

        if LocationType then
    
            sleep = false

            DrawTxt(Locales['SET_' .. LocationType], 0.50, 0.85, 0.7, 0.5, true, 255, 255, 255, 255, true)

            if IsControlJustReleased(0, 0x760A9C6F) then

                local PlayerData     = GetPlayerData()
                local property       = PlayerData.Properties[CurrentProperty]
                local coords         = GetEntityCoords(PlayerPedId())
                local coordsDist     = vector3(coords.x, coords.y, coords.z)
                local propertyCoords = vector3(property.Locations.PrimaryEntrance.x, property.Locations.PrimaryEntrance.y, property.Locations.PrimaryEntrance.z)
                local distance       = #(coordsDist - propertyCoords)

                if distance <= tonumber(property.actionsRange) then

                    TriggerServerEvent("rs_housing:server:setPropertyLocationByType", CurrentProperty, LocationType, coords)

                    PlayerData.IsInMenu = false
                    LocationType        = nil

                    exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'],   Locales['LOCATION_SET'], "generic_textures", "tick", 3000, "COLOR_GREEN")

                    Wait(500)
                    OpenMenuManagement(CurrentProperty)

                else
                    exports.rs_housing:ShowAdvancedNotification( Locales['HOUSING_NOTI'],  Locales['TOO_FAR'], "menu_textures", "cross", 3000, "COLOR_RED")
                end

            end

        end

        if sleep then
            Wait(1000)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(1)

        local PlayerData = GetPlayerData()

        if PlayerData.IsInMenu then
            DisableControlAction(0, 0xCC1075A7, true) -- MWUP
            DisableControlAction(0, 0xFD0F0C2C, true) -- MWDOWN
        else
            Wait(1000)
        end
    end
end)

RegisterNetEvent('rs_housing:ShowAdvancedNotification', function(title, subTitle, dict, icon, duration, color)
    exports['rs_housing']:ShowAdvancedNotification(title, subTitle, dict, icon, duration, color)
end)
