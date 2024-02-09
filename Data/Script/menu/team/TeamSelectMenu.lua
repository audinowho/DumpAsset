--[[
    TeamSelectMenu
    lua port by MistressNebula

    Opens a menu, potentially with multiple pages, that allows the player to select a Pokémon.
    It contains a run method for quick instantiation, as well as a way to open
    a version of itself containing the current party members.
    This equivalent is NOT SAFE FOR REPLAYS. Do NOT use in dungeons until further notice.
]]


--- Menu for selecting a character from a specific list of ``RogueEssence.Dungeon.Character`` objects.
TeamSelectMenu = Class("TeamSelectMenu")

--- Creates a new ``TeamSelectMenu`` instance using the provided list and callbacks.
--- This function throws an error if the parameter ``char_list`` contains less than 1 entries.
--- @param title string the title this window will have.
--- @param char_list table an array, list or lua array table containing ``RogueEssence.Dungeon.Character`` objects.
--- @param filter function a function that takes a ``RogueEssence.Dungeon.Character`` object and returns a boolean. Any character that does not pass this check will have its option disabled in the menu. Defaults to ``return true``.
--- @param confirm_action function the function called when a slot is chosen. It will have a ``RogueEssence.Dungeon.Character`` passed to it as a parameter.
--- @param refuse_action function the function called when the player presses the cancel or menu button.
--- @param use_submenu boolean whether or not to call the ``TeamSelectSubMenu`` before returning. Defaults to true.
--- @param menu_width number the width of this window. Default is 160.
function TeamSelectMenu:initialize(title, char_list, filter, confirm_action, refuse_action, use_submenu, menu_width)
    -- param validity check
    local len = 0
    if type(char_list) == 'table' then len = #char_list
    else len = char_list.Count end
    if len <1 then
        --abort if list is empty
        error("parameter 'char_list' cannot be an empty collection")
    end

    -- constants
    self.MAX_ELEMENTS = 5

    -- parsing data
    self.title = title
    self.confirmAction = confirm_action
    self.refuseAction = refuse_action
    self.use_submenu = use_submenu
    self.menuWidth = menu_width or 160
    self.filter = filter or function(_) return true end
    self.charList = self:load_chars(char_list)
    self.optionsList = self:generate_options()
    if #self.optionsList<self.MAX_ELEMENTS then self.MAX_ELEMENTS = #self.optionsList end
    if self.use_submenu == nil then self.use_submenu = true end

    self.choice = nil -- result

    self:createMenu()

    -- creating the summary window
    local GraphicsManager = RogueEssence.Content.GraphicsManager

    self.summary = RogueEssence.Menu.TeamMiniSummary(RogueElements.Rect.FromPoints(RogueElements.Loc(16,
            GraphicsManager.ScreenHeight - 8 - GraphicsManager.MenuBG.TileHeight * 2 - 14 * 5), --LINE_HEIGHT = 12, VERT_SPACE = 14
            RogueElements.Loc(GraphicsManager.ScreenWidth - 16, GraphicsManager.ScreenHeight - 8)))
    self.menu.SummaryMenus:Add(self.summary)
    self:updateSummary()
end

--- Performs the final adjustments and creates the actual menu object.
function TeamSelectMenu:createMenu()
    local origin = RogueElements.Loc(16,16)
    local option_array = luanet.make_array(RogueEssence.Menu.MenuElementChoice, self.optionsList)
    self.menu = RogueEssence.Menu.ScriptableMultiPageMenu(origin, self.menuWidth, self.title, option_array, 0, self.MAX_ELEMENTS, self.refuseAction, self.refuseAction, false)
    self.menu.ChoiceChangedFunction = function() self:updateSummary() end
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

--- Calls the menu's confirmation callback and stores the chosen character in the choice variable of this object.
--- If the menu is set to use the sub_menu, the aforementioned process will be performed only if the sub_menu
--- returns true.
--- @param index number the chosen character.
function TeamSelectMenu:choose(index)
    local callback = function(ret)
        if ret==true then
            self.choice = self.charList[index]
            self.confirmAction(self.choice)
        end
        _MENU:RemoveMenu()
    end

    if self.use_submenu then
        self:callSubMenu(callback)
    else
        self.choice = self.charList[index]
        self.confirmAction(self.choice)
    end
end

