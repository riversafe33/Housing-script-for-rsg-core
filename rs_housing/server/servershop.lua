local RSGCore = exports['rsg-core']:GetCoreObject()

RegisterNetEvent('rs_housing:server:buyFurniture', function(itemName, itemId, cost, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    if not Player then return end

    cost = tonumber(cost) or 0
    amount = tonumber(amount) or 1
    if amount < 1 then amount = 1 end

    local validItem = false

    for _, category in pairs(Config.furniture) do
        for name, data in pairs(category) do
            if data.item == itemId and name == itemName and tonumber(data.cost) == cost then
                validItem = true
                break
            end
        end
        if validItem then break end
    end

    if not validItem then
        TriggerClientEvent('rs_housing:client:buyResult', src, false, 'invalid', itemName, 0, amount)
        return
    end

    local totalCost = cost * amount
    local playerCash = Player.PlayerData.money['cash']

    if not playerCash or playerCash < totalCost then
        TriggerClientEvent('rs_housing:client:buyResult', src, false, 'money', itemName, 0, amount)
        return
    end

    local canAdd = exports['rsg-inventory']:CanAddItem(src, itemId, amount)
    if not canAdd then
        TriggerClientEvent('rs_housing:client:buyResult', src, false, 'weight', itemName, 0, amount)
        return
    end

    Player.Functions.RemoveMoney('cash', totalCost, 'furniture-shop-purchase')

    local added = exports['rsg-inventory']:AddItem(src, itemId, amount)

    if added then
        TriggerClientEvent('rs_housing:client:buyResult', src, true, 'success', itemName, totalCost, amount)
    else
        Player.Functions.AddMoney('cash', totalCost, 'furniture-shop-refund')
        TriggerClientEvent('rs_housing:client:buyResult', src, false, 'add', itemName, 0, amount)
    end
end)