require 'origin.common'

local tiny_tunnel = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function tiny_tunnel.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_tiny_tunnel")
  

end

function tiny_tunnel.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function tiny_tunnel.EnterSegment(zone, rescuing, segmentID, mapID)
  if rescuing ~= true then
    COMMON.BeginDungeon(zone.ID, segmentID, mapID)
  end
end

function tiny_tunnel.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> ExitSegment_tiny_tunnel result "..tostring(result).." segment "..tostring(segmentID))
  
  --first check for rescue flag; if we're in rescue mode then take a different path
  local exited = COMMON.ExitDungeonMissionCheck(result, rescue, zone.ID, segmentID)
  if exited == true then
    --do nothing
  elseif result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
    COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
  else
    if segmentID == 0 then
      COMMON.UnlockWithFanfare('geode_crevice', true)
      COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 4, 0)
    else
      PrintInfo("No exit procedure found!")
	  COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    end
  end
  
end

return tiny_tunnel
