--[[
    WithdrawMenu
    lua port by MistressNebula

    Opens a menu, potentially with multiple pages, that allows the player to select one or
    more items in their inventory.
    It contains a run method for quick instantiation and an WithdrawChosenMenu port for confirmation.
    This equivalent is NOT SAFE FOR REPLAYS. Do NOT use in dungeons until further notice.
]]

local EquipStateType = luanet.import_type('PMDC.Dungeon.EquipState')
local EdibleStateType = luanet.import_type('PMDC.Dungeon.EdibleState')
local OrbStateType = luanet.import_type('PMDC.Dungeon.OrbState')
local WandStateType = luanet.import_type('PMDC.Dungeon.WandState')
local ExclusiveStateType = luanet.import_type('PMDC.Dungeon.ExclusiveState')
local item_index = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Item]
local UseTypes = RogueEssence.Data.ItemData.UseType

local hasState = function(item_summary, stateType)
    return item_summary:ContainsState(luanet.ctype(stateType))
end

--- Menu for selecting items from the player's inventory.
WithdrawMenu = Class("WithdrawMenu")

--- List of filters that can be used to find specific items more easily.
--- Every filter's function takes an ItemSummary as input and must return a boolean.
--- Filters with no function will display items that don't belong to any other filter.
WithdrawMenu.Filters = {
    {Key = "MENU_FILTER_EQUIP", Predicate = function(item) return hasState(item, EquipStateType) end},
    {Key = "MENU_FILTER_THROW", Predicate = function(item) return item.UsageType == UseTypes.Throw end},
    {Key = "MENU_FILTER_FOOD",  Predicate = function(item) return hasState(item, EdibleStateType) end},
    {Key = "MENU_FILTER_TM",    Predicate = function(item) return item.UsageType == UseTypes.Learn end},
    {Key = "MENU_FILTER_TOOLS", Predicate = function(item) return hasState(item, OrbStateType) or hasState(item, WandStateType) end},
    {Key = "MENU_FILTER_OTHER"},
    {Key = "MENU_FILTER_EXCL",  Predicate = function(item) return hasState(item, ExclusiveStateType) end},
    {Key = "MENU_FILTER_BOXES", Predicate = function(item) return item.UsageType == UseTypes.Box end}
}

