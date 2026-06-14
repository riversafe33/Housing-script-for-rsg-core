local MenuData = {}

TriggerEvent("rsg-menubase:getData", function(call)
    MenuData = call
end)

local globalpropname   = nil
local globalpropconfig = nil
local inmenu           = false
local placefurniture   = false
local placedobject     = false
local objectxyz        = nil
local x, y, z         = 0, 0, 0
local h                = 0
local actionQueue      = nil
local actionSpeed      = 0.01
local menuOpen         = false
local int              = 0.5
local furnitem
local furnitemcost
local furniname
local thefurniitem
local xx, yy, zz, hh
local furniturex       = {}
local furniitems       = {}
local spawnedfurniture = {}
local hidePlacementText = false

local function drawtext(str, dx, dy, w, h2, shadow, r, g, b, a, centre)
    local s = CreateVarString(10, "LITERAL_STRING", str, Citizen.ResultAsLong())
    SetTextScale(w, h2)
    SetTextColor(math.floor(r), math.floor(g), math.floor(b), math.floor(a))
    SetTextCentre(centre)
    if shadow then SetTextDropshadow(1, 0, 0, 0, 255) end
    Citizen.InvokeNative(0xADA9255D, 10)
    DisplayText(s, dx, dy)
end

local function DistanceToProperty(propconfig)
    local center = propconfig.Locations.MenuActions
    local pos    = GetEntityCoords(PlayerPedId())
    return GetDistanceBetweenCoords(pos.x, pos.y, pos.z, center.x, center.y, center.z, true)
end

local function IsInRange()
    if not globalpropconfig then return false end
    return DistanceToProperty(globalpropconfig) <= globalpropconfig.actionsRange
end

RegisterNUICallback("menuAction", function(data, cb)
    actionQueue = data.action
    actionSpeed = tonumber(data.speed)
    cb("ok")
end)

local function OpenFurnitureMenu()
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
    SetCursorLocation(0.95, 0.30)
    SendNUIMessage({
        show = true,
        lang = {
            title          = Locales['TITLE'],
            speed          = Locales['SPEED'],
            positionGroup  = Locales['POSITIONGROUP'],
            elevationGroup = Locales['ELEVATIONGROUP'],
            rotationGroup  = Locales['ROTATIONGROUP'],
            forward        = Locales['FORWARD'],
            backward       = Locales['BACKWARD'],
            left           = Locales['LEFT'],
            right          = Locales['RIGHT'],
            up             = Locales['UP'],
            down           = Locales['DOWN'],
            rotPlus        = Locales['ROTPLUS'],
            rotMinus       = Locales['ROTMINUS'],
            confirm        = Locales['CONFIRM'],
            cancel         = Locales['CANCEL'],
        }
    })
    menuOpen = true
end

local function CloseFurnitureMenu()
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ show = false })
    menuOpen = false
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if menuOpen then
            drawtext(Locales['CAMERA'],
                0.50, 0.05, 0.3, 0.3, true, 0, 255, 0, 255, true)
            if not IsControlPressed(0, 0x07CE1E61) then
                DisableControlAction(0, 0xA987235F, true)
                DisableControlAction(0, 0xD2047988, true)
            end
        end
    end
end)

