ESX = nil
QBcore = nil
local PlayerJob = nil
local inWar = false

CreateThread(function()
    if Config.UseESX then
        ESX = exports["es_extended"]:getSharedObject()
	    while not ESX.IsPlayerLoaded() do
            Wait(100)
        end

        CreateThread(function()
            while true do
                local playerData = ESX.GetPlayerData()
                if playerData.job.name ~= nil then
                    PlayerJob = playerData.job.name
                    break
                end
                Wait(100)
            end
        end)

        RegisterNetEvent('esx:setJob', function(job)
            PlayerJob = job.name
        end)

    elseif Config.UseQBCore then
        QBCore = exports['qb-core']:GetCoreObject()
        
        CreateThread(function ()
			while true do
                local playerData = QBCore.Functions.GetPlayerData()
				if playerData.citizenid ~= nil then
					PlayerJob = playerData.job.name
					if Config.QBCoreUseGangs and playerData.gang.name ~= 'none' then
						PlayerJob = playerData.gang.name
					end
					break
				end
				Wait(100)
			end
		end)

        RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
            local playerData = QBCore.Functions.GetPlayerData()
			PlayerJob = playerData.job.name
			if Config.QBCoreUseGangs and playerData.gang.name ~= 'none' then
            	PlayerJob = playerData.gang.name
			end
        end)
    end
end)

RegisterNetEvent('angelicxs-zoneWar:Notify', function(message, type, warStop)
	if Config.UseCustomNotify then
        TriggerEvent('angelicxs-zoneWar:CustomNotify',message, type)
	elseif Config.UseESX then
		ESX.ShowNotification(message)
	elseif Config.UseQBCore then
		QBCore.Functions.Notify(message, type)
	end
    if warStop then inWar = false end
end)

RegisterCommand(Config.StartWarCommand, function()
    if not Config.WarPassword then
        LocationSelector()
    else
        local PlayerInput = false
        if Config.QBInput then
            local password = exports['qb-input']:ShowInput({
                header = Config.Lang['password_zonewar'],
                submitText = Config.Lang['request_password'],
                inputs = {
                    {
                        type = 'text',
                        isRequired = false,
                        name = 'input',
                        text = Config.Lang['request_password'],
                    }
                }
            })    
            if password then
                PlayerInput = tostring(password.input)
            end
        elseif Config.OXLib then
            local input = lib.inputDialog(Config.Lang['password_zonewar'], {Config.Lang['request_password']})
            if input then
                PlayerInput = tostring(input[1])
            end
        end
        if PlayerInput == Config.WarPassword then
            LocationSelector()
        else
            TriggerEvent('angelicxs-zoneWar:Notify', Config.Lang['wrong_password'], Config.LangType['error'])
        end
    end
end)
TriggerEvent("chat:removeSuggestion", Config.StartWarCommand)

function LocationSelector()
    local menu = {}
    for i = 1, #Config.ZoneWarAreas do
        if Config.QBMenu then
            table.insert(menu, {
                header = Config.ZoneWarAreas[i]["ZoneName"],
                    params = {
                        event = 'angelicxs-zoneWar:TeamInputs',
                        args = Config.ZoneWarAreas[i]
                    }
                })
        elseif Config.OXLib then
            table.insert(menu, {
                title = Config.ZoneWarAreas[i]["ZoneName"],
                onSelect = function()
                    TriggerEvent("angelicxs-zoneWar:TeamInputs", Config.ZoneWarAreas[i])
                end,
            })
        end

    end
    if Config.QBMenu then
        table.insert(menu, {
        header = Config.Lang['cancel'],
            params = {event = ''}
        })
        TriggerEvent("qb-menu:client:openMenu", menu)
    elseif Config.OXLib then
        lib.registerContext({
            id = 'AngelicZoneWarmenu_ox',
            title = Config.Lang['menu_header'],
            options = menu,
            position = 'top-right',
        }, function(selected, scrollIndex, args)
        end)
        lib.showContext('AngelicZoneWarmenu_ox')
    end

end

