require 'origin.common'

RECRUIT_LIST = {}
--[[
    recruit_list.lua
    by MistressNebula

    This file contains all functions necessary to generate Recruitment Lists for dungeons, as well as
    the routine used to show the list itself

    When opening the menu, the game will check the current floor's spawn pool and compile a list of all
    enabled entries, then it will take a snapshot of any other recruitable monster on the floor (Monster
    Houses and other special events) and will show them at the bottom of the list, in cyan if not recruited
    and in a faded version of the recruit color if they are.
]]--

-- -----------------------------------------------
-- Constants
-- -----------------------------------------------

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
    if asterisk then name = "\u{E111}"..name end -- asterisk is for mons that are not in the spawn list but spawned at floor start
    if mode == RECRUIT_LIST.undiscovered then name = '???' end
    local color = RECRUIT_LIST.colorList[mode]
    return '[color='..color..']'..name..'[color]'
end

UnrecruitableType = luanet.import_type('PMDC.LevelGen.MobSpawnUnrecruitable')

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
            local spawn = spawnList:GetSpawn(j)

            -- only include if conditions are met
            if spawn:CanSpawn() then
                local member = spawn.BaseForm.Species
                local hide = false

                -- check if the mon is recruitable
                local features = spawn.SpawnFeatures
                for f = 0, features.Count-1, 1 do
                    if LUA_ENGINE:TypeOf(features[f]) == luanet.ctype(UnrecruitableType) then
                        hide = true -- do not show in recruit list if cannot recruit
                    end
                end

                -- add the member and its display mode to the list
                if not hide and list.entries[member] == nil then
                    table.insert(list.keys, member)
                    list.entries[member] = false
                end
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


function RECRUIT_LIST.compileCurrentList()
    if _DATA.Save.NoRecruiting then return {} end

    local list = RECRUIT_LIST.compileInitialFloorList()

    -- turn first list into final output
    local ret = {}
    for _,key in pairs(list.keys) do
        local state = _DATA.Save:GetMonsterUnlock(key)
        local mode = RECRUIT_LIST.undiscovered -- default is to "???" list 1 mons if unknown

        -- check if the mon has been seen or obtained
        if state == RogueEssence.Data.GameProgress.UnlockState.Discovered then
            mode = RECRUIT_LIST.discovered
        elseif state == RogueEssence.Data.GameProgress.UnlockState.Completed then
            mode = RECRUIT_LIST.obtained
        end

        local entry = {
            species = key,
            mode = mode,
            asterisk = list.entries[key]
        }
        table.insert(ret,entry)
    end

    return ret
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
    self.list = RECRUIT_LIST.compileCurrentList()
    self.page = 0
    self.PAGE_MAX = math.max((#self.list-1)//self.ENTRY_LIMIT+1, 0)

    self:DrawMenu()
end

function RecruitmentListMenu:DrawMenu()
    self.menu.MenuElements:Clear()
    --Standard menu divider. Reuse this whenever you need a menu divider at the top for a title.
    self.menu.MenuElements:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(8, 8 + 12), self.menu.Bounds.Width - 8 * 2))

    self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(RogueEssence.StringKey("MENU_RECRUITMENT_TITLE"):ToLocal(), RogueElements.Loc(16, 8)))

    -- add a special message if there are no entries or recruiting is disabled altogether
    if #self.list<1 then
        self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(RogueEssence.StringKey("MENU_RECRUITMENT_NONE"):ToLocal(), RogueElements.Loc(16, 24)))
        return
    end

    --Add page number if it has more than one
    if self.PAGE_MAX>1 then
        local pagenum = "("..tostring(self.page+1).."/"..tostring(self.PAGE_MAX)..")"
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
        local xpad = 24
        local ypad = 24
        local xdist = ((self.menu.Bounds.Width-32)//self.ENTRY_COLUMNS)
        local ydist = 14
        if self.list[i].asterisk and self.list[i].mode > RECRUIT_LIST.undiscovered then
            xpad = xpad - 10
        end

        -- add element
        local x = xpad + xdist * col
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
            if self.page + 1 >= self.PAGE_MAX then
                _GAME:SE("Menu/Cancel")
            else
                self.page = self.page + 1
                _GAME:SE("Menu/Skip")
                self:DrawMenu()
            end
            self.dirPressed = true
        end
    elseif input.Direction == RogueElements.Dir8.Left then
        if not self.dirPressed then
            if self.page <= 0 then
                _GAME:SE("Menu/Cancel")
            else
                self.page = self.page - 1
                _GAME:SE("Menu/Skip")
                self:DrawMenu()
            end
            self.dirPressed = true
        end
    elseif input.Direction == RogueElements.Dir8.None then
        self.dirPressed = false
    end
end