--- Creates a new ``WithdrawMenu`` instance using the provided list and callbacks.
--- @param defaultChoice number the choice that will be selected by default, counting from 0.
--- @param continueOnChoose boolean if true, the menu will not be closed after selecting a target.
--- @param filter_index number the index of the filter to load by default, counting from 1. 0 corresponds to the full unfiltered list. Defaults to 0.
function WithdrawMenu:initialize(defaultChoice, continueOnChoose, filter_index)
    -- constants
    self.MAX_ELEMENTS = 8

    -- preparing data
    self.title = STRINGS:FormatKey("MENU_STORAGE_TITLE")
    self.continueOnChoose = continueOnChoose
    self.currentFilter = math.min(math.max(0, filter_index or 0), #WithdrawMenu.Filters)
    self.refuseAction = function() _MENU:RemoveMenu() end
    self.menuWidth = RogueEssence.Menu.ItemMenu.ITEM_MENU_WIDTH
    self:generate_options()
    self.currentOptions = {}
    self.currentSlots = {}
    self.filterFlags = {}
    self:MakeCurrentFilteredLists()
    if #self.currentOptions<=0 then --TODO understand why this isn't firing
        self.currentFilter = 0
        self:MakeCurrentFilteredLists()
    end
    self.max_choices = self:count_valid()
    defaultChoice = math.min(math.max(0, defaultChoice), #self.currentOptions-1)
    self.label = "WITHDRAW_MENU_LUA"

    self.multiConfirmAction = function(list)
        local slots = {}
        for _, idx in ipairs(list) do
            table.insert(slots, self.currentSlots[idx+1])
        end
        local menu = WithdrawChosenMenu:new(slots, self, self.continueOnChoose)
        _MENU:AddMenu(menu.menu, true)
    end

    local GraphicsManager = RogueEssence.Content.GraphicsManager
    -- creating the menu
    local origin = RogueElements.Loc(16, 16)
    local option_array = luanet.make_array(RogueEssence.Menu.MenuChoice, self.currentOptions)
    self.menu = RogueEssence.Menu.ScriptableMultiPageMenu(label, origin, self.menuWidth, self.title, option_array, defaultChoice, self.MAX_ELEMENTS, self.refuseAction, self.refuseAction, false, self.max_choices, self.multiConfirmAction)
    self.menu.ChoiceChangedFunction = function() self:updateSummary() end
	self.menu.MultiSelectChangedFunction = function() self:Deselect() end
    self.menu.UpdateFunction = function(input) self:updateFunction(input) end

    -- create the summary window
    self.summary = RogueEssence.Menu.ItemSummary(RogueElements.Rect.FromPoints(
            RogueElements.Loc(16, GraphicsManager.ScreenHeight - 8 - GraphicsManager.MenuBG.TileHeight * 2 - RogueEssence.Menu.MenuBase.VERT_SPACE * 4),
            RogueElements.Loc(GraphicsManager.ScreenWidth - 16, GraphicsManager.ScreenHeight - 8)))
    self.menu.SummaryMenus:Add(self.summary)
    self:updateSummary()
end

--- Processes the menu's properties and generates the ``RogueEssence.Menu.MenuElementChoice`` list that will be displayed.
function WithdrawMenu:generate_options()
    local sortedKeys = item_index:GetOrderedKeys(true)
    self.slots_list = {}
    self.options_list = {}
    self.filtered_indices = {}
    for i = 1,#WithdrawMenu.Filters, 1 do
        if WithdrawMenu.Filters[i].Predicate then
            self.filtered_indices[i] = {}
        end
    end
    self.filtered_indices[0] = {}
    self.filtered_indices[-1] = {}

    local num_entries = 0

    -- add storage in sort order
    for id in luanet.each(sortedKeys) do
        local qty = GAME:GetPlayerStorageItemCount(id)
        if qty > 0 then
            local item_data = item_index:Get(id)
            local slot = RogueEssence.Dungeon.WithdrawSlot(false, id, 0)
            local menuText = RogueEssence.Menu.MenuText(item_data:GetIconName(), RogueElements.Loc(2, 1))
            local menuCount = RogueEssence.Menu.MenuText("("..qty..")", RogueElements.Loc(RogueEssence.Menu.ItemMenu.ITEM_MENU_WIDTH - 8 * 4, 1), RogueElements.DirV.Up, RogueElements.DirH.Right, Color.White)
            local menuChoice = RogueEssence.Menu.MenuElementChoice(function() self:choose() end, true, menuText, menuCount)
            table.insert(self.options_list, menuChoice)
            table.insert(self.slots_list, slot)
            num_entries = num_entries + 1
            
            local in_other = true
            for i = 1, #WithdrawMenu.Filters, 1 do
                if WithdrawMenu.Filters[i].Predicate and WithdrawMenu.Filters[i].Predicate(item_data) then
                    self.filtered_indices[i][num_entries] = true
                    in_other = false
                end
            end
            if in_other then
                self.filtered_indices[-1][num_entries] = true
            end
            self.filtered_indices[0][num_entries] = true
        end
    end

    -- add boxes
    for i = 0, _DATA.Save.ActiveTeam.BoxStorage.Count-1, 1 do
        local slot = RogueEssence.Dungeon.WithdrawSlot(true, "", i)
        local boxId = _DATA.Save.ActiveTeam.BoxStorage[i].ID
        local item_data = item_index:Get(boxId)
        local menuChoice = RogueEssence.Menu.MenuTextChoice(item_data:GetIconName(), function() self:choose(slot) end)
        table.insert(self.options_list, menuChoice)
        table.insert(self.slots_list, slot)
        num_entries = num_entries + 1

        local in_other = true
        for i = 1, #WithdrawMenu.Filters, 1 do
            if WithdrawMenu.Filters[i].Predicate and WithdrawMenu.Filters[i].Predicate(item_data) then
                    self.filtered_indices[i][num_entries] = true
                in_other = false
            end
        end
        if in_other then
            self.filtered_indices[-1][num_entries] = true
        end
        self.filtered_indices[0][num_entries] = true
    end
end

--- Counts the number of valid options generated.
--- @return number the number of valid options.
function WithdrawMenu:count_valid()
    if self.continueOnChoose then
        return _DATA.Save.ActiveTeam:GetMaxInvSlots(_ZONE.CurrentZone) - _DATA.Save.ActiveTeam:GetInvCount()
    else
        return -1
    end
end

--- Passes the currently hovered option index to the menu's confirmation callback.
function WithdrawMenu:choose()
    self.multiConfirmAction({self.menu.CurrentChoiceTotal})
end

--- Uses the current input to apply changes to the menu.
--- @param input userdata the ``RogueEssense.InputManager``.
function WithdrawMenu:updateFunction(input)
    if input:JustPressed(RogueEssence.FrameInput.InputType.SortItems) then
        _GAME:SE("Menu/Skip")
        self:FilterCommand()
    end
end

--- Opens the filter menu.
function WithdrawMenu:FilterCommand()
    local menu = WithdrawFilterMenu:new(self, self.currentFilter)
    _MENU:AddMenu(menu.menu, true)
end

--- Removes a deselected option that doesn't fit the current filter
function WithdrawMenu:Deselect()
    local index = self.menu.CurrentChoiceTotal +1
    if not self.currentOptions[index].Selected and not self.filterFlags[index] then
        table.remove(self.currentOptions, index)
        table.remove(self.currentSlots, index)
        table.remove(self.filterFlags, index)
        self.menu:ImportChoices(luanet.make_array(RogueEssence.Menu.MenuChoice, self.currentOptions))
        self.menu:SetCurrentPage(self.menu.CurrentPage)
    end
    self:updateSummary()
end

--- Checks if the filter corresponding to the parameter has any entries.
--- @param index number the index of the filter to check
--- @return boolean true if the filter has entries, false otherwise
function WithdrawMenu:CanApplyFilter(index)
    local filter_index = -1
    if index == 0 or WithdrawMenu.Filters[index].Predicate then filter_index = index end
    for i, val in pairs(self.filtered_indices[filter_index]) do
        if val then return true end
    end
    return false
end

--- Applies the filter corresponding to the parameter.
--- @param index number the index of the filter to apply
--- @param reset_page boolean if true, sets the current page to 0, otherwise it just refreshes the current page. defaults to true.
function WithdrawMenu:ApplyFilter(index, reset_page)
    if index == self.currentFilter then return end
    if reset_page~=false then reset_page = true end
    if index < 0 or index > #WithdrawMenu.Filters then return end
    self.currentFilter = index
    self:MakeCurrentFilteredLists()
    self.menu:ImportChoices(luanet.make_array(RogueEssence.Menu.MenuChoice, self.currentOptions))
    if reset_page then self.menu:SetCurrentPage(0)
    else self.menu:SetCurrentPage(self.menu.CurrentPage) end
end

--- Updates the current lists and returns the resulting option list
--- @return table a list of ``RogueEssence.Dungeon.MenuChoice``
function WithdrawMenu:MakeCurrentFilteredLists()
    local filter_index = -1
    if self.currentFilter == 0 or WithdrawMenu.Filters[self.currentFilter].Predicate then filter_index = self.currentFilter end
    
    local options, slots, flags = {}, {}, {}
    for i, entry in ipairs(self.options_list) do
        local add, flag = false, true
        if self.filtered_indices[filter_index][i] then
            add = true
        elseif entry.Selected then
            add, flag = true, false
        end
        if add then
            table.insert(options, entry)
            table.insert(slots, self.slots_list[i])
            table.insert(flags, flag)
        end
    end
    self.currentOptions = options
    self.currentSlots = slots
    self.filterFlags = flags
end

--- Updates the summary window.
function WithdrawMenu:updateSummary()
    local slot = self.currentSlots[self.menu.CurrentChoiceTotal+1]
    if not slot.IsBox then
        self.summary:SetItem(RogueEssence.Dungeon.InvItem(slot.ItemID))
    else
        self.summary:SetItem(_DATA.Save.ActiveTeam.BoxStorage[slot.BoxSlot])
    end
end

--- Reinitializes this ``WithdrawMenu``, refreshing the instance's options and filter data.
function WithdrawMenu:reinitialize()
    -- regenerating data
    self:generate_options()
    if self:CanApplyFilter(self.currentFilter) then
        self:ApplyFilter(self.currentFilter, false)
    else
        self:ApplyFilter(0)
        self.menu:SetCurrentPage(0)
    end
    self.max_choices = self:count_valid()
end




WithdrawChosenMenu = Class("WithdrawChosenMenu")

--- Creates a new ``WithdrawChosenMenu`` instance using the provided object as parent.
--- @param slots table the list of selected WithdrawSlots
--- @param parent userdata the parent menu
--- @param continueOnChoose boolean if true, it will refresh the WithdrawMenu instead of closing it when an action is confirmed
function WithdrawChosenMenu:initialize(slots, parent, continueOnChoose)
    local x, y = parent.menu.Bounds.Right, parent.menu.Bounds.Top
    local width = 72
    local label = "WITHDRAW_CHOSEN_MENU_LUA"
    self.parent = parent
    self.slots = slots
    self.continueOnChoose = continueOnChoose
    if not slots[1].IsBox then
        self.first_item = RogueEssence.Dungeon.InvItem(slots[1].ItemID)
    else
        self.first_item = _DATA.Save.ActiveTeam.BoxStorage[slots[1].BoxSlot]
    end

    local options = {
        {STRINGS:FormatKey("MENU_ITEM_WITHDRAW"), true, function() self:confirm() end},
        {STRINGS:FormatKey("MENU_INFO"),          true, function() _MENU:AddMenu(RogueEssence.Menu.TeachInfoMenu(self.first_item.ID), false) end},
        {STRINGS:FormatKey("MENU_EXIT"),          true, function() _MENU:RemoveMenu() end}
    }
    if #slots>1 or item_index:Get(self.first_item.ID).UsageType ~= UseTypes.Learn then
        table.remove(options, 2)
    end

    self.menu = RogueEssence.Menu.ScriptableSingleStripMenu(label, x, y, width, options, 0, function() _MENU:RemoveMenu() end)
end

function WithdrawChosenMenu:confirm(result)
    _MENU:RemoveMenu()
    if #self.slots>1 then
        self:TakeItems(self.slots)
    else
        local selected = self.slots[1]
        if not self.continueOnChoose then
            local itemID
            if selected.IsBox then
                itemID = _DATA.Save.ActiveTeam.BoxStorage[selected.BoxSlot].ID
            else
                itemID = selected.ItemID
            end

            local entry = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Item]:Get(itemID)

            if entry.MaxStack > 1 then
                _MENU:AddMenu(RogueEssence.Menu.ItemAmountMenu(RogueElements.Loc(self.menu.Bounds.X, self.menu.Bounds.End.Y), entry.MaxStack, function(n) self:TakeMultiple(n) end), true)
            else
                self:TakeItems(self.slots)
            end
        elseif not selected.IsBox then
            local entry = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Item]:Get(selected.ItemID)
            local openSlots = _DATA.Save.ActiveTeam:GetMaxInvSlots(_ZONE.CurrentZone) - _DATA.Save.ActiveTeam:GetInvCount()
            --stackable items need to be counted differently
            if (entry.MaxStack > 1) then
                local residualSlots = 0
                for j = 0, _DATA.Save.ActiveTeam:GetInvCount()-1, 1 do
                    if _DATA.Save.ActiveTeam:GetInv(j).ID == selected.ItemID and _DATA.Save.ActiveTeam:GetInv(j).Amount < entry.MaxStack then
                        residualSlots = residualSlots + entry.MaxStack - _DATA.Save.ActiveTeam:GetInv(j).Amount
                    end
                end
                openSlots = (openSlots * entry.MaxStack) + residualSlots
            end

            openSlots = math.min(openSlots, _DATA.Save.ActiveTeam.Storage[selected.ItemID])
            _MENU:AddMenu(RogueEssence.Menu.ItemAmountMenu(RogueElements.Loc(self.menu.Bounds.X, self.menu.Bounds.End.Y), openSlots, function(n) self:TakeMultiple(n) end), true)
        else
            self:TakeItems(self.slots)
        end
    end
