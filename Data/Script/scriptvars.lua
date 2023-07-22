--[[
    scriptvars.lua
      This file contains all the default values for the script variables. AKA on a new game this file is loaded!
      Script variables are stored in a table  that gets saved when the game is saved.
      Its meant to be used for scripters to add data to be saved and loaded during a playthrough.
      
      You can simply refer to the "SV" global table like any other table in any scripts!
      You don't need to write a default value in this lua script to add a new value.
      However its good practice to set a default value when you can!
      
      It is important to stress that this file initializes the SV table ONCE when the player begins a new save file, and NEVER EVER again.
      This means that edits on this file will NOT be added on the script variables of an already existing file!
      To upgrade existing script variables, use the OnUpgrade in script services.  Example found in Data/Script/services/debug_tools/init.lua
      
    --Examples:
    SV.SomeVariable = "Smiles go for miles!"
    SV.AnotherVariable = 2526
    SV.AnotherVariable = { something={somethingelse={} } }
    SV.AnotherVariable = function() PrintInfo('lmao') end
]]--

-----------------------------------------------
-- Services Defaults
-----------------------------------------------
SV.Services =
{
  --Anything that applies to services should be put in here, or assigned to this or a subtable of this in the service's definition script
}

-----------------------------------------------
-- General Defaults
-----------------------------------------------
SV.General =
{
  Rescue = nil,
  Starter = MonsterID("missingno", 0, "normal", Gender.Genderless)
  --Anything that applies to more than a single level, and that is too small to make a sub-table for, should be put in here ideally, or a sub-table of this
}

SV.checkpoint = 
{
  Zone    = 'guildmaster_island', Segment  = -1,
  Map  = 1, Entry  = 0
}


SV.adventure = 
{
  Thief    = false
}

SV.missions =
{
  Missions = { },
  FinishedMissions = { },
}

SV.magnagate =
{
  cards = 0,
  portal = false
}

SV.base_shop = {
	{ Index = "food_apple", Amount = 0, Price = 50},
	{ Index = "food_apple_big", Amount = 0, Price = 150},
	{ Index = "food_banana", Amount = 0, Price = 500},
	{ Index = "food_chestnut", Amount = 0, Price = 80},
	{ Index = "berry_leppa", Amount = 0, Price = 80}
}
SV.base_trades = {
	{ Item="xcl_family_bulbasaur_02", ReqItem={"",""}},
	{ Item="xcl_family_charmander_02", ReqItem={"",""}},
	{ Item="xcl_family_squirtle_02", ReqItem={"",""}}
}

SV.unlocked_trades = {
}

-----------------------------------------------
-- Level Specific Defaults
-----------------------------------------------
SV.test_grounds =
{
  SpokeToPooch = false,
  AcceptedPooch = false,
  Starter = { Species="pikachu", Form=0, Skin="normal", Gender=2 },
  Partner = { Species="eevee", Form=0, Skin="normal", Gender=1 },
  DemoComplete = false,
  Tileset = 0,
}

SV.dex = {
  CurrentRewardIdx = 1
}

SV.roaming_legends =
{
  Raikou = false,
  Entei = false,
  Suicune = false,
  Celebi = false,
  Darkrai = false
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

SV.sleeping_caldera = 
{
  TookTreasure  = false,
  GotHeatran = false
}

SV.base_camp = 
{
  IntroComplete    = false,
  ExpositionComplete  = false,
  FirstTalkComplete  = false,
  FoodIntro  = false,
  FerryUnlocked  = false,
  FerryIntroduced  = false,
  CenterStatueDate  = "",
  LeftStatueDate  = "",
  RightStatueDate  = ""
}

SV.base_town = 
{
  Song    = "A02. Base Town.ogg",
  ValueTradeItem = "",
  ValueTraded = false
}

SV.luminous_spring = 
{
  Returning    = false
}

SV.forest_camp = 
{
  ExpositionComplete  = false
}

SV.cliff_camp = 
{
  ExpositionComplete  = false,
  TeamRetreatIntro = false,
  TeamUndergrowthIntro = false,
  RivalEarlyIntro = false
}

SV.canyon_camp = 
{
  ExpositionComplete  = false,
  ShinyIntro = false
}

SV.rest_stop = 
{
  ExpositionComplete  = false
}

SV.final_stop = 
{
  ExpositionComplete  = false
}

SV.guildmaster_summit = 
{
  ExpositionComplete  = false,
  BattleComplete = false
}

SV.moonlit_end = 
{
  ExpositionComplete  = false,
  BattleComplete  = false,
  BattleFailed  = false,
  ReturnVisit  = false
}

SV.garden_end = 
{
  ExpositionComplete  = false
}

----------------------------------------------