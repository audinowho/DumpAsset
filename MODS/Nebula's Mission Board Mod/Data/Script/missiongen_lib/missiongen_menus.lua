-- PMDO Mission Generation Library v1.0.3, by MistressNebula
-- Menu file
-- ----------------------------------------------------------------------------------------- --
-- This file contains all menus used by the library, separated from the main systems for
-- organization purposes.
-- If you are looking for the main systems, please refer to missiongen_lib.lua
-- ----------------------------------------------------------------------------------------- --
-- This file is already loaded by missiongen_lib.lua. You don't need to require it
-- explicitly in your project unless you want to use the classes within in a more direct way.


local menus = {
    LINE_HEIGHT = 12,
    VERT_SPACE = 14,
    TITLE_HEIGHT = 12 + RogueEssence.Content.GraphicsManager.MenuBG.TileHeight,
    SCREEN_HEIGHT = RogueEssence.Content.GraphicsManager.ScreenHeight,
    SCREEN_WIDTH = RogueEssence.Content.GraphicsManager.ScreenWidth,
    BORDER_HEIGHT = RogueEssence.Content.GraphicsManager.MenuBG.TileHeight,
    BORDER_WIDTH = RogueEssence.Content.GraphicsManager.MenuBG.TileWidth,
}




--- @class BoardSelectionMenu Menu that allows the player to open either a specific board or the taken job list
local BoardSelectionMenu = Class('BoardSelectionMenu')

--- Creates the menu, using the provided data and callback
--- @param library table the entire job library structure
--- @param board_id string the id of the board to be prompted
--- @param callback function that handles the menu's output. The value is equal to the index selected
function BoardSelectionMenu:initialize(library, board_id, callback, start_choice)
    assert(self, "BoardSelectionMenu:initialize(): Error, self is nil!")
    self.callback = callback
    start_choice = start_choice or 0

    local choices = {
        {STRINGS:FormatKey(library.data.boards[board_id].display_key), not library:IsBoardEmpty(board_id), function() self:choose(1) end},
        {STRINGS:FormatKey(library.globals.keys.TAKEN_TITLE), not library:IsTakenListEmpty(), function() self:choose(2) end},
        {STRINGS:FormatKey("MENU_EXIT"), true, function() self:choose(-1) end}
    }
    self.menu = RogueEssence.Menu.ScriptableSingleStripMenu(24, 22, 100, choices, start_choice, function() self:choose(-1) end)
end

--- Confirmation function that runs the stored callback and closes the menu.
--- @param i number the index of the selected choice, or -1 if either the exit option was selected or nothing was.
function BoardSelectionMenu:choose(i)
    self.callback(i)
end

--- Runs a BoardSelectionMenu instance and returns its selected index
--- @param library table the entire job library structure
--- @param board_id string the id of a board. It will be used to display the first option.
--- @param start_choice? integer The 1-based index of the choice that will be selected when opening the menu. Defaults to 1.
--- @return integer #the index of the chosen option, or -1 if the menu was exited without selecting anything.
function BoardSelectionMenu.run(library, board_id, start_choice)
    start_choice = start_choice or 1
    local ret = -1
    local cb = function(choice)
        ret = choice
        _MENU:RemoveMenu()
    end
    local menu = BoardSelectionMenu:new(library, board_id, cb, start_choice-1)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
    return ret
end





--- @class BoardMenu Menu that displays the contents of a board and allows the player to interact with it.
local BoardMenu = Class('BoardMenu')

