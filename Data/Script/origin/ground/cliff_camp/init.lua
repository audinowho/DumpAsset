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
  
  if SV.team_kidnapped.Status ~= 3 and SV.team_kidnapped.Status ~= 4 then
    COMMON.CreateWalkArea("NPC_Sightseer", 144, 328, 48, 48)
  end
  
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
	
	cliff_camp.CheckMissions()
	
    GAME:FadeIn(20)
  end

end

function cliff_camp.Update(map, time)
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------
function cliff_camp.SetupNpcs()
  
  GROUND:Unhide("NPC_Undergrowth_1")
  GROUND:Unhide("NPC_Undergrowth_2")
  GROUND:Unhide("NPC_Sightseer")
  
  if not SV.family.Father and SV.family.FatherActiveDays >= 3 then
  
	local undergrowth1 = CH('NPC_Undergrowth_2')
	local undergrowth2 = CH('NPC_Undergrowth_1')
	GROUND:TeleportTo(undergrowth1, 312, 240, Direction.DownRight)
	GROUND:TeleportTo(undergrowth2, 336, 268, Direction.UpLeft)
  elseif not SV.family.Pet and SV.family.PetActiveDays >= 3 and SV.family.Sister and SV.family.Mother and SV.family.Father and SV.family.Brother then
  
	local undergrowth1 = CH('NPC_Undergrowth_2')
	local undergrowth2 = CH('NPC_Undergrowth_1')
	GROUND:TeleportTo(undergrowth1, 312, 240, Direction.DownRight)
	GROUND:TeleportTo(undergrowth2, 336, 268, Direction.UpLeft)
  end
  
  if SV.team_hunter.Status == 1 then
    GROUND:Unhide("NPC_Broke")
	local broke = CH('NPC_Broke')
	GROUND:TeleportTo(broke, 744, 268, Direction.Right)
  elseif SV.team_hunter.Status == 2 then
    GROUND:Unhide("NPC_Broke")
  elseif SV.team_hunter.Status == 3 then
    -- TODO cycling
  end
  
  if SV.team_catch.Status == 3 then
    GROUND:Unhide("NPC_Catch_1")
	GROUND:Unhide("NPC_Catch_2")
	
	local questname = "QuestNormal"
    local quest = SV.missions.Missions[questname]
	if quest ~= nil then
	  local catch1 = CH('NPC_Catch_1')
	  local catch2 = CH('NPC_Catch_2')
	  GROUND:TeleportTo(catch1, 420, 400, Direction.Down)
	  GROUND:TeleportTo(catch2, 440, 384, Direction.Down)
	end
  elseif SV.team_catch.Status == 4 then
    -- TODO cycling
  end
  
  if SV.Experimental and SV.team_rivals.Status == 0 then
    GROUND:Unhide("Rival_1")
	GROUND:Unhide("Rival_2")
  elseif SV.team_rivals.Status == 9 then
    -- TODO cycling
  end
  
  if SV.team_kidnapped.Status == 2 and SV.team_kidnapped.SpokenTo == false then
    GROUND:Unhide("NPC_Unlucky")
	GROUND:Unhide("NPC_Kidnap")
	local unlucky = CH('NPC_Unlucky')
	GROUND:TeleportTo(unlucky, 96, 456, Direction.Right)
  elseif SV.team_kidnapped.Status == 3 then
	local sightseer = CH('NPC_Sightseer')
	GROUND:TeleportTo(sightseer, 160, 392, Direction.DownRight)

	local questname = "QuestGhost"
    local quest = SV.missions.Missions[questname]
	if quest ~= nil and quest.Complete == COMMON.MISSION_COMPLETE then
	  GROUND:Unhide("NPC_Unlucky")
	end
  elseif SV.team_kidnapped.Status == 4 then
    GROUND:Unhide("NPC_Unlucky")
	
	local sightseer = CH('NPC_Sightseer')
	GROUND:TeleportTo(sightseer, 160, 392, Direction.DownRight)
  elseif SV.team_kidnapped.Status == 5 then
    -- TODO cycling
	GROUND:Unhide("NPC_Unlucky")
  end
  
  
  if SV.team_retreat.Status == 1 then
	GROUND:Unhide("Speedster_1")
	GROUND:Unhide("Speedster_2")
  elseif SV.team_retreat.Status == 2 then
    GROUND:Unhide("Speedster_2")
	
	local questname = "QuestElectric"
    local quest = SV.missions.Missions[questname]
	if quest ~= nil and quest.Complete == COMMON.MISSION_COMPLETE then
	  GROUND:Unhide("Speedster_1")
	end
  elseif SV.team_retreat.Status == 3 then
	GROUND:Unhide("Speedster_1")
	GROUND:Unhide("Speedster_2")
  elseif SV.team_retreat.Status == 4 then
    -- TODO cycling?
	GROUND:Unhide("Speedster_1")
	GROUND:Unhide("Speedster_2")
  end
  
  if SV.team_meditate.Status == 0 then
    GROUND:Unhide("NPC_Monk")
  elseif SV.team_meditate.Status == 5 then
    -- TODO cycling
  end
  
  if SV.team_solo.Status == 2 and SV.team_solo.SpokenTo == false then
    GROUND:Unhide("NPC_Solo")
  elseif SV.team_solo.Status == 6 then
    -- TODO cycling
  end
  
  if SV.Experimental and SV.team_firecracker.Status == 0 then
    GROUND:Unhide("NPC_Seer")
	GROUND:Unhide("NPC_Conjurer")
  elseif SV.team_firecracker.Status == 5 and SV.team_firecracker.Cycle == 2 then
    GROUND:Unhide("NPC_Seer")
	GROUND:Unhide("NPC_Conjurer")
	
	local seer = CH('NPC_Seer')
	local seerData = RogueEssence.Dungeon.CharData()
	seerData.BaseForm = RogueEssence.Dungeon.MonsterID("delphox", 0, "normal", Gender.Male)
	seer.Data = seerData

	local conjurer = CH('NPC_Conjurer')
	local conjurerData = RogueEssence.Dungeon.CharData()
	conjurerData.BaseForm = RogueEssence.Dungeon.MonsterID("typhlosion", 1, "normal", Gender.Male)
	conjurer.Data = conjurerData
  end
  
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


