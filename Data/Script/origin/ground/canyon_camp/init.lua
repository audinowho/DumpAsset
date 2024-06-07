require 'origin.common'

local canyon_camp = {}

--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function canyon_camp.Init(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_canyon_camp")

  COMMON.RespawnAllies()
  
  --set the tutor's appearance based on 
  local tutor = CH('NPC_Tutor')
  
  local charData = RogueEssence.Dungeon.CharData()
  local tutor_species = "missingno"
  if SV.General.Starter.Species == "bulbasaur" then
    if SV.StarterTutor.Evolved then
      tutor_species = "meganium"
	else
	  tutor_species = "bayleef"
	end
  elseif SV.General.Starter.Species == "charmander" then
    if SV.StarterTutor.Evolved then
      tutor_species = "typhlosion"
	else
	  tutor_species = "quilava"
	end
  elseif SV.General.Starter.Species == "squirtle" then
    if SV.StarterTutor.Evolved then
      tutor_species = "feraligatr"
	else
	  tutor_species = "croconaw"
	end
  else --if SV.General.Starter.Species == "pikachu" then
    tutor_species = "raichu"
  end
  charData.BaseForm = RogueEssence.Dungeon.MonsterID(tutor_species, 0, "normal", Gender.Female)
  tutor.Data = charData
end

function canyon_camp.Enter(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine

  SV.checkpoint = 
  {
    Zone    = 'guildmaster_island', Segment  = -1,
    Map  = 5, Entry  = 1
  }
  
  --when arriving the first time, play this cutscene
  if not SV.canyon_camp.ExpositionComplete then
    canyon_camp.SetupNpcs()
    canyon_camp.BeginExposition()
    SV.canyon_camp.ExpositionComplete = true
  elseif SV.rest_stop.BossPhase == 2 then
    canyon_camp.SetupNpcs()
    canyon_camp.Aggron_Fail()
	SV.rest_stop.BossPhase = 1
  else
    canyon_camp.SetupNpcs()
	
	canyon_camp.CheckMissions()
	
    GAME:FadeIn(20)
  end
end

function canyon_camp.Update(map, time)
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------
function canyon_camp.SetupNpcs()
  if SV.rest_stop.ExpositionComplete then
    GROUND:Unhide("NPC_Seeker")
    GROUND:Unhide("NPC_Hidden")
  end
  GROUND:Unhide("NPC_NextCamp")
  GROUND:Unhide("NPC_Spar")
  
  if SV.team_rivals.Status == 1 then
    GROUND:Unhide("Rival_1")
	GROUND:Unhide("Rival_2")
  elseif SV.team_rivals.Status == 2 then
    GROUND:Unhide("Rival_2")
	
	local questname = "QuestRival1"
    local quest = SV.missions.Missions[questname]
	if quest ~= nil and quest.Complete == COMMON.MISSION_COMPLETE then
	  GROUND:Unhide("Rival_1")
	end
  elseif SV.team_rivals.Status == 3 then
    GROUND:Unhide("Rival_1")
	GROUND:Unhide("Rival_2")
  elseif SV.team_rivals.Status == 8 then
    -- TODO cycling
  end
  
  if SV.team_meditate.Status == 1 then
    GROUND:Unhide("NPC_Monk")
  elseif SV.team_meditate.Status == 3 then
	local questname = "QuestFighting"
    local quest = SV.missions.Missions[questname]
	if quest ~= nil and quest.Complete == COMMON.MISSION_COMPLETE then
	  GROUND:Unhide("NPC_Monk")
	else
	  local spar = CH('NPC_Spar')
	  GROUND:TeleportTo(spar, 864, 360, Direction.DownLeft)
	end
  elseif SV.team_meditate.Status == 4 then
    GROUND:Unhide("NPC_Monk")
  elseif SV.team_meditate.Status == 5 then
    -- TODO cycling
	GROUND:Unhide("NPC_Monk")
  end
  
  
  if SV.team_steel.Argued == false then
    GROUND:Unhide("NPC_Argue_1")
    GROUND:Unhide("NPC_Argue_2")
  end
  
  if SV.team_solo.Status == 3 and SV.team_solo.SpokenTo == false then
    GROUND:Unhide("NPC_Solo")
	local solo = CH('NPC_Solo')
	GROUND:TeleportTo(solo, 1064, 400, Direction.Right)
  elseif SV.team_solo.Status == 4 then
	local questname = "QuestWater"
    local quest = SV.missions.Missions[questname]
	if quest ~= nil and quest.Complete == COMMON.MISSION_COMPLETE then
	  GROUND:Unhide("NPC_Solo")
	else
	  local shortcut = CH('NPC_Shortcut')
	  GROUND:TeleportTo(shortcut, 912, 384, Direction.Right)
	end
  elseif SV.team_solo.Status == 5 then
    GROUND:Unhide("NPC_Solo")
  elseif SV.team_solo.Status == 6 then
    -- TODO cycling
    GROUND:Unhide("NPC_Solo")
  end
  
  if SV.team_psychic.Status == 0 or SV.team_psychic.Status == 1 then
    GROUND:Unhide("NPC_Strategy")
    GROUND:Unhide("NPC_Goals")
  elseif SV.team_psychic.Status == 3 then
    GROUND:Unhide("NPC_Strategy")
    GROUND:Unhide("NPC_Brains")
  elseif SV.team_psychic.Status == 4 then
    GROUND:Unhide("NPC_Brains")
	
	local questname = "QuestPsychic"
    local quest = SV.missions.Missions[questname]
	if quest ~= nil and quest.Complete == COMMON.MISSION_COMPLETE then
	  GROUND:Unhide("NPC_Strategy")
	end
  elseif SV.team_psychic.Status == 5 then
    GROUND:Unhide("NPC_Strategy")
    GROUND:Unhide("NPC_Brains")
  elseif SV.team_psychic.Status == 6 then
    -- TODO cycling
    GROUND:Unhide("NPC_Strategy")
    GROUND:Unhide("NPC_Brains")
  end
  
  if SV.team_dragon.Status == 0 then
    GROUND:Unhide("NPC_Dragon_1")
    GROUND:Unhide("NPC_Dragon_2")
    GROUND:Unhide("NPC_Dragon_3")
  elseif SV.team_dragon.Status == 1 then
    GROUND:Unhide("NPC_Dragon_1")
    GROUND:Unhide("NPC_Dragon_2")
    GROUND:Unhide("NPC_Dragon_3")
    GROUND:Unhide("NPC_Protege_Tutor")
  elseif SV.team_dragon.Status == 2 then
    GROUND:Unhide("NPC_Dragon_1")
    GROUND:Unhide("NPC_Dragon_2")
    GROUND:Unhide("NPC_Dragon_3")
    GROUND:Unhide("NPC_Protege")
  elseif SV.team_dragon.Status == 5 then
    GROUND:Unhide("NPC_Dragon_1")
    GROUND:Unhide("NPC_Dragon_2")
    GROUND:Unhide("NPC_Dragon_3")
	
	local protege = CH('NPC_Protege')
	local protegeTutor = CH('NPC_Protege_Tutor')
	GROUND:TeleportTo(protege, 496, 368, Direction.Up)
	GROUND:TeleportTo(protegeTutor, 512, 368, Direction.Up)
    GROUND:Unhide("NPC_Protege")
    GROUND:Unhide("NPC_Protege_Tutor")
	
	local protegeData = RogueEssence.Dungeon.CharData()
	protegeData.BaseForm = RogueEssence.Dungeon.MonsterID("flapple", 0, "normal", Gender.Male)
	protege.Data = protegeData

	local protegeTutorData = RogueEssence.Dungeon.CharData()
	protegeTutorData.BaseForm = RogueEssence.Dungeon.MonsterID("vibrava", 0, "normal", Gender.Male)
	protegeTutor.Data = protegeTutorData
  elseif SV.team_dragon.Status == 8 and SV.team_dragon.Cycle == 3 then
    GROUND:Unhide("NPC_Dragon_1")
    GROUND:Unhide("NPC_Dragon_2")
    GROUND:Unhide("NPC_Dragon_3")
  end
  
  if SV.team_firecracker.Status == 1 then
    GROUND:Unhide("NPC_Seer")
	GROUND:Unhide("NPC_Conjurer")
  elseif SV.team_firecracker.Status == 5 and SV.team_firecracker.Cycle == 3 then
    GROUND:Unhide("NPC_Seer")
	GROUND:Unhide("NPC_Conjurer")
	
	local seer = CH('NPC_Seer')
	local seerData = RogueEssence.Dungeon.CharData()
	seerData.BaseForm = RogueEssence.Dungeon.MonsterID("delphox", 0, "normal", Gender.Male)
	seer.Data = seerData

	local conjurer = CH('NPC_Conjurer')
	local conjurerData = RogueEssence.Dungeon.CharData()
	conjurerData.BaseForm = RogueEssence.Dungeon.MonsterID("typhlosion", 1, "normal", Gender.Male)
	conjurer.Data = conjurerData
  end
  
  if SV.supply_corps.Status < 4 then
    --pass
  elseif SV.supply_corps.Status <= 5 then
    GROUND:Unhide("NPC_Storehouse")
  elseif SV.supply_corps.Status <= 9 then
    GROUND:Unhide("NPC_Storehouse")
    GROUND:Unhide("NPC_Carry")
    GROUND:Unhide("NPC_Deliver")
  elseif SV.supply_corps.Status <= 11 then
    GROUND:Unhide("NPC_Carry")
    GROUND:Unhide("NPC_Deliver")
  elseif SV.supply_corps.Status >= 20 then
    --cycle appearances
	if SV.supply_corps.ManagerCycle == 0 or SV.supply_corps.ManagerCycle == 6 then
	
	else
	  if SV.supply_corps.CarryCycle == 3 then
	    GROUND:Unhide("NPC_Carry")
	  end
	  if SV.supply_corps.DeliverCycle == 3 then
	    GROUND:Unhide("NPC_Deliver")
	  end
	  if SV.supply_corps.ManagerCycle == 3 then
	    GROUND:Unhide("NPC_Storehouse")
	  end
	end
  end
end

function canyon_camp.CheckMissions()
  local player = CH('PLAYER')
  
  local quest = SV.missions.Missions["EscortFather"]
  if quest ~= nil then
    if quest.Complete == COMMON.MISSION_COMPLETE then
	
      --spawn her	  
      
      GAME:FadeIn(20)
      UI:WaitShowDialogue("Escort mission state: Complete.")
      
      --she walks off to sunflora
      UI:WaitShowDialogue("The father drops something as he runs off.")
      
      SV.magnagate.Cards = SV.magnagate.Cards + 1
	  SV.family.Father = true
      COMMON.GiftKeyItem(player, RogueEssence.StringKey("ITEM_KEY_CARD_SAND"):ToLocal())
	  COMMON.CompleteMission("EscortFather")
	  
    end
  end
end

function canyon_camp.BeginExposition()

  UI:WaitShowTitle(GAME:GetCurrentGround().Name:ToLocal(), 20);
  GAME:WaitFrames(30);
  UI:WaitHideTitle(20);
  GAME:FadeIn(20)
  
  GAME:UnlockDungeon('copper_quarry')
  GAME:UnlockDungeon('depleted_basin')
end

--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------


  
function canyon_camp.Rival_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')

  if SV.team_rivals.Status == 1 then
  
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Rival_1_Line_001']))
  
  SV.team_rivals.SpokenTo = true
  
  elseif SV.team_rivals.Status == 2 then
  
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Rival_1_Help_Line_001']))
  
    local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_poison_silk")
  COMMON.GiftItem(player, receive_item)
  
  COMMON.CompleteMission("QuestRival1")
  
  SV.team_rivals.Status = 3
  
  elseif SV.team_rivals.Status == 3 then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Rival_1_Help_Line_002']))
  end
  
  
  
end
  
function canyon_camp.Rival_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')

  if SV.team_rivals.Status == 1 then
  
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Rival_2_Line_001']))
  
  SV.team_rivals.SpokenTo = true
  
  elseif SV.team_rivals.Status == 2 then
  
  local questname = "QuestRival1"
  local quest = SV.missions.Missions[questname]
	
  
  if quest == nil then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Rival_2_Help_Line_001']))
	
	COMMON.CreateMission(questname,
	{ Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_RESCUE,
      DestZone = "copper_quarry", DestSegment = 0, DestFloor = 6,
      FloorUnknown = false,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("seviper", 0, "normal", Gender.Female),
      ClientSpecies = RogueEssence.Dungeon.MonsterID("zangoose", 0, "normal", Gender.Female) }
	)
  elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Rival_2_Help_Line_002']))
  else
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Rival_2_Help_Line_003']))
  end
  
  elseif SV.team_rivals.Status == 3 then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Rival_2_Help_Line_003']))
  end
  
end

function canyon_camp.NPC_Seer_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GROUND:CharTurnToChar(chara,CH('PLAYER'))--make the chara turn to the player
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  
  if SV.team_firecracker.Status ~= 5 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Seer_Line_001']))
	SV.team_firecracker.SpokenTo = true
  else
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Seer_Line_002']))
  end
end

function canyon_camp.NPC_Conjurer_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GROUND:CharTurnToChar(chara,CH('PLAYER'))--make the chara turn to the player
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  
  if SV.team_firecracker.Status ~= 5 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Conjurer_Line_001']))
	SV.team_firecracker.SpokenTo = true
  else
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Conjurer_Line_002']))
  end
end

function canyon_camp.NPC_Storehouse_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
	
  if SV.supply_corps.Status <= 4 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Storehouse_Line_001']))
    SV.supply_corps.Status = 5
  elseif SV.supply_corps.Status == 5 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Storehouse_Line_001']))
  elseif SV.supply_corps.Status == 6 then
    local questname = "OutlawForest2"
    local quest = SV.missions.Missions[questname]
    if quest == nil then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Storehouse_Line_002']))
	  --add the quest
	  COMMON.CreateMission(questname,
	{ Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_OUTLAW_HOUSE,
      DestZone = "flyaway_cliffs", DestSegment = 0, DestFloor = 6, FloorUnknown = true,
      ClientSpecies = chara.CurrentForm,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("toxicroak", 0, "normal", Gender.Male) }
	  )
    elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Storehouse_Line_003']))
    else
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Storehouse_Line_004']))
      --give reward
        local receive_item = RogueEssence.Dungeon.InvItem("food_banana_big")
        COMMON.GiftItem(player, receive_item)
      --complete mission and move to done
	  COMMON.CompleteMission(questname)
      SV.supply_corps.Status = 7
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Storehouse_Line_005']))
    end
  elseif SV.supply_corps.Status == 7 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Storehouse_Line_006']))
  elseif SV.supply_corps.Status == 8 then
    local unlock = _DATA.Save:GetDungeonUnlock("ambush_forest") -- make this the dungeon unlock state
    if unlock == RogueEssence.Data.GameProgress.UnlockState.None then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Storehouse_Line_007']))
      COMMON.UnlockWithFanfare("ambush_forest", false)
    elseif unlock == RogueEssence.Data.GameProgress.UnlockState.Discovered then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Storehouse_Line_008']))
    else
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Storehouse_Line_009']))
      --increase rank for bag space
      _DATA.Save.ActiveTeam:SetRank("bronze")
      SOUND:PlayFanfare("Fanfare/RankUp")
      UI:ResetSpeaker(false)
      UI:SetCenter(true)
	  local rank = _DATA:GetRank(_DATA.Save.ActiveTeam.Rank)
      UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("DLG_BAG_SIZE"):ToLocal(), rank.BagSize))
      UI:SetSpeaker(chara)
      UI:SetCenter(false)
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Storehouse_Line_010']))
      SV.supply_corps.Status = 9
    end
  elseif SV.supply_corps.Status == 9 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Storehouse_Line_011']))
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Storehouse_Line_Route']))
  end
