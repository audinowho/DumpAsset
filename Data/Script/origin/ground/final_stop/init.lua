require 'origin.common'

local final_stop = {}
local MapStrings = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function final_stop.Init(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_final_stop")
  MapStrings = COMMON.AutoLoadLocalizedStrings()
  COMMON.RespawnAllies()
  
  GROUND:AddMapStatus("snow")
end

function final_stop.Enter(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine

  SV.checkpoint = 
  {
    Zone    = 'guildmaster_island', Segment  = -1,
    Map  = 7, Entry  = 1
  }
  
  --when arriving the first time, play this cutscene
  if not SV.final_stop.ExpositionComplete then
    final_stop.SetupNpcs()
    final_stop.BeginExposition()
    SV.final_stop.ExpositionComplete = true
  elseif SV.guildmaster_summit.BossPhase == 2 then
    final_stop.SetupNpcs()
    final_stop.Summit_Fail()
	SV.guildmaster_summit.BossPhase = 1
  elseif SV.final_stop.DragonPhase == 2 then
    final_stop.SetupNpcs()
    final_stop.Dragon_Fail()
	SV.final_stop.DragonPhase = 1
  elseif SV.final_stop.DragonPhase == 3 then
    final_stop.SetupNpcs()
    final_stop.Dragon_Success()
	SV.final_stop.DragonPhase = 4
	SV.team_dragon.Status = 8
  else
    final_stop.SetupNpcs()
	
	final_stop.CheckMissions()
	
    GAME:FadeIn(20)
  end
end

function final_stop.Update(map, time)
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------
function final_stop.SetupNpcs()
  
  GROUND:Unhide("NPC_Secluded")
  GROUND:Unhide("NPC_Forbidden")
  
  if not SV.family.Brother and SV.family.BrotherActiveDays >= 3 then
	local forbidden = CH('NPC_Forbidden')
	GROUND:TeleportTo(forbidden, 292, 88, Direction.Down)
  elseif not SV.family.Grandma and SV.family.GrandmaActiveDays >= 3 and SV.family.Sister and SV.family.Mother and SV.family.Father and SV.family.Brother and SV.family.Pet then
	local forbidden = CH('NPC_Forbidden')
	GROUND:TeleportTo(forbidden, 292, 88, Direction.Down)
  end
  
  if SV.team_rivals.Status == 7 then
    GROUND:Unhide("Rival_1")
	GROUND:Unhide("Rival_2")
  elseif SV.team_rivals.Status == 9 then
    -- TODO cycling
  end

  if SV.team_dragon.Status == 7 then
    GROUND:Unhide("NPC_Dragon_1")
    GROUND:Unhide("NPC_Dragon_2")
    GROUND:Unhide("NPC_Dragon_3")
    GROUND:Unhide("NPC_Protege_Tutor")
	
	local dragon1 = CH('NPC_Dragon_1')
	local dragon2 = CH('NPC_Dragon_2')
	local dragon3 = CH('NPC_Dragon_3')
	local protegeTutor = CH('NPC_Protege_Tutor')
	
	if SV.final_stop.DragonPhase ~= 3 then
	  GROUND:TeleportTo(dragon1, 292, 184, Direction.Down)
	  GROUND:TeleportTo(dragon2, 264, 160, Direction.Down)
	  GROUND:TeleportTo(dragon3, 320, 160, Direction.Down)
	  GROUND:TeleportTo(protegeTutor, 292, 144, Direction.Down)
	end
  elseif SV.team_dragon.Status == 8 then
    GROUND:Unhide("NPC_Protege_Tutor")
	if SV.team_dragon.Cycle == 5 then
      GROUND:Unhide("NPC_Dragon_1")
      GROUND:Unhide("NPC_Dragon_2")
      GROUND:Unhide("NPC_Dragon_3")
	end
  end
  
  if SV.team_firecracker.Status == 3 then
    GROUND:Unhide("NPC_Seer")
  elseif SV.team_firecracker.Status == 4 then
    GROUND:Unhide("NPC_Seer")
	GROUND:Unhide("NPC_Conjurer")
  elseif SV.team_firecracker.Status == 5 and SV.team_firecracker.Cycle == 5 then
    GROUND:Unhide("NPC_Seer")
	GROUND:Unhide("NPC_Conjurer")
  end
  
  if SV.supply_corps.Status < 16 then
    --pass
  elseif SV.supply_corps.Status <= 16 then
    GROUND:Unhide("NPC_Carry")
    GROUND:Unhide("NPC_Deliver")
	
	--also add storehouse once he's saved
    local questname = "OutlawMountain2"
    local quest = SV.missions.Missions[questname]
    if quest ~= nil and quest.Complete == COMMON.MISSION_COMPLETE then
	  GROUND:Unhide("NPC_Storehouse")
	end
  elseif SV.supply_corps.Status <= 19 then
    GROUND:Unhide("NPC_Storehouse")
    GROUND:Unhide("NPC_Carry")
    GROUND:Unhide("NPC_Deliver")
  elseif SV.supply_corps.Status >= 20 then
    --cycle appearances
	if SV.supply_corps.ManagerCycle == 0 or SV.supply_corps.ManagerCycle == 6 then
	
	else
	  if SV.supply_corps.CarryCycle == 5 then
	    GROUND:Unhide("NPC_Carry")
	  end
	  if SV.supply_corps.DeliverCycle == 5 then
	    GROUND:Unhide("NPC_Deliver")
	  end
	  if SV.supply_corps.ManagerCycle == 5 then
	    GROUND:Unhide("NPC_Storehouse")
	  end
	end
  end
end


function final_stop.CheckMissions()
  local player = CH('PLAYER')
  
  local quest = SV.missions.Missions["EscortBrother"]
  if quest ~= nil then
    if quest.Complete == COMMON.MISSION_COMPLETE then
	
      --spawn her	  
      
      GAME:FadeIn(20)
      UI:WaitShowDialogue("Escort mission state: Complete.")
      
      --she walks off to sunflora
      UI:WaitShowDialogue("The brother drops something as he runs off.")
      
      SV.magnagate.Cards = SV.magnagate.Cards + 1
	  SV.family.Brother = true
      COMMON.GiftKeyItem(player, RogueEssence.StringKey("ITEM_KEY_CARD_MIST"):ToLocal())
	  COMMON.CompleteMission("EscortBrother")
	  
    end
  end
end

function final_stop.Summit_Fail()
  --everyone is dead
  UI:ResetSpeaker()
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Summit_Fail_Line_001']))
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Summit_Fail_Line_002']))
  
  GAME:FadeIn(20)
  --get back up
end


function final_stop.BeginExposition()
  
  UI:WaitShowTitle(GAME:GetCurrentGround().Name:ToLocal(), 20);
  GAME:WaitFrames(30);
  UI:WaitHideTitle(20);
  GAME:FadeIn(20)
  
  GAME:UnlockDungeon('champions_road')
end

--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------

  
function final_stop.Rival_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_1_Line_001']))
  
  SV.team_rivals.SpokenTo = true
end
  
function final_stop.Rival_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_2_Line_001']))
  
  SV.team_rivals.SpokenTo = true
end

function final_stop.NPC_Dragon_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  if SV.team_dragon.Status == 7 then
    final_stop.DragonTalk()
  elseif SV.team_dragon.Status == 8 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Dragon_Line_003']))
  end
end
  
function final_stop.NPC_Dragon_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  if SV.team_dragon.Status == 7 then
    final_stop.DragonTalk()
  elseif SV.team_dragon.Status == 8 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Dragon_Line_004']))
  end
end
  
function final_stop.NPC_Dragon_3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  if SV.team_dragon.Status == 7 then
    final_stop.DragonTalk()
  elseif SV.team_dragon.Status == 8 then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Dragon_Line_005']))
  end
end
  
function final_stop.NPC_Protege_Tutor_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  if SV.team_dragon.Status == 7 then
    final_stop.DragonTalk()
  elseif SV.team_dragon.Status == 8 then
    local player = CH('PLAYER')
    UI:SetSpeaker(chara)
    local tutor_skill = "draco_meteor"
	local skillData = _DATA:GetSkill(tutor_skill)
	
	local playerMonId = player.Data.BaseForm
	local monData = _DATA:GetMonster(playerMonId.Species)
	local formData = monData.Forms[playerMonId.Form]
	
	local already_learned = player.Data:HasBaseSkill(tutor_skill)
	if already_learned then
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Intro'], skillData:GetIconName()))
	elseif formData:CanLearnSkill(tutor_skill) then
	  
	  UI:ChoiceMenuYesNo(STRINGS:Format(MapStrings['Tutor_Ask'], skillData:GetIconName()), false)
	  UI:WaitForChoice()
	  result = UI:ChoiceResult()
	  
	  if result then
		--one more check against full list flow
		local replace_msg = STRINGS:Format(RogueEssence.StringKey("TALK_TUTOR_REPLACE"):ToLocal(), skillData:GetIconName())
		result = COMMON.LearnMoveFlow(player.Data, tutor_skill, replace_msg)
	  end
	  
	  if result then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Accept']))
      
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
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Taught']))
		
      --after teaching, unlock the tutor back at the hub
      --the other moves can be found in dungeons by wandering tutors
      SV.StarterTutor.Complete = true
      SV.base_town.TutorMoves[tutor_skill] = true
	  else
	    --come back if you change your mind.
	    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Decline']))
	  end
	else
	  --But the other townsfolk weren't interested in hearing about it.
	  --If only there was someone I could share this knowledge with.
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Intro'], skillData:GetIconName()))
	end
	
  end
end

function final_stop.DragonTalk()
  local dragon1 = CH('NPC_Dragon_1')
  local dragon2 = CH('NPC_Dragon_2')
  local dragon3 = CH('NPC_Dragon_3')
  local protegeTutor = CH('NPC_Protege_Tutor')
  
    UI:SetSpeaker(dragon1)

    UI:ChoiceMenuYesNo(STRINGS:Format(MapStrings['Dragon_Line_001']), true)
    UI:WaitForChoice()
    ch = UI:ChoiceResult()
  
    if ch then
      UI:SetSpeaker(dragon1)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Dragon_Accept']))
	  SV.final_stop.DragonPhase = 1
      SOUND:PlayBattleSE("EVT_Battle_Transition")
      GAME:FadeOut(true, 60)
      GAME:EnterDungeon('guildmaster_island', 0, 7, 0, RogueEssence.Data.GameProgress.DungeonStakes.Progress, true, true)
	else
      UI:SetSpeaker(dragon1)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Dragon_Decline']))
    end
  
end


function final_stop.Dragon_Fail()
  
  --everyone is dead
  GAME:FadeIn(20)
  local dragon1 = CH('NPC_Dragon_1')
  UI:SetSpeaker(dragon1)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Dragon_Fail_Line_001']))
  --move back into position
end

function final_stop.Dragon_Success()
  local player = CH('PLAYER')
  
  --they're dead
  --move back into position
  GAME:FadeIn(20)
  --congrats
  local dragon1 = CH('NPC_Dragon_1')
  UI:SetSpeaker(dragon1)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Dragon_Line_002']))
end



function final_stop.NPC_Seer_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine

  
  if SV.team_firecracker.Status == 3 then
    local questname = "QuestFire"
    local quest = SV.missions.Missions[questname]
	
    if quest == nil then
      UI:SetSpeaker(chara)
      GROUND:CharTurnToChar(chara,CH('PLAYER'))
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seer_Help_Line_001']))
	
	  COMMON.CreateMission(questname,
	{ Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_RESCUE,
        DestZone = "snowbound_path", DestSegment = 0, DestFloor = 10,
        FloorUnknown = false,
        TargetSpecies = RogueEssence.Dungeon.MonsterID("typhlosion", 1, "normal", Gender.Male),
        ClientSpecies = RogueEssence.Dungeon.MonsterID("delphox", 0, "normal", Gender.Male) }
	)
    elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
	  GROUND:CharTurnToChar(chara,CH('PLAYER'))
      UI:SetSpeaker(chara)
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seer_Help_Line_002']))
    else
      final_stop.Fire_Complete()
    end

  elseif SV.team_firecracker.Status < 5 then
    GROUND:CharTurnToChar(chara,CH('PLAYER'))
    UI:SetSpeaker(chara)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seer_Line_001']))
  else
    GROUND:CharTurnToChar(chara,CH('PLAYER'))
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seer_Line_002']))
  end
end

function final_stop.NPC_Conjurer_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GROUND:CharTurnToChar(chara,CH('PLAYER'))--make the chara turn to the player
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  
  if SV.team_firecracker.Status ~= 5 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Conjurer_Line_001']))
  else
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Conjurer_Line_002']))
  end
end


function final_stop.Fire_Complete()
  local seer = CH('NPC_Seer')
  local conjurer = CH('NPC_Conjurer')
  local player = CH('PLAYER')
  
  GROUND:CharTurnToChar(seer,player)
  
  UI:SetSpeaker(seer)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seer_Complete_Line_001']))
  
  GROUND:TeleportTo(conjurer, 360, 416, Direction.Up)
  GROUND:Unhide("NPC_Conjurer")
  
  UI:SetSpeaker(conjurer)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seer_Complete_Line_002']))
  
  UI:SetSpeaker(seer)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seer_Complete_Line_003']))
  
  UI:SetSpeaker(conjurer)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seer_Complete_Line_004']))
  
  UI:SetSpeaker(seer)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seer_Complete_Line_005']))
  
  UI:SetSpeaker(conjurer)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seer_Complete_Line_006']))
  
  GROUND:TeleportTo(conjurer, 392, 368, Direction.Up)
  GROUND:CharTurnToChar(conjurer,seer)
  
  UI:SetSpeaker(seer)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seer_Complete_Line_007']))
  
  local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_fire_silk")
  COMMON.GiftItem(player, receive_item)
  
  COMMON.CompleteMission("QuestFire")
  
  SV.team_firecracker.Status = 4
end


function final_stop.NPC_Storehouse_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  
  if SV.supply_corps.Status <= 16 then
    local questname = "OutlawMountain2"
    local quest = SV.missions.Missions[questname]
    if quest ~= nil and quest.Complete == COMMON.MISSION_COMPLETE then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_001']))
      --give reward
      local receive_item = RogueEssence.Dungeon.InvItem("tm_focus_blast")
      COMMON.GiftItem(player, receive_item)
      --complete mission and move to done
	  COMMON.CompleteMission(questname)
      SV.supply_corps.Status = 17
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_002']))
    end
  elseif SV.supply_corps.Status == 17 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_003']))
  elseif SV.supply_corps.Status == 18 then
    local unlock = _DATA.Save:GetDungeonUnlock("treacherous_mountain") -- make this the dungeon unlock state
    if unlock == RogueEssence.Data.GameProgress.UnlockState.None then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_004']))
      COMMON.UnlockWithFanfare("treacherous_mountain", false)
    elseif unlock == RogueEssence.Data.GameProgress.UnlockState.Discovered then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_005']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_006']))
      --increase rank for bag space
      _DATA.Save.ActiveTeam:SetRank("silver")
      SOUND:PlayFanfare("Fanfare/RankUp")
      UI:ResetSpeaker(false)
      UI:SetCenter(true)
	  local rank = _DATA:GetRank(_DATA.Save.ActiveTeam.Rank)
      UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("DLG_BAG_SIZE"):ToLocal(), rank.BagSize))
      UI:SetSpeaker(chara)
      UI:SetCenter(false)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_007']))
      SV.supply_corps.Status = 19
    end
  elseif SV.supply_corps.Status == 19 then
    if not SV.guildmaster_summit.GameComplete then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_008']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_009']))
    end
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_Route']))
  end
