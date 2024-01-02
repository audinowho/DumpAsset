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
  
  
  if SV.team_rivals.Status == 4 then
    GROUND:Unhide("Rival_1")
	GROUND:Unhide("Rival_2")
  elseif SV.team_rivals.Status == 5 then
    GROUND:Unhide("Rival_1")
	local questname = "QuestRival2"
    local quest = SV.missions.Missions[questname]
	if quest ~= nil and quest.Complete == COMMON.MISSION_COMPLETE then
	  GROUND:Unhide("Rival_2")
	end
  elseif SV.team_rivals.Status == 6 then
    GROUND:Unhide("Rival_1")
	GROUND:Unhide("Rival_2")
  elseif SV.team_rivals.Status == 8 then
    -- TODO cycling
  end


  if SV.team_psychic.Status == 2 then
    GROUND:Unhide("NPC_Strategy")
    GROUND:Unhide("NPC_Goals")
  elseif SV.team_dark.Status == 1 then
    GROUND:Unhide("NPC_Goals")
  elseif SV.team_dark.Status == 3 then
    GROUND:Unhide("NPC_Goals")
  elseif SV.team_dark.Status == 4 then
    GROUND:Unhide("NPC_Goals")
  elseif SV.team_psychic.Status == 5 then
    -- TODO cycling
    GROUND:Unhide("NPC_Goals")
  end


  if SV.team_dragon.Status == 3 then
    GROUND:Unhide("NPC_Dragon_2")
    GROUND:Unhide("NPC_Dragon_3")
	
	local questname = "QuestDragon"
    local quest = SV.missions.Missions[questname]
	if quest ~= nil and quest.Complete == COMMON.MISSION_COMPLETE then
	  GROUND:Unhide("NPC_Dragon_1")
	end
  elseif SV.team_dragon.Status == 4 then
    GROUND:Unhide("NPC_Dragon_1")
    GROUND:Unhide("NPC_Dragon_2")
    GROUND:Unhide("NPC_Dragon_3")
    GROUND:Unhide("NPC_Protege")
    GROUND:Unhide("NPC_Protege_Tutor")
  elseif SV.team_dragon.Status == 6 then
    GROUND:Unhide("NPC_Dragon_1")
    GROUND:Unhide("NPC_Dragon_2")
    GROUND:Unhide("NPC_Dragon_3")
    GROUND:Unhide("NPC_Protege_Tutor")
	
	local protegeTutor = CH('NPC_Protege_Tutor')
	local protegeTutorData = RogueEssence.Dungeon.CharData()
	protegeTutorData.BaseForm = RogueEssence.Dungeon.MonsterID("flygon", 0, "normal", Gender.Male)
	protegeTutor.Data = protegeTutorData
  elseif SV.team_dragon.Status == 8 then
    GROUND:Unhide("NPC_Protege")
	if SV.team_dragon.Cycle == 3 then
      GROUND:Unhide("NPC_Dragon_1")
      GROUND:Unhide("NPC_Dragon_2")
      GROUND:Unhide("NPC_Dragon_3")
	end
  end
  
  if SV.team_firecracker.Status == 2 then
    GROUND:Unhide("NPC_Seer")
	GROUND:Unhide("NPC_Conjurer")
  elseif SV.team_firecracker.Status == 5 and SV.team_firecracker.Cycle == 4 then
    GROUND:Unhide("NPC_Seer")
	GROUND:Unhide("NPC_Conjurer")
	
	local conjurer = CH('NPC_Conjurer')
	local conjurerData = RogueEssence.Dungeon.CharData()
	conjurerData.BaseForm = RogueEssence.Dungeon.MonsterID("typhlosion", 1, "normal", Gender.Male)
	conjurer.Data = conjurerData
  end
  
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
  
  if SV.rest_stop.DaysSinceBoss >= 3 and not SV.rest_stop.BossSolved then

    GROUND:Unhide("Boss_1")
    GROUND:Unhide("Boss_2")
    GROUND:Unhide("Boss_3")
    GROUND:Unhide("Boss_4")
    GROUND:Unhide("Boss_5")
    GROUND:Unhide("Boss_6")
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


