require 'origin.common'

local lava_floe_island = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function lava_floe_island.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_lava_floe_island")
  

end

function lava_floe_island.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function lava_floe_island.EnterSegment(zone, rescuing, segmentID, mapID)
  if rescuing ~= true then
    COMMON.BeginDungeon(zone.ID, segmentID, mapID)
  end
end

function lava_floe_island.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> ExitSegment_lava_floe_island result "..tostring(result).." segment "..tostring(segmentID))
  
  --first check for rescue flag; if we're in rescue mode then take a different path
  local exited = COMMON.ExitDungeonMissionCheck(result, rescue, zone.ID, segmentID)
  if exited == true then
    --do nothing
  elseif result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
    COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
  else
    if segmentID == 0 then
      COMMON.UnlockWithFanfare('castaway_cave', true)
      COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 1, 0)
    elseif segmentID == 1 then
      COMMON.UnlockWithFanfare('inscribed_cave', true)
      COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 1, 0)
    else
      PrintInfo("No exit procedure found!")
	  COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    end
  end
  
end

return lava_floe_island
