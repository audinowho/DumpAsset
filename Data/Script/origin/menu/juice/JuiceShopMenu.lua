--[[
    JuiceShopMenu
    by MistressNebula

    Opens a menu, potentially with multiple pages, that allows the player to select one or
    more items in their inventory, visualizing the effect of the resulting drinks on the target.
    It contains a run method for quick instantiation.
    This menu is NOT SAFE FOR REPLAYS. Do NOT use in dungeons until further notice.
]]
require 'origin.common'
require 'origin.menu.InventorySelectMenu'

--- Menu for selecting items from the player's inventory.
JuiceShopMenu = Class("JuiceShopMenu", InventorySelectMenu)

--- Creates a new ``JuiceShopMenu`` instance using the provided list and callbacks.
--- @param title string the title this window will have.
--- @param character userdata the ``RogueEssence.Dungeon.Character`` object the resulting drink's effect is to be applied to.
--- @param ingredients table a list of key-value pairs where key is an item id and the value is a table of drink effects. See ``ground.base_camp_2.base_camp_2_juice`` for examples.
--- @param confirm_action function the function called when the selection is confirmed. It will have a table array of ``RogueEssence.Dungeon.InvSlot`` objects passed to it as a parameter.
--- @param refuse_action function the function called when the player presses the cancel or menu button.
--- @param include_equips boolean if true, the menu will include equipped items.
--- @param show_preview boolean if true, the preview menu will be shown.
--- @param boost_function function the function that will be used by the preview window to calculate the total boost.
function JuiceShopMenu:initialize(title, character, ingredients, confirm_action, refuse_action, include_equips, show_preview, boost_function)
    -- parsing data
    self.character = character
    self.ingredients = ingredients
    self.show_preview = show_preview
    self.boost_function = boost_function
    -- generate enabled slots filter function
    local filter = function(slot)
        if slot.IsEquipped then
            local item = _DATA.Save.ActiveTeam.Players[slot.Slot].EquippedItem
            return not not self.ingredients[item.ID]
        else
            local item = _DATA.Save.ActiveTeam:GetInv(slot.Slot)
            return not not self.ingredients[item.ID]
        end
    end

    InventorySelectMenu.initialize(self, title, filter, confirm_action, refuse_action, STRINGS:FormatKey('MENU_ITEM_GIVE'), 176, include_equips)

    if show_preview then
        -- create the summary window
        local GraphicsManager = RogueEssence.Content.GraphicsManager
        local left = self.menu.Bounds.Right
        local right = self.summary.Bounds.Right
        local bottom = self.summary.Bounds.Top
        local top = bottom - 14*6 - GraphicsManager.MenuBG.TileHeight*2

        self.preview = DrinkPreviewSummary:new(left, top, right, bottom, character, self.ingredients, boost_function)
        self.menu.SummaryMenus:Add(self.preview.window)

        self:updateSummary()
    end
end

--- Returns the list of ids of the items contained in the selected item slots.
--- @return table a list of ``string`` item ids.
function JuiceShopMenu:getCart()
    local list = {}
    for i, choice in pairs(self.optionsList) do
        if choice.Selected then
            table.insert(list,self.slotList[i])
        end
    end
    return list
end

--- Returns the selected menu option and its corresponding slot
--- @return table a table containing an ``option`` and a ``slot`` property
function JuiceShopMenu:getSelectedOption()
    local i = self.menu.CurrentChoiceTotal+1
    return {
        option = self.optionsList[i],
        slot = self.slotList[i]
    }
end

--- Returns a newly created copy of this object
--- @return table a ``JuiceShopMenu``.
function JuiceShopMenu:cloneMenu()
    return JuiceShopMenu:new(self.title, self.character, self.ingredients, self.confirmAction, self.refuseAction, self.includeEquips, self.show_preview, self.boost_function)
end

--- Updates the summary window and, if present, the summary window
function JuiceShopMenu:updateSummary()
    InventorySelectMenu.updateSummary(self)
    if self.preview then
        local cart = self:getCart()
        local selected = self:getSelectedOption()
        self.preview:setSlots(cart, selected)
    end
end





--- Summary menu that previews a drink's effect on a character's stats.
DrinkPreviewSummary = Class("DrinkPreviewSummary")

