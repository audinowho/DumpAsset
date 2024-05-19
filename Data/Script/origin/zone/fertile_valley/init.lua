require 'origin.common'

local fertile_valley = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function fertile_valley.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_fertile_valley")
  

end

function fertile_valley.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function fertile_valley.EnterSegment(zone, rescuing, segmentID, mapID)
  if rescuing ~= true then
    COMMON.BeginDungeon(zone.ID, segmentID, mapID)
  end
end

function fertile_valley.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> ExitSegment_fertile_valley result "..tostring(result).." segment "..tostring(segmentID))
  
  --first check for rescue flag; if we're in rescue mode then take a different path
  local exited = COMMON.ExitDungeonMissionCheck(result, rescue, zone.ID, segmentID)
  if exited == true then
    --do nothing
  elseif result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
    COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
  else
    if segmentID == 0 then
      COMMON.UnlockWithFanfare('overgrown_wilds', true)
      COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 3, 2)
    elseif segmentID == 1 then
      COMMON.UnlockWithFanfare('wayward_wetlands', true)
      COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 4, 2)
    else
      PrintInfo("No exit procedure found!")
	  COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    end
  end
  
end

return fertile_valley
