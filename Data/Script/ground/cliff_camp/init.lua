require 'common'

local cliff_camp = {}
local MapStrings = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function cliff_camp.Init(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_cliff_camp")
  MapStrings = COMMON.AutoLoadLocalizedStrings()
  COMMON.RespawnAllies()
  
  COMMON.CreateWalkArea("NPC_Sightseer", 144, 328, 48, 48)
end

function cliff_camp.Enter(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine

  SV.checkpoint = 
  {
    Zone    = 'guildmaster_island', Segment  = -1,
    Map  = 4, Entry  = 1
  }
  
  --when arriving the first time, play this cutscene
  if not SV.cliff_camp.ExpositionComplete then
    cliff_camp.SetupNpcs()
    cliff_camp.BeginExposition()
    SV.cliff_camp.ExpositionComplete = true
  else
    cliff_camp.SetupNpcs()
    GAME:FadeIn(20)
  end

end

function cliff_camp.Update(map, time)
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------
function cliff_camp.SetupNpcs()
  GROUND:Unhide("Monk")
  GROUND:Unhide("Rival_Early")
  GROUND:Unhide("Undergrowth_1")
  GROUND:Unhide("Undergrowth_2")
  GROUND:Unhide("NPC_Sightseer")
  
  if SV.supply_corps.Status <= 1 then
    GROUND:Unhide("NPC_Storehouse")
  elseif SV.supply_corps.Status <= 3 then
    GROUND:Unhide("NPC_Storehouse")
    GROUND:Unhide("NPC_Carry")
    GROUND:Unhide("NPC_Deliver")
  elseif SV.supply_corps.Status <= 5 then
    GROUND:Unhide("NPC_Carry")
    GROUND:Unhide("NPC_Deliver")
  elseif SV.supply_corps.Status >= 20 then
    --cycle appearances
	if SV.supply_corps.ManagerCycle == 0 or SV.supply_corps.ManagerCycle == 6 then
	
	else
	  if SV.supply_corps.CarryCycle == 2 then
	    GROUND:Unhide("NPC_Carry")
	  end
	  if SV.supply_corps.DeliverCycle == 2 then
	    GROUND:Unhide("NPC_Deliver")
	  end
	  if SV.supply_corps.ManagerCycle == 2 then
	    GROUND:Unhide("NPC_Storehouse")
	  end
	end
  end
end

function cliff_camp.BeginExposition()
  UI:WaitShowTitle(GAME:GetCurrentGround().Name:ToLocal(), 20);
  GAME:WaitFrames(30);
  UI:WaitHideTitle(20);
  GAME:FadeIn(20)
  GAME:UnlockDungeon('flyaway_cliffs')
  GAME:UnlockDungeon('fertile_valley')
end
--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------
function cliff_camp.East_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  
  local dungeon_entrances = { 'flyaway_cliffs', 'fertile_valley', 'wayward_wetlands', 'deserted_fortress', 'bravery_road', 'geode_underpass', 'the_sky' }
  local ground_entrances = {{Flag=SV.canyon_camp.ExpositionComplete,Zone='guildmaster_island',ID=5,Entry=0},
  {Flag=SV.rest_stop.ExpositionComplete,Zone='guildmaster_island',ID=6,Entry=0},
  {Flag=SV.final_stop.ExpositionComplete,Zone='guildmaster_island',ID=7,Entry=0},
  {Flag=SV.guildmaster_summit.GameComplete,Zone='guildmaster_island',ID=8,Entry=0}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end

function cliff_camp.West_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local dungeon_entrances = { }
  local ground_entrances = {{Flag=true,Zone='guildmaster_island',ID=1,Entry=3},
  {Flag=SV.forest_camp.ExpositionComplete,Zone='guildmaster_island',ID=3,Entry=2}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end


function cliff_camp.Assembly_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  COMMON.ShowTeamAssemblyMenu(obj, COMMON.RespawnAllies)
end

function cliff_camp.Storage_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON:ShowTeamStorageMenu()
end



function cliff_camp.Teammate1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

function cliff_camp.Teammate2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

function cliff_camp.Teammate3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

function cliff_camp.Undergrowth_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GROUND:CharTurnToChar(chara,CH('PLAYER'))--make the chara turn to the player
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  if not SV.cliff_camp.TeamUndergrowthIntro then
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Undergrowth_Intro_001']))
	SV.cliff_camp.TeamUndergrowthIntro = true
  end
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Bellsprout_Line_001']))
  UI:SetSpeakerEmotion("Worried")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Bellsprout_Line_002']))
  GROUND:EntTurn(chara, Direction.DownRight)
end
  
function cliff_camp.Undergrowth_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shroomish_Line_001']))
  
  local partner = CH('Undergrowth_1')
  UI:SetSpeaker(partner)
  UI:SetSpeakerEmotion("Pain")
  GROUND:CharSetEmote(partner, "sweating", 1)
  SOUND:PlayBattleSE("EVT_Emote_Sweating")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Bellsprout_Line_003']))
end
  
function cliff_camp.Rival_Early_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_Line_001']))
end
  
function cliff_camp.Monk_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:SetSpeaker(chara)
  local player = CH('PLAYER')
  GROUND:CharTurnToChar(chara, player)
  
  local quest_choices = {STRINGS:Format(MapStrings['Monk_Option_Fame']), STRINGS:Format(MapStrings['Monk_Option_Fortune']),
    STRINGS:Format(MapStrings['Monk_Option_Curiosity']), STRINGS:Format(MapStrings['Monk_Option_Strength']),
    STRINGS:Format(MapStrings['Monk_Option_Unknown'])}
  
  UI:BeginChoiceMenu(STRINGS:Format(MapStrings['Monk_Line_001']), quest_choices, 1, 5)
  UI:WaitForChoice()
  local result = UI:ChoiceResult()
  if result == 1 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Monk_Line_Fame']))
  elseif result == 2 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Monk_Line_Fortune']))
  elseif result == 3 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Monk_Line_Curiosity']))
  elseif result == 4 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Monk_Line_Strength']))
  else
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Monk_Line_Unknown']))
  end
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Monk_Line_002']))
  GROUND:EntTurn(chara, Direction.Up)
end

function cliff_camp.NPC_Storehouse_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  local carry = CH('NPC_Carry')
  local deliver = CH('NPC_Deliver')
  UI:SetSpeaker(chara)
  
  if SV.supply_corps.Status <= 0 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_001'], carry:GetDisplayName(), deliver:GetDisplayName()))
  elseif SV.supply_corps.Status == 1 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_002']))
  elseif SV.supply_corps.Status == 2 then
    local questname = "OutlawForest1"
    local quest = SV.missions.Missions[questname]
    if quest == nil then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_003']))
	  --add the quest
	  SV.missions.Missions[questname] = { Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_OUTLAW,
      DestZone = "faded_trail", DestSegment = 0, DestFloor = 5, FloorUnknown = true,
      ClientSpecies = chara.CurrentForm,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("murkrow", 0, "normal", Gender.Male) }
	elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_004']))
	else
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_005']))
	  --give reward
      local receive_item = RogueEssence.Dungeon.InvItem("food_apple_huge")
      COMMON.GiftItem(player, receive_item)
	  --complete mission and move to done
	  quest.Complete = COMMON.MISSION_ARCHIVED
	  SV.missions.FinishedMissions[questname] = quest
	  SV.missions.Missions[questname] = nil
	  SV.supply_corps.Status = 3
	end
  elseif SV.supply_corps.Status == 3 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_006']))
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_Route']))
  end
end


function cliff_camp.NPC_Carry_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)
  
  
  if SV.supply_corps.Status == 2 then
    local questname = "OutlawForest1"
    local quest = SV.missions.Missions[questname]
    if quest == nil then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_001']))
    elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_002']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_003']))
    end
  elseif SV.supply_corps.Status == 3 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_004']))
  elseif SV.supply_corps.Status == 4 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_005']))
	SV.supply_corps.Status = 5
  elseif SV.supply_corps.Status == 5 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_005']))
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_Route']))
  end
  
