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
    --TODO: if they have the manaphy egg, REMOVE IT, and set the boolean to true
	local item_slot = GAME:FindPlayerItem("egg_mystery", true, true)
	if item_slot:IsValid() then
		if item_slot.IsEquipped then
			GAME:TakePlayerEquippedItem(item_slot.Slot)
		else
			GAME:TakePlayerBagItem(item_slot.Slot)
		end
		SV.manaphy_egg.Taken = true
	end
    if segmentID == 0 then
      COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 3, 0)
    else
      PrintInfo("No exit procedure found!")
	  COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    end
  end
  
end

return shimmer_bay
