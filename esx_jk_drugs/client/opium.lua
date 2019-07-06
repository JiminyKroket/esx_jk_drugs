local spawnedPoppy = 0
local poppyPlants = {}
local isPickingUp, isProcessing = false, false


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		local coords = GetEntityCoords(PlayerPedId())

		if GetDistanceBetweenCoords(coords, Config.FieldZones.PoppyField.coords, true) < 45 then
			TriggerEvent('esx:showNotification', "~r~The Wong Family might have your head for playing in their Poppy field.")
			SpawnPoppyPlants()
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

		if GetDistanceBetweenCoords(coords, Config.ProcessZones.PoppyProcessing.coords, true) < 15 then
			ESX.ShowNotification("Looks like Humane Labs is getting into opioids")
		end
		if GetDistanceBetweenCoords(coords, Config.ProcessZones.PoppyProcessing.coords, true) < 1 then
			ProcessPoppy()
			Citizen.Wait(500)
		end
	end
end)

function ProcessPoppy()
	isProcessing = true

	TriggerServerEvent('esx_drugs:processPoppy')
	local timeLeft = Config.Delays.PoppyProcessing / 1000
	local playerPed = PlayerPedId()

	while timeLeft > 0 do
		Citizen.Wait(1000)
		timeLeft = timeLeft - 1

		if GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.ProcessZones.PoppyProcessing.coords, false) > 4 then
			TriggerServerEvent('esx_drugs:cancelProcessing')
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

		if GetDistanceBetweenCoords(coords, Config.DumpZones.OpiumDump.coords, true) < 1 then
			if not menuOpen3 then
				ESX.ShowHelpNotification("Press [E] to throw your opium in the O'Neil fireplace, they'll pay don't worry")

				if IsControlJustReleased(0, Keys['E']) then
					wasOpen3 = true
					OpenOpiumDump()
					if Config.EnableCops then
						TriggerServerEvent('esx_drugs:selling')
					end
				end
			else
				Citizen.Wait(500)
			end
		else
			if wasOpen3 then
				wasOpen3 = false
				ESX.UI.Menu.CloseAll()
			end

			Citizen.Wait(500)
		end
	end
end)

function OpenOpiumDump()
	ESX.UI.Menu.CloseAll()
	local elements = {}
	menuOpen3 = true

	for k, v in pairs(ESX.GetPlayerData().inventory) do
		local price = Config.OpiumDumpItems[v.name]

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
			TriggerServerEvent('esx_drugs:sellOpium', data.current.name, data.current.value)
			menu.close()
			menuOpen3 = false
			end, function(data, menu)
		end)

		menuOpen3 = false
	else
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'drug_shop', {
			title    = _U('dealer_title'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			TriggerServerEvent('esx_drugs:sellOpium', data.current.name, data.current.value)
		end, function(data, menu)
			menu.close()
			menuOpen3 = false
		end)

		menuOpen3 = false
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		local nearbyObject, nearbyID

		for i=1, #poppyPlants, 1 do
			if GetDistanceBetweenCoords(coords, GetEntityCoords(poppyPlants[i]), false) < 1 then
				nearbyObject, nearbyID = poppyPlants[i], i
			end
		end

		if nearbyObject and IsPedOnFoot(playerPed) then

			if not isPickingUp then
				ESX.ShowHelpNotification(_U('opium_pickupprompt'))
			end

			if IsControlJustReleased(0, Keys['E']) and not isPickingUp then
				isPickingUp = true

				ESX.TriggerServerCallback('esx_drugs:canPickUp', function(canPickUp)

					if canPickUp then
						TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, false)

						Citizen.Wait(2000)
						ClearPedTasks(playerPed)
						Citizen.Wait(1500)
		
						ESX.Game.DeleteObject(nearbyObject)
		
						table.remove(poppyPlants, nearbyID)
						spawnedPoppy = spawnedPoppy - 1
		
						TriggerServerEvent('esx_drugs:pickedUpPoppy')
					else
						ESX.ShowNotification(_U('opium_inventoryfull'))
					end

					isPickingUp = false

				end, 'opium')
			end

		else
			Citizen.Wait(500)
		end

	end

end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(poppyPlants) do
			ESX.Game.DeleteObject(v)
		end
	end
end)

function SpawnPoppyPlants()
	while spawnedPoppy < 25 do
		Citizen.Wait(0)
		local poppyCoords = GeneratePoppyCoords()

		ESX.Game.SpawnLocalObject('prop_plant_group_03', poppyCoords, function(obj)
			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)

			table.insert(poppyPlants, obj)
			spawnedPoppy = spawnedPoppy + 1
		end)
	end
end

function ValidatePoppyCoord(plantCoord)
	if spawnedPoppy > 0 then
		local validate = true

		for k, v in pairs(poppyPlants) do
			if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
				validate = false
			end
		end

		if GetDistanceBetweenCoords(plantCoord, Config.FieldZones.PoppyField.coords, false) > 50 then
			validate = false
		end

		return validate
	else
		return true
	end
end

function GeneratePoppyCoords()
	while true do
		Citizen.Wait(1)

		local poppyCoordX, poppyCoordY

		math.randomseed(GetGameTimer())
		local modX = math.random(-90, 90)

		Citizen.Wait(100)

		math.randomseed(GetGameTimer())
		local modY = math.random(-90, 90)

		poppyCoordX = Config.FieldZones.PoppyField.coords.x + modX
		poppyCoordY = Config.FieldZones.PoppyField.coords.y + modY

		local coordZ = GetCoordZ(poppyCoordX, poppyCoordY)
		local coord = vector3(poppyCoordX, poppyCoordY, coordZ)

		if ValidatePoppyCoord(coord) then
			return coord
		end
	end
end

function GetCoordZ(x, y)
	local groundCheckHeights = { 115.0, 116.0, 117.0, 118.0, 119.0, 120.0, 121.0, 122.0, 123.0, 124.0, 125.0, 126., 127.0, 128.0, 129.0, 130.0, 131.0, 132.0, 133.0, 134.0, 135.0, 136.0, 137.0, 138.0, 139.0, 140.0 }

	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

		if foundGround then
			return z
		end
	end

	return 128.0
end