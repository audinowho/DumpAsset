require 'common'

local zone_1 = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function zone_1.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_zone_1")
  

end

function zone_1.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function zone_1.EnterSegment(zone, rescuing, segmentID, mapID)

end

function zone_1.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine

  COMMON.EndSession(result, 1,-1,3,0)
end

return zone_1