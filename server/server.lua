local RSGCore = exports['rsg-core']:GetCoreObject()


-----------------------------------------------------------------------
-- version checker
-----------------------------------------------------------------------
local function versionCheckPrint(_type, log)
    local color = _type == 'success' and '^2' or '^1'

    print(('^5['..GetCurrentResourceName()..']%s %s^7'):format(color, log))
end

local function CheckVersion()
    PerformHttpRequest('https://raw.githubusercontent.com/Rexshack-RedM/rsg-cooking/main/version.txt', function(err, text, headers)
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')

        if not text then 
            versionCheckPrint('error', 'Currently unable to run a version check.')
            return 
        end

        --versionCheckPrint('success', ('Current Version: %s'):format(currentVersion))
        --versionCheckPrint('success', ('Latest Version: %s'):format(text))
        
        if text == currentVersion then
            versionCheckPrint('success', 'You are running the latest version.')
        else
            versionCheckPrint('error', ('You are currently running an outdated version, please update to version %s'):format(text))
        end
    end)
end

-- use campfire
RSGCore.Functions.CreateUseableItem("campfire", function(source, item)
    local src = source


    -- Trigger the campfire setup event
    TriggerClientEvent('rsg-cooking:client:setupcampfire', src, item.name)
end, false)

-- check player has the ingredients
RSGCore.Functions.CreateCallback('rsg-cooking:server:checkingredients', function(source, cb, ingredients, cookamount)
    local src = source
    local hasItems = false
    local icheck = 0
    local Player = RSGCore.Functions.GetPlayer(src)
    for k, v in pairs(ingredients) do
        if Player.Functions.GetItemByName(v.item) and Player.Functions.GetItemByName(v.item).amount >= v.amount * cookamount then
            icheck = icheck + 1
            if icheck == #ingredients then
                cb(true)
            end
        else
            TriggerClientEvent('RSGCore:Notify', src, Lang:t('error.you_dont_have_the_required_items').. v.item, 'error')
            cb(false)
            return
        end
    end
end)

-- finish cooking
RegisterServerEvent('rsg-cooking:server:finishcooking')
AddEventHandler('rsg-cooking:server:finishcooking', function(ingredients, receive, giveamount, cookamount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    -- remove ingredients
    for k, v in pairs(ingredients) do
        if Config.Debug == true then
            print(v.item)
            print(v.amount)
        end
        local requiredAmount = v.amount * cookamount
        Player.Functions.RemoveItem(v.item, requiredAmount)    
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[v.item], "remove")
    end
    -- add cooked item
    Player.Functions.AddItem(receive, giveamount * cookamount)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[receive], "add")
    local labelReceive = RSGCore.Shared.Items[receive].label
    TriggerClientEvent('RSGCore:Notify', src, Lang:t('success.cooking_successful')..' '..cookamount..' ' .. labelReceive, 'success')
end)

-- Add this event handler after your existing code
RegisterServerEvent('rsg-campfire:giveCoal')
AddEventHandler('rsg-campfire:giveCoal', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    if Player then
        local coalItem = "coal"  -- Replace with the actual item name for coal in your inventory system
        local amountToAdd = 3     -- Number of coal pieces to add
        Player.Functions.AddItem(coalItem, amountToAdd)
        TriggerClientEvent('RSGCore:Notify', src, 'You received 3 pieces of coal.', 'success')
    end
end)

-- Add this event handler after your existing code
RegisterServerEvent('rsg-cooking:server:removeCampfire')
AddEventHandler('rsg-cooking:server:removeCampfire', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    if Player then
        local campfireItem = "campfire"  -- Replace with the actual item name for the campfire in your inventory system
        local amountToRemove = 1          -- Number of campfire items to remove
        Player.Functions.RemoveItem(campfireItem, amountToRemove)
        
    end
end)

--------------------------------------------------------------------------------------------------
-- start version check
--------------------------------------------------------------------------------------------------
CheckVersion()