--- Generates a new DrinkPreviewSummary object set in the provided coordinates using the provided data.
--- @param left number the x coordinate of the left side of the window.
--- @param top number the y coordinate of the top side of the window.
--- @param right number the x coordinate of the right side of the window.
--- @param bottom number the y coordinate of the bottom side of the window.
--- @param ingredient_effect_table table a list of key-value pairs where key is an item id and the value is a table of drink effects. See ``ground.base_camp_2.base_camp_2_juice`` for examples.
--- @param boost_function function the function that will be used by the preview window to calculate the total boost.
function DrinkPreviewSummary:initialize(left, top, right, bottom, character, ingredient_effect_table, boost_function)
    self.boost_function = boost_function
    self.character = character
    self.ingredient_effect_table = ingredient_effect_table
    self.window = RogueEssence.Menu.SummaryMenu(RogueElements.Rect.FromPoints(
            RogueElements.Loc(left, top), RogueElements.Loc(right, bottom)))

    -- starting data. only stats should be overwritten to not color them when not changed directly
    self.startData = {
        Level      = character.Level,
        EXP        = character.EXP,
        MaxHPBonus = character.MaxHPBonus,
        AtkBonus   = character.AtkBonus,
        DefBonus   = character.DefBonus,
        MAtkBonus  = character.MAtkBonus,
        MDefBonus  = character.MDefBonus,
        SpeedBonus = character.SpeedBonus,
        MaxHP = character.MaxHP,
        Atk   = character.Atk,
        Def   = character.Def,
        MAtk  = character.MAtk,
        MDef  = character.MDef,
        Speed = character.Speed
    }
    -- equal to base at the start. Apply drink changes here
    self.data = {
        Level = character.Level,
        EXP        = character.EXP,
        MaxHPBonus = character.MaxHPBonus,
        AtkBonus   = character.AtkBonus,
        DefBonus   = character.DefBonus,
        MAtkBonus  = character.MAtkBonus,
        MDefBonus  = character.MDefBonus,
        SpeedBonus = character.SpeedBonus,
        MaxHP = character.MaxHP,
        Atk   = character.Atk,
        Def   = character.Def,
        MAtk  = character.MAtk,
        MDef  = character.MDef,
        Speed = character.Speed
    }
    -- equal to base at the start. Changed every time the up-down arrows are pressed
    self.selection_data = {
        Level = character.Level,
        EXP        = character.EXP,
        MaxHPBonus = character.MaxHPBonus,
        AtkBonus   = character.AtkBonus,
        DefBonus   = character.DefBonus,
        MAtkBonus  = character.MAtkBonus,
        MDefBonus  = character.MDefBonus,
        SpeedBonus = character.SpeedBonus,
        MaxHP = character.MaxHP,
        Atk   = character.Atk,
        Def   = character.Def,
        MAtk  = character.MAtk,
        MDef  = character.MDef,
        Speed = character.Speed
    }

    local GraphicsManager = RogueEssence.Content.GraphicsManager
    local x_pos  = GraphicsManager.MenuBG.TileWidth * 2
    local x_pos2 = (self.window.Bounds.Width + GraphicsManager.MenuBG.TileWidth)//2 -6
    local x_pos3 = (self.window.Bounds.Width + GraphicsManager.MenuBG.TileWidth)//2 
    local x_pos4 = self.window.Bounds.Width - GraphicsManager.MenuBG.TileWidth * 2 + 1
    self.growth = _DATA:GetGrowth(_DATA:GetMonster(character.BaseForm.Species).EXPTable)

    self.window.Elements:Add(RogueEssence.Menu.MenuText(character:GetDisplayName(false), RogueElements.Loc(x_pos, GraphicsManager.MenuBG.TileHeight)))

    self.level_text = RogueEssence.Menu.MenuText(tostring(self.data.Level), RogueElements.Loc(x_pos + GraphicsManager.TextFont:SubstringWidth(STRINGS:FormatKey("MENU_TEAM_LEVEL")..": "), GraphicsManager.MenuBG.TileHeight + 14))
    self.window.Elements:Add(RogueEssence.Menu.MenuText(STRINGS:FormatKey("MENU_TEAM_LEVEL")..": ", RogueElements.Loc(x_pos, GraphicsManager.MenuBG.TileHeight + 14)))
    self.window.Elements:Add(self.level_text)

    local exp_text = STRINGS:FormatKey("MENU_TEAM_EXP_SHORT")
    local max = 0
    if self.data.Level<_DATA.Start.MaxLevel then max = self.growth:GetExpToNext(self.data.Level) end
    local x_offset = GraphicsManager.TextFont:SubstringWidth(exp_text) + 3
    local ratio = 1
    if max ~= 0 then ratio = self.data.EXP/max end
    local max_len = self.window.Bounds.Width - GraphicsManager.MenuBG.TileWidth * 4 - x_offset
    local len = max_len * ratio
    self.bar_lower = RogueEssence.Menu.MenuStatBar(RogueElements.Loc(x_pos + x_offset, GraphicsManager.MenuBG.TileHeight + 15*2), 0, Color.MediumPurple, false)
    self.xp_bar    = RogueEssence.Menu.MenuStatBar(RogueElements.Loc(x_pos + x_offset, GraphicsManager.MenuBG.TileHeight + 15*2), len, Color.MediumPurple, false)
    self.bar_upper = RogueEssence.Menu.MenuStatBar(RogueElements.Loc(x_pos + x_offset, GraphicsManager.MenuBG.TileHeight + 15*2), 0, Color.MediumPurple, false)
    self.window.Elements:Add(RogueEssence.Menu.MenuText(exp_text, RogueElements.Loc(x_pos, GraphicsManager.MenuBG.TileHeight + 14*2)))
    self.window.Elements:Add(RogueEssence.Menu.MenuStatBar(RogueElements.Loc(x_pos + x_offset, GraphicsManager.MenuBG.TileHeight + 15*2), max_len, Color.DimGray))
    self.window.Elements:Add(self.bar_lower)
    self.window.Elements:Add(self.xp_bar)
    self.window.Elements:Add(self.bar_upper)

    local hp_label,  spd_label = STRINGS:FormatKey("_ENUM_Stat_HP_tinier"),      STRINGS:FormatKey("_ENUM_Stat_Speed_tinier")
    local atk_label, sat_label = STRINGS:FormatKey("_ENUM_Stat_Attack_tinier"),  STRINGS:FormatKey("_ENUM_Stat_MAtk_tinier")
    local def_label, sdf_label = STRINGS:FormatKey("_ENUM_Stat_Defense_tinier"), STRINGS:FormatKey("_ENUM_Stat_MDef_tinier")

    self.window.Elements:Add(RogueEssence.Menu.MenuText(hp_label,  RogueElements.Loc(x_pos,  GraphicsManager.MenuBG.TileHeight + 14*3)))
    self.window.Elements:Add(RogueEssence.Menu.MenuText(spd_label, RogueElements.Loc(x_pos3, GraphicsManager.MenuBG.TileHeight + 14*3)))
    self.window.Elements:Add(RogueEssence.Menu.MenuText(atk_label, RogueElements.Loc(x_pos,  GraphicsManager.MenuBG.TileHeight + 14*4)))
    self.window.Elements:Add(RogueEssence.Menu.MenuText(sat_label, RogueElements.Loc(x_pos3, GraphicsManager.MenuBG.TileHeight + 14*4)))
    self.window.Elements:Add(RogueEssence.Menu.MenuText(def_label, RogueElements.Loc(x_pos,  GraphicsManager.MenuBG.TileHeight + 14*5)))
    self.window.Elements:Add(RogueEssence.Menu.MenuText(sdf_label, RogueElements.Loc(x_pos3, GraphicsManager.MenuBG.TileHeight + 14*5)))

    self.hp_text  = RogueEssence.Menu.MenuText(tostring(self.data.MaxHP), RogueElements.Loc(x_pos2, GraphicsManager.MenuBG.TileHeight + 14*3), RogueElements.DirH.Right)
    self.spd_text = RogueEssence.Menu.MenuText(tostring(self.data.Speed), RogueElements.Loc(x_pos4, GraphicsManager.MenuBG.TileHeight + 14*3), RogueElements.DirH.Right)
    self.atk_text = RogueEssence.Menu.MenuText(tostring(self.data.Atk),   RogueElements.Loc(x_pos2, GraphicsManager.MenuBG.TileHeight + 14*4), RogueElements.DirH.Right)
    self.sat_text = RogueEssence.Menu.MenuText(tostring(self.data.MAtk),  RogueElements.Loc(x_pos4, GraphicsManager.MenuBG.TileHeight + 14*4), RogueElements.DirH.Right)
    self.def_text = RogueEssence.Menu.MenuText(tostring(self.data.Def),   RogueElements.Loc(x_pos2, GraphicsManager.MenuBG.TileHeight + 14*5), RogueElements.DirH.Right)
    self.sdf_text = RogueEssence.Menu.MenuText(tostring(self.data.MDef),  RogueElements.Loc(x_pos4, GraphicsManager.MenuBG.TileHeight + 14*5), RogueElements.DirH.Right)

    self.window.Elements:Add(self.hp_text)
    self.window.Elements:Add(self.spd_text)
    self.window.Elements:Add(self.atk_text)
    self.window.Elements:Add(self.sat_text)
    self.window.Elements:Add(self.def_text)
    self.window.Elements:Add(self.sdf_text)
