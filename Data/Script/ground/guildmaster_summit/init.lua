require 'common'

local guildmaster_summit = {}
local MapStrings = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function guildmaster_summit.Init(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_guildmaster_summit")
  MapStrings = COMMON.AutoLoadLocalizedStrings()
  COMMON.RespawnAllies()
end

function guildmaster_summit.Enter(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine

  if SV.guildmaster_summit.GameComplete then
    guildmaster_summit.SetupNpcs()
    if SV.guildmaster_trail.FloorsCleared >= 30 and SV.guildmaster_trail.Rewarded == false then
      guildmaster_summit.RewardDialogue()
      SV.guildmaster_trail.Rewarded = true
    else
        GAME:FadeIn(20)
    end
  else
    if SV.guildmaster_summit.BossPhase == 0 then
      guildmaster_summit.PreBattle(false)
    elseif SV.guildmaster_summit.BossPhase == 1 then
      guildmaster_summit.PreBattle(true)
    elseif SV.guildmaster_summit.BossPhase == 3 then
      guildmaster_summit.PostBattle()
    end
  end
  
  
end

function guildmaster_summit.Update(map, time)
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------
function guildmaster_summit.SetupNpcs()
  
  if SV.team_rivals.Status == 8 then
    GROUND:Unhide("NPC_Rival_1")
	GROUND:Unhide("NPC_Rival_2")
  elseif SV.team_rivals.Status == 9 then
    -- TODO cycling
  end
  
  if SV.supply_corps.Status >= 20 then
	if SV.supply_corps.ManagerCycle == 6 then
	  GROUND:Unhide("NPC_Carry")
	  GROUND:Unhide("NPC_Deliver")
	  GROUND:Unhide("NPC_Storehouse")
	end
  end
end

function guildmaster_summit.RewardDialogue()
  
  GAME:CutsceneMode(true)
  local player = CH('PLAYER')
  local noctowl = CH('Noctowl')
  
  GROUND:Unhide("Noctowl")
  
  local team1 = CH('Teammate1')
  local team2 = CH('Teammate2')
  local team3 = CH('Teammate3')
  GROUND:TeleportTo(player, 196, 280, Direction.Up)
  if team1 ~= nil then
    GROUND:TeleportTo(team1, 168, 280, Direction.Up)
  end
  if team2 ~= nil then
    GROUND:TeleportTo(team2, 224, 280, Direction.Up)
  end
  if team3 ~= nil then
    GROUND:TeleportTo(team3, 196, 304, Direction.Up)
  end
  
  GAME:FadeIn(20)
	
  UI:SetSpeaker(noctowl)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Noctowl_Reward_Line_001']))
  --UI:WaitShowDialogue("Where did you come from...?")
  --UI:WaitShowDialogue("Could it be...?")
  
  GROUND:CharAnimateTurnTo(noctowl, Direction.Down, 4)
  
  
  --UI:WaitShowDialogue("When the guildmasters first put up the challenge, I was there.")
  --UI:WaitShowDialogue("I witnessed them set off for the summit, never to return.")
  --UI:WaitShowDialogue("Countless others followed, but never succeeded.")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Noctowl_Reward_Line_002']))
  
  GROUND:MoveInDirection(noctowl, Direction.Down, 24, false, 2)
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Noctowl_Reward_Line_003']))
  
  local receive_item = RogueEssence.Dungeon.InvItem("apricorn_perfect")
  COMMON.GiftItem(player, receive_item)
  
  
  GAME:FadeOut(false, 20)
  
  
  if team1 ~= nil then
    GROUND:TeleportTo(team1, 160, 176, Direction.Up)
  end
  if team2 ~= nil then
    GROUND:TeleportTo(team2, 232, 176, Direction.Up)
  end
  if team3 ~= nil then
    GROUND:TeleportTo(team3, 196, 200, Direction.Up)
  end
  
  GAME:WaitFrames(60)
  
  GAME:CutsceneMode(false)
  
  GROUND:Hide("Noctowl")
  
  GAME:FadeIn(20)
  
end

function guildmaster_summit.PreBattle(shortened)
  -- play cutscene
  
  GAME:WaitFrames(60)
  GAME:CutsceneMode(true)
  
  GROUND:Unhide("Xatu")
  GROUND:Unhide("Lucario")
  GROUND:Unhide("Wigglytuff")

  UI:WaitShowTitle(GAME:GetCurrentGround().Name:ToLocal(), 40)
  GAME:WaitFrames(60)
  UI:WaitHideTitle(40)
  GAME:WaitFrames(30)
  -- move characters to beside the player
  local player = CH('PLAYER')
  local team1 = CH('Teammate1')
  local team2 = CH('Teammate2')
  local team3 = CH('Teammate3')
  GROUND:TeleportTo(player, 196, 244, Direction.Up)
  if team1 ~= nil then
    GROUND:TeleportTo(team1, 168, 244, Direction.Up)
  end
  if team2 ~= nil then
    GROUND:TeleportTo(team2, 224, 244, Direction.Up)
  end
  if team3 ~= nil then
    GROUND:TeleportTo(team3, 196, 272, Direction.Up)
  end
  
  
  GAME:FadeIn(40)
  local xatu = CH('Xatu')
  local lucario = CH('Lucario')
  local wigglytuff = CH('Wigglytuff')
  -- trigger the battle and set a variable indicating its triggering
  UI:SetSpeaker("*", true, -1)
  if shortened then
    UI:WaitShowDialogue("Shortened")
  end
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_001']))
  GAME:WaitFrames(10)
  GAME:MoveCamera(0, -72, 60, true)
  GAME:WaitFrames(10)
  GROUND:CharAnimateTurnTo(xatu, Direction.Down, 4)
  GROUND:CharAnimateTurnTo(lucario, Direction.Down, 4)
  GROUND:CharAnimateTurnTo(wigglytuff, Direction.Down, 4)
  GAME:WaitFrames(20)
  UI:SetSpeaker(xatu)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_002']))
  
  
  if _DATA.Save.ActiveTeam.Name == "" then
    
  --Who are the ones that stand before us?
  --What do you call your team?
  --To follow in our steps is no easy endeavor...
  
	UI:SetSpeaker(xatu)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Ending_Cutscene_Line_Ask_001']))
	
    local ch = false
    local name = ""
    while not ch do
      UI:NameMenu(STRINGS:FormatKey("INPUT_TEAM_TITLE"), STRINGS:Format(""))
      UI:WaitForChoice()
      name = UI:ChoiceResult()
    
	  UI:ResetSpeaker()
      UI:ChoiceMenuYesNo(STRINGS:Format(MapStrings['Ending_Cutscene_Line_Ask_002'], name), true)
      UI:WaitForChoice()
      ch = UI:ChoiceResult()
    end
    GAME:SetTeamName(name)
    
  end
  
  UI:SetSpeaker(xatu)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_003'], GAME:GetTeamName()))
  GAME:WaitFrames(10)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_005']))
  GAME:WaitFrames(10)
  UI:SetSpeaker(lucario)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_006']))
  GAME:WaitFrames(10)
  UI:SetSpeaker(wigglytuff)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_007']))
  GAME:WaitFrames(10)
    
  SOUND:FadeOutBGM()
  
  UI:SetSpeaker(xatu)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_008']))
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_009']))
  
  SOUND:PlayBGM("C06. Final Battle.ogg", false)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_010'], GAME:GetTeamName()))
  GAME:WaitFrames(10)
  SOUND:PlayBattleSE("DUN_Bird_Caw")
  
  
  local animId = RogueEssence.Content.GraphicsManager.GetAnimIndex("Shoot")
  GROUND:CharSetAction(xatu, RogueEssence.Ground.PoseGroundAction(xatu.Position, xatu.Direction, animId))--110
  GAME:WaitFrames(10)
  animId = RogueEssence.Content.GraphicsManager.GetAnimIndex("Chop")
  GROUND:CharSetAction(lucario, RogueEssence.Ground.PoseGroundAction(lucario.Position, lucario.Direction, animId))--100
  
  animId = RogueEssence.Content.GraphicsManager.GetAnimIndex("Shoot")
  GROUND:CharSetAction(wigglytuff, RogueEssence.Ground.PoseGroundAction(wigglytuff.Position, wigglytuff.Direction, animId))--100
  
  GAME:WaitFrames(10)
  SOUND:PlayBattleSE("EVT_Fade_White")
  GAME:FadeOut(true, 80)
  GAME:CutsceneMode(false)
  
  SV.guildmaster_summit.BossPhase = 1
  
  GAME:ContinueDungeon('guildmaster_island', 0,8, 0)
end

function guildmaster_summit.PostBattle()
  --warp the player back to the start, set exposition complete, save and continue, and play credits.
  
  GAME:CutsceneMode(true)
  
  GROUND:Unhide("Xatu")
  GROUND:Unhide("Lucario")
  GROUND:Unhide("Wigglytuff")

  
  local player = CH('PLAYER')
  local team1 = CH('Teammate1')
  local team2 = CH('Teammate2')
  local team3 = CH('Teammate3')
  GROUND:TeleportTo(player, 196, 244, Direction.Up)
  if team1 ~= nil then
    GROUND:TeleportTo(team1, 168, 244, Direction.Up)
  end
  if team2 ~= nil then
    GROUND:TeleportTo(team2, 224, 244, Direction.Up)
  end
  if team3 ~= nil then
    GROUND:TeleportTo(team3, 196, 272, Direction.Up)
  end
  
  local xatu = CH('Xatu')
  local lucario = CH('Lucario')
  local wigglytuff = CH('Wigglytuff')
  
  GROUND:EntTurn(xatu, Direction.Down)
  GROUND:EntTurn(lucario, Direction.Down)
  GROUND:EntTurn(wigglytuff, Direction.Down)
  
  SOUND:PlayBGM("A08. Aftermath.ogg", false)
  
  GAME:MoveCamera(0, -72, 0, true)
  GAME:FadeIn(40)
  

  UI:SetSpeaker(xatu)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Ending_Cutscene_Line_001']))
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Ending_Cutscene_Line_002']))
  GAME:WaitFrames(10)
  UI:SetSpeaker(lucario)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Ending_Cutscene_Line_003']))
  GAME:WaitFrames(10)
  UI:SetSpeaker(wigglytuff)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Ending_Cutscene_Line_004']))
  
  UI:SetSpeaker(lucario)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Ending_Cutscene_Line_005']))
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Ending_Cutscene_Line_006']))
  GAME:WaitFrames(10)
  
  UI:SetSpeaker(xatu)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Ending_Cutscene_Line_007'], GAME:GetTeamName()))

  SOUND:PlayBattleSE("DUN_Bird_Caw")
  local animId = RogueEssence.Content.GraphicsManager.GetAnimIndex("Shoot")
  GROUND:CharSetAction(xatu, RogueEssence.Ground.PoseGroundAction(xatu.Position, xatu.Direction, animId))--200
  GAME:WaitFrames(80)

  GAME:FadeOut(false, 40)

  if GAME:InRogueMode() then

      UI:SetAutoFinish(true)
	  GAME:WaitFrames(60)
	  UI:WaitShowVoiceOver(STRINGS:Format(MapStrings['Ending_Cutscene_Line_008'], GAME:GetTeamName()), -1)
	  GAME:WaitFrames(20);
	  UI:WaitShowVoiceOver(STRINGS:Format(MapStrings['Ending_Cutscene_Line_009']), -1)
	  GAME:WaitFrames(20);
	  UI:WaitShowVoiceOver(STRINGS:Format(MapStrings['Ending_Cutscene_Line_010']), -1)
	  GAME:WaitFrames(20);
	  UI:WaitShowVoiceOver(STRINGS:Format(MapStrings['Ending_Cutscene_Line_011']), -1)
	  GAME:WaitFrames(20);
	  UI:WaitShowVoiceOver(STRINGS:Format(MapStrings['Ending_Cutscene_Line_012']), -1)
      UI:SetAutoFinish(false)
	  GAME:AddToPlayerMoneyBank(100000)
  else
      guildmaster_summit.can_skip = false
	  GAME:WaitFrames(180)
      guildmaster_summit.RollCredits()
  end
  
  SOUND:FadeOutBGM()
  GAME:WaitFrames(160);
  
  SV.guildmaster_summit.BossPhase = 4
  SV.guildmaster_summit.GameComplete = true
  GAME:CutsceneMode(false)
  
  local dungeon_to_clear = "champions_road"
  if SV.guildmaster_summit.ClearedFromTrail then
    dungeon_to_clear = "guildmaster_trail"
	SV.guildmaster_trail.FloorsCleared = 30
  end
  COMMON.EndDayCycle()
  GAME:EndDungeonRun(RogueEssence.Data.GameProgress.ResultType.Cleared, 'guildmaster_island', -1, 1, 0, true, false, dungeon_to_clear)
  GAME:RestartToTitle()
end


function guildmaster_summit.RollCredits()

      UI:SetAutoFinish(true)
	  UI:WaitShowTitle(STRINGS:Format(MapStrings['Credits_Line_001']), 60)
	  GAME:WaitFrames(180)
	  UI:WaitHideTitle(60)
	  if guildmaster_summit.can_skip == true and guildmaster_summit.credit_skip == true then
	    return
	  end
	  
	  GAME:WaitFrames(60)
	  if guildmaster_summit.can_skip == true and guildmaster_summit.credit_skip == true then
	    return
	  end
	  UI:WaitShowVoiceOver(STRINGS:Format(MapStrings['Credits_Line_002']), 210)
	  if guildmaster_summit.can_skip == true and guildmaster_summit.credit_skip == true then
	    return
	  end
	  
	  GAME:WaitFrames(60)
	  if guildmaster_summit.can_skip == true and guildmaster_summit.credit_skip == true then
	    return
	  end
	  UI:WaitShowVoiceOver(STRINGS:Format(MapStrings['Credits_Line_003']), 210)
	  if guildmaster_summit.can_skip == true and guildmaster_summit.credit_skip == true then
	    return
	  end
	  
	  GAME:WaitFrames(60)
	  if guildmaster_summit.can_skip == true and guildmaster_summit.credit_skip == true then
	    return
	  end
	  UI:WaitShowVoiceOver(STRINGS:Format(MapStrings['Credits_Line_004']), 210)
	  if guildmaster_summit.can_skip == true and guildmaster_summit.credit_skip == true then
	    return
	  end
	  
	  GAME:WaitFrames(60)
	  if guildmaster_summit.can_skip == true and guildmaster_summit.credit_skip == true then
	    return
	  end
	  UI:WaitShowVoiceOver(STRINGS:Format(MapStrings['Credits_Line_005']), 210)
	  if guildmaster_summit.can_skip == true and guildmaster_summit.credit_skip == true then
	    return
	  end
	  
	  GAME:WaitFrames(60)
	  if guildmaster_summit.can_skip == true and guildmaster_summit.credit_skip == true then
	    return
	  end
	  UI:WaitShowVoiceOver(STRINGS:Format(MapStrings['Credits_Line_006']), 210)
	  if guildmaster_summit.can_skip == true and guildmaster_summit.credit_skip == true then
	    return
	  end
	  
	  GAME:WaitFrames(60)
	  if guildmaster_summit.can_skip == true and guildmaster_summit.credit_skip == true then
	    return
	  end
	  UI:WaitShowVoiceOver(STRINGS:Format(MapStrings['Credits_Line_007']), 210)
	  if guildmaster_summit.can_skip == true and guildmaster_summit.credit_skip == true then
	    return
	  end
	  
	  GAME:WaitFrames(60)
	  if guildmaster_summit.can_skip == true and guildmaster_summit.credit_skip == true then
	    return
	  end
	  UI:WaitShowVoiceOver(STRINGS:Format(MapStrings['Credits_Line_008']), 210)
	  if guildmaster_summit.can_skip == true and guildmaster_summit.credit_skip == true then
	    return
	  end
	  
	  GAME:WaitFrames(120)
	  if guildmaster_summit.can_skip == true and guildmaster_summit.credit_skip == true then
	    return
	  end
	  UI:WaitShowVoiceOver(STRINGS:Format(MapStrings['Credits_Line_009']), 240)
	  if guildmaster_summit.can_skip == true and guildmaster_summit.credit_skip == true then
	    return
	  end
	  
	  guildmaster_summit.credit_skip = true
end

function guildmaster_summit.WaitCredits()
  while guildmaster_summit.credit_skip == false do
    if GAME:IsInputDown(1) then -- Cancel
	  guildmaster_summit.credit_skip = true
	end
	GAME:WaitFrames(1)
  end
end
--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------
  
function guildmaster_summit.NPC_Rival_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_1_Line_001']))
  
  SV.team_rivals.SpokenTo = true
end
  
function guildmaster_summit.NPC_Rival_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_2_Line_001']))
  
  SV.team_rivals.SpokenTo = true
end

function guildmaster_summit.NPC_Storehouse_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  guildmaster_summit.NPC_All_Action()
end


function guildmaster_summit.NPC_Carry_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  guildmaster_summit.NPC_All_Action()
end


function guildmaster_summit.NPC_Deliver_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  guildmaster_summit.NPC_All_Action()
end

function guildmaster_summit.NPC_All_Action()
  local carry = CH('NPC_Carry')
  local deliver = CH('NPC_Deliver')
  local storehouse = CH('NPC_Storehouse')
  
  UI:SetSpeaker(storehouse)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Supply_Line_001']))
  UI:SetSpeaker(carry)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Supply_Line_002']))
  UI:SetSpeaker(deliver)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Supply_Line_003']))
end


function guildmaster_summit.South_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local dungeon_entrances = { }
  local ground_entrances = {{Flag=true,Zone='guildmaster_island',ID=1,Entry=3},
  {Flag=SV.forest_camp.ExpositionComplete,Zone='guildmaster_island',ID=3,Entry=2},
  {Flag=SV.cliff_camp.ExpositionComplete,Zone='guildmaster_island',ID=4,Entry=2},
  {Flag=SV.canyon_camp.ExpositionComplete,Zone='guildmaster_island',ID=5,Entry=2},
  {Flag=SV.rest_stop.ExpositionComplete,Zone='guildmaster_island',ID=6,Entry=2},
  {Flag=SV.final_stop.ExpositionComplete,Zone='guildmaster_island',ID=7,Entry=2}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end

guildmaster_summit.can_skip = false
guildmaster_summit.credit_skip = false

function guildmaster_summit.Summit_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local team1 = CH('Teammate1')
  local team2 = CH('Teammate2')
  local team3 = CH('Teammate3')
  
  if team1 ~= nil then
  GROUND:CharAnimateTurnTo(team1, Direction.Up, 4)
  end
  if team2 ~= nil then
  GROUND:CharAnimateTurnTo(team2, Direction.Up, 4)
  end
  if team3 ~= nil then
  GROUND:CharAnimateTurnTo(team3, Direction.Up, 4)
  end
  
  UI:ResetSpeaker()
  
  GAME:MoveCamera(0, -48, 48, true)
  
  --local coro1 = TASK:BranchCoroutine(GAME:_MoveCamera(0, -48, 60, true))
  
  local emitter = RogueEssence.Content.OverlayEmitter()
  emitter.Anim = RogueEssence.Content.BGAnimData("White", 0)
  emitter.Layer = DrawLayer.Top
  emitter.Color = Color(0, 0, 0, 0.5)
  emitter.FadeIn = 60
  emitter.FadeOut = 60
  _GROUND:CreateAnim(emitter, DrawLayer.NoDraw)
  GAME:WaitFrames(90)
  --TASK:JoinCoroutines({coro1})
  
  guildmaster_summit.can_skip = true
  guildmaster_summit.credit_skip = false
  local coro2 = TASK:BranchCoroutine(guildmaster_summit.RollCredits)
  local coro3 = TASK:BranchCoroutine(guildmaster_summit.WaitCredits)
  TASK:JoinCoroutines({coro2, coro3})
  
  
  emitter:SwitchOff()
  --coro1 = TASK:BranchCoroutine(GAME:_MoveCamera(0, 0, 60, true))
  --TASK:JoinCoroutines({coro1})
  
  GAME:WaitFrames(60)
  GAME:MoveCamera(0, 0, 48, true)
  
end


function guildmaster_summit.Teammate1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

function guildmaster_summit.Teammate2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

function guildmaster_summit.Teammate3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end


return guildmaster_summit