RegisterNetEvent('angelicxs-zoneWar:TeamInputs', function(zoneData)
    if not zoneData.ZoneName then return end
    local team1 = false
    local team2 = false
    if Config.QBInput then
        local teaminput = exports['qb-input']:ShowInput({
            header = Config.Lang['team_input'],
            submitText = Config.Lang['submit'],
            inputs = {
                {
                    type = 'text',
                    isRequired = false,
                    name = 'team1',
                    text = Config.Lang['team_entry'],
                },
                {
                    type = 'text',
                    isRequired = false,
                    name = 'team2',
                    text = Config.Lang['team_entry'],
                }
            }
        })    
        if teaminput then
            team1 = tostring(teaminput.team1)
            team2 = tostring(teaminput.team2)
        end
    elseif Config.OXLib then
        local input = lib.inputDialog(Config.Lang['team_input'], {Config.Lang['team_entry'], Config.Lang['team_entry']})
        if input then
            team1 = tostring(input[1])
            team2 = tostring(input[2])
        end
    end
    if team1 and team2 then
        TriggerServerEvent('angelicxs-zoneWar:Server:TeamSetUp', team1, team2, zoneData)
    else
        TriggerEvent('angelicxs-zoneWar:Notify', Config.Lang['missing_team'], Config.LangType['error'])
    end
end)

RegisterNetEvent('angelicxs-zoneWar:Client:TeamSetUp', function(zoneWarData, spawn, bucket, capZone)
    if not zoneWarData.ZoneName then return end
    inWar = true
    SetEntityCoords(PlayerPedId(), spawn.x, spawn.y, spawn.z)
    TriggerServerEvent('angelicxs-zoneWar:Server:BucketMover', bucket)
    TriggerEvent('angelicxs-zoneWar:Notify', Config.Lang['war_start'], Config.LangType['info'])
    local spamProtection = false
    local blip = false
    if Config.AddMapBlip then
        blip = AddBlipForCoord(capZone.x, capZone.y, capZone.z)
        SetBlipSprite(blip, Config.StartBlipIcon)
        SetBlipColour(blip, Config.StartBlipColour)
        SetBlipScale(blip, 1.5)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(zoneWarData.ZoneName)
        EndTextCommandSetBlipName(blip)
    end
    CreateThread(function()
        if Config.AutomaticRevive then
            while inWar do
                local hp = GetEntityHealth(PlayerPedId())
                if hp <= 1 then
                    Wait(5000)
                    TriggerEvent('angelicxs-zoneWar:Notify', Config.Lang['respawn_notice'], Config.LangType['info'])
                    Wait(Config.ReviveTimer*1000)
                    SetEntityCoords(PlayerPedId(), spawn.x, spawn.y, spawn.z)
                    TriggerEvent('hospital:client:Revive')
                end
                Wait(1000)
                if not inWar then break end 
            end
        end
    end)
    while inWar do
        local sleep = 2000
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - capZone)
        if distance <= 20.0 then
            DrawMarker(2, capZone.x, capZone.y, (capZone.z+2), 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 2.0, 2.0, 2.0, 100, 200, 50, 255, true, true, 2, 0.0, false, false, false)
            sleep = 0
            if distance <= 5.0 then
                DrawText3Ds(capZone.x, capZone.y, capZone.z, Config.Lang['capture_name'])
                if distance <= 1.5 and IsControlJustReleased(0, 38) and not spamProtection then
                    CreateThread(function()
                        spamProtection = true
                        Wait(5000)
                        spamProtection = false
                    end)
                    TriggerServerEvent('angelicxs-zoneWar:Server:ControlUpdate', PlayerJob)
                end
            end
        end
        Wait(sleep)
        if not inWar then break end
    end
    if blip then
        RemoveBlip(blip)
    end
end)


function DrawText3Ds(x,y,z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	SetTextScale(0.30, 0.30)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry('STRING')
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	local factor = (string.len(text)) / 370
	DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

AddEventHandler('onResourceStop', function(resource)
	if GetCurrentResourceName() == resource then
        inWar = false
	end
end)


