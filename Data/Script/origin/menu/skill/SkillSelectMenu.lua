--[[
    SkillSelectMenu
    lua port by MistressNebula

    Opens a menu with multiple pages that allows the player to select a skill.
    It contains a run method for quick instantiation, as well as a way to open
    an (almost) exact equivalent of UI:RelearnMenu.
    This equivalent is NOT SAFE FOR REPLAYS. Do NOT use in dungeons until further notice.
]]
require 'origin.common'

--- Menu for selecting a skill from a specific list of skills.
SkillSelectMenu = Class("SkillSelectMenu")

--- Creates a new ``SkillSelectMenu`` instance using the provided list and callbacks.
--- This function throws an error if the parameter ``skill_list`` contains less than 1 entries.
--- @param title string the title this window will have.
--- @param character userdata the ``RogueEssence.Dungeon.Character`` object the chosen skill is to be applied to. Used only for charge display reasons. Can be nil.
--- @param skill_list table an array, list or lua array table containing skill indices.
--- @param confirm_action function the function called when a slot is chosen. It will have a skill id string passed to it as a parameter.
--- @param refuse_action function the function called when the player presses the cancel or menu button.
--- @param menu_width number the width of this window. Default is 152.
--- @param label string the label that will be applied to this menu. Defaults to "SKILL_SELECT_MENU_LUA"
function SkillSelectMenu:initialize(title, character, skill_list, confirm_action, refuse_action, menu_width, label)
    -- param validity check
    local len = 0
    if type(skill_list) == 'table' then len = #skill_list else len = skill_list.Count end
    if len <1 then
        --abort if skill list is empty
        error("parameter 'skill_list' cannot be an empty collection")
    end

    -- constants
    self.MAX_ELEMENTS = 5

    -- parsing data
    self.character = character
    self.confirmAction = confirm_action
    self.refuseAction = refuse_action
    self.menuWidth = menu_width or 152
    self.skillList = self:load_skills(skill_list)
    self.optionsList = self:generate_options()
    label = label or "SKILL_SELECT_MENU_LUA"

    self.choice = nil -- result

    -- creating the menu
    local origin = RogueElements.Loc(16,16)
    local option_array = luanet.make_array(RogueEssence.Menu.MenuElementChoice, self.optionsList)
    self.menu = RogueEssence.Menu.ScriptableMultiPageMenu(label, origin, self.menuWidth, title, option_array, 0, self.MAX_ELEMENTS, refuse_action, refuse_action)
    self.menu.ChoiceChangedFunction = function() self:updateSummary() end

    -- creating the summary window
    local GraphicsManager = RogueEssence.Content.GraphicsManager
    self.summary = RogueEssence.Menu.SkillSummary(RogueElements.Rect.FromPoints(RogueElements.Loc(16,
            GraphicsManager.ScreenHeight - 8 - GraphicsManager.MenuBG.TileHeight * 2 - 12 * 2 - 14 * 4), --LINE_HEIGHT = 12, VERT_SPACE = 14
            RogueElements.Loc(GraphicsManager.ScreenWidth - 16, GraphicsManager.ScreenHeight - 8)))
    self.menu.SummaryMenus:Add(self.summary)
    self:updateSummary()
end

--- Loads the skills that will be part of the menu.
--- @param skill_list table an array, list or lua array table containing skill indices
--- @return table a standardized version of the skill list
function SkillSelectMenu:load_skills(skill_list)
    local list = {}

    if type(skill_list) == 'table' then
        for _, skill_id in pairs(skill_list) do table.insert(list, skill_id) end
    else
        for skill_id in luanet.each(LUA_ENGINE:MakeList(skill_list)) do table.insert(list, skill_id) end
    end
    return list
end

--- Processes the menu's properties and generates the ``RogueEssence.Menu.MenuElementChoice`` list that will be displayed.
--- @return table a list of ``RogueEssence.Menu.MenuElementChoice`` objects.
function SkillSelectMenu:generate_options()
    local options = {}
    for i=1, #self.skillList, 1 do
        local skill = _DATA:GetSkill(self.skillList[i])
        local max_charges = skill.BaseCharges
        if self.character then max_charges = max_charges + self.character.ChargeBoost end
        local skill_charges = max_charges.."/"..max_charges
        local text_skill = RogueEssence.Menu.MenuText(skill:GetColoredName(), RogueElements.Loc(2, 1))
        local text_charges = RogueEssence.Menu.MenuText(skill_charges, RogueElements.Loc(self.menuWidth - 8 * 4, 1), RogueElements.DirH.Right)
        local option = RogueEssence.Menu.MenuElementChoice(function() self:choose(i) end, true, text_skill, text_charges)
        table.insert(options, option)
    end
    return options
end

--- Closes the menu and calls the menu's confirmation callback.
--- The result must be retrieved by accessing the choice variable of this object, which will hold
--- the string id of the chosen skill.
--- @param index number the index of the chosen skill.
function SkillSelectMenu:choose(index)
    self.choice = self.skillList[index]
    _MENU:RemoveMenu()
    self.confirmAction(self.choice)
end

--- Updates the summary window.
function SkillSelectMenu:updateSummary()
    self.summary:SetSkill(self.skillList[self.menu.CurrentChoiceTotal+1])
end




--- Creates a basic ``SkillSelectMenu`` instance using the provided list and callbacks, then runs it and returns its output.
--- @param title string the title this window will have
--- @param character userdata the ``RogueEssence.Dungeon.Character`` object the chosen skill is to be applied to. Used only for charge display reasons. Can be ``nil``.
--- @param skill_list table an array, list or lua array table containing skill indices.
--- @return string the id of the selected skill if one was chosen in the menu; ``""`` otherwise.
function SkillSelectMenu.run(title, character, skill_list)
    local ret = ""
    local choose = function(move) ret = move end
    local refuse = function() _MENU:RemoveMenu() end
    local menu = SkillSelectMenu:new(title, character, skill_list, choose, refuse)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
    return ret
end

--- Creates a ``SkillSelectMenu`` instance that allows a choice between the character's relearnable moves, then runs it and returns its output.
--- This function throws an error if the parameter ``chara`` is not valid.
--- @param chara userdata the RogueEssence.Dungeon.Character object the chosen skill is to be applied to
--- @return string the id of the selected skill if one was chosen in the menu; ``""`` otherwise
function SkillSelectMenu.runRelearnMenu(chara)

    local forgottenSkills = chara:GetRelearnableSkills(true)

    return SkillSelectMenu.run(STRINGS:FormatKey("MENU_SKILL_RECALL"), chara, forgottenSkills)
end