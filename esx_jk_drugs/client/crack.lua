local isProcessing = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		local loaded = false
		

		if GetDistanceBetweenCoords(coords, Config.ProcessZones.CrackProcessing.coords, true) < 15 and GetDistanceBetweenCoords(coords, Config.ProcessZones.CrackProcessing.coords, true) > 10 then
			ESX.ShowNotification("The Lost aren\'t too friendly when it comes to sharing drugs")
		end
		if GetDistanceBetweenCoords(coords, Config.ProcessZones.CrackProcessing.coords, true) < 1.5 then
			ProcessCoke()
			Citizen.Wait(500)
		end
	end
end)

function ProcessCoke()
	isProcessing = true

	TriggerServerEvent('esx_drugs:processCoke')
	local timeLeft = Config.Delays.CrackProcessing / 1000
	local playerPed = PlayerPedId()

	while timeLeft > 0 do
		Citizen.Wait(1000)
		timeLeft = timeLeft - 1

		if GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.ProcessZones.CrackProcessing.coords, false) > 4 then
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

		if GetDistanceBetweenCoords(coords, Config.DumpZones.CrackDump.coords, true) < 1 then
			if not menuOpen5 then
				ESX.ShowHelpNotification("Press [E] to to load off on Jerome")

				if IsControlJustReleased(0, Keys['E']) then
					wasOpen5 = true
					OpenCrackDump()
					if Config.EnableCops then
						TriggerServerEvent('esx_drugs:selling')
					end
				end
			else
				Citizen.Wait(500)
			end
		else
			if wasOpen5 then
				wasOpen5 = false
				ESX.UI.Menu.CloseAll()
			end

			Citizen.Wait(500)
		end
	end
end)

function OpenCrackDump()
	ESX.UI.Menu.CloseAll()
	local elements = {}
	menuOpen5 = true

	for k, v in pairs(ESX.GetPlayerData().inventory) do
		local price = Config.CrackDumpItems[v.name]

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
			TriggerServerEvent('esx_drugs:sellCrack', data.current.name, data.current.value)
			menu.close()
			menuOpen5 = false
			end, function(data, menu)
		end)

		menuOpen5 = false
	else
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'drug_shop', {
			title    = _U('dealer_title'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			TriggerServerEvent('esx_drugs:sellCrack', data.current.name, data.current.value)
		end, function(data, menu)
			menu.close()
			menuOpen5 = false
		end)

		menuOpen5 = false		
	end
end