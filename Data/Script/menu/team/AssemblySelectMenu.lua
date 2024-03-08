--[[
    AssemblySelectMenu
    lua port by MistressNebula

    Opens a menu, potentially with multiple pages, that allows the player to select a Pokémon from the assembly.
    It contains a few run methods for quick instantiation.
    This equivalent is NOT SAFE FOR REPLAYS. Do NOT use in dungeons until further notice.
]]
require 'menu.team.TeamSelectMenu'

--- Menu for selecting a character from the assembly.
AssemblySelectMenu = Class("AssemblySelectMenu", TeamSelectMenu)

--- Creates a new ``AssemblySelectMenu`` instance using the provided list and callbacks.
--- @param filter function a function that takes a ``RogueEssence.Dungeon.Character`` object and returns a boolean. Any character that does not pass this check will have its option disabled in the menu. Defaults to ``return true``.
--- @param confirm_action function the function called when a slot is chosen. It will have a ``RogueEssence.Dungeon.Character`` passed to it as a parameter.
--- @param refuse_action function the function called when the player presses the cancel or menu button.
--- @param use_submenu boolean whether or not to call the ``AssemblySelectSubMenu`` before returning. Defaults to true.
--- @param menu_width number the width of this window. Default is 160.
--- @param sort_mode userdata a ``RogueEssence.Menu.AssemblyMenu.AssemblySortMode`` object. defaults to ``Recent``
function AssemblySelectMenu:initialize(filter, confirm_action, refuse_action, use_submenu, menu_width, sort_mode)
    -- helper structues
    local sort_modes = RogueEssence.Menu.AssemblyMenu.AssemblySortMode
    self.mode_to_int = {}
    self.mode_to_int[sort_modes.Recent]   = 0
    self.mode_to_int[sort_modes.Level]    = 1
    self.mode_to_int[sort_modes.Species]  = 2
    self.mode_to_int[sort_modes.Nickname] = 3
    self.int_to_mode = {}
    self.int_to_mode[0] = sort_modes.Recent
    self.int_to_mode[1] = sort_modes.Level
    self.int_to_mode[2] = sort_modes.Species
    self.int_to_mode[3] = sort_modes.Nickname

    self:createPortraitBox()

    -- set defaults
    self.sort_mode = sort_mode or sort_modes.Recent
    if not self.mode_to_int[self.sort_mode] then
        PrintInfo("sort_mode parameter for AssemblySelectMenu was not a valid AssemblySortMode. It will default to \"Recent\"")
        self.sort_mode = sort_modes.Recent
    end

    -- call superclass initializer
    local placeholder = {}
    table.insert(placeholder, 0)
    TeamSelectMenu.initialize(self, STRINGS:FormatKey("MENU_ASSEMBLY_TITLE"), placeholder, filter, confirm_action, refuse_action, use_submenu, menu_width)
    self.menu.UpdateFunction = function(input) self:updateFunction(input) end
    self.menu.SummaryMenus:Add(self.portrait_box)
end

--- Performs the final adjustments and creates the actual menu object.
function AssemblySelectMenu:createMenu()
    self.MAX_ELEMENTS = 6

    local origin = RogueElements.Loc(16,16)
    local option_array = luanet.make_array(RogueEssence.Menu.MenuElementChoice, self.optionsList)
    self.menu = RogueEssence.Menu.ScriptableMultiPageMenu(origin, self.menuWidth, self.title, option_array, 0, self.MAX_ELEMENTS, self.refuseAction, self.refuseAction, true)
    self.menu.ChoiceChangedFunction = function() self:updateSummary() end
end

--- Creates a portrait box for this menu
function AssemblySelectMenu:createPortraitBox()
    -- i hate having to use a window like this but i have no other choice
    local GraphicsManager = RogueEssence.Content.GraphicsManager
    local x, y = GraphicsManager.ScreenWidth - 32 - 40, 16
    local w, h = 38+GraphicsManager.MenuBG.TileWidth*2, 34 + GraphicsManager.MenuBG.TileHeight*2
    self.portrait_box = RogueEssence.Menu.SummaryMenu(RogueElements.Rect.FromPoints(RogueElements.Loc(x, y), RogueElements.Loc(x+w, y+h)))
    local id = RogueEssence.Dungeon.MonsterID.Invalid
    local emote = RogueEssence.Content.EmoteStyle(0)
    local loc = RogueElements.Loc(GraphicsManager.MenuBG.TileWidth-1,GraphicsManager.MenuBG.TileHeight-3)
    self.portrait = RogueEssence.Menu.SpeakerPortrait(id, emote, loc, false)
    self.portrait_box.Elements:Add(self.portrait)