function cliff_camp.CheckMissions()
  local player = CH('PLAYER')
  
  local quest = SV.missions.Missions["EscortPet"]
  if quest ~= nil then
    if quest.Complete == COMMON.MISSION_COMPLETE then
	
      --spawn her	  
      
      GAME:FadeIn(20)
      UI:WaitShowDialogue("Escort mission state: Complete.")
      
      --she walks off to sunflora
      UI:WaitShowDialogue("The pet drops something as it runs off.")
      
      SV.magnagate.Cards = SV.magnagate.Cards + 1
	  SV.family.Pet = true
      COMMON.GiftKeyItem(player, RogueEssence.StringKey("ITEM_KEY_CARD_GRASS"):ToLocal())
	  COMMON.CompleteMission("EscortPet")
	  
    end
  end
  
  quest = SV.missions.Missions["EscortGrandma"]
  if quest ~= nil then
    if quest.Complete == COMMON.MISSION_COMPLETE then
	
      --spawn her	  
      
      GAME:FadeIn(20)
      UI:WaitShowDialogue("Escort mission state: Complete.")
      
      --she walks off to sunflora
      UI:WaitShowDialogue("The grandma drops something as she runs off.")
      
      SV.magnagate.Cards = SV.magnagate.Cards + 1
	  SV.family.Grandma = true
      COMMON.GiftKeyItem(player, RogueEssence.StringKey("ITEM_KEY_CARD_WIND"):ToLocal())
	  COMMON.CompleteMission("EscortGrandma")
	  
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
  
  local dungeon_entrances = { 'fertile_valley', 'flyaway_cliffs', 'wayward_wetlands', 'deserted_fortress', 'bravery_road', 'geode_underpass', 'the_sky' }
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
  COMMON.GroundInteract(activator, chara)
