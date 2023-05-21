--[[
    Example Service
    
    This is an example to demonstrate how to use the BaseService class to implement a game service.
    
    **NOTE:** After declaring you service, you have to include your package inside the main.lua file!
]]--
require 'common'
require 'services.baseservice'

--Declare class VisibleMonsterHouses
local VisibleMonsterHouses = Class('VisibleMonsterHouses', BaseService)

--[[---------------------------------------------------------------
    VisibleMonsterHouses:initialize()
      VisibleMonsterHouses class constructor
---------------------------------------------------------------]]
function VisibleMonsterHouses:initialize()
  BaseService.initialize(self)
  self.mapname = ""
  PrintInfo('VisibleMonsterHouses:initialize()')
end

--[[---------------------------------------------------------------
    VisibleMonsterHouses:OnInit()
      Called on initialization of the script engine by the game!
---------------------------------------------------------------]]
function VisibleMonsterHouses:OnInit()
  _GAME.ChestAmbushWarningTile = "chest_house_full"
  _GAME.MonsterHouseWarningTile = "tile_warning"
  PrintInfo("\n<!> ExampleSvc: Init..")
end

--[[---------------------------------------------------------------
    VisibleMonsterHouses:OnDeinit()
      Called on de-initialization of the script engine by the game!
---------------------------------------------------------------]]
function VisibleMonsterHouses:OnDeinit()
  assert(self, 'VisibleMonsterHouses:OnDeinit() : self is null!')
  PrintInfo("\n<!> ExampleSvc: Deinit..")
end


---Summary
-- Subscribe to all channels this service wants callbacks from
function VisibleMonsterHouses:Subscribe(med)
  med:Subscribe("VisibleMonsterHouses", EngineServiceEvents.Init,                function() self.OnInit(self) end )
  med:Subscribe("VisibleMonsterHouses", EngineServiceEvents.Deinit,              function() self.OnDeinit(self) end )
end

---Summary
-- un-subscribe to all channels this service subscribed to
function VisibleMonsterHouses:UnSubscribe(med)
end

---Summary
-- The update method is run as a coroutine for each services.
function VisibleMonsterHouses:Update(gtime)
--  while(true)
--    coroutine.yield()
--  end
end

--Add our service
SCRIPT:AddService("VisibleMonsterHouses", VisibleMonsterHouses:new())
return VisibleMonsterHouses