require 'origin.common'

local sleeping_caldera = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function sleeping_caldera.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_sleeping_caldera")
  

end

function sleeping_caldera.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function sleeping_caldera.EnterSegment(zone, rescuing, segmentID, mapID)
  if rescuing ~= true then
    COMMON.BeginDungeon(zone.ID, segmentID, mapID)
  end
  SV.sleeping_caldera.TookTreasure = false
end

function sleeping_caldera.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> ExitSegment_sleeping_caldera result "..tostring(result).." segment "..tostring(segmentID))
  
  --first check for rescue flag; if we're in rescue mode then take a different path
  local exited = COMMON.ExitDungeonMissionCheck(result, rescue, zone.ID, segmentID)
  if exited == true then
    
    local got_treasure = COMMON.ProcessOneTimeTreasure("loot_secret_slab", "xcl_element_fire_dust", SV.sleeping_caldera)
	
    if not got_treasure and result == RogueEssence.Data.GameProgress.ResultType.Cleared then
      result = RogueEssence.Data.GameProgress.ResultType.Escaped
    end
	
  elseif result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
    COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
  else
	
    local got_treasure = COMMON.ProcessOneTimeTreasure("loot_secret_slab", "xcl_element_fire_dust", SV.sleeping_caldera)
	
    if not got_treasure and result == RogueEssence.Data.GameProgress.ResultType.Cleared then
      result = RogueEssence.Data.GameProgress.ResultType.Escaped
    end
	
    if segmentID == 0 then
      COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 5, 2)
    else
      PrintInfo("No exit procedure found!")
	  COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    end
  end
  
end

return sleeping_caldera
