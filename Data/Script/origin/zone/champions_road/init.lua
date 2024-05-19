require 'origin.common'

local champions_road = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function champions_road.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_champions_road")
  

end

function champions_road.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function champions_road.EnterSegment(zone, rescuing, segmentID, mapID)
  if rescuing ~= true then
    COMMON.BeginDungeon(zone.ID, segmentID, mapID)
  end
end

function champions_road.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> ExitSegment_champions_road result "..tostring(result).." segment "..tostring(segmentID))
  
  --first check for rescue flag; if we're in rescue mode then take a different path
  local exited = COMMON.ExitDungeonMissionCheck(result, rescue, zone.ID, segmentID)
  if exited == true then
    --do nothing
  elseif result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
    COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
  else
    if segmentID == 0 then
	  if SV.guildmaster_summit.GameComplete then
        COMMON.EndDungeonDay(result, 'guildmaster_island', -1,8,0)
	  else
	    SV.guildmaster_summit.ClearedFromTrail = false
	    GAME:EnterZone('guildmaster_island',-1,8, 0)
	  end
    elseif segmentID == 1 then
      COMMON.UnlockWithFanfare('the_sky', true)
      COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 4, 2)
    else
      PrintInfo("No exit procedure found!")
	  COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    end
  end
  
end

return champions_road