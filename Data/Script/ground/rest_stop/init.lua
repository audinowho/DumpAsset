require 'common'

local rest_stop = {}
local MapStrings = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function rest_stop.Init(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_rest_stop")
  MapStrings = COMMON.AutoLoadLocalizedStrings()
  COMMON.RespawnAllies()
end

function rest_stop.Enter(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine

  SV.checkpoint = 
  {
    Zone    = 'guildmaster_island', Segment  = -1,
    Map  = 6, Entry  = 1
  }
  
  --when arriving the first time, play this cutscene
  if SV.rest_stop.BossPhase == 0 then
    rest_stop.BeginExposition(false)
  elseif SV.rest_stop.BossPhase == 1 then
    rest_stop.BeginExposition(true)
  elseif SV.rest_stop.BossPhase == 3 then
    rest_stop.Steelix_Success()
	SV.rest_stop.BossPhase = 4
    SV.rest_stop.ExpositionComplete = true
  else
    rest_stop.SetupNpcs()
    GAME:FadeIn(20)
  end
end

function rest_stop.Update(map, time)
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------

function rest_stop.SetupNpcs()
  --GROUND:Unhide("NPC_1")
  --GROUND:Unhide("NPC_2")
  
  if SV.supply_corps.Status < 10 then
    --pass
  elseif SV.supply_corps.Status <= 11 then
    GROUND:Unhide("NPC_Storehouse")
  elseif SV.supply_corps.Status <= 15 then
    GROUND:Unhide("NPC_Storehouse")
    GROUND:Unhide("NPC_Carry")
    GROUND:Unhide("NPC_Deliver")
  elseif SV.supply_corps.Status >= 20 then
    --cycle appearances
	if SV.supply_corps.ManagerCycle == 0 or SV.supply_corps.ManagerCycle == 6 then
	
	else
	  if SV.supply_corps.CarryCycle == 4 then
	    GROUND:Unhide("NPC_Carry")
	  end
	  if SV.supply_corps.DeliverCycle == 4 then
	    GROUND:Unhide("NPC_Deliver")
	  end
	  if SV.supply_corps.ManagerCycle == 4 then
	    GROUND:Unhide("NPC_Storehouse")
	  end
	end
  end
end

function rest_stop.BeginExposition(shortened)
  
  UI:WaitShowTitle(GAME:GetCurrentGround().Name:ToLocal(), 20)
  GAME:WaitFrames(30)
  UI:WaitHideTitle(20)
  GAME:FadeIn(20)
  
  
  --camerawork
  --walk in
  
  --bosses appear
  GROUND:Unhide("Boss_1")
  GROUND:Unhide("Boss_2")
  GROUND:Unhide("Boss_3")
  GROUND:Unhide("Boss_4")
  GROUND:Unhide("Boss_5")
  GROUND:Unhide("Boss_6")
  
  SOUND:PlayBGM("A13. Threat.ogg", false)
  
  --bosses talk
  UI:ResetSpeaker()
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Boss_Line_001']))
  if shortened then
    UI:WaitShowDialogue("Return version")
  end
  
  --battle!
  SV.rest_stop.BossPhase = 1
  COMMON.BossTransition()
  GAME:EnterDungeon('guildmaster_island', 0, 6, 0, RogueEssence.Data.GameProgress.DungeonStakes.Progress, true, true)
end

function rest_stop.Steelix_Success()
  
  
  GROUND:Unhide("Boss_1")
  GROUND:Unhide("Boss_2")
  GROUND:Unhide("Boss_3")
  GROUND:Unhide("Boss_4")
  GROUND:Unhide("Boss_5")
  GROUND:Unhide("Boss_6")
  
  GAME:FadeIn(20)
  
  UI:ResetSpeaker()
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Boss_Line_Success_001']))
  
  GROUND:Hide("Boss_1")
  GROUND:Hide("Boss_2")
  GROUND:Hide("Boss_3")
  GROUND:Hide("Boss_4")
  GROUND:Hide("Boss_5")
  GROUND:Hide("Boss_6")
  
  GAME:UnlockDungeon('thunderstruck_pass')
  GAME:UnlockDungeon('veiled_ridge')
end

--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------

function rest_stop.NPC_Storehouse_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  
  if SV.supply_corps.Status <= 10 then
    UI:WaitShowDialogue("Thanks for discovering this cave.  We're putting supplies here.")
	SV.supply_corps.Status = 11
  elseif SV.supply_corps.Status == 11 then
    UI:WaitShowDialogue("Thanks for discovering this cave.  We're putting supplies here.")
  elseif SV.supply_corps.Status == 12 then
    local questname = "OutlawMountain1"
    local quest = SV.missions.Missions[questname]
    if quest == nil then
      UI:WaitShowDialogue("Some thugs beat our guys up in Copper Quarry!  Teach them a lesson!")
	  --add the quest
	  SV.missions.Missions[questname] = { Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_OUTLAW, DestZone = "copper_quarry", DestSegment = 0, DestFloor = 4, TargetSpecies = RogueEssence.Dungeon.MonsterID("weavile", 0, "normal", Gender.Male) }
	elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue("Some thugs beat our guys up in Copper Quarry!  Teach them a lesson! (You already have the quest)")
	else
	  UI:WaitShowDialogue("Thanks for getting back the supplies!  Have a reward!")
	  --give reward
      local receive_item = RogueEssence.Dungeon.InvItem("tm_sludge_bomb")
      COMMON.GiftItem(player, receive_item)
	  --complete mission and move to done
	  quest.Complete = COMMON.MISSION_ARCHIVED
	  SV.missions.FinishedMissions[questname] = quest
	  SV.missions.Missions[questname] = nil
	  SV.supply_corps.Status = 13
	end
  elseif SV.supply_corps.Status == 13 then
    UI:WaitShowDialogue("Thanks for protecting us!")
  elseif SV.supply_corps.Status == 14 then
    UI:WaitShowDialogue("We're getting ready to go to snow camp.")
	SV.supply_corps.Status = 15
  elseif SV.supply_corps.Status == 15 then
    UI:WaitShowDialogue("We'll get to snow camp in a day probably.")
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue("I'm on my routine route in cave camp!")
  end
end

function rest_stop.NPC_Carry_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)
  
  if SV.supply_corps.Status == 12 then
    local questname = "OutlawMountain1"
    local quest = SV.missions.Missions[questname]
    if quest == nil then
      UI:WaitShowDialogue("(Carry) Some thugs beat our guys up in Copper Quarry!  Teach them a lesson!")
	elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue("Some thugs beat our guys up in Copper Quarry!  Teach them a lesson! (You already have the quest)")
	else
	  UI:WaitShowDialogue("(Carry) Thanks for getting back the supplies!")
	end
  elseif SV.supply_corps.Status == 13 then
    UI:WaitShowDialogue("(Carry) Thanks for protecting us!")
  elseif SV.supply_corps.Status == 14 then
    UI:WaitShowDialogue("(Carry) We're getting ready to go to snow camp.")
	SV.supply_corps.Status = 15
  elseif SV.supply_corps.Status == 15 then
    UI:WaitShowDialogue("(Carry) We'll get to snow camp in a day probably.")
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue("(Carry) I'm on my routine route in cave camp!")
  end
  
end

function rest_stop.NPC_Deliver_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)
  
  if SV.supply_corps.Status == 12 then
    local questname = "OutlawMountain1"
    local quest = SV.missions.Missions[questname]
    if quest == nil then
      UI:WaitShowDialogue("(Deliver) Some thugs beat our guys up in Copper Quarry!  Teach them a lesson!")
	elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue("Some thugs beat our guys up in Copper Quarry!  Teach them a lesson! (You already have the quest)")
	else
	  UI:WaitShowDialogue("(Deliver) Thanks for getting back the supplies!")
	end
  elseif SV.supply_corps.Status == 13 then
    UI:WaitShowDialogue("(Deliver) Thanks for protecting us!")
  elseif SV.supply_corps.Status == 14 then
    UI:WaitShowDialogue("(Deliver) We're getting ready to go to snow camp.")
	SV.supply_corps.Status = 15
  elseif SV.supply_corps.Status == 15 then
    UI:WaitShowDialogue("(Deliver) We'll get to snow camp in a day probably.")
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue("(Deliver) I'm on my routine route in cave camp!")
  end