function rest_stop.Rival_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')

  if SV.team_rivals.Status == 4 then
  
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_1_Line_001']))
  
  SV.team_rivals.SpokenTo = true
  
  elseif SV.team_rivals.Status == 5 then
  
  local questname = "QuestRival2"
  local quest = SV.missions.Missions[questname]
	
  
  if quest == nil then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_1_Help_Line_001']))
	
	SV.missions.Missions[questname] = { Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_RESCUE,
      DestZone = "thunderstruck_pass", DestSegment = 0, DestFloor = 8,
      FloorUnknown = false,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("zangoose", 0, "normal", Gender.Female),
      ClientSpecies = RogueEssence.Dungeon.MonsterID("seviper", 0, "normal", Gender.Female) }
	
  elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_1_Help_Line_002']))
  else
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_1_Help_Line_003']))
  end
  
  elseif SV.team_rivals.Status == 6 then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_1_Help_Line_003']))
  end
  
  
end
  
function rest_stop.Rival_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')

  if SV.team_rivals.Status == 4 then
  
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_2_Line_001']))
  
  SV.team_rivals.SpokenTo = true
  
  elseif SV.team_rivals.Status == 5 then
  
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_2_Help_Line_001']))
  
    local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_normal_silk")
  COMMON.GiftItem(player, receive_item)
  
  COMMON.CompleteMission("QuestRival2")
  
  SV.team_rivals.Status = 6
  
  elseif SV.team_rivals.Status == 6 then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_2_Help_Line_002']))
  end
  
  
  
end


function rest_stop.NPC_Dragon_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  rest_stop.DragonTalk()
end
  
function rest_stop.NPC_Dragon_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  rest_stop.DragonTalk()
end
  
function rest_stop.NPC_Dragon_3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  rest_stop.DragonTalk()
end
  
function rest_stop.NPC_Protege_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  rest_stop.DragonTalk()
end
  
function rest_stop.NPC_Protege_Tutor_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  rest_stop.DragonTalk()
end

function rest_stop.DragonTalk()
  local dragon1 = CH('NPC_Dragon_1')
  local dragon2 = CH('NPC_Dragon_2')
  local dragon3 = CH('NPC_Dragon_3')
  local protege = CH('NPC_Protege')
  local protegeTutor = CH('NPC_Protege_Tutor')
  
  if SV.team_dragon.Status == 3 then
    local questname = "QuestDragon"
    local quest = SV.missions.Missions[questname]
	
    if quest == nil then
      UI:SetSpeaker(dragon3)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Dragon_Line_001']))
	  
	  SV.missions.Missions[questname] = { Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_RESCUE,
      DestZone = "snowbound_path", DestSegment = 0, DestFloor = 14,
      FloorUnknown = false,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("charizard", 0, "normal", Gender.Male),
      ClientSpecies = RogueEssence.Dungeon.MonsterID("aerodactyl", 0, "normal", Gender.Male) }
	
    elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:SetSpeaker(dragon3)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Dragon_Line_002']))
    else
      rest_stop.Dragon_Complete()
    end
  
  elseif SV.team_dragon.Status == 4 then
      UI:SetSpeaker(dragon1)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Dragon_Rescue_Line_002']))
  elseif SV.team_dragon.Status == 6 then
    if SV.team_dragon.SpokenTo == false then
      UI:SetSpeaker(dragon1)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Dragon_Line_003']))
	else
      UI:SetSpeaker(dragon1)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Dragon_Line_004']))
	end
  elseif SV.team_dragon.Status == 8 then
    UI:SetSpeaker(dragon1)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Dragon_Line_005']))
  end
  
  SV.team_dragon.SpokenTo = true
end

function rest_stop.Dragon_Complete()
  local dragon1 = CH('NPC_Dragon_1')
  local dragon2 = CH('NPC_Dragon_2')
  local dragon3 = CH('NPC_Dragon_3')
  local protege = CH('NPC_Protege')
  local protegeTutor = CH('NPC_Protege_Tutor')
  local player = CH('PLAYER')
  
  GROUND:Unhide("NPC_Protege")
  GROUND:Unhide("NPC_Protege_Tutor")
  
  UI:SetSpeaker(dragon1)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Dragon_Rescue_Line_001']))
  
  local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_dragon_silk")
  COMMON.GiftItem(player, receive_item)
  
  COMMON.CompleteMission("QuestDragon")
  
  SV.team_dragon.Status = 4
