require 'origin.common'

local ambush_forest = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function ambush_forest.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_ambush_forest")
  

end

function ambush_forest.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function ambush_forest.EnterSegment(zone, rescuing, segmentID, mapID)
  if rescuing ~= true then
    COMMON.BeginDungeon(zone.ID, segmentID, mapID)
  end
end

function ambush_forest.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> ExitSegment_ambush_forest result "..tostring(result).." segment "..tostring(segmentID))
  
  --first check for rescue flag; if we're in rescue mode then take a different path
  local exited = COMMON.ExitDungeonMissionCheck(result, rescue, zone.ID, segmentID)
  if exited == true then
    --do nothing
  elseif result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
    if segmentID == 2 then
	  SV.ambush_forest.BossPhase = 1
	end
    COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
  else
    if segmentID == 0 then
      GAME:EnterZone('ambush_forest', -1, 0, 0)
	elseif segmentID == 3 then
	  SV.ambush_forest.BossPhase = 3
	  GAME:EnterZone('ambush_forest', -1, 0, 0)
    else
      PrintInfo("No exit procedure found!")
	  COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    end
  end
  
end

return ambush_forest
