ESX = nil
local menuOpen = false
local wasOpen = false
local count = 0

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(100)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if menuOpen then
            ESX.UI.Menu.CloseAll()
        end
    end
end)

function CreateBlipCircle(coords, text, radius, color, sprite)
    local blip = AddBlipForRadius(coords, radius)

    SetBlipHighDetail(blip, true)
    SetBlipColour(blip, 1)
    SetBlipAlpha (blip, 128)
    SetBlipAsShortRange(blip, true)

    -- create a blip in the middle
    blip = AddBlipForCoord(coords)

    SetBlipHighDetail(blip, true)
    SetBlipSprite (blip, sprite)
    SetBlipScale  (blip, 1.0)
    SetBlipColour (blip, color)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
end

Citizen.CreateThread(function()
    while true do

        Citizen.Wait(0)

        if Config.ShowMarkers then

            local coords = GetEntityCoords(GetPlayerPed(-1))

            for k,v in pairs(Config.DumpZones) do
                if GetDistanceBetweenCoords(coords, v.coords, true) < Config.DrawDistance then
                    DrawMarker(Config.MarkerType, v.coords, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
                end
            end
			
			for k,v in pairs(Config.FieldZones) do
                if GetDistanceBetweenCoords(coords, v.coords, true) < Config.DrawDistance then
                    DrawMarker(Config.MarkerType, v.coords, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
                end
            end

            for k,v in pairs(Config.ProcessZones) do
                if GetDistanceBetweenCoords(coords, v.coords, true) < Config.DrawDistance then
                    DrawMarker(Config.MarkerType, v.coords, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()

    if Config.ShowBlips then
        for k,v in pairs(Config.DumpZones) do
            CreateBlipCircle(v.coords, v.name, v.radius, v.color, v.sprite)
        end
		
		for k,v in pairs(Config.FieldZones) do
            CreateBlipCircle(v.coords, v.name, v.radius, v.color, v.sprite)
        end

        for k,v in pairs(Config.ProcessZones) do
            CreateBlipCircle(v.coords, v.name, v.radius, v.color, v.sprite)
        end
    end
end)

Citizen.CreateThread(function()
    for k,v in pairs(Config.Peds) do
        RequestModel(v.ped)
        while not HasModelLoaded(v.ped) do
            Wait(1)
        end

        -- If the zone is for a dealer, render a PED
        local seller = CreatePed(1, v.ped, v.x, v.y, v.z, v.h, false, true)
        SetBlockingOfNonTemporaryEvents(seller, true)
        SetPedDiesWhenInjured(seller, false)
        SetPedCanPlayAmbientAnims(seller, true)
        SetPedCanRagdollFromPlayerImpact(seller, false)
        SetEntityInvincible(seller, true)
        FreezeEntityPosition(seller, true)
        TaskStartScenarioInPlace(seller, "WORLD_HUMAN_CLIPBOARD", 0, true)
    end
end)

RegisterNetEvent('esx_jk_drugs:useItem')
AddEventHandler('esx_jk_drugs:useItem', function(itemName)
    ESX.UI.Menu.CloseAll()

    if itemName == 'marijuana' then
        local lib, anim = 'amb@world_human_smoking_pot@male@base', 'base'
        local playerPed = PlayerPedId()

        ESX.ShowNotification(_U('weed_use'))
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_jk_drugs:onPot')
        end)

    elseif itemName == 'cocaine' then
        local lib, anim = 'anim@mp_player_intcelebrationmale@face_palm', 'face_palm' -- TODO better animations
        local playerPed = PlayerPedId()

        ESX.ShowNotification(_U('cocaine_use'))
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_jk_drugs:cokedOut')
        end)

    elseif itemName == 'meth' then
        local lib, anim = 'mp_weapons_deal_sting', 'crackhead_bag_loop' -- TODO better animations
        local playerPed = PlayerPedId()

        ESX.ShowNotification(_U('meth_use'))
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_jk_drugs:icedOut')
        end)

    elseif itemName == 'crack' then
        local lib, anim = 'mp_weapons_deal_sting', 'crackhead_bag_loop' -- TODO better animations
        local playerPed = PlayerPedId()

        ESX.ShowNotification(_U('crack_use'))
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_jk_drugs:crackedOut')
        end)

    elseif itemName == 'heroine' then
        local lib, anim = 'rcmpaparazzo1ig_4', 'miranda_shooting_up' -- TODO better animations
        local playerPed = PlayerPedId()

        ESX.ShowNotification(_U('heroine_use'))
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, 10000, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_jk_drugs:noddinOut')
        end)

    elseif itemName == 'drugtest' then
        local lib, anim = 'misscarsteal2peeing', 'peeing_intro'
        local playerPed = PlayerPedId()

        ESX.ShowNotification(_U('drug_test'))
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_jk_drugs:testing')
        end)

    elseif itemName == 'fakepee' then

        ESX.ShowNotification(_U('fake_pee'))
        TriggerEvent('esx_jk_drugs:fakePee')

    elseif itemName == 'beer' then
        local lib, anim = 'amb@world_human_drinking@beer@male@idle_a', 'idle_a'
        local playerPed = PlayerPedId()

        ESX.ShowNotification(_U('beer'))
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, 5000, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_jk_drugs:buzzin')
        end)

    elseif itemName == 'tequila' then
        local lib, anim = 'amb@world_human_drinking@beer@male@idle_a', 'idle_a'
        local playerPed = PlayerPedId()

        ESX.ShowNotification(_U('tequila'))
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, 5000, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_jk_drugs:drunk')
        end)

    elseif itemName == 'vodka' then
        local lib, anim = 'amb@world_human_drinking@beer@male@idle_a', 'idle_a'
        local playerPed = PlayerPedId()

        ESX.ShowNotification(_U('vodka'))
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, 5000, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_jk_drugs:drunk')
        end)
    elseif itemName == 'whiskey' then
        local lib, anim = 'amb@world_human_drinking@beer@male@idle_a', 'idle_a'
        local playerPed = PlayerPedId()

        ESX.ShowNotification(_U('whiskey'))
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, 5000, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_jk_drugs:drunk')
        end)
    elseif itemName == 'breathalyzer' then

        ESX.ShowNotification(_U('forced'))
        TriggerEvent('esx_jk_drugs:breathalyzer')
    end