end


function rest_stop.NPC_Seer_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GROUND:CharTurnToChar(chara,CH('PLAYER'))--make the chara turn to the player
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  
  if SV.team_firecracker.Status ~= 5 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seer_Line_001']))
	SV.team_firecracker.SpokenTo = true
  else
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seer_Line_002']))
  end
end

function rest_stop.NPC_Conjurer_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GROUND:CharTurnToChar(chara,CH('PLAYER'))--make the chara turn to the player
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  
  if SV.team_firecracker.Status ~= 5 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Conjurer_Line_001']))
	SV.team_firecracker.SpokenTo = true
  else
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Conjurer_Line_002']))
  end
end

function rest_stop.NPC_Storehouse_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  
  if SV.supply_corps.Status <= 10 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_001']))
    SV.supply_corps.Status = 11
  elseif SV.supply_corps.Status == 11 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_001']))
  elseif SV.supply_corps.Status == 12 then
    local questname = "OutlawMountain1"
    local quest = SV.missions.Missions[questname]
    if quest == nil then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_002']))
	  --add the quest
	  SV.missions.Missions[questname] = { Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_OUTLAW,
      DestZone = "copper_quarry", DestSegment = 0, DestFloor = 4,
      FloorUnknown = true,
      ClientSpecies = chara.CurrentForm,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("weavile", 0, "normal", Gender.Male) }
    elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_003']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_004']))
      --give reward
      local receive_item = RogueEssence.Dungeon.InvItem("tm_sludge_bomb")
      COMMON.GiftItem(player, receive_item)
      --complete mission and move to done
	  COMMON.CompleteMission(questname)
      SV.supply_corps.Status = 13
    end
  elseif SV.supply_corps.Status == 13 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_005']))
  elseif SV.supply_corps.Status == 14 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_006']))
  elseif SV.supply_corps.Status == 15 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_007']))
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_Route']))
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
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_001']))
    elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_002']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_003']))
    end
  elseif SV.supply_corps.Status == 13 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_004']))
  elseif SV.supply_corps.Status == 14 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_005']))
    SV.supply_corps.Status = 15
  elseif SV.supply_corps.Status == 15 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_006']))
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_Route']))
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
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_001']))
    elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_002']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_003']))
    end
  elseif SV.supply_corps.Status == 13 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_004']))
  elseif SV.supply_corps.Status == 14 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_005']))
    SV.supply_corps.Status = 15
  elseif SV.supply_corps.Status == 15 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_006']))
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_Route']))
  end
end


function rest_stop.Boss_1_Action(chara, activator)
  rest_stop.Rock_Boss(chara, activator)
end

function rest_stop.Boss_2_Action(chara, activator)
  rest_stop.Rock_Boss(chara, activator)
end

function rest_stop.Rock_Boss(chara, activator)
  
  local questname = "QuestRock"
  local quest = SV.missions.Missions[questname]
	
  
  if quest == nil then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,CH('PLAYER'))
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rock_Boss_Line_001']))
	
	SV.missions.Missions[questname] = { Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_RESCUE,
      DestZone = "veiled_ridge", DestSegment = 0, DestFloor = 10,
      FloorUnknown = false,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("exploud", 0, "normal", Gender.Male),
      ClientSpecies = RogueEssence.Dungeon.MonsterID("aggron", 0, "normal", Gender.Male) }
	
  elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,CH('PLAYER'))
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rock_Boss_Line_002']))
  else
    rest_stop.Rock_Complete()
  end
end

function rest_stop.Boss_3_Action(chara, activator)
  rest_stop.Screech_Rabble(chara, activator)
end

function rest_stop.Boss_4_Action(chara, activator)
  rest_stop.Screech_Rabble(chara, activator)
end

function rest_stop.Screech_Rabble(chara, activator)

  local questname = "QuestRock"
  local quest = SV.missions.Missions[questname]
  
  if quest ~= nil and quest.Complete == COMMON.MISSION_COMPLETE then
    rest_stop.Rock_Complete()
  else
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Screech_Rabble_Line_001']))
  end
end



function rest_stop.Boss_5_Action(chara, activator)
  rest_stop.Loud_Rabble(chara, activator)
end

