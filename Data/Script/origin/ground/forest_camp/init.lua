require 'origin.common'

local forest_camp = {}

--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function forest_camp.Init(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_forest_camp")

  COMMON.RespawnAllies()
  
  if SV.forest_child.Status == 0 or SV.forest_child.Status == 3 then
    COMMON.CreateWalkArea("NPC_Camps", 168, 184, 48, 48)
  end
  
  local snorlax = CH('Snorlax')
  GROUND:CharSetAnim(snorlax, "Sleep", true)
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------

function forest_camp.Enter(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine

  SV.checkpoint = 
  {
    Zone    = 'guildmaster_island', Segment  = -1,
    Map  = 3, Entry  = 1
  }
  
  --when arriving the first time, play this cutscene
  if not SV.forest_camp.ExpositionComplete then
    forest_camp.SetupNpcs()
    forest_camp.BeginExposition()
    SV.forest_camp.ExpositionComplete = true
  elseif SV.forest_camp.SnorlaxPhase == 2 then
    forest_camp.SetupNpcs()
    forest_camp.Snorlax_Fail()
    SV.forest_camp.SnorlaxPhase = 1
  elseif SV.forest_camp.SnorlaxPhase == 3 then
    forest_camp.SetupNpcs()
    forest_camp.Snorlax_Success()
    SV.forest_camp.SnorlaxPhase = 4
    SV.supply_corps.Status = 1
  else
    forest_camp.SetupNpcs()
    forest_camp.CheckMissions()
	
    GAME:FadeIn(20)
  end
  
  -- TODO: move this back to BeginExposition
  GAME:UnlockDungeon('faded_trail')
  GAME:UnlockDungeon('bramble_woods')
end

function forest_camp.Update(map, time)
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------
function forest_camp.SetupNpcs()
  GROUND:Unhide("NPC_Camps")
  GROUND:Unhide("NPC_Parent")
  


  if SV.town_elder.Status == 1 then
    GROUND:Unhide("NPC_Elder")
  elseif SV.town_elder.Status == 2 then
    GROUND:Unhide("NPC_Elder")
  elseif SV.town_elder.Status == 3 then
    -- TODO cycling
  end

  if SV.forest_child.Status == 0 then
    GROUND:Unhide("NPC_Child")
  elseif SV.forest_child.Status == 1 or SV.forest_child.Status == 2 then
    local parent = CH('NPC_Parent')
	GROUND:EntTurn(parent, Direction.Right)
	local camps = CH('NPC_Camps')
	GROUND:TeleportTo(camps, 248, 336, Direction.Left)
  elseif SV.forest_child.Status == 3 then
    GROUND:Unhide("NPC_Child")
  elseif SV.forest_child.Status >= 4 then
    local parent = CH('NPC_Parent')
	GROUND:EntTurn(parent, Direction.DownRight)
	GROUND:Unhide("NPC_Child")
	local child = CH('NPC_Child')
	GROUND:TeleportTo(child, 408, 368, Direction.Down)
  end
  

  if SV.team_catch.Status == 2 then
    GROUND:Unhide("NPC_Catch_1")
	GROUND:Unhide("NPC_Catch_2")
  elseif SV.team_catch.Status == 4 then
    -- TODO cycling
  end
  
  if SV.team_kidnapped.Status == 1 then
    GROUND:Unhide("NPC_Unlucky")
  elseif SV.team_kidnapped.Status == 6 then
    -- TODO cycling
  end
  
  if SV.team_retreat.Status == 0 then
	GROUND:Unhide("Speedster_1")
	GROUND:Unhide("Speedster_2")
  elseif SV.team_retreat.Status == 4 then
    -- TODO cycling?
  end
  
  if SV.team_solo.Status == 1 and SV.team_solo.SpokenTo == false then
    GROUND:Unhide("NPC_Solo")
  elseif SV.team_solo.Status == 6 then
    -- TODO cycling
  end

  if SV.supply_corps.Status == 0 then
    GROUND:Unhide("Snorlax")
    GROUND:Unhide("NPC_Carry")
    GROUND:Unhide("NPC_Deliver")
  elseif SV.supply_corps.Status >= 20 then
    --cycle appearances
	if SV.supply_corps.ManagerCycle == 0 or SV.supply_corps.ManagerCycle == 6 then
	
	else
	  if SV.supply_corps.CarryCycle == 1 then
	    GROUND:Unhide("NPC_Carry")
	  end
	  if SV.supply_corps.DeliverCycle == 1 then
	    GROUND:Unhide("NPC_Deliver")
	  end
	  if SV.supply_corps.ManagerCycle == 1 then
	    GROUND:Unhide("NPC_Storehouse")
	  end
	end
  end
end

function forest_camp.CheckMissions()
  local player = CH('PLAYER')
  
  local quest = SV.missions.Missions["EscortSister"]
  if quest ~= nil then
    if quest.Complete == COMMON.MISSION_COMPLETE then
	
      --spawn her	  
      
      GAME:FadeIn(20)
      UI:WaitShowDialogue("Escort mission state: Complete.")
      
      --she walks off to sunflora
      UI:WaitShowDialogue("The sister drops something as she runs off.")
      
      SV.magnagate.Cards = SV.magnagate.Cards + 1
	  SV.family.Sister = true
      COMMON.GiftKeyItem(player, RogueEssence.StringKey("ITEM_KEY_CARD_SUN"):ToLocal())
	  COMMON.CompleteMission("EscortSister")
	  
    end
  end

end



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
  local dungeon_entrances = { 'faded_trail', 'bramble_woods', 'trickster_woods', 'overgrown_wilds', 'moonlit_courtyard', 'ambush_forest', 'tiny_tunnel', 'energy_garden', 'sickly_hollow'}
  local ground_entrances = {{Flag=SV.cliff_camp.ExpositionComplete,Zone='guildmaster_island',ID=4,Entry=0},
  {Flag=SV.canyon_camp.ExpositionComplete,Zone='guildmaster_island',ID=5,Entry=0},
  {Flag=SV.rest_stop.ExpositionComplete,Zone='guildmaster_island',ID=6,Entry=0},
  {Flag=SV.final_stop.ExpositionComplete,Zone='guildmaster_island',ID=7,Entry=0},
  {Flag=SV.guildmaster_summit.GameComplete,Zone='guildmaster_island',ID=8,Entry=0}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end

function forest_camp.South_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local dungeon_entrances = { }
  local ground_entrances = {{Flag=true,Zone='guildmaster_island',ID=1,Entry=3}}
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
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sleeper_Line_001']))
  
  if SV.Experimental ~= true then
    return
  end
  
  UI:ChoiceMenuYesNo(STRINGS:Format(STRINGS.MapStrings['Sleeper_Line_Ask'], name), true)
  UI:WaitForChoice()
  local ch = UI:ChoiceResult()
  
  if ch then
    SOUND:PlayBGM("", true)
    --start wiggling
    GROUND:CharSetDrawEffect(chara, DrawEffect.Trembling)
    UI:SetSpeaker(chara)
    UI:SetSpeakerEmotion("Sad")
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sleeper_Line_002']))
    --pose in anger
    local animId = RogueEssence.Content.GraphicsManager.GetAnimIndex("Shoot")
    GROUND:CharSetAction(chara, RogueEssence.Ground.FrameGroundAction(chara.Position, chara.Direction, animId, 0))
    SOUND:PlayBattleSE("EVT_Roar")
    UI:SetSpeaker(chara, false)
    UI:SetSpeakerEmotion("Angry")
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sleeper_Line_003']))
    SV.forest_camp.SnorlaxPhase = 1
    
    local deliver = CH("NPC_Deliver")
    local carry = CH("NPC_Carry")
    local player = CH('PLAYER')
    GROUND:CharTurnToChar(deliver, player)
    GROUND:CharTurnToChar(carry, player)
    
    GROUND:CharSetEmote(deliver, "sweating", 1)
    GROUND:CharSetEmote(carry, "sweating", 1)
    
    SOUND:PlayBattleSE("EVT_Battle_Transition")
    GAME:FadeOut(true, 60)
    GROUND:CharEndDrawEffect(chara, DrawEffect.Trembling)
    GAME:EnterDungeon('guildmaster_island', 0, 3, 0, RogueEssence.Data.GameProgress.DungeonStakes.Progress, true, true)
  end
end

function forest_camp.Snorlax_Fail()
  local player = CH('PLAYER')
  local snorlax = CH("Snorlax")
  local deliver = CH("NPC_Deliver")
  local carry = CH("NPC_Carry")
  SOUND:PlayBGM("", true)
  
  GROUND:CharTurnToChar(deliver, player)
  GROUND:CharTurnToChar(carry, player)
  
  --everyone is dead
  GROUND:CharSetDrawEffect(snorlax, DrawEffect.Trembling)
  local animId = RogueEssence.Content.GraphicsManager.GetAnimIndex("Shoot")
  GROUND:CharSetAction(snorlax, RogueEssence.Ground.FrameGroundAction(snorlax.Position, snorlax.Direction, animId, 0))
  
  local animId = RogueEssence.Content.GraphicsManager.GetAnimIndex("Pain")
  GROUND:CharSetAction(player, RogueEssence.Ground.FrameGroundAction(player.Position, player.Direction, animId, 10))
  GAME:FadeIn(20)
  
  UI:SetSpeaker(snorlax)
  UI:SetSpeakerEmotion("Angry")
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sleeper_Line_Fail_001']))
  GAME:WaitFrames(10)
  
  --snorlax collapses back
  SOUND:PlayBattleSE("_UNK_EVT_018")
  GROUND:CharEndDrawEffect(snorlax, DrawEffect.Trembling)
  GROUND:CharSetAnim(snorlax, "Sleep", true)
  
  GAME:WaitFrames(60)
  SOUND:PlayBGM(_ZONE.CurrentGround.Music, true)
  
  if SV.forest_camp.SnorlaxAttempted then
    GROUND:CharEndAnim(player)
    GROUND:CharAnimateTurnTo(player, Direction.Down, 4)
  else
    -- camera down
    GAME:MoveCamera(0, 60, 40, true)
    
    SOUND:PlayBattleSE("EVT_Emote_Sweatdrop")
    GROUND:CharSetEmote(deliver, "sweatdrop", 1)
    GAME:WaitFrames(30)
    UI:SetSpeaker(deliver)
    UI:SetSpeakerEmotion("Stunned")
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sleeper_Line_Fail_002']))
    
    GROUND:CharEndAnim(player)
    GROUND:CharAnimateTurnTo(player, Direction.Down, 4)

    UI:SetSpeaker(carry)
    UI:SetSpeakerEmotion("Worried")
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sleeper_Line_Fail_003'], snorlax:GetDisplayName()))
    --move back to position
    
    GAME:MoveCamera(0, 0, 40, true)
    SV.forest_camp.SnorlaxAttempted = true
  end
end

function forest_camp.Snorlax_Success()
  local ground = _DATA:GetGround("forest_camp")
  
  local player = CH('PLAYER')
  
  local snorlax = CH("Snorlax")
  local deliver = CH("NPC_Deliver")
  local storehouse = CH("NPC_Storehouse")
  local carry = CH("NPC_Carry")
  
  GROUND:TeleportTo(deliver, 348, 344, Direction.Up)
  GROUND:TeleportTo(carry, 380, 344, Direction.Up)
  
  GROUND:CharSetDrawEffect(snorlax, DrawEffect.Trembling)
  local animId = RogueEssence.Content.GraphicsManager.GetAnimIndex("Shoot")
  GROUND:CharSetAction(snorlax, RogueEssence.Ground.FrameGroundAction(snorlax.Position, snorlax.Direction, animId, 0))
  
  GAME:FadeIn(20)
  
  UI:SetSpeaker(snorlax)
  UI:SetSpeakerEmotion("Shouting")
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sleeper_Line_Success_001']))
  GROUND:CharEndDrawEffect(snorlax, DrawEffect.Trembling)
  SOUND:PlayBattleSE("_UNK_EVT_069")
  GROUND:MoveToPosition(snorlax, 292, 316, true, 4)
  GROUND:MoveToPosition(snorlax, 292, 432, true, 4)
  --snorlax runs off
  GROUND:Hide("Snorlax")
  --the team walks up (semi-parallel)
  GAME:WaitFrames(30)
  
  local coro1 = TASK:BranchCoroutine(function() forest_camp.Carry_Sequence_1(carry) end)
  GAME:WaitFrames(20)
  local coro2 = TASK:BranchCoroutine(function() forest_camp.Deliver_Sequence_1(deliver) end)
  -- wait to join coroutines before giving control back to the player
  TASK:JoinCoroutines({coro1, coro2})
  
  UI:SetSpeaker(CH("NPC_Carry"))
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sleeper_Line_Success_002'], snorlax:GetDisplayName()))
  UI:SetSpeaker(CH("NPC_Deliver"))
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sleeper_Line_Success_003'], ground:GetColoredName()))
  
  --they rummage the tent
  GROUND:CharAnimateTurnTo(deliver, Direction.UpRight, 4)
  GROUND:CharAnimateTurnTo(carry, Direction.UpLeft, 4)
  
  GROUND:CharSetAnim(deliver, "Walk", true)
  GROUND:CharSetAnim(carry, "Walk", true)
  --rummaging sounds
  SOUND:PlayBattleSE("_UNK_EVT_116")
  GAME:WaitFrames(30)
  SOUND:PlayBattleSE("_UNK_EVT_010")
  GAME:WaitFrames(10)
  SOUND:PlayBattleSE("_UNK_EVT_010")
  GAME:WaitFrames(20)
  SOUND:PlayBattleSE("_UNK_EVT_128")
  GAME:WaitFrames(10)
  GROUND:CharEndAnim(carry)
  GROUND:CharEndAnim(deliver)
  GAME:WaitFrames(30)
  
  GROUND:CharAnimateTurnTo(deliver, Direction.Right, 4)
  UI:SetSpeaker(CH("NPC_Deliver"))
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sleeper_Line_Success_004'], carry:GetDisplayName(), storehouse:GetDisplayName()))
  
  GROUND:CharAnimateTurnTo(carry, Direction.DownLeft, 4)
  UI:SetSpeaker(CH("NPC_Carry"))
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sleeper_Line_Success_005']))
  local receive_item = RogueEssence.Dungeon.InvItem("apricorn_big")
  COMMON.GiftItem(player, receive_item)
  

  local coro1 = TASK:BranchCoroutine(function() forest_camp.Carry_Sequence_2(carry) end)
  local coro2 = TASK:BranchCoroutine(function() forest_camp.Deliver_Sequence_2(deliver) end)
  -- wait to join coroutines before giving control back to the player
  TASK:JoinCoroutines({coro1, coro2})
  
end

function forest_camp.Deliver_Sequence_1(deliver)

  deliver.CollisionDisabled = true
  GROUND:MoveToPosition(deliver, 348, 248, false, 2)
  GROUND:CharAnimateTurnTo(deliver, Direction.DownRight, 4)
end

function forest_camp.Carry_Sequence_1(carry)
  carry.CollisionDisabled = true
  GROUND:MoveToPosition(carry, 380, 256, false, 2)
  GROUND:CharAnimateTurnTo(carry, Direction.DownLeft, 4)
end

function forest_camp.Deliver_Sequence_2(deliver)
  --they head off
  GROUND:MoveToPosition(deliver, 328, 248, false, 2)
  GROUND:MoveToPosition(deliver, 292, 220, false, 2)
  GROUND:MoveToPosition(deliver, 292, 120, false, 2)
  GROUND:Hide("NPC_Deliver")
end

function forest_camp.Carry_Sequence_2(carry)
  GROUND:MoveToPosition(carry, 336, 256, false, 2)
  GROUND:MoveToPosition(carry, 292, 220, false, 2)
  GROUND:MoveToPosition(carry, 292, 120, false, 2)
  GROUND:Hide("NPC_Carry")
end

function forest_camp.NPC_Storehouse_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)
  
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Storehouse_Line_Route']))

end

function forest_camp.NPC_Carry_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)
  
  if SV.supply_corps.Status == 0 then
    local snorlax = CH("Snorlax")
    if SV.forest_camp.SnorlaxAttempted then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_003'], snorlax:GetDisplayName()))
    else
      UI:SetSpeakerEmotion("Angry")
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_001'], snorlax:GetDisplayName()))
      UI:SetSpeakerEmotion("Stunned")
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_002']))
      GROUND:EntTurn(chara, Direction.Left)
    end
  elseif SV.supply_corps.Status >= 20 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_Route']))
  end
  

end

function forest_camp.NPC_Deliver_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)
  
  if SV.supply_corps.Status == 0 then
    local snorlax = CH("Snorlax")
    if SV.forest_camp.SnorlaxAttempted then
      UI:SetSpeakerEmotion("Sad")
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Deliver_Line_002'], snorlax:GetDisplayName()))
    else
      UI:SetSpeakerEmotion("Pain")
      SOUND:PlayBattleSE("EVT_Emote_Sweating")
      GROUND:CharSetEmote(chara, "sweating", 1)
      GAME:WaitFrames(30)
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Deliver_Line_001']))
      GROUND:EntTurn(chara, Direction.Right)
    end
  elseif SV.supply_corps.Status >= 20 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Deliver_Line_Route']))
  end
  