end)

RegisterNetEvent('esx_jk_drugs:onPot')
AddEventHandler('esx_jk_drugs:onPot', function()
    RequestAnimSet("MOVE_M@DRUNK@SLIGHTLYDRUNK")
    while not HasAnimSetLoaded("MOVE_M@DRUNK@SLIGHTLYDRUNK") do
        Citizen.Wait(0)
    end
    onDrugs = true
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    SetTimecycleModifier("spectator5")
    SetPedMotionBlur(GetPlayerPed(-1), true)
    SetPedMovementClipset(GetPlayerPed(-1), "MOVE_M@DRUNK@SLIGHTLYDRUNK", true)
    SetPedIsDrunk(GetPlayerPed(-1), true)
    DoScreenFadeIn(1000)
    Citizen.Wait(600000)
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    ClearTimecycleModifier()
    ResetScenarioTypesEnabled()
    ResetPedMovementClipset(GetPlayerPed(-1), 0)
    SetPedIsDrunk(GetPlayerPed(-1), false)
    SetPedMotionBlur(GetPlayerPed(-1), false)
    ESX.ShowNotification(_U('comin_down'))
    onDrugs = false

end)

RegisterNetEvent('esx_jk_drugs:cokedOut')
AddEventHandler('esx_jk_drugs:cokedOut', function()
    RequestAnimSet("move_m@hurry_butch@a")
    while not HasAnimSetLoaded("move_m@hurry_butch@a") do
        Citizen.Wait(0)
    end
    onDrugs = true
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    SetPedMotionBlur(GetPlayerPed(-1), true)
    SetPedMovementClipset(GetPlayerPed(-1), "move_m@hurry_butch@a", true)
    SetPedRandomProps(GetPlayerPed(-1), true)
    SetRunSprintMultiplierForPlayer(GetPlayerPed(-1), 2.5)
    DoScreenFadeIn(1000)
    Citizen.Wait(300000)
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    ClearTimecycleModifier()
    ResetPedMovementClipset(GetPlayerPed(-1), 0)
    SetPedRandomProps(GetPlayerPed(-1), false)
    ClearAllPedProps(GetPlayerPed(-1), true)
    SetRunSprintMultiplierForPlayer(GetPlayerPed(-1), 1.0)
    SetPedMotionBlur(GetPlayerPed(-1), false)
    ESX.ShowNotification(_U('comin_down'))
    onDrugs = false

end)

