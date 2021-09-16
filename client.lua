local DebugCommands = true

playerData = nil
HandCuffed = false
HandCuff = nil
HandcuffBack = false
HandcuffFront = false

function GetClosestPlayer()
    local players = GetPlayers()
    local closetD = -1
    local closetP = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply)
	--
    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords['x'], targetCoords['y'], targetCoords['z'], plyCoords['x'], plyCoords['y'], plyCoords['z'], true)
			--print(target)
            if 1 > distance then
				closetP = value
				closetD = distance
				break
            end
        end
    end
	--
    return closetP, closetD
end

function GetPlayers()
    local players = {}
    
    for _, player in ipairs(GetActivePlayers()) do
        table.insert(players, player)
    end
    --
    return players
end

-------------- DEBUG COMMANDS --------------
if DebugCommands then
	--
	RegisterCommand("zip-back", function(source, args)
		TriggerEvent("handcuff:c:checkNearbyToBack", source)
	end)

	RegisterCommand("zip-front", function(source, args)
		TriggerEvent("handcuff:c:checkNearbyToFront", source)
	end)

	RegisterCommand("unzip", function(source, args)
		TriggerEvent("handcuff:c:checkNearbyToFree", source)
	end)
	--
end
--------------------------------------------

RegisterNetEvent('jamie:anim')
AddEventHandler('jamie:anim', function()
	local playerPed = PlayerPedId()

	while not HasAnimDictLoaded('mp_arresting') do
		Citizen.Wait(100)
	end

	TaskPlayAnim(playerPed, 'mp_arresting', 'a_uncuff', 8.0, -8, 3000, 49, 0, 0, 0, 0)
	Citizen.Wait(3000)
end)



-------------- Checking Players --------------
RegisterNetEvent('handcuff:c:checkNearbyToBack')
AddEventHandler('handcuff:c:checkNearbyToBack', function()
	local closetP, closetD = GetClosestPlayer()
	if closetP == -1 or closetD > 1.0 then
		print("There's no one nearby")
	else
		TriggerServerEvent("handcuff:s:back", GetPlayerServerId(closetP))
		TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 4.5, 'ziptie', 1.0)
	end
end)


RegisterNetEvent('handcuff:c:checkNearbyToFront')
AddEventHandler('handcuff:c:checkNearbyToFront', function()
	local closetP, closetD = GetClosestPlayer()
	if closetP == -1 or closetD > 1.0 then
		print("There's no one nearby")
	else
		TriggerServerEvent("handcuff:s:front", GetPlayerServerId(closetP))
		TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 4.5, 'ziptie', 1.0)
	end
end)


RegisterNetEvent('handcuff:c:checkNearbyToFree')
AddEventHandler('handcuff:c:checkNearbyToFree', function()
	local closetP, closetD = GetClosestPlayer()
	if closetP == -1 or closetD > 1.0 then
		print("There's no one nearby
				")
	else
		TriggerServerEvent("handcuff:s:free", GetPlayerServerId(closetP))
		TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 4.5, 'ziptie', 1.0)
	end
end)
----------------------------------------------






------- Animations -------

RegisterNetEvent('handcuff:c:back')
AddEventHandler('handcuff:c:back', function()
	local playerPed = PlayerPedId()
	if not HandCuffed then
		local getCoord = GetEntityCoords(playerPed)
		RequestAnimDict("mp_arresting")
		while not HasAnimDictLoaded("mp_arresting") do
			Citizen.Wait(100)
		end
		TaskPlayAnim(playerPed, "mp_arresting", "idle",8.0,-8,-1,49,0,0,0,0)
		
		if HandCuff ~= nil then
			DetachEntity(HandCuff, true, true)
			DeleteEntity(HandCuff)
		end
		
		SetEnableHandcuffs(playerPed, true)
		DisablePlayerFiring(playerPed, true)
		SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
		SetPedCanPlayGestureAnims(playerPed, false)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(false)
		HandCuffed = true
		HandCuff = CreateObject(GetHashKey("hei_prop_zip_tie_positioned"), getCoord.x, getCoord.y, getCoord.z, true, true, true)
		local net = ObjToNet(HandCuff)
		SetNetworkIdExistsOnAllMachines(net, true)
		SetNetworkIdCanMigrate(net, true)
		NetworkSetNetworkIdDynamic(net, true)
		AttachEntityToEntity(HandCuff, playerPed, GetPedBoneIndex(playerPed, 60309), -0.020, 0.035, 0.06, 0.04, 155.0, 80.0, true, false, false, false, 0, true)
		HandcuffBack = true
		HandcuffFront = false
	end
end)