end


function forest_camp.NPC_Elder_Action(chara, activator)
  
  local zone_summary = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get("ambush_forest")
  
  if SV.town_elder.Status == 1 then
  
    local questname = "QuestGround"
    local quest = SV.missions.Missions[questname]
    
    if quest == nil then
      UI:SetSpeaker(chara)
      GROUND:CharTurnToChar(chara,CH('PLAYER'))
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Elder_Line_001'], GAME:GetTeamName(), zone_summary:GetColoredName()))
      
      COMMON.CreateMission(questname,
      { Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.SIDEQUEST_TYPE_LOST_ITEM,
          DestZone = "ambush_forest", DestSegment = 0, DestFloor = 11,
          FloorUnknown = false,
        TargetItem = RogueEssence.Dungeon.InvItem("lost_item_ground"),
          ClientSpecies = RogueEssence.Dungeon.MonsterID("donphan", 0, "normal", Gender.Male) }
      )
    else
    
      COMMON.TakeMissionItem(quest)
    
      if quest.Complete == COMMON.MISSION_INCOMPLETE then
        UI:SetSpeaker(chara)
        GROUND:CharTurnToChar(chara,CH('PLAYER'))
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Elder_Line_002'], zone_summary:GetColoredName()))
      else
        forest_camp.Ground_Complete()
      end
    end
  
  elseif SV.town_elder.Status == 2 then
    
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Elder_Complete_Line_002']))
  end
  
