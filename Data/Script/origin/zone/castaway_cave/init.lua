require 'common'

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
    --do nothing
	
	
	local got_treasure = false
    --bag items
	local inv_count = _DATA.Save.ActiveTeam:GetInvCount() - 1
    for i = inv_count, 0, -1 do
	  local item = _DATA.Save.ActiveTeam:GetInv(i)
      if item.ID == "box_deluxe" and item.HiddenValue == "empty" then
        item.HiddenValue = "xcl_element_water_dust"
		got_treasure = true
      end
      if item.ID == "egg_mystery" and item.HiddenValue == "empty" then
        SV.manaphy_egg.Taken = true
		got_treasure = true
      end
    end
  
    --equips
    local player_count = _DATA.Save.ActiveTeam.Players.Count
    for i = 0, player_count - 1, 1 do 
      local player = _DATA.Save.ActiveTeam.Players[i]
      if player.EquippedItem.ID == "box_deluxe" and player.EquippedItem.HiddenValue == "empty" then 
        player.EquippedItem.HiddenValue = "xcl_element_water_dust"
		got_treasure = true
      end
      if player.EquippedItem.ID == "egg_mystery" and player.EquippedItem.HiddenValue == "empty" then 
        SV.manaphy_egg.Taken = true
		got_treasure = true
      end
    end
	
	if not got_treasure and result == RogueEssence.Data.GameProgress.ResultType.Cleared then
	  result = RogueEssence.Data.GameProgress.ResultType.Escaped
	end
  elseif result ~= RogueEssence.Data.GameProgress.ResultType.Cleared and result ~= RogueEssence.Data.GameProgress.ResultType.Escaped then
    COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
  else
	
	--if they took the egg and brought it all the way out, it's theirs now and can never respawn
	--only roguelocke can you get more from then on
    --if they have a chest with empty, REMOVE IT and change it to the correct item value
	
	local got_treasure = false
    --bag items
	local inv_count = _DATA.Save.ActiveTeam:GetInvCount() - 1
    for i = inv_count, 0, -1 do
	  local item = _DATA.Save.ActiveTeam:GetInv(i)
      if item.ID == "box_deluxe" and item.HiddenValue == "empty" then
        item.HiddenValue = "xcl_element_water_dust"
		got_treasure = true
      end
      if item.ID == "egg_mystery" and item.HiddenValue == "empty" then
        SV.manaphy_egg.Taken = true
		got_treasure = true
      end
    end
  
    --equips
    local player_count = _DATA.Save.ActiveTeam.Players.Count
    for i = 0, player_count - 1, 1 do 
      local player = _DATA.Save.ActiveTeam.Players[i]
      if player.EquippedItem.ID == "box_deluxe" and player.EquippedItem.HiddenValue == "empty" then 
        player.EquippedItem.HiddenValue = "xcl_element_water_dust"
		got_treasure = true
      end
      if player.EquippedItem.ID == "egg_mystery" and player.EquippedItem.HiddenValue == "empty" then 
        SV.manaphy_egg.Taken = true
		got_treasure = true
      end
    end
	
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
