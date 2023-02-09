require 'common'

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
  COMMON.ExitDungeonMissionCheck(zone.ID, segmentID)
  if rescue == true then
    COMMON.EndRescue(zone, result, segmentID)
  elseif result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
    COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
  else
    if segmentID == 0 then
	  if SV.guildmaster_summit.ExpositionComplete then
        COMMON.EndDungeonDay(result, 'guildmaster_island', -1,8,0)
	  else
	    GAME:EnterZone('guildmaster_island',-1,8, 0)
	  end
    elseif segmentID == 1 then
      COMMON.UnlockWithFanfare('the_sky', true)
      COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 4, 2)
    elseif segmentID == 2 then
      --for the boss segment, set a save variable
      --the MAP's script will play the final cutscene
      --AND it will end the game
      SV.guildmaster_summit.BattleComplete = true
      GAME:EnterZone('guildmaster_island', -1, 8, 0)
    else
      PrintInfo("No exit procedure found!")
	  COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    end
  end
  
end

return champions_road