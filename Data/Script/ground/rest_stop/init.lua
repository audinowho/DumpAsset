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
function rest_stop.North_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local dungeon_entrances = { 'thunderstruck_pass', 'veiled_ridge', 'snowbound_path', 'treacherous_mountain', 'hope_road', 'cave_of_whispers' }
  --also dungeon 21: royal halls, is accessible by ???
  --also dungeon 22: cave of solace, is accessible by having 8 key items
  local ground_entrances = {{Flag=SV.final_stop.ExpositionComplete,Zone='guildmaster_island',ID=7,Entry=0},
  {Flag=SV.guildmaster_summit.ExpositionComplete,Zone='guildmaster_island',ID=8,Entry=0}}
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