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
	GROUND:TeleportTo(camps, 200, 336, Direction.Left)
  elseif SV.forest_child.Status == 3 then
    GROUND:Unhide("NPC_Child")
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
  local dungeon_entrances = { 'faded_trail', 'bramble_woods', 'trickster_woods', 'overgrown_wilds', 'moonlit_courtyard', 'ambush_forest', 'tiny_tunnel', 'energy_garden', 'sickly_hollow', 'secret_garden'}
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
  ch = UI:ChoiceResult()
  
  if ch then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sleeper_Line_002']))
	SV.forest_camp.SnorlaxPhase = 1
    SOUND:PlayBattleSE("EVT_Battle_Transition")
    GAME:FadeOut(true, 60)
    GAME:EnterDungeon('guildmaster_island', 0, 3, 0, RogueEssence.Data.GameProgress.DungeonStakes.Progress, true, true)
  end
end

function forest_camp.Snorlax_Fail()
  --snorlax collapses back
  --everyone is dead
  GAME:FadeIn(20)
  --ekans: he doesn't like to have his sleep disturbed
  UI:SetSpeaker(CH("NPC_Deliver"))
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sleeper_Line_Fail_001']))
  --move back to position
end

function forest_camp.Snorlax_Success()
  local player = CH('PLAYER')
  
  GAME:FadeIn(20)
  --snorlax runs off
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sleeper_Line_Success_001']))
  GROUND:Hide("Snorlax")
  --the team thanks you, gives you a stock
  UI:SetSpeaker(CH("NPC_Deliver"))
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sleeper_Line_Success_002']))
  local receive_item = RogueEssence.Dungeon.InvItem("apricorn_big")
  COMMON.GiftItem(player, receive_item)
  --they head off
  UI:SetSpeaker(CH("NPC_Carry"))
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sleeper_Line_Success_003']))
  GROUND:Hide("NPC_Carry")
  GROUND:Hide("NPC_Deliver")
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
    UI:SetSpeakerEmotion("Angry")
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_001']))
    UI:SetSpeakerEmotion("Stunned")
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_002']))
    GROUND:EntTurn(chara, Direction.Left)
  elseif SV.supply_corps.Status >= 20 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Carry_Line_Route']))
  end
  

end

function forest_camp.NPC_Deliver_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)
  
  if SV.supply_corps.Status == 0 then
    UI:SetSpeakerEmotion("Pain")
    SOUND:PlayBattleSE("EVT_Emote_Sweating")
    GROUND:CharSetEmote(chara, "sweating", 1)
    GAME:WaitFrames(30)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Deliver_Line_001']))
    GROUND:EntTurn(chara, Direction.Right)
  elseif SV.supply_corps.Status >= 20 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Deliver_Line_Route']))
  end
  
end


function forest_camp.NPC_Elder_Action(chara, activator)
  
  if SV.town_elder.Status == 1 then
  
  local questname = "QuestGround"
  local quest = SV.missions.Missions[questname]
  
  if quest == nil then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,CH('PLAYER'))
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Elder_Line_001']))
	
	COMMON.CreateMission(questname,
	{ Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_LOST_ITEM,
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
	  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Elder_Line_002']))
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
  local broke = CH('NPC_Elder')
  local player = CH('PLAYER')
  
  GROUND:CharTurnToChar(broke,player)
  
  UI:SetSpeaker(broke)
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
    forest_camp.Sick_Child()
  elseif SV.forest_child.Status == 2 then
    forest_camp.Sick_Child()
  elseif SV.forest_child.Status == 3 then
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
    forest_camp.Sick_Child()
  elseif SV.forest_child.Status == 2 then
    forest_camp.Sick_Child()
  elseif SV.forest_child.Status == 3 then
    forest_camp.Parent_Child()
  end
end

function forest_camp.NPC_Child_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  forest_camp.Parent_Child()
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
  
  GROUND:CharTurnToChar(player, parent)
  UI:SetSpeaker(parent)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Cure_Line_004']))
  GROUND:CharTurnToChar(player, child)
  UI:SetSpeaker(child)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Cure_Line_005']))
  
  end
end

function forest_camp.Sick_Child()
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  if SV.forest_child.Status == 1 then
  
  local questname = "QuestGrass"
  local quest = SV.missions.Missions[questname]
  
  if quest == nil then
    local parent = CH('NPC_Parent')
    local camps = CH('NPC_Camps')
    local player = CH('PLAYER')

    UI:SetSpeaker(parent)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sickness_Line_001']))

    UI:SetSpeaker(camps)
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sickness_Line_002']))

    GROUND:CharTurnToChar(player, camps)
    GROUND:CharTurnToChar(player, parent)
    local destFloor = 10
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sickness_Line_003'], tostring(destFloor+1)))

	
    COMMON.CreateMission(questname,
      { Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_LOST_ITEM,
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
      UI:SetSpeaker(camps)
      GROUND:CharTurnToChar(camps,CH('PLAYER'))
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sickness_Line_004']))
    else
      forest_camp.Grass_Complete()
    end
  end
  
  elseif SV.forest_child.Status == 2 then
    
    local parent = CH('NPC_Parent')
    UI:SetSpeaker(parent)
    GROUND:CharTurnToChar(parent,CH('PLAYER'))
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Cure_Line_003']))
  end
end

function forest_camp.Grass_Complete()
	local parent = CH('NPC_Parent')
	local camps = CH('NPC_Camps')
	local player = CH('PLAYER')
  
  GROUND:CharTurnToChar(parent,player)
  GROUND:CharTurnToChar(camps,player)
  
  UI:SetSpeaker(camps)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Cure_Line_001']))
  
  UI:SetSpeaker(parent)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Cure_Line_002']))
  
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