--[[
    Example Service
    
    This is an example to demonstrate how to use the BaseService class to implement a game service.
    
    **NOTE:** After declaring you service, you have to include your package inside the main.lua file!
]]--
require 'common'
require 'services.baseservice'

--Declare class NoMonsterHouseSpawns
local NoMonsterHouseSpawns = Class('NoMonsterHouseSpawns', BaseService)

MenuTextChoiceType = luanet.import_type('RogueEssence.Menu.MenuTextChoice')
MenuTextType = luanet.import_type('RogueEssence.Menu.MenuText')
--[[---------------------------------------------------------------
    NoMonsterHouseSpawns:initialize()
      NoMonsterHouseSpawns class constructor
---------------------------------------------------------------]]
function NoMonsterHouseSpawns:initialize()
  BaseService.initialize(self)
  self.mapname = ""
  PrintInfo('NoMonsterHouseSpawns:initialize()')
end

--[[---------------------------------------------------------------
    NoMonsterHouseSpawns:OnInit()
      Called on initialization of the script engine by the game!
---------------------------------------------------------------]]
function NoMonsterHouseSpawns:OnInit()
  _GAME.NoMonsterHouseEntrances = true
  PrintInfo("\n<!> ExampleSvc: Init..")
end

--[[---------------------------------------------------------------
    NoMonsterHouseSpawns:OnDeinit()
      Called on de-initialization of the script engine by the game!
---------------------------------------------------------------]]
function NoMonsterHouseSpawns:OnDeinit()
  assert(self, 'NoMonsterHouseSpawns:OnDeinit() : self is null!')
  PrintInfo("\n<!> ExampleSvc: Deinit..")
end

  ---Summary
-- Subscribe to all channels this service wants callbacks from
function NoMonsterHouseSpawns:Subscribe(med)
  med:Subscribe("NoMonsterHouseSpawns", EngineServiceEvents.Init,                function() self.OnInit(self) end )
  med:Subscribe("NoMonsterHouseSpawns", EngineServiceEvents.Deinit,              function() self.OnDeinit(self) end )
end

---Summary
-- un-subscribe to all channels this service subscribed to
function NoMonsterHouseSpawns:UnSubscribe(med)
end

---Summary
-- The update method is run as a coroutine for each services.
function NoMonsterHouseSpawns:Update(gtime)
--  while(true)
--    coroutine.yield()
--  end
end

--Add our service
SCRIPT:AddService("NoMonsterHouseSpawns", NoMonsterHouseSpawns:new())
return NoMonsterHouseSpawns