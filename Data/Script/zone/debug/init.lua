require 'common'

local debug = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function debug.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_debug")
  

end

function debug.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function debug.EnterSegment(zone, rescuing, segmentID, mapID)
  PrintInfo("=>> EnterSegment_debug")
  if rescuing ~= true then
    COMMON.BeginDungeon(zone.ID, segmentID, mapID)
  end
end

function debug.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  COMMON.ExitDungeonMissionCheck(zone.ID, segmentID)
  if rescue == true then
    COMMON.EndRescue(zone, result, segmentID)
  else
    COMMON.EndSession(result, 0, -1, 0, 0)
  end
end

return debug