RegisterNetEvent('esx_jk_drugs:icedOut')
AddEventHandler('esx_jk_drugs:icedOut', function()
    RequestAnimSet("move_m@hurry_butch@b")
    while not HasAnimSetLoaded("move_m@hurry_butch@b") do
        Citizen.Wait(0)
    end
    onDrugs = true
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    SetPedMotionBlur(GetPlayerPed(-1), true)
    SetPedMovementClipset(GetPlayerPed(-1), "move_m@hurry_butch@b", true)
    DoScreenFadeIn(1000)
	repeat
		TaskJump(GetPlayerPed(-1), false, true, false)
		Citizen.Wait(60000)
		count = count  + 1
	until count == 5
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    ClearTimecycleModifier()
    ResetPedMovementClipset(GetPlayerPed(-1), 0)
    ClearAllPedProps(GetPlayerPed(-1), true)
    SetPedMotionBlur(GetPlayerPed(-1), false)
    ESX.ShowNotification(_U('comin_down'))
    onDrugs = false

end)

RegisterNetEvent('esx_jk_drugs:noddinOut')
AddEventHandler('esx_jk_drugs:noddinOut', function()
    RequestAnimSet("move_m@hurry_butch@c")
    while not HasAnimSetLoaded("move_m@hurry_butch@c") do
        Citizen.Wait(0)
    end
    onDrugs = true
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    SetPedMotionBlur(GetPlayerPed(-1), true)
    SetPedMovementClipset(GetPlayerPed(-1), "move_m@hurry_butch@c", true)
    DoScreenFadeIn(1000)
    repeat
		DoScreenFadeOut(1000)
		SetPedToRagdoll(GetPlayerPed(-1), 5000, 0, 0, false, false, false)
		Citizen.Wait(5000)
		DoScreenFadeIn(1000)
		count = count + 1
	until count == 5
    ClearTimecycleModifier()
    ResetPedMovementClipset(GetPlayerPed(-1), 0)
    SetPedMotionBlur(GetPlayerPed(-1), false)
    ESX.ShowNotification(_U('comin_down'))
    onDrugs = false

end)

RegisterNetEvent('esx_jk_drugs:buzzin')
AddEventHandler('esx_jk_drugs:buzzin', function()
    RequestAnimSet("move_m@buzzed")
    while not HasAnimSetLoaded("move_m@buzzed") do
        Citizen.Wait(0)
    end
    onBeer = true
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    SetPedMotionBlur(GetPlayerPed(-1), true)
    SetPedMovementClipset(GetPlayerPed(-1), "move_m@buzzed", true)
    DoScreenFadeIn(1000)
    Citizen.Wait(150000)
    ClearTimecycleModifier()
    ResetPedMovementClipset(GetPlayerPed(-1), 0)
    SetPedMotionBlur(GetPlayerPed(-1), false)
    ESX.ShowNotification(_U('wearin_off'))
    onBeer = false

end)