end

function cliff_camp.Teammate2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara)
end

function cliff_camp.Teammate3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara)
end


function cliff_camp.NPC_Broke_Action(chara, activator)
  
  if SV.team_hunter.Status == 1 then
  
  local questname = "QuestDark"
  local quest = SV.missions.Missions[questname]
  
  if quest == nil then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,CH('PLAYER'))
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Broke_Line_001']))
	
	COMMON.CreateMission(questname,
	{ Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_LOST_ITEM,
      DestZone = "flyaway_cliffs", DestSegment = 0, DestFloor = 6,
      FloorUnknown = false,
	  TargetItem = RogueEssence.Dungeon.InvItem("lost_item_dark"),
      ClientSpecies = RogueEssence.Dungeon.MonsterID("mightyena", 0, "normal", Gender.Male) }
	)
  else
  
	COMMON.TakeMissionItem(quest)
	
    if quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:SetSpeaker(chara)
      GROUND:CharTurnToChar(chara,CH('PLAYER'))
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Broke_Line_002']))
    else
      cliff_camp.Dark_Complete()
	end
  end
  
  elseif SV.team_hunter.Status == 2 then
    
	UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Broke_Line_004']))
  elseif SV.team_hunter.Status == 3 then
    
	--TODO: cycling
  end
  
end

function cliff_camp.Dark_Complete()
  local broke = CH('NPC_Broke')
  local player = CH('PLAYER')
  
  GROUND:CharTurnToChar(broke,player)
  
  UI:SetSpeaker(broke)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Broke_Line_003']))
  
  local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_dark_silk")
  COMMON.GiftItem(player, receive_item)
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Broke_Line_004']))
  
  COMMON.CompleteMission("QuestDark")
  
  SV.team_hunter.Status = 2
end


function cliff_camp.NPC_Catch_1_Action(chara, activator)
  DEBUG.EnableDbgCoro()
  
  cliff_camp.Catch_Action()
end

function cliff_camp.NPC_Catch_2_Action(chara, activator)
  DEBUG.EnableDbgCoro()
  
  cliff_camp.Catch_Action()
end

function cliff_camp.Catch_Action()
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local questname = "QuestNormal"
  local quest = SV.missions.Missions[questname]
  
  if quest == nil then
    cliff_camp.Catch_Trouble()
	
	COMMON.CreateMission(questname,
	{ Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_LOST_ITEM,
      DestZone = "overgrown_wilds", DestSegment = 0, DestFloor = 6,
      FloorUnknown = false,
	  TargetItem = RogueEssence.Dungeon.InvItem("lost_item_normal"),
      ClientSpecies = RogueEssence.Dungeon.MonsterID("rattata", 0, "normal", Gender.Male) }
	)
  else
  
	COMMON.TakeMissionItem(quest)
	
    if quest.Complete == COMMON.MISSION_INCOMPLETE then
      local catch1 = CH('NPC_Catch_1')
      local catch2 = CH('NPC_Catch_2')
	  UI:SetSpeaker(catch1)
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Line_005']))
	  UI:SetSpeaker(catch2)
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Line_006']))
    else
      cliff_camp.Catch_Complete()
	end
  end
end
  

