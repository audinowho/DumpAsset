--[[
    Example Service
    
    This is an example to demonstrate how to use the BaseService class to implement a game service.
    
    **NOTE:** After declaring you service, you have to include your package inside the main.lua file!
]]--
require 'origin.common'
require 'origin.services.baseservice'

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
	  TODO: Currently causes issues.  debug later.
  ---------------------------------------------------------------]]
--function UpgradeTools:__gc()
--  PrintInfo('*****************UpgradeTools:__gc()')
--end

--[[---------------------------------------------------------------
    UpgradeTools:OnUpgrade()
      When a save file in an old version is loaded this is called!
---------------------------------------------------------------]]
function UpgradeTools:OnUpgrade()
  assert(self, 'UpgradeTools:OnUpgrade() : self is null!')
  
  local old_ver = _DATA.Save:GetVersion(System.Guid.Empty)
  local new_ver = RogueEssence.PathMod.GetVersion(System.Guid.Empty)
  PrintInfo("=>> Upgrading version " .. old_ver:ToString() .. " to " .. new_ver:ToString())
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
  
  
  if SV.magnagate == nil or SV.magnagate.Cards == nil then
    SV.magnagate =
    {
      Cards = 0
    }
  end
  
  if SV.castaway_cave == nil then
    SV.castaway_cave = 
    {
      TookTreasure  = false,
      TreasureTaken  = false
    }
  end
  
  if SV.manaphy_egg == nil then
    SV.manaphy_egg = 
    {
      ExpositionComplete = false,
      Hatched = false
    }
  end
  
  if SV.castaway_cave.TreasureTaken == nil and SV.manaphy_egg.Taken ~= nil then
    SV.castaway_cave.TreasureTaken = SV.manaphy_egg.Taken
  end
  
  if SV.roaming_legends == nil then
    SV.roaming_legends =
    {
      Raikou = false,
      Entei = false,
      Suicune = false,
      Latios = false,
      Latias = false,
      Darkrai = false
    }
  end
  if SV.roaming_legends.Latios == nil then
    SV.roaming_legends.Latios = false
    SV.roaming_legends.Latias = false
  end
  
  
  if SV.secret == nil then
    SV.secret =
    {
      New = false,
      Time = false,
      Wish = false
    }
  end
  
  
  if SV.sleeping_caldera == nil then
    SV.sleeping_caldera = 
    {
      TookTreasure  = false,
      TreasureTaken  = false,
      GotHeatran = false
    }
  end
  
  if SV.geode_crevice == nil then
    SV.geode_crevice = 
    {
      TreasureTaken  = false
    }
  end
  
  if SV.sleeping_caldera.TreasureTaken == nil then
    SV.sleeping_caldera.TreasureTaken = false
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
  
  if SV.base_town.JuiceShop == nil then
	SV.base_town.JuiceShop = 0
  end
  

  if SV.ambush_forest == nil then
    SV.ambush_forest = 
    {
      BossPhase  = 0
    }
  end
  
  if SV.treacherous_mountain == nil then
    SV.treacherous_mountain = 
    {
      BossPhase  = 0
    }
  end
  
  if SV.rest_stop.BossPhase == nil then
    SV.rest_stop.BossPhase = 0
  end
  
  if SV.rest_stop.DaysSinceBoss == nil then
    SV.rest_stop.DaysSinceBoss = 0
	SV.rest_stop.BossSolved = false
  end

  if SV.forest_camp.SnorlaxPhase == nil then
    SV.forest_camp.SnorlaxPhase = 0
  end

  if SV.forest_camp.TeamRetreatIntro == nil then
    SV.forest_camp.TeamRetreatIntro = false
  end

  if SV.guildmaster_summit.BossPhase == nil then
    SV.guildmaster_summit.BossPhase = 0
	SV.guildmaster_summit.GameComplete = false
	SV.guildmaster_summit.ClearedFromTrail = false
  end

  if SV.guildmaster_trail == nil then
	SV.guildmaster_trail = 
	{
	  FloorsCleared = 0,
	  Rewarded  = false
	}
  end

  if SV.guild_hut == nil then
	SV.guild_hut = 
	{
	  ExpositionComplete = false,
	  TookCard  = false,
	  Portal  = false,
      BookPhase = 0
	}
  end

  if SV.supply_corps == nil then
	SV.supply_corps =
	{
	  Status = 0,
	  DaysSinceCheckpoint = 0,
	  CarryCycle = 0,
	  DeliverCycle = 0,
	  ManagerCycle = 0
	}
  end

  if SV.team_hunter == nil then
	SV.team_hunter =
	{
	  Status = 0,
	  SpokenTo = false,
	  DaysSinceCheckpoint = 0,
	  Cycle = 0
	}
  end

  if SV.town_elder == nil then
	SV.town_elder =
	{
	  Status = 0,
	  SpokenTo = false,
	  DaysSinceCheckpoint = 0,
	  Cycle = 0
	}
  end

  if SV.forest_child == nil then
	SV.forest_child =
	{
	  Status = 0,
	  SpokenTo = false,
	  DaysSinceCheckpoint = 0
	}
  end

  if SV.team_catch == nil then
	SV.team_catch =
	{
	  Status = 0,
	  SpokenTo = false,
	  DaysSinceCheckpoint = 0,
	  Cycle = 0
	}
  end

  if SV.team_rivals == nil then
	SV.team_rivals =
	{
	  Status = 0,
	  SpokenTo = false,
	  DaysSinceCheckpoint = 0,
	  Cycle = 0
	}
  end


  if SV.team_kidnapped == nil then
	SV.team_kidnapped =
	{
	  Status = 0,
	  SpokenTo = false,
	  DaysSinceCheckpoint = 0,
	  Cycle = 0
	}
  end


  if SV.team_retreat == nil then
	SV.team_retreat =
	{
      Intro = false
	}
  end
  
  if SV.team_retreat.Status == nil then
	SV.team_retreat =
	{
	  Status = 0,
	  SpokenTo = false,
	  DaysSinceCheckpoint = 0,
	  
	  Cycle = 0
	}
  end

  if SV.team_meditate == nil then
	SV.team_meditate =
	{
	  Status = 0,
	  SpokenTo = false,
	  DaysSinceCheckpoint = 0,
	  
	  Cycle = 0
	}
  end

  if SV.team_steel == nil then
	SV.team_steel =
	{
	  Argued = false,
	  DaysSinceArgue = 0,
	  Rescued = false
	}
  end

  if SV.team_solo == nil then
	SV.team_solo =
	{
	  Status = 0,
	  SpokenTo = false,
	  DaysSinceCheckpoint = 0,
	  Cycle = 0
	}
  end

  if SV.team_psychic == nil then
	SV.team_psychic =
	{
	  Status = 0,
	  SpokenTo = false,
	  DaysSinceCheckpoint = 0,
	  Cycle = 0
	}
  end

  if SV.team_dark == nil then
	SV.team_dark =
	{
	  Status = 0,
	  SpokenTo = false,
	  DaysSinceCheckpoint = 0,
	  Cycle = 0
	}
  end
  
  if SV.team_dark.Status == nil then
    if SV.team_psychic.Status == 3 then
	  SV.team_dark.Status = 1
	else
      SV.team_dark.Status = 0
	end
  end

  if SV.team_dragon == nil then
	SV.team_dragon =
	{
	  Status = 0,
	  SpokenTo = false,
	  DaysSinceCheckpoint = 0,
	  Cycle = 0
	}
  end
  
  if SV.final_stop.DragonPhase == nil then
    SV.final_stop.DragonPhase = 0
  end


  if SV.team_firecracker == nil then
	SV.team_firecracker =
	{
		Status = 0,
		SpokenTo = false,
		DaysSinceCheckpoint = 0,
		Cycle = 0
	}
  end

  
  if SV.family == nil then
	SV.family =
	{
	  SisterActiveDays = 0,
	  Sister = false,
	  MotherActiveDays = 0,
	  Mother = false,
	  FatherActiveDays = 0,
	  Father = false,
	  BrotherActiveDays = 0,
	  Brother = false,
	  GrandmaActiveDays = 0,
	  Grandma = false,
	  PetActiveDays = 0,
	  Pet = false
	}
  end
  
  if SV.missions.FinishedMissions["EscortSister"] ~= nil and SV.family.Sister ~= true then
    SV.family.Sister = true
  end
  
  if SV.missions.FinishedMissions["EscortMother"] ~= nil and SV.family.Mother ~= true then
    SV.family.Mother = true
  end
  
  if SV.missions.FinishedMissions["EscortFather"] ~= nil and SV.family.Father ~= true then
    SV.family.Father = true
  end
  
  if SV.missions.FinishedMissions["EscortBrother"] ~= nil and SV.family.Brother ~= true then
    SV.family.Brother = true
  end
  
  if SV.missions.FinishedMissions["EscortPet"] ~= nil and SV.family.Pet ~= true then
    SV.family.Pet = true
  end
  
  if SV.missions.FinishedMissions["EscortGrandma"] ~= nil and SV.family.Grandma ~= true then
    SV.family.Grandma = true
  end
  
  if old_ver < System.Version("0.8.10") then
    SV.missions.Missions = {}
  end
  
  if SV.family.BrotherActiveDays == nil then
    SV.family.BrotherActiveDays = 0
	SV.family.Brother = false
  end
  
  if SV.family.TalkedReturn == nil then
    SV.family.TalkedReturn = false
	SV.family.Returned = false
  end
  
  if SV.base_town.FreeRelearn == nil then
    SV.base_town.FreeRelearn = false
  end
  
  if SV.base_town.TutorOpen == nil then
    SV.base_town.TutorOpen = false
  end
  
  if SV.base_town.TutorMoves == nil then
    SV.base_town.TutorMoves = {}
  end
  
  if SV.StarterTutor == nil then
	SV.StarterTutor =
	{
		Complete = false,
		Evolved = false,
		--go on a cycle after tutoring?
		--may appear in cave camp, where he alludes to the elemental hyper beam tutors' locations
	}
  end
  
  if SV.adventure.Tutors == nil then
    SV.adventure.Tutors = { }
  end
  
  if SV.Experimental == nil then
    SV.Experimental = false
  end
  
  PrintInfo("=>> Loaded version")
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

--Add our service
SCRIPT:AddService("UpgradeTools", UpgradeTools:new())
return UpgradeTools