end

function canyon_camp.NPC_Carry_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)
  
  if SV.supply_corps.Status == 6 then
    local questname = "OutlawForest2"
    local quest = SV.missions.Missions[questname]
    if quest == nil then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_001']))
    elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_002']))
    else
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_003']))
    end
  elseif SV.supply_corps.Status == 7 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_004']))
  elseif SV.supply_corps.Status == 8 then
    local unlock = _DATA.Save:GetDungeonUnlock("ambush_forest") -- make this the dungeon unlock state
    if unlock == RogueEssence.Data.GameProgress.UnlockState.None then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_005']))
    elseif unlock == RogueEssence.Data.GameProgress.UnlockState.Discovered then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_006']))
    else
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_007']))
    end
  elseif SV.supply_corps.Status == 9 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_008']))
  elseif SV.supply_corps.Status == 10 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_009']))
    SV.supply_corps.Status = 11
  elseif SV.supply_corps.Status == 11 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_009']))
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_Route']))
  end
  
end

function canyon_camp.NPC_Deliver_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)
  
  if SV.supply_corps.Status == 6 then
    local questname = "OutlawForest2"
    local quest = SV.missions.Missions[questname]
    if quest == nil then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Deliver_Line_001']))
    elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Deliver_Line_002']))
    else
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Deliver_Line_003']))
    end
  elseif SV.supply_corps.Status == 7 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Deliver_Line_004']))
  elseif SV.supply_corps.Status == 8 then
    local unlock = _DATA.Save:GetDungeonUnlock("ambush_forest") -- make this the dungeon unlock state
    if unlock == RogueEssence.Data.GameProgress.UnlockState.None then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Deliver_Line_005']))
    elseif unlock == RogueEssence.Data.GameProgress.UnlockState.Discovered then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Deliver_Line_006']))
    else
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Deliver_Line_007']))
    end
  elseif SV.supply_corps.Status == 9 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Deliver_Line_008']))
  elseif SV.supply_corps.Status == 10 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Deliver_Line_009']))
	SV.supply_corps.Status = 11
  elseif SV.supply_corps.Status == 11 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Deliver_Line_009']))
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Deliver_Line_Route']))
  end