end

function forest_camp.Ground_Complete()
  local elder = CH('NPC_Elder')
  local player = CH('PLAYER')
  
  GROUND:CharTurnToChar(elder,player)
  
  SOUND:PlayBattleSE("EVT_Emote_Exclaim_2")
  GROUND:CharSetEmote(elder, "exclaim", 1)
  GAME:WaitFrames(40)
  
  UI:SetSpeaker(elder)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Elder_Complete_Line_001']))
  
  local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_ground_silk")
  COMMON.GiftItem(player, receive_item)
  
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Elder_Complete_Line_002']))
  
  COMMON.CompleteMission("QuestGround")
  
  SV.town_elder.Status = 2
end

function forest_camp.Speedster_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local player = CH('PLAYER')
  GROUND:CharTurnToChar(chara,player)
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character

	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Doduo_Line_001']))
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Doduo_Line_002']))
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Doduo_Line_003']))
	GROUND:EntTurn(chara, Direction.UpLeft)
end
  
function forest_camp.Speedster_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local player = CH('PLAYER')
  GROUND:CharTurnToChar(chara,player)
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  
  local receive_item = RogueEssence.Dungeon.InvItem("orb_escape")
  if not SV.team_retreat.SpokenTo then
    GROUND:CharTurnToChar(chara, player)--make the chara turn to the player
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Pachirisu_Line_001']))
	COMMON.GiftItem(player, receive_item)
	
	SV.team_retreat.SpokenTo = true
  end
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Pachirisu_Line_002'], receive_item:GetDisplayName()))
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Pachirisu_Line_003']))
  
  GROUND:EntTurn(chara, Direction.DownRight)