Citizen.CreateThread(function()
    local created = false

    while true do
        Citizen.Wait(0)
        local sleep = true

        if placefurniture then
            sleep = false

            DisableControlAction(0, Config.keysPlace.Create,  true)
            DisableControlAction(0, Config.keysPlace.Confirm, true)
            DisableControlAction(0, Config.keysPlace.Cancel,  true)

            if not IsInRange() then

                if not created and not hidePlacementText then
                    drawtext(Locales['FURNITURE_TOO_FAR'],
                        0.15, 0.10, 0.1, 0.3, true, 255, 80, 80, 255, true)

                    drawtext(Locales['FOURTOCANCEL'],
                        0.15, 0.13, 0.3, 0.3, true, 255, 255, 255, 255, true)
                end

                if IsDisabledControlJustPressed(0, Config.keysPlace.Cancel) then
                    placefurniture = false
                    placedobject   = false
                    created        = false
                    inmenu         = false
                    hidePlacementText = false

                    if objectxyz then
                        DeleteObject(objectxyz)
                        objectxyz = nil
                    end
                end

            else

                if not created and not hidePlacementText then
                    drawtext(Locales['GITEMPLACE'],
                        0.15, 0.10, 0.1, 0.3, true, 255, 255, 255, 255, true)

                    drawtext(Locales['FOURTOCANCEL'],
                        0.15, 0.13, 0.3, 0.3, true, 255, 255, 255, 255, true)

                    drawtext(Locales['USEDMENU'],
                        0.15, 0.16, 0.3, 0.3, true, 255, 255, 255, 255, true)
                end

                if not HasModelLoaded(furnitem) then
                    RequestModel(furnitem)
                end

                while not HasModelLoaded(furnitem) do
                    Citizen.Wait(1)
                end

                if IsDisabledControlJustPressed(0, Config.keysPlace.Create) then
                    if not placedobject then

                        local myPed   = PlayerPedId()
                        local pos     = GetEntityCoords(myPed, true)
                        local forward = GetEntityForwardVector(myPed)

                        objectxyz = CreateObject(
                            furnitem,
                            pos.x + forward.x * 2.5,
                            pos.y + forward.y * 2.5,
                            pos.z,
                            true, true, false
                        )

                        PlaceObjectOnGroundProperly(objectxyz)
                        SetEntityAsMissionEntity(objectxyz, true)
                        FreezeEntityPosition(objectxyz, true)
                        SetEntityAlpha(objectxyz, 153)

                        placedobject = true
                        created      = true

                        local p = GetEntityCoords(objectxyz, true)

                        x, y, z = p.x, p.y, p.z
                        h       = GetEntityHeading(objectxyz)

                        OpenFurnitureMenu()
                    end
                end

                if placedobject and menuOpen and actionQueue ~= nil then
                    local sp = actionSpeed * int

                    if actionQueue == "x_plus"    then x = x + sp end
                    if actionQueue == "x_minus"   then x = x - sp end
                    if actionQueue == "y_plus"    then y = y + sp end
                    if actionQueue == "y_minus"   then y = y - sp end
                    if actionQueue == "z_plus"    then z = z + sp end
                    if actionQueue == "z_minus"   then z = z - sp end
                    if actionQueue == "rot_plus"  then h = h + (actionSpeed * 5.0) end
                    if actionQueue == "rot_minus" then h = h - (actionSpeed * 5.0) end

                    if actionQueue == "confirm" then
                        xx, yy, zz, hh = x, y, z, h

                        placefurniture = false
                        placedobject   = false
                        created        = false
                        hidePlacementText = false

                        DeleteObject(objectxyz)
                        objectxyz = nil

                        CloseFurnitureMenu()

                        Citizen.Wait(500)

                        confirmmenu_furniture(
                            "confirmfurniturebuy",
                            "buyfurnimenu2"
                        )
                    end

                    if actionQueue == "cancel" then
                        placefurniture = false
                        placedobject   = false
                        created        = false
                        hidePlacementText = false

                        if objectxyz then
                            DeleteObject(objectxyz)
                            objectxyz = nil
                        end

                        CloseFurnitureMenu()
                        inmenu = false
                    end

                    if objectxyz then
                        SetEntityCoords(objectxyz, x, y, z)
                        SetEntityHeading(objectxyz, h)
                    end

                    actionQueue = nil
                end

                if IsDisabledControlJustPressed(0, Config.keysPlace.Cancel) then
                    placefurniture = false
                    placedobject   = false
                    created        = false
                    hidePlacementText = false

                    if objectxyz then
                        DeleteObject(objectxyz)
                        objectxyz = nil
                    end

                    CloseFurnitureMenu()
                    inmenu = false
                end
            end
        end

        if sleep then
            Citizen.Wait(500)
        end
    end
end)

local function SpawnFurniture(propname, furniture)
    if spawnedfurniture[propname] then
        for _, ent in ipairs(spawnedfurniture[propname]) do
            if DoesEntityExist(ent) then DeleteObject(ent) end
        end
    end
    spawnedfurniture[propname] = {}

    for _, v in ipairs(furniture) do
        local hash = v.furnitem
        if not HasModelLoaded(hash) then RequestModel(hash) end
        local waited = 0
        while not HasModelLoaded(hash) and waited < 3000 do
            Citizen.Wait(100)
            waited = waited + 100
        end
        if HasModelLoaded(hash) then
            local obj = CreateObjectNoOffset(hash, v.x, v.y, v.z, false, true, false)
            SetEntityAsMissionEntity(obj, true)
            FreezeEntityPosition(obj, true)
            SetEntityHeading(obj, v.h)
            table.insert(spawnedfurniture[propname], obj)
        end
    end
