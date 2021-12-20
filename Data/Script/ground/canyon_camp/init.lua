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
  local tutor_species = 0
  if SV.file.Starter.Species == 1 then
    tutor_species = 254
  elseif SV.file.Starter.Species == 4 then
    tutor_species = 257
  elseif SV.file.Starter.Species == 7 then
    tutor_species = 210
  elseif SV.file.Starter.Species == 25 then
    tutor_species = 26
  end
  charData.BaseForm = RogueEssence.Dungeon.MonsterID(tutor_species, 0, 0, Gender.Female)
  tutor.Data = charData
end

function canyon_camp.Enter(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine

  SV.checkpoint = 
  {
    Zone    = 1, Segment  = -1,
    Map  = 5, Entry  = 1
  }
  
  --when arriving the first time, play this cutscene
  if not SV.canyon_camp.ExpositionComplete then
    canyon_camp.BeginExposition()
    SV.canyon_camp.ExpositionComplete = true
  else
    GAME:FadeIn(20)
  end
end

function canyon_camp.Update(map, time)
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------
function canyon_camp.BeginExposition()

  UI:WaitShowTitle(GAME:GetCurrentGround().Name:ToLocal(), 20);
  GAME:WaitFrames(30);
  UI:WaitHideTitle(20);
  GAME:FadeIn(20)
  
  GAME:UnlockDungeon(16)
end

--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------
function canyon_camp.East_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local dungeon_entrances = { 5, 9, 16, 18 }
  local ground_entrances = {{Flag=SV.rest_stop.ExpositionComplete,Zone=1,ID=6,Entry=0},
  {Flag=SV.final_stop.ExpositionComplete,Zone=1,ID=7,Entry=0},
  {Flag=SV.guildmaster_summit.ExpositionComplete,Zone=1,ID=8,Entry=0}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end

function canyon_camp.West_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local dungeon_entrances = { }
  local ground_entrances = {{Flag=true,Zone=1,ID=1,Entry=3},
  {Flag=SV.forest_camp.ExpositionComplete,Zone=1,ID=3,Entry=2},
  {Flag=SV.cliff_camp.ExpositionComplete,Zone=1,ID=4,Entry=2}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
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
    if player.CurrentForm.Skin == 0 then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shiny_Line_001']))
    else
      SOUND:PlayBattleSE("EVT_Emote_Exclaim_2")
      GROUND:CharSetEmote(chara, 3, 1)
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
  
  local tutor_skill = 0
  if SV.file.Starter.Species == 1 then
    tutor_skill = 520
  elseif SV.file.Starter.Species == 4 then
    tutor_skill = 519
  elseif SV.file.Starter.Species == 7 then
    tutor_skill = 518
  elseif SV.file.Starter.Species == 25 then
    tutor_skill = 344
  end
  
  
  --after teaching, unlock the tutor back at the hub for ALL moves
  
end
  
function canyon_camp.NPC_Argue_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
end
  
function canyon_camp.NPC_Argue_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
end
  
function canyon_camp.NPC_Hidden_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
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