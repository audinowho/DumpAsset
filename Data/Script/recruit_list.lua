require 'common'

RECRUIT_LIST = {}
--[[
    recruit_list.lua
    by MistressNebula

    This file contains all functions necessary to generate Recruitment Lists for dungeons, as well as
    the routine used to show the list itself

    Every time a floor is loaded, the system takes a snapshot of what Pokémon are in the spawn pool
    and adds to them those that are not in the spawn pool but are spawned regardless on turn 0 (like
    Ralts in Moonlit Courtyard, for example). Those that are not in the spawn pool will be marked with
    an asterisk when the Recruitment List is opened.

    When opening the menu, the game will check again for any other recruitable, spawned monster (Monster
    Houses and other special events) and will show them at the bottom of the list, in cyan if not recruited
    and in a faded version of the recruit color if they are.
]]--

-- -----------------------------------------------
-- Constants
-- -----------------------------------------------
RECRUIT_LIST.recruitMenuOption = "Recruitment search"
RECRUIT_LIST.menuTitle = "Potential Recruits"
RECRUIT_LIST.noRecruitsMessage = "No recruits available"


RECRUIT_LIST.hide =                    0
RECRUIT_LIST.undiscovered =            1
RECRUIT_LIST.discovered =              2
RECRUIT_LIST.extra_discovered =        3
RECRUIT_LIST.obtained =                4
RECRUIT_LIST.extra_obtained =          5
RECRUIT_LIST.obtainedMultiForm =       6
RECRUIT_LIST.extra_obtainedMultiForm = 7

RECRUIT_LIST.colorList = {'#FFFFFF', '#FFFFFF', '#00FFFF', '#FFFF00', '#FFFFA0', '#FFA500', '#FFE0A0'}

-- -----------------------------------------------
-- Functions
-- -----------------------------------------------

-- Wraps a string with a color bracket corresponding to mode. If mode is 1, the
-- string is replaced with "???" before wrapping
function RECRUIT_LIST.colorName(monster, mode, asterisk)
    local name = _DATA:GetMonster(monster).Name:ToLocal()
    if asterisk then name = "*"..name end -- asterisk is for mons that are not in the spawn list but spawned at floor start
    if mode == 1 then name = '???' end
    local color = RECRUIT_LIST.colorList[mode]
    return '[color='..color..']'..name..'[color]'
end

-- Extracts and sorts the list of all mons that are spawned at the start of the current floor
-- Non-respawning mons will have an asterisk at the start of their name
-- returns a table containing the following properties:
-- {table{string} keys, table{string -> boolean} entries}
function RECRUIT_LIST.compileInitialFloorList()
    local list = {
        keys = {},
        entries = {}
    }
    -- abort immediately if we're not inside a dungeon
    if RogueEssence.GameManager.Instance.CurrentScene ~= RogueEssence.Dungeon.DungeonScene.Instance then
        return list
    end

    local map = _ZONE.CurrentMap
    local spawns = map.TeamSpawns

    -- get the spawn list
    for i = 0, spawns.Count-1, 1 do
        local spawnList = spawns:GetSpawn(i):GetPossibleSpawns()
        for j = 0, spawnList.Count-1, 1 do
            local member = spawnList:GetSpawn(j).BaseForm.Species
            local hide = false

            -- check if the mon is recruitable
            local features = spawnList:GetSpawn(j).SpawnFeatures
            for f = 0, features.Count-1, 1 do
                if RECRUIT_LIST.getClass(features[f]) == "PMDC.LevelGen.MobSpawnUnrecruitable" then
                    hide = true -- do not show in recruit list if cannot recruit
                end
            end

            -- add the member and its display mode to the list
            if not hide and list.entries[member] == nil then
                print("added "..member, false)
                table.insert(list.keys, member)
                list.entries[member] = false
            end
        end
    end

    -- get the currently spawned mons
    local teams = map.MapTeams
    for i = 0, teams.Count-1, 1 do
        local team = teams[i].Players
        for j = 0, team.Count-1, 1 do
            local member = team[j].BaseForm.Species
            local hide = false

            -- do not show in recruit list if cannot recruit
            if team[j].Unrecruitable then hide = true end

            -- add the member and its display mode to the list
            if not hide and list.entries[member] == nil then
                print("added "..member, true)
                table.insert(list.keys, member)
                list.entries[member] = true
            end
        end
    end

    -- sort spawn list
    table.sort(list.keys, function (a, b)
        return _DATA:GetMonster(a).IndexNum < _DATA:GetMonster(b).IndexNum
    end)

    return list
