local RSGCore = exports['rsg-core']:GetCoreObject()
local MenuData = {}

TriggerEvent("rsg-menubase:getData", function(call)
    MenuData = call
end)

local menuOpen       = false
local previewObject  = nil
local previewRunning = false
local loadingHash    = nil

local shopCam       = nil
local activeCamData = nil

local function CreateShopCamera(camVec4)
    if shopCam then return end

    local cam = CreateCamWithParams(
        "DEFAULT_SCRIPTED_CAMERA",
        camVec4.x, camVec4.y, camVec4.z + 1.0,
        0.0, 0.0, camVec4.w,
        60.0,
        false, 0
    )
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1000, true, false, 0)
    shopCam = cam
end

local shopBlips = {}

Citizen.CreateThread(function()
    if not Config.furnitureitems then
        return
    end

    for i, location in pairs(Config.Locations) do
        if location.blip.enabled then
            local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, location.coords.x, location.coords.y, location.coords.z)
            SetBlipSprite(blip, location.blip.sprite, 1)
            SetBlipScale(blip, location.blip.scale)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, location.label)
            shopBlips[i] = blip
        end
    end
end)

local function DestroyShopCamera()
    if not shopCam then return end
    RenderScriptCams(false, true, 800, true, false, 0)
    DestroyCam(shopCam, false)
    shopCam       = nil
    activeCamData = nil
end

local function FreezePlayer()
    FreezeEntityPosition(PlayerPedId(), true)
end

local function UnfreezePlayer()
    FreezeEntityPosition(PlayerPedId(), false)
end

local function GetCoordsInFrontOfCam(dist)
    local originX, originY, originZ, heading

    if activeCamData then
        originX  = activeCamData.x
        originY  = activeCamData.y
        originZ  = activeCamData.z
        heading  = activeCamData.w
    else
        local ped = PlayerPedId()
        local c   = GetEntityCoords(ped)
        originX   = c.x
        originY   = c.y
        originZ   = c.z
        heading   = GetEntityHeading(ped)
    end

    local rad     = math.rad(heading)
    local fwdX    = -math.sin(rad)
    local fwdY    =  math.cos(rad)
    local leftX   = -math.cos(rad)
    local leftY   = -math.sin(rad)

    return vec3(
        originX + (fwdX * dist) + (leftX * 1.2 ),
        originY + (fwdY * dist) + (leftY * 1.2 ),
        originZ + 0.0
    )
end

local function DeletePreviewObject()
    previewRunning = false
    loadingHash    = nil
    if DoesEntityExist(previewObject) then
        DeleteObject(previewObject)
        previewObject = nil
    end
end


local PropOffsetByHash = {}
for modelName, offset in pairs(Config.PropOffset) do
    PropOffsetByHash[GetHashKey(modelName)] = offset
end

local function SpawnPreviewObject(hash)
    previewRunning = false
    loadingHash    = hash

    if DoesEntityExist(previewObject) then
        DeleteObject(previewObject)
        previewObject = nil
    end

    CreateThread(function()
        RequestModel(hash)
        local timeout = 0
        while not HasModelLoaded(hash) and timeout < 100 do
            Wait(50)
            timeout = timeout + 1
            if loadingHash ~= hash then return end
        end

        if loadingHash ~= hash then return end
        if not HasModelLoaded(hash) then return end

        local pos = GetCoordsInFrontOfCam(Config.PreviewDistance)

        if PropOffsetByHash[hash] then
            pos = vec3(pos.x, pos.y, pos.z + PropOffsetByHash[hash])
        end

        local obj = CreateObjectNoOffset(hash, pos.x, pos.y, pos.z, false, false, false)
        if not DoesEntityExist(obj) then return end

        if loadingHash ~= hash then
            DeleteObject(obj)
            return
        end

        previewObject = obj
        SetEntityCollision(previewObject, false, false)
        FreezeEntityPosition(previewObject, true)
        SetEntityAlpha(previewObject, 210, false)
        SetModelAsNoLongerNeeded(hash)

        previewRunning = true
        local angle = 0.0
        while previewRunning do
            if DoesEntityExist(previewObject) then
                local p = GetCoordsInFrontOfCam(Config.PreviewDistance)

                if PropOffsetByHash[hash] then
                    p = vec3(p.x, p.y, p.z + PropOffsetByHash[hash])
                end

                SetEntityCoordsNoOffset(previewObject, p.x, p.y, p.z, false, false, false)
                SetEntityRotation(previewObject, 0.0, 0.0, angle, 2, false)
                angle = (angle + Config.RotationSpeed) % 360.0
            end
            Wait(0)
        end
    end)