end

--- Loads the characters that will be part of the menu.
--- @return table a table array of the characters in the assembly, sorted using the given sorting method.
function AssemblySelectMenu:load_chars(_)
    local list = {}

    self.assemblyIndexes = self:getSortedAssembly()
    for char in luanet.each(LUA_ENGINE:MakeList(_DATA.Save.ActiveTeam.Players)) do table.insert(list, char) end
    for index = 1, #self.assemblyIndexes, 1 do
        local char = _DATA.Save.ActiveTeam.Assembly[self.assemblyIndexes[index]]
        table.insert(list, char)
    end

    return list
end

function AssemblySelectMenu:getSortedAssembly()
    local sortedAssembly = {}
    for i = 0, _DATA.Save.ActiveTeam.Assembly.Count-1, 1 do
        table.insert(sortedAssembly, i)
    end
    table.sort(sortedAssembly, function(a, b) return self:assemblyCompare(a, b) end)
    return sortedAssembly
end

function AssemblySelectMenu:assemblyCompare(a, b)
    local assembly = _DATA.Save.ActiveTeam.Assembly

    local char_a = assembly[a]
    local char_b = assembly[b]
    if char_a.IsFavorite ~= char_b.IsFavorite then
        return char_a.IsFavorite
    end

    if self.sort_mode == RogueEssence.Menu.AssemblyMenu.AssemblySortMode.Level then
        return char_a.Level > char_b.Level
    elseif self.sort_mode == RogueEssence.Menu.AssemblyMenu.AssemblySortMode.Nickname then
        return char_a.BaseName < char_b.BaseName
    elseif self.sort_mode == RogueEssence.Menu.AssemblyMenu.AssemblySortMode.Species then
        local monster = RogueEssence.Data.DataManager.DataType.Monster
        local dex1 = _DATA.DataIndices[monster]:Get(char_a.BaseForm.Species).SortOrder
        local dex2 = _DATA.DataIndices[monster]:Get(char_b.BaseForm.Species).SortOrder
        return dex1 < dex2
    end

    return a < b
end

--- Processes the menu's properties and generates the ``RogueEssence.Menu.MenuElementChoice`` list that will be displayed.
--- @return table a list of ``RogueEssence.Menu.MenuElementChoice`` objects.
function AssemblySelectMenu:generate_options()
    local options = {}
    for i=1, #self.charList, 1 do
        local char = self.charList[i]
        local enabled = self.filter(char)
        local color = Color.White
        if i == _DATA.Save.ActiveTeam.LeaderIndex+1 then color = RogueEssence.Menu.MenuBase.TextIndigo
        elseif i<=_DATA.Save.ActiveTeam.Players.Count then color = Color.Lime
        elseif char.IsFavorite then color = Color.Yellow end
        if not enabled then color = Color.Red end

        local name = char.BaseName
        local level = char.Level
        local text_name = RogueEssence.Menu.MenuText(name, RogueElements.Loc(2, 1), color)
        local text_lv_label = RogueEssence.Menu.MenuText(STRINGS:FormatKey("MENU_TEAM_LEVEL_SHORT"), RogueElements.Loc(self.menuWidth - 8 * 7 + 6, 1), RogueElements.DirV.Up, RogueElements.DirH.Right, color)
        local text_level = RogueEssence.Menu.MenuText(tostring(level), RogueElements.Loc(self.menuWidth - 8 * 4, 1), RogueElements.DirV.Up, RogueElements.DirH.Right, color)
        local option = RogueEssence.Menu.MenuElementChoice(function() self:choose(i) end, enabled, text_name, text_lv_label, text_level)
        table.insert(options, option)
    end
    return options
end

--- Summons a ``TeamSelectSubMenu`` with the provided callback.
--- @param callback function the function that will be called by the menu upon running confirm or cancel operations. It will have a boolean passed as a parameter.
function AssemblySelectMenu:callSubMenu(callback)
    _MENU:AddMenu(AssemblySelectSubMenu:new(self, function() callback(true) end, function() callback(false) end).menu, true)
end

