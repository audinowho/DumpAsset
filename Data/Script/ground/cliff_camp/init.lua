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
    Zone    = 1, Segment  = -1,
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
  GAME:UnlockDungeon(4)
end
--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------
function cliff_camp.East_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  UI:WaitShowDialogue(STRINGS:Format("You've reached the end of the demo![pause=0] A winner is you!"))
  
  -- local dungeon_entrances = { 4, 11, 15, 17 }
  -- local ground_entrances = {{Flag=SV.canyon_camp.ExpositionComplete,Zone=1,ID=5,Entry=0},
  -- {Flag=SV.rest_stop.ExpositionComplete,Zone=1,ID=6,Entry=0},
  -- {Flag=SV.final_stop.ExpositionComplete,Zone=1,ID=7,Entry=0},
  -- {Flag=SV.guildmaster_summit.ExpositionComplete,Zone=1,ID=8,Entry=0}}
  -- COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end

function cliff_camp.West_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local dungeon_entrances = { }
  local ground_entrances = {{Flag=true,Zone=1,ID=1,Entry=3},
  {Flag=SV.forest_camp.ExpositionComplete,Zone=1,ID=3,Entry=2}}
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
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Doduo_Line_005']))
	  GROUND:CharSetEmote(chara, 5, 1)
	  SOUND:PlayBattleSE("EVT_Emote_Sweating")
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Doduo_Line_006']))
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
  GROUND:CharSetEmote(partner, 5, 1)
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
	local receive_item = RogueEssence.Dungeon.InvItem(250)
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

return cliff_camp