end

local function DespawnFurniture(propname)
    if spawnedfurniture[propname] then
        for _, ent in ipairs(spawnedfurniture[propname]) do
            if DoesEntityExist(ent) then DeleteObject(ent) end
        end
        spawnedfurniture[propname] = nil
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000)
        local pos = GetEntityCoords(PlayerPedId())

        for propname, propdata in pairs(Config.Properties) do
            local center = propdata.Locations.MenuActions
            local dist   = GetDistanceBetweenCoords(
                pos.x, pos.y, pos.z,
                center.x, center.y, center.z,
                true
            )
            local renderRange = (propdata.actionsRange) + 20.0

            if dist <= renderRange then
                if not spawnedfurniture[propname] then
                    TriggerServerEvent('rs_furniture:server:load', propname)
                end
            else
                if spawnedfurniture[propname] then
                    DespawnFurniture(propname)
                end
            end
        end
    end
end)

RegisterNetEvent('rs_furniture:client:receive')
AddEventHandler('rs_furniture:client:receive', function(propname, furniture)
    if globalpropname == propname then
        furniturex = furniture
    end
    SpawnFurniture(propname, furniture)
end)

RegisterNetEvent('rs_furniture:client:useitem')
AddEventHandler('rs_furniture:client:useitem', function(itemname)
    TriggerServerEvent('rs_furniture:server:useitem', itemname)
end)

RegisterNetEvent('rs_furniture:client:tryplaceitem')
AddEventHandler('rs_furniture:client:tryplaceitem', function(furnidata)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local foundProp    = nil
    local foundConfig  = nil

    for propname, propconfig in pairs(Config.Properties) do
        local center = propconfig.Locations.MenuActions
        local dist   = GetDistanceBetweenCoords(
            playerCoords.x, playerCoords.y, playerCoords.z,
            center.x, center.y, center.z,
            true
        )
        if dist <= propconfig.actionsRange then
            foundProp   = propname
            foundConfig = propconfig
            break
        end
    end

    if not foundProp then
        lib.notify({
            title       = Locales['HOUSING_NOTI'],
            description = Locales['FURNITURE_TOO_FAR'],
            type        = 'error',
            duration    = 3000,
            position    = 'top'
        })
        return
    end

    globalpropname   = foundProp
    globalpropconfig = foundConfig

    TriggerServerEvent('rs_furniture:server:checkauth', foundProp, furnidata)
end)

RegisterNetEvent('rs_furniture:client:startplace')
AddEventHandler('rs_furniture:client:startplace', function(propname, furnidata)

    if not IsInRange() then
        lib.notify({
            title       = Locales['HOUSING_NOTI'],
            description = Locales['FURNITURE_TOO_FAR'],
            type        = 'error',
            duration    = 3000,
            position    = 'top'
        })
        return
    end

    thefurniitem = furnidata.item
    furnitem     = furnidata.hash
    furniname    = furnidata.label

    placefurniture   = true
    inmenu           = false
    hidePlacementText = true

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local fwd = GetEntityForwardVector(ped)

    if not HasModelLoaded(furnitem) then
        RequestModel(furnitem)

        while not HasModelLoaded(furnitem) do
            Wait(0)
        end
    end

    objectxyz = CreateObject(
        furnitem,
        pos.x + fwd.x * 2.0,
        pos.y + fwd.y * 2.0,
        pos.z,
        true, true, false
    )

    PlaceObjectOnGroundProperly(objectxyz)
    SetEntityAsMissionEntity(objectxyz, true)
    FreezeEntityPosition(objectxyz, true)
    SetEntityAlpha(objectxyz, 153)

    placedobject = true

    local p = GetEntityCoords(objectxyz)

    x, y, z = p.x, p.y, p.z
    h       = GetEntityHeading(objectxyz)

    OpenFurnitureMenu()

    FreezeEntityPosition(PlayerPedId(), false)
    ClearPedTasks(PlayerPedId())
end)

