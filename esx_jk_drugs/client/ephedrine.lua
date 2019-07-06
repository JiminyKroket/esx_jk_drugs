local spawnedEphedra = 5
local ephedraPlants = {}
local isPickingUp, isProcessing = false, false


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		local coords = GetEntityCoords(PlayerPedId())

		if GetDistanceBetweenCoords(coords, Config.FieldZones.EphedrineField.coords, true) < 100 then
			TriggerEvent('esx:showNotification', "~r~You are in a Restricted Area. Authorities have been notified, leave immediately!")
			TriggerServerEvent('esx_drugs:restrictedArea')
			SpawnEphedraPlants()
			
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

		if GetDistanceBetweenCoords(coords, Config.ProcessZones.EphedrineProcessing.coords, true) < 15 and GetDistanceBetweenCoords(coords, Config.ProcessZones.EphedrineProcessing.coords, true) > 10 then
			ESX.ShowNotification("You smell dead cats and piss")
		end
		if GetDistanceBetweenCoords(coords, Config.ProcessZones.EphedrineProcessing.coords, true) < 1 then
			ProcessEphedra()
			Citizen.Wait(500)
		end
	end
end)

function ProcessEphedra()
	isProcessing = true

	TriggerServerEvent('esx_drugs:processEphedra')
	local timeLeft = Config.Delays.EphedrineProcessing / 1000
	local playerPed = PlayerPedId()

	while timeLeft > 0 do
		Citizen.Wait(1000)
		timeLeft = timeLeft - 1

		if GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.ProcessZones.EphedrineProcessing.coords, false) > 4 then
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
		local nearbyObject, nearbyID

		for i=1, #ephedraPlants, 1 do
			if GetDistanceBetweenCoords(coords, GetEntityCoords(ephedraPlants[i]), false) < 1 then
				nearbyObject, nearbyID = ephedraPlants[i], i
			end
		end

		if nearbyObject and IsPedOnFoot(playerPed) then

			if not isPickingUp then
				ESX.ShowHelpNotification(_U('ephedrine_pickupprompt'))
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
		
						table.remove(ephedraPlants, nearbyID)
						spawnedEphedra = spawnedEphedra - 1
		
						TriggerServerEvent('esx_drugs:pickedUpEphedra')
					else
						ESX.ShowNotification(_U('ephedrine_inventoryfull'))
					end

					isPickingUp = false

				end, 'ephedrine')
			end

		else
			Citizen.Wait(500)
		end

	end

end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(ephedraPlants) do
			ESX.Game.DeleteObject(v)
		end
	end
end)

function SpawnEphedraPlants()
	while spawnedEphedra < 25 do
		Citizen.Wait(0)
		local ephedraCoords = GenerateEphedraCoords()

		ESX.Game.SpawnLocalObject('prop_plant_cane_01b', ephedraCoords, function(obj)
			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)

			table.insert(ephedraPlants, obj)
			spawnedEphedra = spawnedEphedra + 1
		end)
	end
end

function ValidateEphedraCoord(plantCoord)
	if spawnedEphedra > 0 then
		local validate = true

		for k, v in pairs(ephedraPlants) do
			if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
				validate = false
			end
		end

		if GetDistanceBetweenCoords(plantCoord, Config.FieldZones.EphedrineField.coords, false) > 50 then
			validate = false
		end

		return validate
	else
		return true
	end
end

function GenerateEphedraCoords()
	while true do
		Citizen.Wait(1)

		local ephedraCoordX, ephedraCoordY

		math.randomseed(GetGameTimer())
		local modX = math.random(-90, 90)

		Citizen.Wait(100)

		math.randomseed(GetGameTimer())
		local modY = math.random(-90, 90)

		ephedraCoordX = Config.FieldZones.EphedrineField.coords.x + modX
		ephedraCoordY = Config.FieldZones.EphedrineField.coords.y + modY

		local coordZ = GetCoordZ(ephedraCoordX, ephedraCoordY)
		local coord = vector3(ephedraCoordX, ephedraCoordY, coordZ)

		if ValidateEphedraCoord(coord) then
			return coord
		end
	end
end

function GetCoordZ(x, y)
	local groundCheckHeights = { 70.0, 71.0, 72.0, 73.0, 74.0, 75.0, 76.0, 77.0, 78.0, 79.0, 80.0, 81.0, 82.0, 83.0, 84.0, 85.0, 86.0, 87.0, 88.0, 89.0, 90.0, 91.0, 92.0, 93.0, 94.0, 95.0, 96.0, 97.0, 98.0, 99.0, 100.0, 101.0, 102.0, 103.0, 104.0, 105.0, 106.0, 107.0, 108.0, 109.0, 110.0 }

	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

		if foundGround then
			return z
		end
	end

	return 95.0
end