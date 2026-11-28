--[[
    common_vars.lua
    Save vars
]]--

---Check used in missiongen_settings to see if there is an active sidequest in the current zone
function COMMON.HasSidequestInZone(zone)
    for _, mission in pairs(SV.missions.Missions) do
        if mission.DestZone == zone then
            return true
        end
    end
    return false
end

local base_game_exit_dungeon_mission_check_ex = COMMON.ExitDungeonMissionCheckEx
---Overrides origin function.
function COMMON.ExitDungeonMissionCheckEx(result, rescue, zoneId, segmentID)
    --specifically added for PMDO's base game. Resets the quest board reroll price to minimum at each day end. 
    if SV.jobs.rerolls then SV.jobs.rerolls=0 end
    --remove all guests from the dungeon
    MISSION_GEN:ExitDungeonMissionCheckEx(result, rescue, zoneId, segmentID)
    return base_game_exit_dungeon_mission_check_ex(result, rescue, zoneId, segmentID)
end