local spawnedWeeds = 1
local weedPlants = {}
local isPickingUp, isProcessing = false, false


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		local coords = GetEntityCoords(PlayerPedId())

		if GetDistanceBetweenCoords(coords, Config.FieldZones.WeedField.coords, true) < 20 then
			TriggerEvent('esx:showNotification', _U('weed_field_close'))
			SpawnWeedPlants()
			Citizen.Wait(500)
		else
			Citizen.Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if GetDistanceBetweenCoords(coords, Config.ProcessZones.WeedProcessing.coords, true) < 15 and GetDistanceBetweenCoords(coords, Config.ProcessZones.WeedProcessing.coords, true) > 10 then
			ESX.ShowNotification(_U('weed_process_close'))
		end
		if GetDistanceBetweenCoords(coords, Config.ProcessZones.WeedProcessing.coords, true) < 1.5 and not isProcessing then
			ProcessWeed()
			Citizen.Wait(500)
		end
	end
end)

function ProcessWeed()
	isProcessing = true

	TriggerServerEvent('esx_jk_drugs:processCannabis')
	local timeLeft = Config.Delays.WeedProcessing / 1000
	local playerPed = PlayerPedId()

	while timeLeft > 0 do
		Citizen.Wait(1000)
		timeLeft = timeLeft - 1

		if GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.ProcessZones.WeedProcessing.coords, false) > 4 then
			TriggerServerEvent('esx_jk_drugs:cancelProcessing')
			break
		end
	end
	isProcessing = false
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if GetDistanceBetweenCoords(coords, Config.DumpZones.WeedDump.coords, true) < 1 then
			if not menuOpen4 then
				ESX.ShowHelpNotification(_U('weed_sell'))

				if IsControlJustReleased(0, 38) then
					wasOpen4 = true
					OpenWeedDump()
					if Config.EnableCops then	
						local percent = math.random(11)

						if percent <= 2 or percent >= 10 then
						TriggerEvent('esx_jk_drugs:selling', source)	
						end
					end
				end
			else
				Citizen.Wait(500)
			end
		else
			if wasOpen4 then
				wasOpen4 = false
				ESX.UI.Menu.CloseAll()
			end

			Citizen.Wait(500)
		end
	end
end)

function OpenWeedDump()
	ESX.UI.Menu.CloseAll()
	local elements = {}
	menuOpen4 = true

	for k, v in pairs(ESX.GetPlayerData().inventory) do
		local price = Config.WeedDumpItems[v.name]

		if price and v.count > 0 then
			table.insert(elements, {
				label = ('%s - <span style="color:green;">%s</span>'):format(v.label, _U('dealer_item', ESX.Math.GroupDigits(price))),
				name = v.name,
				price = price,

				-- menu properties
				type = 'slider',
				value = 1,
				min = 1,
				max = 10
			})
		end
	end

	if Config.ForceMulti then
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'drug_shop', {
			title    = _U('dealer_title'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			TriggerServerEvent('esx_jk_drugs:sellWeed', data.current.name, data.current.value)
			menu.close()
			menuOpen4 = false
			end, function(data, menu)
		end)

		menuOpen4 = false
	else
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'drug_shop', {
			title    = _U('dealer_title'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			TriggerServerEvent('esx_jk_drugs:sellWeed', data.current.name, data.current.value)
		end, function(data, menu)
			menu.close()
			menuOpen4 = false
		end)

		menuOpen4 = false
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		local nearbyObject, nearbyID

		for i=1, #weedPlants, 1 do
			if GetDistanceBetweenCoords(coords, GetEntityCoords(weedPlants[i]), false) < 1 then
				nearbyObject, nearbyID = weedPlants[i], i
			end
		end

		if nearbyObject and IsPedOnFoot(playerPed) and not IsPedUsingAnyScenario(playerPed) then

			if not isPickingUp then
				ESX.ShowHelpNotification(_U('weed_pickupprompt'))
			end

			if IsControlJustReleased(0, 38) and not isPickingUp then
				isPickingUp = true

				ESX.TriggerServerCallback('esx_jk_drugs:canPickUp', function(canPickUp)

					if canPickUp then
						TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, false)

						table.remove(weedPlants, nearbyID)
						spawnedWeeds = spawnedWeeds - 1

						Citizen.Wait(1250)
						ClearPedTasks(playerPed)
						Citizen.Wait(1500)
						ESX.Game.DeleteObject(nearbyObject)

						TriggerServerEvent('esx_jk_drugs:pickedUpCannabis')
					else
						ESX.ShowNotification(_U('weed_inventoryfull'))
					end
				end, 'cannabis')
				isPickingUp = false
			end
		else
			Citizen.Wait(500)
		end
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(weedPlants) do
			ESX.Game.DeleteObject(v)
		end
	end
end)

function SpawnWeedPlants()
	while spawnedWeeds < 10 do
		Citizen.Wait(0)
		local weedCoords = GenerateWeedCoords()

		ESX.Game.SpawnLocalObject('prop_weed_01', weedCoords, function(obj)
			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)

			table.insert(weedPlants, obj)
			spawnedWeeds = spawnedWeeds + 1
		end)
	end
end

function ValidateWeedCoord(plantCoord)
	if spawnedWeeds > 0 then
		local validate = true

		for k, v in pairs(weedPlants) do
			if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
				validate = false
			end
		end

		if GetDistanceBetweenCoords(plantCoord, Config.FieldZones.WeedField.coords, false) > 5 then
			validate = false
		end

		return validate
	else
		return true
	end
end

function GenerateWeedCoords()
	while true do
		Citizen.Wait(1)

		local weedCoordX, weedCoordY

		math.randomseed(GetGameTimer())
		local modX = math.random(-20, 20)

		Citizen.Wait(100)

		math.randomseed(GetGameTimer())
		local modY = math.random(-20, 20)

		weedCoordX = Config.FieldZones.WeedField.coords.x + modX
		weedCoordY = Config.FieldZones.WeedField.coords.y + modY

		local coordZ = GetCoordZ(weedCoordX, weedCoordY)
		local coord = vector3(weedCoordX, weedCoordY, coordZ)

		if ValidateWeedCoord(coord) then
			return coord
		end
	end
end

function GetCoordZ(x, y)
    local ped = GetPlayerPed(-1)
    local coords = GetEntityCoords(ped)
    local groundCheckHeights = { (GetGroundZFor_3dCoord(coords) - 1),  (GetGroundZFor_3dCoord(coords)),  (GetGroundZFor_3dCoord(coords) + 1) }

    for i, height in ipairs(groundCheckHeights) do
        local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

        if foundGround then
            return z
        end
    end
    return GetGroundZFor_3dCoord(coords)
end