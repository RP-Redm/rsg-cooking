local QRCore = exports['qr-core']:GetCoreObject()

-- use campfire
QRCore.Functions.CreateUseableItem("campfire", function(source, item)
    local src = source
	TriggerClientEvent('rsg-cooking:client:setupcampfire', src, item.name)
end)

-- check player has the ingredients
QRCore.Functions.CreateCallback('rsg-cooking:server:checkingredients', function(source, cb, ingredients)
    local src = source
    local hasItems = false
    local icheck = 0
    local Player = QRCore.Functions.GetPlayer(src)
	for k, v in pairs(ingredients) do
		if Player.Functions.GetItemByName(v.item) and Player.Functions.GetItemByName(v.item).amount >= v.amount then
			icheck = icheck + 1
			if icheck == #ingredients then
				cb(true)
			end
		else
			TriggerClientEvent('QRCore:Notify', src, 'You don\'t have the required items!', 'error')
			cb(false)
			return
		end
	end
end)

-- finish cooking
RegisterServerEvent('rsg-cooking:server:finishcooking')
AddEventHandler('rsg-cooking:server:finishcooking', function(ingredients, receive)
	local src = source
    local Player = QRCore.Functions.GetPlayer(src)
	-- remove ingredients
	for k, v in pairs(ingredients) do
		if Config.Debug == true then
			print(v.item)
			print(v.amount)
		end
		Player.Functions.RemoveItem(v.item, v.amount)
		TriggerClientEvent('inventory:client:ItemBox', src, QRCore.Shared.Items[v.item], "remove")
	end
	-- add cooked item
	Player.Functions.AddItem(receive, 1)
	TriggerClientEvent('inventory:client:ItemBox', src, QRCore.Shared.Items[receive], "add")
	TriggerClientEvent('QRCore:Notify', src, 'cooking finished', 'success')
end)