end

  
function canyon_camp.NPC_Dragon_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  canyon_camp.DragonTalk()
end
  
function canyon_camp.NPC_Dragon_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  canyon_camp.DragonTalk()
end
  
function canyon_camp.NPC_Dragon_3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  canyon_camp.DragonTalk()
end
  
function canyon_camp.NPC_Protege_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  canyon_camp.DragonTalk()
end
  
function canyon_camp.NPC_Protege_Tutor_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  canyon_camp.DragonTalk()
end

function canyon_camp.DragonTalk()
  local dragon1 = CH('NPC_Dragon_1')
  local dragon2 = CH('NPC_Dragon_2')
  local dragon3 = CH('NPC_Dragon_3')
  local protege = CH('NPC_Protege')
  local protegeTutor = CH('NPC_Protege_Tutor')
  
  if SV.team_dragon.Status == 0 then
    if SV.team_dragon.SpokenTo == false then
      UI:SetSpeaker(dragon1)
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Dragon_Line_001']))
  
      UI:SetSpeaker(dragon2)
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Dragon_Line_002']))
  
      UI:SetSpeaker(dragon3)
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Dragon_Line_003']))
  
      UI:SetSpeaker(dragon1)
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Dragon_Line_004']))
	else
      UI:SetSpeaker(dragon1)
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Dragon_Line_005']))
	end
  elseif SV.team_dragon.Status == 1 then
    if SV.team_dragon.SpokenTo == false then
      UI:SetSpeaker(dragon1)
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Dragon_Line_006']))
	else
      UI:SetSpeaker(dragon1)
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Dragon_Line_007']))
	end
  
  elseif SV.team_dragon.Status == 2 then
    if SV.team_dragon.SpokenTo == false then
      UI:SetSpeaker(dragon1)
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Dragon_Line_008']))
	else
      UI:SetSpeaker(dragon1)
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Dragon_Line_009']))
	end
  
  elseif SV.team_dragon.Status == 5 then
    if SV.team_dragon.SpokenTo == false then
      UI:SetSpeaker(dragon1)
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Dragon_Line_010']))
	else
      UI:SetSpeaker(dragon1)
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Dragon_Line_011']))
	end
  
  elseif SV.team_dragon.Status == 8 then
    UI:SetSpeaker(dragon1)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Dragon_Line_012']))
  end
  
  SV.team_dragon.SpokenTo = true
