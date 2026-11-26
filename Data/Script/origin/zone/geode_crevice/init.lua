require 'origin.common'

local geode_crevice = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function geode_crevice.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_geode_crevice")
  

end

function geode_crevice.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function geode_crevice.EnterSegment(zone, rescuing, segmentID, mapID)
  if rescuing ~= true then
    COMMON.BeginDungeon(zone.ID, segmentID, mapID)
  end
end

function geode_crevice.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> ExitSegment_geode_crevice result "..tostring(result).." segment "..tostring(segmentID))
    
  --first check for rescue flag; if we're in rescue mode then take a different path
  local exited = COMMON.ExitDungeonMissionCheck(result, rescue, zone.ID, segmentID)
  if exited == true then
    
    local got_treasure = COMMON.ProcessOneTimeTreasure("loot_music_box", rand_item, SV.geode_crevice)
	
  elseif result ~= RogueEssence.Data.GameProgress.ResultType.Cleared and result ~= RogueEssence.Data.GameProgress.ResultType.Escaped then
    COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
  elseif result == RogueEssence.Data.GameProgress.ResultType.Escaped then
	local got_treasure = COMMON.ProcessOneTimeTreasure("loot_music_box", rand_item, SV.geode_crevice)
	COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
  else
    local got_treasure = COMMON.ProcessOneTimeTreasure("loot_music_box", rand_item, SV.geode_crevice)
	
    if segmentID == 0 then
      COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 4, 0)
	  -- COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 5, 0)
    else
      PrintInfo("No exit procedure found!")
	  COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    end
  end
  
end

return geode_crevice