end


function final_stop.NPC_Carry_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  
  if SV.supply_corps.Status <= 16 then
    local questname = "OutlawMountain2"
    local quest = SV.missions.Missions[questname]
    if quest == nil then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_001']))
      --add the quest
      COMMON.CreateMission(questname,
	{ Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_OUTLAW_DISGUISE,
        DestZone = "snowbound_path", DestSegment = 0, DestFloor = 12,
        FloorUnknown = true,
        ClientSpecies = chara.CurrentForm,
        TargetSpecies = RogueEssence.Dungeon.MonsterID("zoroark", 1, "normal", Gender.Male),
        DisguiseSpecies = RogueEssence.Dungeon.MonsterID("swalot", 0, "normal", Gender.Male), DisguiseTalk = "DisguiseTalk", DisguiseHit = "DisguiseHit" }
		)
    elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_002']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_003']))
    end
  elseif SV.supply_corps.Status == 17 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_004']))
  elseif SV.supply_corps.Status == 18 then
    local unlock = _DATA.Save:GetDungeonUnlock("treacherous_mountain") -- make this the dungeon unlock state
    if unlock == RogueEssence.Data.GameProgress.UnlockState.None then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_005']))
    elseif unlock == RogueEssence.Data.GameProgress.UnlockState.Discovered then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_006']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_007']))
    end
  elseif SV.supply_corps.Status == 19 then
    if not SV.guildmaster_summit.GameComplete then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_008']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_009']))
    end
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_Route']))
  end