end

  
function canyon_camp.NPC_Shiny_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  GROUND:CharTurnToChar(chara, player)--make the chara turn to the player
  if not SV.canyon_camp.ShinyIntro then
    if player.CurrentForm.Skin == "normal" then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shiny_Line_001']))
    else
      SOUND:PlayBattleSE("EVT_Emote_Exclaim_2")
      GROUND:CharSetEmote(chara, "exclaim", 1)
	  GAME:WaitFrames(30)
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shiny_Line_002']))
	  SV.canyon_camp.ShinyIntro = true
    end
  else
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shiny_Line_003']))
  end
end
  
function canyon_camp.NPC_Tutor_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local tutor_skill = "struggle"
  if SV.General.Starter.Species == "bulbasaur" then
    tutor_skill = "grass_pledge"
  elseif SV.General.Starter.Species == "charmander" then
    tutor_skill = "fire_pledge"
  elseif SV.General.Starter.Species == "squirtle" then
    tutor_skill = "water_pledge"
  else --if SV.General.Starter.Species == "pikachu" then
    tutor_skill = "volt_tackle"
  end
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  if SV.StarterTutor.Complete == false then
    
	local skillData = _DATA:GetSkill(tutor_skill)
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Intro'], skillData:GetIconName()))
	
	local playerMonId = player.Data.BaseForm
	local monData = _DATA:GetMonster(playerMonId.Species)
	local formData = monData.Forms[playerMonId.Form]
	
	local already_learned = player.Data:HasBaseSkill(tutor_skill)
	if already_learned then
	  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Already'], skillData:GetIconName()))
	elseif formData:CanLearnSkill(tutor_skill) then
	  
	  UI:ChoiceMenuYesNo(STRINGS:Format(STRINGS.MapStrings['Tutor_Ask'], monData:GetColoredName(), skillData:GetIconName()), false)
	  UI:WaitForChoice()
	  result = UI:ChoiceResult()
	  
	  if result then
		--one more check against full list flow
		local replace_msg = STRINGS:Format(RogueEssence.StringKey("TALK_TUTOR_REPLACE"):ToLocal(), skillData:GetIconName())
		result = COMMON.LearnMoveFlow(player.Data, tutor_skill, replace_msg)
	  end
	  
	  if result then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Accept']))
      
      --fade out, pause
      local animId = RogueEssence.Content.GraphicsManager.GetAnimIndex("Pose")
      GROUND:CharSetAction(chara, RogueEssence.Ground.PoseGroundAction(chara.Position, chara.Direction, animId))
      GROUND:CharSetAction(player, RogueEssence.Ground.PoseGroundAction(player.Position, player.Direction, animId))
		
      GAME:FadeOut(false, 30)
      GAME:WaitFrames(30)
		
      SOUND:PlayFanfare("Fanfare/LearnSkill")
      local orig_settings = UI:ExportSpeakerSettings()
      UI:ResetSpeaker(false)
      UI:WaitShowDialogue(STRINGS:FormatKey("DLG_SKILL_LEARN", player.Data:GetDisplayName(true), skillData:GetIconName()))
      UI:ImportSpeakerSettings(orig_settings)
		
      --fade in
      GROUND:CharEndAnim(chara)
      GROUND:CharEndAnim(player)
      GAME:FadeIn(30)
		
	    --I learned this move from a traveling move tutor.  He said he'd pass by base town after I spoke to him.
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Taught']))
		
      --after teaching, unlock the tutor back at the hub
      --the other moves can be found in dungeons by wandering tutors
      SV.StarterTutor.Complete = true
      SV.base_town.TutorMoves[tutor_skill] = true
	  else
	    --come back if you change your mind.
	    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Decline']))
	  end
	else
	  --But the other townsfolk weren't interested in hearing about it.
	  --If only there was someone I could share this knowledge with.
	  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Incompatible']))
	end
  else
	--There are other tutors wandering around in the dungeons. They've spent too much time training in dungeons without outside contact, but I'm sure they'd appreciate company.
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Done']))
  end
	
  
