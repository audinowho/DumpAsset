--[[
    InventorySelectMenu
    lua port by MistressNebula

    Opens a menu, potentially with multiple pages, that allows the player to select one or
    more items in their inventory.
    It contains a run method for quick instantiation.
    This equivalent is NOT SAFE FOR REPLAYS. Do NOT use in dungeons until further notice.
]]


--- Menu for selecting items from the player's inventory.
InventorySelectMenu = Class("InventorySelectMenu")

--- Creates a new ``InventorySelectMenu`` instance using the provided list and callbacks.
--- @param title string the title this window will have.
--- @param filter function a function that takes a ``RogueEssence.Dungeon.InvSlot`` object and returns a boolean. Any slot that does not pass this check will have its option disabled in the menu. Defaults to ``return true``.
--- @param confirm_action function the function called when the selection is confirmed. It will have a table array of ``RogueEssence.Dungeon.InvSlot`` objects passed to it as a parameter.
--- @param refuse_action function the function called when the player presses the cancel or menu button.
--- @param menu_width number the width of this window. Default is 176.
--- @param include_equips boolean if true, the menu will include equipped items.
function InventorySelectMenu:initialize(title, filter, confirm_action, refuse_action, menu_width, include_equips)
    if include_equips == nil then include_equips = true end

    -- constants
    self.MAX_ELEMENTS = 8

    -- parsing data
    self.confirmAction = confirm_action
    self.refuseAction = refuse_action
    self.menuWidth = menu_width or 176
    self.filter = filter or function(_) return true end
    self.includeEquips = include_equips
    self.slotList = self:load_slots()
    self.optionsList = self:generate_options()
    self.max_choices = self:count_valid()

    self.multiConfirmAction = function(list)
        _MENU:RemoveMenu()
        self.confirmAction(self:multiConfirm(list))
    end

    self.choices = {} -- result

    -- creating the menu
    local origin = RogueElements.Loc(16,16)
    local option_array = luanet.make_array(RogueEssence.Menu.MenuElementChoice, self.optionsList)
    self.menu = RogueEssence.Menu.ScriptableMultiPageMenu(origin, self.menuWidth, title, option_array, 0, self.MAX_ELEMENTS, refuse_action, refuse_action, false, self.max_choices, self.multiConfirmAction)
    self.menu.ChoiceChangedFunction = function() self:updateSummary() end
	self.menu.MultiSelectChangedFunction = function() self:updateSummary() end

    -- create the summary window
    local GraphicsManager = RogueEssence.Content.GraphicsManager

    self.summary = RogueEssence.Menu.ItemSummary(RogueElements.Rect.FromPoints(
            RogueElements.Loc(16, GraphicsManager.ScreenHeight - 8 - GraphicsManager.MenuBG.TileHeight * 2 - 14 * 4), --LINE_HEIGHT = 12, VERT_SPACE = 14
            RogueElements.Loc(GraphicsManager.ScreenWidth - 16, GraphicsManager.ScreenHeight - 8)))
    self.menu.SummaryMenus:Add(self.summary)
    self:updateSummary()
end

--- Loads the item slots that will be part of the menu.
--- @return table a standardized version of the item list
function InventorySelectMenu:load_slots()
    local list = {}

    if self.includeEquips then
        -- add equipped items
        local chars = _DATA.Save.ActiveTeam.Players
        for i=0, chars.Count-1, 1 do
            local char = chars[i]
            if char.EquippedItem.ID and char.EquippedItem.ID ~= "" then
                local entry = RogueEssence.Dungeon.InvSlot(true, i)
                table.insert(list, entry)
            end
        end
    end
    -- add rest of inventory
    for i=0, _DATA.Save.ActiveTeam:GetInvCount()-1, 1 do
        local entry = RogueEssence.Dungeon.InvSlot(false, i)
        table.insert(list, entry)
    end
    return list
end

--- Processes the menu's properties and generates the ``RogueEssence.Menu.MenuElementChoice`` list that will be displayed.
--- @return table a list of ``RogueEssence.Menu.MenuElementChoice`` objects.
function InventorySelectMenu:generate_options()
    local options = {}
    for i=1, #self.slotList, 1 do
        local slot = self.slotList[i]
        local enabled = self.filter(slot)
        local item, equip_id = nil, nil
        if slot.IsEquipped then
            equip_id = slot.Slot
            item = _DATA.Save.ActiveTeam.Players[equip_id].EquippedItem
        else
            item = _DATA.Save.ActiveTeam:GetInv(slot.Slot)
        end
        local color = Color.White
        if not enabled then color = Color.Red end

        local name = item:GetDisplayName()
        if equip_id then name = tostring(equip_id+1)..": "..name end
        local text_name = RogueEssence.Menu.MenuText(name, RogueElements.Loc(2, 1), color)
        local option = RogueEssence.Menu.MenuElementChoice(function() self:choose(i) end, enabled, text_name)
        table.insert(options, option)
    end
    return options
end

--- Counts the number of valid options generated.
--- @return number the number of valid options.
function InventorySelectMenu:count_valid()
    local count = 0
    for _, option in pairs(self.optionsList) do
        if option.Enabled then count = count+1 end
    end
    return count
end

--- Closes the menu and calls the menu's confirmation callback.
--- The result must be retrieved by accessing the choice variable of this object, which will hold
--- the chosen index as the single element of a table array.
--- @param index number the index of the chosen character, wrapped inside of a single element table array.
function InventorySelectMenu:choose(index)
    self.choices = {index-1}
    self.multiConfirmAction(self.choices)
end

--- Updates the summary window.
function InventorySelectMenu:updateSummary()
    self.summary:SetItem(_DATA.Save.ActiveTeam:GetInv(self.slotList[self.menu.CurrentChoiceTotal+1].Slot))
end

--- Extract the list of selected slots.
--- @param list table a table array containing the menu indexes of the chosen items.
--- @return table a table array containing ``RogueEssence.Dungeon.InvSlot`` objects.
function InventorySelectMenu:multiConfirm(list)
    local result = {}
    for _, index in pairs(list) do
        local inv_slot = self.slotList[index+1]
        PrintInfo(tostring(inv_slot.IsEquipped).."\t"..tostring(inv_slot.Slot))
        table.insert(result, inv_slot)
    end
    return result
end




--- Creates a basic ``InventorySelectMenu`` instance using the provided parameters, then runs it and returns its output.
--- @param title string the title this window will have
--- @param filter function a function that takes a ``RogueEssence.Dungeon.InvSlot`` object and returns a boolean. Any ``InvSlot`` that does not pass this check will have its option disabled in the menu. Defaults to ``return true``.
--- @param includeEquips boolean if true, the party's equipped items will be included in the menu. Defaults to true.
--- @return userdata a table array containing the chosen ``RogueEssence.Dungeon.InvSlot`` objects.
function InventorySelectMenu.run(title, filter, includeEquips)

    local ret = {}
    local choose = function(list) ret = list end
    local refuse = function() _MENU:RemoveMenu() end
    local menu = InventorySelectMenu:new(title, filter, choose, refuse, includeEquips)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
    return ret
end