end


function forest_camp.NPC_Camps_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  
  if SV.forest_child.Status == 0 then
    forest_camp.Talk_Camps()
  elseif SV.forest_child.Status == 1 then
    forest_camp.Sick_Child(chara)
  elseif SV.forest_child.Status == 2 then
    forest_camp.Sick_Child(chara)
  else
    forest_camp.Talk_Camps()
  end
  
end

function forest_camp.Talk_Camps()
  local chara = CH('NPC_Camps')
  local zone_summary = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get("faded_trail")
  local ground = _DATA:GetGround("cliff_camp")
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Camps_Line_001'], zone_summary:GetColoredName(), ground:GetColoredName()))
end

function forest_camp.NPC_Parent_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  if SV.forest_child.Status == 0 then
    forest_camp.Parent_Child()
  elseif SV.forest_child.Status == 1 then
    forest_camp.Sick_Child(chara)
  elseif SV.forest_child.Status == 2 then
    forest_camp.Sick_Child(chara)
  elseif SV.forest_child.Status == 3 then
    forest_camp.Parent_Child()
  else
    local parent = CH('NPC_Parent')
	GROUND:CharTurnToChar(parent,CH('PLAYER'))
    UI:SetSpeaker(parent)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Parent_Line_001']))
  end
end

function forest_camp.NPC_Child_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  if SV.forest_child.Status >= 4 then
    forest_camp.Child_Secret()
  else
    forest_camp.Parent_Child()
  end