function rest_stop.Boss_6_Action(chara, activator)
  rest_stop.Loud_Rabble(chara, activator)
end

function rest_stop.Loud_Rabble(chara, activator)

  local questname = "QuestRock"
  local quest = SV.missions.Missions[questname]
  
  if quest ~= nil and quest.Complete == COMMON.MISSION_COMPLETE then
    rest_stop.Rock_Complete()
  else
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Loud_Rabble_Line_001']))
  end
end


function rest_stop.Rock_Complete()
  local player = CH('PLAYER')
  local rock1 = CH('Boss_1')
  local loud1 = CH('Boss_5')
  local loud2 = CH('Boss_6')
  local loud_boss = CH('Boss_Loud')
  
  UI:SetSpeaker(loud1)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Loud_Boss_Line_001']))
  
  GROUND:Unhide("Boss_Loud")
  
  GAME:WaitFrames(60)
  
  UI:SetSpeaker(loud_boss)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Loud_Boss_Line_002']))
  
  UI:SetSpeaker(loud1)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Loud_Boss_Line_003']))
  
  GROUND:Hide("Boss_5")
  GROUND:Hide("Boss_6")
  GROUND:Hide("Boss_Loud")
  
  GAME:WaitFrames(60)
  
  UI:SetSpeaker(rock1)
  UI:SetSpeakerEmotion("Stunned")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Loud_Boss_Line_004']))
  
  UI:SetSpeakerEmotion("Normal")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rock_Boss_Reward']))
  
  
  local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_rock_silk")
  COMMON.GiftItem(player, receive_item)
  
  
  GROUND:Hide("Boss_1")
  GROUND:Hide("Boss_2")
  
  GROUND:Hide("Boss_3")
  GROUND:Hide("Boss_4")
  
  COMMON.CompleteMission("QuestRock")
  
  SV.rest_stop.BossSolved = true
end


function rest_stop.NPC_Strategy_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  
  if SV.team_psychic.Status == 2 then
  
    if SV.team_psychic.SpokenTo then
      UI:SetSpeaker(chara)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Strategy_Line_002']))
	else
      rest_stop.Separate()
	end
	
  elseif SV.team_psychic.Status == 6 then
    --cycle?
  end
end

function rest_stop.NPC_Goals_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  
  if SV.team_psychic.Status == 2 then
  
    if SV.team_psychic.SpokenTo then
      UI:SetSpeaker(chara)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Goals_Line_002']))
	else
      rest_stop.Separate()
	end
	
  elseif SV.team_dark.Status == 1 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Goals_Line_003']))
	
  elseif SV.team_dark.Status == 3 then
    
  local questname = "QuestIce"
  local quest = SV.missions.Missions[questname]
	
  if quest == nil then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Goals_Help_Line_001']))
	
	SV.missions.Missions[questname] = { Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_RESCUE,
      DestZone = "treacherous_mountain", DestSegment = 0, DestFloor = 9,
      FloorUnknown = false,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("ninetales", 1, "normal", Gender.Male),
      ClientSpecies = RogueEssence.Dungeon.MonsterID("sneasel", 0, "normal", Gender.Male) }
	
  elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Goals_Help_Line_002']))
  else
    rest_stop.Ice_Complete()
  end
	
  elseif SV.team_dark.Status == 4 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Goals_Line_004']))
	
  elseif SV.team_dark.Status == 5 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Goals_Line_004']))
	
  end
end

function rest_stop.Separate()
  local strategy = CH('NPC_Strategy')
  local goals = CH('NPC_Goals')
  local player = CH('PLAYER')
  
  UI:SetSpeaker(strategy)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Strategy_Line_001']))
  
  UI:SetSpeaker(goals)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Goals_Line_001']))
  
  UI:SetSpeaker(strategy)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Strategy_Line_002']))
  
  UI:SetSpeaker(goals)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Goals_Line_002']))
  
  SV.team_psychic.SpokenTo = true
end

function rest_stop.Ice_Complete()
  local goals = CH('NPC_Goals')
  local player = CH('PLAYER')
  
  UI:SetSpeaker(goals)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Goals_Done_Line_001']))
  
  local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_ice_silk")
  COMMON.GiftItem(player, receive_item)
  
  
  COMMON.CompleteMission("QuestIce")
  
  SV.team_dark.Status = 5
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