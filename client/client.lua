local RSGCore = exports['rsg-core']:GetCoreObject()
local campfire = false
local fire
local cookgrill
local options = {}

------------------------------------------------------------------------------------------------------

exports['rsg-target']:AddTargetModel(Config.CampfireProps, {
    options = {
        {
            type = "client",
            event = 'rsg-cooking:client:cookmenu',
            icon = "far fa-eye",
            label = Lang:t('label.open_cooking_menu'),
            distance = 3.0
        }
    }
})

------------------------------------------------------------------------------------------------------

-- setup campfire / use campfire to setup and put out
RegisterNetEvent('rsg-cooking:client:setupcampfire')
AddEventHandler('rsg-cooking:client:setupcampfire', function()
    local ped = PlayerPedId()
    if campfire == true then
        TaskStartScenarioInPlace(ped, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), -1, true, false, false, false)
        Wait(6000)
        ClearPedTasks(ped)
        SetEntityAsMissionEntity(fire)
        DeleteObject(fire)
        SetEntityAsMissionEntity(cookgrill)
        DeleteObject(cookgrill)
        RSGCore.Functions.Notify(Lang:t('primary.campfire_put_out'), 'primary')
        campfire = false
    elseif campfire == false then
        TaskStartScenarioInPlace(ped, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), -1, true, false, false, false)
        Wait(6000)
        ClearPedTasks(ped)
        local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.75, -1.55))
        local prop = CreateObject(GetHashKey("p_campfire05x"), x, y+1, z, true, false, true)
        local prop2 = CreateObject(GetHashKey("p_cookgrate01x"), x, y+1, z, true, false, true)
        SetEntityHeading(prop, GetEntityHeading(PlayerPedId()))
        SetEntityHeading(prop2, GetEntityHeading(PlayerPedId()))
        PlaceObjectOnGroundProperly(prop)
        PlaceObjectOnGroundProperly(prop2)
        fire = prop
        cookgrill = prop2
        RSGCore.Functions.Notify(Lang:t('primary.campfire_deployed'), 'primary')
        campfire = true
    end
end, false)

------------------------------------------------------------------------------------------------------

for _, v in ipairs(Config.Recipes) do
    table.insert(options, {
        title = v.title,
        description = v.description,
        icon = 'fa-solid fa-kitchen-set',
        event = 'rsg-cooking:client:checkingredients',
        args = {
            title = v.title,
            ingredients = v.ingredients,
            cooktime = v.cooktime,
            receive = v.receive,
            giveamount = v.giveamount
        }
    })
end

RegisterNetEvent('rsg-cooking:client:cookmenu', function()
    lib.registerContext({
        id = 'cooking_menu',
        title = 'Cooking Menu',
        options = options
    })
    lib.showContext('cooking_menu')
end)

------------------------------------------------------------------------------------------------------

-- check player has the ingredients to cook item
RegisterNetEvent('rsg-cooking:client:checkingredients', function(data)
    RSGCore.Functions.TriggerCallback('rsg-cooking:server:checkingredients', function(hasRequired)
    if (hasRequired) then
        if Config.Debug == true then
            print("passed")
        end
        TriggerEvent('rsg-cooking:cookmeal', data.title, data.ingredients, tonumber(data.cooktime), data.receive, data.giveamount)
    else
        if Config.Debug == true then
            print("failed")
        end
        return
    end
    end, data.ingredients)
end)

-- do cooking
RegisterNetEvent('rsg-cooking:cookmeal', function(title, ingredients, cooktime, receive, giveamount)
    RSGCore.Functions.Progressbar('cook-meal', Lang:t('progressbar.cooking_a')..title, cooktime, false, true, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerServerEvent('rsg-cooking:server:finishcooking', ingredients, receive, giveamount)
    end)
end)

------------------------------------------------------------------------------------------------------
