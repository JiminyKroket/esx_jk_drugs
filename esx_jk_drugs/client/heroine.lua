local isProcessing = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if GetDistanceBetweenCoords(coords, Config.ProcessZones.HeroineProcessing.coords, true) < 15 then
			ESX.ShowNotification("Trevor might have something for you to do for cash")
		end
		if GetDistanceBetweenCoords(coords, Config.ProcessZones.HeroineProcessing.coords, true) < 1 then
			ProcessHeroine()
			Citizen.Wait(500)
		end
	end
end)

function ProcessHeroine()
	isProcessing = true

	TriggerServerEvent('esx_drugs:processOpium')
	local timeLeft = Config.Delays.HeroineProcessing / 1000
	local playerPed = PlayerPedId()

	while timeLeft > 0 do
		Citizen.Wait(1000)
		timeLeft = timeLeft - 1

		if GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.ProcessZones.HeroineProcessing.coords, false) > 4 then
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

		if GetDistanceBetweenCoords(coords, Config.DumpZones.HeroineDump.coords, true) < 1 then
			if not menuOpen1 then
				ESX.ShowHelpNotification(_U('heroine_sell'))

				if IsControlJustReleased(0, Keys['E']) then
					wasOpen1 = true
					OpenHeroineDump()
					if Config.EnableCops then
						TriggerServerEvent('esx_drugs:selling')
					end
				end
			else
				Citizen.Wait(500)
			end
		else
			if wasOpen1 then
				wasOpen1 = false
				ESX.UI.Menu.CloseAll()
			end

			Citizen.Wait(500)
		end
	end
end)

function OpenHeroineDump()
	ESX.UI.Menu.CloseAll()
	local elements = {}
	menuOpen1 = true

	for k, v in pairs(ESX.GetPlayerData().inventory) do
		local price = Config.HeroineDumpItems[v.name]

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
			TriggerServerEvent('esx_drugs:sellHeroine', data.current.name, data.current.value)
			menu.close()
			menuOpen1 = false
			end, function(data, menu)
		end)

		menuOpen1 = false
	else
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'drug_shop', {
			title    = _U('dealer_title'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			TriggerServerEvent('esx_drugs:sellHeroine', data.current.name, data.current.value)
		end, function(data, menu)
			menu.close()
			menuOpen1 = false

		end)

		menuOpen1 = false
	end
end
