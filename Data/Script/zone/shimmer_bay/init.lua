require 'common'

local shimmer_bay = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function shimmer_bay.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_shimmer_bay")
  

end

function shimmer_bay.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function shimmer_bay.EnterSegment(zone, rescuing, segmentID, mapID)
  if rescuing ~= true then
    COMMON.BeginDungeon(zone.ID, segmentID, mapID)
  end
  if GAME:GetPlayerStorageItemCount("egg_mystery") > 0 or GAME:InRogueMode() then
    SV.manaphy_egg.Taken = true
  else
	local item_slot = GAME:FindPlayerItem("egg_mystery", true, true)
	if item_slot:IsValid() then
	  SV.manaphy_egg.Taken = true
	else
      SV.manaphy_egg.Taken = false
	end
  end
  
  SV.shimmer_bay.TookTreasure = false
end

function shimmer_bay.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> ExitSegment_shimmer_bay result "..tostring(result).." segment "..tostring(segmentID))
  
  --first check for rescue flag; if we're in rescue mode then take a different path
  COMMON.ExitDungeonMissionCheck(zone.ID, segmentID)
  if rescue == true then
    COMMON.EndRescue(zone, result, segmentID)
  elseif result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
    COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
  else
    --if they have a chest with empty, REMOVE IT and change it to the correct item value
    --bag items
	local inv_count = _DATA.Save.ActiveTeam:GetInvCount() - 1
    for i = inv_count, 0, -1 do
	  local item = _DATA.Save.ActiveTeam:GetInv(i)
      if item.ID == "box_deluxe" and item.HiddenValue == "empty" then
        item.HiddenValue = "xcl_element_water_dust"
      end
    end
  
    --equips
    local player_count = _DATA.Save.ActiveTeam.Players.Count
    for i = 0, player_count - 1, 1 do 
      local player = _DATA.Save.ActiveTeam.Players[i]
      if player.EquippedItem.ID == "box_deluxe" and player.EquippedItem.HiddenValue == "empty" then 
        player.EquippedItem.HiddenValue = "xcl_element_water_dust"
      end
    end
	
    if segmentID == 0 then
      COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 1, 0)
    else
      PrintInfo("No exit procedure found!")
	  COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    end
  end
  
end

return shimmer_bay
