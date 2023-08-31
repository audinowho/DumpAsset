require 'common'

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
  
  if not SV.guild_hut.ExpositionComplete then
    guild_hut.BeginExposition()
	SV.guild_hut.ExpositionComplete = true
  elseif SV.guild_hut.BookPhase == 1 then
    guild_hut.AfterFirstNovel()
    SV.guild_hut.BookPhase = 2
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
  UI:WaitShowDialogue("This was the base of operations for the original guildmaster.")
  UI:WaitShowDialogue("It's yours now.")
  
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
  UI:WaitShowDialogue("talk about the guild and how the guildmaster left")
  --they took all the magnagates and closed the portal
  UI:WaitShowDialogue("they took all the magnagates and closed the portal, leaving only one.")
  
  if SV.guild_hut.TookCard == false then
    UI:WaitShowDialogue("...there's a card between the pages.")
  
    --set the savevar
	SV.guild_hut.TookCard = true
    --add the card
	SV.magnagate.Cards = SV.magnagate.Cards + 1
    --message you got the card
	
	UI:WaitShowDialogue("You got the sun card")
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
  
  
  UI:ResetSpeaker()
  if SV.guild_hut.BookPhase == 0 then
    UI:WaitShowDialogue("It's a book called the neverending tale")
    UI:WaitShowDialogue("A story of a band of fearless explorers traveling the lands on an endless journey...")
    UI:WaitShowDialogue("...")
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
    local book_choices = {"Read",
      "Notes",
      STRINGS:FormatKey("MENU_CANCEL")}
  
    local zone = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get('the_neverending_tale')
  
    local result = 2
    while result == 2 do
      UI:BeginChoiceMenu(STRINGS:Format("The book reads, {0}", zone:GetColoredName()), book_choices, 1, 3)
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
  UI:WaitShowDialogue("...?")
  UI:WaitShowDialogue("Must've dozed off...")
  UI:WaitShowDialogue("There's notes on the back of the book.")
  
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
  
  local dungeon_entrances = { 'tropical_path', 'faded_trail', 'bramble_woods', 'faultline_ridge' }
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
  COMMON.GroundInteract(activator, chara, true)
end

function guild_hut.Teammate2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

function guild_hut.Teammate3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, true)
end

return guild_hut