--- Uses the current input to apply changes to the menu.
--- @param input userdata the ``RogueEssense.InputManager``.
function AssemblySelectMenu:updateFunction(input)
    if input:JustPressed(RogueEssence.FrameInput.InputType.SortItems) then
        _GAME:SE("Menu/Sort")
        local new_mode = self.int_to_mode[(self.mode_to_int[self.sort_mode]+1)%4]
        local new_menu = self:cloneMenu(new_mode)
        _MENU:ReplaceMenu(new_menu.menu)
        new_menu.menu:SetCurrentPage(self.menu.CurrentPage)
        new_menu.menu.CurrentChoice = self.menu.CurrentChoice
        new_menu:updateSummary()
    end
end

--- Returns a newly created copy of this object with the provided ``RogueEssence.Menu.AssemblyMenu.AssemblySortMode``
--- @param new_mode userdata the ``RogueEssence.Menu.AssemblyMenu.AssemblySortMode`` to be applied
--- @return table an ``AssemblySelectMenu``.
function AssemblySelectMenu:cloneMenu(new_mode)
    return AssemblySelectMenu:new(self.filter, self.confirmAction, self.refuseAction, self.use_submenu, self.menuWidth, new_mode)
end

--- Updates the portrait and the summary window.
function AssemblySelectMenu:updateSummary()
    TeamSelectMenu.updateSummary(self)
    self.portrait.Speaker = self.charList[self.menu.CurrentChoiceTotal+1].BaseForm
end

-------------------------------------------------------------------------------------------
--- Menu for selecting one or more characters from the assembly.
AssemblyMultiSelectMenu = Class("AssemblyMultiSelectMenu", AssemblySelectMenu)
-------------------------------------------------------------------------------------------

--- Creates a new ``AssemblyMultiSelectMenu`` instance using the provided list and callbacks.
--- @param filter function a function that takes a ``RogueEssence.Dungeon.Character`` object and returns a boolean. Any character that does not pass this check will have its option disabled in the menu. Defaults to ``return true``.
--- @param confirm_action function the function called when a slot is chosen. It will have a ``RogueEssence.Dungeon.Character`` passed to it as a parameter.
--- @param refuse_action function the function called when the player presses the cancel or menu button.
--- @param use_submenu boolean whether or not to call the ``AssemblySelectSubMenu`` before returning. Defaults to true.
--- @param menu_width number the width of this window. Default is 160.
--- @param sort_mode userdata a ``RogueEssence.Menu.AssemblyMenu.AssemblySortMode`` object. defaults to ``Recent``
function AssemblyMultiSelectMenu:initialize(filter, confirm_action, refuse_action, use_submenu, menu_width, sort_mode)
    self.multiConfirmAction = function(list)
        self.choice = self:multiConfirm(list)
        self.confirmAction(self.choice)
    end
    AssemblySelectMenu.initialize(self, filter, confirm_action, refuse_action, use_submenu, menu_width, sort_mode)
end

--- Performs the final adjustments and creates the actual menu object.
function AssemblyMultiSelectMenu:createMenu()
    self.MAX_ELEMENTS = 6

    local valid = self:count_valid()
    local origin = RogueElements.Loc(16,16)
    local option_array = luanet.make_array(RogueEssence.Menu.MenuElementChoice, self.optionsList)
    self.menu = RogueEssence.Menu.ScriptableMultiPageMenu(origin, self.menuWidth, self.title, option_array, 0, self.MAX_ELEMENTS, self.refuseAction, self.refuseAction, true, valid, self.multiConfirmAction)
    self.menu.ChoiceChangedFunction = function() self:updateSummary() end
end

--- Counts the number of valid options generated.
--- @return number the number of valid options.
function AssemblyMultiSelectMenu:count_valid()
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
function AssemblyMultiSelectMenu:choose(index)
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
function AssemblyMultiSelectMenu:multiConfirm(list)
    local result = {}
    for _, index in pairs(list) do
        local char = self.charList[index+1]
        table.insert(result, char)
    end
    return result
end

--- Returns a newly created copy of this object with the provided ``RogueEssence.Menu.AssemblyMenu.AssemblySortMode``
--- @param new_mode userdata the ``RogueEssence.Menu.AssemblyMenu.AssemblySortMode`` to be applied
--- @return table an ``AssemblyMultiSelectMenu``.
function AssemblyMultiSelectMenu:cloneMenu(new_mode)
    local selected_team, selected = self:saveSelectedMembers()
    local new_menu = AssemblyMultiSelectMenu:new(self.filter, self.confirmAction, self.refuseAction, self.use_submenu, self.menuWidth, new_mode)
    new_menu:loadSelectedMembers(selected_team, selected)
    return new_menu
end

