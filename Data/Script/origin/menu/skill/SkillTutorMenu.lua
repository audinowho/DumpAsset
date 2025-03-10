--[[
    SkillTutorMenu
    by MistressNebula

    Opens a menu with multiple pages that allows the player to select a skill.
    The skills will have a cost in money or items associated with them, and will
    only be possible to choose if the requirement is fulfilled.
    It contains a run method for quick instantiation.
    This equivalent is NOT SAFE FOR REPLAYS. Do not use in dungeons until further notice.
]]
require 'origin.common'
require 'origin.menu.skill.SkillSelectMenu'

--- Menu for selecting a skill from a specific list of skills.
SkillTutorMenu = Class("SkillTutorMenu", SkillSelectMenu)

--- Creates a new ``SkillTutorMenu`` instance using the provided list and callbacks.
--- This function throws an error if the parameter ``skill_list`` contains less than 1 entries, or
--- if ``price_list`` and ``skill_list`` contain a different number of entries.
--- @param title string the title this window will have.
--- @param skill_list table an array, list or lua array table containing skill indices.
--- @param price_list table a lua array table containing ``{number, string}`` entries.
--- @param confirm_action function the function called when a slot is chosen. It will have a skill id string passed to it as a parameter.
--- @param refuse_action function the function called when the player presses the cancel or menu button.
--- @param check_bank boolean if true, currencies will also count bank money. Defaults to false.
--- @param check_storage boolean if true, currencies will also count stored items. Defaults to false.
--- @param label string the label that will be applied to this menu. Defaults to "SKILL_TUTOR_MENU_LUA"
function SkillTutorMenu:initialize(title, skill_list, price_list, confirm_action, refuse_action, check_bank, check_storage, label)
    -- param validity check
    local len = 0
    if type(skill_list) == 'table' then len = #skill_list else len = skill_list.Count end
    if #price_list ~= len then
        --abort if skill list is empty
        error("parameters 'skill_list' and 'price_list' must have the save length")
    end

    self.priceList = self:load_prices(price_list)
    self.currencyList = self:load_currencies(price_list)
    self.check_bank = check_bank or false
    self.check_storage = check_storage or false
    label = label or "SKILL_TUTOR_MENU_LUA"

    -- superclass init
    SkillSelectMenu.initialize(self, title, nil, skill_list, confirm_action, refuse_action, nil, label)

    -- creating the currency window
    local GraphicsManager = RogueEssence.Content.GraphicsManager
    local w, h = 120, 28 + GraphicsManager.MenuBG.TileHeight*2
    local x, y = self.summary.Bounds.Right -w, self.menu.Bounds.Bottom - h
    self.currencyWindow = RogueEssence.Menu.SummaryMenu(RogueElements.Rect.FromPoints(RogueElements.Loc(x, y),
            RogueElements.Loc(x+w, y+h)))
    self.currency_title = RogueEssence.Menu.MenuText("", RogueElements.Loc(GraphicsManager.MenuBG.TileWidth*2, GraphicsManager.MenuBG.TileHeight))
    self.currency_text = RogueEssence.Menu.MenuText("", RogueElements.Loc(self.currencyWindow.Bounds.Width - GraphicsManager.MenuBG.TileWidth*2, GraphicsManager.MenuBG.TileHeight + 14), RogueElements.DirH.Right)
    self.currencyWindow.Elements:Add(self.currency_title)
    self.currencyWindow.Elements:Add(self.currency_text)

    self.menu.SummaryMenus:Add(self.currencyWindow)
    self:updateSummary()
end


--- Loads the price list for all skills in the menu.
--- @param price_list table a lua array table containing ``{number, string}`` entries.
--- @return table a standardized version of the price list
function SkillTutorMenu:load_prices(price_list)
    local list = {}
    for i=1, #price_list, 1 do
        local price = price_list[i]
        local amount = price[1]
        local currency = price[2]
        if not amount or amount<0 then amount = 0 end
        if not currency then currency = "" end
        table.insert(list, {amount, currency})
    end
    return list
end

--- Fetches the amount of available currency for all currencies mentioned in the price list and stores them in a table.
--- @param price_list table a lua array table containing ``{number, string}`` entries.
--- @return table a dictionary whose keys are currency item ids (or ``""`` for money) and values are their available amount.
function SkillTutorMenu:load_currencies(price_list)
    local list = {}
    for i=1, #price_list, 1 do
        local currency = price_list[i][2]
        if not list[currency] then
            if currency == "" then
                list[currency] = GAME:GetPlayerMoney()
                if self.check_bank then
                    list[currency] = list[currency] + GAME:GetPlayerMoneyBank()
                end
            else list[currency] = COMMON.GetPlayerItemCount(currency, self.check_storage) end
        end
    end
    return list
end

