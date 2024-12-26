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
  SV.geode_crevice.TookTreasure = false
end

function geode_crevice.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> ExitSegment_geode_crevice result "..tostring(result).." segment "..tostring(segmentID))
  
  local rand_item = "xcl_element_normal_silk"
  local inside_val = _DATA.Save.Rand:Next(5)
  if inside_val == 0 then
    rand_item = "xcl_element_electric_silk"
  elseif inside_val == 1 then
    rand_item = "xcl_element_fire_silk"
  elseif inside_val == 2 then
    rand_item = "xcl_element_water_silk"
  elseif inside_val == 3 then
    rand_item = "xcl_element_grass_silk"
  else
    rand_item = "xcl_element_normal_silk"
  end
  
  --first check for rescue flag; if we're in rescue mode then take a different path
  local exited = COMMON.ExitDungeonMissionCheck(result, rescue, zone.ID, segmentID)
  if exited == true then
    
    local got_treasure = COMMON.ProcessOneTimeTreasure("loot_music_box", rand_item, SV.geode_crevice)
	
  elseif result ~= RogueEssence.Data.GameProgress.ResultType.Cleared and result ~= RogueEssence.Data.GameProgress.ResultType.Escaped then
    COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
  else
	
    local got_treasure = COMMON.ProcessOneTimeTreasure("loot_music_box", rand_item, SV.geode_crevice)
	
    if segmentID == 0 then
      COMMON.UnlockWithFanfare('secret_garden', true)
      COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 5, 0)
    else
      PrintInfo("No exit procedure found!")
	  COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    end
  end
  
end

return geode_crevice
