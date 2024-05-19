require 'origin.common'

local flyaway_cliffs = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function flyaway_cliffs.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_flyaway_cliffs")
  

end

function flyaway_cliffs.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function flyaway_cliffs.EnterSegment(zone, rescuing, segmentID, mapID)
  if rescuing ~= true then
    COMMON.BeginDungeon(zone.ID, segmentID, mapID)
  end
end

function flyaway_cliffs.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> ExitSegment_flyaway_cliffs result "..tostring(result).." segment "..tostring(segmentID))
  
  --first check for rescue flag; if we're in rescue mode then take a different path
  local exited = COMMON.ExitDungeonMissionCheck(result, rescue, zone.ID, segmentID)
  if exited == true then
    --do nothing
  elseif result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
    COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
  else
    if segmentID == 0 then
	  if SV.Experimental then
        COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 5, 0)
	  else
	    COMMON.EndDungeonDay(result, 'the_neverending_tale', -1,0,0)
	  end
    else
      PrintInfo("No exit procedure found!")
	  COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    end
  end
  
end

return flyaway_cliffs