end
  
function canyon_camp.NPC_Argue_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  canyon_camp.Argument()
end
  
function canyon_camp.NPC_Argue_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  canyon_camp.Argument()
end

function canyon_camp.Argument()
  
  arg1 = CH('NPC_Argue_1')
  arg2 = CH('NPC_Argue_2')
  
  local itemEntry = _DATA:GetItem("held_metal_coat")
  
  local argue_choices = {arg1:GetDisplayName(),
    arg2:GetDisplayName()}
  
  local item_slot = GAME:FindPlayerItem("held_metal_coat", true, true)
	if item_slot:IsValid() then
		argue_choices[3] = STRINGS:Format(STRINGS.MapStrings['Argue_Option'], itemEntry:GetIconName())
	end
			
  UI:SetSpeaker(arg1)
  UI:BeginChoiceMenu(STRINGS:Format(STRINGS.MapStrings['Argue_Line_001']), argue_choices, 1, -1)
  UI:WaitForChoice()
  result = UI:ChoiceResult()
  
  if result < 3 then
    UI:SetSpeaker(arg2)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Argue_Line_002']))
  else
    SOUND:PlayBattleSE("EVT_CH02_Box_Open")
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Argue_Solved_Line_001']))
	GROUND:Hide("NPC_Argue_1")
	GROUND:Hide("NPC_Argue_2")
	
	
	if item_slot.IsEquipped then
		GAME:TakePlayerEquippedItem(item_slot.Slot)
	else
		GAME:TakePlayerBagItem(item_slot.Slot)
	end
	
	SV.team_steel.Argued = true
  end
