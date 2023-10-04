-- Ensure the resource 'rsg-core' is properly imported and accessible
local RSGCore = exports['rsg-core']:GetCoreObject()

-- Initialize campfire and other variables
local campfire = false
local fire
local options = {}

-- Add target models for interaction
exports['rsg-target']:AddTargetModel(Config.CampfireProps, {
    options = {
        {
            type = "client",
            event = 'rsg-cooking:client:cookmenu',
            icon = "far fa-eye",
            label = Lang:t('label.open_cooking_menu'),
            distance = 3.0
        },
        {
            event = "rsg-campfire:getWarm",
            icon = "fas fa-fire",
            label = "Warm Up",
        },
        {
            icon = "fas fa-fire-extinguisher",
            label = "Extinguish",
            action = function(entity)
                TriggerEvent('rsg-campfire:removeCampfire', entity)
            end
        },
    }
})

-- Event to get warm
RegisterNetEvent('rsg-campfire:getWarm', function()
    local ped = PlayerPedId(-1)

    
    RSGCore.Functions.RequestAnimDict('script_common@shared_scenarios@kneel@mourn@female@a@base')
    TaskPlayAnim(ped, "script_common@shared_scenarios@kneel@mourn@female@a@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)

    -- Show progress circle while warming up
    if lib.progressCircle({
        duration = 27000, -- Adjust the duration as needed
        position = 'bottom',
        label = 'Warming Up.... ',
        useWhileDead = false,
        canCancel = false, -- Change to true if you want to allow canceling
        anim = {
            dict = 'script_common@shared_scenarios@kneel@mourn@female@a@base',
            clip = 'empathise_headshake_f_001',
            flag = 15,  
        },
        disableControl = true, -- Disable player control during the animation
        text = 'Warming up...',
    }) then
        --- Clear the animation immediately
        ClearPedTasksImmediately(ped)

        -- Increase player's health
        local maxHealth = GetEntityMaxHealth(ped)
        local health = GetEntityHealth(ped)
        local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 60))
        SetEntityHealth(ped, newHealth)
    else
        -- Handle cancelation or failure
        RSGCore.Functions.Notify("Warming up canceled or failed.", 'error')
    end
end)

--no props in towns
function CanPlacePropHere(pos)
    local canPlace = true

    local ZoneTypeId = 1  -- Replace with the correct ZoneTypeId you want to check
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
    local town = Citizen.InvokeNative(0x43AD8FC02B429D33, x, y, z, ZoneTypeId)

    if town ~= false then
        canPlace = false
    end

    return canPlace
end

-- setup campfire  
RegisterNetEvent('rsg-cooking:client:setupcampfire')
AddEventHandler('rsg-cooking:client:setupcampfire', function()
    local ped = PlayerPedId()
    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.75, -1.55))
    local positionToCheck = { x = x, y = y + 1, z = z }

    if CanPlacePropHere(positionToCheck) then
        if existingCampfire then
            -- Display a message to the player
            RSGCore.Functions.Notify('Your existing campfire will be put out to place a new one.', 'inform', 5000) -- Change the duration as needed (in milliseconds)

            -- Remove the existing campfire if it exists
            DeleteObject(existingCampfire)
        end

        local ped = PlayerPedId()
        RSGCore.Functions.RequestAnimDict('script_common@shared_scenarios@kneel@mourn@female@a@base')
        TaskPlayAnim(ped, "script_common@shared_scenarios@kneel@mourn@female@a@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
        
        -- Use the Oxlib progress circle
        if lib.progressCircle({
            duration = 20000, -- Adjust the duration as needed
            position = 'bottom',
            label = 'Setting Up Campfire',
            useWhileDead = false,
            canCancel = true,
            anim = {
                dict = 'script_common@shared_scenarios@kneel@mourn@female@a@base',
                clip = 'empathise_headshake_f_001',
                flag = 15,
            },
        }) then
            -- Place the campfire after the progress circle completes
            local prop = CreateObject(GetHashKey("p_campfire05x"), x, y + 1, z, true, false, true)
            SetEntityHeading(prop, GetEntityHeading(PlayerPedId()))
            PlaceObjectOnGroundProperly(prop)
            fire = prop
            RSGCore.Functions.Notify("Campfire deployed.", 'primary')
            TriggerServerEvent('rsg-cooking:server:removeCampfire')
            campfire = true  -- Set the campfire variable to true
            existingCampfire = prop -- Update the existing campfire reference
        else
            -- Handle cancelation
            RSGCore.Functions.Notify("Campfire setup canceled.", 'error')
        end
        
        -- Stop the animation task even if the progress circle is canceled
        StopAnimTask(ped, 'script_common@shared_scenarios@kneel@mourn@female@a@base', 'base', 1.0)
    else
        -- Handle blocked placement
        RSGCore.Functions.Notify('You cannot place the campfire here.', 'error')
    end
end, false)

