--[[
    Example Service
    
    This is an example to demonstrate how to use the BaseService class to implement a game service.
    
    **NOTE:** After declaring you service, you have to include your package inside the main.lua file!
]]--
require 'common'
require 'services.baseservice'
require 'mission_gen'
require 'recruit_list'

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
--function DebugTools:__gc()
--  PrintInfo('*****************DebugTools:__gc()')
--end

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
  
  --Custom menu stuff for jobs. 
  --Check if we're in a dungeon or not. Only do main menu changes outside of a dungeon. Do others menu changes in dungeon only.
  if RogueEssence.GameManager.Instance.CurrentScene == RogueEssence.Dungeon.DungeonScene.Instance then
    DebugTools.MainMenu.Choices:RemoveAt(5)
    DebugTools.MainMenu.Choices:Insert(5, RogueEssence.Menu.MenuTextChoice("Others", function () _MENU:AddMenu(DebugTools:CustomDungeonOthersMenu(), false) end))
  else--not in a dungeon 
	--Add Job List option
	local taken_count = MISSION_GEN.GetTakenCount()
	local job_list_color = Color.Red
	if taken_count > 0 then
		job_list_color = Color.White
	end 
	
	DebugTools.MainMenu.Choices:Insert(4, RogueEssence.Menu.MenuTextChoice("Job List", function () _MENU:AddMenu(BoardMenu:new(COMMON.MISSION_BOARD_TAKEN, nil, DebugTools.MainMenu).menu, false) end, taken_count > 0, job_list_color))
 
  end
 
  DebugTools.MainMenu:SetupTitleAndSummary()
  
  DebugTools.MainMenu:InitMenu()
  TASK:WaitTask(_MENU:ProcessMenuCoroutine(DebugTools.MainMenu))
end



function DebugTools:CustomDungeonOthersMenu()
    local menu = RogueEssence.Menu.OthersMenu()
    menu:SetupChoices();
	if RogueEssence.GameManager.Instance.CurrentScene == RogueEssence.Dungeon.DungeonScene.Instance then
		menu.Choices:Add(RogueEssence.Menu.MenuTextChoice("Mission Objectives", function () _MENU:AddMenu(DungeonJobList:new().menu, false) end))
		-- add recruitment search menu only if assembly is unlocked
		if SV.Chapter4 and SV.Chapter4.FinishedAssemblyIntro then
			menu.Choices:Add(RogueEssence.Menu.MenuTextChoice(RogueEssence.StringKey("MENU_RECRUITMENT"):ToLocal(), function () _MENU:AddMenu(RecruitmentListMenu:new().menu, false) end))
		end
	end
	menu:InitMenu();
    return menu
end


--[[---------------------------------------------------------------
    DebugTools:OnNewGame()
      When a debug save file is loaded this is called!
---------------------------------------------------------------]]
function DebugTools:OnNewGame()
  assert(self, 'DebugTools:OnNewGame() : self is null!')
end




--Reset most variables to their default if they don't exist
--This needs to be upkept whenever I add new variables to the game.
--Yanderedev ftw
function DebugTools:OnUpgrade()
  assert(self, 'DebugTools:OnUpgrade() : self is null!')
  
  PrintInfo("=>> Loading version")
 
 if SV.DestinationFloorNotified == nil then SV.DestinationFloorNotified = false end
 if SV.MonsterHouseMessageNotified == nil then SV.MonsterHouseMessageNotified = false end
 if SV.OutlawDefeated == nil then SV.OutlawDefeated = false end
 if SV.OutlawGoonsDefeated == nil then SV.OutlawGoonsDefeated = false end
 if SV.OutlawItemPickedUp == nil then SV.OutlawItemPickedUp = false end

 if SV.TakenBoard == nil then
	SV.TakenBoard =
	{
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = "",
			BackReference = -1
		},
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = "",
			BackReference = -1
		},	
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = "",
			BackReference = -1
		},	
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = "",
			BackReference = -1
		},	
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = "",
			BackReference = -1
		},	
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = "",
			BackReference = -1
		},
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = "",
			BackReference = -1
		},	
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = "",
			BackReference = -1
		}

	}
	end 
	
	if SV.MissionBoard == nil then
		SV.MissionBoard =
		{
			{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = ""
		},
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = ""
		},	
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = ""
		},	
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = ""
		},	
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = ""
		},	
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = ""
		},
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = ""
		},	
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = ""
		}

	}
	end
	
	if SV.OutlawBoard == nil then
		SV.OutlawBoard =
		{
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = ""
		},
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = ""
		},	
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = ""
		},	
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = ""
		},	
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = ""
		},	
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = ""
		},
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = ""
		},	
		{
			Client = "",
			Target = "",
			Flavor = "",
			Title = "",
			Zone = "",
			Segment = -1,
			Floor = -1,
			Reward = "",
			Type = -1,
			Completion = -1,
			Taken = false,
			Difficulty = "",
			Item = "",
			Special = "",
			ClientGender = -1,
			TargetGender = -1,
			BonusReward = ""
		}
	}
	end
 
  PrintInfo("=>> Loaded version")
end

--[[---------------------------------------------------------------
    DebugTools:OnLossPenalty()
      Called when the player fails a dungeon in main progress
  ---------------------------------------------------------------]]
function DebugTools:OnLossPenalty(save) 
  assert(self, 'DebugTools:OnLossPenalty() : self is null!')
	
end

---Summary
-- Subscribe to all channels this service wants callbacks from
function DebugTools:Subscribe(med)
  med:Subscribe("DebugTools", EngineServiceEvents.Init,                function() self.OnInit(self) end )
  med:Subscribe("DebugTools", EngineServiceEvents.Deinit,              function() self.OnDeinit(self) end )
  med:Subscribe("DebugTools", EngineServiceEvents.MenuButtonPressed,        function() self.OnMenuButtonPressed() end )
  med:Subscribe("DebugTools", EngineServiceEvents.NewGame,        function() self.OnNewGame(self) end )
  med:Subscribe("DebugTools", EngineServiceEvents.UpgradeSave,        function() self.OnUpgrade(self) end )
  med:Subscribe("DebugTools", EngineServiceEvents.LossPenalty,        function(_, args) self.OnLossPenalty(self, args[0]) end )
	-- med:Subscribe("DebugTools", EngineServiceEvents.DungeonMapInit,        function(_, args) self.OnDungeonMapInit(self, args[0], args[1]) end )
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