function cliff_camp.Catch_Trouble()

  local catch1 = CH('NPC_Catch_1')
  local catch2 = CH('NPC_Catch_2')
  local player = CH('PLAYER')
  local itemAnim = nil
  
  GROUND:CharTurnToChar(player, catch1)
  UI:SetSpeaker(catch1)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Line_001']))
  SOUND:PlayBattleSE("DUN_Throw_Start")
  GROUND:CharSetAnim(catch1, "Rotate", false)
  GAME:WaitFrames(18)
  SOUND:PlayBattleSE("DUN_Throw_Arc")
  itemAnim = RogueEssence.Content.ItemAnim(catch1.Bounds.Center, catch2.Bounds.Center, "Stone_White", 48, 1)
  GROUND:PlayVFXAnim(itemAnim, RogueEssence.Content.DrawLayer.Normal)
  
  GROUND:CharTurnToChar(player, catch2)
  GAME:WaitFrames(RogueEssence.Content.ItemAnim.ITEM_ACTION_TIME)
	
  SOUND:PlayBattleSE("_UNK_EVT_012")
  
  itemAnim = RogueEssence.Content.ItemAnim(catch2.Bounds.Center, RogueElements.Loc(400, 524), "Stone_White", 48, 1)
  GROUND:PlayVFXAnim(itemAnim, RogueEssence.Content.DrawLayer.Normal)
  
  UI:SetSpeaker(catch2)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Line_002']))
  
  GAME:WaitFrames(30)
  
  GROUND:TeleportTo(catch1, 420, 400, Direction.Down)
  GROUND:TeleportTo(catch2, 440, 384, Direction.Down)
  
  UI:SetSpeaker(catch1)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Line_003']))
  
  UI:SetSpeaker(catch2)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Line_004']))
end



function cliff_camp.Catch_Complete()

  local catch1 = CH('NPC_Catch_1')
  local catch2 = CH('NPC_Catch_2')
  local player = CH('PLAYER')
  
  GROUND:CharTurnToChar(catch1, player)
  GROUND:CharTurnToChar(catch2, player)
  
  UI:SetSpeaker(catch1)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Done_Line_001']))
  
  UI:SetSpeaker(catch2)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Done_Line_002']))
  
  UI:SetSpeaker(catch1)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Done_Line_003']))
  
  
  local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_normal_silk")
  COMMON.GiftItem(player, receive_item)
  
  UI:SetSpeaker(catch2)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Done_Line_004']))
  
  GROUND:Hide("NPC_Catch_1")
  GROUND:Hide("NPC_Catch_2")
  
  COMMON.CompleteMission("QuestNormal")
  
  SV.team_catch.Status = 4
end


function cliff_camp.NPC_Kidnap_Action(chara, activator)
  cliff_camp.Kidnap_Sequence()
end


function cliff_camp.NPC_Unlucky_Action(chara, activator)
  local player = CH('PLAYER')
  
  if SV.team_kidnapped.Status == 2 then
    cliff_camp.Kidnap_Sequence()
  elseif SV.team_kidnapped.Status == 3 then
  
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Unlucky_Done_Line_001']))
	
    local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_ghost_silk")
    COMMON.GiftItem(player, receive_item)
  
	COMMON.CompleteMission("QuestGhost")

	SV.team_kidnapped.Status = 4
	
  elseif SV.team_kidnapped.Status == 4 then
  
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Unlucky_Done_Line_002']))
  elseif SV.team_kidnapped.Status == 5 then
  
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Unlucky_Done_Line_002']))
  end
end

function cliff_camp.Kidnap_Sequence()
  local unlucky = CH('NPC_Unlucky')
  local kidnap = CH('NPC_Kidnap')
  
  UI:SetSpeaker(unlucky)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Kidnap_Line_001']))
  
  UI:SetSpeaker(kidnap)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Kidnap_Line_002']))
  
  UI:SetSpeaker(unlucky)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Kidnap_Line_003']))
  
  UI:SetSpeaker(kidnap)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Kidnap_Line_004']))
  
  GROUND:Hide("NPC_Unlucky")
  GROUND:Hide("NPC_Kidnap")
  
  if SV.Experimental then
    SV.team_kidnapped.SpokenTo = true
  end
end



