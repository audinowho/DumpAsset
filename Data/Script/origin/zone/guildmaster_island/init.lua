require 'origin.common'

local guildmaster_island = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function guildmaster_island.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_guildmaster_island")
  

end

function guildmaster_island.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function guildmaster_island.EnterSegment(zone, rescuing, segmentID, mapID)
  if rescuing ~= true then
    COMMON.BeginDungeon(zone.ID, segmentID, mapID)
  end
end

function guildmaster_island.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine

  local exited = COMMON.ExitDungeonMissionCheck(result, rescue, zone.ID, segmentID)
  if exited == true then
    --do nothing
  elseif result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
    if segmentID == 0 then
	  if mapID == 3 then
	    SV.forest_camp.SnorlaxPhase = 2
	    COMMON.EndSession(result, 'guildmaster_island', -1,3,3)
	    return
	  elseif mapID == 6 then
	    SV.rest_stop.BossPhase = 2
	    COMMON.EndSession(result, 'guildmaster_island', -1,5,2)
	    return
	  elseif mapID == 7 then
	    SV.final_stop.DragonPhase = 2
	    COMMON.EndSession(result, 'guildmaster_island', -1,7,1)
	    return
	  elseif mapID == 8 then
	    SV.guildmaster_summit.BossPhase = 2
		if SV.guildmaster_summit.ClearedFromTrail then
	      SV.guildmaster_summit.BossPhase = 1
	      COMMON.EndDungeonDay(result, 'guildmaster_island', -1,1,0)
		else
		  COMMON.EndDayCycle()
		  COMMON.EndSession(RogueEssence.Data.GameProgress.ResultType.Escaped, 'guildmaster_island', -1,7,2)
		end
	    return
	  end
	end
    COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
  else
    if segmentID == 0 then
	  if mapID == 3 then
		SV.forest_camp.SnorlaxPhase = 3
	    COMMON.EndSession(result, 'guildmaster_island', -1,3,3)
	  elseif mapID == 6 then
		SV.rest_stop.BossPhase = 3
	    COMMON.EndSession(result, 'guildmaster_island', -1,6,1)
	  elseif mapID == 7 then
		SV.final_stop.DragonPhase = 3
	    COMMON.EndSession(result, 'guildmaster_island', -1,7,1)
      elseif mapID == 8 then
        --for the boss segment, set a save variable
        --the MAP's script will play the final cutscene
        --AND it will end the game
        SV.guildmaster_summit.BossPhase = 3
		if SV.guildmaster_summit.ClearedFromTrail then
		  GAME:EnterZone('guildmaster_trail',-1,0,0)
		else
          GAME:EnterZone('guildmaster_island', -1, 8, 0)
		end
	  else
	    PrintInfo("No exit procedure found!")
		COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
	  end
    else
      PrintInfo("No exit procedure found!")
	  COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    end
  end
end

return guildmaster_island