end


function final_stop.NPC_Deliver_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  
  if SV.supply_corps.Status <= 16 then
    local questname = "OutlawMountain2"
    local quest = SV.missions.Missions[questname]
    if quest == nil then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_001']))
    elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_002']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_003']))
    end
  elseif SV.supply_corps.Status == 17 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_004']))
  elseif SV.supply_corps.Status == 18 then
    local unlock = _DATA.Save:GetDungeonUnlock("treacherous_mountain") -- make this the dungeon unlock state
    if unlock == RogueEssence.Data.GameProgress.UnlockState.None then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_005']))
    elseif unlock == RogueEssence.Data.GameProgress.UnlockState.Discovered then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_006']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_007']))
    end
  elseif SV.supply_corps.Status == 19 then
    if not SV.guildmaster_summit.GameComplete then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_008']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_009']))
    end
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_Route']))
  end
end



function final_stop.NPC_Secluded_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GROUND:CharTurnToChar(chara,CH('PLAYER'))--make the chara turn to the player
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Secluded_Line_001']))
end

function final_stop.NPC_Forbidden_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))--make the chara turn to the player
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  
  if not SV.family.Brother and SV.family.BrotherActiveDays >= 3 then
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Hint_Brother_Line_001']))
  elseif not SV.family.Grandma and SV.family.GrandmaActiveDays >= 3 and SV.family.Sister and SV.family.Mother and SV.family.Father and SV.family.Brother and SV.family.Pet then
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Hint_Grandma_Line_001']))
  else
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Forbidden_Line_001']))
  
  end
