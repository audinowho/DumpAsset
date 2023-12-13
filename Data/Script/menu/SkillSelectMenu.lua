--[[
    SkillSelectMenu
    lua port by MistressNebula

    Opens a menu with multiple pages that allows the player to select a skill.
    It contains a run method for quick instantiation, as well as a way to open
    an (almost) exact equivalent of UI:RelearnMenu.
    This equivalent is NOT SAFE FOR REPLAYS. Do not use in dungeons until further notice.
]]
require 'common'

--- Menu for selecting a skill from a specific list of skills.
SkillSelectMenu = Class("SkillSelectMenu")

--- Creates a new SkillSelectMenu instance using the provided list and callbacks.
--- This function throws an error if the parameter 'skill_list' contains less than 1 entries.
--- @param title string the title this window will have
--- @param character userdata the RogueEssence.Dungeon.Character object the chosen skill is to be applied to. Used only for charge display reasons. Can be nil
--- @param skill_list table an array, list or lua array table containing skill indices
--- @param confirm_action function the function called when a slot is chosen. It will have a skill id string passed to it as a parameter
--- @param refuse_action function the function called when the player presses the cancel or menu button
--- @param menu_width number the width of this window. Default is 152
function SkillSelectMenu:initialize(title, character, skill_list, confirm_action, refuse_action, menu_width)
    -- constants
    self.MAX_ELEMENTS = 5

    -- try to find a RogueEssence.Dungeon.Character
    local Character = luanet.import_type('RogueEssence.Dungeon.Character')
    -- if character exists and is not a RogueEssence.Dungeon.Character
    if character and LUA_ENGINE:TypeOf(character) ~= luanet.ctype(Character) then
        -- assume the object is actually a GroundChar or similar and try to fetch character.Data
        if character.Data and LUA_ENGINE:TypeOf(character.Data) == luanet.ctype(Character) then
            character = character.Data -- save object if class is right
        else
            character = nil -- give up if wrong
        end
    end

    -- loading parameters
    self.character = character
    self.confirmAction = confirm_action
    self.refuseAction = refuse_action
    self.menuWidth = menu_width or 152
    self.skillList, self.optionsList = self:load_skills(skill_list)

    self.choice = nil -- result

    if #self.skillList <1 then
        --abort if skill list is empty
        error("parameter 'skill_list' cannot be an empty collection")
    end

    -- creating the menu
    local origin = RogueElements.Loc(16,16)
    local option_array = luanet.make_array(RogueEssence.Menu.MenuElementChoice, self.optionsList)
    self.menu = RogueEssence.Menu.ScriptableMultiPageMenu(origin, self.menuWidth, title, option_array, 0, self.MAX_ELEMENTS, refuse_action, refuse_action)
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
--- @param skills table an array, list or lua array table containing skill indices
--- @return table,table a standardized version of the indices list, the list of MenuElementChoice elements corresponding to the skill indices
function SkillSelectMenu:load_skills(skills)
    local skill_list = {}
    local options_list = {}

    if type(skills) == 'table' then
        for _, skill_id in pairs(skills) do
            table.insert(options_list, self:process_entry(skill_id, #skill_list+1))
            table.insert(skill_list, skill_id)
        end
    else
        for skill_id in luanet.each(LUA_ENGINE:MakeList(skills)) do
            table.insert(options_list, self:process_entry(skill_id, #skill_list+1))
            table.insert(skill_list, skill_id)
        end
    end
    return skill_list, options_list
end

--- Processes one specific skill id and turns it into a MenuElementChoice
--- @param skill_id string the id of the skill to process
--- @param index number the index of the skill in the list it will be inserted in
--- @return userdata the RogueEssence.Menu.MenuElementChoice associated to the skill id and index
function SkillSelectMenu:process_entry(skill_id, index)
    local skill = _DATA:GetSkill(skill_id)
    local skill_name = skill:GetColoredName()
    local max_charges = skill.BaseCharges
    if self.character then max_charges = max_charges + self.character.ChargeBoost end
    local skill_charges = max_charges.."/"..max_charges
    local text_skill = RogueEssence.Menu.MenuText(skill_name, RogueElements.Loc(2, 1))
    local text_charges = RogueEssence.Menu.MenuText(skill_charges, RogueElements.Loc(self.menuWidth - 8 * 4, 1), RogueElements.DirH.Right)
    return RogueEssence.Menu.MenuElementChoice(function() self:choose(index) end, true, text_skill, text_charges)
end

--- Closes the menu and calls the menu's confirmation callback.
--- The result must be retrieved by accessing the choice variable of this object, which will hold
--- the string id of the chosen skill.
--- @param index number the index of the chosen skill
function SkillSelectMenu:choose(index)
    self.choice = self.skillList[index]
    _MENU:RemoveMenu()
    self.confirmAction(self.choice)
end

--- Updates the summary menu.
function SkillSelectMenu:updateSummary()
    self.summary:SetSkill(self.skillList[self.menu.CurrentChoiceTotal+1])
end


--- Creates a basic SkillSelectMenu instance using the provided list and callbacks, then runs it and returns its output.
--- @param title string the title this window will have
--- @param character userdata the RogueEssence.Dungeon.Character object the chosen skill is to be applied to. Used only for charge display reasons. Can be nil
--- @param skill_list table an array, list or lua array table containing skill indices
--- @return string the id of the selected skill if one was chosen in the menu; "" otherwise
function SkillSelectMenu.run(title, character, skill_list)
    local ret = ""
    local choose = function(move) ret = move end
    local refuse = function() _MENU:RemoveMenu() end
    local menu = SkillSelectMenu:new(title, character, skill_list, choose, refuse)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
    return ret
end

--- Creates a SkillSelectMenu instance that allows a choice between the character's relearnable moves, then runs it and returns its output.
--- This function throws an error if the parameter 'chara' is not valid.
--- @param chara userdata the RogueEssence.Dungeon.Character object the chosen skill is to be applied to
--- @return string the id of the selected skill if one was chosen in the menu; "" otherwise or if 'chara' was invalid
function SkillSelectMenu.runRelearnMenu(chara)

    local forgottenSkills = chara:GetRelearnableSkills(true)

    return SkillSelectMenu.run(STRINGS:FormatKey("MENU_SKILL_RECALL"), chara, forgottenSkills)
end


function SkillSelectMenu.runTutorMenu(chara, tutor_moves)
	
	local valid_moves = COMMON.GetTutorableMoves(chara, tutor_moves)
	
	--TODO: Allow the list to show the cost in heart scales

    local tutor_skills = {}
	for move_idx, skill in pairs(valid_moves) do
		table.insert(tutor_skills, move_idx)
	end

    return SkillSelectMenu.run(RogueEssence.StringKey("MENU_SKILL_TUTOR"):ToLocal(), chara, tutor_skills)
end