--[[
    Example Service
    
    This is an example to demonstrate how to use the BaseService class to implement a game service.
    
    **NOTE:** After declaring you service, you have to include your package inside the main.lua file!
]]--
require 'common'
require 'services.baseservice'

--Declare class DebugTools
local DebugTools = Class('DebugTools', BaseService)


--[[---------------------------------------------------------------
    DebugTools:initialize()
      DebugTools class constructor
---------------------------------------------------------------]]
function DebugTools:initialize()
  BaseService.initialize(self)
  PrintInfo('DebugTools:initialize()')
end

--[[---------------------------------------------------------------
    DebugTools:__gc()
      DebugTools class gc method
      Essentially called when the garbage collector collects the service.
  ---------------------------------------------------------------]]
function DebugTools:__gc()
  PrintInfo('*****************DebugTools:__gc()')
end

--[[---------------------------------------------------------------
    DebugTools:OnInit()
      Called on initialization of the script engine by the game!
---------------------------------------------------------------]]
function DebugTools:OnInit()
  assert(self, 'DebugTools:OnInit() : self is null!')
  PrintInfo("\n<!> ExampleSvc: Init..")
end

--[[---------------------------------------------------------------
    DebugTools:OnDeinit()
      Called on de-initialization of the script engine by the game!
---------------------------------------------------------------]]
function DebugTools:OnDeinit()
  assert(self, 'DebugTools:OnDeinit() : self is null!')
  PrintInfo("\n<!> ExampleSvc: Deinit..")
end

--[[---------------------------------------------------------------
    DebugTools:OnMenuButtonPressed()
      When the main menu button is pressed or the main menu should be enabled this is called!
      This is called as a coroutine.
---------------------------------------------------------------]]
function DebugTools:OnMenuButtonPressed()
  if DebugTools.MainMenu == nil then
    DebugTools.MainMenu = RogueEssence.Menu.MainMenu()
  end
  DebugTools.MainMenu:SetupChoices()
  DebugTools.MainMenu:SetupTitleAndSummary()
  DebugTools.MainMenu:InitMenu()
  TASK:WaitTask(_MENU:ProcessMenuCoroutine(DebugTools.MainMenu))
end

--[[---------------------------------------------------------------
    DebugTools:OnOthersMenuButtonPressed()
      When the others menu button is pressed from the main menu (or the others menu should be enabled) this is called!
      This is called as a coroutine.
---------------------------------------------------------------]]
function DebugTools:OnOthersMenuButtonPressed()
  if DebugTools.OthersMenu == nil then
    DebugTools.OthersMenu = RogueEssence.Menu.OthersMenu()
  end
  DebugTools.OthersMenu:SetupChoices()
  DebugTools.OthersMenu:InitMenu()
  TASK:WaitTask(_MENU:ProcessMenuCoroutine(DebugTools.OthersMenu))
end