AddEventHandler('rs_furniture:open', function(propname)
    local propconfig = Config.Properties[propname]
    if not propconfig then
        print('[rs_furniture] Propiedad desconocida: ' .. tostring(propname))
        return
    end

    globalpropname   = propname
    globalpropconfig = propconfig

    TriggerServerEvent('rs_furniture:server:load', propname)

    inmenu = true
    FreezeEntityPosition(PlayerPedId(), true)
    TaskStandStill(PlayerPedId(), -1)
    furnimenu()
end)

function BackToManagement()
    inmenu = false
    local PlayerData = GetPlayerData()
    PlayerData.IsInMenu = false
    FreezeEntityPosition(PlayerPedId(), false)
    ClearPedTasks(PlayerPedId())
    MenuData.CloseAll()
    OpenMenuManagement(globalpropname)
end

function confirmmenu_furniture(mtype, lastmenux)
    MenuData.CloseAll()

    local elements = {
        { label = Locales['YESPLACE'], value = "yes", desc = "" },
        { label = Locales['NOPLACE'],  value = "no",  desc = "" },
    }

    MenuData.Open("default", GetCurrentResourceName(), "menuapi",
        {
            title    = Locales['CONFIRM'],
            subtext  = "",
            align    = "top-right",
            elements = elements,
            lastmenu = lastmenux,
        },
        function(data, menu)
            if data.current.value == "yes" then
                if mtype == "confirmfurniturebuy" then
                    if not Config.furnitureitems then
                        -- Sin items: compra con dinero
                        TriggerServerEvent('rs_furniture:server:buy',
                            globalpropname, furnitem, furniname, furnitemcost,
                            xx, yy, zz, hh)
                    else
                        -- Con items: coloca gastando el item, coste = 0
                        TriggerServerEvent('rs_furniture:server:place',
                            globalpropname, furnitem, furniname, 0,
                            xx, yy, zz, hh, thefurniitem)
                    end
                    inmenu = false
                    local PlayerData = GetPlayerData()
                    PlayerData.IsInMenu = false
                    FreezeEntityPosition(PlayerPedId(), false)
                    ClearPedTasks(PlayerPedId())
                    MenuData.CloseAll()
                end
            end

            if data.current.value == "no" then
                placefurniture = false
                placedobject   = false
                if objectxyz then DeleteObject(objectxyz) objectxyz = nil end
                inmenu = false
                local PlayerData = GetPlayerData()
                PlayerData.IsInMenu = false
                FreezeEntityPosition(PlayerPedId(), false)
                ClearPedTasks(PlayerPedId())
                MenuData.CloseAll()
            end
        end,
        function(data, menu) menu.close() end
    )
end

function furnimenu()
    MenuData.CloseAll()

    local elements = {}
    local sellPercent = math.floor((Config.sellPercentage or 0.6) * 100)

    if not Config.furnitureitems then
        table.insert(elements, {
            label = Locales['MENU_FURNITURE_BUY'],
            value = "buyfurni",
            desc  = ""
        })
        table.insert(elements, {
            label = Locales['MENU_FURNITURE_SELL'],
            value = "sellfurni",
            desc  = Locales['MENU_FURNITURE_SELL_DESC'] .. " " .. sellPercent .. "%" .. " " .. Locales['MENU_FURNITURE_SELL_DESC_2']
        })
    else
        table.insert(elements, {
            label = Locales['MENU_FURNITURE_REMOVE'],
            value = "removefurni",
            desc  = ""
        })
    end

    table.insert(elements, {
        label = Locales['MENU_BACK'],
        value = "backup",
        desc  = ""
    })

    MenuData.Open("default", GetCurrentResourceName(), "menuapi", {
        title   = Locales['MENU_FURNITURE'],
        subtext = Locales['MENU_FURNITURE_SUBTEXT_PROP'] .. " " .. globalpropname .. " | " .. Locales['MENU_FURNITURE_SUBTEXT_RANGE'] .. " " .. globalpropconfig.actionsRange .. "m",
        align   = "right",
        elements = elements,
    },
    function(data, menu)
        if data.current.value == "backup"      then BackToManagement() return end
        if data.current.value == "buyfurni"    then buyfurnimenu()     return end
        if data.current.value == "sellfurni"   then sellfurnimenu()    return end
        if data.current.value == "removefurni" then removefurnimenu()  return end
    end,
    function(data, menu)
        BackToManagement()
    end)
end