function cliff_camp.NPC_Sightseer_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  
  if SV.team_kidnapped.Status == 3 then
  
  local questname = "QuestGhost"
  local quest = SV.missions.Missions[questname]
  
  if quest == nil then

    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Sightseer_Quest_Line_001']))
	
	--TODO: later oblivion valley
	COMMON.CreateMission(questname,
	{ Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_RESCUE,
      DestZone = "secret_garden", DestSegment = 0, DestFloor = 9,
      FloorUnknown = false,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("meowth", 0, "normal", Gender.Male),
      ClientSpecies = RogueEssence.Dungeon.MonsterID("pidgeotto", 0, "normal", Gender.Male) }
	)
  elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Sightseer_Quest_Line_002']))
  else
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Sightseer_Quest_Line_003']))
  end
	
  elseif SV.team_kidnapped.Status == 4 then
  
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Sightseer_Quest_Line_003']))
  else

  UI:SetSpeaker(chara)
  local player = CH('PLAYER')
  GROUND:CharTurnToChar(chara, player)
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Sightseer_Line_001']))
  
  end
  
end



function cliff_camp.Speedster_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  if SV.team_retreat.Status == 1 then

  local player = CH('PLAYER')
  GROUND:CharTurnToChar(chara,player)
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Doduo_Line_001']))
  SV.team_retreat.SpokenTo = true
  
  elseif SV.team_retreat.Status == 2 then
    cliff_camp.Electric_Complete()
  elseif SV.team_retreat.Status == 3 then
    UI:SetSpeaker(chara)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Doduo_Line_002']))
  else
	--TODO: cycling
    UI:SetSpeaker(chara)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Doduo_Line_002']))
  end
  
end
  
function cliff_camp.Speedster_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  
  if SV.team_retreat.Status == 1 then

  
  GROUND:CharTurnToChar(chara,player)
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Pachirisu_Line_001']))
  SV.team_retreat.SpokenTo = true
  
  elseif SV.team_retreat.Status == 2 then
    --give mission
	
  local questname = "QuestElectric"
  local quest = SV.missions.Missions[questname]
	
  
  if quest == nil then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Pachirisu_Help_Line_001']))
	
	--TODO: later deserted fortress
	COMMON.CreateMission(questname,
	{ Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_RESCUE,
      DestZone = "trickster_woods", DestSegment = 0, DestFloor = 6,
      FloorUnknown = false,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("doduo", 0, "normal", Gender.Male),
      ClientSpecies = RogueEssence.Dungeon.MonsterID("pachirisu", 0, "normal", Gender.Male) }
	)
  elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,player)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Pachirisu_Help_Line_002']))
  else
    cliff_camp.Electric_Complete()
  end
	
  elseif SV.team_retreat.Status == 3 then
    UI:SetSpeaker(chara)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Pachirisu_Line_002']))
  else
	--TODO: cycling
    UI:SetSpeaker(chara)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Pachirisu_Line_002']))
  
  end

end


function cliff_camp.Electric_Complete()
  local speed1 = CH('Speedster_1')
  local speed2 = CH('Speedster_2')
  local player = CH('PLAYER')
  
  GROUND:CharTurnToChar(speed1,player)
  GROUND:CharTurnToChar(speed2,player)
  
  UI:SetSpeaker(speed2)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Pachirisu_Done_Line_001']))
  
  local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_electric_silk")
  COMMON.GiftItem(player, receive_item)
  
  COMMON.CompleteMission("QuestElectric")
  
  SV.team_retreat.Status = 3
end

function cliff_camp.NPC_Solo_Action(chara, activator)
  
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Solo_Line_001']))
  
  GROUND:Hide("NPC_Solo")
  
  SV.team_solo.SpokenTo = true
  
end


function cliff_camp.NPC_Undergrowth_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  
  if not SV.family.Father and SV.family.FatherActiveDays >= 3 then
    cliff_camp.NPC_Undergrowth_Concern()
  elseif not SV.family.Pet and SV.family.PetActiveDays >= 3 and SV.family.Sister and SV.family.Mother and SV.family.Father and SV.family.Brother then
    cliff_camp.NPC_Undergrowth_Concern()
  else
  
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
end
  
