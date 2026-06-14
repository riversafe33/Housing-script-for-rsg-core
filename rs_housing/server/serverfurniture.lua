local RSGCore = exports['rsg-core']:GetCoreObject()

local function notiFurniSuccess(source, title, message)
    TriggerClientEvent('ox_lib:notify', source, {
        title       = title,
        description = message,
        type        = 'success',
        duration    = 4000,
        position    = 'top'
    })
end

local function notiFurniError(source, title, message)
    TriggerClientEvent('ox_lib:notify', source, {
        title       = title,
        description = message,
        type        = 'error',
        duration    = 3000,
        position    = 'top'
    })
end

local function GetPlayer(src)
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then
    end
    return Player
end

local function GetFurniture(propname, cb)
    exports.oxmysql:query(
        'SELECT furniture FROM properties WHERE name = ?',
        { propname },
        function(result)
            if not result or not result[1] then cb({}) return end
            cb(json.decode(result[1].furniture or '[]') or {})
        end
    )
end

local function SaveFurniture(propname, furnitureTable, cb)
    exports.oxmysql:update(
        'UPDATE properties SET furniture = ? WHERE name = ?',
        { json.encode(furnitureTable), propname },
        function(rows)
            if cb then cb(rows and rows > 0) end
        end
    )
end

local function GenerateId()
    return tostring(os.time()) .. tostring(math.random(10000, 99999))
end

local function IsAuthorized(src, propname, cb)
    local Player = GetPlayer(src)
    if not Player then cb(false) return end

    local citizenid = Player.PlayerData.citizenid

    exports.oxmysql:query(
        'SELECT citizenid, keyholders FROM properties WHERE name = ?',
        { propname },
        function(result)
            if not result or not result[1] then cb(false) return end

            local owner      = result[1].citizenid
            local keyholders = json.decode(result[1].keyholders or '{}') or {}

            if owner == citizenid then cb(true) return end

            local kh = keyholders[citizenid]
            if kh and kh.permissions and kh.permissions.place_furniture == 1 then
                cb(true) return
            end

            cb(false)
        end
    )
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    if not Config.furnitureitems then return end

    for category, items in pairs(Config.furniture) do
        for name, data in pairs(items) do
            if data.item then
                local itemname = data.item
                RSGCore.Functions.CreateUseableItem(itemname, function(src)
                    TriggerClientEvent('rs_furniture:client:useitem', src, itemname)
                end)
            end
        end
    end
end)

RegisterNetEvent('rs_furniture:server:useitem')
AddEventHandler('rs_furniture:server:useitem', function(itemname)
    local src    = source
    local Player = GetPlayer(src)
    if not Player then return end

    if type(itemname) ~= 'string' then return end

    local furnidata = nil
    for category, items in pairs(Config.furniture) do
        for name, data in pairs(items) do
            if data.item == itemname then
                furnidata = {
                    label = name,
                    hash  = data.hash,
                    item  = data.item,
                }
                break
            end
        end
        if furnidata then break end
    end

    if not furnidata then
        notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_NOT_FOUND'])
        return
    end

    TriggerClientEvent('rs_furniture:client:tryplaceitem', src, furnidata)
end)

RegisterNetEvent('rs_furniture:server:load')
AddEventHandler('rs_furniture:server:load', function(propname)
    local src = source
    if type(propname) ~= 'string' then return end

    GetFurniture(propname, function(furniture)
        TriggerClientEvent('rs_furniture:client:receive', src, propname, furniture)
    end)
end)