RegisterNetEvent('esx_jk_drugs:drunk')
AddEventHandler('esx_jk_drugs:drunk', function()
    RequestAnimSet("move_m@drunk@moderatedrunk")
    while not HasAnimSetLoaded("move_m@drunk@moderatedrunk") do
        Citizen.Wait(0)
    end
    onLiquor = true
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    SetPedMotionBlur(GetPlayerPed(-1), true)
    SetPedMovementClipset(GetPlayerPed(-1), "move_m@drunk@moderatedrunk", true)
    SetPedIsDrunk(GetPlayerPed(-1), true)
    DoScreenFadeIn(1000)
    Citizen.Wait(600000)
    ClearTimecycleModifier()
    ResetPedMovementClipset(GetPlayerPed(-1), 0)
    SetPedMotionBlur(GetPlayerPed(-1), false)
    SetPedIsDrunk(GetPlayerPed(-1), false)
    ESX.ShowNotification(_U('wearin_off'))
    onLiquor = false

end)

RegisterNetEvent('esx_jk_drugs:testing')
AddEventHandler('esx_jk_drugs:testing', function()
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    if onDrugs then
        ESX.ShowNotification(_U('drug_fail'))
        TriggerServerEvent('esx_jk_drugs:testResultsFail')
    else
        ESX.ShowNotification(_U('drug_pass'))
        TriggerServerEvent('esx_jk_drugs:testResultsPass')
    end
end)

RegisterNetEvent('esx_jk_drugs:fakePee')
AddEventHandler('esx_jk_drugs:fakePee', function()
    local wasDrugged = false
    if onDrugs then
        ESX.ShowNotification(_U('fake_clean'))
        wasDrugged = true
        onDrugs = false
    else
        ESX.ShowNotification(_U('not_needed'))
    end
    Citizen.Wait(60000)
    if wasDrugged then
        onDrugs = true
    end
end)

RegisterNetEvent('esx_jk_drugs:breathalyzer')
AddEventHandler('esx_jk_drugs:breathalyzer', function()

    if onBeer then
        ESX.ShowNotification(_U('fail_tipsy'))
        TriggerServerEvent('esx_jk_drugs:testResultsFailTipsy')
    elseif onLiquor then
        ESX.ShowNotification(_U('fail_drunk'))
        TriggerServerEvent('esx_jk_drugs:testResultsFailDrunk')
    else
        ESX.ShowNotification(_U('bca_pass'))
        TriggerServerEvent('esx_jk_drugs:testResultsPassBCA')
    end
end)

RegisterNetEvent('esx_jk_drugs:crackedOut')
AddEventHandler('esx_jk_drugs:crackedOut', function()
    RequestAnimSet("move_m@hurry_butch@a")
    while not HasAnimSetLoaded("move_m@hurry_butch@a") do
        Citizen.Wait(0)
    end
    onDrugs = true
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    SetPedMotionBlur(GetPlayerPed(-1), true)
    SetPedMovementClipset(GetPlayerPed(-1), "move_m@hurry_butch@a", true)
    SetPedRandomProps(GetPlayerPed(-1), true)
    SetRunSprintMultiplierForPlayer(GetPlayerPed(-1), 1.49)
    DoScreenFadeIn(1000)
   repeat
		TaskJump(GetPlayerPed(-1), false, true, false)
		Citizen.Wait(60000)
		count = count  + 1
	until count == 5
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    ClearTimecycleModifier()
    ResetPedMovementClipset(GetPlayerPed(-1), 0)
    SetPedRandomProps(GetPlayerPed(-1), false)
    ClearAllPedProps(GetPlayerPed(-1), true)
    SetRunSprintMultiplierForPlayer(GetPlayerPed(-1), 1.0)
    SetPedMotionBlur(GetPlayerPed(-1), false)
    ESX.ShowNotification(_U('comin_down'))
    onDrugs = false

end)