end



function forest_camp.Parent_Child()
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local parent = CH('NPC_Parent')
  local child = CH('NPC_Child')
  local player = CH('PLAYER')
  
  if SV.forest_child.Status == 0 then
  
    GROUND:CharTurnToChar(player, child)
    UI:SetSpeaker(child)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Parent_Child_Line_001']))
    GROUND:CharTurnToChar(player, parent)
    UI:SetSpeaker(parent)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Parent_Child_Line_002']))
    
    if SV.Experimental then
      SV.forest_child.SpokenTo = true
    end
  
  elseif SV.forest_child.Status == 3 then
  
    GROUND:CharTurnToChar(parent, player)
    UI:SetSpeaker(parent)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Cure_After_Line_001'], child:GetDisplayName(), _DATA.Save.ActiveTeam.Name))
    GROUND:CharTurnToChar(child, player)
    UI:SetSpeaker(child)
    UI:SetSpeakerEmotion("Inspired")
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Cure_After_Line_002']))
  
  end
end

function forest_camp.Sick_Child(chara)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local parent = CH('NPC_Parent')
  local child = CH('NPC_Child')
  local camps = CH('NPC_Camps')
  local player = CH('PLAYER')
	
  if SV.forest_child.Status == 1 then
  
    local questname = "QuestGrass"
    local quest = SV.missions.Missions[questname]
    
    local zone_summary = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get("sickly_hollow")

  
    if quest == nil then
      
      SOUND:PlayBattleSE("EVT_Emote_Sweating")
      GROUND:CharSetEmote(parent, "sweating", 1)
      GAME:WaitFrames(30)
      
      UI:SetSpeaker(parent)
      UI:SetSpeakerEmotion("Worried")
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sickness_Line_001'], child:GetDisplayName()))

      UI:SetSpeaker(camps)
      UI:SetSpeakerEmotion("Worried")
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sickness_Line_002'], zone_summary:GetColoredName()))
      
      GROUND:CharSetEmote(parent, "shock", 1)
      SOUND:PlayBattleSE("EVT_Emote_Shock")
      GAME:WaitFrames(60)
      
      UI:SetSpeaker(parent)
      UI:SetSpeakerEmotion("Surprised")
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sickness_Line_003'], zone_summary:GetColoredName()))

      UI:SetSpeaker(camps)
      UI:SetSpeakerEmotion("Worried")
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sickness_Line_004']))

      UI:SetSpeaker(parent)
      UI:SetSpeakerEmotion("Shouting")
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sickness_Line_005'], zone_summary:GetColoredName()))

      UI:SetSpeaker(camps)
      UI:SetSpeakerEmotion("Pain")
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sickness_Line_006']))
    
      SOUND:PlayBattleSE("EVT_Emote_Sweating")
      GROUND:CharSetEmote(camps, "sweating", 1)
      GAME:WaitFrames(30)
    
      GROUND:CharTurnToChar(camps, player)
      GROUND:CharTurnToChar(parent, player)
      local experienced = false
    
      UI:SetSpeaker(camps)
      UI:SetSpeakerEmotion("Worried")
      if experienced then
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sickness_Line_007_Skilled'], _DATA.Save.ActiveTeam.Name, zone_summary:GetColoredName()))
      else
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sickness_Line_007'], _DATA.Save.ActiveTeam.Name, zone_summary:GetColoredName()))
      end
    
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sickness_Line_008'], zone_summary:GetColoredName(), child:GetDisplayName()))

      local destFloor = 10

    
      COMMON.CreateMission(questname,
        { Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.SIDEQUEST_TYPE_LOST_ITEM,
            DestZone = "sickly_hollow", DestSegment = 0, DestFloor = destFloor,
            FloorUnknown = false,
            TargetItem = RogueEssence.Dungeon.InvItem("lost_item_grass"),
            ClientSpecies = RogueEssence.Dungeon.MonsterID("sunflora", 0, "normal", Gender.Male)
        }
      )
    else
    
      COMMON.TakeMissionItem(quest)
    
      if quest.Complete == COMMON.MISSION_INCOMPLETE then
        local camps = CH('NPC_Camps')
        UI:SetSpeaker(chara)
        GROUND:CharTurnToChar(chara,CH('PLAYER'))
      
        if chara == camps then
          UI:SetSpeakerEmotion("Worried")
          UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Camps_Sickness_Line_001'], quest.DestFloor + 1, zone_summary:GetColoredName()))
        else
          SOUND:PlayBattleSE("EVT_Emote_Sweating")
          GROUND:CharSetEmote(parent, "sweating", 1)
          GAME:WaitFrames(30)
          UI:SetSpeakerEmotion("Sad")
          UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Parent_Sickness_Line_001']))
        end
      else
        forest_camp.Grass_Complete()
      end
    end
  
  elseif SV.forest_child.Status == 2 then
  
      local camps = CH('NPC_Camps')
      UI:SetSpeaker(chara)
      GROUND:CharTurnToChar(chara,CH('PLAYER'))
	  
	  if chara == camps then
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Cure_Done_Line_001'], child:GetDisplayName()))
	  else
	    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Cure_Done_Line_002']))
	  end
  end