--[[---------------------------------------------------------------
    DebugTools:OnNewGame()
      When a new save file is loaded this is called!
---------------------------------------------------------------]]
function DebugTools:OnNewGame()
  assert(self, 'DebugTools:OnNewGame() : self is null!')
  
  for ii = 1, _DATA.Start.Chars.Count, 1 do
    _DATA.Save:RogueUnlockMonster(_DATA.Start.Chars[ii-1].ID.Species)
  end
  
  if _DATA.Save.ActiveTeam.Players.Count > 0 then
    local talk_evt = RogueEssence.Dungeon.BattleScriptEvent("AllyInteract")
    _DATA.Save.ActiveTeam.Players[0].ActionEvents:Add(talk_evt)
	_DATA.Save:RegisterMonster(_DATA.Save.ActiveTeam.Players[0].BaseForm.Species)
	
	_DATA.Save.ActiveTeam:SetRank("normal")
	if not GAME:InRogueMode() then
      _DATA.Save.ActiveTeam.Bank = 1000
	end
	SV.General.Starter = _DATA.Save.ActiveTeam.Players[0].BaseForm
  else
    PrintInfo("\n<!> ExampleSvc: Preparing debug save file")
    _DATA.Save.ActiveTeam:SetRank("normal")
    _DATA.Save.ActiveTeam.Name = "Debug"
    _DATA.Save.ActiveTeam.Money = 1000
    _DATA.Save.ActiveTeam.Bank = 1000000
  
    local mon_id = RogueEssence.Dungeon.MonsterID("bulbasaur", 0, "normal", Gender.Male)
    _DATA.Save.ActiveTeam.Players:Add(_DATA.Save.ActiveTeam:CreatePlayer(_DATA.Save.Rand, mon_id, 50, "", 0))
    mon_id = RogueEssence.Dungeon.MonsterID("charmander", 0, "normal", Gender.Male)
    _DATA.Save.ActiveTeam.Players:Add(_DATA.Save.ActiveTeam:CreatePlayer(_DATA.Save.Rand, mon_id, 50, "", 0))
    mon_id = RogueEssence.Dungeon.MonsterID("squirtle", 0, "normal", Gender.Male)
    _DATA.Save.ActiveTeam.Players:Add(_DATA.Save.ActiveTeam:CreatePlayer(_DATA.Save.Rand, mon_id, 50, "", 0))
	
	
    local talk_evt = RogueEssence.Dungeon.BattleScriptEvent("AllyInteract")
    _DATA.Save.ActiveTeam.Players[0].ActionEvents:Add(talk_evt)
	talk_evt = RogueEssence.Dungeon.BattleScriptEvent("AllyInteract")
    _DATA.Save.ActiveTeam.Players[1].ActionEvents:Add(talk_evt)
	talk_evt = RogueEssence.Dungeon.BattleScriptEvent("AllyInteract")
    _DATA.Save.ActiveTeam.Players[2].ActionEvents:Add(talk_evt)
	
    _DATA.Save.ActiveTeam.Leader.IsFounder = true
	
	_DATA.Save:UpdateTeamProfile(true)
    
	local dungeon_keys = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:GetOrderedKeys(false)
	for ii = 0, dungeon_keys.Count-1 ,1 do
		GAME:UnlockDungeon(dungeon_keys[ii])
	end
  
    --for ii = 900, 2370, 1 do
    --  GAME:GivePlayerStorageItem(ii)
    --  SV.unlocked_trades[ii] = true
    --end
	
    --for ii = 1, 10000, 1 do
    --  mon_id = RogueEssence.Dungeon.MonsterID("bulbasaur", 0, "normal", Gender.Male)
    --  _DATA.Save.ActiveTeam.Assembly:Add(_DATA.Save.ActiveTeam:CreatePlayer(_DATA.Save.Rand, mon_id, 50, "", 0))
    --end
    
	if SV.base_camp ~= nil then
      SV.base_camp.ExpositionComplete = true
      SV.base_camp.IntroComplete = true
	end
	if SV.test_grounds ~= nil then
	  SV.test_grounds.DemoComplete = true
	end
	SV.General.Starter = _DATA.Save.ActiveTeam.Players[0].BaseForm
  end
end

