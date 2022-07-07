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
  
  if not SV.base_camp.IntroComplete then
    base_camp.PrepareFirstTimeVisit()
	GAME:FadeIn(20)
  elseif SV.test_grounds.DemoComplete then
    local noctowl = CH('Noctowl')
    GROUND:TeleportTo(noctowl, 80, 288, Direction.Right)
	GAME:FadeIn(20)
  elseif not SV.base_camp.ExpositionComplete then
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
  
      for i = 1,assemblyCount,1 do
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
    UI:SetSpeaker(STRINGS:Format("\\uE040"), true, -1, -1, -1, RogueEssence.Data.Gender.Unknown)
	
    local zone = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone].Entries['guildmaster_trail']
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_001'], zone:GetColoredName()))
    --move the noctowl to a new position
    local noctowl = CH('Noctowl')
    GROUND:TeleportTo(noctowl, 244, 286, Direction.Up)
    GAME:FadeIn(20)
  else
    GAME:FadeIn(20)
  end
  --When the player gets back after fainting for the first time, play this cutscene
  if SV.base_camp.IntroComplete and not SV.base_camp.ExpositionComplete then
    base_camp.BeginExposition()
    SV.base_camp.ExpositionComplete = true
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
  GROUND:Hide("NPC_Bystander")
  GROUND:Hide("Lapras")
  GROUND:Unhide("East_LogPile")
  GROUND:Unhide("West_LogPile")
  GROUND:Unhide("First_North_Exit")
  GAME:UnlockDungeon('guildmaster_trail')
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------
function base_camp.BeginExposition()  
  local noctowl = CH('Noctowl')
  local player = CH('PLAYER')
  UI:SetSpeaker(noctowl)
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_002']))
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_003']))
  
  GROUND:CharSetEmote(player, 8, 1)
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
  
  local zone = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone].Entries['guildmaster_trail']
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
  
  zone = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone].Entries['tropical_path']
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

--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------

function base_camp.North_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local dungeon_entrances = { 'tropical_path', 'faulted_cliffs', 'cave_of_whispers', 'shimmer_bay', 'guildmaster_trail' }
  local ground_entrances = {{Flag=SV.forest_camp.ExpositionComplete,Zone=1,ID=3,Entry=0},
  {Flag=SV.cliff_camp.ExpositionComplete,Zone='guildmaster_island',ID=4,Entry=0},
  {Flag=SV.canyon_camp.ExpositionComplete,Zone='guildmaster_island',ID=5,Entry=0},
  {Flag=SV.rest_stop.ExpositionComplete,Zone='guildmaster_island',ID=6,Entry=0},
  {Flag=SV.final_stop.ExpositionComplete,Zone='guildmaster_island',ID=7,Entry=0},
  {Flag=SV.guildmaster_summit.ExpositionComplete,Zone='guildmaster_island',ID=8,Entry=0}}
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end

function base_camp.First_North_Exit_Touch(obj, activator)  
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:ResetSpeaker()
  local zone = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone].Entries['guildmaster_trail']
  UI:ChoiceMenuYesNo(STRINGS:FormatKey("DLG_ASK_ENTER_DUNGEON", zone:GetColoredName()), false)
  UI:WaitForChoice()
  ch = UI:ChoiceResult()
  if ch then
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
  GAME:EnterGroundMap("base_camp_2", "entrance_west")
end

function base_camp.Sign_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  UI:SetAutoFinish(true)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Sign_Action_Text']))
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
  
  if not SV.base_camp.FirstTalkComplete then
    -- UI:WaitShowDialogue(STRINGS:Format(MapStrings['Noctowl_Action_Line_003']))
    SV.base_camp.FirstTalkComplete = true
  end
  
  local tutorial_choices = {STRINGS:FormatKey("DLG_CHOICE_YES"),
    STRINGS:FormatKey("MENU_INFO"),
    STRINGS:FormatKey("DLG_CHOICE_NO")}
  
  local zone = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone].Entries['training_maze']
  
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
  GROUND:CharSetEmote(chara, 5, 1)
  GAME:WaitFrames(30)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Range_Line_001']))
  UI:SetSpeakerEmotion("Sad")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Range_Line_002']))
end

function base_camp.NPC_Bystander_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Bystander_Line_001']))
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

return base_camp