end

--- Updates the list of currently selected items in the menu and then updates the menu itself.
--- @param list table a list of ``string`` item ids.
--- @param current_option table a table containing an ``option`` and a ``slot`` property
function DrinkPreviewSummary:setSlots(list, current_option)
    self.cart = list
    self.selected_option = current_option
    self:updateData()
    self:updateMenu()
end

--- Updates the list of currently selected items in the menu and runs the total boost calculation, storing
--- all the data necessary for drawing the final effect of the boosts.
function DrinkPreviewSummary:updateData()
    local selected = self.selected_option.option.Selected
    local slot = self.selected_option.slot

    local cart = {}
    local adj_cart = {}
    if not selected then table.insert(adj_cart, slot) end
    for _, elem in pairs(self.cart) do
        if not selected or elem.Slot~=slot.Slot or elem.IsEquipped~=slot.IsEquipped then
            table.insert(cart, elem)
        end
        table.insert(adj_cart, elem)
    end

    local changes = self.boost_function(cart, self.character)
    local selected_changes = self.boost_function(adj_cart, self.character)

    --TODO test
    self.data.Level = self.startData.Level
    self.data.EXP =   self.startData.EXP   + changes.EXP
    self.data.MaxHPBonus = self.startData.MaxHPBonus + changes.HP
    self.data.AtkBonus   = self.startData.AtkBonus   + changes.Atk
    self.data.DefBonus   = self.startData.DefBonus   + changes.Def
    self.data.MAtkBonus  = self.startData.MAtkBonus  + changes.SpAtk
    self.data.MDefBonus  = self.startData.MDefBonus  + changes.SpDef
    self.data.SpeedBonus = self.startData.SpeedBonus + changes.Speed

    self.selection_data.Level = self.startData.Level
    self.selection_data.EXP =   self.startData.EXP   + selected_changes.EXP
    self.selection_data.MaxHPBonus = self.startData.MaxHPBonus + selected_changes.HP
    self.selection_data.AtkBonus   = self.startData.AtkBonus   + selected_changes.Atk
    self.selection_data.DefBonus   = self.startData.DefBonus   + selected_changes.Def
    self.selection_data.MAtkBonus  = self.startData.MAtkBonus  + selected_changes.SpAtk
    self.selection_data.MDefBonus  = self.startData.MDefBonus  + selected_changes.SpDef
    self.selection_data.SpeedBonus = self.startData.SpeedBonus + selected_changes.Speed

    -- -------------------------------------------------------------- --

    if self.data.EXP<0 then
        while self.data.EXP<0 and self.data.Level>1 do
            self.data.Level = self.data.Level-1
            local toLvl = self.growth:GetExpToNext(self.data.Level)
            self.data.EXP = self.data.EXP + toLvl
        end
        if self.data.Level==1 and self.data.EXP<0 then
            self.data.EXP = 0
        end
    else
        if self.data.Level<_DATA.Start.MaxLevel then
            local toLvl = self.growth:GetExpToNext(self.data.Level)
            while self.data.EXP>=toLvl and self.data.Level<_DATA.Start.MaxLevel do
                self.data.Level = self.data.Level+1
                self.data.EXP   = self.data.EXP - toLvl
                if self.data.Level<_DATA.Start.MaxLevel then
                    toLvl = self.growth:GetExpToNext(self.data.Level)
                end
            end
        end
        if self.data.Level==_DATA.Start.MaxLevel then
            self.data.EXP = 0
        end
    end

    if self.selection_data.EXP<0 then
        while self.selection_data.EXP<0 and self.selection_data.Level>1 do
            self.selection_data.Level = self.selection_data.Level-1
            local toLvl = self.growth:GetExpToNext(self.selection_data.Level)
            self.selection_data.EXP = self.selection_data.EXP + toLvl
        end
        if self.selection_data.Level==1 and self.selection_data.EXP<0 then
            self.selection_data.EXP = 0
        end
    else
        if self.selection_data.Level<_DATA.Start.MaxLevel then
            local toLvl = self.growth:GetExpToNext(self.selection_data.Level)
            while self.selection_data.EXP>=toLvl and self.selection_data.Level<_DATA.Start.MaxLevel do
                self.selection_data.Level = self.selection_data.Level+1
                self.selection_data.EXP   = self.selection_data.EXP - toLvl
                if self.selection_data.Level<_DATA.Start.MaxLevel then
                    toLvl = self.growth:GetExpToNext(self.selection_data.Level)
                end
            end
        end
        if self.selection_data.Level==_DATA.Start.MaxLevel then
            self.selection_data.EXP = 0
        end
    end


    self.data.Level = math.max(1, math.min(self.data.Level + changes.Level, _DATA.Start.MaxLevel))
    self.selection_data.Level = math.max(1,math.min(self.selection_data.Level + selected_changes.Level, _DATA.Start.MaxLevel))
    if changes.Level ~= 0 then self.data.EXP = 0 end
    if selected_changes.Level ~= 0 then self.selection_data.EXP = 0 end

    -- -------------------------------------------------------------- --

    self.data.MaxHPBonus = math.max(0,math.min(self.data.MaxHPBonus, 256))
    self.data.AtkBonus   = math.max(0,math.min(self.data.AtkBonus,   256))
    self.data.DefBonus   = math.max(0,math.min(self.data.DefBonus,   256))
    self.data.MAtkBonus  = math.max(0,math.min(self.data.MAtkBonus,  256))
    self.data.MDefBonus  = math.max(0,math.min(self.data.MDefBonus,  256))
    self.data.SpeedBonus = math.max(0,math.min(self.data.SpeedBonus, 256))

    self.selection_data.MaxHPBonus = math.max(0,math.min(self.selection_data.MaxHPBonus, 256))
    self.selection_data.AtkBonus   = math.max(0,math.min(self.selection_data.AtkBonus,   256))
    self.selection_data.DefBonus   = math.max(0,math.min(self.selection_data.DefBonus,   256))
    self.selection_data.MAtkBonus  = math.max(0,math.min(self.selection_data.MAtkBonus,  256))
    self.selection_data.MDefBonus  = math.max(0,math.min(self.selection_data.MDefBonus,  256))
    self.selection_data.SpeedBonus = math.max(0,math.min(self.selection_data.SpeedBonus, 256))

    -- -------------------------------------------------------------- --

    local form = _DATA:GetMonster(self.character.BaseForm.Species).Forms[self.character.BaseForm.Form]

    self.startData.MaxHP = form:GetStat(self.data.Level, RogueEssence.Data.Stat.HP,      self.startData.MaxHPBonus)
    self.startData.Atk   = form:GetStat(self.data.Level, RogueEssence.Data.Stat.Attack,  self.startData.AtkBonus)
    self.startData.Def   = form:GetStat(self.data.Level, RogueEssence.Data.Stat.Defense, self.startData.DefBonus)
    self.startData.MAtk  = form:GetStat(self.data.Level, RogueEssence.Data.Stat.MAtk,    self.startData.MAtkBonus)
    self.startData.MDef  = form:GetStat(self.data.Level, RogueEssence.Data.Stat.MDef,    self.startData.MDefBonus)
    self.startData.Speed = form:GetStat(self.data.Level, RogueEssence.Data.Stat.Speed,   self.startData.SpeedBonus)

    self.data.MaxHP = form:GetStat(self.data.Level, RogueEssence.Data.Stat.HP,      self.data.MaxHPBonus)
    self.data.Atk   = form:GetStat(self.data.Level, RogueEssence.Data.Stat.Attack,  self.data.AtkBonus)
    self.data.Def   = form:GetStat(self.data.Level, RogueEssence.Data.Stat.Defense, self.data.DefBonus)
    self.data.MAtk  = form:GetStat(self.data.Level, RogueEssence.Data.Stat.MAtk,    self.data.MAtkBonus)
    self.data.MDef  = form:GetStat(self.data.Level, RogueEssence.Data.Stat.MDef,    self.data.MDefBonus)
    self.data.Speed = form:GetStat(self.data.Level, RogueEssence.Data.Stat.Speed,   self.data.SpeedBonus)

    self.selection_data.MaxHP = form:GetStat(self.selection_data.Level, RogueEssence.Data.Stat.HP,      self.selection_data.MaxHPBonus)
    self.selection_data.Atk   = form:GetStat(self.selection_data.Level, RogueEssence.Data.Stat.Attack,  self.selection_data.AtkBonus)
    self.selection_data.Def   = form:GetStat(self.selection_data.Level, RogueEssence.Data.Stat.Defense, self.selection_data.DefBonus)
    self.selection_data.MAtk  = form:GetStat(self.selection_data.Level, RogueEssence.Data.Stat.MAtk,    self.selection_data.MAtkBonus)
    self.selection_data.MDef  = form:GetStat(self.selection_data.Level, RogueEssence.Data.Stat.MDef,    self.selection_data.MDefBonus)
    self.selection_data.Speed = form:GetStat(self.selection_data.Level, RogueEssence.Data.Stat.Speed,   self.selection_data.SpeedBonus)