--- Summons a ``TeamSelectSubMenu`` with the provided callback.
--- @param callback function the function that will be called by the menu upon running confirm or cancel operations. It will have a boolean passed as a parameter.
function TeamSelectMenu:callSubMenu(callback)
    _MENU:AddMenu(TeamSelectSubMenu:new(self, function() callback(true) end, function() callback(false) end).menu, true)
end

--- Updates the summary window.
function TeamSelectMenu:updateSummary()
    self.summary:SetMember(self.charList[self.menu.CurrentChoiceTotal+1])
end


-------------------------------------------------------------------------------------------
--- Menu for selecting one or more characters from a specific list of ``RogueEssence.Dungeon.Character`` objects.
TeamMultiSelectMenu = Class("TeamMultiSelectMenu", TeamSelectMenu)
-------------------------------------------------------------------------------------------

--- Creates a new ``TeamMultiSelectMenu`` instance using the provided list and callbacks.
--- This function throws an error if the parameter ``char_list`` contains less than 1 entries.
--- @param title string the title this window will have.
--- @param char_list table an array, list or lua array table containing ``RogueEssence.Dungeon.Character`` objects.
--- @param filter function a function that takes a ``RogueEssence.Dungeon.Character`` object and returns a boolean. Any character that does not pass this check will have its option disabled in the menu. Defaults to ``return true``.
--- @param confirm_action function the function called when a slot is chosen. It will have a ``RogueEssence.Dungeon.Character`` passed to it as a parameter.
--- @param refuse_action function the function called when the player presses the cancel or menu button.
--- @param menu_width number the width of this window. Default is 160.
function TeamMultiSelectMenu:initialize(title, char_list, filter, confirm_action, refuse_action, menu_width)
    self.multiConfirmAction = function(list)
        self.choice = self:multiConfirm(list)
        self.confirmAction(self.choice)
    end
    TeamSelectMenu.initialize(self, title, char_list, filter, confirm_action, refuse_action, menu_width)
end

--- Performs the final adjustments and creates the actual menu object.
function TeamMultiSelectMenu:createMenu()
    local valid = self:count_valid()
    local origin = RogueElements.Loc(16,16)
    local option_array = luanet.make_array(RogueEssence.Menu.MenuElementChoice, self.optionsList)
    self.menu = RogueEssence.Menu.ScriptableMultiPageMenu(origin, self.menuWidth, self.title, option_array, 0, self.MAX_ELEMENTS, self.refuseAction, self.refuseAction, false, valid, self.multiConfirmAction)
    self.menu.ChoiceChangedFunction = function() self:updateSummary() end
end

--- Counts the number of valid options generated.
--- @return number the number of valid options.
function TeamMultiSelectMenu:count_valid()
    local count = 0
    for _, option in pairs(self.optionsList) do
        if option.Enabled then count = count+1 end
    end
    return count
end

--- Calls the menu's confirmation callback and stores the table array of chosen charactes in the choice
--- variable of this object.
--- If the menu is set to use the sub_menu, the aforementioned process will be performed only if the sub_menu
--- returns true.
--- @param index number the chosen character, wrapped inside of a single element table array.
function TeamMultiSelectMenu:choose(index)
    local callback = function(ret)
        if ret==true then
            self.multiConfirmAction({index-1})
        end
        _MENU:RemoveMenu()
    end

    if self.use_submenu then
        self:callSubMenu(callback)
    else
        self.multiConfirmAction({index-1})
    end
end

--- Extract the list of selected slots.
--- @param list table a table array containing the menu indexes of the chosen items.
--- @return table a table array containing ``RogueEssence.Dungeon.InvSlot`` objects.
function TeamMultiSelectMenu:multiConfirm(list)
    local result = {}
    for _, index in pairs(list) do
        local char = self.charList[index+1]
        table.insert(result, char)
    end
    return result
end


-------------------------------------------------------------------------------------------
--- Menu for choosing what to do with the chosen character.
TeamSelectSubMenu = Class("TeamSelectSubMenu")
-------------------------------------------------------------------------------------------