end


-- Extracts a list of all mons currently spawned on the current floor and
-- then appends them at the end of the spawn list, all while pairing them to
-- the display mode that should be used for that mon's name in the menu
-- output: a new list of table entries containing these properties:RECRUIT_LIST
-- {string species, int mode, boolean asterisk}
function RECRUIT_LIST.compileCurrentList()
    SV.temp = SV.temp or {}
    local list = SV.temp.floorList or {
        keys = {},
        entries = {}
    }

    local new_list = {
        keys = {},
        entries = {}
    }
    -- abort immediately if we're not inside a dungeon
    if RogueEssence.GameManager.Instance.CurrentScene ~= RogueEssence.Dungeon.DungeonScene.Instance then
        return new_list
    end

    local map = _ZONE.CurrentMap
    local teams = map.MapTeams

    for i = 0, teams.Count-1, 1 do
        local team = teams[i].Players
        for j = 0, team.Count-1, 1 do
            local member = team[j].BaseForm.Species
            local state = _DATA.Save:GetMonsterUnlock(member)
            local mode = RECRUIT_LIST.hide -- default is to not show non-respawning mons if unknown

            -- check if the mon has been seen or obtained
            if state == RogueEssence.Data.GameProgress.UnlockState.Discovered then
                mode = RECRUIT_LIST.extra_discovered
            elseif state == RogueEssence.Data.GameProgress.UnlockState.Completed then
                if _DATA:GetMonster(member).Forms.Count>1 then
                    mode = RECRUIT_LIST.extra_obtainedMultiForm
                else
                    mode = RECRUIT_LIST.extra_obtained
                end
            end
            -- do not show in recruit list if cannot recruit
            if team[j].Unrecruitable then mode = RECRUIT_LIST.hide end

            -- add the member and its display mode to the list if it's not in any of them already
            if mode > RECRUIT_LIST.hide and list.entries[member] == nil and new_list.entries[member] == nil then
                print("found "..member, false)
                table.insert(new_list.keys, member)
                new_list.entries[member] = {mode, false}
            end
        end
    end

    -- turn first list into final output
    local ret = {}
    for _,key in pairs(list.keys) do
        local state = _DATA.Save:GetMonsterUnlock(key)
        local mode = RECRUIT_LIST.undiscovered -- default is to "???" list 1 mons if unknown

        -- check if the mon has been seen or obtained
        if state == RogueEssence.Data.GameProgress.UnlockState.Discovered then
            mode = RECRUIT_LIST.discovered
        elseif state == RogueEssence.Data.GameProgress.UnlockState.Completed then
            if _DATA:GetMonster(key).Forms.Count>1 then
                mode = RECRUIT_LIST.obtainedMultiForm --special color for multi-form mons
            else
                mode = RECRUIT_LIST.obtained
            end
        end

        local entry = {
            species = key,
            mode = mode,
            asterisk = list.entries[key]
        }
        table.insert(ret,entry)
    end

    -- put new list into final output
    for _,key in pairs(new_list.keys) do
        local entry = {
            species = key,
            mode = new_list.entries[key][1],
            asterisk = new_list.entries[key][2]
        }
        table.insert(ret,entry)
    end
    return ret
end

-- Returns the class of an object as string. Useful to extract and check C# classes
function RECRUIT_LIST.getClass(csobject)
    if not csobject then return "nil" end
    local namet = getmetatable(csobject).__name
    if not namet then return type(csobject) end
    for a in namet:gmatch('([^,]+)') do
        return a
    end
end

-- Returns the class of an object as string. Useful to extract and check C# classes
function RECRUIT_LIST.tri(check, y, n)
    if check then return y else return n end
