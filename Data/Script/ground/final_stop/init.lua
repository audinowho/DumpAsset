require 'common'

local final_stop = {}
local MapStrings = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function final_stop.Init(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_final_stop")
  MapStrings = COMMON.AutoLoadLocalizedStrings()
  COMMON.RespawnAllies()
  
  GROUND:AddMapStatus("snow")
end

function final_stop.Enter(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine

  SV.checkpoint = 
  {
    Zone    = 'guildmaster_island', Segment  = -1,
    Map  = 7, Entry  = 1
  }
  
  --when arriving the first time, play this cutscene
  if not SV.final_stop.ExpositionComplete then
    final_stop.SetupNpcs()
    final_stop.BeginExposition()
    SV.final_stop.ExpositionComplete = true
  elseif SV.guildmaster_summit.BossPhase == 2 then
    final_stop.SetupNpcs()
    final_stop.Summit_Fail()
	SV.guildmaster_summit.BossPhase = 1
  else
    final_stop.SetupNpcs()
    GAME:FadeIn(20)
  end
end

function final_stop.Update(map, time)
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------
function final_stop.SetupNpcs()
  GROUND:Unhide("Rival_Late")
  
  if SV.supply_corps.Status < 16 then
    --pass
  elseif SV.supply_corps.Status <= 16 then
    GROUND:Unhide("NPC_Carry")
    GROUND:Unhide("NPC_Deliver")
	
	--also add storehouse once he's saved
    local questname = "OutlawMountain2"
    local quest = SV.missions.Missions[questname]
    if quest ~= nil and quest.Complete == COMMON.MISSION_COMPLETE then
	  GROUND:Unhide("NPC_Storehouse")
	end
  elseif SV.supply_corps.Status <= 19 then
    GROUND:Unhide("NPC_Storehouse")
    GROUND:Unhide("NPC_Carry")
    GROUND:Unhide("NPC_Deliver")
  elseif SV.supply_corps.Status >= 20 then
    --cycle appearances
	if SV.supply_corps.ManagerCycle == 0 or SV.supply_corps.ManagerCycle == 6 then
	
	else
	  if SV.supply_corps.CarryCycle == 5 then
	    GROUND:Unhide("NPC_Carry")
	  end
	  if SV.supply_corps.DeliverCycle == 5 then
	    GROUND:Unhide("NPC_Deliver")
	  end
	  if SV.supply_corps.ManagerCycle == 5 then
	    GROUND:Unhide("NPC_Storehouse")
	  end
	end
  end
end


function final_stop.Summit_Fail()
  --everyone is dead
  UI:ResetSpeaker()
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Summit_Fail_Line_001']))
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Summit_Fail_Line_002']))
  
  GAME:FadeIn(20)
  --get back up
end


function final_stop.BeginExposition()
  
  UI:WaitShowTitle(GAME:GetCurrentGround().Name:ToLocal(), 20);
  GAME:WaitFrames(30);
  UI:WaitHideTitle(20);
  GAME:FadeIn(20)
  
  GAME:UnlockDungeon('champions_road')
end

--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------

function final_stop.NPC_Storehouse_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  
  if SV.supply_corps.Status <= 16 then
    local questname = "OutlawMountain2"
    local quest = SV.missions.Missions[questname]
    if quest ~= nil and quest.Complete == COMMON.MISSION_COMPLETE then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_001']))
      --give reward
      local receive_item = RogueEssence.Dungeon.InvItem("tm_focus_blast")
      COMMON.GiftItem(player, receive_item)
      --complete mission and move to done
      quest.Complete = COMMON.MISSION_ARCHIVED
      SV.missions.FinishedMissions[questname] = quest
      SV.missions.Missions[questname] = nil
      SV.supply_corps.Status = 17
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_002']))
    end
  elseif SV.supply_corps.Status == 17 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_003']))
  elseif SV.supply_corps.Status == 18 then
    local unlock = _DATA.Save:GetDungeonUnlock("treacherous_mountain") -- make this the dungeon unlock state
    if unlock == RogueEssence.Data.GameProgress.UnlockState.None then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_004']))
      COMMON.UnlockWithFanfare("treacherous_mountain", false)
    elseif unlock == RogueEssence.Data.GameProgress.UnlockState.Discovered then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_005']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_006']))
      --increase rank for bag space
      _DATA.Save.ActiveTeam:SetRank("silver")
      SOUND:PlayFanfare("Fanfare/RankUp")
      UI:ResetSpeaker(false)
      UI:SetCenter(true)
	  local rank = _DATA:GetRank(_DATA.Save.ActiveTeam.Rank)
      UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("DLG_BAG_SIZE"):ToLocal(), rank.BagSize))
      UI:SetSpeaker(chara)
      UI:SetCenter(false)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_007']))
      SV.supply_corps.Status = 19
    end
  elseif SV.supply_corps.Status == 19 then
    if not SV.guildmaster_summit.GameComplete then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_008']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_009']))
    end
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_Route']))
  end
