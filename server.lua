ESX = nil
QBcore = nil
local TimeRemaining = false
local WarBucket = {} 
local PointControl = false

if Config.UseESX then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.UseQBCore then
    QBCore = exports['qb-core']:GetCoreObject()
end

RegisterNetEvent('angelicxs-zoneWar:Server:TeamSetUp', function(team1, team2, zoneWarData)
    local bucket = math.random(1,64)
    local admin = source
    TriggerClientEvent('angelicxs-zoneWar:Client:TeamSetUp', admin, zoneWarData, zoneWarData.CaptureArea, bucket, zoneWarData.CaptureArea)
    if Config.UseESX then
        local xPlayers = ESX.GetPlayers()
        for i=1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            if xPlayer.job.name == team1 then
                TriggerClientEvent('angelicxs-zoneWar:Client:TeamSetUp', xPlayers[i], zoneWarData, zoneWarData.TeamOneSpawn, bucket, zoneWarData.CaptureArea)
            elseif xPlayer.job.name == team2 then
                TriggerClientEvent('angelicxs-zoneWar:Client:TeamSetUp', xPlayers[i], zoneWarData, zoneWarData.TeamTwoSpawn, bucket, zoneWarData.CaptureArea)
            end
        end
    elseif Config.UseQBCore then
        local players = QBCore.Functions.GetQBPlayers()
        for k, v in pairs(players) do
            local name = v.PlayerData.job.name
            if Config.QBCoreUseGangs and v.PlayerData.gang.name ~= 'none' then
                name = v.PlayerData.gang.name
            end
            if name == team1 then
                TriggerClientEvent('angelicxs-zoneWar:Client:TeamSetUp', k, zoneWarData, zoneWarData.TeamOneSpawn, bucket, zoneWarData.CaptureArea)
            elseif name == team2 then
                TriggerClientEvent('angelicxs-zoneWar:Client:TeamSetUp', k, zoneWarData, zoneWarData.TeamTwoSpawn, bucket, zoneWarData.CaptureArea)
            end
        end
    end
    Wait(5000)
    CreateThread(function()
        TimeRemaining = Config.TimeLimit
        while true do
            Wait(60000)
            TimeRemaining = TimeRemaining-1
            for i = 1, #Config.TimeWarning do
                if TimeRemaining == Config.TimeWarning[i] then
                    for id, _ in pairs(WarBucket) do
                        TriggerClientEvent('angelicxs-zoneWar:Notify', id, Config.Lang['time_begin'].." "..tostring(Config.TimeWarning[i]).." "..Config.Lang['time_end'], Config.LangType['info'])
                    end
                end
            end
            if TimeRemaining <= 0 then
                for id, _ in pairs(WarBucket) do
                    TriggerClientEvent('angelicxs-zoneWar:Notify', id, Config.Lang['war_end'], Config.LangType['info'])
                    SetPlayerRoutingBucket(id, 0)
                    SetEntityCoords(GetPlayerPed(id), zoneWarData.CaptureArea.x, zoneWarData.CaptureArea.y, zoneWarData.CaptureArea.z)
                    if PointControl then
                        TriggerClientEvent('angelicxs-zoneWar:Notify', id, Config.Lang['war_winner'].." "..PointControl, Config.LangType['info'], true)
                    else
                        TriggerClientEvent('angelicxs-zoneWar:Notify', id, Config.Lang['war_nowinner'], Config.LangType['info'], true)
                    end
                end
                PointControl = false
                TimeRemaining = false
                WarBucket = {}
                break
            end
        end
    end)
end)


RegisterNetEvent('angelicxs-zoneWar:Server:ControlUpdate', function(team)
    if PointControl ~= team then
        PointControl = team
        for id, _ in pairs(WarBucket) do
            TriggerClientEvent('angelicxs-zoneWar:Notify', id, Config.Lang['capture_point'].." "..PointControl, Config.LangType['info'])
        end
    end
end)

RegisterNetEvent('angelicxs-zoneWar:Server:BucketMover', function(bucket)
    local src = source
    WarBucket[src] = true
    if not bucket then
        SetPlayerRoutingBucket(src, 0)
    elseif bucket ~= 0 then
        SetPlayerRoutingBucket(src, bucket)
    end
end)

AddEventHandler('onResourceStop', function(resource)
	if GetCurrentResourceName() == resource then
        for id, _ in pairs(WarBucket) do
            SetPlayerRoutingBucket(id, 0)
        end
        TimeRemaining = false
        WarBucket = {}
        PointControl = false
	end
end)