end

-- -----------------------------------------------
-- Recruitment List Menu
-- -----------------------------------------------
-- Menu that displays the recruitment list to the player
RecruitmentListMenu = Class('RecruitmentListMenu')

function RecruitmentListMenu:initialize()
    assert(self, "RecruitmentListMenu:initialize(): self is nil!")

    self.ENTRY_LINES = 10
    self.ENTRY_COLUMNS = 2
    self.ENTRY_LIMIT = self.ENTRY_LINES * self.ENTRY_COLUMNS

    self.menu = RogueEssence.Menu.ScriptableMenu(32, 32, 256, 176, function(input) self:Update(input) end)
    self.dirPressed = false
    self.list = {}
    self.list = RECRUIT_LIST.compileCurrentList()
    self.page = 0
    self.PAGE_MAX = (#self.list+1)//self.ENTRY_LIMIT

    self:DrawMenu()
end

function RecruitmentListMenu:DrawMenu()
    self.menu.MenuElements:Clear()
    --Standard menu divider. Reuse this whenever you need a menu divider at the top for a title.
    self.menu.MenuElements:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(8, 8 + 12), self.menu.Bounds.Width - 8 * 2))

    self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(RECRUIT_LIST.menuTitle, RogueElements.Loc(16, 8)))

    -- add a special message if there are no entries
    if #self.list<1 then
        self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(RECRUIT_LIST.noRecruitsMessage, RogueElements.Loc(16, 24)))
        return
    end

    --Add page number if it has more than one
    if self.PAGE_MAX>0 then
        local pagenum = "("..tostring(self.page+1).."/"..tostring(self.PAGE_MAX+1)..")"
        self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(pagenum, RogueElements.Loc(self.menu.Bounds.Width - 8, 8),RogueElements.DirH.Right))
    end

    --how many entries we have populated so far
    local count = 0

    --other helper indexes
    local start_pos = self.page * self.ENTRY_LIMIT
    local end_pos = math.min(start_pos+self.ENTRY_LIMIT, #self.list)
    start_pos = start_pos + 1

    --populate entries with mon list
    for i=start_pos, end_pos, 1 do
        -- positional parameters
        local line = count % self.ENTRY_LINES
        local col = count // self.ENTRY_LINES
        local xpad = 16
        local ypad = 24
        local xdist = ((self.menu.Bounds.Width-32)//self.ENTRY_COLUMNS)
        local ydist = 14
        local xadjust = RECRUIT_LIST.tri(self.list[i].asterisk and self.list[i].mode > RECRUIT_LIST.undiscovered, 6, 0)

        -- add element
        local x = xpad + xdist * col - xadjust
        local y = ypad + ydist * line
        local text = RECRUIT_LIST.colorName(self.list[i].species, self.list[i].mode, self.list[i].asterisk)
        self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(text, RogueElements.Loc(x, y)))
        count = count + 1
    end
end

function RecruitmentListMenu:Update(input)
    if input:JustPressed(RogueEssence.FrameInput.InputType.Cancel) then
        _GAME:SE("Menu/Cancel")
        _MENU:RemoveMenu()
    elseif input:JustPressed(RogueEssence.FrameInput.InputType.Menu) then
        _GAME:SE("Menu/Cancel")
        _MENU:RemoveMenu()
    elseif input.Direction == RogueElements.Dir8.Right then
        if not self.dirPressed then
            if self.page >= self.PAGE_MAX then
                _GAME:SE("Menu/Cancel")
                self.page = self.PAGE_MAX
            else
                self.page = self.page +1
                _GAME:SE("Menu/Skip")
                self:DrawMenu()
            end
            self.dirPressed = true
        end
    elseif input.Direction == RogueElements.Dir8.Left then
        if not self.dirPressed then
            if self.page <= 0 then
                _GAME:SE("Menu/Cancel")
                self.page = 0
            else
                self.page = self.page -1
                _GAME:SE("Menu/Skip")
                self:DrawMenu()
            end
            self.dirPressed = true
        end
    elseif input.Direction == RogueElements.Dir8.None then
        self.dirPressed = false
    end
end