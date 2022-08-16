require 'common'

local debug_zone = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function debug_zone.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_debug")
  

end

function debug_zone.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function debug_zone.EnterSegment(zone, rescuing, segmentID, mapID)
  PrintInfo("=>> EnterSegment_debug")
  if rescuing ~= true then
    COMMON.BeginDungeon(zone.ID, segmentID, mapID)
  end
end

function debug_zone.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  COMMON.ExitDungeonMissionCheck(zone.ID, segmentID)
  if rescue == true then
    COMMON.EndRescue(zone, result, segmentID)
  else
    COMMON.EndSession(result, 'debug_zone', -1, 0, 0)
  end
end

return debug_zone