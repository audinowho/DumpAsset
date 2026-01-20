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

---Overrides origin function.
function COMMON.ExitDungeonMissionCheckEx(result, rescue, zoneId, segmentID)
    --remove all guests from the dungeon
    return MissionGen:ExitDungeonMissionCheckEx(result, rescue, zoneId, segmentID)
end