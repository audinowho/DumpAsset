require 'common'

local base_camp = {}
local MapStrings = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function base_camp.Init(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_base_camp")
  MapStrings = COMMON.AutoLoadLocalizedStrings()
  
  COMMON.RespawnAllies()
end

function base_camp.Enter(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  SV.checkpoint = 
  {
    Zone    = 'guildmaster_island', Segment  = -1,
    Map  = 1, Entry  = 0
  }
  
  if SV.base_camp.CenterStatueDate and SV.base_camp.CenterStatueDate ~= "" then
    GROUND:Unhide("Statue_Center")
  end
  if SV.base_camp.LeftStatueDate and SV.base_camp.LeftStatueDate ~= "" then
    GROUND:Unhide("Statue_Left")
  end
  if SV.base_camp.RightStatueDate and SV.base_camp.RightStatueDate ~= "" then
    GROUND:Unhide("Statue_Right")
  end
  
  if not SV.base_camp.FerryUnlocked then
    GROUND:Hide("Lapras")
    GROUND:Hide("Ferry")
  end
  
  if not SV.base_camp.IntroComplete then
    base_camp.PrepareFirstTimeVisit()
	GAME:FadeIn(20)
  elseif SV.guildmaster_trail.FloorsCleared >= 30 and SV.guildmaster_trail.Rewarded == false then
    base_camp.RewardDialogue()
	SV.guildmaster_trail.Rewarded = true
    SV.base_camp.ExpositionComplete = true
  elseif not SV.base_camp.ExpositionComplete then	
    base_camp.SetupNpcs()
    base_camp.BeginExposition()
    SV.base_camp.ExpositionComplete = true
  else
    base_camp.SetupNpcs()
    GAME:FadeIn(20)
  end
  
  SV.base_camp.IntroComplete = true
  
end

--------------------------------------------------
-- Map Setup Functions
--------------------------------------------------
function base_camp.PrepareFirstTimeVisit()
  --Hide assembly and storage
  GROUND:Hide("Assembly")
  GROUND:Hide("Storage")
  GROUND:Hide("North_Exit")
  GROUND:Hide("Noctowl")
  GROUND:Hide("NPC_Entrance")
  GROUND:Hide("NPC_Range")
  GROUND:Hide("NPC_Coast")
  GROUND:Unhide("East_LogPile")
  GROUND:Unhide("West_LogPile")
  GROUND:Unhide("First_North_Exit")
  GAME:UnlockDungeon('guildmaster_trail')
  
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------
function base_camp.SetupNpcs()
  GROUND:Unhide("NPC_Coast")
  GROUND:Unhide("NPC_Range")
  GROUND:Unhide("NPC_Entrance")
  
  if SV.guildmaster_summit.GameComplete then
    local noctowl = CH('Noctowl')
    GROUND:TeleportTo(noctowl, 80, 288, Direction.Right)
  end
end

function base_camp.BeginExposition()  

  local noctowl = CH('Noctowl')
  local player = CH('PLAYER')
  
	-- move founder to team if not in party
	-- get party
	local party_table = GAME:GetPlayerPartyTable()
	-- check for presence
	local in_party = false
	for ii = 1, #party_table, 1 do
	  local ent = party_table[ii]
	  if ent.IsFounder then
	    in_party = true
		break
	  end
	end
	
	-- if no, search assembly and then add to party
	if not in_party then
	  local assemblyCount = GAME:GetPlayerAssemblyCount()
  
      for i = assemblyCount,1,-1 do
        p = GAME:GetPlayerAssemblyMember(i-1)
		if p.IsFounder then
		  GAME:RemovePlayerAssembly(i-1)
		  GAME:AddPlayerTeam(p)
		end
      end
	end
	
	-- move everyone else into assembly
	local partyCount = GAME:GetPlayerPartyCount()
    for i = partyCount,1,-1 do
      p = GAME:GetPlayerPartyMember(i-1)
	  if not p.IsFounder then
		GAME:RemovePlayerTeam(i-1)
		GAME:AddPlayerAssembly(p)
	  end
    end
	
	-- make leader
	GAME:SetTeamLeaderIndex(0)
	-- update team
    COMMON.RespawnAllies()
	
	
    GAME:CutsceneMode(true)
    UI:SetSpeaker(STRINGS:Format("\\uE040"), true, "", -1, "", RogueEssence.Data.Gender.Unknown)
	
    local zone = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get('guildmaster_trail')
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_001'], zone:GetColoredName()))
    --move the noctowl to a new position
    GROUND:TeleportTo(noctowl, 244, 286, Direction.Up)
    GAME:FadeIn(20)


  UI:SetSpeaker(noctowl)
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_002']))
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_003']))
  
  GROUND:CharSetEmote(player, "shock", 1)
  SOUND:PlayBattleSE("EVT_Emote_Shock_Bad")
  GAME:WaitFrames(60)
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_004']))
    
  local ch = false
  local name = ""
  while not ch do
    name = ""
	while name == "" do
      UI:NameMenu(STRINGS:FormatKey("INPUT_TEAM_TITLE"), "")
      UI:WaitForChoice()
      name = UI:ChoiceResult()
	end
    --UI:WaitShowDialogue("I see... {0}? [Exactly.] [Actually, it's...]")
    

    UI:ChoiceMenuYesNo(STRINGS:Format(MapStrings['Expo_Cutscene_Line_005'], name), true)
    UI:WaitForChoice()
    ch = UI:ChoiceResult()
  end
  
  GAME:SetTeamName(name)
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_006']))
  
  local zone = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get('guildmaster_trail')
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_007'], zone:GetColoredName()))
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_008']))
  
  GROUND:EntTurn(player, Direction.DownRight)
  GROUND:MoveInDirection(noctowl, Direction.UpRight, 17, false, 2)
  
  GROUND:EntTurn(player, Direction.Right)
  GROUND:EntTurn(noctowl, Direction.Left)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_009']))
  
  GROUND:EntTurn(player, Direction.UpRight)
  GROUND:MoveInDirection(noctowl, Direction.UpLeft, 17, false, 2)
  
  GROUND:EntTurn(player, Direction.Up)
  GROUND:EntTurn(noctowl, Direction.Down)
  
  zone = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get('tropical_path')
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_010'], zone:GetColoredName()))
  
  --UI:WaitShowDialogue("It amazes me that the likes of you still come to this island.")
  --UI:WaitShowDialogue("I had believed the rush to explore this island died down years ago.")
  
  --?
  GROUND:EntTurn(player, Direction.UpLeft)
  GROUND:MoveInDirection(noctowl, Direction.DownLeft, 17, false, 2)
  
  GROUND:EntTurn(player, Direction.Left)
  GROUND:EntTurn(noctowl, Direction.Right)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_011']))
  
  
  GROUND:MoveInDirection(noctowl, Direction.Left, 101, false, 2)
  GROUND:EntTurn(noctowl, Direction.Right)
  
  
  UI:ResetSpeaker()
  
  --walk to block off the main entrance
  
  --speak, and then unlock the new dungeon
  GAME:UnlockDungeon('tropical_path')
  GAME:CutsceneMode(false)
  
end


function base_camp.RewardDialogue()
  
  GAME:CutsceneMode(true)
  local player = CH('PLAYER')
  local noctowl = CH('Noctowl')
    
  GROUND:TeleportTo(noctowl, 244, 286, Direction.Up)
	
  GAME:FadeIn(20)
	
  UI:SetSpeaker(noctowl)
  
  UI:WaitShowDialogue("Your badge... that insignia!")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Noctowl_Reward_Line_001']))
  --UI:WaitShowDialogue("Where did you come from...?")
  --UI:WaitShowDialogue("Could it be...?")
  
  --UI:WaitShowDialogue("When the guildmasters first put up the challenge, I was there.")
  --UI:WaitShowDialogue("I witnessed them set off for the summit, never to return.")
  --UI:WaitShowDialogue("Countless others followed, but never succeeded.")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Noctowl_Reward_Line_002']))
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Noctowl_Reward_Line_003']))
  
  local receive_item = RogueEssence.Dungeon.InvItem("apricorn_perfect")
  COMMON.GiftItem(player, receive_item)
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Noctowl_Reward_Line_004']))
  
  GROUND:MoveToPosition(noctowl, 82, 286, false, 2)
  
  GROUND:MoveToPosition(noctowl, 80, 288, false, 2)
  
  GROUND:CharAnimateTurnTo(noctowl, Direction.Right, 4)
  
  GAME:UnlockDungeon('tropical_path')
  
  
  GAME:CutsceneMode(false)
  
end

--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------

function base_camp.North_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local dungeon_entrances = { 'tropical_path', 'faultline_ridge', 'tiny_tunnel', 'guildmaster_trail' }
  local ground_entrances = {{Flag=SV.forest_camp.ExpositionComplete,Zone='guildmaster_island',ID=3,Entry=0},
  {Flag=SV.cliff_camp.ExpositionComplete,Zone='guildmaster_island',ID=4,Entry=0},
  {Flag=SV.canyon_camp.ExpositionComplete,Zone='guildmaster_island',ID=5,Entry=0},
  {Flag=SV.rest_stop.ExpositionComplete,Zone='guildmaster_island',ID=6,Entry=0},
  {Flag=SV.final_stop.ExpositionComplete,Zone='guildmaster_island',ID=7,Entry=0},
  {Flag=SV.guildmaster_summit.GameComplete,Zone='guildmaster_island',ID=8,Entry=0}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end

function base_camp.First_North_Exit_Touch(obj, activator)  
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:ResetSpeaker(false)
  SOUND:PlaySE("Menu/Skip")
  local zone = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get('guildmaster_trail')
  UI:ChoiceMenuYesNo(STRINGS:FormatKey("DLG_ASK_ENTER_DUNGEON", zone:GetColoredName()), false)
  UI:WaitForChoice()
  ch = UI:ChoiceResult()
  if ch then
    _DATA:PreLoadZone('guildmaster_trail')
	SOUND:PlayBGM("", true)
    GAME:FadeOut(false, 20)
    GAME:EnterDungeon('guildmaster_trail', 0, 0, 0, RogueEssence.Data.GameProgress.DungeonStakes.Risk, true, true)
  end
end

function base_camp.West_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GAME:FadeOut(false, 20)
  GAME:EnterGroundMap("guild_path", "entrance_east")
end

function base_camp.East_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GAME:FadeOut(false, 20)
  GAME:EnterGroundMap("base_camp_2", "entrance_west", true)
end

function base_camp.Ferry_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local ferry = CH('Lapras')
  UI:SetSpeaker(ferry)
  if not SV.base_camp.FerryIntroduced then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Ferry_Line_001']))
	SV.base_camp.FerryIntroduced = true
  end
  local dungeon_entrances = { 'lava_floe_island', 'castaway_cave', 'eon_island', 'lost_seas', 'inscribed_cave', 'prism_isles' }
  local ground_entrances = {}
  base_camp.ShowFerryMenu(dungeon_entrances,ground_entrances)
end

function base_camp.ShowFerryMenu(dungeon_entrances, ground_entrances)
  
  --check for unlock of dungeons
  local open_dests = {}
  for ii = 1,#dungeon_entrances,1 do
    if GAME:DungeonUnlocked(dungeon_entrances[ii]) then
	local zone_summary = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(dungeon_entrances[ii])
	  if zone_summary.Released then
	    local zone_name = ""
	    if _DATA.Save:GetDungeonUnlock(dungeon_entrances[ii]) == RogueEssence.Data.GameProgress.UnlockState.Completed then
		  zone_name = zone_summary:GetColoredName()
		else
		  zone_name = "[color=#00FFFF]"..zone_summary.Name:ToLocal().."[color]"
		end
        table.insert(open_dests, { Name=zone_name, Dest=RogueEssence.Dungeon.ZoneLoc(dungeon_entrances[ii], 0, 0, 0) })
	  end
	end
  end
  
  --check for unlock of grounds
  for ii = 1,#ground_entrances,1 do
    if ground_entrances[ii].Flag then
	  local ground_id = ground_entrances[ii].Zone
	  local zone = _DATA:GetZone(ground_id)
	  local ground = _DATA:GetGround(zone.GroundMaps[ground_entrances[ii].ID])
	  local ground_name = ground:GetColoredName()
      table.insert(open_dests, { Name=ground_name, Dest=RogueEssence.Dungeon.ZoneLoc(ground_id, -1, ground_entrances[ii].ID, ground_entrances[ii].Entry) })
	end
  end
  
  local dest = RogueEssence.Dungeon.ZoneLoc.Invalid
  
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Ferry_Line_002']))
    UI:DestinationMenu(open_dests)
	UI:WaitForChoice()
	dest = UI:ChoiceResult()
  
  if dest:IsValid() then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Ferry_Line_003']))
    SOUND:PlayBGM("", true)
    GAME:FadeOut(false, 20)
	if dest.StructID.Segment > -1 then
	  GAME:EnterDungeon(dest.ID, dest.StructID.Segment, dest.StructID.ID, dest.EntryPoint, RogueEssence.Data.GameProgress.DungeonStakes.Risk, true, false)
	else
	  GAME:EnterZone(dest.ID, dest.StructID.Segment, dest.StructID.ID, dest.EntryPoint)
	end
  end
end

base_camp.sign_count = 0
function base_camp.Sign_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  UI:SetAutoFinish(true)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Sign_Action_Text']))
  UI:SetAutoFinish(false)
  
  base_camp.sign_count = base_camp.sign_count + 1
  if base_camp.sign_count > 5 and SV.Experimental == nil then
    UI:ChoiceMenuYesNo("UNLOCK THE HALF FINISHED STORY? NO GOING BACK.", true)
    UI:WaitForChoice()
    ch = UI:ChoiceResult()
	if ch then
	  SV.Experimental = true
	  UI:WaitShowDialogue("UNLOCKED")
	end
  end
end

function base_camp.Assembly_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  COMMON.ShowTeamAssemblyMenu(obj, COMMON.RespawnAllies)
end

function base_camp.Storage_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON:ShowTeamStorageMenu()
end

function base_camp.Noctowl_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)
  
  if not SV.base_camp.FirstTalkComplete and _DATA.Save:GetDungeonUnlock("champions_road") ~= RogueEssence.Data.GameProgress.UnlockState.Completed and SV.guildmaster_summit.GameComplete then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Noctowl_Action_Line_001']))
    SV.base_camp.FirstTalkComplete = true
  end
  
  local tutorial_choices = {STRINGS:FormatKey("DLG_CHOICE_YES"),
    STRINGS:FormatKey("MENU_INFO"),
    STRINGS:FormatKey("DLG_CHOICE_NO")}
  
  local zone = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get('training_maze')
  
  local result = 2
  while result == 2 do
    UI:BeginChoiceMenu(STRINGS:Format(MapStrings['Noctowl_Ask_Tutorial'], zone:GetColoredName()), tutorial_choices, 1, 3)
    UI:WaitForChoice()
    result = UI:ChoiceResult()
    if result == 1 then
      GAME:FadeOut(false, 20)
      GAME:EnterDungeon('training_maze', 0, 9, 0, RogueEssence.Data.GameProgress.DungeonStakes.None, false, true)
      break
    elseif result == 3 then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Noctowl_Tutorial_End']))
      break
    else
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Noctowl_Tutorial_Line_001'], zone:GetColoredName()))
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Noctowl_Tutorial_Line_002']))
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Noctowl_Tutorial_Line_003']))
    end
  end
  
end


function base_camp.NPC_Entrance_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Warn_Line_001']))
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Warn_Line_002']))
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Warn_Line_003']))
end

function base_camp.NPC_Coast_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Outside_Line_001']))
  GROUND:EntTurn(chara, Direction.Down)
end

function base_camp.NPC_Range_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)
  UI:SetSpeakerEmotion("Worried")
  
  
  SOUND:PlayBattleSE("EVT_Emote_Sweating")
  GROUND:CharSetEmote(chara, "sweating", 1)
  GAME:WaitFrames(30)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Range_Line_001']))
  UI:SetSpeakerEmotion("Sad")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Range_Line_002']))
end

function base_camp.Statue_Center_Action(obj, activator)
  
  UI:ResetSpeaker()
  UI:SetAutoFinish(true)
  UI:SetCenter(true)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Statue_Center_Text'], SV.base_camp.CenterStatueDate, GAME:GetTeamName()))
  UI:SetAutoFinish(false)
  UI:ResetSpeaker()
end

function base_camp.Statue_Left_Action(obj, activator)
  
  UI:ResetSpeaker()
  UI:SetAutoFinish(true)
  UI:SetCenter(true)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Statue_Left_Text'], SV.base_camp.LeftStatueDate, GAME:GetTeamName()))
  UI:SetAutoFinish(false)
  UI:ResetSpeaker()
end

function base_camp.Statue_Right_Action(obj, activator)
  
  UI:ResetSpeaker()
  UI:SetAutoFinish(true)
  UI:SetCenter(true)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Statue_Right_Text'], SV.base_camp.RightStatueDate, GAME:GetTeamName()))
  UI:SetAutoFinish(false)
  UI:ResetSpeaker()
end

function base_camp.Teammate1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

function base_camp.Teammate2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

function base_camp.Teammate3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

function base_camp.SisterReminderActive()
  if SV.family.Sister == 0 and SV.family.SisterActiveDays > 2 then
    return true
  end
  return false
end

return base_camp