--- Processes the menu's properties and generates the ``RogueEssence.Menu.MenuElementChoice`` list that will be displayed.
---
--- Overrides ``SkillSelectMenu.generate_options()``
--- @return table a list of ``RogueEssence.Menu.MenuElementChoice`` objects.
function SkillTutorMenu:generate_options()
    local options = {}
    for i=1, #self.skillList, 1 do
        --extract data
        local price = self.priceList[i]
        local amount = price[1]
        local currency = price[2]
        local enabled = amount <=self.currencyList[currency]
        --build text
        local skill_name = _DATA:GetSkill(self.skillList[i]).Name:ToLocal()
        local skill_price = tostring(amount)
        --special "free" line
        if amount <= 0 then skill_price = STRINGS:FormatKey("MENU_COST_FREE") end
        local color = "#FF0000"
        if enabled then color = "#00FF00" end
        skill_name = "[color="..color.."]"..skill_name.."[color]"
        skill_price = "[color="..color.."]"..skill_price.."[color]"
        --add icon
        if amount>0 then
            if currency == "" then
                skill_price = skill_price..STRINGS:FormatKey("MONEY_AMOUNT" ,"")
            else
                local currency_icon = _DATA:GetItem(currency).Icon
                if currency_icon > -1 then
                    skill_price = skill_price..utf8.char(57504+currency_icon)
                end
            end
        end
        --compose elements
        local text_skill = RogueEssence.Menu.MenuText(skill_name, RogueElements.Loc(2, 1))
        local text_charges = RogueEssence.Menu.MenuText(skill_price, RogueElements.Loc(self.menuWidth - 8 * 4, 1), RogueElements.DirH.Right)
        local option = RogueEssence.Menu.MenuElementChoice(function() self:choose(i) end, enabled, text_skill, text_charges)
        table.insert(options, option)
    end
    return options
end

--- Updates the summary and currency windows.
---
--- Overrides ``SkillSelectMenu.updateSummary()``
function SkillTutorMenu:updateSummary()
    local choice = self.menu.CurrentChoiceTotal+1
    self.summary:SetSkill(self.skillList[choice])
    if not self.currencyWindow then return end

    local currency = self.priceList[choice][2]
    local amount = self.currencyList[currency]
    if currency == "" then
        self.currency_title:SetText(STRINGS:FormatKey("MENU_STORAGE_MONEY")..":")
        self.currency_text:SetText(STRINGS:FormatKey("MONEY_AMOUNT" , amount))
    else
        local item_name = _DATA:GetItem(currency):GetIconName()
        self.currency_title:SetText(RogueEssence.StringKey("MENU_CURRENCY_AVAILABLE"):ToLocal()..":")
        self.currency_text:SetText(item_name.." [color=#FFCEFF]("..tostring(amount)..")[color]")
    end
end




--- Creates a ``SkillTutorMenu`` instance that allows a choice between the provided tutor moves, then runs it and returns its output.
--- The tutor moves are then filtered so that the menu shows only those the character can actually learn.
--- For the menu to function, ``tutor_moves`` must contain key-value pairs structured like so:
--- - key: a skill id string
--- - value: a table ``{Cost, Currency}`` entry.
---
--- The value table must, in turn, be structured like so:
--- - Cost = number. It indicates the price of the skill in the given currency. If omitted, it will be free.
--- - Currency = string. It must be either an item id or ``""``. It's the item required to purchase the skill. If omitted, the
---     parameter ``default_currency`` will be used. If ``""``, money will be used.
---
--- This function throws an error if the parameter ``skill_list`` contains less than 1 entries,
--- or if ``price_list`` and ``skill_list`` contain a different number of entries.
--- @param tutor_moves table the table containing all move data necessary for the menu to function.
--- @param default_currency string the item id of the currency that will be used by all skills in the menu that do not specify one. ``""`` means money.
--- @param check_bank boolean if true, currencies will also count bank money. Defaults to false.
--- @param check_storage boolean if true, currencies will also count stored items. Defaults to false.
--- @return string the id of the selected skill if one was chosen in the menu; ``""`` otherwise.
function SkillTutorMenu.runTutorMenu(tutor_moves, default_currency, check_bank, check_storage)
    --moved GetTutorableMoves call to base_camp_2\init, line 1199   -Nebula
    local tutor_skills = {}
    local tutor_prices = {}

    for move_idx, data in pairs(tutor_moves) do
        local pos = #tutor_skills+1
        for i=1, #tutor_skills, 1 do
            if move_idx<tutor_skills[i] then
                pos = i
                break
            end
        end
        table.insert(tutor_skills, pos, move_idx)

        if not data.Cost then
            table.insert(tutor_prices, pos, {0, ""})
        else
            local cost = data.Cost
            local currency = default_currency
            if data.Currency then currency = data.Currency end
            table.insert(tutor_prices, pos, {cost, currency})
        end
    end

    -- running the menu
    local ret = ""
    local choose = function(move) ret = move end
    local refuse = function() _MENU:RemoveMenu() end
    local menu = SkillTutorMenu:new(RogueEssence.StringKey("MENU_SKILL_TUTOR"):ToLocal(), tutor_skills, tutor_prices, choose, refuse, check_bank, check_storage)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
    return ret
end