end

function cliff_camp.NPC_Deliver_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)
  
  if SV.supply_corps.Status == 2 then
    local questname = "OutlawForest1"
    local quest = SV.missions.Missions[questname]
    if quest == nil then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_001']))
    elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_002']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_003']))
    end
  elseif SV.supply_corps.Status == 3 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_004']))
  elseif SV.supply_corps.Status == 4 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_005']))
    SV.supply_corps.Status = 5
  elseif SV.supply_corps.Status == 5 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_005']))
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_Route']))
  end
end


function cliff_camp.NPC_Sightseer_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:SetSpeaker(chara)
  local player = CH('PLAYER')
  GROUND:CharTurnToChar(chara, player)
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Sightseer_Line_001']))
end

function cliff_camp.NPC_DexRater_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  --ability capsule
  --magenta silk
  --bravery road
  --friend bow
  
  local rewardReqs = { 15, 30, 60 }
  --local rewardReqs = { 15, 30, 60, 100, 151, 251, 386 }
  
  UI:SetSpeaker(chara)
  local player = CH('PLAYER')
  GROUND:CharTurnToChar(chara, player)
  
  --Ring the bell, and your friends will gather, isn't that wonderful?
  --How many kinds of Pokemon have you befriended?
  --XX!  Wow!
  --Let me show you a secret dungeon
  --Let me give you this!
  --If you get to XX, I'll give you something special~
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['DexRater_Intro_001']))
  
  local dexCompletion = _DATA.Save:GetTotalMonsterUnlock(RogueEssence.Data.GameProgress.UnlockState.Completed)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['DexRater_Check_001'], GAME:GetTeamName(), dexCompletion))
  
  if SV.dex.CurrentRewardIdx > #rewardReqs then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['DexRater_Full_001']))
  else 
    suffix = ""
    while SV.dex.CurrentRewardIdx <= #rewardReqs and dexCompletion >= rewardReqs[SV.dex.CurrentRewardIdx] do
	  if SV.dex.CurrentRewardIdx == 1 then
		UI:WaitShowDialogue(STRINGS:Format(MapStrings['DexRater_Reward_Dungeon'..suffix]))
		COMMON.UnlockWithFanfare("lava_floe_island", false)
		SV.base_camp.FerryUnlocked = true
	  elseif SV.dex.CurrentRewardIdx == 2 then
		UI:WaitShowDialogue(STRINGS:Format(MapStrings['DexRater_Reward_Item'..suffix]))
		local receive_item = RogueEssence.Dungeon.InvItem("machine_ability_capsule")
		COMMON.GiftItem(player, receive_item)
	  elseif SV.dex.CurrentRewardIdx == 3 then
		UI:WaitShowDialogue(STRINGS:Format(MapStrings['DexRater_Reward_Item'..suffix]))
		local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_fairy_silk")
		COMMON.GiftItem(player, receive_item)
	  elseif SV.dex.CurrentRewardIdx == 4 then
		UI:WaitShowDialogue(STRINGS:Format(MapStrings['DexRater_Reward_Dungeon'..suffix]))
		COMMON.UnlockWithFanfare("bravery_road", false)
	  elseif SV.dex.CurrentRewardIdx == 5 then
		UI:WaitShowDialogue(STRINGS:Format(MapStrings['DexRater_Reward_Item'..suffix]))
		local receive_item = RogueEssence.Dungeon.InvItem("held_friend_bow")
		COMMON.GiftItem(player, receive_item)
	  elseif SV.dex.CurrentRewardIdx == 6 then
		UI:WaitShowDialogue(STRINGS:Format(MapStrings['DexRater_Reward_Dungeon'..suffix]))
		COMMON.UnlockWithFanfare("labyrinth_of_the_lost", false)
	  end
	  SV.dex.CurrentRewardIdx = SV.dex.CurrentRewardIdx + 1
	  suffix = "_Alt"
	end
	
	if SV.dex.CurrentRewardIdx <= #rewardReqs then
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['DexRater_Next_001'], rewardReqs[SV.dex.CurrentRewardIdx]))
	end
  end
  
end

return cliff_camp