end


  
function canyon_camp.NPC_Monk_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  if SV.team_meditate.Status == 1 then
    GROUND:CharTurnToChar(chara, player)
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Monk_Line_001']))
	SV.team_meditate.SpokenTo = true
  elseif SV.team_meditate.Status == 3 then
    canyon_camp.Fighting_Complete()
  elseif SV.team_meditate.Status == 4 then
    GROUND:CharTurnToChar(chara, player)
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Monk_Line_002']))
  elseif SV.team_meditate.Status == 5 then
    GROUND:CharTurnToChar(chara, player)
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Monk_Line_002']))
  end
end

  
function canyon_camp.NPC_Spar_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  
  if SV.team_meditate.Status == 0 then
  
    GROUND:CharTurnToChar(chara, player)
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Spar_Line_001']))
  elseif SV.team_meditate.Status == 1 then
    GROUND:CharTurnToChar(chara, player)
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Spar_Line_002']))
  elseif SV.team_meditate.Status == 2 then
    GROUND:CharTurnToChar(chara, player)
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Spar_Line_002']))
  elseif SV.team_meditate.Status == 3 then
  
  local questname = "QuestFighting"
  local quest = SV.missions.Missions[questname]
	
  local days = SV.team_meditate.DaysSinceCheckpoint + 4
  
  if quest == nil then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Spar_Help_Line_001'], days))
	
	COMMON.CreateMission(questname,
	{ Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_RESCUE,
      DestZone = "sleeping_caldera", DestSegment = 0, DestFloor = 8,
      FloorUnknown = false,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("meditite", 0, "normal", Gender.Male),
      ClientSpecies = RogueEssence.Dungeon.MonsterID("makuhita", 0, "normal", Gender.Male) }
	)
  elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Spar_Help_Line_001'], days))
  else
    canyon_camp.Fighting_Complete()
  end
  
  elseif SV.team_meditate.Status == 4 then
    GROUND:CharTurnToChar(chara, player)
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Spar_Line_003']))
  elseif SV.team_meditate.Status == 5 then
    GROUND:CharTurnToChar(chara, player)
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Spar_Line_003']))
  end
