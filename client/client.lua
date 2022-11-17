local QRCore = exports['qr-core']:GetCoreObject()
local campfire = false

------------------------------------------------------------------------------------------------------

-- setup campfire / use campfire to setup and put out
RegisterNetEvent('rsg-cooking:client:setupcampfire')
AddEventHandler('rsg-cooking:client:setupcampfire', function()
	local ped = PlayerPedId()
    if campfire == true then
		CrouchAnim()
		Wait(6000)
		ClearPedTasks(ped)
        SetEntityAsMissionEntity(fire)
        DeleteObject(fire)
        SetEntityAsMissionEntity(cookgrill)
        DeleteObject(cookgrill)
		QRCore.Functions.Notify('campfire put out', 'primary')
		campfire = false
    elseif campfire == false then
		CrouchAnim()
		Wait(6000)
		ClearPedTasks(ped)
		local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.75, -1.55))
		local prop = CreateObject(GetHashKey("p_campfire05x"), x, y, z, true, false, true)
		local prop2 = CreateObject(GetHashKey("p_cookgrate01x"), x, y, z, true, false, true)
		SetEntityHeading(prop, GetEntityHeading(PlayerPedId()))
		SetEntityHeading(prop2, GetEntityHeading(PlayerPedId()))
		PlaceObjectOnGroundProperly(prop)
		PlaceObjectOnGroundProperly(prop2)
		fire = prop
		cookgrill = prop2
		QRCore.Functions.Notify('campfire deployed', 'primary')
		campfire = true
	end
end, false)

-- trigger cook menu
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local pos, awayFromObject = GetEntityCoords(PlayerPedId()), true
		for _,v in pairs(Config.CampfireProps) do
			local cookObject1 = GetClosestObjectOfType(pos, 5.0, GetHashKey(v), false, false, false)
			if cookObject1 ~= 0 then
				local objectPos = GetEntityCoords(cookObject1)
				if #(pos - objectPos) < 3.0 then
					awayFromObject = false
					DrawText3Ds(objectPos.x, objectPos.y, objectPos.z + 1.0, "Cook Menu [J]")
					if IsControlJustReleased(0, QRCore.Shared.Keybinds['J']) then
						TriggerEvent('rsg-cooking:client:cookmenu')
					end
				end
			end
		end
		if awayFromObject then
			Wait(1000)
		end
	end
end)

------------------------------------------------------------------------------------------------------

-- cook menu
RegisterNetEvent('rsg-cooking:client:cookmenu', function()
    cookMenu = {}
    cookMenu = {
        {
            header = "🥩 | Cooking Menu",
            isMenuHeader = true,
        },
    }
    for k, v in pairs(Config.Recipes) do
        local item = {}
        local text = ""
        for k, v in pairs(v.ingredients) do
            text = text .. "- " .. QRCore.Shared.Items[v.item].label .. ": " .. v.amount .. "x <br>"
        end
        cookMenu[#cookMenu + 1] = {
            header = k,
            txt = text,
            params = {
                event = 'rsg-cooking:client:checkingredients',
                args = {
					name = v.name,
                    item = k,
                    cooktime = v.cooktime,
					receive = v.receive
                }
            }
        }
    end
    cookMenu[#cookMenu + 1] = {
        header = "❌ | Close Menu",
        txt = '',
        params = {
            event = 'qr-menu:closeMenu',
        }
    }
    exports['qr-menu']:openMenu(cookMenu)
end)

------------------------------------------------------------------------------------------------------

-- check player has the ingredients to cook item
RegisterNetEvent('rsg-cooking:client:checkingredients', function(data)
	QRCore.Functions.TriggerCallback('rsg-cooking:server:checkingredients', function(hasRequired)
    if (hasRequired) then
		if Config.Debug == true then
			print("passed")
		end
		TriggerEvent('rsg-cooking:cookmeal', data.name, data.item, tonumber(data.cooktime), data.receive)
	else
		if Config.Debug == true then
			print("failed")
		end
		return
	end
	end, Config.Recipes[data.item].ingredients)
end)

-- do cooking
RegisterNetEvent('rsg-cooking:cookmeal', function(name, item, cooktime, receive)
	local ingredients = Config.Recipes[item].ingredients
	QRCore.Functions.Progressbar('cook-meal', 'Cooking a '..name, cooktime, false, true, {
		disableMovement = true,
		disableCarMovement = false,
		disableMouse = false,
		disableCombat = true,
	}, {}, {}, {}, function() -- Done
		TriggerServerEvent('rsg-cooking:server:finishcooking', ingredients, receive)
	end)
end)

------------------------------------------------------------------------------------------------------

-- ped crouch
function CrouchAnim()
    local dict = "script_rc@cldn@ig@rsc2_ig1_questionshopkeeper"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    TaskPlayAnim(ped, dict, "inspectfloor_player", 0.5, 8.0, -1, 1, 0, false, false, false)
end

------------------------------------------------------------------------------------------------------

-- text for trigger
function DrawText3Ds(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(9)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
end

------------------------------------------------------------------------------------------------------
