require 'common'

local canyon_camp = {}
local MapStrings = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function canyon_camp.Init(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_canyon_camp")
  MapStrings = COMMON.AutoLoadLocalizedStrings()
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
    canyon_camp.Steelix_Fail()
	SV.rest_stop.BossPhase = 1
  else
    canyon_camp.SetupNpcs()
    GAME:FadeIn(20)
  end
end

function canyon_camp.Update(map, time)
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------
function canyon_camp.SetupNpcs()
  GROUND:Unhide("NPC_Seeker")
  GROUND:Unhide("NPC_Hidden")
  GROUND:Unhide("NPC_Dragon_1")
  GROUND:Unhide("NPC_Dragon_2")
  GROUND:Unhide("NPC_Dragon_3")
  GROUND:Unhide("NPC_Strategy")
  GROUND:Unhide("NPC_Wall")
  GROUND:Unhide("NPC_NextCamp")
  --GROUND:Unhide("NPC_Argue_1")
  --GROUND:Unhide("NPC_Argue_2")
  
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

function canyon_camp.BeginExposition()

  UI:WaitShowTitle(GAME:GetCurrentGround().Name:ToLocal(), 20);
  GAME:WaitFrames(30);
  UI:WaitHideTitle(20);
  GAME:FadeIn(20)
  
  GAME:UnlockDungeon('copper_quarry')
  GAME:UnlockDungeon('forsaken_desert')
  GAME:UnlockDungeon('sleeping_caldera')
end

--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------

function canyon_camp.NPC_Storehouse_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
	
  if SV.supply_corps.Status <= 4 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_001']))
    SV.supply_corps.Status = 5
  elseif SV.supply_corps.Status == 5 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_001']))
  elseif SV.supply_corps.Status == 6 then
    local questname = "OutlawForest2"
    local quest = SV.missions.Missions[questname]
    if quest == nil then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_002']))
	  --add the quest
	  SV.missions.Missions[questname] = { Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_OUTLAW_HOUSE,
      DestZone = "flyaway_cliffs", DestSegment = 0, DestFloor = 6, FloorUnknown = true,
      ClientSpecies = chara.CurrentForm,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("toxicroak", 0, "normal", Gender.Male) }
    elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_003']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_004']))
      --give reward
        local receive_item = RogueEssence.Dungeon.InvItem("food_banana_big")
        COMMON.GiftItem(player, receive_item)
      --complete mission and move to done
      quest.Complete = COMMON.MISSION_ARCHIVED
      SV.missions.FinishedMissions[questname] = quest
      SV.missions.Missions[questname] = nil
      SV.supply_corps.Status = 7
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_005']))
    end
  elseif SV.supply_corps.Status == 7 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_006']))
  elseif SV.supply_corps.Status == 8 then
    local unlock = _DATA.Save:GetDungeonUnlock("ambush_forest") -- make this the dungeon unlock state
    if unlock == RogueEssence.Data.GameProgress.UnlockState.None then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_007']))
      COMMON.UnlockWithFanfare("ambush_forest", false)
    elseif unlock == RogueEssence.Data.GameProgress.UnlockState.Discovered then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_008']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_009']))
      --increase rank for bag space
      _DATA.Save.ActiveTeam:SetRank("bronze")
      SOUND:PlayFanfare("Fanfare/RankUp")
      UI:ResetSpeaker(false)
      UI:SetCenter(true)
	  local rank = _DATA:GetRank(_DATA.Save.ActiveTeam.Rank)
      UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("DLG_BAG_SIZE"):ToLocal(), rank.BagSize))
      UI:SetSpeaker(chara)
      UI:SetCenter(false)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_010']))
      SV.supply_corps.Status = 9
    end
  elseif SV.supply_corps.Status == 9 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_011']))
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_Route']))
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
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_001']))
    elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_002']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_003']))
    end
  elseif SV.supply_corps.Status == 7 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_004']))
  elseif SV.supply_corps.Status == 8 then
    local unlock = _DATA.Save:GetDungeonUnlock("ambush_forest") -- make this the dungeon unlock state
    if unlock == RogueEssence.Data.GameProgress.UnlockState.None then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_005']))
    elseif unlock == RogueEssence.Data.GameProgress.UnlockState.Discovered then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_006']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_007']))
    end
  elseif SV.supply_corps.Status == 9 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_008']))
  elseif SV.supply_corps.Status == 10 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_009']))
    SV.supply_corps.Status = 11
  elseif SV.supply_corps.Status == 11 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_009']))
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_Route']))
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
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_001']))
    elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_002']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_003']))
    end
  elseif SV.supply_corps.Status == 7 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_004']))
  elseif SV.supply_corps.Status == 8 then
    local unlock = _DATA.Save:GetDungeonUnlock("ambush_forest") -- make this the dungeon unlock state
    if unlock == RogueEssence.Data.GameProgress.UnlockState.None then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_005']))
    elseif unlock == RogueEssence.Data.GameProgress.UnlockState.Discovered then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_006']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_007']))
    end
  elseif SV.supply_corps.Status == 9 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_008']))
  elseif SV.supply_corps.Status == 10 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_009']))
	SV.supply_corps.Status = 11
  elseif SV.supply_corps.Status == 11 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_009']))
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_Route']))
  end