--- Creates a new ``TeamSelectSubMenu`` instance using the provided data and callbacks.
--- @param parent table a ``TeamSelectMenu``
--- @param confirm_action function the function called when the first option is pressed.
--- @param refuse_action function the function called when the third option or the cancel or menu buttons are pressed.
function TeamSelectSubMenu:initialize(parent, confirm_action, refuse_action)
    self.parent = parent
    local x, y, w = parent.menu.Bounds.Right, parent.menu.Bounds.Top, 64
    local summary_action = function()
        self:openSummary()
    end
    
    local choices = {
        {STRINGS:FormatKey("MENU_CHOOSE"),       true, confirm_action},
        {STRINGS:FormatKey("MENU_TEAM_SUMMARY"), true, summary_action},
        {STRINGS:FormatKey("MENU_EXIT"),         true, refuse_action}
    }
    self.menu = RogueEssence.Menu.ScriptableSingleStripMenu(x, y, w, choices, 0, refuse_action)
end

--- Opens the ``RogueEssence.Menu.MemberFeaturesMenu`` of the character selected in the parent menu.
function TeamSelectSubMenu:openSummary()
    _MENU:AddMenu(RogueEssence.Menu.MemberFeaturesMenu(self.parent.menu.CurrentChoiceTotal, false, false), false)
end




-------------------------------------------------------------------------------------------
--- Creates a basic ``TeamSelectMenu`` instance using the provided list and callbacks, then runs it and returns its output.
--- @param title string the title this window will have
--- @param char_list table an array, list or lua array table containing ``RogueEssence.Dungeon.Character`` objects.
--- @param filter function a function that takes a ``RogueEssence.Dungeon.Character`` object and returns a boolean. Any character that does not pass this check will have its option disabled in the menu. Defaults to ``return true``.
--- @param use_submenu boolean whether or not to call the ``TeamSelectSubMenu`` before returning. Defaults to true.
--- @return userdata the selected character if one was chosen in the menu; ``nil`` otherwise.
function TeamSelectMenu.run(title, char_list, filter, use_submenu)
    local ret
    local choose = function(char)
        ret = char
        _MENU:RemoveMenu()
    end
    local refuse = function() _MENU:RemoveMenu() end
    local menu = TeamSelectMenu:new(title, char_list, filter, choose, refuse, use_submenu)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
    return ret
end

--- Creates a ``TeamSelectMenu`` instance that allows a choice between the current party members.
--- @param filter function a function that takes a ``RogueEssence.Dungeon.Character`` object and returns a boolean. Any character that does not pass this check will have its option disabled in the menu. Defaults to ``return true``.
--- @param use_submenu boolean whether or not to call the ``TeamSelectSubMenu`` before returning. Defaults to true.
--- @return userdata the selected character if one was chosen in the menu; ``nil`` otherwise.
function TeamSelectMenu.runPartyMenu(filter, use_submenu)
    local char_list = _DATA.Save.ActiveTeam.Players

    return TeamSelectMenu.run(STRINGS:FormatKey("MENU_TEAM_TITLE"), char_list, filter, use_submenu)
end

-------------------------------------------------------------------------------------------
--- Creates a basic ``TeamMultiSelectMenu`` instance using the provided list and callbacks, then runs it and returns its output.
--- @param title string the title this window will have
--- @param char_list table an array, list or lua array table containing ``RogueEssence.Dungeon.Character`` objects.
--- @param filter function a function that takes a ``RogueEssence.Dungeon.Character`` object and returns a boolean. Any character that does not pass this check will have its option disabled in the menu. Defaults to ``return true``.
--- @return table the list of selected characters if at least one was chosen in the menu; ``nil`` otherwise.
function TeamMultiSelectMenu.runMultiMenu(title, char_list, filter)
    local ret = {}
    local choose = function(chars)
        ret = chars
        _MENU:RemoveMenu()
    end
    local refuse = function() _MENU:RemoveMenu() end
    local menu = TeamMultiSelectMenu:new(title, char_list, filter, choose, refuse)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
    return ret
end

--- Creates a ``TeamMultiSelectMenu`` instance that allows a choice between the current party members.
--- @param filter function a function that takes a ``RogueEssence.Dungeon.Character`` object and returns a boolean. Any character that does not pass this check will have its option disabled in the menu. Defaults to ``return true``.
--- @return table the list of selected characters if at least one was chosen in the menu; ``nil`` otherwise.
function TeamMultiSelectMenu.runMultiPartyMenu(filter)
    local char_list = _DATA.Save.ActiveTeam.Players

    return TeamMultiSelectMenu.runMultiMenu(STRINGS:FormatKey("MENU_TEAM_TITLE"), char_list, filter)
end