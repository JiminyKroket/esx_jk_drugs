Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil
local menuOpen = false
local wasOpen = false

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

RegisterNetEvent('esx_drugs:useItem')
AddEventHandler('esx_drugs:useItem', function(itemName)
    ESX.UI.Menu.CloseAll()

    if itemName == 'marijuana' then
        local lib, anim = 'amb@world_human_smoking_pot@male@base', 'base'
        local playerPed = PlayerPedId()

        ESX.ShowNotification("You smoked a doobie.")
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_drugs:onPot')
        end)

    elseif itemName == 'cocaine' then
        local lib, anim = 'anim@mp_player_intcelebrationmale@face_palm', 'face_palm' -- TODO better animations
        local playerPed = PlayerPedId()

        ESX.ShowNotification("You ate a pile of coke!")
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_drugs:cokedOut')
        end)

    elseif itemName == 'meth' then
        local lib, anim = 'mp_weapons_deal_sting', 'crackhead_bag_loop' -- TODO better animations
        local playerPed = PlayerPedId()

        ESX.ShowNotification("You dropped some ice trying to smoke!")
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_drugs:icedOut')
        end)

    elseif itemName == 'crack' then
        local lib, anim = 'mp_weapons_deal_sting', 'crackhead_bag_loop' -- TODO better animations
        local playerPed = PlayerPedId()

        ESX.ShowNotification("Probably wouldn\'t drop your crack if you didn\'t smoke it")
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_drugs:crackedOut')
        end)

    elseif itemName == 'heroine' then
        local lib, anim = 'rcmpaparazzo1ig_4', 'miranda_shooting_up' -- TODO better animations
        local playerPed = PlayerPedId()

        ESX.ShowNotification("You poked yourself... with a needle.")
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, 10000, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_drugs:noddinOut')
        end)

    elseif itemName == 'drugtest' then
        local lib, anim = 'misscarsteal2peeing', 'peeing_intro'
        local playerPed = PlayerPedId()

        ESX.ShowNotification("You took a drug test")
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_drugs:testing')
        end)

    elseif itemName == 'fakepee' then

        ESX.ShowNotification("You took a fake pee pill")
        TriggerEvent('esx_drugs:fakePee')

    elseif itemName == 'beer' then
        local lib, anim = 'amb@world_human_drinking@beer@male@idle_a', 'idle_a'
        local playerPed = PlayerPedId()

        ESX.ShowNotification("Why are you drinking piss water?")
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, 5000, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_drugs:buzzin')
        end)

    elseif itemName == 'tequila' then
        local lib, anim = 'amb@world_human_drinking@beer@male@idle_a', 'idle_a'
        local playerPed = PlayerPedId()

        ESX.ShowNotification("You went for some tequila tonight")
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, 5000, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_drugs:drunk')
        end)

    elseif itemName == 'vodka' then
        local lib, anim = 'amb@world_human_drinking@beer@male@idle_a', 'idle_a'
        local playerPed = PlayerPedId()

        ESX.ShowNotification("You went for some vodka tonight")
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, 5000, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_drugs:drunk')
        end)
    elseif itemName == 'whiskey' then
        local lib, anim = 'amb@world_human_drinking@beer@male@idle_a', 'idle_a'
        local playerPed = PlayerPedId()

        ESX.ShowNotification("You went for some whiskey tonight")
        ESX.Streaming.RequestAnimDict(lib, function()
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, 5000, 32, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            TriggerEvent('esx_drugs:drunk')
        end)
    elseif itemName == 'breathalyzer' then

        ESX.ShowNotification("You've been forced to take a breathalyzer")
        TriggerEvent('esx_drugs:breathalyzer')
    end
end)

RegisterNetEvent('esx_drugs:onPot')
AddEventHandler('esx_drugs:onPot', function()
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
    ESX.ShowNotification("You feel yourself come down from your high!")
    onDrugs = false

end)

RegisterNetEvent('esx_drugs:cokedOut')
AddEventHandler('esx_drugs:cokedOut', function()
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
    SetRunSprintMultiplierForPlayer(GetPlayerPed(-1), 2)
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
    ESX.ShowNotification("You feel yourself come down from your high!")
    onDrugs = false

end)

RegisterNetEvent('esx_drugs:icedOut')
AddEventHandler('esx_drugs:icedOut', function()
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
    TaskJump(GetPlayerPed(-1), false, true, false)
    Citizen.Wait(60000)
    TaskJump(GetPlayerPed(-1), false, true, false)
    Citizen.Wait(60000)
    TaskJump(GetPlayerPed(-1), false, true, false)
    Citizen.Wait(60000)
    TaskJump(GetPlayerPed(-1), false, true, false)
    Citizen.Wait(60000)
    TaskJump(GetPlayerPed(-1), false, true, false)
    Citizen.Wait(60000)
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    ClearTimecycleModifier()
    ResetPedMovementClipset(GetPlayerPed(-1), 0)
    ClearAllPedProps(GetPlayerPed(-1), true)
    SetPedMotionBlur(GetPlayerPed(-1), false)
    ESX.ShowNotification("You feel yourself come down from your high!")
    onDrugs = false

end)