RegisterNetEvent('rs_furniture:server:buy')
AddEventHandler('rs_furniture:server:buy', function(propname, furnitem, furniname, cost, px, py, pz, ph)
    local src    = source
    local Player = GetPlayer(src)
    if not Player then return end

    if type(propname)  ~= 'string'                         then return end
    if type(cost)      ~= 'number' or cost < 0             then return end
    if type(px)        ~= 'number' or type(py) ~= 'number'
        or type(pz)    ~= 'number' or type(ph) ~= 'number' then return end
    if type(furniname) ~= 'string'                         then return end

    IsAuthorized(src, propname, function(auth)
        if not auth then
            notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_NO_ACCESS'])
            return
        end

        GetFurniture(propname, function(furniture)
            if #furniture >= Config.furniturelimit then
                notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_LIMIT_REACHED'])
                return
            end

            if Player.Functions.GetMoney('cash') < cost then
                notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_NOT_ENOUGH_MONEY'])
                return
            end

            Player.Functions.RemoveMoney('cash', cost, 'rs_furniture:buy')

            local entry = {
                id       = GenerateId(),
                furnitem = furnitem,
                name     = furniname,
                x        = px,
                y        = py,
                z        = pz,
                h        = ph,
                price    = cost,
            }
            table.insert(furniture, entry)

            SaveFurniture(propname, furniture, function(ok)
                if not ok then
                    Player.Functions.AddMoney('cash', cost, 'rs_furniture:buy-refund')
                    notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_SAVE_ERROR'])
                    return
                end

                TriggerClientEvent('rs_furniture:client:receive', src, propname, furniture)
                notiFurniSuccess(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_PLACED'])
            end)
        end)
    end)
end)

RegisterNetEvent('rs_furniture:server:place')
AddEventHandler('rs_furniture:server:place', function(propname, furnitem, furniname, cost, px, py, pz, ph, itemname)
    local src    = source
    local Player = GetPlayer(src)
    if not Player then return end

    if type(propname)  ~= 'string'  then return end
    if type(itemname)  ~= 'string'  then return end
    if type(furniname) ~= 'string'  then return end
    if type(px) ~= 'number' or type(py) ~= 'number'
        or type(pz) ~= 'number' or type(ph) ~= 'number' then return end

    IsAuthorized(src, propname, function(auth)
        if not auth then
            notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_NO_ACCESS'])
            return
        end

        GetFurniture(propname, function(furniture)
            if #furniture >= Config.furniturelimit then
                notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_LIMIT_REACHED'])
                return
            end

            if not exports['rsg-inventory']:HasItem(src, itemname, 1) then
                notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_NO_ITEM'])
                return
            end

            if not exports['rsg-inventory']:RemoveItem(src, itemname, 1, nil, 'rs_furniture:place') then
                notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_REMOVE_ITEM_ERROR'])
                return
            end

            local entry = {
                id       = GenerateId(),
                furnitem = furnitem,
                name     = furniname,
                item     = itemname,
                x        = px,
                y        = py,
                z        = pz,
                h        = ph,
                price    = 0,
            }
            table.insert(furniture, entry)

            SaveFurniture(propname, furniture, function(ok)
                if not ok then
                    exports['rsg-inventory']:AddItem(src, itemname, 1, nil, nil, 'rs_furniture:place-refund')
                    notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_SAVE_ERROR'])
                    return
                end

                TriggerClientEvent('rs_furniture:client:receive', src, propname, furniture)
                notiFurniSuccess(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_PLACED'])
            end)
        end)
    end)
end)

RegisterNetEvent('rs_furniture:server:sell')
AddEventHandler('rs_furniture:server:sell', function(propname, furniid)
    local src    = source
    local Player = GetPlayer(src)
    if not Player then return end

    if type(propname) ~= 'string' or type(furniid) ~= 'string' then return end

    IsAuthorized(src, propname, function(auth)
        if not auth then
            notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_NO_ACCESS'])
            return
        end

        GetFurniture(propname, function(furniture)
            local foundIdx   = nil
            local foundEntry = nil

            for i, v in ipairs(furniture) do
                if tostring(v.id) == tostring(furniid) then
                    foundIdx   = i
                    foundEntry = v
                    break
                end
            end

            if not foundIdx then
                notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_NOT_FOUND'])
                return
            end

            local sellPrice = math.floor((foundEntry.price or 0) * Config.furnituresellrate)

            table.remove(furniture, foundIdx)

            SaveFurniture(propname, furniture, function(ok)
                if not ok then
                    notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_SAVE_ERROR'])
                    return
                end

                Player.Functions.AddMoney('cash', sellPrice, 'rs_furniture:sell')
                TriggerClientEvent('rs_furniture:client:receive', src, propname, furniture)
                notiFurniSuccess(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_SOLD'] .. ' ' .. foundEntry.name .. ' ' .. Locales['FOR'] .. ' ' .. sellPrice .. '$')
            end)
        end)
    end)
end)

RegisterNetEvent('rs_furniture:server:remove')
AddEventHandler('rs_furniture:server:remove', function(propname, furniid)
    local src    = source
    local Player = GetPlayer(src)
    if not Player then return end

    if type(propname) ~= 'string' or type(furniid) ~= 'string' then return end

    IsAuthorized(src, propname, function(auth)
        if not auth then
            notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_NO_ACCESS'])
            return
        end

        GetFurniture(propname, function(furniture)
            local foundIdx   = nil
            local foundEntry = nil

            for i, v in ipairs(furniture) do
                if tostring(v.id) == tostring(furniid) then
                    foundIdx   = i
                    foundEntry = v
                    break
                end
            end

            if not foundIdx then
                notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_NOT_FOUND'])
                return
            end

            table.remove(furniture, foundIdx)

            SaveFurniture(propname, furniture, function(ok)
                if not ok then
                    notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_SAVE_ERROR'])
                    return
                end

                if Config.furnitureitems and foundEntry.item then
                    local canAdd = exports['rsg-inventory']:CanAddItem(src, foundEntry.item, 1)
                    if canAdd then
                        exports['rsg-inventory']:AddItem(src, foundEntry.item, 1, nil, nil, 'rs_furniture:remove')
                    else
                        notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_INVENTORY_FULL'])
                    end
                end

                TriggerClientEvent('rs_furniture:client:receive', src, propname, furniture)
                notiFurniSuccess(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_REMOVED'] .. ' ' .. (foundEntry.name or '?') .. ' ')
            end)
        end)
    end)
end)

RegisterNetEvent('rs_furniture:server:checkauth')
AddEventHandler('rs_furniture:server:checkauth', function(propname, furnidata)
    local src = source
    if type(propname) ~= 'string' then return end

    IsAuthorized(src, propname, function(auth)
        if not auth then
            notiFurniError(src, Locales['HOUSING_NOTI'], Locales['FURNITURE_NO_ACCESS'])
            return
        end
        TriggerClientEvent('rs_furniture:client:startplace', src, propname, furnidata)
    end)
end)