RegisterNetEvent('handcuff:c:free')
AddEventHandler('handcuff:c:free', function()
	local playerPed = PlayerPedId()
	if HandCuffed then
		HandCuffed = false
		
		DetachEntity(HandCuff, true, true)
		DeleteEntity(HandCuff)
		HandcuffBack = false
		HandcuffFront = false
		
		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(true)
	end
end)

RegisterNetEvent('handcuff:c:front')
AddEventHandler('handcuff:c:front', function()
	local playerPed = PlayerPedId()
	if not HandCuffed then
		local getCoord = GetEntityCoords(GetPlayerPed(PlayerId()), false)
		RequestAnimDict("anim@move_m@prisoner_cuffed")
		while not HasAnimDictLoaded("anim@move_m@prisoner_cuffed") do
			Citizen.Wait(100)
		end
		TaskPlayAnim(playerPed, "anim@move_m@prisoner_cuffed", "idle",8.0,-8,-1,49,0,0,0,0)
		
		if HandCuff ~= nil then
			DetachEntity(HandCuff, true, true)
			DeleteEntity(HandCuff)
		end
		
		SetEnableHandcuffs(playerPed, true)
		DisablePlayerFiring(playerPed, true)
		SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
		SetPedCanPlayGestureAnims(playerPed, false)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(false)
		HandCuffed = true
		HandCuff = CreateObject(GetHashKey("hei_prop_zip_tie_positioned"), getCoord.x, getCoord.y, getCoord.z, true, true, true)
		local net = ObjToNet(HandCuff)
		SetNetworkIdExistsOnAllMachines(net, true)
		SetNetworkIdCanMigrate(net, true)
		NetworkSetNetworkIdDynamic(net, true)
		AttachEntityToEntity(HandCuff, GetPlayerPed(PlayerId()), GetPedBoneIndex(GetPlayerPed(PlayerId()), 60309), -0.015, 0.0, 0.08, 340.0, 95.0, 120.0, true, false, false, false, 0, true)
		HandcuffBack = false
		HandcuffFront = true
	end
end)

----------------------------

---- Event Blocker ----

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()

		if HandCuffed then
			--DisableControlAction(0, 1, true) -- Disable pan
			--DisableControlAction(0, 2, true) -- Disable tilt
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			--DisableControlAction(0, 32, true) -- W
			--DisableControlAction(0, 34, true) -- A
			--DisableControlAction(0, 31, true) -- S
			--DisableControlAction(0, 30, true) -- D

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?

			DisableControlAction(0, 288,  true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job

			--DisableControlAction(0, 0, true) -- Disable changing view
			--DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			--DisableControlAction(2, 199, true) -- Disable pause screen

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
			
			if IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) ~= 1 and HandcuffBack then
				RequestAnimDict('mp_arresting')
				TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
			end
			if IsEntityPlayingAnim(playerPed, 'anim@move_m@prisoner_cuffed', 'idle', 3) ~= 1 and HandcuffFront then
				RequestAnimDict('anim@move_m@prisoner_cuffed')
				TaskPlayAnim(playerPed, 'anim@move_m@prisoner_cuffed', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
			end
		else
			Citizen.Wait(500)
		end
	end
end)

AddEventHandler('onClientResourceStop', function (resourceName)
	if GetCurrentResourceName() == resourceName then
		print("Restart")
		if HandCuffed then
			DetachEntity(HandCuff, true, true)
			DeleteEntity(HandCuff)
			ClearPedTasksImmediately(PlayerPedId())
			print("Restart")
		end
	end
end)