RegisterNetEvent('esx_jk_drugs:selling')
AddEventHandler('esx_jk_drugs:selling', function()

    local playerPed = PlayerPedId()
    PedPosition        = GetEntityCoords(playerPed)
    local PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z }
    
    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
    local plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
    local streetName, crossing = Citizen.InvokeNative( 0x2EB41072B4C1E4C0, plyPos.x, plyPos.y, plyPos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt() )
    local streetName, crossing = GetStreetNameAtCoord(x, y, z)
    streetName = GetStreetNameFromHashKey(streetName)
    crossing = GetStreetNameFromHashKey(crossing)
	
	if Config.UseESXPhone then
        if crossing ~= nil then

            local coords      = GetEntityCoords(GetPlayerPed(-1))

            TriggerServerEvent('esx_phone:send', "police", "Some shady prick is selling drugs on " .. streetName .. " and " .. crossing, true, {
                x = coords.x,
                y = coords.y,
                z = coords.z
            })
        else
            TriggerServerEvent('esx_phone:send', "police", "Some shady prick is selling drugs on " .. streetName, true, {
                x = coords.x,
                y = coords.y,
                z = coords.z
            })
        end
    elseif Config.UseGCPhone then
        if crossing ~= nil then
            local coords      = GetEntityCoords(GetPlayerPed(-1))

            TriggerServerEvent('esx_addons_gcphone:startCall', 'police', "Some shady prick is selling drugs on " .. streetName .. " and " .. crossing, PlayerCoords, {
                PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z },
            })
        else
            TriggerServerEvent('esx_addons_gcphone:startCall', "police", "Some shady prick is selling drugs on " .. streetName, PlayerCoords, {
                PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z },
            })
        end
    else
		TriggerServerEvent('esx_jk_drugs:policeAlert')
	end
end)

RegisterNetEvent('esx_jk_drugs:restricted')
AddEventHandler('esx_jk_drugs:restricted', function()

    local playerPed = PlayerPedId()
    PedPosition        = GetEntityCoords(playerPed)
    local PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z }
    
    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
    local plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
    local streetName, crossing = Citizen.InvokeNative( 0x2EB41072B4C1E4C0, plyPos.x, plyPos.y, plyPos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt() )
    local streetName, crossing = GetStreetNameAtCoord(x, y, z)
    streetName = GetStreetNameFromHashKey(streetName)
    crossing = GetStreetNameFromHashKey(crossing)
	
	if Config.UseESXPhone then
        if crossing ~= nil then

            local coords      = GetEntityCoords(GetPlayerPed(-1))

            TriggerServerEvent('esx_phone:send', "police", "Someone entered a Restricted Area at " .. streetName .. " and " .. crossing, true, {
                x = coords.x,
                y = coords.y,
                z = coords.z
            })
        else
            TriggerServerEvent('esx_phone:send', "police", "Someone entered a Restricted Area at " .. streetName, true, {
                x = coords.x,
                y = coords.y,
                z = coords.z
            })
        end
    elseif Config.UseGCPhone then
        if crossing ~= nil then
            local coords      = GetEntityCoords(GetPlayerPed(-1))

            TriggerServerEvent('esx_addons_gcphone:startCall', 'police', "Someone entered a Restricted Area at " .. streetName .. " and " .. crossing, PlayerCoords, {
                PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z },
            })
        else
            TriggerServerEvent('esx_addons_gcphone:startCall', "police", "Someone entered a Restricted Area at " .. streetName, PlayerCoords, {
                PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z },
            })
        end
    else
		TriggerServerEvent('esx_jk_drugs:restrictedArea')
	end
end)

-- Give Cops access to test kits

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)	
        if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'police' then
        
            local coords = GetEntityCoords(GetPlayerPed(-1))

            if GetDistanceBetweenCoords(coords, 461.6, -979.56, 30.69, true) < 15 then
                DrawMarker(21, 461.6, -979.56, 30.69, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 0.5, 50, 50, 204, 100, true, true, 2, false, false, false, false)
            end
        
            if GetDistanceBetweenCoords(coords, 461.6, -979.56, 30.69, true) < 1 then
                ESX.ShowNotification("You grabbed some test kits")
                TriggerServerEvent('esx_jk_drugs:giveItem', 'drugtest')
                TriggerServerEvent('esx_jk_drugs:giveItem', 'breathalyzer')
                Citizen.Wait(10000)
            end
        end
    end
end)