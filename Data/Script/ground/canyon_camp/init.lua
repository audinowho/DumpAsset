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
  local tutor_species = "missingno"
  if SV.General.Starter.Species == "bulbasaur" then
    tutor_species = "meganium"
  elseif SV.General.Starter.Species == "charmander" then
    tutor_species = "typhlosion"
  elseif SV.General.Starter.Species == "squirtle" then
    tutor_species = "feraligatr"
  elseif SV.General.Starter.Species == "pikachu" then
    tutor_species = "raichu"
  end
  charData.BaseForm = RogueEssence.Dungeon.MonsterID(tutor_species, 0, "normal", Gender.Female)
  tutor.Data = charData
end

function canyon_camp.Enter(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine

  SV.checkpoint = 
  {
    Zone    = 'guildmaster_island', Segment  = -1,
    Map  = 5, Entry  = 1
  }
  
  --when arriving the first time, play this cutscene
  if not SV.canyon_camp.ExpositionComplete then
    canyon_camp.SetupNpcs()
    canyon_camp.BeginExposition()
    SV.canyon_camp.ExpositionComplete = true
  elseif SV.rest_stop.BossPhase == 2 then
    canyon_camp.SetupNpcs()
    canyon_camp.Steelix_Fail()
	SV.rest_stop.BossPhase = 1
  else
    canyon_camp.SetupNpcs()
    GAME:FadeIn(20)
  end
end

function canyon_camp.Update(map, time)
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------
function canyon_camp.SetupNpcs()
  GROUND:Unhide("NPC_Seeker")
  GROUND:Unhide("NPC_Hidden")
  GROUND:Unhide("NPC_Dragon_1")
  GROUND:Unhide("NPC_Dragon_2")
  GROUND:Unhide("NPC_Dragon_3")
  GROUND:Unhide("NPC_Strategy")
  GROUND:Unhide("NPC_Wall")
  GROUND:Unhide("NPC_8")
  GROUND:Unhide("NPC_Argue_1")
  GROUND:Unhide("NPC_Argue_2")
  
  if SV.supply_corps.Status < 4 then
    --pass
  elseif SV.supply_corps.Status <= 5 then
    GROUND:Unhide("NPC_Storehouse")
    GROUND:Unhide("NPC_Deliver")
  elseif SV.supply_corps.Status <= 9 then
    GROUND:Unhide("NPC_Storehouse")
    GROUND:Unhide("NPC_Carry")
    GROUND:Unhide("NPC_Deliver")
  elseif SV.supply_corps.Status >= 18 then
    --cycle appearances
  end
end

function canyon_camp.BeginExposition()

  UI:WaitShowTitle(GAME:GetCurrentGround().Name:ToLocal(), 20);
  GAME:WaitFrames(30);
  UI:WaitHideTitle(20);
  GAME:FadeIn(20)
  
  GAME:UnlockDungeon('copper_quarry')
  GAME:UnlockDungeon('forsaken_desert')
  GAME:UnlockDungeon('sleeping_caldera')
end

--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------
function canyon_camp.East_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local dungeon_entrances = { 'copper_quarry', 'forsaken_desert', 'relic_tower', 'sleeping_caldera', 'royal_halls', 'starfall_heights', 'wisdom_road', 'sacred_tower'}
  local ground_entrances = {{Flag=SV.rest_stop.ExpositionComplete,Zone='guildmaster_island',ID=6,Entry=0},
  {Flag=SV.final_stop.ExpositionComplete,Zone='guildmaster_island',ID=7,Entry=0},
  {Flag=SV.guildmaster_summit.GameComplete,Zone='guildmaster_island',ID=8,Entry=0}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end

function canyon_camp.West_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local dungeon_entrances = { }
  local ground_entrances = {{Flag=true,Zone='guildmaster_island',ID=1,Entry=3},
  {Flag=SV.forest_camp.ExpositionComplete,Zone='guildmaster_island',ID=3,Entry=2},
  {Flag=SV.cliff_camp.ExpositionComplete,Zone='guildmaster_island',ID=4,Entry=2}}
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
    if player.CurrentForm.Skin == "normal" then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shiny_Line_001']))
    else
      SOUND:PlayBattleSE("EVT_Emote_Exclaim_2")
      GROUND:CharSetEmote(chara, "exclaim", 1)
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
  if SV.General.Starter.Species == "bulbasaur" then
    tutor_skill = "grass_pledge"
  elseif SV.General.Starter.Species == "charmander" then
    tutor_skill = "fire_pledge"
  elseif SV.General.Starter.Species == "squirtle" then
    tutor_skill = "water_pledge"
  elseif SV.General.Starter.Species == "pikachu" then
    tutor_skill = "volt_tackle"
  end
  
  
  --after teaching, unlock the tutor back at the hub for ALL moves
  
end
  
function canyon_camp.NPC_Argue_1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
end
  
function canyon_camp.NPC_Argue_2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
end
  
function canyon_camp.NPC_Seeker_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seeker_Line_001']))
  SOUND:PlayBattleSE("EVT_Emote_Exclaim_2")
  GROUND:CharSetEmote(chara, "exclaim", 1)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  GAME:WaitFrames(30)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seeker_Line_002']))
  GROUND:CharSetEmote(chara, "glowing", 4)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Seeker_Line_003']))
end
  
function canyon_camp.NPC_Hidden_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  
  local dungeon_id = 'secret_garden'
  if not GAME:DungeonUnlocked(dungeon_id) then
    UI:SetSpeaker(chara)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Hidden_Line_001']))
    GAME:FadeOut(false, 20)
    GAME:WaitFrames(30)
    COMMON.UnlockWithFanfare(dungeon_id, false)
    GAME:WaitFrames(30)
    GAME:FadeIn(20)
  end
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Hidden_Line_002']))
  UI:SetSpeakerEmotion("Pain")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Hidden_Line_003']))
end
  
function canyon_camp.NPC_Shortcut_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shortcut_Line_001']))
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shortcut_Line_002']))
end
  
function canyon_camp.NPC_Wall_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Wall_Line_001']))
end
  
function canyon_camp.NPC_Strategy_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Strategy_Line_001']))
end

function canyon_camp.NPC_Fairy(chara, activator)
  
  UI:SetSpeaker(chara)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Fairy_Line_001']))
end


function canyon_camp.NPC_Storehouse_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
	
  if SV.supply_corps.Status <= 4 then
    UI:WaitShowDialogue("I went ahead and set up tent here! I'm waiting for my subordinates to make another trip!")
	SV.supply_corps.Status = 5
  elseif SV.supply_corps.Status == 6 then
    local questname = "OutlawForest2"
    local quest = SV.missions.Missions[questname]
    if quest == nil then
      UI:WaitShowDialogue("Carry NPC had his package stolen! Please Help!")
	  --add the quest
	  SV.missions.Missions[questname] = { Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_OUTLAW_HOUSE, DestZone = "flyaway_cliffs", DestSegment = 0, DestFloor = 6, TargetSpecies = "decidueye" }
	elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue("Carry NPC had his package stolen! (You already have the quest)")
	else
	  UI:WaitShowDialogue("Thanks for getting back the supplies!  Have a reward!")
	  --give reward
      local receive_item = RogueEssence.Dungeon.InvItem("food_banana_big")
      COMMON.GiftItem(player, receive_item)
	  --complete mission and move to done
	  quest.Complete = COMMON.MISSION_ARCHIVED
	  SV.missions.FinishedMissions[questname] = quest
	  SV.missions.Missions[questname] = nil
	  SV.supply_corps.Status = 7
	  UI:WaitShowDialogue("We've got to do something about these thieves.")
	end
  elseif SV.supply_corps.Status == 7 then
	UI:WaitShowDialogue("We've got to do something about these thieves.")
  elseif SV.supply_corps.Status == 8 then
    local unlock = _DATA.Save:GetDungeonUnlock("ambush_forest") -- make this the dungeon unlock state
	if unlock == RogueEssence.Data.GameProgress.UnlockState.None then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_001']))
      COMMON.UnlockWithFanfare("ambush_forest", false)
	elseif unlock == RogueEssence.Data.GameProgress.UnlockState.Discovered then
	  UI:WaitShowDialogue("Please help us take down this criminal!")
	else
	  UI:WaitShowDialogue("Thanks for bringing down the criminal!  We reward you with a storage bag!")
	  --increase rank for bag space
	  _DATA.Save.ActiveTeam:SetRank("bronze")
	  SOUND:PlayFanfare("Fanfare/RankUp")
	  UI:ResetSpeaker(false)
      UI:SetCenter(true)
      UI:WaitShowDialogue(STRINGS:Format("You can now carry {0} items in your Treasure Bag!", 32))
	  UI:SetSpeaker(chara)
	  UI:SetCenter(false)
	  UI:WaitShowDialogue("We use this bag for our runs!")
	  SV.supply_corps.Status = 9
	end
  elseif SV.supply_corps.Status == 9 then
    UI:WaitShowDialogue("Thanks for bringing honchkrow down.")
  end
end


function canyon_camp.Steelix_Fail()
  --everyone is dead
  GAME:FadeIn(20)
  --get back up
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