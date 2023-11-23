--Import stuff from the submodules
require 'common'
require 'services.baseservice'

--Declare class ChatterEngine
local ChatterEngine = Class('ChatterEngine', BaseService)

--[[---------------------------------------------------------------
    ChatterEngine:new()
      ChatterEngine class constructor
---------------------------------------------------------------]]
function ChatterEngine:initialize()
  BaseService.initialize(self)
  PrintInfo('ChatterEngine:initialize()')
end


function ChatterEngine:Subscribe(med)
end

---Summary
-- un-subscribe to all channels this service subscribed to
function ChatterEngine:UnSubscribe(med)
end

--Add our service
SCRIPT:AddService("ChatterEngine", ChatterEngine:new())
return ChatterEngine