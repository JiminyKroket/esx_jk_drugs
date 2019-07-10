local isProcessing = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if GetDistanceBetweenCoords(coords, Config.ProcessZones.MethProcessing.coords, true) < 15 then
			ESX.ShowNotification(_U('meth_process_close'))
		end
		if GetDistanceBetweenCoords(coords, Config.ProcessZones.MethProcessing.coords, true) < 1 then
			ProcessEphedrine()
			Citizen.Wait(500)
		end
	end
end)

function ProcessEphedrine()
	isProcessing = true

	TriggerServerEvent('esx_jk_drugs:processEphedrine')
	local timeLeft = Config.Delays.MethProcessing / 1000
	local playerPed = PlayerPedId()

	while timeLeft > 0 do
		Citizen.Wait(1000)
		timeLeft = timeLeft - 1

		if GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.ProcessZones.MethProcessing.coords, false) > 4 then
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

		if GetDistanceBetweenCoords(coords, Config.DumpZones.MethDump.coords, true) < 1 then
			if not menuOpen2 then
				ESX.ShowHelpNotification(_U('meth_sell'))

				if IsControlJustReleased(0, Keys['E']) then
					wasOpen2 = true
					OpenMethDump()
					if Config.EnableCops then
						TriggerServerEvent('esx_jk_drugs:selling')
					end
				end
			else
				Citizen.Wait(500)
			end
		else
			if wasOpen2 then
				wasOpen2 = false
				ESX.UI.Menu.CloseAll()
			end

			Citizen.Wait(500)
		end
	end
end)

function OpenMethDump()
	ESX.UI.Menu.CloseAll()
	local elements = {}
	menuOpen2 = true

	for k, v in pairs(ESX.GetPlayerData().inventory) do
		local price = Config.MethDumpItems[v.name]

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
			TriggerServerEvent('esx_jk_drugs:sellMeth', data.current.name, data.current.value)
			menu.close()
			menuOpen2 = false
			end, function(data, menu)
		end)

		menuOpen2 = false
	else
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'drug_shop', {
			title    = _U('dealer_title'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			TriggerServerEvent('esx_jk_drugs:sellMeth', data.current.name, data.current.value)
		end, function(data, menu)
			menu.close()
			menuOpen2 = false
		end)

		menuOpen2 = false
	end
end
