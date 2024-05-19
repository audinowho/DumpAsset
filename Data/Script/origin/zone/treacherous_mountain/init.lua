require 'origin.common'

local treacherous_mountain = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function treacherous_mountain.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_treacherous_mountain")
  

end

function treacherous_mountain.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function treacherous_mountain.EnterSegment(zone, rescuing, segmentID, mapID)
  if rescuing ~= true then
    COMMON.BeginDungeon(zone.ID, segmentID, mapID)
  end
end

function treacherous_mountain.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> ExitSegment_treacherous_mountain result "..tostring(result).." segment "..tostring(segmentID))
  
  --first check for rescue flag; if we're in rescue mode then take a different path
  local exited = COMMON.ExitDungeonMissionCheck(result, rescue, zone.ID, segmentID)
  if exited == true then
    --do nothing
  elseif result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
    if segmentID == 2 then
	  SV.treacherous_mountain.BossPhase = 1
	end
    COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
  else
    if segmentID == 0 then
      GAME:EnterZone('treacherous_mountain', -1, 0, 0)
	elseif segmentID == 3 then
	  SV.treacherous_mountain.BossPhase = 3
	  GAME:EnterZone('treacherous_mountain', -1, 0, 0)
    else
      PrintInfo("No exit procedure found!")
	  COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    end
  end
  
end

return treacherous_mountain