--- Takes the currently selected assembly and team indexes and stores them in lists.
--- @return table, table the list of selected team indexes, the list of selected assembly indexes
function AssemblyMultiSelectMenu:saveSelectedMembers()
    local selected = {}
    local selected_team = {}

    local num = _DATA.Save.ActiveTeam.Players.Count
    for index, option in pairs(self.optionsList) do
        if option.Selected then
            if index <= num then
                table.insert(selected_team, index)
            else
                local i = index - num
                table.insert(selected, self.assemblyIndexes[i])
            end
        end
    end
    return selected_team, selected
end

--- Takes a list of assembly indexes and selects the corresponding options.
--- @param selected_team table a list of integer team indexes to be selected
--- @param selected table a list of integer assembly indexes to be selected
function AssemblyMultiSelectMenu:loadSelectedMembers(selected_team, selected)
    local num = _DATA.Save.ActiveTeam.Players.Count
    for _, index in pairs(selected_team) do
        self.optionsList[index]:SilentSelect(true)
    end
    for i=1, #self.assemblyIndexes, 1 do
        for pos, val in pairs(selected) do
            if val == self.assemblyIndexes[i] then
                table.remove(selected, pos)
                self.optionsList[i+num]:SilentSelect(true)
                break
            end
        end
    end
end

-------------------------------------------------------------------------------------------
--- Menu for choosing what to do with the chosen character. Assembly menu version.
AssemblySelectSubMenu = Class("AssemblySelectSubMenu", TeamSelectSubMenu)
-------------------------------------------------------------------------------------------

--- Creates a new ``AssemblySelectSubMenu`` instance using the provided data and callbacks.
--- @param parent table an ``AssemblySelectMenu``
--- @param confirm_action function the function called when the first option is pressed.
--- @param refuse_action function the function called when the third option or the cancel or menu buttons are pressed.
function AssemblySelectSubMenu:initialize(parent, confirm_action, refuse_action)
    TeamSelectSubMenu.initialize(self, parent, confirm_action, refuse_action)
end

--- Opens the ``RogueEssence.Menu.MemberFeaturesMenu`` of the character selected in the parent menu.
function AssemblySelectSubMenu:openSummary()
    local choice = self.parent.menu.CurrentChoiceTotal
    local index_list = self.parent.assemblyIndexes
    local team_tail_id = _DATA.Save.ActiveTeam.Players.Count-1
    local is_assembly = false
    local index = choice
    if choice > team_tail_id then
        is_assembly = true
        index = index_list[choice - team_tail_id]
    end
    _MENU:AddMenu(RogueEssence.Menu.MemberFeaturesMenu(index, is_assembly, _DATA.Save.ActiveTeam.Assembly.Count > 0), false)
end








--- Creates a basic ``TeamSelectMenu`` instance using the provided list and callbacks, then runs it and returns its output.
--- @param filter function a function that takes a ``RogueEssence.Dungeon.Character`` object and returns a boolean. Any character that does not pass this check will have its option disabled in the menu. Defaults to ``return true``.
--- @param use_submenu boolean whether or not to call the ``AssemblySelectSubMenu`` before returning. Defaults to true.
--- @return userdata the selected character if one was chosen in the menu; ``nil`` otherwise.
function AssemblySelectMenu.run(filter, use_submenu)
    local ret
    local choose = function(char)
        ret = char
        _MENU:RemoveMenu()
    end
    local refuse = function() _MENU:RemoveMenu() end
    local menu = AssemblySelectMenu:new(filter, choose, refuse, use_submenu)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
    return ret
end


--- Creates a basic ``TeamMultiSelectMenu`` instance using the provided list and callbacks, then runs it and returns its output.
--- @param filter function a function that takes a ``RogueEssence.Dungeon.Character`` object and returns a boolean. Any character that does not pass this check will have its option disabled in the menu. Defaults to ``return true``.
--- @param use_submenu boolean whether or not to call the ``AssemblySelectSubMenu`` before returning. Defaults to true. Only appears if a character is chosen without selecting.
--- @return table the list of selected characters if at least one was chosen in the menu; ``nil`` otherwise.
function AssemblyMultiSelectMenu.runMultiMenu(filter, use_submenu)
    local ret = {}

    local choose = function(chars)
        ret = chars
        _MENU:RemoveMenu()
    end

    local refuse = function() _MENU:RemoveMenu() end
    local menu = AssemblyMultiSelectMenu:new(filter, choose, refuse, use_submenu)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
    return ret
end
