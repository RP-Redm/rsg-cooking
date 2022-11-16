local QRCore = exports['qr-core']:GetCoreObject()

-- use campfire
QRCore.Functions.CreateUseableItem("campfire", function(source, item)
    local src = source
	TriggerClientEvent('rsg-cooking:client:setupcampfire', src, item.name)
end)

-- finish cooking
RegisterServerEvent('rsg-cooking:server:finishcooking')
AddEventHandler('rsg-cooking:server:finishcooking', function(item, amount, meal)
	local src = source
    local Player = QRCore.Functions.GetPlayer(src)
	Player.Functions.RemoveItem(item, amount)
	TriggerClientEvent('inventory:client:ItemBox', src, QRCore.Shared.Items[item], "remove")
	-- add items
	Player.Functions.AddItem(meal, 1)
	TriggerClientEvent('inventory:client:ItemBox', src, QRCore.Shared.Items[meal], "add")
	TriggerClientEvent('QRCore:Notify', src, 'cooking finished', 'success')
end)