end

local shopPrompts = {}

local function CreateShopPrompts()
    for i, loc in ipairs(Config.Locations) do
        local groupHash = GetRandomIntInRange(0, 0xffffff)
        local prompt    = PromptRegisterBegin()

        PromptSetControlAction(prompt, Config.ShopKey)
        local str = CreateVarString(10, 'LITERAL_STRING', Locales["PROMPT_FURNI"] )
        PromptSetText(prompt, str)
        PromptSetEnabled(prompt, 1)
        PromptSetVisible(prompt, 0)
        PromptSetStandardMode(prompt, 1)
        PromptSetGroup(prompt, groupHash)
        Citizen.InvokeNative(0xC5F428EE08FA7F2C, prompt, true)
        PromptRegisterEnd(prompt)

        shopPrompts[i] = {
            prompt    = prompt,
            groupHash = groupHash,
            label     = loc.label,
        }
    end
end

local OpenMainMenu
local OpenCategoryMenu

local function CloseShop()
    DeletePreviewObject()
    DestroyShopCamera()
    UnfreezePlayer()
    menuOpen = false
end

local function OpenBuyMenu(itemName, itemData, categoryName)
    local elements = {
        { label = '💰 ' .. Locales["FURNI_PRICE"] .. " " .. itemData.cost .. "$", value = 'price', disabled = true },
        { label = '🛒 ' .. Locales["FURNI_BUY"], value = 'buy' },
        { label = '← ' .. Locales["FURNI_BACK"], value = 'back' },
    }

    MenuData.Open('default', GetCurrentResourceName(), 'furniture_buy_menu', {
        title    = itemName,
        align    = 'top-right',
        elements = elements,
    }, function(data, menu)

        if data.current.value == 'buy' then

            local input = lib.inputDialog(Locales["FURNI_BUY"], {
                {
                    type = 'number',
                    label = Locales["FURNI_AMOUNT"],
                    description = Locales["FURNI_AMOUNT_DESC"],
                    required = true,
                    min = 1,
                }
            })

            if not input or not input[1] then
                return
            end

            local amount = tonumber(input[1])

            if amount and amount > 0 then
                TriggerServerEvent(
                    'rs_housing:server:buyFurniture',
                    itemName,
                    itemData.item,
                    itemData.cost,
                    amount
                )
            end

            menu.close()
            DeletePreviewObject()
            OpenMainMenu()

        elseif data.current.value == 'back' then
            menu.close()
            OpenCategoryMenu(categoryName)
        end

    end, function(data, menu)
        menu.close()
        OpenCategoryMenu(categoryName)
    end)
end

