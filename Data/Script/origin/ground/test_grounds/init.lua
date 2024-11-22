--[[
    Example init.lua
    
  ****Each maps must have init.lua! ****
    
    Each map needs to have a init.lua, and a actions.lua file that defines its own instance of the GroundMap class.
    This will be used to determine how to run the map events and more!
    
    If the base implementation of GroundMap isn't enough, you can override any methods of the 
    GroundMap class in here as needed!
    
    You can add any number of scripts in the map folder as you want! Some special constants are available to fetch the current map's directory
    to load the scripts using a dofile or require function call.
    
    _SCRIPT_MAP_DIR = global containing the path from the Script root folder to the current folder
]]--
require 'origin.common'

local test_grounds = {}


--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function test_grounds.Init(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_test_grounds <<=")

  COMMON.RespawnStarterPartner()
  
  local partner = CH('Partner')
  AI:SetCharacterAI(partner, "origin.ai.ground_partner", CH('PLAYER'), partner.Position)
  partner.CollisionDisabled = true
  partner.InteractOrder = 1
	
  --Set Poochy AI
  local poochy = CH("Poochy")
  --Set the area to wander in
  local poochzone = {X = poochy.X - 100, Y = poochy.Y - 100, 
                     W = 200, H = 200};
  AI:SetCharacterAI(poochy,                                      --[[Entity that will use the AI]]--
                    "origin.ai.ground_default",                         --[[Class path to the AI class to use]]--
                    RogueElements.Loc(poochzone.X, poochzone.Y), --[[Top left corner pos of the allowed idle wander area]]--
                    RogueElements.Loc(poochzone.W, poochzone.H), --[[Width and Height of the allowed idle wander area]]--
                    0.5,                                         --[[Wandering speed]]--
                    48,                                          --[[Min move distance for a single wander]]--
                    64,                                          --[[Max move distance for a single wander]]--
                    320,                                         --[[Min delay between idle actions]]--
                    620);                                        --[[Max delay between idle actions]]--
    


  
  --Spawn our spawner npcs
  GROUND:SpawnerDoSpawn('MerchantSpawner')
  
  GROUND:SpawnerDoSpawn('MerchantSpawner2')
end

function test_grounds.GameLoad(map)
  PrintInfo('GameLoad_test_grounds')

end

function test_grounds.GameSave(map)
  PrintInfo('GameSave_test_grounds')

end

--Called when the screen fades in as the player enters the map
function test_grounds.Enter(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo('Enter_test_grounds')
  
  local caterQuest = SV.missions.FinishedMissions["CaterQuest"]
  if caterQuest == nil then
	GROUND:Hide("Caterpie")
  end
  local volmiseQuest = SV.missions.FinishedMissions["VolmiseQuest"]
  if volmiseQuest == nil then
	GROUND:Hide("Illumise")
  end
  
  GAME:FadeIn(60)
  UI:ResetSpeaker()
  
end

--Called constantly while the map is running
function test_grounds.Update(map, time)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
end

function test_grounds.Test_Action()
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo('Test_Action')

  UI:SetSpeaker(CH('PLAYER'))
  UI:WaitShowDialogue("So cool!")
  GROUND:Unhide("Illumise")
  GROUND:Unhide("Caterpie")
  local groundObject = RogueEssence.Ground.GroundObject(RogueEssence.Content.ObjAnimData("Sign", 1), RogueElements.Rect(244, 180, 24, 24), RogueElements.Loc(8, 0), false, "Sign2")
  _ZONE.CurrentGround:AddTempObject(groundObject)
end

--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------
function test_grounds.Sign1_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo('Sign1_Action')
  

  
  local zone = _DATA:GetZone("faded_trail")
  local cur_floor = zone.Segments[0].Floors[0]
  local priorities = LUA_ENGINE:MakeList(cur_floor.GenSteps)
  for priority in luanet.each(priorities) do
    PrintInfo(priority:ToString())
  end
  
  GROUND:MoveObjectToPosition(obj, 40, 40, 2)
  GROUND:TeleportTo(obj, 200, 200, Direction.Right)
  UI:ResetSpeaker()
  UI:SetCenter(true)
  UI:WaitShowDialogue(STRINGS.MapStrings['Sign1_Action_Line0'])
  UI:WaitShowVoiceOver("This room features many[pause=0]\nmechanics useful for scripting.[br]Some of which\n\nmay never be used\nin the final game.[scroll]To enable developer mode,[scroll]run dev.bat in the game folder.", -1)
  GAME:WaitFrames(30)
  UI:SetAutoFinish(true)
  UI:WaitShowVoiceOver("Fork us at[pause=0]\nhttps://github.com/audinowho/PMDODump![br]Now...\nLet's move you around![scroll]Ready in\n3 2 1", -1)
  
  TASK:WaitStartEntityTask(activator, function()
    SOUND:PlayBattleSE("EVT_Emote_Confused")
    GROUND:CharSetEmote(activator, "question", 1)
    GAME:WaitFrames(60)
    GROUND:MoveInDirection(activator, Direction.Down, 30, false, 2)
    GROUND:MoveInDirection(activator, Direction.DownLeft, 30, false, 2)
    GROUND:MoveInDirection(activator, Direction.DownRight, 30, false, 2)
    GROUND:MoveInDirection(activator, Direction.UpRight, 30, false, 2)
    GROUND:MoveInDirection(activator, Direction.UpLeft, 30, false, 2)
  end)

  UI:SetAutoFinish(false)
  TASK:WaitEntityTask(activator)
  UI:WaitShowDialogue("Ye,[pause=0] you just moved around by yourself.")
  
  SOUND:PlayBattleSE("DUN_Explosion")
  local emitter = RogueEssence.Content.SingleEmitter(RogueEssence.Content.AnimData("Flamethrower", 3))
  emitter.LocHeight = 14
  GROUND:PlayVFX(emitter, activator.MapLoc.X, activator.MapLoc.Y)
  
  
  local switchEmitter = RogueEssence.Content.SingleSwitchEmitter()
  switchEmitter.Anim = RogueEssence.Content.StaticAnim(RogueEssence.Content.AnimData("Flamethrower", 3), 0, -1)
  switchEmitter.LocHeight = 14
  switchEmitter:SetupEmit(RogueElements.Loc(activator.MapLoc.X + 64, activator.MapLoc.Y), RogueElements.Loc(activator.MapLoc.X + 64, activator.MapLoc.Y), Dir8.Down)
  _GROUND:CreateAnim(switchEmitter, DrawLayer.NoDraw)
  --use _DUNGEON for dungeon.
  
  GAME:WaitFrames(60)
  UI:WaitShowDialogue("BOOM.")
  
  SOUND:PlayBattleSE("DUN_Explosion")
  emitter = RogueEssence.Content.FiniteAreaEmitter(RogueEssence.Content.AnimData("Explosion", 3))
  emitter.Range = 72
  emitter.Speed = 72
  emitter.TotalParticles = 12
  GROUND:PlayVFX(emitter, activator.MapLoc.X, activator.MapLoc.Y)
  
  GAME:WaitFrames(60)
  UI:WaitShowDialogue("BOOM BOOM BOOM.")
  
  switchEmitter:SwitchOff()
end


function test_grounds.Concurrent_Sequence(turnTime)
	local chara = CH('PLAYER')
  
  GROUND:CharSetAnim(chara, "None", true)
  GROUND:CharAnimateTurnTo(chara, Direction.Left, turnTime)
  GAME:WaitFrames(20)
  GROUND:CharAnimateTurn(chara, Direction.Right, turnTime, false)
  GAME:WaitFrames(20)
  GROUND:CharAnimateTurn(chara, Direction.Left, turnTime, true)
  GAME:WaitFrames(20)
  GROUND:CharAnimateTurn(chara, Direction.Right, turnTime, false)
  GAME:WaitFrames(20)
  GROUND:CharAnimateTurn(chara, Direction.Left, turnTime, true)
  GAME:WaitFrames(20)
  GROUND:CharAnimateTurn(chara, Direction.Right, turnTime, false)
  GAME:WaitFrames(20)
  GROUND:CharAnimateTurnTo(chara, Direction.Up, turnTime)
  GAME:WaitFrames(20)
  SOUND:PlayBattleSE("EVT_Emote_Confused")
  GROUND:CharSetEmote(chara, "question", 1)
  GAME:WaitFrames(20)
  GROUND:CharSetAnim(chara, "None", false)
end

function test_grounds.Sign3_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local chara = CH('PLAYER')
  PrintInfo('Sign2_Action')
  UI:ResetSpeaker()
  UI:SetAutoFinish(true)
  UI:WaitShowDialogue(STRINGS.MapStrings['Sign2_Action_Line0'])
  GAME:FadeOut(false, 30)
  GAME:MoveCamera(0, 120, 1, true)
  --perform this fade without waiting for its completion
  local coro1 = TASK:BranchCoroutine(GAME:_FadeIn(60))
  local coro2 = TASK:BranchCoroutine(function() test_grounds.Concurrent_Sequence(4) end)
  GAME:MoveCamera(0, 0, 60, true)
  --TODO: wait to join coroutines before giving control back to the player
  TASK:JoinCoroutines({coro1, coro2})
  
  
  coro1 = TASK:BranchCoroutine(test_grounds.Concurrent_BG)
  coro2 = TASK:BranchCoroutine(test_grounds.Concurrent_Title)
  TASK:JoinCoroutines({coro1, coro2})
end


function test_grounds.Sign4_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo('Text Tag Regression Test')
  local chara = CH('PLAYER')
  
  UI:SetBounds(16, 16, 128, 128)
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue("The quick brown fox jumped over the lazy dog. The quick brown fox jumped over the lazy dog. The quick brown fox jumped over the lazy dog.")
  UI:SetSpeakerLoc(144, 16)
  UI:WaitShowDialogue("The quick brown fox jumped over the lazy dog. The quick brown fox jumped over the lazy dog. The quick brown fox jumped over the lazy dog.")
  
  UI:ChoiceMenuYesNo("Was the dog lazy?")
  UI:WaitForChoice()
  UI:SetChoiceLoc(144, 72)
  UI:ChoiceMenuYesNo("Was the fox jumpy?")
  UI:WaitForChoice()
  
  UI:ResetSpeaker()
  UI:ChoiceMenuYesNo("Was the fox brown?")
  UI:WaitForChoice()
  
  UI:WaitShowDialogue("Hello[pause=120]")
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue("ABCD[scroll]ABCD[scroll]ABCD[scroll]ABCD")
  UI:SetSpeakerReverse(true)
  UI:WaitShowDialogue("Normal Normal Normal Normal Normal Normal Normal Normal [emote=sad]Sad Sad Sad Sad Sad Sad Sad Sad Sad Sad [emote=special1]Special1 Special1 Special1 Special1 Special1 Special1 Special1[emote=teary-eyed]Teary-Eyed Teary-Eyed Teary-Eyed Teary-Eyed Teary-Eyed Teary-Eyed Teary-Eyed Teary-Eyed")
  UI:WaitShowDialogue("Normal Normal Normal Normal Normal Normal [speed=3]Fast Fast Fast Fast Fast Fast Fast Fast Fast [speed=0.2]Slow Slow Slow Slow")
  UI:WaitShowDialogue("THE[pause=0] [color=#FF0000]QUICK[color] BROWN\n FOX [color=#FF0000]JUMPS[color] OVER[pause=0] THE[scroll] LAZY [color=#FF0000]DOG[color].\nTHE [color=#FF0000]QUICK[color] BROWN[pause=0] FOX [color=#FF0000]JUMPS[color].")
  UI:WaitShowDialogue("Normal Sound Normal Sound Normal Sound Normal Sound Normal Sound Normal Sound Normal Sound")
  UI:WaitShowDialogue("[sound=Menu/Speak,8]Normal Sound But Slower Normal Sound But Slower Normal Sound But Slower Normal Sound But Slower")
  UI:WaitShowDialogue("Normal Sound Normal Sound Normal Sound Normal Sound [sound=Battle/_UNK_DUN_Water_Drop]Different Sound Different Sound Different Sound")
  UI:WaitShowDialogue("[sound=Battle/_UNK_DUN_Water_Drop,7]Different Sound But Slower Different Sound But Slower Different Sound But Slower")
  
  UI:SetSe("Menu/Unknown-3", 10)
  UI:WaitShowDialogue("Beep boop beep boop beep boop beep boop beep boop beep boop beep boop")
  UI:ResetSe()
end

function test_grounds.Sign5_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo('Text Tag Regression Test')
  local chara = CH('PLAYER')
  
  UI:ResetSpeaker()
  UI:WaitShowVoiceOver("Our belief is often strongest when it should be weakest. That is the nature of hope.", 130, 150, 20, 100, -1)
  UI:WaitShowVoiceOver("[speed=0.2]Alright... [speed=7.0]Zooming at the speed of light!\n[speed=0.2]Then... [speed=0.07]Slow as a Slowpoke.", 70)
  
  UI:TextPopUp("Everything", 30);
  GAME:WaitFrames(70)
  UI:TextPopUp("Everywhere, all at once, and everything that was here, and there, and everywhere", 50, 50, 50, 80, -1, false, false)
  GAME:WaitFrames(70)
  UI:TextPopUp("Oh, it can also stretch over here too!", 30, 150, 20, 90, -1, true, false)
  GAME:WaitFrames(50)
  UI:WaitShowVoiceOver("Now watch this!", 120, 0, 0, -1, -1)
  function test0()
    UI:WaitShowDialogue("Skip me!")
  end

  function test1()
    local tutor_choices = {RogueEssence.StringKey("MENU_RECALL_SKILL"):ToLocal(),
                           RogueEssence.StringKey("MENU_FORGET_SKILL"):ToLocal(),
                           STRINGS:FormatKey("MENU_INFO"),
                           STRINGS:FormatKey("MENU_EXIT")}
    UI:BeginMultiPageMenu(24, 24, 196, "Title Name", tutor_choices, 8, 1, 4)
    UI:WaitForChoice()
  end

  function test2()
    SOUND:PlayBattleSE("DUN_Explosion")
    local emitter = RogueEssence.Content.SingleEmitter(RogueEssence.Content.AnimData("Flamethrower", 3))
    emitter.LocHeight = 2
    GROUND:PlayVFX(emitter, activator.MapLoc.X, activator.MapLoc.Y)
    GAME:WaitFrames(60)
    SOUND:PlayBattleSE("DUN_Explosion")
    emitter = RogueEssence.Content.FiniteAreaEmitter(RogueEssence.Content.AnimData("Explosion", 3))
    emitter.Range = 20
    emitter.Speed = 72
    emitter.TotalParticles = 2
    GROUND:PlayVFX(emitter, activator.MapLoc.X, activator.MapLoc.Y)
    GAME:WaitFrames(60)
  end
  local callbacks = { test0, test1, test2 }
  UI:WaitShowDialogue("Aha![script=2] You've fallen in my trap![pause=60] Now there is no escape.[script=0][script=1]", callbacks)
end


function test_grounds.Concurrent_Title()

  UI:WaitShowTitle("Like\nComment\nSubscribe", 60)
  GAME:WaitFrames(120)
  UI:WaitHideTitle(60)
end

function test_grounds.Concurrent_BG()

  UI:WaitShowBG("Cosmic_Power", 1, 60)
  GAME:WaitFrames(120)
  UI:WaitHideBG(60)
end

ListType = luanet.import_type('System.Collections.Generic.List`1')
MenuTextChoiceType = luanet.import_type('RogueEssence.Menu.MenuTextChoice')

function test_grounds.Sign2_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local chara = CH('PLAYER')
  GROUND:Unhide('Activation')
  UI:WaitShowDialogue("The Debug Dungeon is accessible from here.")
  UI:WaitShowDialogue("We do not take responsibility for broken things you encounter there.")
  UI:WaitShowDialogue("If you get stuck inside, try deleting SAVE/QUICKSAVE.rsqs")
  UI:WaitShowDialogue("Maybe back up your main save too. (SAVE/SAVE.rssv)")
end

function test_grounds.Entrance_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo('Entrance_Action')
end

function test_grounds.Activation_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo('Activation_Action')
end

function test_grounds.Assembly_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GROUND:ObjectWaitAnimFrame(obj, 3)
  UI:ResetSpeaker()
  SOUND:PlaySE("Menu/Skip")
  UI:AssemblyMenu()
  UI:WaitForChoice()
  result = UI:ChoiceResult()
  UI:WaitShowDialogue("Unlike the assembly objects in other maps, this one doesn't reload the map on team change.")
end

function test_grounds.SouthExit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local open_dests = {
    { Name="Replay Test Zone", Dest=RogueEssence.Dungeon.ZoneLoc('debug_zone', 4, 0, 0) },
    { Name="Base Camp", Dest=RogueEssence.Dungeon.ZoneLoc('guildmaster_island', -1, 1, 0) }
  }
  
  local dest = RogueEssence.Dungeon.ZoneLoc.Invalid
  if #open_dests > 1 or force_list then
    if before_list ~= nil then
	  before_list(dest)
	end
	
    SOUND:PlaySE("Menu/Skip")
	default_choice = 1
	while true do
      UI:ResetSpeaker()
      UI:DestinationMenu(open_dests, default_choice)
	  UI:WaitForChoice()
	  default_choice = UI:ChoiceResult()
	
	  if default_choice == nil then
	    break
	  end
	  ask_dest = open_dests[default_choice].Dest
      if ask_dest.StructID.Segment >= 0 then	  
	    --chosen dungeon entry
		if speaker ~= nil then
		  UI:SetSpeaker(speaker)
		else
          UI:ResetSpeaker(false)
		end
	    UI:DungeonChoice(open_dests[default_choice].Name, ask_dest)
        UI:WaitForChoice()
        if UI:ChoiceResult() then
	      dest = ask_dest
	      break
	    end
	  else 
	    dest = ask_dest
	    break
	  end
	end
  elseif #open_dests == 1 then
    if open_dests[1].Dest.StructID.Segment < 0 then
	  --single ground entry
	  if speaker ~= nil then
	    UI:SetSpeaker(speaker)
	  else
        UI:ResetSpeaker(false)
        SOUND:PlaySE("Menu/Skip")
	  end
	  UI:ChoiceMenuYesNo(STRINGS:FormatKey("DLG_ASK_ENTER_GROUND", open_dests[1].Name))
      UI:WaitForChoice()
      if UI:ChoiceResult() then
	    dest = open_dests[1].Dest
	  end
	else
	  --single dungeon entry
	  if speaker ~= nil then
	    UI:SetSpeaker(speaker)
	  else
        UI:ResetSpeaker(false)
        SOUND:PlaySE("Menu/Skip")
	  end
	  UI:DungeonChoice(open_dests[1].Name, open_dests[1].Dest)
      UI:WaitForChoice()
      if UI:ChoiceResult() then
	    dest = open_dests[1].Dest
	  end
	end
  else
    PrintInfo("No valid destinations found!")
  end
  
  if dest:IsValid() then
    if confirm_msg ~= nil then
	  UI:WaitShowDialogue(confirm_msg)
	end
	if dest.StructID.Segment > -1 then
	  --pre-loads the zone on a separate thread while we fade out, just for a little optimization
	  _DATA:PreLoadZone(dest.ID)
	  SOUND:PlayBGM("", true)
      GAME:FadeOut(false, 20)
	  GAME:EnterDungeon(dest.ID, dest.StructID.Segment, dest.StructID.ID, dest.EntryPoint, RogueEssence.Data.GameProgress.DungeonStakes.Risk, true, false)
	else
	  SOUND:PlayBGM("", true)
      GAME:FadeOut(false, 20)
	  GAME:EnterZone(dest.ID, dest.StructID.Segment, dest.StructID.ID, dest.EntryPoint)
	end
  end
end
--------------------------------------------------
-- Characters Callbacks
--------------------------------------------------
function test_grounds.Mew_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local mew = CH('Mew')
  local player = CH('PLAYER')
  local partner = CH('Partner')
  local state = {olddir = mew.CharDir}

  GROUND:CharTurnToChar(mew,player)
  GROUND:CharSetEmote(mew, "", 0)

  UI:SetSpeaker(mew)
  UI:WaitShowTimedDialogue("Walk with me!", 120)
  GROUND:CharSetEmote(mew, "happy", 0)

  local coro1 = TASK:BranchCoroutine(function() test_grounds.Walk_Sequence(mew) end)
  local coro2 = TASK:BranchCoroutine(function() test_grounds.Walk_Sequence(player) end)
  
  TASK:JoinCoroutines({coro1, coro2})

  CH('Mew').CharDir = state.olddir
  
  GAME:WaitFrames(60)
  
  mew.CollisionDisabled = true
  local animId = RogueEssence.Content.GraphicsManager.GetAnimIndex("Hop")
  local frameAction = RogueEssence.Ground.IdleAnimGroundAction(mew.Position, 0, Direction.Up, animId, false)
  
  local head_pos = GROUND:CharGetAnimPoint(player, RogueEssence.Content.ActionPointType.Head)
  local shadow_pos = GROUND:CharGetAnimPoint(player, RogueEssence.Content.ActionPointType.Shadow)
  GROUND:ActionToPosition(mew, frameAction, player.MapLoc.X, player.MapLoc.Y, 1, 0.2, shadow_pos.Y - head_pos.Y + 100)
  
  GAME:WaitFrames(30)
  mew.EntOrder = 1
  
  
  animId = RogueEssence.Content.GraphicsManager.GetAnimIndex("Rotate")
  frameAction = RogueEssence.Ground.ReverseGroundAction(mew.Position, mew.LocHeight, Direction.Up, animId)
  GROUND:ActionToPosition(mew, frameAction, player.MapLoc.X, player.MapLoc.Y, 1, 2, shadow_pos.Y - head_pos.Y)
  
  GAME:WaitFrames(30)
  
  animId = RogueEssence.Content.GraphicsManager.GetAnimIndex("Rotate")
  frameAction = RogueEssence.Ground.IdleAnimGroundAction(mew.Position, mew.LocHeight, Direction.Up, animId, true)
  GROUND:ActionToPosition(mew, frameAction, player.MapLoc.X, player.MapLoc.Y, 1, 2, shadow_pos.Y - head_pos.Y + 100)
  
  GAME:WaitFrames(30)
  
  mew.EntOrder = -1
  
  animId = RogueEssence.Content.GraphicsManager.GetAnimIndex("Rotate")
  frameAction = RogueEssence.Ground.ReverseGroundAction(mew.Position, mew.LocHeight, Direction.Up, animId)
  GROUND:ActionToPosition(mew, frameAction, player.MapLoc.X, player.MapLoc.Y, 1, 2, shadow_pos.Y - head_pos.Y)
  
  animId = RogueEssence.Content.GraphicsManager.GetAnimIndex("None")
  GROUND:CharSetAction(mew, RogueEssence.Ground.FrameGroundAction(mew.Position, mew.LocHeight, Direction.Up, animId, 0))
  
end

function test_grounds.Walk_Sequence(chara)
  
  GROUND:MoveInDirection(chara, Direction.Up, 20, false, 2)
  GAME:WaitFrames(60)
  GROUND:AnimateInDirection(chara, "Hurt", Direction.Down, Direction.Up, 20, 1, 5)
  PrintInfo(GROUND:CharGetAnimFallback(chara, "Hurt"))
  PrintInfo(GROUND:CharGetAnimFallback(chara, "Kick"))
  PrintInfo(GROUND:CharGetAnim(chara))
  GAME:WaitFrames(60)
  GROUND:MoveInDirection(chara, Direction.Down, 20, true, 7)
end


function test_grounds.Caterpie_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo('Caterpie_Action')
  local olddir = chara.CharDir
  GROUND:CharTurnToCharAnimated(chara, CH('PLAYER'), 4)
  
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue("So cool!")
  
end


function test_grounds.Magnezone_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo('Magnezone_Action')
  GROUND:CharTurnToCharAnimated(chara, CH('PLAYER'), 4)
  
  UI:SetSpeaker(chara)
  -- check for quest presence
  local quest = SV.missions.Missions["OutlawQuest"]
  local finishedquest = SV.missions.FinishedMissions["OutlawQuest"]
  if finishedquest ~= nil then
	  -- there is an outlaw quest, and it has been completed- thank you note
	  UI:WaitShowDialogue("Outlaw mission state: Rewarded.  Thank you for apprehending Riolu!")
  elseif quest == nil then
    -- no outlaw quest? ask to start one
    UI:ChoiceMenuYesNo("No Outlaw mission detected. Do you want to start one?")
    UI:WaitForChoice()
    local chres = UI:ChoiceResult() 
    if chres then
	  -- Type 0 = Rescue
	  COMMON.CreateMission("OutlawQuest",
	{ Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_OUTLAW,
      DestZone = "debug_zone", DestSegment = 4, DestFloor = 9,
      FloorUnknown = true,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("riolu", 0, "normal", Gender.Male),
      ClientSpecies = RogueEssence.Dungeon.MonsterID("magnezone", 0, "normal", Gender.Genderless) }
	  )
      UI:WaitShowDialogue("You can find the perpetrator at Replay Test Zone 10F.  Good luck!")
    end
  else
    if quest.Complete == COMMON.MISSION_COMPLETE then
	  UI:WaitShowDialogue("Outlaw mission state: Complete.  Give a reward and mark mission as rewarded.")
	  COMMON.CompleteMission("OutlawQuest")
	else
	  -- there is an outlaw quest, but it hasn't been completed?  ask to abandon
      UI:ChoiceMenuYesNo("Outlaw mission state: Incomplete.  Do you want to abandon the mission?")
      UI:WaitForChoice()
      local chres = UI:ChoiceResult() 
      if chres then
	    SV.missions.Missions["OutlawQuest"] = nil
        UI:WaitShowDialogue("Outlaw mission removed.")
      end
	end
  end
end


function test_grounds.Butterfree_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo('Butterfree_Action')
  GROUND:CharTurnToCharAnimated(chara, CH('PLAYER'), 4)
  
  UI:SetSpeaker(chara)
  -- check for quest presence
  local quest = SV.missions.Missions["CaterQuest"]
  local finishedquest = SV.missions.FinishedMissions["CaterQuest"]
  if finishedquest ~= nil then
	  -- there is a caterpie quest, and it has been completed- thank you note
	  UI:WaitShowDialogue("Caterpie mission state: Rewarded.  Thank you for rescuing Caterpie!")
  elseif quest == nil then
    -- no caterpie quest? ask to start one
    UI:ChoiceMenuYesNo("No Caterpie mission detected. Do you want to start one?")
    UI:WaitForChoice()
    local chres = UI:ChoiceResult() 
    if chres then
	  -- Type 0 = Rescue
	  COMMON.CreateMission("CaterQuest",
	{ Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_RESCUE,
      DestZone = "debug_zone", DestSegment = 4, DestFloor = 4,
      FloorUnknown = false,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("caterpie", 0, "normal", Gender.Male),
      ClientSpecies = RogueEssence.Dungeon.MonsterID("butterfree", 0, "normal", Gender.Male) }
	  )
      UI:WaitShowDialogue("You can find Caterpie at Replay Test Zone 5F.  Good luck!")
    end
  else
    if quest.Complete == COMMON.MISSION_COMPLETE then
	  UI:WaitShowDialogue("Caterpie mission state: Complete.  Give a reward and mark mission as rewarded.")
	  COMMON.CompleteMission("CaterQuest")
	else
	  -- there is a caterpie quest, but it hasn't been completed?  ask to abandon
      UI:ChoiceMenuYesNo("Caterpie mission state: Incomplete.  Do you want to abandon the mission?")
      UI:WaitForChoice()
      local chres = UI:ChoiceResult() 
      if chres then
	    SV.missions.Missions["CaterQuest"] = nil
        UI:WaitShowDialogue("Caterpie mission removed.")
      end
	end
  end
end


function test_grounds.Illumise_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo('Illumise_Action')
  local olddir = chara.CharDir
  GROUND:CharTurnToCharAnimated(chara, CH('PLAYER'), 4)
  
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue("Thank you for rescuing me!")
  
end

function test_grounds.Volbeat_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo('Volbeat_Action')
  GROUND:CharTurnToCharAnimated(chara, CH('PLAYER'), 4)
  
  UI:SetSpeaker(chara)
  -- check for quest presence
  local quest = SV.missions.Missions["VolmiseQuest"]
  local finishedquest = SV.missions.FinishedMissions["VolmiseQuest"]
  if finishedquest ~= nil then
	  -- there is an outlaw quest, and it has been completed- thank you note
	  UI:WaitShowDialogue("Volmise mission state: Rewarded.  Thank you for rescuing Illumise!")
  elseif quest == nil then
    -- no caterpie quest? ask to start one
    UI:ChoiceMenuYesNo("No Volmise mission detected. Do you want to start one?")
    UI:WaitForChoice()
    local chres = UI:ChoiceResult() 
    if chres then
	  -- Type 1 = Escort
	  COMMON.CreateMission("VolmiseQuest",
	{ Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_ESCORT,
      DestZone = "debug_zone", DestSegment = 4, DestFloor = 3,
      FloorUnknown = true,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("illumise", 0, "normal", Gender.Female),
      EscortSpecies = RogueEssence.Dungeon.MonsterID("volbeat", 0, "normal", Gender.Male),
      ClientSpecies = RogueEssence.Dungeon.MonsterID("volbeat", 0, "normal", Gender.Male) }
	  )
      UI:WaitShowDialogue("You can find Illumise at Replay Test Zone ?F.  I'll join you when you enter!")
    end
  else
    if quest.Complete == COMMON.MISSION_COMPLETE then
	  UI:WaitShowDialogue("Volmise mission state: Complete.  Give a reward and mark mission as rewarded.")
	  COMMON.CompleteMission("VolmiseQuest")
	else
	  -- there is a caterpie quest, but it hasn't been completed?  ask to abandon
      UI:ChoiceMenuYesNo("Volmise mission state: Incomplete.  Do you want to abandon the mission?")
      UI:WaitForChoice()
      local chres = UI:ChoiceResult() 
      if chres then
	    SV.missions.Missions["VolmiseQuest"] = nil
        UI:WaitShowDialogue("Volmise mission removed.")
      end
	end
  end
end

-- equivalent to defining a class
local ExampleMenu = Class('ExampleMenu')

function ExampleMenu:initialize()
  assert(self, "ExampleMenu:initialize(): Error, self is nil!")
  self.menu = RogueEssence.Menu.ScriptableMenu(24, 24, 196, 128, function(input) self:Update(input) end)
  
  self.cursor = RogueEssence.Menu.MenuCursor(self.menu)
  self.menu.Elements:Add(self.cursor)
  self.menu.Elements:Add(RogueEssence.Menu.MenuText("Test String", RogueElements.Loc(16, 8 + 12 * 0)))
  self.menu.Elements:Add(RogueEssence.Menu.MenuText("Apple", RogueElements.Loc(88, 8 + 12 * 0)))
  self.menu.Elements:Add(RogueEssence.Menu.MenuText("Test String 2", RogueElements.Loc(16, 8 + 12 * 1)))
  self.menu.Elements:Add(RogueEssence.Menu.MenuText("Orange", RogueElements.Loc(88, 8 + 12 * 1)))
  
  local portrait = RogueEssence.Menu.MenuPortrait(RogueElements.Loc(16, 32), RogueEssence.Dungeon.MonsterID("jigglypuff", 0, "normal", Gender.Male), RogueEssence.Content.EmoteStyle(1, true))
  self.menu.Elements:Add(portrait)
  local dirtex = RogueEssence.Menu.MenuDirTex(RogueElements.Loc(64, 32), RogueEssence.Menu.MenuDirTex.TexType.Item, RogueEssence.Content.AnimData("Money_Gray", 1))
  self.menu.Elements:Add(dirtex)
  local dirtex2 = RogueEssence.Menu.MenuDirTex(RogueElements.Loc(64, 48), RogueEssence.Menu.MenuDirTex.TexType.Icon, RogueEssence.Content.AnimData("Shield_Green", 3))
  self.menu.Elements:Add(dirtex2)
  self.total_items = 4
  self.current_item = 0
  self.cursor.Loc = RogueElements.Loc(8 + 12 * (self.current_item % 2), 8 + 80 * (self.current_item // 2))
end

function ExampleMenu:Update(input)
  assert(self, "BaseState:Begin(): Error, self is nil!")
  -- default does nothing
  if input:JustPressed(RogueEssence.FrameInput.InputType.Confirm) then
    _GAME:SE("Menu/Confirm")
	if self.current_item > 2 then
	  local choices = { RogueEssence.Menu.MenuTextChoice(STRINGS:FormatKey("DLG_CHOICE_YES"), LUA_ENGINE:MakeLuaAction(function() _GAME:SE("Fanfare/RankUp")  end) ),
        { STRINGS:FormatKey("MENU_INFO"), false, function() end  },
        { STRINGS:FormatKey("DLG_CHOICE_NO"), true, function() _MENU:RemoveMenu() end }}
	  submenu = RogueEssence.Menu.ScriptableSingleStripMenu(220, 24, 24, choices, 1, function() _MENU:RemoveMenu() end)
	  _MENU:AddMenu(submenu, true)
	end
  elseif input:JustPressed(RogueEssence.FrameInput.InputType.Cancel) then
    _GAME:SE("Menu/Cancel")
    _MENU:RemoveMenu()
  else
    moved = false
    if RogueEssence.Menu.InteractableMenu.IsInputting(input, LUA_ENGINE:MakeLuaArray(Dir8, { Dir8.Down, Dir8.DownLeft, Dir8.DownRight })) then
      moved = true
      self.current_item = (self.current_item + 1) % self.total_items
    elseif RogueEssence.Menu.InteractableMenu.IsInputting(input, LUA_ENGINE:MakeLuaArray(Dir8, { Dir8.Up, Dir8.UpLeft, Dir8.UpRight })) then
      moved = true
      self.current_item = (self.current_item + self.total_items - 1) % self.total_items
    end
    if moved then
      _GAME:SE("Menu/Select")
      self.cursor:ResetTimeOffset()
      self.cursor.Loc = RogueElements.Loc(8 + 80 * (self.current_item % 2), 8 + 12 * (self.current_item // 2))
    end
  end
end

function test_grounds.Hungrybox_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo('Hungrybox_Action')
  local player = CH('PLAYER')
  local hbox = chara
  local olddir = hbox.CharDir
  --GROUND:Hide("PLAYER")
  GROUND:CharTurnToCharAnimated(hbox, player, 4)
  GROUND:CharSetDrawEffect(hbox, DrawEffect.Trembling)
  GAME:WaitFrames(120)
  GROUND:CharEndDrawEffect(hbox, DrawEffect.Trembling)
  GROUND:CharAnimateTurnTo(hbox, olddir, 4)
  --chara.CollisionDisabled = true
  --GROUND:Unhide("PLAYER")
  
  COMMON.BossTransition()
  
  local coro1 = TASK:BranchCoroutine(GAME:_FadeOutFront(true, 180))

  UI:SetSpeaker(hbox)
  UI:TextDialogue("AAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAAAAAAAAAAAAAAAAAAAAAAA", 180)
  UI:WaitDialog()
  
  TASK:JoinCoroutines({coro1})
  
  GAME:WaitFrames(120)

  coro1 = TASK:BranchCoroutine(GAME:_FadeInFront(180))
  
  local menu = ExampleMenu:new()
  UI:SetCustomMenu(menu.menu)
  UI:WaitForChoice()
  
  TASK:JoinCoroutines({coro1})
  
  
  GAME:FadeIn(60)
end

function test_grounds.Custom_Menu_Update(input)
  if input:JustPressed(RogueEssence.FrameInput.InputType.Confirm) then
    _MENU:RemoveMenu()
  end
end

function test_grounds.Poochy_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintSVAndStrings()
  
  local olddir = chara.CharDir
  GROUND:CharTurnToCharAnimated(chara, activator, 4)
  UI:SetSpeaker(chara)
  
  if SV.base_camp.AcceptedPooch then
    --If we already talked with poochy and got him to set the ScriptVar
    UI:TextDialogue(STRINGS:Format(STRINGS.MapStrings['Pooch_Action_Line3']))
    UI:WaitDialog()
  else
    --If we haven't gotten poochy to set the script var
    
    if not SV.base_camp.SpokeToPooch then
      --If we never spoke to poochy before
      UI:TextDialogue(STRINGS:Format(STRINGS.MapStrings['Pooch_Action_Line0A']))
      UI:WaitDialog()
      SV.base_camp.SpokeToPooch = true
    else
      --If we already spoke to poochy before, but didn't get him to set the script var
      UI:TextDialogue(STRINGS:Format(STRINGS.MapStrings['Pooch_Action_Line0B']))
      UI:WaitDialog()
    end
    
    UI:ChoiceMenuYesNo(STRINGS:Format(STRINGS.MapStrings['Pooch_Action_Question1']))
    UI:WaitForChoice()
    local ch = UI:ChoiceResult()
    
    if ch then
      --The player told poochy to set the script var
      SV.base_camp.AcceptedPooch = true
      SOUND:PlayFanfare("Fanfare/MissionClear")
      SOUND:WaitFanfare()
      UI:TextDialogue(STRINGS:Format(STRINGS.MapStrings['Pooch_Action_Line2A']))
    else
      --The player told poochy NOT to set the script var
      UI:TextDialogue(STRINGS:Format(STRINGS.MapStrings['Pooch_Action_Line2B']))
    end
    
    UI:WaitDialog()
    
  end -- if SV.AcceptedPooch
  UI:ResetSpeaker()
  GROUND:CharAnimateTurnTo(chara, olddir, 4)
end

--------------------------------------------------
-- Spawners Callbacks
--------------------------------------------------

--[[
--]]
function test_grounds.MerchantSpawner_EntSpawned(spawner, spawnedent)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("test_grounds.MerchantSpawner_EntSpawned()!!")
end

--[[
    
--]]
function test_grounds.Merchant_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  
  local olddir = chara.CharDir
  GROUND:CharTurnToCharAnimated(chara, activator, 4)
  UI:SetSpeaker(chara)
  
  
  UI:WaitShowDialogue("Your sprite will always be Pikachu and Eevee, only on this map.")
  UI:WaitShowDialogue("Handy for mods that want to imitate Explorers-style hub!")
  UI:WaitDialog()
  GROUND:CharAnimateTurnTo(chara, olddir, 4)
  
  
  local tutor_choices = {RogueEssence.StringKey("MENU_RECALL_SKILL"):ToLocal(),
  RogueEssence.StringKey("MENU_FORGET_SKILL"):ToLocal(),
  STRINGS:FormatKey("MENU_INFO"),
  STRINGS:FormatKey("MENU_EXIT")}
  UI:BeginMultiPageMenu(24, 24, 196, "Title Name", tutor_choices, 8, 1, 4)
  UI:WaitForChoice()
  PrintInfo(UI:ChoiceResult())
end

--[[
--]]
function test_grounds.MerchantSpawner2_EntSpawned(spawner, spawnedent)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("test_grounds.MerchantSpawner_EntSpawned()!!")
end

--[[
    
--]]
function test_grounds.Merchant2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  
  local olddir = chara.CharDir
  GROUND:CharTurnToCharAnimated(chara, activator, 4)
  UI:SetSpeaker(chara)
  
  UI:TextDialogue(STRINGS:Format("HELLO!"))
  UI:WaitDialog()
  GROUND:CharAnimateTurnTo(chara, olddir, 4)
end

function test_grounds.Teammate1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:SetSpeaker("", false, chara.CurrentForm.Species, chara.CurrentForm.Form, chara.CurrentForm.Skin, chara.CurrentForm.Gender)
  
  local tbl = LTBL(chara)
  
  if tbl.TalkAmount == nil then
    UI:WaitShowDialogue("I have script vars specific to me.")
    UI:WaitShowDialogue("Switch with me by pressing 2 and 1.")
    UI:WaitShowDialogue("We will remember how many times we've been talked to.")
	tbl.TalkAmount = 1
  else
	tbl.TalkAmount = tbl.TalkAmount + 1
  end
  UI:WaitShowDialogue("You've talked to me "..tostring(tbl.TalkAmount).." times.")
end

function test_grounds.Teammate2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara)
end

function test_grounds.Teammate3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara)
end

return test_grounds