end


function canyon_camp.Fighting_Complete()
  local monk = CH('NPC_Monk')
  local spar = CH('NPC_Spar')
  local player = CH('PLAYER')
  
  UI:SetSpeaker(spar)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Spar_Complete_Line_001']))
  
  UI:SetSpeaker(monk)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Spar_Complete_Line_002']))
  
  UI:SetSpeaker(spar)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Spar_Complete_Line_003']))
  
  local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_fighting_silk")
  COMMON.GiftItem(player, receive_item)
  
  COMMON.CompleteMission("QuestFighting")
  
  SV.team_meditate.Status = 4
end


  
function canyon_camp.NPC_Shortcut_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  
  if SV.team_solo.Status < 4 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shortcut_Line_001']))
  elseif SV.team_solo.Status == 4 then

  local questname = "QuestWater"
  local quest = SV.missions.Missions[questname]
	
  if quest == nil then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shortcut_Quest_Line_001']))
	
	COMMON.CreateMission(questname,
	{ Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_RESCUE,
      DestZone = "forsaken_desert", DestSegment = 0, DestFloor = 0,
      FloorUnknown = false,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("prinplup", 0, "normal", Gender.Male),
      ClientSpecies = RogueEssence.Dungeon.MonsterID("floatzel", 0, "normal", Gender.Male) }
	)
  elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shortcut_Quest_Line_002']))
  else
    canyon_camp.Water_Complete()
  end

  elseif SV.team_solo.Status == 5 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shortcut_Line_002']))
  elseif SV.team_solo.Status == 6 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shortcut_Line_002']))
  end
end

function canyon_camp.NPC_Solo_Action(chara, activator)
  
  
  if SV.team_solo.Status == 3 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Solo_Line_001']))
	GROUND:Hide("NPC_Solo")
    SV.team_solo.SpokenTo = true
  elseif SV.team_solo.Status == 4 then
    canyon_camp.Water_Complete()
  elseif SV.team_solo.Status == 5 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Solo_Line_002']))
  elseif SV.team_solo.Status == 6 then
    --TODO: cycle?
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Solo_Line_002']))
  end
end


function canyon_camp.Water_Complete()
  local shortcut = CH('NPC_Shortcut')
  local solo = CH('NPC_Solo')
  local player = CH('PLAYER')
  
  UI:SetSpeaker(shortcut)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shortcut_Complete_Line_001']))
  
  UI:SetSpeaker(solo)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shortcut_Complete_Line_002']))
  
  local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_water_silk")
  COMMON.GiftItem(player, receive_item)
  
  
  UI:SetSpeaker(shortcut)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shortcut_Complete_Line_003']))
  
  UI:SetSpeaker(solo)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shortcut_Complete_Line_004']))
  
  COMMON.CompleteMission("QuestWater")
  
  SV.team_solo.Status = 5
end

function canyon_camp.NPC_Seeker_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Seeker_Line_001']))
  SOUND:PlayBattleSE("EVT_Emote_Exclaim_2")
  GROUND:CharSetEmote(chara, "exclaim", 1)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  GAME:WaitFrames(30)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Seeker_Line_002']))
  GROUND:CharSetEmote(chara, "glowing", 4)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Seeker_Line_003']))
end
  
function canyon_camp.NPC_Hidden_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  
  local dungeon_id = 'sleeping_caldera'
  if not GAME:DungeonUnlocked(dungeon_id) then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Hidden_Line_001']))
    GAME:FadeOut(false, 20)
    GAME:WaitFrames(30)
    COMMON.UnlockWithFanfare(dungeon_id, false)
    GAME:WaitFrames(30)
    GAME:FadeIn(20)
  end
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Hidden_Line_002']))
  UI:SetSpeakerEmotion("Pain")
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Hidden_Line_003']))
end
  
