require 'origin.common'

local guild_hut = {}
local MapStrings = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function guild_hut.Init(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_guild_hut")
  MapStrings = COMMON.AutoLoadLocalizedStrings()
  
  COMMON.RespawnAllies()
end

function guild_hut.Enter(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  if SV.guild_hut.Portal then
    GROUND:Unhide("Card_Portal")
  end
  
  if not SV.guild_hut.ExpositionComplete then
    guild_hut.BeginExposition()
	SV.guild_hut.ExpositionComplete = true
  elseif SV.guild_hut.BookPhase == 1 then
    guild_hut.AfterFirstNovel()
    SV.guild_hut.BookPhase = 2
  elseif SV.family.Returned and not SV.guild_hut.Portal then
    guild_hut.FamilyReturn()
	SV.guild_hut.Portal = true
  else
    GAME:FadeIn(20)
  end
end

function guild_hut.Update(map, time)
end

--------------------------------------------------
-- Map Begin Functions
--------------------------------------------------

    
function guild_hut.BeginExposition()
  
  GAME:CutsceneMode(true)
  local player = CH('PLAYER')
  local noctowl = CH('Noctowl')
  
  
  local team1 = CH('Teammate1')
  local team2 = CH('Teammate2')
  local team3 = CH('Teammate3')
  GROUND:TeleportTo(player, 184, 256, Direction.Up)
  if team1 ~= nil then
    GROUND:TeleportTo(team1, 160, 256, Direction.Up)
  end
  if team2 ~= nil then
    GROUND:TeleportTo(team2, 208, 256, Direction.Up)
  end
  if team3 ~= nil then
    GROUND:TeleportTo(team3, 184, 240, Direction.Up)
  end
  
  GAME:FadeIn(20)
	
  GROUND:Unhide("Noctowl")
  
  UI:SetSpeaker(noctowl)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_001']))
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Expo_Cutscene_Line_002']))
  
  GROUND:CharAnimateTurnTo(noctowl, Direction.Down, 4)
  
  
  GAME:FadeOut(false, 20)
  
  
  if team1 ~= nil then
    GROUND:TeleportTo(team1, 120, 228, Direction.Up)
  end
  if team2 ~= nil then
    GROUND:TeleportTo(team2, 80, 180, Direction.Right)
  end
  if team3 ~= nil then
    GROUND:TeleportTo(team3, 120, 164, Direction.Down)
  end
  
  GAME:WaitFrames(60)
  
  GAME:CutsceneMode(false)
  
  GROUND:Hide("Noctowl")
  
  GAME:FadeIn(20)
  
end


function guild_hut.FamilyReturn()
  GAME:CutsceneMode(true)
  
  GROUND:Unhide("Noctowl")
  GROUND:Unhide("Family_Sister")
  GROUND:Unhide("Family_Mother")
  GROUND:Unhide("Family_Father")
  GROUND:Unhide("Family_Brother")
  GROUND:Unhide("Family_Pet")
  GROUND:Unhide("Family_Grandma")
  
  local player = CH('PLAYER')
  local noctowl = CH('Noctowl')
  local sister = CH('Family_Sister')
  local mother = CH('Family_Mother')
  local brother = CH('Family_Brother')
  local grandma = CH('Family_Grandma')
  
  GAME:FadeIn(20)
  
  UI:ResetSpeaker()
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Isekai_Line_001']))
  
  SOUND:PlayBattleSE("EVT_Evolution_Start")
  GAME:FadeOut(true, 20)
  GROUND:Unhide("Card_Portal")
  GAME:FadeIn(20)
  
  UI:SetSpeaker(brother)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Isekai_Line_002']))
  
  UI:SetSpeaker(mother)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Isekai_Line_003']))
  
  UI:SetSpeaker(grandma)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Isekai_Line_004']))
  
  UI:SetSpeaker(noctowl)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Isekai_Line_005']))
  UI:ResetSpeaker()
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Isekai_Line_006']))
  
  GROUND:Hide("Family_Sister")
  GROUND:Hide("Family_Mother")
  GROUND:Hide("Family_Father")
  GROUND:Hide("Family_Brother")
  GROUND:Hide("Family_Pet")
  GROUND:Hide("Family_Grandma")
  
  
  UI:SetSpeaker(noctowl)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Isekai_Line_007']))
  
  GAME:FadeOut(false, 20)
  
  GAME:WaitFrames(60)
  
  GAME:CutsceneMode(false)
  
  GROUND:Hide("Noctowl")
  
  GAME:FadeIn(20)
  
end

--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------
function guild_hut.South_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GAME:FadeOut(false, 20)
  GAME:EnterGroundMap("guild_path", "entrance_hut")
end

function guild_hut.Journal_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  
  GROUND:ObjectSetDefaultAnim(obj, 'Diary_Purple_Opening', 0, 0, 0, Direction.Right)	  
  GROUND:ObjectSetAnim(obj, 6, 0, 3, Direction.Right, 1)
  GROUND:ObjectSetDefaultAnim(obj, 'Diary_Purple_Opening', 0, 3, 3, Direction.Right)
  
  
  --talk about the guild and how the guildmaster left?
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Journal_Line_001']))
  --they took all the magnagates and closed the portal
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Journal_Line_002']))
  
  if SV.guild_hut.TookCard == false then
    local player = CH('PLAYER')
    
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Journal_Line_Card']))
  
    --set the savevar
    SV.guild_hut.TookCard = true
    --add the card
    SV.magnagate.Cards = SV.magnagate.Cards + 1
    --message you got the card
    COMMON.GiftKeyItem(player, RogueEssence.StringKey("ITEM_KEY_CARD_WORLD"):ToLocal())
  end
  
  GROUND:ObjectSetDefaultAnim(obj, 'Diary_Purple_Closing', 0, 0, 0, Direction.Right)
  GROUND:ObjectSetAnim(obj, 6, 0, 3, Direction.Right, 1)
  GROUND:ObjectSetDefaultAnim(obj, 'Diary_Purple_Closing', 0, 3, 3, Direction.Right)
end

function guild_hut.Novel_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  
  GROUND:ObjectSetDefaultAnim(obj, 'Diary_Green_Opening', 0, 0, 0, Direction.Left)	  
  GROUND:ObjectSetAnim(obj, 6, 0, 3, Direction.Left, 1)
  GROUND:ObjectSetDefaultAnim(obj, 'Diary_Green_Opening', 0, 3, 3, Direction.Left)
  
  local zone = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get('the_neverending_tale')
  
  UI:ResetSpeaker()
  if SV.guild_hut.BookPhase == 0 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Novel_Intro_001'], zone:GetColoredName()))
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Novel_Intro_002']))
    GAME:FadeOut(false, 20)
	  SV.guild_hut.BookPhase = 1
	  --enter the dungeon with 0 stakes
	
    SV.checkpoint = 
    {
      Zone    = 'guildmaster_island', Segment  = -1,
      Map  = 10, Entry  = 2
    }
	
    GAME:EnterDungeon('the_neverending_tale', 0, 0, 0, RogueEssence.Data.GameProgress.DungeonStakes.None, true, true)
    return
  else    
    local book_choices = {STRINGS:Format(MapStrings['Menu_Novel_Read']),
      STRINGS:Format(MapStrings['Menu_Novel_Notes']),
      STRINGS:FormatKey("MENU_CANCEL")}
  
    local result = 2
    while result == 2 do
      UI:BeginChoiceMenu(STRINGS:Format(MapStrings['Novel_Ask'], zone:GetColoredName()), book_choices, 1, 3)
      UI:WaitForChoice()
      result = UI:ChoiceResult()
      if result == 1 then
        GAME:FadeOut(false, 20)
		
		SV.checkpoint = 
		{
		  Zone    = 'guildmaster_island', Segment  = -1,
		  Map  = 10, Entry  = 2
		}
		
        GAME:EnterDungeon('the_neverending_tale', 0, 0, 0, RogueEssence.Data.GameProgress.DungeonStakes.None, true, true)
        break
      elseif result == 2 then
        guild_hut.DisplayNotes()
      end
    end
  end
  
  GROUND:ObjectSetDefaultAnim(obj, 'Diary_Green_Closing', 0, 0, 0, Direction.Left)
  GROUND:ObjectSetAnim(obj, 6, 0, 3, Direction.Left, 1)
  GROUND:ObjectSetDefaultAnim(obj, 'Diary_Green_Closing', 0, 3, 3, Direction.Left)
end


function guild_hut.AfterFirstNovel()
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local obj = OBJ("Novel")
  GROUND:ObjectSetDefaultAnim(obj, 'Diary_Green_Opening', 0, 3, 3, Direction.Left)
  
  GAME:FadeIn(20)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Novel_After_001']))
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Novel_After_002']))
  
  guild_hut.DisplayNotes()
  
  GROUND:ObjectSetDefaultAnim(obj, 'Diary_Green_Closing', 0, 0, 0, Direction.Left)
  GROUND:ObjectSetAnim(obj, 6, 0, 3, Direction.Left, 1)
  GROUND:ObjectSetDefaultAnim(obj, 'Diary_Green_Closing', 0, 3, 3, Direction.Left)
end

function guild_hut.DisplayNotes()
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  --display a custom menu of the top 10 endeavors
  --do it for all 4 teamsizes
  --[Name] [Icon] [Icon] [Icon] [Icon] Floor + Score
  
  local menu = guild_hut.NoteMenu:new()
  UI:SetCustomMenu(menu.menu)
  UI:WaitForChoice()
  
end

function guild_hut.Card_Portal_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local dungeon_entrances = { 'tropical_path', 'faded_trail', 'bramble_woods', 'faultline_ridge', 'trickster_woods',
    'moonlit_courtyard', 'fertile_valley', 'flyaway_cliffs', 'overgrown_wilds', 'lava_floe_island', 'castaway_cave',
    'copper_quarry', 'depleted_basin', 'forsaken_desert', 'relic_tower', 'sleeping_caldera', 'thunderstruck_pass', 'veiled_ridge',
    'snowbound_path', 'champions_road',
    'ambush_forest', 'treacherous_mountain', 'barren_tundra', 'energy_garden', 'wayward_wetlands', 'sickly_hollow',
    'cave_of_solace', 'royal_halls', 'the_sky', 'guildmaster_trail', 'secret_garden', 'the_abyss'}
  local ground_entrances = { }
  COMMON.ShowDestinationMenu(dungeon_entrances,ground_entrances)
end

-- equivalent to defining a class
guild_hut.NoteMenu = Class('NoteMenu')

function guild_hut.NoteMenu:initialize()
  assert(self, "NoteMenu:initialize(): Error, self is nil!")
  self.menu = RogueEssence.Menu.ScriptableMenu(24, 24, 196, 128, function(input) self:Update(input) end)
  
  self.cursor = RogueEssence.Menu.MenuCursor(self.menu)
  self.menu.MenuElements:Add(self.cursor)
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText("Test String", RogueElements.Loc(16, 8 + 12 * 0)))
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText("Apple", RogueElements.Loc(88, 8 + 12 * 0)))
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText("Test String 2", RogueElements.Loc(16, 8 + 12 * 1)))
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText("Orange", RogueElements.Loc(88, 8 + 12 * 1)))
  self.total_items = 4
  self.current_item = 0
  self.cursor.Loc = RogueElements.Loc(8 + 12 * (self.current_item % 2), 8 + 80 * (self.current_item // 2))
end

function guild_hut.NoteMenu:Update(input)
  assert(self, "BaseState:Begin(): Error, self is nil!")
  -- default does nothing
  if input:JustPressed(RogueEssence.FrameInput.InputType.Confirm) then
    _GAME:SE("Menu/Confirm")
  elseif input:JustPressed(RogueEssence.FrameInput.InputType.Cancel) then
    _GAME:SE("Menu/Cancel")
    _MENU:RemoveMenu()
  end
end


function guild_hut.Assembly_1_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  COMMON.ShowTeamAssemblyMenu(obj, COMMON.RespawnAllies)
end


function guild_hut.Assembly_2_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  COMMON.ShowTeamAssemblyMenu(obj, COMMON.RespawnAllies)
end

function guild_hut.Assembly_3_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  UI:ResetSpeaker()
  COMMON.ShowTeamAssemblyMenu(obj, COMMON.RespawnAllies)
end

function guild_hut.Storage_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON:ShowTeamStorageMenu()
end

function guild_hut.Teammate1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara)
end

function guild_hut.Teammate2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara)
end

function guild_hut.Teammate3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara)
end

return guild_hut