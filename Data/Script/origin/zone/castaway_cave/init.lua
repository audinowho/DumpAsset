require 'origin.common'

local castaway_cave = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function castaway_cave.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_castaway_cave")
  

end

function castaway_cave.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function castaway_cave.EnterSegment(zone, rescuing, segmentID, mapID)
  if rescuing ~= true then
    COMMON.BeginDungeon(zone.ID, segmentID, mapID)
  end
  SV.castaway_cave.TookTreasure = false
end

function castaway_cave.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> ExitSegment_castaway_cave result "..tostring(result).." segment "..tostring(segmentID))
  
  --first check for rescue flag; if we're in rescue mode then take a different path
  local exited = COMMON.ExitDungeonMissionCheck(result, rescue, zone.ID, segmentID)
  if exited == true then
    
    local got_treasure = COMMON.ProcessOneTimeTreasure("egg_mystery", "xcl_element_water_dust", SV.castaway_cave)
	
    if not got_treasure and result == RogueEssence.Data.GameProgress.ResultType.Cleared then
      result = RogueEssence.Data.GameProgress.ResultType.Escaped
    end
  elseif result ~= RogueEssence.Data.GameProgress.ResultType.Cleared and result ~= RogueEssence.Data.GameProgress.ResultType.Escaped then
    COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
  else
	
    local got_treasure = COMMON.ProcessOneTimeTreasure("egg_mystery", "xcl_element_water_dust", SV.castaway_cave)
	
    if not got_treasure and result == RogueEssence.Data.GameProgress.ResultType.Cleared then
      result = RogueEssence.Data.GameProgress.ResultType.Escaped
    end
	
    if segmentID == 0 then
      COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 1, 0)
    else
      PrintInfo("No exit procedure found!")
	  COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    end
  end
  
end

return castaway_cave
