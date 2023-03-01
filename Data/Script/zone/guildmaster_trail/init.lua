require 'common'

local guildmaster_trail = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function guildmaster_trail.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_guildmaster_trail")
  

end

function guildmaster_trail.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function guildmaster_trail.EnterSegment(zone, rescuing, segmentID, mapID)
  if rescuing ~= true then
    COMMON.BeginDungeon(zone.ID, segmentID, mapID)
  end
end

function guildmaster_trail.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> ExitSegment_guildmaster_trail result "..tostring(result).." segment "..tostring(segmentID))
  
  --TODO: rogue mode endings
  --need to restart to title
  
  --first check for rescue flag; if we're in rescue mode then take a different path
  COMMON.ExitDungeonMissionCheck(zone.ID, segmentID)
  if rescue == true then
    COMMON.EndRescue(zone, result, segmentID)
  else
	if not SV.base_camp.ExpositionComplete then
	  GAME:SetRescueAllowed(true)
	end
    if result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
    --if result is defeat, unknown, timed out, or escaped, end the game with the destination as the last checkpoint
    --defeat is the same for all segments
      COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    else
      if segmentID == 0 then
        --if the result is victory, send to the destination zone, or just win to the destination zone
	    if SV.guildmaster_summit.ExpositionComplete then
          COMMON.EndDungeonDay(result, 'guildmaster_island', -1,8,0)
	    else
	      --GAME:EnterZone('guildmaster_island',-1,8,0)
		  GAME:UnlockDungeon('tropical_path')
		  SV.base_camp.ExpositionComplete = true
          SV.base_camp.FirstTalkComplete = true
		  SV.test_grounds.DemoComplete = true
		  COMMON.EndDungeonDay(result, 'the_neverending_tale', -1,0,0)
	    end
      elseif segmentID == 1 then
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
end

return guildmaster_trail