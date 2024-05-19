require 'origin.common'

local training_maze = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function training_maze.Init(zone)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_training_maze")
  

end

function training_maze.Rescued(zone, name, mail)
  COMMON.Rescued(zone, name, mail)
end

function training_maze.EnterSegment(zone, rescuing, segmentID, mapID)
  if rescuing ~= true then
    COMMON.BeginDungeon(zone.ID, segmentID, mapID)
  end
end

function training_maze.ExitSegment(zone, result, rescue, segmentID, mapID)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> ExitSegment_training_maze result "..tostring(result).." segment "..tostring(segmentID))
  
  --first check for rescue flag; if we're in rescue mode then take a different path
  if result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
    COMMON.EndSession(result, 'guildmaster_island', -1, 1, 0)
  else
    -- TODO: make noctowl say something.  requires setting save variables
    COMMON.EndSession(result, 'guildmaster_island', -1, 1, 0)
  end
  
end

return training_maze