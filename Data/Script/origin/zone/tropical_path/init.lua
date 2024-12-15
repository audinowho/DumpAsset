require 'origin.common'

local tropical_path = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function tropical_path.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_tropical_path")
  

end

function tropical_path.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function tropical_path.EnterSegment(zone, rescuing, segmentID, mapID)
  if rescuing ~= true then
    COMMON.BeginDungeon(zone.ID, segmentID, mapID)
  end
end

function tropical_path.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> ExitSegment_tropical_path result "..tostring(result).." segment "..tostring(segmentID))
  
  --first check for rescue flag; if we're in rescue mode then take a different path
  local exited = COMMON.ExitDungeonMissionCheck(result, rescue, zone.ID, segmentID)
  if exited == true then
    --do nothing
  elseif result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
    COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
  else
    if segmentID == 0 then
      COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 3, 0)
    elseif segmentID == 1 then
      COMMON.UnlockWithFanfare('tiny_tunnel', true)
      COMMON.EndDungeonDay(result, 'guildmaster_island', -1, 3, 0)
    else
      PrintInfo("No exit procedure found!")
      COMMON.EndDungeonDay(result, SV.checkpoint.Zone, SV.checkpoint.Segment, SV.checkpoint.Map, SV.checkpoint.Entry)
    end
  end
end

return tropical_path