end

  
function canyon_camp.NPC_Dragon_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
end
  
function canyon_camp.NPC_Dragon_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
end
  
function canyon_camp.NPC_Dragon_3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
end
  
function canyon_camp.NPC_Shiny_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  GROUND:CharTurnToChar(chara, player)--make the chara turn to the player
  if not SV.canyon_camp.ShinyIntro then
    if player.CurrentForm.Skin == "normal" then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shiny_Line_001']))
    else
      SOUND:PlayBattleSE("EVT_Emote_Exclaim_2")
      GROUND:CharSetEmote(chara, "exclaim", 1)
	  GAME:WaitFrames(30)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shiny_Line_002']))
	  SV.canyon_camp.ShinyIntro = true
    end
  else
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shiny_Line_003']))
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
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Intro'], skillData:GetIconName()))
	
	local playerMonId = player.Data.BaseForm
	local monData = _DATA:GetMonster(playerMonId.Species)
	local formData = monData.Forms[playerMonId.Form]
	if formData:CanLearnSkill(tutor_skill) then
	  
	  UI:ChoiceMenuYesNo(STRINGS:Format(MapStrings['Tutor_Ask'], monData:GetColoredName(), skillData:GetIconName()), false)
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
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Incompatible']))
	end
  else
	--There are other tutors wandering around in the dungeons. They've spent too much time training in dungeons without outside contact, but I'm sure they'd appreciate company.
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Done']))
  end
	
  
end
  
function canyon_camp.NPC_Argue_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
end
  
function canyon_camp.NPC_Argue_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
end
  
function canyon_camp.NPC_Seeker_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seeker_Line_001']))
  SOUND:PlayBattleSE("EVT_Emote_Exclaim_2")
  GROUND:CharSetEmote(chara, "exclaim", 1)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  GAME:WaitFrames(30)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seeker_Line_002']))
  GROUND:CharSetEmote(chara, "glowing", 4)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seeker_Line_003']))
end
  
function canyon_camp.NPC_Hidden_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  
  local dungeon_id = 'secret_garden'
  if not GAME:DungeonUnlocked(dungeon_id) then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Hidden_Line_001']))
    GAME:FadeOut(false, 20)
    GAME:WaitFrames(30)
    COMMON.UnlockWithFanfare(dungeon_id, false)
    GAME:WaitFrames(30)
    GAME:FadeIn(20)
  end
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Hidden_Line_002']))
  UI:SetSpeakerEmotion("Pain")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Hidden_Line_003']))
end
  
function canyon_camp.NPC_Shortcut_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shortcut_Line_001']))
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shortcut_Line_002']))
end
  
function canyon_camp.NPC_NextCamp_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['NextCamp_Line_001']))
end
  
function canyon_camp.NPC_Strategy_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Strategy_Line_001']))
end

function canyon_camp.NPC_Fairy_Action(chara, activator)
  
  UI:SetSpeaker(chara)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Fairy_Line_001']))
end



function canyon_camp.Steelix_Fail()
  --everyone is dead
  GAME:FadeIn(20)
  --get back up
end

function canyon_camp.East_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local dungeon_entrances = { 'copper_quarry', 'forsaken_desert', 'relic_tower', 'sleeping_caldera', 'royal_halls', 'starfall_heights', 'wisdom_road', 'sacred_tower'}
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
  COMMON.GroundInteract(activator, chara, true)
end

function canyon_camp.Teammate2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

function canyon_camp.Teammate3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

return canyon_camp