end

function WithdrawChosenMenu:TakeMultiple(amount) --TODO fix this shit
    local slots = {}
    for i = 1, amount, 1 do
        table.insert(slots, self.slots[1])
    end
    self:TakeItems(slots)
end

function WithdrawChosenMenu:TakeItems(slots)
    local ListType = luanet.import_type('System.Collections.Generic.List`1')
    local WithdrawSlotType = luanet.import_type('RogueEssence.Dungeon.WithdrawSlot')
    local list_slots = LUA_ENGINE:MakeGenericType( ListType, { WithdrawSlotType }, { })
    for _, slot in ipairs(slots) do list_slots:Add(slot) end
    --remove items and fetch them
    local items = _DATA.Save.ActiveTeam:TakeItems(list_slots)

    for item in luanet.each(items) do
        local entry = _DATA:GetItem(item.ID)
        if entry.MaxStack > 1 then
            for inv in luanet.each(LUA_ENGINE:MakeList(_DATA.Save.ActiveTeam:EnumerateInv())) do
                if inv.ID == item.ID and inv.Cursed == item.Cursed and inv.Amount < entry.MaxStack then
                    local addValue = math.min(entry.MaxStack - inv.Amount, item.Amount)
                    inv.Amount = inv.Amount + addValue
                    item.Amount = item.Amount - addValue
                    if (item.Amount <= 0) then
                        break
                    end
                end
            end
            --withdraw the remainder normally
            if (item.Amount > 0) then
                _DATA.Save.ActiveTeam:AddToInv(item)
            end
        else
            _DATA.Save.ActiveTeam:AddToInv(item)
        end
    end

    if self.continueOnChoose then
        --refresh base menu
        local hasStorage = (_DATA.Save.ActiveTeam.BoxStorage.Count > 0)
        for entry in luanet.each(_DATA.Save.ActiveTeam.Storage) do
            if (entry.Value > 0) then
                hasStorage = true
                break
            end
        end
        if hasStorage then
            self.parent:reinitialize(self.parent.menu.CurrentChoiceTotal, self.parent.continueOnChoose, self.parent.currentFilter)
        else
            _MENU:RemoveMenu()
        end
    else
        _MENU:RemoveMenu()
    end
