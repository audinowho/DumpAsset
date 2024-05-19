--[[
    SpecialtiesMenu
    by MistressNebula

    Opens a menu, potentially with multiple pages, that allows the player to select one or
    more dishes and then the desired serving size.
    It contains a run method for quick instantiation.
    This menu is NOT SAFE FOR REPLAYS. Do NOT use in dungeons until further notice.
]]
require 'origin.common'
require 'origin.menu.DescriptionSummary'

---Menu for selecting a drink Specialty from a list of possible specialties.
SpecialtiesMenu = Class('SpecialtiesMenu')

--- Creates a new ``SpecialtiesMenu`` instance using the provided list and callbacks.
--- @param title string the title this window will have.
--- @param specialties table the specialties available in the menu. See ``ground.base_camp_2.base_camp_2_juice`` for format examples.
--- @param confirm_action function the function called when the selection is confirmed.
--- @param refuse_action function the function called when the player presses the cancel or menu button.
--- @param menu_width number the width of this window. Default is 152.
function SpecialtiesMenu:initialize(title, specialties, confirm_action, refuse_action, menu_width)
    -- constants
    self.MAX_ELEMENTS = 8

    -- parsing data
    self.confirmAction = confirm_action
    self.refuseAction = refuse_action
    self.menuWidth = menu_width or 152
    self.specialties = specialties
    self.optionsList = self:generate_options()

    self.choice = nil -- result

    -- creating the menu
    local origin = RogueElements.Loc(16,16)
    local option_array = luanet.make_array(RogueEssence.Menu.MenuElementChoice, self.optionsList)
    self.menu = RogueEssence.Menu.ScriptableMultiPageMenu(origin, self.menuWidth, title, option_array, 0, self.MAX_ELEMENTS, refuse_action, refuse_action, false)
    self.menu.ChoiceChangedFunction = function() self:updateSummary() end

    local GraphicsManager = RogueEssence.Content.GraphicsManager
    self.summary = DescriptionSummary:new(16, self.menu.Bounds.Bottom, GraphicsManager.ScreenWidth-16, GraphicsManager.ScreenHeight-16)
    self.menu.SummaryMenus:Add(self.summary.window)
    self:updateSummary()
end


--- Processes the menu's properties and generates the ``RogueEssence.Menu.MenuElementChoice`` list that will be displayed.
--- @return table a list of ``RogueEssence.Menu.MenuElementChoice`` objects.
function SpecialtiesMenu:generate_options()
    local options = {}
    for i=1, #self.specialties, 1 do
        local specialty = self.specialties[i]
        local name = "[color=#FFCEFF]"..specialty.Name.."[color]"
        local text_name = RogueEssence.Menu.MenuText(name, RogueElements.Loc(2, 1))
        local option = RogueEssence.Menu.MenuElementChoice(function() self:choose(i) end, true, text_name)
        table.insert(options, option)
    end
    return options
end

--- Summons the ServingSizes menu, providing it the necessary data. Then, if the sub-menu returns an output, it
--- closes this menu as well. The result must then be retrieved by accessing the choice variable of this object,
--- which will hold the table {Choice, Size} associated to the two selected options.
--- @param index number the index of the chosen option.
function SpecialtiesMenu:choose(index)
    local choice = self.specialties[index]
    local ret

    local callback = function(result)
        if result then
            self.choice = {Choice = index, Size = result}
            _MENU:RemoveMenu()
            self.confirmAction(self.choice)
        end
    end
    _MENU:AddMenu(ServingSizeMenu:new(choice.Sizes, callback, self.menu.Bounds.Right).menu, true)
end

--- Updates the summary window.
function SpecialtiesMenu:updateSummary()
    self.summary:setDescription(self.specialties[self.menu.CurrentChoiceTotal+1].Desc)
end


---Menu for selecting a Specialty's Serving Size from a list of possible sizes.
ServingSizeMenu = Class('ServingSizeMenu')