RegisterNetEvent('esx_drugs:noddinOut')
AddEventHandler('esx_drugs:noddinOut', function()
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
    Citizen.Wait(60000)
    DoScreenFadeOut(1000)
    SetPedToRagdoll(GetPlayerPed(-1), 5000, 0, 0, false, false, false)
    Citizen.Wait(5000)
    DoScreenFadeIn(1000)
    Citizen.Wait(60000)
    DoScreenFadeOut(1000)
    SetPedToRagdoll(GetPlayerPed(-1), 5000, 0, 0, false, false, false)
    Citizen.Wait(5000)
    DoScreenFadeIn(1000)
    Citizen.Wait(60000)
    DoScreenFadeOut(1000)
    SetPedToRagdoll(GetPlayerPed(-1), 5000, 0, 0, false, false, false)
    Citizen.Wait(5000)
    DoScreenFadeIn(1000)
    Citizen.Wait(60000)
    DoScreenFadeOut(1000)
    SetPedToRagdoll(GetPlayerPed(-1), 5000, 0, 0, false, false, false)
    Citizen.Wait(5000)
    DoScreenFadeIn(1000)
    Citizen.Wait(60000)
    DoScreenFadeOut(1000)
    SetPedToRagdoll(GetPlayerPed(-1), 5000, 0, 0, false, false, false)
    Citizen.Wait(5000)
    DoScreenFadeIn(1000)
    ClearTimecycleModifier()
    ResetPedMovementClipset(GetPlayerPed(-1), 0)
    SetPedMotionBlur(GetPlayerPed(-1), false)
    ESX.ShowNotification("You feel yourself come down from your high!")
    onDrugs = false

end)

RegisterNetEvent('esx_drugs:buzzin')
AddEventHandler('esx_drugs:buzzin', function()
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
    ESX.ShowNotification("You're buzz is wearing off!")
    onBeer = false

end)

RegisterNetEvent('esx_drugs:drunk')
AddEventHandler('esx_drugs:drunk', function()
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
    ESX.ShowNotification("You're buzz is wearing off!")
    onLiquor = false

end)

RegisterNetEvent('esx_drugs:testing')
AddEventHandler('esx_drugs:testing', function()
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    if onDrugs then
        ESX.ShowNotification("You failed the drug test")
        TriggerServerEvent('esx_drugs:testResultsFail')
    else
        ESX.ShowNotification("You passed the drug test")
        TriggerServerEvent('esx_drugs:testResultsPass')
    end
end)

RegisterNetEvent('esx_drugs:fakePee')
AddEventHandler('esx_drugs:fakePee', function()
    local wasDrugged = false
    if onDrugs then
        ESX.ShowNotification("You'll appear clean for a minute!")
        wasDrugged = true
        onDrugs = false
    else
        ESX.ShowNotification("You shouldn't take drugs you don't need!")
    end
    Citizen.Wait(60000)
    if wasDrugged then
        onDrugs = true
    end
end)

RegisterNetEvent('esx_drugs:testingBCA')
AddEventHandler('esx_drugs:testingBCA', function()
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    if onBeer then
        ESX.ShowNotification("You failed the BCA test")
        TriggerServerEvent('esx_drugs:testResultsFailTipsy')
    elseif onLiquor then
        ESX.ShowNotification("You failed the BCA test")
        TriggerServerEvent('esx_drugs:testResultsFailDrunk')
    else
        ESX.ShowNotification("You passed the BCA test")
        TriggerServerEvent('esx_drugs:testResultspassBCA')
    end
end)

RegisterNetEvent('esx_drugs:breathalyzer')
AddEventHandler('esx_drugs:breathalyzer', function()

        if onBeer then
            ESX.ShowNotification("You failed with 0.06%")
            TriggerServerEvent('esx_drugs:testResultsFailTipsy')
        elseif onLiquor then
            ESX.ShowNotification("You failed with .16%")
            TriggerServerEvent('esx_drugs:testResultsFailDrunk')
        else
            ESX.ShowNotification("You passed with less than 0.01%")
            TriggerServerEvent('esx_drugs:testResultsPassBCA')
        end
end)

RegisterNetEvent('esx_drugs:crackedOut')
AddEventHandler('esx_drugs:crackedOut', function()
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
    TaskJump(GetPlayerPed(-1), false, true, false)
    Citizen.Wait(60000)
    TaskJump(GetPlayerPed(-1), false, true, false)
    Citizen.Wait(60000)
    TaskJump(GetPlayerPed(-1), false, true, false)
    Citizen.Wait(60000)
    TaskJump(GetPlayerPed(-1), false, true, false)
    Citizen.Wait(60000)
    TaskJump(GetPlayerPed(-1), false, true, false)
    Citizen.Wait(60000)
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    ClearTimecycleModifier()
    ResetPedMovementClipset(GetPlayerPed(-1), 0)
    SetPedRandomProps(GetPlayerPed(-1), false)
    ClearAllPedProps(GetPlayerPed(-1), true)
    SetRunSprintMultiplierForPlayer(GetPlayerPed(-1), 1.0)
    SetPedMotionBlur(GetPlayerPed(-1), false)
    ESX.ShowNotification("You feel yourself come down from your high!")
    onDrugs = false

end)

RegisterNetEvent('esx_drugs:selling')
AddEventHandler('esx_drugs:selling', function()

        local playerPed = PlayerPedId()
        PedPosition        = GetEntityCoords(playerPed)
        local PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z }
        
        local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
        local plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
        local streetName, crossing = Citizen.InvokeNative( 0x2EB41072B4C1E4C0, plyPos.x, plyPos.y, plyPos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt() )
        local streetName, crossing = GetStreetNameAtCoord(x, y, z)
        streetName = GetStreetNameFromHashKey(streetName)
        crossing = GetStreetNameFromHashKey(crossing)

        if Config.UseGCPhone ~= true then
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
        end

        if Config.UseGCPhone ~= false then
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
        end
end)