function cliff_camp.NPC_Undergrowth_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  if not SV.family.Father and SV.family.FatherActiveDays >= 3 then
    cliff_camp.NPC_Undergrowth_Concern()
  elseif not SV.family.Pet and SV.family.PetActiveDays >= 3 and SV.family.Sister and SV.family.Mother and SV.family.Father and SV.family.Brother then
    cliff_camp.NPC_Undergrowth_Concern()
  else
  
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shroomish_Line_001']))
  
  local partner = CH('NPC_Undergrowth_1')
  UI:SetSpeaker(partner)
  UI:SetSpeakerEmotion("Pain")
  GROUND:CharSetEmote(partner, "sweating", 1)
  SOUND:PlayBattleSE("EVT_Emote_Sweating")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Bellsprout_Line_003']))
  
  end
end


function cliff_camp.NPC_Undergrowth_Concern()
  local undergrowth1 = CH('NPC_Undergrowth_1')
  local undergrowth2 = CH('NPC_Undergrowth_2')
  
  if not SV.family.Father and SV.family.FatherActiveDays >= 3 then
    
	UI:SetSpeaker(undergrowth1)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Hint_Father_Line_001']))
	
	UI:SetSpeaker(undergrowth2)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Hint_Father_Line_002']))
	
  elseif not SV.family.Pet and SV.family.PetActiveDays >= 3 and SV.family.Sister and SV.family.Mother and SV.family.Father and SV.family.Brother then
  
	UI:SetSpeaker(undergrowth1)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Hint_Pet_Line_001']))
	
	UI:SetSpeaker(undergrowth2)
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Hint_Pet_Line_002']))
	
  end
  
end
  
function cliff_camp.Rival_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_1_Line_001']))
  
  SV.team_rivals.SpokenTo = true
end
  
function cliff_camp.Rival_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Rival_2_Line_001']))
  
  SV.team_rivals.SpokenTo = true
end
  
function cliff_camp.NPC_Monk_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:SetSpeaker(chara)
  local player = CH('PLAYER')
  GROUND:CharTurnToChar(chara, player)
  
  if not SV.team_meditate.SpokenTo then
  
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
  
  SV.team_meditate.SpokenTo = true
  
  end
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Monk_Line_002']))
  GROUND:EntTurn(chara, Direction.Up)
end



function cliff_camp.NPC_Seer_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GROUND:CharTurnToChar(chara,CH('PLAYER'))--make the chara turn to the player
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  
  if SV.team_firecracker.Status ~= 5 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seer_Line_001']))
	SV.team_firecracker.SpokenTo = true
  else
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seer_Line_002']))
  end
end

function cliff_camp.NPC_Conjurer_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GROUND:CharTurnToChar(chara,CH('PLAYER'))--make the chara turn to the player
  UI:SetSpeaker(chara)--set the dialogue box's speaker to the character
  
  if SV.team_firecracker.Status ~= 5 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Conjurer_Line_001']))
	SV.team_firecracker.SpokenTo = true
  else
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Conjurer_Line_002']))
  end
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
	  COMMON.CreateMission(questname,
	{ Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_OUTLAW,
      DestZone = "faded_trail", DestSegment = 0, DestFloor = 5, FloorUnknown = true,
      ClientSpecies = chara.CurrentForm,
      TargetSpecies = RogueEssence.Dungeon.MonsterID("murkrow", 0, "normal", Gender.Male) }
	  )
	elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_004']))
	else
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_005']))
	  --give reward
      local receive_item = RogueEssence.Dungeon.InvItem("food_apple_huge")
      COMMON.GiftItem(player, receive_item)
	  --complete mission and move to done
	  COMMON.CompleteMission(questname)
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


function cliff_camp.FatherReminderActive()
  if SV.family.Father == false and SV.family.FatherActiveDays > 2 then
    return true
  end
  return false
end


function cliff_camp.GrandmaReminderActive()
  if SV.family.Grandma == false and SV.family.GrandmaActiveDays > 2 then
    return true
  end
  return false
end

function cliff_camp.PetReminderActive()
  if SV.family.Pet == false and SV.family.PetActiveDays > 2 then
    return true
  end
  return false
end

return cliff_camp