end

function forest_camp.Grass_Complete()
  local parent = CH('NPC_Parent')
  local child = CH('NPC_Child')
  local camps = CH('NPC_Camps')
  local player = CH('PLAYER')
  
  GROUND:CharTurnToChar(parent,player)
  GROUND:CharTurnToChar(camps,player)
  
  SOUND:PlayBattleSE("EVT_Emote_Exclaim_2")
  GROUND:CharSetEmote(camps, "exclaim", 1)
  
  GAME:WaitFrames(40)
  
  UI:SetSpeaker(camps)
  UI:SetSpeakerEmotion("Surprised")
  local quest_item = RogueEssence.Dungeon.InvItem("lost_item_grass")
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Cure_Line_001'], quest_item:GetDisplayName(), child:GetDisplayName()))
  
  GAME:FadeOut(false, 30)
  
  SOUND:PlayBattleSE("DUN_Aromatherapy")
  GAME:WaitFrames(60)
  
  GROUND:TeleportTo(player, 240, 352, Direction.UpLeft)
  GROUND:TeleportTo(parent, 200, 336, Direction.UpRight)
  GROUND:TeleportTo(camps, 216, 328, Direction.UpLeft)
  
  GAME:FadeIn(30)
  
  GROUND:CharAnimateTurnTo(camps, Direction.DownRight, 4)
  
  UI:SetSpeakerEmotion("Sigh")
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Cure_Line_002'], child:GetDisplayName()))
  
  GROUND:CharTurnToChar(parent,player)
  UI:SetSpeaker(parent)
  UI:SetSpeakerEmotion("Teary-Eyed")
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Cure_Line_003'], _DATA.Save.ActiveTeam.Name))
  
  local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_grass_silk")
  COMMON.GiftItem(player, receive_item)
  
  COMMON.CompleteMission("QuestGrass")
  
  SV.forest_child.Status = 2