--[[---------------------------------------------------------------
    DebugTools:OnUpgrade()
      When a save file in an old version is loaded this is called!
---------------------------------------------------------------]]
function DebugTools:OnUpgrade()
  assert(self, 'DebugTools:OnUpgrade() : self is null!')
  
  PrintInfo("=>> Loading version")
  _DATA.Save.NextDest = _DATA.Start.Map
  
  SV.checkpoint = 
  {
    Zone    = 'guildmaster_island', Segment  = -1,
    Map  = 1, Entry  = 0
  }
  
  if SV.test_grounds.DemoComplete == nil then
    SV.test_grounds =
    {
      SpokeToPooch = false,
      AcceptedPooch = false,
      Starter = { Species="pikachu", Form=0, Skin="normal", Gender=2 },
      Partner = { Species="eevee", Form=0, Skin="normal", Gender=1 },
      DemoComplete = false,
    }
  end
  
  SV.test_grounds.Starter = { Species="pikachu", Form=0, Skin="normal", Gender=2 }
  SV.test_grounds.Partner = { Species="eevee", Form=0, Skin="normal", Gender=1 }
  
  if SV.missions == nil then
    SV.missions =
	{
	  Missions = { },
	  FinishedMissions = { },
	}
  end
  
  
  -- end
  if SV.unlocked_trades ~= nil then
  else
    SV.unlocked_trades = {}
  end
  
  if SV.General.Starter == nil then
    SV.General.Starter = MonsterID("bulbasaur", 0, "normal", Gender.Male)
  end
  
  local oldVersion = _DATA.Save.GameVersion
  if oldVersion.Major <= 0 and oldVersion.Minor <= 6 and oldVersion.Build <= 7 then
    _DATA.Save:DeleteOutdatedAssets(RogueEssence.Data.DataManager.DataType.Item)
  end
  if oldVersion.Major <= 0 and oldVersion.Minor <= 7 and oldVersion.Build <= 2 then
  
  SV.base_camp.FerryUnlocked = false
  SV.base_camp.FerryIntroduced = false
  
  SV.magnagate =
  {
    cards = 0,
    portal = false
  }

  SV.shimmer_bay = 
  {
    TookTreasure  = false
  }

  SV.manaphy_egg = 
  {
    Taken = false,
    ExpositionComplete = false,
    Hatched = false
  }

  SV.roaming_legends =
  {
    Raikou = false,
    Entei = false,
    Suicune = false,
    Celebi = false,
    Darkrai = false
  }


  SV.sleeping_caldera = 
  {
    TookTreasure  = false,
    GotHeatran = false
  }
  
  SV.dex = {
    CurrentRewardIdx = 1
  }
	
  SV.moonlit_end = 
  {
    ExpositionComplete  = false
  }

  GAME:UnlockDungeon('fertile_valley')
  end
  
  PrintInfo("=>> Loaded version")
end

--[[---------------------------------------------------------------
    DebugTools:OnLossPenalty()
      Called when the player fails a dungeon in main progress
  ---------------------------------------------------------------]]
function DebugTools:OnLossPenalty(save) 
  assert(self, 'DebugTools:OnLossPenalty() : self is null!')
 
  --remove money
  save.ActiveTeam.Money = 0
  local inv_count = save.ActiveTeam:GetInvCount() - 1

  --remove bag items
  for i = inv_count, 0, -1 do
    local entry = _DATA:GetItem(save.ActiveTeam:GetInv(i).ID)
    if not entry.CannotDrop then
      save.ActiveTeam:RemoveFromInv(i)
    end
  end
  
  --remove equips
  local player_count = save.ActiveTeam.Players.Count
  for i = 0, player_count - 1, 1 do 
    local player = save.ActiveTeam.Players[i]
    if player.EquippedItem.ID ~= '' and player.EquippedItem.ID ~= nil then 
      local entry = _DATA:GetItem(player.EquippedItem.ID)
      if not entry.CannotDrop then
         player:SilentDequipItem()
      end
    end
  end
end

---Summary
-- Subscribe to all channels this service wants callbacks from
function DebugTools:Subscribe(med)
  med:Subscribe("DebugTools", EngineServiceEvents.Init,                function() self.OnInit(self) end )
  med:Subscribe("DebugTools", EngineServiceEvents.Deinit,              function() self.OnDeinit(self) end )
  med:Subscribe("DebugTools", EngineServiceEvents.MenuButtonPressed,        function() self.OnMenuButtonPressed() end )
  med:Subscribe("DebugTools", EngineServiceEvents.OthersMenuButtonPressed,        function() self.OnOthersMenuButtonPressed() end )
  med:Subscribe("DebugTools", EngineServiceEvents.NewGame,        function() self.OnNewGame(self) end )
  med:Subscribe("DebugTools", EngineServiceEvents.UpgradeSave,        function() self.OnUpgrade(self) end )
  med:Subscribe("DebugTools", EngineServiceEvents.LossPenalty,        function(_, args) self.OnLossPenalty(self, args[0]) end )
--  med:Subscribe("DebugTools", EngineServiceEvents.GraphicsUnload,      function() self.OnGraphicsUnload(self) end )
--  med:Subscribe("DebugTools", EngineServiceEvents.Restart,             function() self.OnRestart(self) end )
end

---Summary
-- un-subscribe to all channels this service subscribed to
function DebugTools:UnSubscribe(med)
end

---Summary
-- The update method is run as a coroutine for each services.
function DebugTools:Update(gtime)
--  while(true)
--    coroutine.yield()
--  end
end

--Add our service
SCRIPT:AddService("DebugTools", DebugTools:new())
return DebugTools