function canyon_camp.NPC_NextCamp_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  
  if _DATA.Save:GetDungeonUnlock("forsaken_desert") == RogueEssence.Data.GameProgress.UnlockState.None then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Desert_Line_001']))
	COMMON.UnlockWithFanfare("forsaken_desert", false)
  else
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Desert_Line_002']))
  end
end
  
  
function canyon_camp.NPC_Goals_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  
  if SV.team_psychic.Status == 0 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Goals_Line_001']))
	
  elseif SV.team_psychic.Status == 1 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Goals_Line_002']))
  end
end


function canyon_camp.NPC_Strategy_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  
  if SV.team_psychic.Status == 0 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Strategy_Line_001']))
	
  elseif SV.team_psychic.Status == 1 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Strategy_Line_002']))
	
  elseif SV.team_psychic.Status == 3 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Strategy_Line_003']))
	
	SV.team_psychic.SpokenTo = true
  elseif SV.team_psychic.Status == 4 then
	canyon_camp.Psychic_Complete()
  elseif SV.team_psychic.Status == 5 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Strategy_Line_004']))
	
  elseif SV.team_psychic.Status == 6 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Strategy_Line_004']))
	
  end
end

function canyon_camp.NPC_Brains_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  
  if SV.team_psychic.Status == 3 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Brains_Line_001']))
	
  elseif SV.team_psychic.Status == 4 then
	
  local questname = "QuestPsychic"
  local quest = SV.missions.Missions[questname]
	
  if quest == nil then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Brains_Line_002']))
	
	COMMON.CreateMission(questname,
	{ Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_RESCUE,
      DestZone = "relic_tower", DestSegment = 0, DestFloor = 8,
      FloorUnknown = false,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("kirlia", 0, "normal", Gender.Male),
      ClientSpecies = RogueEssence.Dungeon.MonsterID("girafarig", 0, "normal", Gender.Male) }
	)
  elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Brains_Line_003']))
  else
    canyon_camp.Psychic_Complete()
  end
	
  elseif SV.team_psychic.Status == 5 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Brains_Line_004']))
	
  elseif SV.team_psychic.Status == 6 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Brains_Line_004']))
	
  end
end

function canyon_camp.Psychic_Complete()
  local strategy = CH('NPC_Strategy')
  local brains = CH('NPC_Brains')
  local player = CH('PLAYER')
  
  UI:SetSpeaker(strategy)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Strategy_Rescued_Line_001']))
  
  UI:SetSpeaker(brains)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Strategy_Rescued_Line_002']))
  
  UI:SetSpeaker(strategy)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Strategy_Rescued_Line_003']))
  
  local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_psychic_silk")
  COMMON.GiftItem(player, receive_item)
  
  
  COMMON.CompleteMission("QuestPsychic")
  
  SV.team_psychic.Status = 5
end

function canyon_camp.NPC_Fairy_Action(chara, activator)
  
  UI:SetSpeaker(chara)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Fairy_Line_001']))
end



function canyon_camp.Aggron_Fail()
  --everyone is dead
  GAME:FadeIn(20)
  --get back up
end

function canyon_camp.East_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local dungeon_entrances = { 'copper_quarry', 'depleted_basin', 'forsaken_desert', 'relic_tower', 'sleeping_caldera', 'royal_halls', 'starfall_heights', 'wisdom_road', 'sacred_tower'}
  local ground_entrances = {{Flag=SV.rest_stop.ExpositionComplete,Zone='guildmaster_island',ID=6,Entry=0},
  {Flag=SV.final_stop.ExpositionComplete,Zone='guildmaster_island',ID=7,Entry=0},
  {Flag=SV.guildmaster_summit.GameComplete,Zone='guildmaster_island',ID=8,Entry=0}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end

function canyon_camp.West_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local dungeon_entrances = { }
  local ground_entrances = {{Flag=true,Zone='guildmaster_island',ID=1,Entry=3},
  {Flag=SV.forest_camp.ExpositionComplete,Zone='guildmaster_island',ID=3,Entry=2},
  {Flag=SV.cliff_camp.ExpositionComplete,Zone='guildmaster_island',ID=4,Entry=2}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end



function canyon_camp.Assembly_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  COMMON.ShowTeamAssemblyMenu(obj, COMMON.RespawnAllies)
end

function canyon_camp.Storage_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON:ShowTeamStorageMenu()
end

function canyon_camp.Teammate1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara)
end

function canyon_camp.Teammate2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara)
end

function canyon_camp.Teammate3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara)
end

return canyon_camp