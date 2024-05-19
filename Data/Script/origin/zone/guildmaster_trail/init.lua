require 'origin.common'

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
  local exited = COMMON.ExitDungeonMissionCheck(result, rescue, zone.ID, segmentID)
  if exited == true then
    --do nothing
  else
	if not SV.base_camp.ExpositionComplete then
	  GAME:SetRescueAllowed(true)
	end
    if result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
    --if result is defeat, unknown, timed out, or escaped, end the game with the destination as the last checkpoint
    --defeat is the same for all segments
	  if mapID > SV.guildmaster_trail.FloorsCleared then
	    SV.guildmaster_trail.FloorsCleared = mapID
	  end
	  
      COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    else
	  
      if segmentID == 0 then
        
	    if SV.guildmaster_summit.GameComplete then
	
		  if mapID >= SV.guildmaster_trail.FloorsCleared then
			SV.guildmaster_trail.FloorsCleared = mapID + 1
		  end
		  --already cleared the game? just win and land on the summit
          COMMON.EndDungeonDay(result, 'guildmaster_island', -1,8,0)
	    else
		  --didnt clear the game yet?  Go to the summit for the final test
		  if SV.Experimental then
			if mapID >= SV.guildmaster_trail.FloorsCleared then
			  SV.guildmaster_trail.FloorsCleared = mapID
			end  
			SV.guildmaster_summit.ClearedFromTrail = true
	        GAME:EnterZone('guildmaster_trail',-1,0,0)
		  else
		    GAME:UnlockDungeon('tropical_path')
		    SV.base_camp.ExpositionComplete = true
            SV.base_camp.FirstTalkComplete = true
		    SV.test_grounds.DemoComplete = true
		    COMMON.EndDungeonDay(result, 'the_neverending_tale', -1,0,0)
		  end
	    end
      else
        PrintInfo("No exit procedure found!")
	    COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
      end
    end
  end
end

return guildmaster_trail