end


function final_stop.NPC_Carry_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  
  if SV.supply_corps.Status <= 16 then
    local questname = "OutlawMountain2"
    local quest = SV.missions.Missions[questname]
    if quest == nil then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_001']))
      --add the quest
      SV.missions.Missions[questname] = { Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_OUTLAW_DISGUISE,
        DestZone = "snowbound_path", DestSegment = 0, DestFloor = 12,
        FloorUnknown = true,
        ClientSpecies = chara.CurrentForm,
        TargetSpecies = RogueEssence.Dungeon.MonsterID("zoroark", 1, "normal", Gender.Male),
        DisguiseSpecies = RogueEssence.Dungeon.MonsterID("swalot", 0, "normal", Gender.Male), DisguiseTalk = "DisguiseTalk", DisguiseHit = "DisguiseHit" }
    elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_002']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_003']))
    end
  elseif SV.supply_corps.Status == 17 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_004']))
  elseif SV.supply_corps.Status == 18 then
    local unlock = _DATA.Save:GetDungeonUnlock("treacherous_mountain") -- make this the dungeon unlock state
    if unlock == RogueEssence.Data.GameProgress.UnlockState.None then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_005']))
    elseif unlock == RogueEssence.Data.GameProgress.UnlockState.Discovered then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_006']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_007']))
    end
  elseif SV.supply_corps.Status == 19 then
    if not SV.guildmaster_summit.GameComplete then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_008']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_009']))
    end
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Carry_Line_Route']))
  end
end


function final_stop.NPC_Deliver_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  
  if SV.supply_corps.Status <= 16 then
    local questname = "OutlawMountain2"
    local quest = SV.missions.Missions[questname]
    if quest == nil then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_001']))
    elseif quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_002']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_003']))
    end
  elseif SV.supply_corps.Status == 17 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_004']))
  elseif SV.supply_corps.Status == 18 then
    local unlock = _DATA.Save:GetDungeonUnlock("treacherous_mountain") -- make this the dungeon unlock state
    if unlock == RogueEssence.Data.GameProgress.UnlockState.None then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_005']))
    elseif unlock == RogueEssence.Data.GameProgress.UnlockState.Discovered then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_006']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_007']))
    end
  elseif SV.supply_corps.Status == 19 then
    if not SV.guildmaster_summit.GameComplete then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_008']))
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_009']))
    end
  elseif SV.supply_corps.Status == 20 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Deliver_Line_Route']))
  end
end

function final_stop.North_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local dungeon_entrances = { 'champions_road', 'barren_tundra', 'cave_of_solace', 'labyrinth_of_the_lost' }
  local ground_entrances = {{Flag=SV.guildmaster_summit.GameComplete,Zone='guildmaster_island',ID=8,Entry=0}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end

function final_stop.South_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local dungeon_entrances = { }
  local ground_entrances = {{Flag=true,Zone='guildmaster_island',ID=1,Entry=3},
  {Flag=SV.forest_camp.ExpositionComplete,Zone='guildmaster_island',ID=3,Entry=2},
  {Flag=SV.cliff_camp.ExpositionComplete,Zone='guildmaster_island',ID=4,Entry=2},
  {Flag=SV.canyon_camp.ExpositionComplete,Zone='guildmaster_island',ID=5,Entry=2},
  {Flag=SV.rest_stop.ExpositionComplete,Zone='guildmaster_island',ID=6,Entry=2}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end


function final_stop.Assembly_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  COMMON.ShowTeamAssemblyMenu(obj, COMMON.RespawnAllies)
end

function final_stop.Storage_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON:ShowTeamStorageMenu()
end



function final_stop.Teammate1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

function final_stop.Teammate2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

function final_stop.Teammate3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

return final_stop