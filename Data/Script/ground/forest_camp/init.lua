require 'common'

local forest_camp = {}
local MapStrings = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function forest_camp.Init(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_forest_camp")
  MapStrings = COMMON.AutoLoadLocalizedStrings()
  COMMON.RespawnAllies()
  
  
  local snorlax = CH('Snorlax')
  GROUND:CharSetAnim(snorlax, "Sleep", true)
end

function forest_camp.Enter(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine

  SV.checkpoint = 
  {
    Zone    = 1, Segment  = -1,
    Map  = 3, Entry  = 1
  }
  
  --when arriving the first time, play this cutscene
  if not SV.forest_camp.ExpositionComplete then
    forest_camp.BeginExposition()
    SV.forest_camp.ExpositionComplete = true
  else
    GAME:FadeIn(20)
  end
  
  -- TODO: move this back to BeginExposition
  GAME:UnlockDungeon(3)
  GAME:UnlockDungeon(36)
end

function forest_camp.Update(map, time)
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------
function forest_camp.BeginExposition()
  
  UI:WaitShowTitle(GAME:GetCurrentGround().Name:ToLocal(), 20)
  GAME:WaitFrames(30)
  UI:WaitHideTitle(20)
  GAME:FadeIn(20)
  
  
end

--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------
function forest_camp.North_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local dungeon_entrances = { 3, 36, 13, 14, 20, 30, 37}
  local ground_entrances = {{Flag=SV.cliff_camp.ExpositionComplete,Zone=1,ID=4,Entry=0},
  {Flag=SV.canyon_camp.ExpositionComplete,Zone=1,ID=5,Entry=0},
  {Flag=SV.rest_stop.ExpositionComplete,Zone=1,ID=6,Entry=0},
  {Flag=SV.final_stop.ExpositionComplete,Zone=1,ID=7,Entry=0},
  {Flag=SV.guildmaster_summit.ExpositionComplete,Zone=1,ID=8,Entry=0}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end

function forest_camp.South_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local dungeon_entrances = { }
  local ground_entrances = {{Flag=true,Zone=1,ID=1,Entry=3}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end

function forest_camp.Assembly_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  COMMON.ShowTeamAssemblyMenu(obj, COMMON.RespawnAllies)
end

function forest_camp.Storage_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON:ShowTeamStorageMenu()
end

function forest_camp.Snorlax_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:ResetSpeaker()
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Sleeper_Line_001']))
  
  
  --SOUND:PlayBattleSE("EVT_Battle_Transition")
  --GAME:FadeOut(true, 60)
  --GAME:EnterDungeon(1, 0, 3, 0, RogueEssence.Data.GameProgress.DungeonStakes.Progress, true, true)
end

function forest_camp.NPC_Carry_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)
  UI:SetSpeakerEmotion("Angry")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_001']))
  UI:SetSpeakerEmotion("Stunned")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_002']))
  GROUND:EntTurn(chara, Direction.Left)
end

function forest_camp.NPC_Deliver_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)
  UI:SetSpeakerEmotion("Pain")
  
  SOUND:PlayBattleSE("EVT_Emote_Sweating")
  GROUND:CharSetEmote(chara, 5, 1)
  GAME:WaitFrames(30)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_001']))
  GROUND:EntTurn(chara, Direction.Right)
end

function forest_camp.NPC_Camps_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Camps_Line_001']))
end




function forest_camp.Teammate1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

function forest_camp.Teammate2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

function forest_camp.Teammate3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

return forest_camp