-- Remove campfire
RegisterNetEvent('rsg-campfire:removeCampfire', function(Campfire)
    local ped = PlayerPedId()
    campfire = false

    RSGCore.Functions.RequestAnimDict('script_common@shared_scenarios@kneel@mourn@female@a@base')
    TaskPlayAnim(ped, "script_common@shared_scenarios@kneel@mourn@female@a@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
    
    -- Use the Oxlib progress circle
    if lib.progressCircle({
        duration = 3000, -- Adjust the duration as needed
        label = 'Removing Campfire',
        position = 'bottom',
        useWhileDead = false,
        canCancel = false, -- Change to true if you want to allow canceling
        anim = {
            dict = 'script_common@shared_scenarios@kneel@mourn@female@a@base',
            clip = 'empathise_headshake_f_001',
            flag = 15,
        },
    }) then
        -- Stop the animation task
        StopAnimTask(ped, 'script_common@shared_scenarios@kneel@mourn@female@a@base', 'base', 1.0)

        -- Delete the campfire object
        DeleteObject(Campfire)

        -- Add coal to the player's inventory using RSGCore's AddItem function
        TriggerServerEvent('rsg-campfire:giveCoal')

        RSGCore.Functions.Notify("Campfire removed.", 'primary')
    else
        -- Handle cancelation
        RSGCore.Functions.Notify("Campfire removal canceled.", 'error')
    end
end)
------------------------------------------------------------------------------------------------------

-- create a table to store menu options by category
local categoryMenus = {}

-- iterate through recipes and organize them by category
for _, v in ipairs(Config.Recipes) do
    local ingredientsMetadata = {}

    for i, ingredient in ipairs(v.ingredients) do
        table.insert(ingredientsMetadata, { label = RSGCore.Shared.Items[ingredient.item].label, value = ingredient.amount })
    end
    local option = {
        title = v.title,
        icon = 'fa-solid fa-kitchen-set',
        event = 'rsg-cooking:client:checkingredients',
        metadata = ingredientsMetadata,
        args = {
            title = v.title,
            ingredients = v.ingredients,
            cooktime = v.cooktime,
            receive = v.receive,
            giveamount = v.giveamount
        }
    }

    -- check if a menu already exists for this category
    if not categoryMenus[v.category] then
        categoryMenus[v.category] = {
            id = 'cooking_menu_' .. v.category,
            title = 'Cooking Menu - ' .. v.category,
            menu = 'cooking_main_menu',
            onBack = function() end,
            options = { option }
        }
    else
        table.insert(categoryMenus[v.category].options, option)
    end
end

-- log menu events by category
for category, menuData in pairs(categoryMenus) do
    RegisterNetEvent('rsg-cooking:client:' .. category)
    AddEventHandler('rsg-cooking:client:' .. category, function()
        lib.registerContext(menuData)
        lib.showContext(menuData.id)
    end)
end

-- main event to open main menu
RegisterNetEvent('rsg-cooking:client:cookmenu')
AddEventHandler('rsg-cooking:client:cookmenu', function()
    -- show main menu with categories
    local mainMenu = {
        id = 'cooking_main_menu',
        title = 'Cooking Main Menu',
        options = {}
    }

    for category, menuData in pairs(categoryMenus) do
        table.insert(mainMenu.options, {
            title = category,
            description = 'Explore the recipes for ' .. category,
            icon = 'fa-solid fa-kitchen-set',
            event = 'rsg-cooking:client:' .. category,
            arrow = true
        })
    end

    lib.registerContext(mainMenu)
    lib.showContext(mainMenu.id)
end)

------------------------------------------------------------------------------------------------------

-- check player has the ingredients to cook item
RegisterNetEvent('rsg-cooking:client:checkingredients', function(data)
    local input = lib.inputDialog('Cooking Amount', {
        { 
            type = 'input',
            label = 'Amount',
            required = true,
            min = 1, max = 10 
        },
    })

    if not input then return end

    local cookamount = tonumber(input[1])
    if cookamount then
        RSGCore.Functions.TriggerCallback('rsg-cooking:server:checkingredients', function(hasRequired)
            if (hasRequired) then
                if Config.Debug == true then
                    print("passed")
                end
                TriggerEvent('rsg-cooking:cookmeal', data.title, data.ingredients, tonumber(data.cooktime * cookamount), data.receive, data.giveamount,  cookamount)
            else
                if Config.Debug == true then
                    print("failed")
                end
                return
            end
        end, data.ingredients,  cookamount)
    end
end)

-- do cooking
RegisterNetEvent('rsg-cooking:cookmeal', function(title, ingredients, cooktime, receive, giveamount, cookamount)
    local ped = PlayerPedId()
    local animDict = 'script_common@shared_scenarios@kneel@mourn@female@a@base'
    local animName = 'base'

    RSGCore.Functions.RequestAnimDict(animDict)

    -- Check if the animation dictionary was successfully loaded
    if HasAnimDictLoaded(animDict) then
        -- Play the animation
        TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)

        -- Use the Oxlib progress circle with a message
        if lib.progressCircle({
            duration = cooktime, -- Adjust the duration as needed
            position = 'bottom',
            useWhileDead = false,
            canCancel = false, -- Change to true if you want to allow canceling
            anim = {
                dict = animDict,
                clip = 'empathise_headshake_f_001',
                flag = 15,
            },
            disableControl = true, -- Disable player control during the animation
            label = 'Cooking ' .. title, -- Your cooking message here
        }) then
            -- Cooking was successful
            TriggerServerEvent('rsg-cooking:server:finishcooking', ingredients, receive, giveamount, cookamount)

            -- Stop the animation
            StopAnimTask(ped, animDict, animName, 1.0)
        else
            -- Handle cancelation or failure
            RSGCore.Functions.Notify("Cooking canceled or failed.", 'error')

            -- Cancel the animation
            StopAnimTask(ped, animDict, animName, 1.0)
        end
    else
        -- Handle if the animation dictionary couldn't be loaded
        RSGCore.Functions.Notify("Failed to load animation dictionary.", 'error')
    end
end)


------------------------------------------------------------------------------------------------------
