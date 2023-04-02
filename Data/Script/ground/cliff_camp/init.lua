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
    cliff_camp.BeginExposition()
    SV.cliff_camp.ExpositionComplete = true
  else
    GAME:FadeIn(20)
  end

end

function cliff_camp.Update(map, time)
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------
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
  {Flag=SV.guildmaster_summit.ExpositionComplete,Zone='guildmaster_island',ID=8,Entry=0}}
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

function cliff_camp.Speedster_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GROUND:CharTurnToChar(chara,CH('PLAYER'))--make the chara turn to the player
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
	if not SV.cliff_camp.TeamRetreatIntro then
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Doduo_Intro_001']))
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Doduo_Intro_002']))
	  GROUND:EntTurn(chara, Direction.DownLeft)
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Doduo_Intro_003']))
	  GROUND:CharTurnToChar(chara,CH('PLAYER'))
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Doduo_Intro_004']))
	  GROUND:EntTurn(chara, Direction.DownLeft)
	  SV.cliff_camp.TeamRetreatIntro = true
	else
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Doduo_Line_001']))
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Doduo_Line_002']))
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Doduo_Line_003']))
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Doduo_Line_004']))
	  GROUND:CharSetEmote(chara, "sweating", 1)
	  SOUND:PlayBattleSE("EVT_Emote_Sweating")
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Doduo_Line_005']))
	  GROUND:EntTurn(chara, Direction.DownLeft)
	end
end
  
function cliff_camp.Speedster_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GROUND:CharTurnToChar(chara,CH('PLAYER'))--make the chara turn to the player
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
	if not SV.cliff_camp.TeamRetreatIntro then
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Pachirisu_Intro_001']))
	  GROUND:EntTurn(chara, Direction.UpRight)
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Pachirisu_Intro_002']))
	  GROUND:CharTurnToChar(chara,CH('PLAYER'))
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Pachirisu_Intro_003']))
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Pachirisu_Intro_004']))
	  SV.cliff_camp.TeamRetreatIntro = true
	  GROUND:EntTurn(chara, Direction.UpRight)
	else
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Pachirisu_Line_001']))
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Pachirisu_Line_002']))
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Pachirisu_Line_003']))
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Pachirisu_Line_004']))
	  GROUND:EntTurn(chara, Direction.UpRight)
	end
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
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  if not SV.cliff_camp.RivalEarlyIntro then
    GROUND:CharTurnToChar(chara, player)--make the chara turn to the player
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_Line_001']))
	local receive_item = RogueEssence.Dungeon.InvItem("orb_escape")
	COMMON.GiftItem(player, receive_item)
	UI:SetSpeaker(chara)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_Line_002']))
    SV.cliff_camp.RivalEarlyIntro = true
	GROUND:EntTurn(chara, Direction.Right)
  else
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_Line_003']))
  end
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
  
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_001']))
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