function buyfurnimenu()
    MenuData.CloseAll()
    local elements = {}
    for k, v in pairs(Config.furniture) do
        table.insert(elements, { label = k, value = v, desc = "" })
    end
    table.insert(elements, { label = Locales['MENU_BACK'], value = "backup", desc = "" })

    MenuData.Open("default", GetCurrentResourceName(), "menuapi",
        {
            title    = Locales['MENU_FURNITURE'],
            subtext  = "",
            align    = "right",
            elements = elements,
        },
        function(data, menu)
            if data.current == "backup" or data.current.value == "backup" then
                furnimenu() return
            end
            buyfurnimenu2(data.current.value)
        end,
        function(data, menu)
            furnimenu()
        end
    )
end

function buyfurnimenu2(furnigroup)
    MenuData.CloseAll()

    local elements = {}

    for k, v in pairs(furnigroup) do
        table.insert(elements, {
            label = k .. " - $" .. v.cost,
            value = v,
            namee = k,
            desc  = "",
        })
    end

    table.insert(elements, {
        label = Locales['MENU_BACK'],
        value = "backup",
        desc  = ""
    })

    MenuData.Open("default", GetCurrentResourceName(), "menuapi",
    {
        title    = Locales['MENU_FURNITURE'],
        subtext  = "",
        align    = "right",
        elements = elements,
    },
    function(data, menu)

        if data.current == "backup"
        or data.current.value == "backup" then
            buyfurnimenu()
            return
        end

        furnitem       = data.current.value.hash
        furnitemcost   = data.current.value.cost
        furniname      = data.current.namee

        placefurniture   = true
        hidePlacementText = false

        inmenu = false

        local PlayerData = GetPlayerData()
        PlayerData.IsInMenu = false

        MenuData.CloseAll()

        FreezeEntityPosition(PlayerPedId(), false)
        ClearPedTasks(PlayerPedId())

    end,
    function(data, menu)
        buyfurnimenu()
    end)
end

function sellfurnimenu()
    MenuData.CloseAll()
    local elements = {}
    if next(furniturex) ~= nil then
        for _, v in ipairs(furniturex) do
            local sellprice = math.floor((v.price or 0) * Config.furnituresellrate)
            table.insert(elements, {
                label = (v.name or "?") .. " - $" .. sellprice,
                value = v,
                desc  = "",
            })
        end
    end
    table.insert(elements, { label = Locales['MENU_BACK'], value = "backup", desc = "" })

    MenuData.Open("default", GetCurrentResourceName(), "menuapi",
        {
            title    = Locales['MENU_FURNITURE'],
            subtext  = "",
            align    = "right",
            elements = elements,
        },
        function(data, menu)
            if data.current == "backup" or data.current.value == "backup" then
                furnimenu() return
            end
            TriggerServerEvent('rs_furniture:server:sell',
                globalpropname, tostring(data.current.value.id))
            inmenu = false
            local PlayerData = GetPlayerData()
            PlayerData.IsInMenu = false
            FreezeEntityPosition(PlayerPedId(), false)
            ClearPedTasks(PlayerPedId())
            MenuData.CloseAll()
        end,
        function(data, menu)
            furnimenu()
        end
    )
end

function removefurnimenu()
    MenuData.CloseAll()
    local elements = {}
    if next(furniturex) ~= nil then
        for _, v in ipairs(furniturex) do
            table.insert(elements, {
                label = v.name or "?",
                value = v,
                desc  = "",
            })
        end
    end
    table.insert(elements, { label = Locales['MENU_BACK'], value = "backup", desc = "" })

    MenuData.Open("default", GetCurrentResourceName(), "menuapi",
        {
            title    = Locales['MENU_FURNITURE'],
            subtext  = "",
            align    = "right",
            elements = elements,
        },
        function(data, menu)
            if data.current == "backup" or data.current.value == "backup" then
                furnimenu() return
            end
            TriggerServerEvent('rs_furniture:server:remove',
                globalpropname, tostring(data.current.value.id))
            inmenu = false
            local PlayerData = GetPlayerData()
            PlayerData.IsInMenu = false
            FreezeEntityPosition(PlayerPedId(), false)
            ClearPedTasks(PlayerPedId())
            MenuData.CloseAll()
        end,
        function(data, menu)
            furnimenu()
        end
    )
end

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for propname, entities in pairs(spawnedfurniture) do
            for _, ent in ipairs(entities) do
                if DoesEntityExist(ent) then DeleteObject(ent) end
            end
        end
    end
end)