end


function forest_camp.NPC_Catch_1_Action(chara, activator)
  DEBUG.EnableDbgCoro()
  
  forest_camp.Catch_Action()
end

function forest_camp.NPC_Catch_2_Action(chara, activator)
  DEBUG.EnableDbgCoro()
  forest_camp.Catch_Action()
  
end

function forest_camp.Catch_Action()
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local catch1 = CH('NPC_Catch_1')
  local catch2 = CH('NPC_Catch_2')
  local player = CH('PLAYER')
  local itemAnim = nil
  
  GROUND:CharTurnToChar(player, catch1)
  UI:SetSpeaker(catch1)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Catch_Line_001']))
  SOUND:PlayBattleSE("DUN_Throw_Start")
  GROUND:CharSetAnim(catch1, "Rotate", false)
  GAME:WaitFrames(18)
  SOUND:PlayBattleSE("DUN_Throw_Arc")
  itemAnim = RogueEssence.Content.ItemAnim(catch1.Bounds.Center, catch2.Bounds.Center, "Rock_Gray", 48, 1)
  GROUND:PlayVFXAnim(itemAnim, RogueEssence.Content.DrawLayer.Normal)
  
  GROUND:CharTurnToChar(player, catch2)
  GAME:WaitFrames(RogueEssence.Content.ItemAnim.ITEM_ACTION_TIME)
	
  SOUND:PlayBattleSE("DUN_Equip")
  UI:SetSpeaker(catch2)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Catch_Line_002']))
  SOUND:PlayBattleSE("DUN_Throw_Start")
  GROUND:CharSetAnim(catch2, "Rotate", false)
  GAME:WaitFrames(18)
  SOUND:PlayBattleSE("DUN_Throw_Arc")
  itemAnim = RogueEssence.Content.ItemAnim(catch2.Bounds.Center, catch1.Bounds.Center, "Rock_Gray", 48, 1)
  GROUND:PlayVFXAnim(itemAnim, RogueEssence.Content.DrawLayer.Normal)
  
  GROUND:CharTurnToChar(player, catch1)
  GAME:WaitFrames(RogueEssence.Content.ItemAnim.ITEM_ACTION_TIME)
  
  SOUND:PlayBattleSE("DUN_Equip")
  
  
  SV.team_catch.SpokenTo = true
end


function forest_camp.NPC_Unlucky_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  
  UI:SetSpeaker(chara)
  SOUND:PlayBattleSE("EVT_Emote_Sweating")
  GROUND:CharSetEmote(chara, "sweating", 1)
  GAME:WaitFrames(30)
  UI:SetSpeakerEmotion("Worried")
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Unlucky_Line_001']))
  
  
  if SV.Experimental then
    SV.team_kidnapped.SpokenTo = true
  end
end

function forest_camp.NPC_Solo_Action(chara, activator)
  
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Solo_Line_001']))
  
  GROUND:Hide("NPC_Solo")
  
  SV.team_solo.SpokenTo = true
  
end

forest_camp.guiding = false
function forest_camp.Child_Secret()
  
  local child = CH('NPC_Child')
  GROUND:CharTurnToChar(child,CH('PLAYER'))
  UI:SetSpeaker(child)
  if SV.forest_child.Status >= 5 then
    --ask the revisit qustion
    local zone_summary = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get("secret_garden")
    UI:ChoiceMenuYesNo(STRINGS:Format(STRINGS.MapStrings['Child_Secret_Ask_Again']), false)
  else
    GROUND:CharSetEmote(child, "glowing", 4)
    UI:SetSpeakerEmotion("Joyous")
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Child_Secret_Line_001']))
    
    UI:SetSpeakerEmotion("Normal")
    UI:ChoiceMenuYesNo(STRINGS:Format(STRINGS.MapStrings['Child_Secret_Ask']), false)
    
    -- set to "started showing secret garden"
    SV.forest_child.Status = 5
  end
  

  
  UI:WaitForChoice()
  local ch = UI:ChoiceResult()
  
  if ch then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Child_Secret_Checkpoint_001']))
	
    -- make the sunkern intangible
    child.CollisionDisabled = true
	
    -- move the sunkern in
    GROUND:MoveToPosition(child, 424, 384, false, 2)
    GROUND:MoveToPosition(child, 472, 384, false, 2)
	
    GROUND:Unhide("NPC_Child")
    
    --activate checkpoint 1
    GROUND:Unhide("Guide_1")
    GROUND:Unhide("Guide_2")
    GROUND:Unhide("Guide_3")
    GROUND:Unhide("Guide_4")
    GROUND:Unhide("Guide_5")
    GROUND:Unhide("Guide_End")
    
    forest_camp.guiding = true
  end