OpenCategoryMenu = function(categoryName)
    local items    = Config.furniture[categoryName]
    local sorted   = {}
    local elements = {}

    for name, data in pairs(items) do
        sorted[#sorted + 1] = { name = name, data = data }
    end

    table.sort(sorted, function(a, b)
        return a.name < b.name
    end)

    for _, entry in ipairs(sorted) do
        elements[#elements + 1] = {
            label = entry.name .. ' - ' .. entry.data.cost .. "$",
            value = entry.name,
            data  = entry.data,
        }
    end

    elements[#elements + 1] = {
        label = '← Back',
        value = '__back__',
        data = nil
    }

    if sorted[1] then
        SpawnPreviewObject(sorted[1].data.hash)
    end

    MenuData.Open('default', GetCurrentResourceName(), 'furniture_cat_menu', {
        title    = categoryName,
        align    = 'top-right',
        elements = elements,
    }, function(data, menu)

        if data.current.value == '__back__' then
            menu.close()
            DeletePreviewObject()
            OpenMainMenu()
        else
            menu.close()
            OpenBuyMenu(data.current.value, data.current.data, categoryName)
        end

    end, function(data, menu)
        menu.close()
        DeletePreviewObject()
        OpenMainMenu()

    end, function(data, menu)

        if data.current.data then
            SpawnPreviewObject(data.current.data.hash)
        else
            DeletePreviewObject()
        end

    end)
end

OpenMainMenu = function()
    menuOpen = true
    FreezePlayer()

    local sorted   = {}
    local elements = {}

    for cat, _ in pairs(Config.furniture) do
        sorted[#sorted + 1] = cat
    end
    table.sort(sorted)

    for _, cat in ipairs(sorted) do
        elements[#elements + 1] = { label = cat, value = cat }
    end

    MenuData.Open('default', GetCurrentResourceName(), 'furniture_main_menu', {
        title    = Locales["FURNI_SHOP"],
        align    = 'top-right',
        elements = elements,
    }, function(data, menu)
        menu.close()
        OpenCategoryMenu(data.current.value)
    end, function(data, menu)
        menu.close()
        CloseShop()
    end)
end

CreateThread(function()

    if Config.furnitureitems then
        CreateShopPrompts()
    else
        return
    end

    while true do
        local sleep = 1000
        local pedCoords = GetEntityCoords(PlayerPedId())

        for i, loc in ipairs(Config.Locations) do

            local p = shopPrompts[i]

            if p and p.prompt then

                local dist = #(pedCoords - loc.coords)

                if dist < Config.PromptRadius then
                    sleep = 0

                    PromptSetVisible(p.prompt, 1)
                    PromptSetEnabled(p.prompt, 1)

                    local label = CreateVarString(10, 'LITERAL_STRING', loc.label)
                    PromptSetActiveGroupThisFrame(p.groupHash, label)

                    if not menuOpen and Citizen.InvokeNative(0xC92AC953F0A982AE, p.prompt) then

                        if loc.camera then
                            activeCamData = loc.camera
                            CreateShopCamera(loc.camera)
                        end

                        OpenMainMenu()
                    end

                else
                    PromptSetVisible(p.prompt, 0)
                    PromptSetEnabled(p.prompt, 0)
                end
            end
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('rs_housing:client:buyResult', function(success, reason, itemName, cost, amount)
    if success then
        lib.notify({
            title       = Locales['FURNI_NOTI'],
            description = Locales['YOU_BOUGTH'] .. " " .. amount .. "x " .. itemName .. " " .. Locales['FOR'] .. " " .. cost .. "$",
            type        = 'success',
            duration    = 3000,
            position    = 'top'
        })
    elseif reason == 'weight' then
        lib.notify({
            title       = Locales['FURNI_NOTI'],
            description = Locales['FURNITURE_NOT_ENOUGH_WEIGHT'],
            type        = 'error',
            duration    = 3000,
            position    = 'top'
        })
    else
        lib.notify({
            title       = Locales['FURNI_NOTI'],
            description = Locales['FURNITURE_NOT_ENOUGH_MONEY'],
            type        = 'error',
            duration    = 3000,
            position    = 'top'
        })
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        CloseShop()
        for _, p in ipairs(shopPrompts) do
            PromptDelete(p.prompt)
        end
        for i, blip in pairs(shopBlips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
            shopBlips[i] = nil
        end
    end
end)