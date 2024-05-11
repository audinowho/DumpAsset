--[[
    Example Service
    
    This is an example to demonstrate how to use the BaseService class to implement a game service.
    
    **NOTE:** After declaring you service, you have to include your package inside the main.lua file!
]]--
require 'common'
require 'services.baseservice'

--Declare class MissionService
local MissionService = Class('MissionService', BaseService)

--[[---------------------------------------------------------------
    MissionService:initialize()
      MissionService class constructor
---------------------------------------------------------------]]
function MissionService:initialize()
  BaseService.initialize(self)
  self.mapname = ""
  PrintInfo('MissionService:initialize()')
end

--[[---------------------------------------------------------------
    MissionService:OnInit()
      Called on initialization of the script engine by the game!
---------------------------------------------------------------]]
function MissionService:OnInit()
  assert(self, 'MissionService:OnInit() : self is null!')
  PrintInfo("\n<!> ExampleSvc: Init..")
end

--[[---------------------------------------------------------------
    MissionService:OnDeinit()
      Called on de-initialization of the script engine by the game!
---------------------------------------------------------------]]
function MissionService:OnDeinit()
  assert(self, 'MissionService:OnDeinit() : self is null!')
  PrintInfo("\n<!> ExampleSvc: Deinit..")
end

function MissionService:OnNewGame()
  assert(self, 'MissionService:OnNewGame() : self is null!')

  SV.MissionsEnabled = true

end

function MissionService:OnUpgrade()
  assert(self, 'MissionService:OnUpgrade() : self is null!')
  
SV.MissionsEnabled = true
  
end

---Summary
-- Subscribe to all channels this service wants callbacks from
function MissionService:Subscribe(med)
  med:Subscribe("MissionService", EngineServiceEvents.Init,                function() self.OnInit(self) end )
  med:Subscribe("MissionService", EngineServiceEvents.Deinit,              function() self.OnDeinit(self) end )
  med:Subscribe("MissionService", EngineServiceEvents.NewGame,            function() self.OnNewGame(self) end )
  med:Subscribe("MissionService", EngineServiceEvents.UpgradeSave,        function() self.OnUpgrade(self) end )
end

---Summary
-- un-subscribe to all channels this service subscribed to
function MissionService:UnSubscribe(med)
end

---Summary
-- The update method is run as a coroutine for each services.
function MissionService:Update(gtime)
--  while(true)
--    coroutine.yield()
--  end
end

--Add our service
SCRIPT:AddService("MissionService", MissionService:new())
return MissionService