end




WithdrawFilterMenu = Class("WithdrawFilterMenu")

--- Creates a new ``WithdrawFilterMenu`` instance using the provided object as parent.
--- @param parent userdata the parent menu
function WithdrawFilterMenu:initialize(parent, defaultOption)
    self.parent = parent
    self.color = defaultOption > 0
    self.defaultOption = math.max(0, defaultOption-1)
    local x, y = self.parent.menu.Bounds.Right, self.parent.menu.Bounds.Top
    local width = 72
    local label = "WITHDRAW_FILTER_MENU_LUA"

    self:generate_options()
    
    self.menu = RogueEssence.Menu.ScriptableSingleStripMenu(label, x, y, width, self.options, self.defaultOption, function() _MENU:RemoveMenu() end)
    local b = self.menu.Bounds
    self.menu.Bounds = RogueElements.Rect(b.X, b.Y, b.Width, b.Height+2)
end

function WithdrawFilterMenu:generate_options()
    self.options = {}
    for i, entry in ipairs(WithdrawMenu.Filters) do
        local str = STRINGS:FormatKey(entry.Key)
        if i == self.defaultOption+1 and self.color then str = "[color=#FFFF00]"..str.."[color]" end
        table.insert(self.options, {str, self.parent:CanApplyFilter(i), function() self:choose(i) end})
    end
    table.insert(self.options, {STRINGS:FormatKey("MENU_FILTER_ALL"), true, function() self:choose(0) end})
end

function WithdrawFilterMenu:choose(index)
    self.parent:ApplyFilter(index)
    _MENU:RemoveMenu()
end






--- Creates a ``WithdrawMenu`` instance and runs it.
function WithdrawMenu.run()
    local menu = WithdrawMenu:new(0, true, 0)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
end