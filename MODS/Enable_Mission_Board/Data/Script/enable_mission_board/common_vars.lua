--[[
    common_vars.lua
    Save vars
]]--

function COMMON.CreateMission(key, mission)
    SV.missions.Missions[key] = mission

    if mission.DestZone ~= nil then
        for i = 1, 8, 1 do
            local zone = SV.TakenBoard[i].Zone
            if zone ~= nil and zone ~= '' and zone == mission.DestZone then
                SV.TakenBoard[i].Taken = false
            end
        end
    end
end

--Check to see if there is an active sidequest in the current zone
function COMMON.HasSidequestInZone(zone)
    for name, mission in pairs(SV.missions.Missions) do
        if mission.DestZone == zone then
            return true
        end
    end

    return false
end

function COMMON.ExitDungeonMissionCheckEx(result, rescue, zoneId, segmentID)
    --remove all guests from the dungeon
    _DATA.Save.ActiveTeam.Guests:Clear()

    --Remove any lost/stolen items. If the item's ID starts with "mission" then delete it on exiting the dungeon.
    local itemCount = GAME:GetPlayerBagCount()
    local item

    local i = 0
    while i <= itemCount - 1 do
        item = GAME:GetPlayerBagItem(i)
        if string.sub(item.ID, 1, 7) == "mission" then
            GAME:TakePlayerBagItem(i)
            itemCount = itemCount - 1
        else
            i = i + 1
        end
    end

    --send equipped items to storage
    for i = 1, GAME:GetPlayerPartyCount(), 1 do
        item = GAME:GetPlayerEquippedItem(i-1)
        if string.sub(item.ID, 1, 7) == "mission" then
            GAME:TakePlayerEquippedItem(i-1)
        end
    end

    if SV.MissionsEnabled then

        MISSION_GEN.EndOfDay(result, segmentID)

        if SV.TemporaryFlags.MissionCompleted then
            COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 2, 0)
            return true
        end
    end

    return false
end