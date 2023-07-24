--[[
    Example Service
    
    This is an example to demonstrate how to use the BaseService class to implement a game service.
    
    **NOTE:** After declaring you service, you have to include your package inside the main.lua file!
]]--
require 'common'
require 'services.baseservice'

--Declare class UpgradeTools
local UpgradeTools = Class('UpgradeTools', BaseService)


--[[---------------------------------------------------------------
    UpgradeTools:initialize()
      UpgradeTools class constructor
---------------------------------------------------------------]]
function UpgradeTools:initialize()
  BaseService.initialize(self)
  PrintInfo('UpgradeTools:initialize()')
end

--[[---------------------------------------------------------------
    UpgradeTools:__gc()
      UpgradeTools class gc method
      Essentially called when the garbage collector collects the service.
  ---------------------------------------------------------------]]
function UpgradeTools:__gc()
  PrintInfo('*****************UpgradeTools:__gc()')
end

--[[---------------------------------------------------------------
    UpgradeTools:OnUpgrade()
      When a save file in an old version is loaded this is called!
---------------------------------------------------------------]]
function UpgradeTools:OnUpgrade()
  assert(self, 'UpgradeTools:OnUpgrade() : self is null!')
  
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
  
  if SV.base_camp.FerryUnlocked == nil then
    SV.base_camp.FerryUnlocked = false
    SV.base_camp.FerryIntroduced = false
  end
  
  if SV.base_town.ValueTradeState == nil then
    SV.base_town.ValueTradeState = 0
	ValueTradeItem = ""
  end
  
  
  if SV.magnagate == nil then
    SV.magnagate =
    {
      cards = 0,
      portal = false
    }
  end
  
  if SV.shimmer_bay == nil then
    SV.shimmer_bay = 
    {
      TookTreasure  = false
    }
  end
  
  if SV.manaphy_egg == nil then
    SV.manaphy_egg = 
    {
      Taken = false,
      ExpositionComplete = false,
      Hatched = false
    }
  end
  
  if SV.roaming_legends == nil then
    SV.roaming_legends =
    {
      Raikou = false,
      Entei = false,
      Suicune = false,
      Celebi = false,
      Darkrai = false
    }
  end
  
  if SV.sleeping_caldera == nil then
    SV.sleeping_caldera = 
    {
      TookTreasure  = false,
      GotHeatran = false
    }
  end
  
  if SV.dex == nil then
    SV.dex = {
      CurrentRewardIdx = 1
    }
  end
  
  if SV.moonlit_end == nil then
    SV.moonlit_end = 
    {
      ExpositionComplete  = false
    }
  end
  
  
  if SV.cliff_camp.ExpositionComplete == true then
    GAME:UnlockDungeon('fertile_valley')
  end
  
  if SV.base_camp.CenterStatueDate == nil then
	SV.base_camp.CenterStatueDate = ""
	SV.base_camp.LeftStatueDate = ""
	SV.base_camp.RightStatueDate = ""
  end
  
  if SV.base_town.ValueTraded == nil then
	SV.base_town.ValueTradeItem = ""
	SV.base_town.ValueTraded = false
  end
  
  
  PrintInfo("=>> Loaded version")
end

--[[---------------------------------------------------------------
    UpgradeTools:OnLossPenalty()
      Called when the player fails a dungeon in main progress
  ---------------------------------------------------------------]]
function UpgradeTools:OnLossPenalty(save) 
  assert(self, 'UpgradeTools:OnLossPenalty() : self is null!')
 
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
function UpgradeTools:Subscribe(med)
  med:Subscribe("UpgradeTools", EngineServiceEvents.UpgradeSave,        function() self.OnUpgrade(self) end )
end

---Summary
-- un-subscribe to all channels this service subscribed to
function UpgradeTools:UnSubscribe(med)
end

---Summary
-- The update method is run as a coroutine for each services.
function UpgradeTools:Update(gtime)
--  while(true)
--    coroutine.yield()
--  end
end

--Add our service
SCRIPT:AddService("UpgradeTools", UpgradeTools:new())
return UpgradeTools