end

function forest_camp.Guide_1_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  -- give the next instructions
  local child = CH('NPC_Child')
  UI:SetSpeaker(child)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Child_Secret_Checkpoint_002']))
  GROUND:Hide("Guide_1")
end

function forest_camp.Guide_2_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  -- give the next instructions
  local child = CH('NPC_Child')
  UI:SetSpeaker(child)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Child_Secret_Checkpoint_003']))
  GROUND:Hide("Guide_2")
end

function forest_camp.Guide_3_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  -- give the next instructions
  local child = CH('NPC_Child')
  UI:SetSpeaker(child)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Child_Secret_Checkpoint_004']))
  GROUND:Hide("Guide_3")
end

function forest_camp.Guide_4_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  -- give the next instructions
  local child = CH('NPC_Child')
  UI:SetSpeaker(child)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Child_Secret_Checkpoint_005']))
  GROUND:Hide("Guide_4")
end

function forest_camp.Guide_5_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  -- give the next instructions
  local child = CH('NPC_Child')
  UI:SetSpeaker(child)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Child_Secret_Checkpoint_006']))
  GROUND:Hide("Guide_5")
end

function forest_camp.Guide_End_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  forest_camp.Secret_Complete()
end

function forest_camp.Secret_Mistake()

  if forest_camp.guiding == true then
    local child = CH('NPC_Child')
    UI:SetSpeaker(child)
    UI:SetSpeakerEmotion("Stunned")
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Child_Secret_Mistake_001']))
	
	forest_camp.Secret_End()
  end
end


function forest_camp.Secret_Complete()

  if forest_camp.guiding == true then
    local zone_summary = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get("secret_garden")
    local child = CH('NPC_Child')
    UI:SetSpeaker(child)
    UI:SetSpeakerEmotion("Joyous")
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Child_Secret_Complete_001'], zone_summary:GetColoredName()))
	
    if SV.forest_child.Status == 5 then
      UI:SetSpeakerEmotion("Normal")
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Child_Secret_Complete_002'], zone_summary:GetColoredName()))
      SV.forest_child.Status = 6
    end
    
    forest_camp.Secret_End()
  end
end

function forest_camp.Secret_End()
  local child = CH('NPC_Child')
  
  -- move the child back
  GROUND:Unhide("NPC_Child")
  child.CollisionDisabled = false
  GROUND:MoveToPosition(child, 424, 384, false, 2)
  GROUND:MoveToPosition(child, 408, 368, false, 2)
  GROUND:EntTurn(child, Direction.Down)
  
  GROUND:Hide("Guide_1")
  GROUND:Hide("Guide_2")
  GROUND:Hide("Guide_3")
  GROUND:Hide("Guide_4")
  GROUND:Hide("Guide_5")
  GROUND:Hide("Guide_End")
  forest_camp.guiding = false
end

function forest_camp.Reset_Gate_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:Unhide("Block_Gate_Up")
  GROUND:Unhide("Block_Gate_Down")
  GROUND:Hide("Block_Gate_1")
  GROUND:Hide("Block_Gate_2")
  GROUND:Unhide("Close_Gate_1")
  GROUND:Unhide("Close_Gate_2")
  GROUND:Unhide("Close_Gate_5")
end

function forest_camp.Open_Gate_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:Hide("Block_Gate_Up")
  GROUND:Hide("Block_Gate_Down")
  GROUND:Hide("Close_Gate_1")
  GROUND:Hide("Close_Gate_2")
end

function forest_camp.Close_Gate_1_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:Unhide("Block_Gate_1")
  forest_camp.Secret_Mistake()
end

function forest_camp.Close_Gate_2_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:Unhide("Block_Gate_1")
  forest_camp.Secret_Mistake()
end


function forest_camp.Close_Gate_3_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:Unhide("Block_Gate_2")
  forest_camp.Secret_Mistake()
end

function forest_camp.Close_Gate_4_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:Unhide("Block_Gate_2")
  forest_camp.Secret_Mistake()
end


function forest_camp.Close_Gate_5_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:Hide("Open_Gate")
  forest_camp.Secret_Mistake()
end

function forest_camp.Close_Gate_6_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:Hide("Open_Gate")
  forest_camp.Secret_Mistake()
end


function forest_camp.Secret_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GAME:UnlockDungeon('secret_garden')
  
  local dungeon_entrances = { 'secret_garden' }
  local ground_entrances = { }
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end


function forest_camp.Assembly_Secret_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  COMMON.ShowTeamAssemblyMenu(obj, COMMON.RespawnAllies)
end

function forest_camp.Storage_Secret_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON:ShowTeamStorageMenu()
end

function forest_camp.Teammate1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara)
end

function forest_camp.Teammate2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara)
end

function forest_camp.Teammate3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara)
end

return forest_camp