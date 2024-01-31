----------------------------------------------------------------------
-- Thanks for supporting AngelicXS Scripts!							--
-- Support can be found at: https://discord.gg/tQYmqm4xNb			--
-- More paid scripts at: https://angelicxs.tebex.io/ 				--
-- More FREE scripts at: https://github.com/GouveiaXS/ 				--
----------------------------------------------------------------------

-- Model info: https://docs.fivem.net/docs/game-references/ped-models/
-- Blip info: https://docs.fivem.net/docs/game-references/blips/

Config = {}

Config.UseESX = false						-- Use ESX Framework
Config.UseQBCore = true						-- Use QBCore Framework (Ignored if Config.UseESX = true)
Config.QBCoreUseGangs = true                -- If true and Config.UseQBCore = true, will use QBCore gang playerdata

Config.QBInput = true						-- Use QB-Input [https://github.com/qbcore-framework/qb-input]
Config.QBMenu = true						-- Use QB-Menu [https://github.com/qbcore-framework/qb-menu]
Config.OXLib = false						-- Use the OX_lib (Ignored if Config.QBInput = true) [https://github.com/overextended/ox_lib]  !! must add shared_script '@ox_lib/init.lua' and lua54 'yes' to fxmanifest!!

Config.UseCustomNotify = false				-- Use a custom notification script, must complete event below.
-- Only complete this event if Config.UseCustomNotify is true; mythic_notification provided as an example
RegisterNetEvent('angelicxs-zoneWar:CustomNotify')
AddEventHandler('angelicxs-zoneWar:CustomNotify', function(message, type)
    --exports.mythic_notify:SendAlert(type, message, 4000)
    --exports['okokNotify']:Alert('', message, 4000, type, false)
end)

-- Blip Config
Config.AddMapBlip = true                    -- If true, adds blip on the map marking the capture point for war participants
Config.StartBlipIcon = 164                  -- If Config.AddMapBlip = true, what the blip icon is
Config.StartBlipColour = 2                  -- If Config.AddMapBlip = true, what colour the blip icon is


-- Zone War Information
Config.StartWarCommand = "startzonewar"     -- The /command to bring start a zone war
Config.WarPassword = "angelicxsZoneWar"     -- Password required to initiate a zone war, put false to turn off
Config.AutomaticRevive = true               -- If true, will automatically revive a player at their spawn after Config.ReviveTimer seconds
Config.ReviveTimer = 5                      -- If Config.AutomaticRevive = true, how long in seconds until the player is revived at their spawn
Config.TimeLimit = 2                       -- Time in minutes until Zone War is complete
Config.TimeWarning = {25,20,15,10,5,4,3,2,1}    -- Times when players will be informed how many minutes remain in the war
Config.ZoneWarAreas = {
    {ZoneName = "Mining Area", CaptureArea = vector3(2692.01, 2869.67, 36.45), TeamOneSpawn = vector3(2682.8, 2856.61, 36.25), TeamTwoSpawn = vector3(2705.47, 2880.98, 38.5)},
    {ZoneName = "Mining Area2", CaptureArea = vector3(2692.01, 2869.67, 36.45), TeamOneSpawn = vector3(2682.8, 2856.61, 36.25), TeamTwoSpawn = vector3(2705.47, 2880.98, 38.5)},

}

-- Language Configuration
Config.LangType = {
	['error'] = 'error',
	['success'] = 'success',
	['info'] = 'primary'
}

Config.Lang = {
	['password_zonewar'] = 'Input The Password To Access Zone War',
	['request_password'] = 'Input Password',
    ['wrong_password'] = 'You have input the wrong password.',
    ['menu_header'] = 'Choose Zone War Locations',
    ['cancel'] = 'Cancel',
    ['submit'] = 'Submit',
    ['team_input'] = "Enter Team Names",
    ['team_entry'] = "Team Name (database)",
    ['missing_team'] = "Team entry failure.",
    ['time_begin'] = "There is",
    ['time_end'] = "minutes remaining until war end!",
    ['war_start'] = "The war has started, it will last for "..Config.TimeLimit.." minutes!",
    ['capture_name'] = "Press ~r~E~w~ to capture the point!",
    ['war_end'] = "The war has ended you will be brought to the capture zone.",
    ['war_winner'] = "The winner of the war is",
    ['capture_point'] = "Zone area has been capture by",
    ['war_nowinner'] = "No one captured the point during the war, there is no winner.",
    ['respawn_notice'] = "You will be respawned soon.",
}