end

--- Uses the currently stored data to apply changes to the display elements of the menu.
function DrinkPreviewSummary:updateMenu()
    local GraphicsManager = RogueEssence.Content.GraphicsManager
    local getColor = function(change, pos, def, neg)
        if change>0 then     return pos
        elseif change<0 then return neg
        else return def end
    end
    local getTextColor = function(change) return getColor(change, Color.Cyan, Color.White, Color.Red) end
    local getAdjustColor = function(change) return getColor(change, Color.Lime, Color.White, Color.Red) end

    -- compute level and exp difference for coloring
    local level_change = self.data.Level - self.startData.Level
    local exp_change = self.data.EXP - self.startData.EXP
    if level_change ~= 0 then exp_change = level_change end
    -- compute level and exp adjustment for coloring
    local level_adjust = self.selection_data.Level - self.data.Level
    local exp_adjust = self.selection_data.EXP - self.data.EXP
    if level_adjust ~= 0 then exp_adjust = level_adjust end

    -- compute stat difference for coloring
    local hp_change = self.data.MaxHP - self.startData.MaxHP
    local atk_change = self.data.Atk - self.startData.Atk
    local def_change = self.data.Def - self.startData.Def
    local sat_change = self.data.MAtk - self.startData.MAtk
    local sdf_change = self.data.MDef - self.startData.MDef
    local spd_change = self.data.Speed - self.startData.Speed
    -- compute stat adjustment for coloring
    local hp_adjust = self.selection_data.MaxHP - self.data.MaxHP
    local atk_adjust = self.selection_data.Atk - self.data.Atk
    local def_adjust = self.selection_data.Def - self.data.Def
    local sat_adjust = self.selection_data.MAtk - self.data.MAtk
    local sdf_adjust = self.selection_data.MDef - self.data.MDef
    local spd_adjust = self.selection_data.Speed - self.data.Speed

    -- compute color for text
    self.level_text:SetText(tostring(self.selection_data.Level))
    self.level_text.Color = getTextColor(level_change)
    if level_adjust ~= 0 then self.level_text.Color = getAdjustColor(level_adjust) end
    self.hp_text:SetText(tostring(self.selection_data.MaxHP))
    self.hp_text.Color = getTextColor(hp_change)
    if hp_adjust ~= 0    then self.hp_text.Color = getAdjustColor(hp_adjust) end
    self.atk_text:SetText(tostring(self.selection_data.Atk))
    self.atk_text.Color = getTextColor(atk_change)
    if atk_adjust ~= 0   then self.atk_text.Color = getAdjustColor(atk_adjust) end
    self.def_text:SetText(tostring(self.selection_data.Def))
    self.def_text.Color = getTextColor(def_change)
    if def_adjust ~= 0   then self.def_text.Color = getAdjustColor(def_adjust) end
    self.sat_text:SetText(tostring(self.selection_data.MAtk))
    self.sat_text.Color = getTextColor(sat_change)
    if sat_adjust ~= 0   then self.sat_text.Color = getAdjustColor(sat_adjust) end
    self.sdf_text:SetText(tostring(self.selection_data.MDef))
    self.sdf_text.Color = getTextColor(sdf_change)
    if sdf_adjust ~= 0   then self.sdf_text.Color = getAdjustColor(sdf_adjust) end
    self.spd_text:SetText(tostring(self.selection_data.Speed))
    self.spd_text.Color = getTextColor(spd_change)
    if spd_adjust ~= 0   then self.spd_text.Color = getAdjustColor(spd_adjust) end

    -- compute exp gauge data
    local exp_text = STRINGS:FormatKey("MENU_TEAM_EXP_SHORT")
    local x_offset = GraphicsManager.TextFont:SubstringWidth(exp_text) + 3
    local max_len = self.window.Bounds.Width - GraphicsManager.MenuBG.TileWidth * 4 - x_offset

    local max = 0
    if self.data.Level<_DATA.Start.MaxLevel then max = self.growth:GetExpToNext(self.data.Level) end
    local ratio = 1
    if max ~= 0 then ratio = self.data.EXP/max end
    local len = max_len * ratio

    local max_adj = 0
    if self.selection_data.Level<_DATA.Start.MaxLevel then max_adj = self.growth:GetExpToNext(self.selection_data.Level) end
    local ratio_adj = 1
    if max_adj ~= 0 then ratio_adj = self.selection_data.EXP/max_adj end
    local len_adj = max_len * ratio_adj

    --set gauge layers' most common values
    self.xp_bar.Color = Color.LightYellow
    self.xp_bar.Length = len
    self.bar_lower.Length = max_len
    self.bar_lower.Color = getAdjustColor(exp_adjust)
    self.bar_upper.Length = 0
    self.bar_upper.Color = getAdjustColor(exp_adjust)

    --compute gauge layers setup
    if self.selection_data.Level<_DATA.Start.MaxLevel then
        if level_adjust>0 then
            if level_adjust>1 then self.xp_bar.Length = 0 end
            if self.selection_data.EXP ~= 0 then self.bar_lower.Color = Color.Green end
            self.bar_upper.Length = len_adj
        elseif level_adjust == 0 then
            if exp_adjust>0 then
                self.bar_lower.Length = len_adj
            else
                self.xp_bar.Length = len_adj
                self.bar_lower.Length = len
            end
        else
            self.xp_bar.Length = len_adj
        end
    end
end





--- Creates a ``JuiceShopMenu`` instance using the provided parameters, then runs it and returns its output.
--- @param title string the title this window will have
--- @param character userdata the ``RogueEssence.Dungeon.Character`` that will receive this drink.
--- @param ingredients table a list of key-value pairs where the keys are item ids and the values are the drink effects, as specified in ``ground.base_camp_2.base_camp_2_juice``. Only items in this list will be enabled.
--- @param includeEquips boolean if true, the party's equipped items will be included in the menu. Defaults to true.
--- @param show_preview boolean if true, the drink summary window will be shown. Defaults to false.
--- @param boost_function function the function that will be used by the preview window to calculate the total boost.
--- @return table a table array containing the chosen ``RogueEssence.Dungeon.InvSlot`` objects.
function JuiceShopMenu.run(title, character, ingredients, includeEquips, show_preview, boost_function)

    local ret = {}
    local choose = function(list) ret = list end
    local refuse = function() _MENU:RemoveMenu() end
    local menu = JuiceShopMenu:new(title, character, ingredients, choose, refuse, includeEquips, show_preview, boost_function)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
    return ret
end