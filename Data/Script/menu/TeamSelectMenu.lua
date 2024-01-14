--[[
    TeamSelectMenu
    lua port by MistressNebula

    Opens a menu, potentially with multiple pages, that allows the player to select a Pokémon.
    It contains a run method for quick instantiation, as well as a way to open
    a version of itself containing the current party members.
    This equivalent is NOT SAFE FOR REPLAYS. Do NOT use in dungeons until further notice.
]]


--- Menu for selecting a skill from a specific list of ``RogueEssence.Dungeon.Character`` objects.
TeamSelectMenu = Class("TeamSelectMenu")

--- Creates a new ``TeamSelectMenu`` instance using the provided list and callbacks.
--- This function throws an error if the parameter ``char_list`` contains less than 1 entries.
--- @param title string the title this window will have.
--- @param char_list table an array, list or lua array table containing ``RogueEssence.Dungeon.Character`` objects.
--- @param filter function a function that takes a ``RogueEssence.Dungeon.Character`` object and returns a boolean. Any character that does not pass this check will have its option disabled in the menu. Defaults to ``return true``.
--- @param confirm_action function the function called when a slot is chosen. It will have a ``RogueEssence.Dungeon.Character`` passed to it as a parameter.
--- @param refuse_action function the function called when the player presses the cancel or menu button.
--- @param menu_width number the width of this window. Default is 160.
function TeamSelectMenu:initialize(title, char_list, filter, confirm_action, refuse_action, menu_width)
    -- param validity check
    local len = 0
    if type(char_list) == 'table' then len = #char_list
    else len = char_list.Count end
    if len <1 then
        --abort if skill list is empty
        error("parameter 'char_list' cannot be an empty collection")
    end

    -- constants
    self.MAX_ELEMENTS = 5

    -- parsing data
    self.confirmAction = confirm_action
    self.refuseAction = refuse_action
    self.menuWidth = menu_width or 160
    self.filter = filter or function(_) return true end
    self.charList = self:load_chars(char_list)
    self.optionsList = self:generate_options()
    if #self.optionsList<self.MAX_ELEMENTS then self.MAX_ELEMENTS = #self.optionsList end

    self.choice = nil -- result

    -- creating the menu
    local origin = RogueElements.Loc(16,16)
    local option_array = luanet.make_array(RogueEssence.Menu.MenuElementChoice, self.optionsList)
    self.menu = RogueEssence.Menu.ScriptableMultiPageMenu(origin, self.menuWidth, title, option_array, 0, self.MAX_ELEMENTS, refuse_action, refuse_action, false)
    self.menu.ChoiceChangedFunction = function() self:updateSummary() end

    -- creating the summary window
    local GraphicsManager = RogueEssence.Content.GraphicsManager

    self.summary = RogueEssence.Menu.TeamMiniSummary(RogueElements.Rect.FromPoints(RogueElements.Loc(16,
            GraphicsManager.ScreenHeight - 8 - GraphicsManager.MenuBG.TileHeight * 2 - 14 * 5), --LINE_HEIGHT = 12, VERT_SPACE = 14
            RogueElements.Loc(GraphicsManager.ScreenWidth - 16, GraphicsManager.ScreenHeight - 8)))
    self.menu.SummaryMenus:Add(self.summary)
    self:updateSummary()
end


--- Loads the characters that will be part of the menu.
--- @param char_list table an array, list or lua array table containing ``RogueEssence.Dungeon.Character`` objects.
--- @return table a standardized version of the character list
function TeamSelectMenu:load_chars(char_list)
    local list = {}

    if type(char_list) == 'table' then
        for _, char in pairs(char_list) do table.insert(list, char) end
    else
        for char in luanet.each(LUA_ENGINE:MakeList(char_list)) do table.insert(list, char) end
    end
    return list
end

--- Processes the menu's properties and generates the ``RogueEssence.Menu.MenuElementChoice`` list that will be displayed.
--- @return table a list of ``RogueEssence.Menu.MenuElementChoice`` objects.
function TeamSelectMenu:generate_options()
    local options = {}
    for i=1, #self.charList, 1 do
        local char = self.charList[i]
        local enabled = self.filter(char)
        local color = Color.White
        if not enabled then color = Color.Red end

        local name = char:GetDisplayName(true)
        local level = char.Level
        local text_name = RogueEssence.Menu.MenuText(name, RogueElements.Loc(2, 1), color)
        local text_lv_label = RogueEssence.Menu.MenuText(STRINGS:FormatKey("MENU_TEAM_LEVEL_SHORT"), RogueElements.Loc(self.menuWidth - 8 * 7 + 6, 1), RogueElements.DirV.Up, RogueElements.DirH.Right, color)
        local text_level = RogueEssence.Menu.MenuText(tostring(level), RogueElements.Loc(self.menuWidth - 8 * 4, 1), RogueElements.DirV.Up, RogueElements.DirH.Right, color)
        local option = RogueEssence.Menu.MenuElementChoice(function() self:choose(i) end, enabled, text_name, text_lv_label, text_level)
        table.insert(options, option)
    end
    return options
end

--- Closes the menu and calls the menu's confirmation callback.
--- The result must be retrieved by accessing the choice variable of this object, which will hold
--- the string id of the chosen skill.
--- @param index number the index of the chosen character.
function TeamSelectMenu:choose(index)
    self.choice = self.charList[index]
    _MENU:RemoveMenu()
    self.confirmAction(self.choice)
end

--- Updates the summary window.
function TeamSelectMenu:updateSummary()
    self.summary:SetMember(self.charList[self.menu.CurrentChoiceTotal+1])
end




--- Creates a basic ``TeamSelectMenu`` instance using the provided list and callbacks, then runs it and returns its output.
--- @param title string the title this window will have
--- @param char_list table an array, list or lua array table containing ``RogueEssence.Dungeon.Character`` objects.
--- @param filter function a function that takes a ``RogueEssence.Dungeon.Character`` object and returns a boolean. Any character that does not pass this check will have its option disabled in the menu. Defaults to ``return true``.
--- @return userdata the selected character if one was chosen in the menu; ``nil`` otherwise.
function TeamSelectMenu.run(title, char_list, filter)

    local ret = nil
    local choose = function(char) ret = char end
    local refuse = function() _MENU:RemoveMenu() end
    local menu = TeamSelectMenu:new(title, char_list, filter, choose, refuse)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
    return ret
end

--- Creates a ``TeamSelectMenu`` instance that allows a choice between the current party members.
--- @param filter function a function that takes a ``RogueEssence.Dungeon.Character`` object and returns a boolean. Any character that does not pass this check will have its option disabled in the menu. Defaults to ``return true``.
--- @return userdata the selected character if one was chosen in the menu; ``nil`` otherwise.
function TeamSelectMenu.runPartyMenu(filter)
    local char_list = _DATA.Save.ActiveTeam.Players

    return TeamSelectMenu.run(STRINGS:FormatKey("MENU_TEAM_TITLE"), char_list, filter)
end