end

function rest_stop.North_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local dungeon_entrances = { 'thunderstruck_pass', 'veiled_ridge', 'snowbound_path', 'treacherous_mountain', 'hope_road', 'cave_of_whispers' }
  --also dungeon 21: royal halls, is accessible by ???
  --also dungeon 22: cave of solace, is accessible by having 8 key items
  local ground_entrances = {{Flag=SV.final_stop.ExpositionComplete,Zone='guildmaster_island',ID=7,Entry=0},
  {Flag=SV.guildmaster_summit.GameComplete,Zone='guildmaster_island',ID=8,Entry=0}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end

function rest_stop.South_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local dungeon_entrances = { }
  local ground_entrances = {{Flag=true,Zone='guildmaster_island',ID=1,Entry=3},
  {Flag=SV.forest_camp.ExpositionComplete,Zone='guildmaster_island',ID=3,Entry=2},
  {Flag=SV.cliff_camp.ExpositionComplete,Zone='guildmaster_island',ID=4,Entry=2},
  {Flag=SV.canyon_camp.ExpositionComplete,Zone='guildmaster_island',ID=5,Entry=2}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end

function rest_stop.Assembly_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  COMMON.ShowTeamAssemblyMenu(obj, COMMON.RespawnAllies)
end

function rest_stop.Storage_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON:ShowTeamStorageMenu()
end




function rest_stop.Teammate1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

function rest_stop.Teammate2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

function rest_stop.Teammate3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end


return rest_stop