--- Creates the menu, using the provided data and callback
--- @param library table the entire job library structure
--- @param board_id string the id of the board to be prompted
--- @param callback function that handles the menu's output. The value is equal to the index selected
--- @param start_choice number the choice that should be selected first. Defaults to 1
function BoardMenu:initialize(library, board_id, callback, start_choice)
    assert(self, "BoardMenu:initialize(): Error, self is nil!")
    self.MAX_ENTRIES = 4

    start_choice = start_choice or 0
    self.library = library
    self.board_id = board_id  --if nil, then taken board
    self.callback = callback
    if board_id then
        self.board_content = self.library.root.boards[board_id]
        self.board_title = self.library.data.boards[board_id].display_key
    else
        self.board_content = self.library.root.taken
        self.board_title = self.library.globals.keys.TAKEN_TITLE
    end

    self.menu = RogueEssence.Menu.ScriptableMenu(32, 32, 256, 176, function(input) self:Update(input) end)
    self.choices = self:GenerateOptions()
    self.pages = math.ceil(#self.choices / self.MAX_ENTRIES)
    self.taken_count = self.library:GetTakenCount()
    if self.pages <= 0 then
        _MENU:RemoveMenu()
        return
    end

    self:DrawBoardStatic()
    self:Select(start_choice)
end


function BoardMenu:GenerateOptions()
    local choices = {}
    for i, job in pairs(self.board_content) do
        ---@cast job jobTable
        local zone_str, floor_pattern = self.library:GetSegmentName(job.Zone, job.Segment)
        local target, item = "[color=#FF0000]TARGET[color]", "[color=#FF0000]ITEM[color]"
        local client = self.library:GetCharacterName(job.Client)
        if job.MenuOverrides and job.MenuOverrides[self.library.globals.overrides.CLIENT] then
        client = STRINGS:FormatKey(job.MenuOverrides[self.library.globals.overrides.CLIENT]) end
        if job.Target then target = self.library:GetCharacterName(job.Target) end
        if job.Item and job.Item ~= "" then item = self.library:GetItemName(job.Item) end

        local title = STRINGS:FormatKey(job.Title, target, zone_str, item, client)
        local taken_string = 'false'

        if job.Taken then
            taken_string = 'true'
        end

        local difficulty = self.library:GetDifficultyString(job)
        -- This is the whole reason why we need a shallowcopy function for the mission data: we can't guarantee the structures point to the same job after save and load
        local icon = ""
        if not self.board_id then
            if job.Taken and not self.library:HasExternalEvents(job.Zone) --if there is an eternal condition, show as not active
            then icon = STRINGS:Format("\\uE10F")--open letter
            else icon = STRINGS:Format("\\uE10E")--closed letter
            end
        else
            if job.Taken
            then icon = STRINGS:Format("\\uE10E")--closed letter
            else icon = STRINGS:Format("\\uE110")--paper
            end
        end
        local location = zone_str
        if not job.HideFloor then location = location.. " " .. STRINGS:Format(floor_pattern, tostring(job.Floor)) end

        local color = Color.White
        --color everything red if job is taken and this is a job board
        local enabled = not (self.board_id and job.Taken)
        if not enabled then
            color = Color.Red
        end


        --modulo the iterator so that if we're on the 2nd page it goes to the right spot
        local choice = RogueEssence.Menu.MenuElementChoice(function() self:choose(i) end, enabled)
        local x, y0 = 17, menus.TITLE_HEIGHT
        choice.Bounds = RogueElements.Rect(x, y0 + (menus.VERT_SPACE*2) * ((i-1) % self.MAX_ENTRIES), self.menu.Bounds.Width-x*2, menus.VERT_SPACE*2)

        choice.Elements:Add(RogueEssence.Menu.MenuText(icon, RogueElements.Loc(4, 8), color))
        choice.Elements:Add(RogueEssence.Menu.MenuText(title, RogueElements.Loc(16, 8), color))
        choice.Elements:Add(RogueEssence.Menu.MenuText(location, RogueElements.Loc(16, 8 + menus.LINE_HEIGHT), color))
        choice.Elements:Add(RogueEssence.Menu.MenuText(difficulty, RogueElements.Loc(choice.Bounds.Width - 4, 8 + menus.LINE_HEIGHT), RogueElements.DirV.Up, RogueElements.DirH.Right, color))
        table.insert(choices, choice)
    end
    return choices
end

function BoardMenu:choose(i)
    self.callback(i)
end

function BoardMenu:DrawBoardStatic()
    --Standard menu divider
    self.menu.Elements:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(menus.BORDER_WIDTH, menus.TITLE_HEIGHT), self.menu.Bounds.Width - menus.BORDER_WIDTH * 2))
    --Standard title
    self.menu.Elements:Add(RogueEssence.Menu.MenuText(STRINGS:FormatKey(self.board_title), RogueElements.Loc(16, 8)))
    --page number
    self.page_num = RogueEssence.Menu.MenuText("(0/0)", RogueElements.Loc(self.menu.Bounds.Width - 17, menus.BORDER_HEIGHT), RogueElements.DirH.Right)
    self.menu.Elements:Add(self.page_num)
    --Another divider, plus accepted counter
    self.menu.Elements:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(8, self.menu.Bounds.Height - 24), self.menu.Bounds.Width - 8 * 2))
    self.menu.Elements:Add(RogueEssence.Menu.MenuText(STRINGS:FormatKey(self.library.globals.keys.JOB_ACCEPTED, #self.library.root.taken, self.library:GetTakenSize()), RogueElements.Loc(96, self.menu.Bounds.Height - 20)))
    --Cursor
    self.cursor = RogueEssence.Menu.MenuCursor(self.menu)
    self.menu.Elements:Add(self.cursor)
    --In total, 6 elements. Remember this for menu refresh
end

function BoardMenu:Select(index)
    self.current = math.max(1, math.max(index, #self.choices))
    self.cursor_pos = (index-1) % self.MAX_ENTRIES +1
    self.page = (index-1) // self.MAX_ENTRIES +1
    self:SelectPage(self.page)
end

function BoardMenu:SelectPage(num)
    num = (num-1) % self.pages +1
    while self.menu.Elements.Count > 6 do
        self.menu.Elements:RemoveAt(6)
    end
    local start = (num-1) * self.MAX_ENTRIES +1
    local finish = math.min(start+3, #self.choices)
    for i = start, finish, 1 do
        self.menu.Elements:Add(self.choices[i])
    end
    self.page_choices = finish-start+1
    self.page = num
    self.page_num:SetText("(" .. tostring(self.page) .. "/" .. tostring(self.pages) .. ")")
    self:MoveCursor(math.min(self.cursor_pos, self.page_choices))
end

function BoardMenu:MoveCursor(index)
    local max_page_entries = math.min(self.MAX_ENTRIES, #self.choices - (self.page-1) * self.MAX_ENTRIES)
    self.cursor_pos = (index-1) % max_page_entries +1
    self.current = self.cursor_pos + (self.page-1) * self.MAX_ENTRIES

    self.cursor:ResetTimeOffset()
    self.cursor.Loc = RogueElements.Loc(9, 28 * self.cursor_pos -1)
end

function BoardMenu:Update(input)
    if self.pages <= 0 then
        _MENU:RemoveMenu()
        return
    end
    if input:JustPressed(RogueEssence.FrameInput.InputType.Confirm) then
        --open the selected job menu
        self.choices[self.current]:OnConfirm()
    elseif input:JustPressed(RogueEssence.FrameInput.InputType.Cancel) or input:JustPressed(RogueEssence.FrameInput.InputType.Menu) then
        _GAME:SE("Menu/Cancel")
        self:choose(-1)
    else
        local start = self.current
        if RogueEssence.Menu.InteractableMenu.IsInputting(input, LUA_ENGINE:MakeLuaArray(Dir8, { Dir8.Down, Dir8.DownLeft, Dir8.DownRight })) then
            self:MoveCursor(self.cursor_pos+1)
        elseif RogueEssence.Menu.InteractableMenu.IsInputting(input, LUA_ENGINE:MakeLuaArray(Dir8, { Dir8.Up, Dir8.UpLeft, Dir8.UpRight })) then
            self:MoveCursor(self.cursor_pos-1)
        elseif RogueEssence.Menu.InteractableMenu.IsInputting(input, LUA_ENGINE:MakeLuaArray(Dir8, {Dir8.Right})) then
            self:SelectPage(self.page+1)
        elseif RogueEssence.Menu.InteractableMenu.IsInputting(input, LUA_ENGINE:MakeLuaArray(Dir8, {Dir8.Left})) then
            self:SelectPage(self.page-1)
        end

        if start ~= self.current then
            _GAME:SE("Menu/Select")
        end
    end
end

--- Runs a BoardMenu instance and returns its selected index
--- @param library table the entire job library structure
--- @param board_id string|nil the id of the board to visualize. Set to nil to select the taken list.
--- @param start_choice|nil number the choice that should be selected first. Defaults to 1
--- @return integer #the index of the chosen option, or -1 if the menu was exited without selecting anything.
function BoardMenu.run(library, board_id, start_choice)
    local ret = -1
    local cb = function(choice)
        ret = choice
        _MENU:RemoveMenu()
    end
    local menu = BoardMenu:new(library, board_id, cb, start_choice or 1)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
    return ret
end

--- Adds a BoardMenu instance to the menu stack and then runs the given callback.
--- @param library table the entire job library structure.
--- @param board_id string|nil the id of the board to visualize. Set to nil to select the taken list.
--- @param callback fun(i:number):nil the callback to run when the menu needs to close. It will have a number passed to it that is equal to the selected index, or -1 if nothing was selected.
--- @param start_choice number|nil the choice that should be selected first. Defaults to 1
function BoardMenu.add(library, board_id, callback, start_choice)
    local menu = BoardMenu:new(library, board_id, callback, start_choice or 1)
    _MENU:AddMenu(menu.menu, false)
end

--- Replaces a previously opened BoardMenu with a fresh new instance and then runs the given callback.
--- @param library table the entire job library structure.
--- @param board_id string|nil the id of the board to visualize. Set to nil to select the taken list.
--- @param callback fun(i:number):nil the callback to run when the menu needs to close. It will have a number passed to it that is equal to the selected index, or -1 if nothing was selected.
--- @param start_choice number|nil the choice that should be selected first. Defaults to 1
function BoardMenu.reset(library, board_id, callback, start_choice)
    local menu = BoardMenu:new(library, board_id, callback, start_choice or 1)
    _MENU:ReplaceMenu(menu.menu)
end




--- @class JobMenu Menu that allows the player to choose what to do with a specific job
local JobMenu = Class('JobMenu')

--- Creates the menu, using the provided data and callback
--- @param library table the entire job library structure
--- @param board_id string the id of the board to be prompted
--- @param job_index number the index of the job to visualize
--- @param callback function that handles the menu's output. The value is equal to the index selected
function JobMenu:initialize(library, board_id, job_index, callback)
    assert(self, "BoardSelectionMenu:initialize(): Error, self is nil!")
    self.library = library
    self.board = self.library.root.taken
    if board_id then self.board = self.library.root.boards[board_id] end
    self.job = self.board[job_index] --[[@as jobTable]]
    self.callback = callback

    local choices = {}
    local choice_str = STRINGS:FormatKey(self.library.globals.keys.BUTTON_TAKE)
    if not board_id then
        --if there is an external condition, lock quest and do not allow its activation
        local enabled = not self.library:HasExternalEvents(self.job.Zone) and not self.library:IsJobDestinationInTaken(self.job, true)
        if self.job.Taken and enabled then choice_str = STRINGS:FormatKey(self.library.globals.keys.BUTTON_SUSPEND) end
        table.insert(choices, {choice_str, enabled, function() self:choose(1) end})
        table.insert(choices, {STRINGS:FormatKey(self.library.globals.keys.BUTTON_DELETE), true, function() self:choose(2) end})
    else
        table.insert(choices, {STRINGS:FormatKey(self.library.globals.keys.BUTTON_TAKE), not self.library:IsTakenListFull() and not self.job.Taken, function() self:choose(1) end })
    end
    table.insert(choices, {STRINGS:FormatKey("MENU_CANCEL"), true, function() self:choose(-1) end })
    self.menu = RogueEssence.Menu.ScriptableSingleStripMenu(232, 138, 24, choices, 0, function() self:choose(-1) end)

    self.job_window = self:GenerateSummary()
    self.menu.LowerSummaryMenus:Add(self.job_window)
end

--- Confirmation function that runs the stored callback and closes the menu.
--- @param i number the index of the selected choice, or -1 if nothing was selected.
function JobMenu:choose(i)
    self.callback(i)
end

function JobMenu:GenerateSummary()
    local summary = RogueEssence.Menu.SummaryMenu(RogueElements.Rect(32, 32, 256, 176))
    local dungeon = self.library:GetSegmentName(self.job.Zone, self.job.Segment)
    local target, item = "[color=#FF0000]TARGET[color]", "[color=#FF0000]ITEM[color]"
    local client = self.library:GetCharacterName(self.job.Client)
    if self.job.MenuOverrides and self.job.MenuOverrides[self.library.globals.overrides.CLIENT] then
    client = STRINGS:FormatKey(self.job.MenuOverrides[self.library.globals.overrides.CLIENT]) end
    if self.job.Target then target = self.library:GetCharacterName(self.job.Target) end
    if self.job.Item and self.job.Item ~= "" then item = self.library:GetItemName(self.job.Item) end

    --Standard menu divider. Reuse this whenever you need a menu divider at the top for a title.
    summary.Elements:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(8, 8 + 12), summary.Bounds.Width - 8 * 2))

    --Standard title. Reuse this whenever a title is needed.
    summary.Elements:Add(RogueEssence.Menu.MenuText(Text.FormatKey(self.library.globals.keys.JOB_SUMMARY), RogueElements.Loc(16, 8)))

    --Accepted element
    summary.Elements:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(8, summary.Bounds.Height - 24), summary.Bounds.Width - 8 * 2))
    summary.Elements:Add(RogueEssence.Menu.MenuText(STRINGS:FormatKey(self.library.globals.keys.JOB_ACCEPTED, #self.library.root.taken, self.library:GetTakenSize()), RogueElements.Loc(96, summary.Bounds.Height - 20)))

    summary.Elements:Add(RogueEssence.Menu.MenuText(STRINGS:FormatKey(self.job.Flavor[1], target, dungeon, item, client), RogueElements.Loc(16, 24)))
    if self.job.Flavor[2] and self.job.Flavor[2] ~= "" then
    summary.Elements:Add(RogueEssence.Menu.MenuText(STRINGS:FormatKey(self.job.Flavor[2], target, dungeon, item, client), RogueElements.Loc(16, 36))) end
    summary.Elements:Add(RogueEssence.Menu.MenuText(STRINGS:FormatKey(self.library.globals.keys.JOB_CLIENT), RogueElements.Loc(16, 54)))
    summary.Elements:Add(RogueEssence.Menu.MenuText(STRINGS:FormatKey(self.library.globals.keys.JOB_OBJECTIVE), RogueElements.Loc(16, 68)))
    summary.Elements:Add(RogueEssence.Menu.MenuText(STRINGS:FormatKey(self.library.globals.keys.JOB_PLACE), RogueElements.Loc(16, 82)))
    summary.Elements:Add(RogueEssence.Menu.MenuText(STRINGS:FormatKey(self.library.globals.keys.JOB_DIFFICULTY), RogueElements.Loc(16, 96)))
    summary.Elements:Add(RogueEssence.Menu.MenuText(STRINGS:FormatKey(self.library.globals.keys.JOB_REWARD), RogueElements.Loc(16, 110)))

    if self.job.MenuOverrides and self.job.MenuOverrides[self.library.globals.overrides.CLIENT] then
    summary.Elements:Add(RogueEssence.Menu.MenuText(STRINGS:FormatKey(self.job.MenuOverrides[self.library.globals.overrides.CLIENT]), RogueElements.Loc(68, 54))) else
    summary.Elements:Add(RogueEssence.Menu.MenuText(self.library:GetCharacterName(self.job.Client),RogueElements.Loc(68, 54))) end
    summary.Elements:Add(RogueEssence.Menu.MenuText(self.library:GetObjectiveString(self.job), RogueElements.Loc(68, 68)))
    summary.Elements:Add(RogueEssence.Menu.MenuText(self.library:GetDestinationString(self.job), RogueElements.Loc(68, 82)))
    summary.Elements:Add(RogueEssence.Menu.MenuText(self.library:GetDifficultyString(self.job, true), RogueElements.Loc(68, 96)))
    summary.Elements:Add(RogueEssence.Menu.MenuText(self.library:GetRewardString(self.job), RogueElements.Loc(68, 110)))

    return summary
end

--- Runs a JobMenu instance and returns its selected index.
--- @param library table the entire job library structure.
--- @param board_id string|nil the id of the board this job is in. Set to nil to select the taken list.
--- @param job_index number the index of the job to visualize.
--- @return integer #the index of the chosen option, or -1 if the menu was exited without selecting anything.
function JobMenu.run(library, board_id, job_index)
    local ret = -1
    local cb = function(choice)
        ret = choice
        _MENU:RemoveMenu()
    end
    local menu = JobMenu:new(library, board_id, job_index, cb)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
    return ret
end

--- Adds a JobMenu instance to the menu stack and then runs the given callback.
--- @param library table the entire job library structure
--- @param board_id string|nil the id of the board this job is in. Set to nil to select the taken list.
--- @param job_index number the index of the job to visualize.
--- @param callback fun(i:number):nil the callback to run when the menu needs to close. It will have a number passed to it that is equal to the selected index, or -1 if either the exit option was selected or nothing was.
function JobMenu.add(library, board_id, job_index, callback)
    local menu = JobMenu:new(library, board_id, job_index, callback)
    _MENU:AddMenu(menu.menu, false)
end


--- @class DungeonJobList Menu that allows the player to see what jobs are in the current dungeon.
local DungeonJobList = Class('DungeonJobList')

--- Creates the menu, using the provided data if required
--- @param library table the entire job library structure
--- @param zone string|nil Optional. A zone id to display the jobs of. It will be ignored unless this menu is opened from a ground map.
--- @param segment string|nil Optional. A segment id to display the jobs of. It will be ignored unless this menu is opened from a ground map.
function DungeonJobList:initialize(library, zone, segment)
    self.library = library
    assert(self, "DungeonJobList:initialize(): Error, self is nil!")
    self.MAX_ENTRIES = 10

    self.zone = ""
    self.segment = -1

    if RogueEssence.GameManager.Instance.CurrentScene == RogueEssence.Dungeon.DungeonScene.Instance then
        self.zone = _ZONE.CurrentZoneID
        self.segment = _ZONE.CurrentMapID.Segment
    elseif zone and segment then
        self.zone = zone
        self.segment = segment
    end

    self.entries = self:GenerateEntries()
    self.pages = math.max(0, #self.entries-1)//self.MAX_ENTRIES +1
    self.page = 1
    self.menu = RogueEssence.Menu.ScriptableMenu(32, 32, 256, 176, function(input) self:Update(input) end)
    self:DrawMenu()
end

function DungeonJobList:GenerateEntries()
    local list = {}
    local oth_segments = {}
    local oth_segments_list = {}
    local _, floor_pattern = self.library:GetSegmentName(self.zone, self.segment)

    local jobs = self.library.root.taken
    for _, job in ipairs(jobs) do
        ---@cast job jobTable
        if job.Taken and job.Zone == self.zone then
            if job.Segment == self.segment then
                local icon = STRINGS:Format("\\uE10F") --open letter
                if job.Completion>0 then icon = STRINGS:Format("\\uE10A") --check mark
                elseif job.Completion<0 then icon = STRINGS:Format("\\uE10B") end -- X

                local floor = ""
                if not job.HideFloor then
                    floor = STRINGS:Format(floor_pattern, job.Floor)
                end

                local message = self.library:GetObjectiveString(job)

                table.insert(list, {icon = icon, floor = floor, message = message, floor_number = job.Floor})
            elseif self.segment and not oth_segments[job.Segment] and not job.Segment == 0 then
                table.insert(oth_segments_list, job.Segment)
                oth_segments[job.Segment] = true
            end
        end
    end
    table.sort(list, function (a, b) return a.floor_number < b.floor_number end)
    if #oth_segments_list>0 then
        table.sort(oth_segments_list)
        for _, segment in ipairs(oth_segments_list) do
            local seg_name = self.library:GetSegmentName(self.zone, segment)
            local message = STRINGS:FormatKey(self.library.globals.keys.REACH_SEGMENT, seg_name)
            table.insert(list, {icon = nil, floor = nil, message = message})
        end
    end
    if #list <= 0 then
        if _DATA.Save.Rescue ~= nil and _DATA.Save.Rescue.Rescuing then
            if self.segment ~= _DATA.Save.Rescue.SOS.Goal.StructID.Segment then
                local seg_name = self.library:GetSegmentName(self.zone, _DATA.Save.Rescue.SOS.Goal.StructID.Segment)
                local message = STRINGS:FormatKey(self.library.globals.keys.REACH_SEGMENT, seg_name)
                table.insert(list, {icon = nil, floor = nil, message = message})
            else
                local team_to_save = STRINGS:Format("[color=#FFA5FF]{0}[color]", _DATA.Save.Rescue.SOS.TeamName)
                local message = STRINGS:FormatKey(self.library.globals.keys.RESCUE_SELF, team_to_save)
                floor = STRINGS:Format(floor_pattern, _DATA.Save.Rescue.SOS.Goal.StructID.ID+1)
                table.insert(list, {icon = STRINGS:Format("\\uE10F"), floor = floor, message = message})
            end
        else
            local missing = "[color=#FF0000]???[color]"
            local conditions = self.library:GetExternalEvents(self.zone)
            for _, condition in ipairs(conditions) do
                if condition.message_key then
                    local icon = STRINGS:Format(condition.icon) or nil
                    local argtable = {}
                    if condition.message_args then argtable = condition.message_args(self.zone) end
                    table.insert(list,
                        {
                            icon = icon,
                            floor = nil,
                            message = STRINGS:FormatKey(condition.message_key, argtable[1] or missing,
                                argtable[2] or missing, argtable[3] or missing, argtable[4] or missing, argtable[5] or missing),
                        })
                end
            end
            if #list <= 0 then --default if it's still empty
                table.insert(list, { icon = nil, floor = nil, message = STRINGS:FormatKey(self.library.globals.keys.OBJECTIVE_DEFAULT) })
            end
        end
    end
    return list
end

function DungeonJobList:DrawMenu()
    self.menu.Elements:Clear()

    --Standard menu divider. Reuse this whenever you need a menu divider at the top for a title.
    self.menu.Elements:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(8, 8 + 12), self.menu.Bounds.Width - 8 * 2))

    --Standard title. Reuse this whenever a title is needed.
    self.menu.Elements:Add(RogueEssence.Menu.MenuText(STRINGS:FormatKey(self.library.globals.keys.OBJECTIVES_TITLE), RogueElements.Loc(16, 8)))

    --page number
    if self.pages > 1 then
        self.menu.Elements:Add(RogueEssence.Menu.MenuText("(" .. tostring(self.page) .. "/" .. tostring(self.pages) .. ")", RogueElements.Loc(self.menu.Bounds.Width - 17, menus.BORDER_HEIGHT), RogueElements.DirH.Right))
    end

    --how many jobs have we populated so far
    local side_dungeon_mission = false
    local zone_string = ''

    --populate jobs that are in this dungeon
    local start  = (self.page-1) * self.MAX_ENTRIES + 1
    local finish = math.min(self.page * self.MAX_ENTRIES, #self.entries)
    local icon_x, floor_x, msg_x = 16, 16, 16
    for i = finish, start, -1 do
        local count = (i-1) % self.MAX_ENTRIES
        local entry = self.entries[i]

        if entry.icon then
            if icon_x == floor_x then floor_x, msg_x = floor_x + 12, msg_x + 12 end
            self.menu.Elements:Add(RogueEssence.Menu.MenuText(entry.icon,    RogueElements.Loc(icon_x,  24 + 14 * count)))
        end
        if entry.floor then
            if floor_x == msg_x then msg_x = msg_x + 32 end
            self.menu.Elements:Add(RogueEssence.Menu.MenuText(entry.floor,   RogueElements.Loc(floor_x, 24 + 14 * count)))
        end
        if entry.message then
            self.menu.Elements:Add(RogueEssence.Menu.MenuText(entry.message, RogueElements.Loc(msg_x,   24 + 14 * count)))
        end
    end
end

function DungeonJobList:Update(input)
    if input:JustPressed(RogueEssence.FrameInput.InputType.Confirm) then
        _GAME:SE("Menu/Cancel")
        _MENU:RemoveMenu()
    elseif input:JustPressed(RogueEssence.FrameInput.InputType.Cancel) then
        _GAME:SE("Menu/Cancel")
        _MENU:RemoveMenu()
    elseif input:JustPressed(RogueEssence.FrameInput.InputType.Menu) then
        _GAME:SE("Menu/Cancel")
        _MENU:RemoveMenu()
    elseif self.pages>1 and RogueEssence.Menu.InteractableMenu.IsInputting(input, LUA_ENGINE:MakeLuaArray(Dir8, {Dir8.Right})) then
        self.page = (self.page)   % self.pages + 1
        SOUND:PlaySE("Menu/Skip")
        self:DrawMenu()
    elseif self.pages>1 and RogueEssence.Menu.InteractableMenu.IsInputting(input, LUA_ENGINE:MakeLuaArray(Dir8, {Dir8.Left})) then
        self.page = (self.page-2) % self.pages + 1
        SOUND:PlaySE("Menu/Skip")
        self:DrawMenu()
    end
end

--- Runs a DungeonJobList instance.
--- @param library table the entire job library structure.
--- @param zone string|nil Optional. A zone id to display the jobs of. It will be ignored unless this menu is opened from a ground map.
--- @param segment string|nil Optional. A segment id to display the jobs of. It will be ignored unless this menu is opened from a ground map.
function DungeonJobList.run(library, zone, segment)
    local menu = DungeonJobList:new(library, zone, segment)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
end

--- Adds a DungeonJobList instance to the menu stack.
--- @param library table the entire job library structure
--- @param zone string|nil Optional. A zone id to display the jobs of. It will be ignored unless this menu is opened from a ground map.
--- @param segment string|nil Optional. A segment id to display the jobs of. It will be ignored unless this menu is opened from a ground map.
function DungeonJobList.add(library, zone, segment)
    local menu = DungeonJobList:new(library, zone, segment)
    _MENU:AddMenu(menu.menu, false)
end

menus.BoardSelection = BoardSelectionMenu
menus.Board = BoardMenu
menus.Job = JobMenu
menus.Objectives = DungeonJobList

return menus