end

function final_stop.North_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local dungeon_entrances = { 'champions_road', 'barren_tundra', 'cave_of_solace', 'labyrinth_of_the_lost' }
  local ground_entrances = {{Flag=SV.guildmaster_summit.GameComplete,Zone='guildmaster_island',ID=8,Entry=0}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end

function final_stop.South_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local dungeon_entrances = { }
  local ground_entrances = {{Flag=true,Zone='guildmaster_island',ID=1,Entry=3},
  {Flag=SV.forest_camp.ExpositionComplete,Zone='guildmaster_island',ID=3,Entry=2},
  {Flag=SV.cliff_camp.ExpositionComplete,Zone='guildmaster_island',ID=4,Entry=2},
  {Flag=SV.canyon_camp.ExpositionComplete,Zone='guildmaster_island',ID=5,Entry=2},
  {Flag=SV.rest_stop.ExpositionComplete,Zone='guildmaster_island',ID=6,Entry=2}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end


function final_stop.Assembly_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  COMMON.ShowTeamAssemblyMenu(obj, COMMON.RespawnAllies)
end

function final_stop.Storage_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON:ShowTeamStorageMenu()
end



function final_stop.Teammate1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara)
end

function final_stop.Teammate2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara)
end

function final_stop.Teammate3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara)
end


function final_stop.BrotherReminderActive()
  if SV.family.Brother == false and SV.family.BrotherActiveDays > 2 then
    return true
  end
  return false
end

return final_stop