--- Creates a new ``ServingSizeMenu`` instance using the provided list and callbacks.
--- @param servings table a list of serving sizes. See ``ground.base_camp_2.base_camp_2_juice`` for format examples.
--- @param confirm_action function the function called when the selection is confirmed.
--- @param menu_x number the x coordinate of this window's origin point.
function ServingSizeMenu:initialize(servings, confirm_action, menu_x)
    -- constants
    self.MAX_ELEMENTS = 5
    if #servings < 5 then self.MAX_ELEMENTS = #servings end

    -- parsing data
    self.confirmAction = confirm_action
    self.refuseAction = function() _MENU:RemoveMenu() end
    self.menuX = menu_x
    self.servings = servings
    self.optionsList = self:generate_options()
    self.choice = nil -- result

    -- creating the menu
    local GraphicsManager = RogueEssence.Content.GraphicsManager

    local text_width = 0
    for _, elem in pairs(self.servings) do
        local elem_width = GraphicsManager.TextFont:SubstringWidth(elem.Name)
        if elem_width>text_width then text_width=elem_width end
    end

    --clamp width between half and full space available
    local snapWidth = RogueEssence.Content.GraphicsManager.ScreenWidth - 16 - self.menuX
    local menuWidth = math.max(math.ceil(snapWidth/2),text_width + GraphicsManager.MenuBG.TileWidth*4+11)
    if menuWidth + GraphicsManager.MenuBG.TileWidth > snapWidth then menuWidth = snapWidth end --slight menu border width sized snapping

    local menuY = 16 + 14*(8-self.MAX_ELEMENTS)
    local origin = RogueElements.Loc(self.menuX, menuY)
    local option_array = luanet.make_array(RogueEssence.Menu.MenuElementChoice, self.optionsList)
    self.menu = RogueEssence.Menu.ScriptableMultiPageMenu(origin, menuWidth, "Sizes", option_array, 0, self.MAX_ELEMENTS, self.refuseAction, self.refuseAction, false)
    self.menu.ChoiceChangedFunction = function() self:updateSummary() end

    self.summary = DescriptionSummary:new(16, self.menu.Bounds.Bottom, GraphicsManager.ScreenWidth-16, GraphicsManager.ScreenHeight-16)
    self.menu.SummaryMenus:Add(self.summary.window)
    self:updateSummary()
end


--- Processes the menu's properties and generates the ``RogueEssence.Menu.MenuElementChoice`` list that will be displayed.
--- @return table a list of ``RogueEssence.Menu.MenuElementChoice`` objects.
function ServingSizeMenu:generate_options()
    local options = {}
    for i=1, #self.servings, 1 do
        local serving = self.servings[i]
        local name = "[color=#FFCEFF]"..serving.Name.."[color]"
        local text_name = RogueEssence.Menu.MenuText(name, RogueElements.Loc(2, 1))
        local option = RogueEssence.Menu.MenuElementChoice(function() self:choose(i) end, true, text_name)
        table.insert(options, option)
    end
    return options
end

--- Closes the menu and calls the menu's confirmation callback.
--- The result must be retrieved by accessing the choice variable of this object, which will hold
--- the index of the chosen serving size.
--- @param index number the index of the chosen option.
function ServingSizeMenu:choose(index)
    self.choice = index
    _MENU:RemoveMenu()
    self.confirmAction(index)
end

--- Updates the summary window.
function ServingSizeMenu:updateSummary()
    self.summary:setDescription(self.servings[self.menu.CurrentChoiceTotal+1].Desc)
end






--- Creates a ``SpecialtiesMenu`` instance using the provided parameters, then runs it and returns its output.
--- @param title string the title this window will have
--- @param specialties table the specialties available in the menu. link example here.
--- @return table a table in the form of ``{Choice, Size}``. Choice is the index of the selected specialty; Size is the index of the selected serving size.
function SpecialtiesMenu.run(title, specialties)
    local ret = nil
    local choose = function(result) ret = result end
    local refuse = function() _MENU:RemoveMenu() end
    local menu = SpecialtiesMenu:new(title, specialties, choose, refuse)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
    return ret
end