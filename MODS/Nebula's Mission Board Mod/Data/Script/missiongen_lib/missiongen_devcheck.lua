-- PMDO Mission Generation Library v1.0.3, by MistressNebula
-- Debug file
-- ----------------------------------------------------------------------------------------- --
-- This file is a big debug function used by the library only when loading during dev mode.
-- It checks all settings in missiongen_settings.lua to make sure their data structures are
-- correct, and to ensure consistency in the provided data.
-- ----------------------------------------------------------------------------------------- --
-- The library's loading routine tries to run this file in protected mode, so deleting it
-- does not cause any issues other than disable this debug routine altogether.

local errors, warns

local LogError = function(msg)
    PrintInfo("[ERROR] " .. tostring(msg))
    errors = errors+1
end
local LogWarn = function(msg)
    PrintInfo("[WARN] " .. tostring(msg))
    warns = warns+1
end
local LogInfo = function(msg)
    PrintInfo("[INFO] " .. tostring(msg))
end

---@generic T:any
---@param value T
---@param allowed T[]
---@return boolean
local EqualToAny = function(value, allowed)
    for _, val in ipairs(allowed) do
        if val == value then return true end
    end
    return false
end

local checker = {}

---@param monster monsterIDTable
---@param print_path string
function checker.checkMonsterIDTable(monster, print_path)
    if type(monster.Species) == "string" then
        if _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Monster]:ContainsKey(monster.Species) then
            if monster.Form then
                if type(monster.Form) == "number" then
                    local species_data = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Monster]:Get(monster
                    .Species)
                    if monster.Form < 0 then
                        LogError("\"" .. tostring(print_path) .. ".Form\" cannot be negative.")
                    elseif monster.Form >= species_data.Forms.Count then
                        LogError("\"" .. print_path .. ".Form\" must be lower than " .. species_data.Forms.Count .. " because \"" .. tostring(monster.Species) .. "\" only has " .. tostring(species_data.Forms.Count) .. " forms.")
                    end
                else
                    LogError("\"" .. tostring(print_path) .. ".Form\" is not number or nil. This may cause the library to fail.")
                end
            end
            if not EqualToAny(type(monster.Gender), { "number", "nil" }) then
                LogError("\"" .. tostring(print_path) .. ".Gender\" is not number or nil. This may cause the library to fail.")
            end
            if monster.Skin then
                if type(monster.Skin) == "string" then
                    if not _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Skin]:ContainsKey(monster.Skin) then
                        LogError("Value \"" .. monster.Skin .. "\" in \"" .. tostring(print_path) .. "\" is not a valid skin id. This may cause the library to fail.")
                    end
                else
                    LogError("\"" .. tostring(print_path) .. ".Skin\" is not string or nil. This may cause the library to fail.")
                end
            end
            if not EqualToAny(type(monster.Nickname), { "string", "nil" }) then
                LogError("\"" .. tostring(print_path) .. ".Nickname\" is not string or nil. This may cause the library to fail.")
            end
        else
            LogError("Value \"" .. monster.Species .. "\" in \"" .. tostring(print_path) .. ".Species\" is not a valid species id. This may cause the library to fail.")
        end
    else
        LogError("\"" .. tostring(print_path) .. ".Species\" is not a string. This may cause the library to fail.")
    end
end

---@param loc {zone:string, map:integer}
---@param print_path string
function checker.checkGroundLocationTable(loc, print_path)
    local can_check = true
    if type(loc.zone) ~= "string" then
        LogError("\"" .. tostring(print_path) .. ".zone\" is not a string. This will cause the library to fail.")
        can_check = false
    end
    if type(loc.map) ~= "number" then
        LogError("\"" .. tostring(print_path) .. ".map\" is not a number. This will cause the library to fail.")
        can_check = false
    end
    if can_check then
        if _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:ContainsKey(loc.zone) then
            local zone_summary = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(loc.zone)
            if loc.map < 0 then
                LogError("\"" .. tostring(print_path) .. ".map\" cannot be negative.")
            elseif loc.map >= zone_summary.Grounds.Count then
                LogError("\"" .. tostring(print_path) .. ".map\" is higher than the number of ground maps registered to \"" .. tostring(loc.zone) .. "\". This will cause the library to fail.")
            end
        else
            LogError("The value \"" .. tostring(loc.zone) .. "\" of \"" .. tostring(print_path) .. ".zone\" is not a valid zone id. This will cause the library to fail.")
        end
    end
end

function checker.check(library)
    local values = {}
    ---@type table<string, boolean>
    values.difficulties = {}
    ---@type table<string, boolean>
    values.dungeons = {}
    ---@type table<string, boolean>
    values.job_types = {}
    ---@type table<string, boolean>
    values.reward_pools = {}
    ---@type table<string, {pokemon:boolean, enforcer_chance:boolean, special_data:table<string, boolean>}>
    values.data_tiers = {}
    ---@type table<string, boolean>
    values.special_types = {}
    values.special = false

    errors, warns = 0, 0

    local settings = library.data --require("missiongen_lib.missiongen_settings")
    LogInfo("Running sanity checker from missiongen_devcheck.lua")

    if not settings then
        LogError("The base \"settings\" struct is nil. This will cause the library to fail. Was the return statement in \"missiongen_settings.lua\" removed?")
        return
    elseif type(settings) ~= "table" then
        LogError("The base \"settings\" struct is not a table. This will cause the library to fail. Was the return statement in \"missiongen_settings.lua\" tampered with?")
        return
    end

    --validate root name
    if not settings.sv_root_name then
        LogError("\"sv_root_name\" is nil. This will cause the library to fail.")
    elseif type(settings.sv_root_name) ~= "string" then
        if type(settings.sv_root_name) == "table" then
            for _, elem in ipairs(settings.sv_root_name --[[@as string[] ]]) do
                if type(elem) == "string" then
                    LogWarn("All elements inside \"sv_root_name\" should be strings.")
                    break
                end
            end
        else
            LogError("\"sv_root_name\" is not a string or a list of strings. This will cause the library to fail.")
        end
    end

    if not settings.difficulty_list then
        LogError("\"difficulty_list\" is nil. This will cause the library to fail.")
    elseif type(settings.difficulty_list) == "table" then
        for _, diff in ipairs(settings.difficulty_list) do
            if type(diff) ~= "string" then
                LogWarn("\"difficulty_list\" contains an id of type \"" ..
                type(diff) .. "\". All difficulty ids should be strings.")
            end
            values.difficulties[diff] = true
        end
    else
        LogError("\"difficulty_list\" is not a table. This will cause the library to fail.")
    end

    if not settings.dungeons then
        LogError("\"dungeons\" is nil. This will cause the library to fail.")
    elseif type(settings.dungeons) == "table" then
        for id, zone_data in pairs(settings.dungeons) do
            if _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:ContainsKey(id) then
                if type(zone_data) == "table" then
                    local zone = _DATA:GetZone(id)
                    for index, segment_data in pairs(zone_data) do
                        if index >= 0 and index < zone.Segments.Count then
                            if type(segment_data) == "table" then
                                if not type(segment_data.max_floor) == "number" then
                                    LogError("\"dungeons[" ..
                                    tostring(id) ..
                                    "][" ..
                                    tostring(index) ..
                                    "].max_floor\" is not a number. This will cause the library to fail.")
                                end
                                if not EqualToAny(type(segment_data.must_end), { "boolean", "nil" }) then
                                    LogWarn("\"dungeons[" ..
                                    tostring(id) ..
                                    "][" ..
                                    tostring(index) ..
                                    "].must_end\" is not boolean or nil. This may lead to unintended results.")
                                end
                                for idx, section in pairs(segment_data.sections) do
                                    if type(section) == "table" then
                                        if not type(section.start) == "number" then
                                            LogError("\"dungeons[" ..
                                            tostring(id) ..
                                            "][" ..
                                            tostring(index) ..
                                            "].sections[" ..
                                            tostring(idx) ..
                                            "].start\" is not a number. This may cause the library to fail.")
                                        end
                                        if type(section.difficulty) == "string" then
                                            if not values.difficulties[section.difficulty] then
                                                LogWarn("Value " ..
                                                tostring(section.difficulty) ..
                                                " of \"dungeons[" ..
                                                tostring(id) ..
                                                "][" ..
                                                tostring(index) ..
                                                "].sections[" ..
                                                tostring(idx) ..
                                                "].difficulty\" does not correspond to any defined difficulty id. It will be treated as if it was the difficulty of index 1.")
                                            end
                                        else
                                            LogWarn("\"dungeons[" ..
                                            tostring(id) ..
                                            "][" ..
                                            tostring(index) ..
                                            "].sections[" ..
                                            tostring(idx) ..
                                            "].difficulty\" is not a string. It will be treated as if it was the difficulty of index 1.")
                                        end
                                    else
                                        LogError("\"dungeons[" ..
                                        tostring(id) ..
                                        "][" ..
                                        tostring(index) ..
                                        "].sections[" ..
                                        tostring(idx) .. "]\" is not a table. This may cause the library to fail.")
                                    end
                                end
                            else
                                LogError("\"dungeons[" ..
                                tostring(id) ..
                                "][" .. tostring(index) .. "]\" is not a table. This will cause the library to fail.")
                            end
                        else
                            LogError("\"" ..
                            tostring(id) ..
                            "\" does not contain a segment of index " ..
                            tostring(index) .. ". This may cause the library to fail.")
                        end
                    end
                else
                    LogError("\"dungeons[" .. tostring(id) .. "]\" is not a table. This will cause the library to fail.")
                end
                values.dungeons[id] = true
            else
                LogError("\"" .. tostring(id) .. "\" is not a valid zone id. This may cause the library to fail.")
            end
        end
    else
        LogError("\"dungeons\" is not a table. This will cause the library to fail.")
    end

    if not settings.dungeon_order then
        LogError("\"dungeon_order\" is nil. This will cause the library to fail.")
    elseif type(settings.dungeon_order) == "table" then
        for id, val in pairs(settings.dungeon_order) do
            if type(val) ~= "number" then
                LogError("\"dungeon_order[" .. tostring(id) .. "]\" is not a number. This may cause the library to fail.")
            end
        end
    else
        LogError("\"dungeon_order\" is not a table. This will cause the library to fail.")
    end

    if not settings.job_types then
        LogError("\"job_types\" is nil. This will cause the library to fail.")
    elseif type(settings.job_types) == "table" then
        for id, val in pairs(settings.job_types) do
            if type(id) == "string" and library.globals.job_types[id] then
                if not EqualToAny(type(val.rank_modifier), { "number", "nil" }) then
                    LogWarn("\"job_types[" ..
                    tostring(id) .. "].rank_modifier\" is not number or nil. This will cause the library to fail.")
                end
                if val.min_rank then
                    if type(val.min_rank) == "string" then
                        if not values.difficulties[val.min_rank] then
                            LogWarn("Value " ..
                            tostring(val.min_rank) ..
                            " of \"job_types[" ..
                            tostring(id) ..
                            "].min_rank\" does not correspond to any defined difficulty id. It will be treated as if it was the difficulty of index 1.")
                        end
                    else
                        LogWarn("\"job_types[" ..
                        tostring(id) ..
                        "].min_rank\" is not a string. It will be treated as if it was the difficulty of index 1.")
                    end
                end
                values.job_types[id] = true
            else
                LogWarn("Invalid job id \"" .. tostring(id) .. "\" found inside \"job_types\".")
            end
        end
    else
        LogError("\"job_types\" is not a table. This will cause the library to fail.")
    end

    if not settings.dungeon_job_modifiers then
        LogError("\"dungeon_job_modifiers\" is nil. This will cause the library to fail.")
    elseif type(settings.dungeon_job_modifiers) == "table" then
        for id, tbl in pairs(settings.dungeon_job_modifiers) do
            if type(tbl) == "table" then
                for job, mult in pairs(tbl) do
                    if type(job) == "string" and library.globals.job_types[job] then
                        if values.job_types[job] then
                            if type(mult) ~= "number" then
                                LogError("\"dungeon_job_modifiers[" ..
                                tostring(id) ..
                                "][" .. tostring(job) .. "]\" is not a number. This may cause the library to fail.")
                            end
                        else
                            LogWarn("Unused job id \"" ..
                            tostring(job) .. "\" found inside \"dungeon_job_modifiers[" .. tostring(id) .. "]\"")
                        end
                    else
                        LogWarn("Invalid job id \"" ..
                        tostring(job) .. "\" found inside \"dungeon_job_modifiers[" .. tostring(id) .. "]\".")
                    end
                end
            else
                LogError("\"dungeon_job_modifiers[" ..
                tostring(id) .. "]\" is not a table. This may cause the library to fail.")
            end
        end
    else
        LogError("\"dungeon_job_modifiers\" is not a table. This will cause the library to fail.")
    end

    if not settings.special_chance then
        LogError("\"special_chance\" is nil. This will cause the library to fail.")
    elseif type(settings.special_chance) == "number" then
        values.special = settings.special_chance > 0
    else
        LogError("\"special_chance\" is not a number. This will cause the library to fail.")
    end

    if not settings.special_jobs then
        if values.special then
            LogError("\"special_jobs\" is nil. This will cause the library to fail.")
        else
            LogInfo("\"special_jobs\" is nil. This is acceptable, because \"special_chance\" is 0 or less.")
        end
    elseif type(settings.special_jobs) == "table" then
        for id, ls in pairs(settings.special_jobs) do
            if type(id) == "string" and library.globals.job_types[id] then
                if values.job_types[id] then
                    if type(ls) == "table" then
                        for i, entry in pairs(ls) do
                            if type(entry) == "string" then
                                values.special_types[entry] = false
                            else
                                if values.special then
                                    LogWarn("Index " ..
                                    tostring(i) ..
                                    " of \"special_jobs[" ..
                                    tostring(id) .. "]\" is not a string. This may lead to unintended results.")
                                else
                                    LogWarn("Index " ..
                                    tostring(i) .. " of \"special_jobs[" .. tostring(id) .. "]\" is not a string.")
                                end
                            end
                        end
                    else
                        if values.special then
                            LogError("\"special_jobs[" ..
                            tostring(id) .. "]\" is not a table. This may cause the library to fail.")
                        else
                            LogWarn("\"special_jobs[" .. tostring(id) .. "]\" is not a table.")
                        end
                    end
                else
                    LogWarn("Unused job id \"" .. tostring(id) .. "\" found inside \"special_jobs\"")
                end
            else
                LogWarn("Invalid job id \"" .. tostring(id) .. "\" found inside \"special_jobs\".")
            end
        end
    else
        if values.special then
            LogError("\"special_jobs\" is not a table. This will cause the library to fail.")
        else
            LogWarn("\"special_jobs\" is not a table.")
        end
    end

    if not settings.reward_types then
        LogError("\"reward_types\" is nil. This will cause the library to fail.")
    elseif type(settings.reward_types) == "table" then
        for i, tbl in ipairs(settings.reward_types) do
            if type(tbl) == "table" then
                if type(tbl.id) ~= "string" or not library.globals.reward_types[tbl.id] then
                    LogWarn("Invalid reward type id \"" ..
                    tostring(tbl.id) .. "\" found inside \"reward_types[" .. tostring(i) .. "]\".")
                end
                if tbl.min_rank then
                    if type(tbl.min_rank) ~= "string" or not values.difficulties[tbl.min_rank] then
                        LogWarn("Value " ..
                        tostring(tbl.min_rank) ..
                        " of \"reward_types[" ..
                        tostring(i) ..
                        "].min_rank\" does not correspond to any defined difficulty id. It will be treated as if it was the difficulty of index 1.")
                    end
                end
                if tbl.weight then
                    if type(tbl.weight) == "number" then
                        if tbl.weight < 0 then
                            LogWarn("\"reward_types[" ..
                            tostring(i) .. "].weight\" is less than 0. This may lead to unintended results.")
                        end
                    else
                        LogError("\"reward_types[" ..
                        tostring(i) .. "].weight\" is not number or nil. This may cause the library to fail.")
                    end
                end
            else
                LogError("\"reward_types[" .. tostring(i) .. "]\" is not a table. This may cause the library to fail.")
            end
        end
    else
        LogError("\"reward_types\" is not a table. This will cause the library to fail.")
    end

    if not settings.rewards_per_difficulty then
        LogError("\"rewards_per_difficulty\" is nil. This will cause the library to fail.")
    elseif type(settings.rewards_per_difficulty) == "table" then
        for diff in pairs(values.difficulties) do
            local pools = settings.rewards_per_difficulty[diff]
            if pools then
                for i, pool in ipairs(pools) do
                    if type(pool) == "table" then
                        if type(pool.id) ~= "string" then
                            LogWarn("\"rewards_per_difficulty[" ..
                            tostring(diff) ..
                            "][" ..
                            tostring(i) ..
                            "].id\" is of type \"" .. type(pool.id) .. "\". All pool ids should be strings.")
                        end
                        if settings.reward_pools[pool.id] then
                            values.reward_pools[pool.id] = true
                        else
                            LogError("\"rewards_per_difficulty[" ..
                            tostring(diff) ..
                            "][" ..
                            tostring(i) ..
                            "]\" refers to undefined pool \"" ..
                            tostring(pool.id) .. ".This may cause the library to fail.")
                        end
                        if pool.weight then
                            if type(pool.weight) == "number" then
                                if pool.weight < 0 then
                                    LogWarn("\"rewards_per_difficulty[" ..
                                    tostring(diff) ..
                                    "][" ..
                                    tostring(i) .. "].weight\" is less than 0. This may lead to unintended results.")
                                end
                            else
                                LogError("\"rewards_per_difficulty[" ..
                                tostring(diff) ..
                                "][" ..
                                tostring(i) .. "].weight\" is not number or nil. This may cause the library to fail.")
                            end
                        end
                    else
                        LogError("\"rewards_per_difficulty[" ..
                        tostring(diff) ..
                        "][" .. tostring(i) .. "]\" is not a table. This may cause the library to fail.")
                    end
                end
            else
                LogError("Difficulty id\"" ..
                tostring(diff) ..
                "\" has no reward pools assigned to it inside \"rewards_per_difficulty\". This may cause the library to fail.")
            end
        end
    else
        LogError("\"rewards_per_difficulty\" is not a table. This will cause the library to fail.")
    end
    for diff in pairs(settings.rewards_per_difficulty) do
        if not values.difficulties then
            LogWarn("Reward pool with difficulty id \"" ..
            tostring(diff) .. "\" is unused because no such difficulty exists.")
        end
    end

    if not settings.reward_pools then
        LogError("\"reward_pools\" is nil. This will cause the library to fail.")
    elseif type(settings.reward_pools) == "table" then
        for id, pool in pairs(settings.reward_pools) do
            values.reward_pools[id] = values.reward_pools[id] or false
            if type(id) ~= "string" then
                LogWarn("\"reward_pools\" contains an id of type \"" ..
                type(id) .. "\". All reward pool ids should be strings.")
            end
            if type(pool) == "table" then
                for i, entry in ipairs(pool) do
                    if type(entry) == "table" then
                        if type(entry.id) ~= "string" then
                            LogWarn("\"reward_pools[" ..
                            tostring(id) ..
                            "][" ..
                            tostring(i) ..
                            "].id\" is of type \"" .. type(entry.id) .. "\". All pool ids should be strings.")
                        end
                        if settings.reward_pools[entry.id] then
                            values.reward_pools[entry.id] = true
                        else
                            if not _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Item]:ContainsKey(entry.id) then
                                LogError("Pool entry id \"" ..
                                tostring(entry.id) ..
                                "\" in \"reward_pools[" ..
                                tostring(id) ..
                                "][" ..
                                tostring(i) ..
                                "]\" does not correspond to an item nor another pool. This may cause the library to fail.")
                            end
                        end
                        if entry.weight then
                            if type(entry.weight) == "number" then
                                if entry.weight < 0 then
                                    LogWarn("\"reward_pools[" ..
                                    tostring(id) ..
                                    "][" ..
                                    tostring(i) .. "].weight\" is less than 0. This may lead to unintended results.")
                                end
                            else
                                LogError("\"reward_pools[" ..
                                tostring(id) ..
                                "][" ..
                                tostring(i) .. "].weight\" is not number or nil. This may cause the library to fail.")
                            end
                        end
                        if not EqualToAny(type(entry.count), { "number", "nil" }) then
                            LogError("\"reward_pools[" ..
                            tostring(id) ..
                            "][" .. tostring(i) .. "].count\" is not number or nil. This may cause the library to fail.")
                        end
                        if not EqualToAny(type(entry.hidden), { "string", "nil" }) then
                            LogError("\"reward_pools[" ..
                            tostring(id) ..
                            "][" .. tostring(i) .. "].hidden\" is not string or nil. This may cause the library to fail.")
                        end
                    else
                        LogError("\"reward_pools[" ..
                        tostring(id) .. "][" .. tostring(i) .. "]\" is not a table. This may cause the library to fail.")
                    end
                end
            else
                LogError("\"reward_pools[" .. tostring(id) .. "]\" is not a table. This may cause the library to fail.")
            end
        end
    else
        LogError("\"reward_pools\" is not a table. This will cause the library to fail.")
    end
    for pool, used in pairs(values.reward_pools) do
        if not used then
            LogWarn("Reward pool with id \"" .. tostring(pool) .. "\" is unused.")
        end
    end

    if not settings.target_items then
        LogError("\"target_items\" is nil. This will cause the library to fail.")
    elseif type(settings.target_items) == "table" then
        for job, data in pairs(library.globals.job_types) do
            if data.req_target_item then
                if settings.target_items[job] then
                    if type(settings.target_items[job]) == "table" then
                        for i, item in ipairs(settings.target_items[job]) do
                            if _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Item]:ContainsKey(item) then
                                local item_summary = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Item]:Get(
                                item)
                                if item_summary.MaxStack > 1 then
                                    LogWarn("Item \"" ..
                                    tostring(item) ..
                                    "\" in \"target_items[" ..
                                    tostring(job) ..
                                    "][" .. tostring(i) .. "]\" is stackable. This may lead to unintended results.")
                                end
                            else
                                LogError("Entry id \"" ..
                                tostring(item) ..
                                "\" in \"target_items[" ..
                                tostring(job) ..
                                "][" ..
                                tostring(i) .. "]\" does not correspond to an item. This may cause the library to fail.")
                            end
                        end
                    else
                        LogError("\"target_items[" ..
                        tostring(job) .. "]\" is not a table. This may cause the library to fail.")
                    end
                else
                    LogError("Missing \"target_items\" table for job type \"" ..
                    tostring(job) .. "\". This may cause the library to fail.")
                end
            end
        end
    else
        LogError("\"target_items\" is not a table. This will cause the library to fail.")
    end

    if not settings.difficulty_to_tier then
        LogError("\"difficulty_to_tier\" is nil. This will cause the library to fail.")
    elseif type(settings.difficulty_to_tier) == "table" then
        for diff in pairs(values.difficulties) do
            local pools = settings.difficulty_to_tier[diff]
            if pools then
                for i, pool in ipairs(pools) do
                    if type(pool) == "table" then
                        if type(pool.id) ~= "string" then
                            LogWarn("\"rewards_per_difficulty[" ..
                            tostring(diff) ..
                            "][" ..
                            tostring(i) ..
                            "].id\" is of type \"" .. type(pool.id) .. "\". All pool ids should be strings.")
                        end
                        values.data_tiers[pool.id] = {}
                        if pool.weight then
                            if type(pool.weight) == "number" then
                                if pool.weight < 0 then
                                    LogWarn("\"rewards_per_difficulty[" ..
                                    tostring(diff) ..
                                    "][" ..
                                    tostring(i) .. "].weight\" is less than 0. This may lead to unintended results.")
                                end
                            else
                                LogError("\"rewards_per_difficulty[" ..
                                tostring(diff) ..
                                "][" ..
                                tostring(i) .. "].weight\" is not number or nil. This may cause the library to fail.")
                            end
                        end
                    else
                        LogError("\"difficulty_to_tier[" ..
                        tostring(diff) ..
                        "][" .. tostring(i) .. "]\" is not a table. This may cause the library to fail.")
                    end
                end
            else
                LogError("Difficulty id\"" ..
                tostring(diff) ..
                "\" has no reward pools assigned to it inside \"difficulty_to_tier\". This may cause the library to fail.")
            end
        end
    else
        LogError("\"difficulty_to_tier\" is not a table. This will cause the library to fail.")
    end

    if not settings.pokemon then
        LogError("\"pokemon\" is nil. This will cause the library to fail.")
    elseif type(settings.pokemon) == "table" then
        for id, pool in pairs(settings.pokemon) do
            if values.data_tiers[id] then
                values.data_tiers[id].pokemon = true
            else
                LogWarn("Pokemon pool with id \"" .. tostring(id) .. "\" is unused.")
            end
            if type(id) ~= "string" then
                LogWarn("\"pokemon\" contains an id of type \"" ..
                type(id) .. "\". All pokemon pool ids should be strings.")
            end
            if type(pool) == "table" then
                for i, entry in ipairs(pool) do
                    if type(entry) == "string" then
                        if not _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Monster]:ContainsKey(entry) then
                            LogError("Value \"" ..
                            tostring(entry) ..
                            "\" in \"pokemon[" ..
                            tostring(id) ..
                            "][" .. tostring(i) .. "]\" is not a valid species id. This may cause the library to fail.")
                        end
                    elseif type(entry) == "table" then
                        checker.checkMonsterIDTable(entry, "pokemon[" .. tostring(id) .. "][" .. tostring(i) .. "]")
                    else
                        LogError("\"pokemon[" ..
                        tostring(id) ..
                        "][" .. tostring(i) .. "]\" is not string or table. This may cause the library to fail.")
                    end
                end
            else
                LogError("\"pokemon[" .. tostring(id) .. "]\" is not a table. This may cause the library to fail.")
            end
        end
    else
        LogError("\"pokemon\" is not a table. This will cause the library to fail.")
    end
    for pool, used in pairs(values.data_tiers) do
        if not used.pokemon then
            LogWarn("Pokemon pool with id \"" .. tostring(pool) .. "\" is unused.")
        end
    end

    if not settings.law_enforcement then
        LogError("\"law_enforcement\" is nil. This will cause the library to fail.")
    elseif type(settings.law_enforcement) == "table" then
        if type(settings.law_enforcement.OFFICER) == "table" then
            checker.checkMonsterIDTable(settings.law_enforcement.OFFICER, "settings.law_enforcement.OFFICER")
        else
            LogError("\"law_enforcement.OFFICER\" is not a table. This may cause the library to fail.")
        end
        if type(settings.law_enforcement.AGENT) == "table" then
            for i, agent in ipairs(settings.law_enforcement.AGENT) do
                if type(agent) == "table" then
                    checker.checkMonsterIDTable(agent --[[@as monsterIDTable]],
                        "law_enforcement.AGENT[" .. tostring(i) .. "]")
                    if not EqualToAny(type(agent.Unique), { "boolean", "nil" }) then
                        LogWarn("\"law_enforcement.AGENT[" ..
                        tostring(i) .. "].Unique\" is not boolean or nil. This may lead to unintended results.")
                    end
                    if agent.Weight then
                        if type(agent.Weight) == "number" then
                            if agent.Weight < 0 then
                                LogWarn("\"law_enforcement.AGENT[" ..
                                tostring(i) .. "].Weight\" is less than 0. This may lead to unintended results.")
                            end
                        else
                            LogError("\"law_enforcement.AGENT[" ..
                            tostring(i) .. "].Weight\" is not number or nil. This may cause the library to fail.")
                        end
                    end
                else
                    LogError("\"law_enforcement.AGENT[" ..
                    tostring(i) .. "]\" is not a table. This may cause the library to fail.")
                end
            end
        else
            LogError("\"law_enforcement.AGENT\" is not a table. This may cause the library to fail.")
        end
    else
        LogError("\"law_enforcement\" is not a table. This will cause the library to fail.")
    end


    if not settings.enforcer_chance then
        LogError("\"enforcer_chance\" is nil. This will cause the library to fail.")
    elseif type(settings.enforcer_chance) == "table" then
        for id, pool in pairs(settings.enforcer_chance) do
            if values.data_tiers[id] then
                values.data_tiers[id].enforcer_chance = true
            else
                LogWarn("Enforcer chance pool with id \"" .. tostring(id) .. "\" is unused.")
            end
            if type(id) ~= "string" then
                LogWarn("\"enforcer_chance\" contains an id of type \"" ..
                type(id) .. "\". All enforcer chance pool ids should be strings.")
            end
            if type(pool) == "table" then
                for i, entry in ipairs(pool) do
                    if type(entry) == "table" then
                        if not EqualToAny(entry.id, { "OFFICER", "AGENT" }) then
                            LogError("\"enforcer_chance[" ..
                            tostring(id) ..
                            "][" ..
                            tostring(i) .. "].id\" is not \"OFFICER\" or \"AGENT\". This may cause the library to fail.")
                        end
                        if entry.index and entry.id == "AGENT" then
                            if type(entry.index) == "number" then
                                if entry.index <= 0 then
                                    LogError("\"enforcer_chance[" ..
                                    tostring(id) .. "][" .. tostring(i) .. "].index\" cannot be 0 or negative.")
                                elseif settings.law_enforcement and settings.law_enforcement.AGENT and entry.index > #settings.law_enforcement.AGENT then
                                    LogError("\"enforcer_chance[" ..
                                    tostring(id) ..
                                    "][" ..
                                    tostring(i) ..
                                    "].index\" is higher than the number of defined agents in \"law_enforcement[AGENT]\". This may cause the library to fail.")
                                end
                            else
                                LogError("\"pokemon[" ..
                                tostring(id) ..
                                "][" ..
                                tostring(i) .. "].index\" is not number or nil. This may cause the library to fail.")
                            end
                        end
                        if entry.weight then
                            if type(entry.weight) == "number" then
                                if entry.weight < 0 then
                                    LogWarn("\"reward_types[" ..
                                    tostring(i) .. "].weight\" is less than 0. This may lead to unintended results.")
                                end
                            else
                                LogError("\"reward_types[" ..
                                tostring(i) .. "].weight\" is not number or nil. This may cause the library to fail.")
                            end
                        end
                    else
                        LogError("\"enforcer_chance[" ..
                        tostring(id) .. "][" .. tostring(i) .. "]\" is not a table. This may cause the library to fail.")
                    end
                end
            else
                LogError("\"enforcer_chance[" ..
                tostring(id) .. "]\" is not a table. This may cause the library to fail.")
            end
        end
    else
        LogError("\"enforcer_chance\" is not a table. This will cause the library to fail.")
    end
    for pool, used in pairs(values.data_tiers) do
        if not used.enforcer_chance then
            LogWarn("Enforcer chance pool with id \"" .. tostring(pool) .. "\" is unused.")
        end
    end

    if not settings.special_data then
        if values.special then
            LogError("\"special_data\" is nil. This will cause the library to fail.")
        else
            LogInfo("\"special_data\" is nil. This is acceptable, because \"special_chance\" is 0 or less.")
        end
    elseif type(settings.special_data) == "table" then
        for spec, tbl in pairs(settings.special_data) do
            if type(spec) == "string" then
                if values.special_types[spec] == nil then
                    LogWarn("Special data pool with id \"" .. tostring(spec) .. "\" is unused.")
                else
                    values.special_types[spec] = true
                end
                if type(tbl) == "table" then
                    for t, list in pairs(tbl) do
                        if type(t) == "string" then
                            if values.data_tiers[t] then
                                values.data_tiers[t].special_data = values.data_tiers[t].special_data or {}
                                values.data_tiers[t].special_data[spec] = values.data_tiers[t].special_data[spec] or {}
                                values.data_tiers[t].special_data[spec] = true
                            else
                                LogWarn("Special data tier with id \"" ..
                                tostring(t) .. "\" defined inside pool \"" .. tostring(spec) .. "\" is unused.")
                            end
                            if type(list) == "table" then
                                for i, entry in ipairs(list) do
                                    if type(entry.client) == "table" then
                                        checker.checkMonsterIDTable(entry.client --[[@as monsterIDTable]],
                                            "special_data[" ..
                                            tostring(spec) .. "][" .. tostring(t) .. "][" .. tostring(i) .. "].client")
                                    elseif type(entry.client) == "string" then
                                        if entry.client ~= "ENFORCER" and entry.client ~= "OFFICER" and entry.client ~= "AGENT" then
                                            LogError("\"special_data[" ..
                                                tostring(spec) ..
                                                "][" ..
                                                tostring(t) ..
                                                "][" ..
                                                tostring(i) ..
                                                "].client\" is set to an invalid keyword. This may cause the library to fail.\n" ..
                                                "Valid keywords are: \"ENFORCER\",\"OFFICER\",\"AGENT\".")
                                        end
                                    else
                                        LogError("\"special_data[" ..
                                        tostring(spec) ..
                                        "][" ..
                                        tostring(t) ..
                                        "][" ..
                                        tostring(i) ..
                                        "].client\" is not table or string. This may cause the library to fail.")
                                    end
                                    if type(entry.target) == "table" then
                                        checker.checkMonsterIDTable(entry.target --[[@as monsterIDTable]],
                                            "special_data[" ..
                                            tostring(spec) .. "][" .. tostring(t) .. "][" .. tostring(i) .. "].target")
                                    elseif type(entry.target) == "string" then
                                        if entry.target ~= "ENFORCER" and entry.target ~= "OFFICER" and entry.target ~= "AGENT" then
                                            LogError("\"special_data[" ..
                                                tostring(spec) ..
                                                "][" ..
                                                tostring(t) ..
                                                "][" ..
                                                tostring(i) ..
                                                "].target\" is set to an invalid keyword. This may cause the library to fail.\n" ..
                                                "Valid keywords are: \"ENFORCER\",\"OFFICER\",\"AGENT\".")
                                        end
                                    else
                                        LogError("\"special_data[" ..
                                        tostring(spec) ..
                                        "][" ..
                                        tostring(t) ..
                                        "][" ..
                                        tostring(i) ..
                                        "].target\" is not table or string. This may cause the library to fail.")
                                    end
                                    if entry.item then
                                        if type(entry.item) == string then
                                            if _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Item]:ContainsKey(entry.item) then
                                                local item_summary = _DATA.DataIndices
                                                [RogueEssence.Data.DataManager.DataType.Item]:Get(entry.item)
                                                if item_summary.MaxStack > 1 then
                                                    LogWarn("Item \"" ..
                                                    tostring(entry.item) ..
                                                    "\" in \"special_data[" ..
                                                    tostring(spec) ..
                                                    "][" ..
                                                    tostring(t) ..
                                                    "][" ..
                                                    tostring(i) ..
                                                    "].item\" is stackable. This may lead to unintended results.")
                                                end
                                            else
                                                LogError("Entry id \"" ..
                                                tostring(entry.item) ..
                                                "\" in \"special_data[" ..
                                                tostring(spec) ..
                                                "][" ..
                                                tostring(t) ..
                                                "][" ..
                                                tostring(i) ..
                                                "].item\" does not correspond to an item. This may cause the library to fail.")
                                            end
                                        else
                                            LogError("\"special_data[" ..
                                            tostring(spec) ..
                                            "][" ..
                                            tostring(t) ..
                                            "][" ..
                                            tostring(i) ..
                                            "].target\" is not a string. This may cause the library to fail.")
                                        end
                                    end
                                    if type(entry.flavor) == "string" then
                                        if not RogueEssence.Text.Strings:ContainsKey(entry.flavor) then
                                            LogWarn("\"special_data[" ..
                                            tostring(spec) ..
                                            "][" ..
                                            tostring(t) ..
                                            "][" ..
                                            tostring(i) ..
                                            "].flavor\" is not a valid strings.resx key. This will cause errors when opening menus.")
                                        end
                                    else
                                        LogError("\"special_data[" ..
                                        tostring(spec) ..
                                        "][" ..
                                        tostring(t) ..
                                        "][" ..
                                        tostring(i) .. "].flavor\" is not a string. This may cause the library to fail.")
                                    end
                                end
                            else
                                if values.special then
                                    LogError("\"special_data[" ..
                                    tostring(spec) ..
                                    "][" .. tostring(t) .. "]\" is not a table. This may cause the library to fail.")
                                else
                                    LogWarn("\"special_data[" ..
                                    tostring(spec) .. "][" .. tostring(t) .. "]\" is not a table.")
                                end
                            end
                        else
                            LogWarn("\"special_data[" ..
                            tostring(spec) ..
                            "]\" contains an id of type \"" ..
                            type(t) .. "\". All special data tier ids should be strings.")
                        end
                    end
                else
                    if values.special then
                        LogError("\"special_data[" ..
                        tostring(spec) .. "]\" is not a table. This may cause the library to fail.")
                    else
                        LogWarn("\"special_data[" .. tostring(spec) .. "]\" is not a table.")
                    end
                end
            else
                LogWarn("\"special_data\" contains an id of type \"" ..
                type(spec) .. "\". All special data pool ids should be strings.")
            end
        end
    else
        if values.special then
            LogError("\"special_data\" is not a table. This will cause the library to fail.")
        else
            LogWarn("\"special_data\" is not a table.")
        end
    end
    for spec, defined in pairs(values.special_types) do
        if not defined then
            if values.special then
                LogError("Special type \"" ..
                tostring(spec) .. "\" is not defined in \"special_data\". This may cause the library to fail")
            else
                LogWarn("Special type \"" .. tostring(spec) .. "\" is not defined in \"special_data\".")
            end
            for t, tbl in pairs(values.data_tiers) do
                if tbl.special_data then
                    if not tbl.special_data[spec] then
                        LogWarn("Special data pool of tier \"" ..
                        tostring(t) ..
                        "\" does not contain a list for special type \"" ..
                        tostring(spec) .. "\". This may cause the library to fail")
                    end
                else
                    LogWarn("Special data pool of tier \"" ..
                    tostring(t) .. "\" does not contain any entries. This may cause the library to fail")
                end
            end
        end
    end

    if not settings.job_titles then
        LogError("\"job_titles\" is nil. This will cause the library to fail.")
    elseif type(settings.job_titles) == "table" then
        for t, list in pairs(settings.job_titles) do
            if values.job_types[t] or values.special_types[t] then
                if type(list) == "table" then
                    for i, entry in ipairs(list) do
                        if type(entry) == "string" then
                            if not RogueEssence.Text.Strings:ContainsKey(entry) then
                                LogWarn("\"job_titles[" ..
                                tostring(t) ..
                                "][" ..
                                tostring(i) ..
                                "]\" is not a valid strings.resx key. This will cause errors when opening menus.")
                            end
                        else
                            LogError("\"job_titles[" ..
                            tostring(t) ..
                            "][" .. tostring(i) .. "]\" is not a string. This may cause the library to fail.")
                        end
                    end
                else
                    LogError("\"job_titles[" .. tostring(t) .. "]\" is not a table. This will cause the library to fail.")
                end
            elseif library.globals.job_types[t] then
                LogWarn("Unused job type id \"" .. tostring(t) .. "\" found inside \"job_titles\".")
            else
                LogWarn("Invalid job type id \"" .. tostring(t) .. "\" found inside \"job_titles\".")
            end
        end
    else
        LogError("\"job_titles\" is not a table. This will cause the library to fail.")
    end
    for t in pairs(values.job_types) do
        if not settings.job_titles[t] then
            LogError("Job type id\"" ..
            tostring(t) ..
            "\" has no job title pool assigned to it inside \"job_titles\". This may cause the library to fail.")
        end
    end
    for t in pairs(values.special_types) do
        if not settings.job_titles[t] then
            if values.special then
                LogError("Special type id\"" ..
                tostring(t) ..
                "\" has no job title pool assigned to it inside \"job_titles\". This may cause the library to fail.")
            else
                LogWarn("Special type id\"" ..
                tostring(t) .. "\" has no job title pool assigned to it inside \"job_titles\".")
            end
        end
    end

    if not settings.job_flavor then
        LogError("\"job_flavor\" is nil. This will cause the library to fail.")
    elseif type(settings.job_flavor) == "table" then
        for t, list in pairs(settings.job_flavor) do
            if values.job_types[t] then
                if type(list) == "table" then
                    for i, entry in ipairs(list) do
                        if type(entry) == "table" then
                            for s = 1, 2, 1 do
                                if type(entry[s]) == "string" then
                                    if not RogueEssence.Text.Strings:ContainsKey(entry[s]) then
                                        LogWarn("\"job_flavor[" ..
                                        tostring(t) ..
                                        "][" ..
                                        tostring(i) ..
                                        "][" ..
                                        tostring(s) ..
                                        "]\" is not a valid strings.resx key. This will cause errors when opening menus.")
                                    end
                                else
                                    LogError("\"job_flavor[" ..
                                    tostring(t) ..
                                    "][" ..
                                    tostring(i) ..
                                    "][" .. tostring(s) .. "]\" is not a string. This may cause the library to fail.")
                                end
                            end
                        else
                            LogError("\"job_flavor[" ..
                            tostring(t) ..
                            "][" .. tostring(i) .. "]\" is not a table. This may cause the library to fail.")
                        end
                    end
                else
                    LogError("\"job_flavor[" .. tostring(t) .. "]\" is not a table. This will cause the library to fail.")
                end
            elseif library.globals.job_types[t] then
                LogWarn("Unused job type id \"" .. tostring(t) .. "\" found inside \"job_flavor\".")
            else
                LogWarn("Invalid job type id \"" .. tostring(t) .. "\" found inside \"job_flavor\".")
            end
        end
    else
        LogError("\"job_flavor\" is not a table. This will cause the library to fail.")
    end
    for t in pairs(values.job_types) do
        if not settings.job_flavor[t] then
            LogError("Job type id\"" ..
            tostring(t) ..
            "\" has no job flavor pool assigned to it inside \"job_flavor\". This may cause the library to fail.")
        end
    end

    if not settings.escort_talks then
        LogError("\"escort_talks\" is nil. This will cause the library to fail.")
    elseif type(settings.escort_talks) == "table" then
        for t, list in pairs(settings.escort_talks) do
            if values.job_types[t] or values.special_types[t] then
                if type(list) == "table" then
                    for i, entry in ipairs(list) do
                        if type(entry) == "string" then
                            if not RogueEssence.Text.StringsEx:ContainsKey(entry) then
                                LogWarn("\"escort_talks[" ..
                                tostring(t) ..
                                "][" ..
                                tostring(i) ..
                                "]\" is not a valid stringsEx.resx key. This will cause errors when loading it as dialogue.")
                            end
                        else
                            LogError("\"escort_talks[" ..
                            tostring(t) ..
                            "][" .. tostring(i) .. "]\" is not a string. This may cause the library to fail.")
                        end
                    end
                else
                    LogError("\"escort_talks[" ..
                    tostring(t) .. "]\" is not a table. This will cause the library to fail.")
                end
            elseif library.globals.job_types[t] then
                LogWarn("Unused job type id \"" .. tostring(t) .. "\" found inside \"escort_talks\".")
            else
                LogWarn("Invalid job type id \"" .. tostring(t) .. "\" found inside \"escort_talks\".")
            end
        end
    else
        LogError("\"escort_talks\" is not a table. This will cause the library to fail.")
    end
    for t in pairs(values.job_types) do
        if library.globals.job_types[t].has_guest then
            if not settings.escort_talks[t] then
                LogError("Job type id\"" ..
                tostring(t) ..
                "\" has no escort dialogue pool assigned to it inside \"escort_talks\". This may cause the library to fail.")
            end
        end
    end
    for t in pairs(values.job_types) do
        if library.globals.job_types[t].has_guest and settings.special_jobs[t] and type(settings.special_jobs[t]) == "table" then
            for _, spec in ipairs(settings.special_jobs[t]) do
                if values.special then
                    if not settings.escort_talks[spec] then
                        LogError("Special type id \"" ..
                        tostring(spec) ..
                        "\" has no escort dialogue pool assigned to it inside \"escort_talks\". This may cause the library to fail.")
                    end
                else
                    LogWarn("Special type id \"" ..
                    tostring(spec) .. "\" has no escort dialogue pool assigned to it inside \"escort_talks\".")
                end
            end
        end
    end

    if not settings.rescue_responses then
        LogError("\"rescue_responses\" is nil. This will cause the library to fail.")
    elseif type(settings.rescue_responses) == "table" then
        local emotions = { "Normal", "Happy", "Pain", "Angry", "Worried", "Sad", "Crying", "Shouting", "Teary-Eyed",
            "Determined", "Joyous", "Inspired", "Surprised", "Dizzy", "Special0", "Special1", "Sigh", "Stunned",
            "Special2", "Special3" }
        local emotions2 = {}
        for _, e in ipairs(emotions) do table.insert(emotions2, "\"" .. tostring(e) .. "\"") end
        for case, tbl in pairs(settings.rescue_responses) do
            if case == "rescue_yes" or case == "rescue_no" then
                if type(tbl) == "table" then
                    for t, list in pairs(tbl) do
                        if t == "_DEFAULT" or values.special_types[t] then
                            if type(list) == "table" then
                                for i, entry in ipairs(list) do
                                    if type(entry) == "table" then
                                        if type(entry.key) == "string" then
                                            if not RogueEssence.Text.StringsEx:ContainsKey(entry.key) then
                                                LogWarn("\"rescue_responses[" ..
                                                tostring(case) ..
                                                "][" ..
                                                tostring(t) ..
                                                "][" ..
                                                tostring(i) ..
                                                "].key\" is not a valid stringsEx.resx key. This will cause errors when loading it as dialogue.")
                                            end
                                        else
                                            LogError("\"rescue_responses[" ..
                                            tostring(case) ..
                                            "][" ..
                                            tostring(t) ..
                                            "][" ..
                                            tostring(i) .. "].key\" is not a string. This may cause the library to fail.")
                                        end
                                        if entry.emotion then
                                            if type(entry.emotion) == "string" then
                                                if not EqualToAny(entry.emotion, emotions) then
                                                    LogError("\"rescue_responses[" ..
                                                        tostring(case) ..
                                                        "][" ..
                                                        tostring(t) ..
                                                        "][" ..
                                                        tostring(i) ..
                                                        "].emotion\" is neither nil nor a valid emotion id.\n" ..
                                                        "Valid keywords are: " .. STRINGS:CreateList(emotions2))
                                                end
                                            else
                                                LogError("\"rescue_responses[" ..
                                                tostring(case) ..
                                                "][" ..
                                                tostring(t) ..
                                                "][" ..
                                                tostring(i) ..
                                                "].emotion\" is not a string. This may cause the library to fail.")
                                            end
                                        end
                                    else
                                        LogError("\"rescue_responses[" ..
                                        tostring(case) ..
                                        "][" ..
                                        tostring(t) ..
                                        "][" .. tostring(i) .. "]\" is not a table. This may cause the library to fail.")
                                    end
                                end
                            else
                                LogError("\"rescue_responses[" ..
                                tostring(case) ..
                                "][" .. tostring(t) .. "]\" is not a table. This will cause the library to fail.")
                            end
                        elseif type(t) == "string" then
                            LogWarn("Unused special type id \"" ..
                            tostring(t) .. "\" found inside \"rescue_responses[" .. tostring(case) .. "]\".")
                        else
                            LogWarn("\"rescue_responses[" ..
                            tostring(case) ..
                            "]\" contains a special type id of type \"" ..
                            type(t) .. "\". All special type ids should be strings.")
                        end
                    end
                else
                    LogError("\"rescue_responses[" ..
                    tostring(case) .. "]\" is not a table. This will cause the library to fail.")
                end
            else
                LogWarn("Invalid response case \"" .. tostring(case) .. "\" found inside \"rescue_responses\".")
            end
        end
    else
        LogError("\"rescue_responses\" is not a table. This will cause the library to fail.")
    end

    if not settings.difficulty_data then
        LogError("\"difficulty_data\" is nil. This will cause the library to fail.")
    elseif type(settings.difficulty_data) == "table" then
        for diff, data in pairs(settings.difficulty_data) do
            if values.difficulties[diff] then
                if type(data) == "table" then
                    if type(data.display_key) == "string" then
                        if not RogueEssence.Text.Strings:ContainsKey(data.display_key) then
                            LogWarn("\"difficulty_data[" ..
                            tostring(diff) ..
                            "].display_key\" is not a valid strings.resx key. This will cause errors when opening menus.")
                        end
                    else
                        LogError("\"difficulty_data[" ..
                        tostring(diff) .. "].display_key\" is not a string. This may cause the library to fail.")
                    end
                    if type(data.money_reward) ~= "number" then
                        LogError("\"difficulty_data[" ..
                        tostring(diff) .. "].money_reward\" is not a number. This may cause the library to fail.")
                    end
                    if type(data.extra_reward) ~= "number" then
                        LogError("\"difficulty_data[" ..
                        tostring(diff) .. "].extra_reward\" is not a number. This may cause the library to fail.")
                    end
                    if not EqualToAny(type(data.escort_level), { "number", "nil" }) then
                        LogError("\"difficulty_data[" ..
                        tostring(diff) .. "].escort_level\" is not number or nil. This may cause the library to fail.")
                    end
                    if not EqualToAny(type(data.outlaw_level), { "number", "nil" }) then
                        LogError("\"difficulty_data[" ..
                        tostring(diff) .. "].outlaw_level\" is not number or nil. This may cause the library to fail.")
                    end
                else
                    LogError("\"difficulty_data[" ..
                    tostring(diff) .. "]\" is not a table. This will cause the library to fail.")
                end
            elseif type(diff) == "string" then
                LogWarn("Unused difficulty id \"" .. tostring(diff) .. "\" found inside \"difficulty_data\".")
            else
                LogWarn("\"difficulty_data\" contains a difficulty id of type \"" ..
                type(diff) .. "\". All difficulty ids should be strings.")
            end
        end
    else
        LogError("\"difficulty_data\" is not a table. This will cause the library to fail.")
    end
    for diff in pairs(values.difficulties) do
        if not settings.difficulty_data then
            LogError("\"difficulty_data\" does not contain an entry for difficulty id \"" ..
            tostring(diff) .. "\". This will cause the library to fail.")
        end
    end

    if not settings.hidden_floor_chance then
        LogError("\"hidden_floor_chance\" is nil. This may cause the library to fail.")
    elseif type(settings.hidden_floor_chance) ~= "number" then
        LogError("\"hidden_floor_chance\" is not a number. This may cause the library to fail.")
    end


    if not settings.boards then
        LogError("\"boards\" is nil. This may cause the library to fail.")
    elseif type(settings.boards) == "table" then
        for id, data in pairs(settings.boards) do
            if type(id) ~= "string" then
                LogWarn("\"boards\" contains an id of type \"" .. type(id) .. "\". All board ids should be strings.")
            end
            if type(data) == "table" then
                if type(data.display_key) == "string" then
                    if not RogueEssence.Text.Strings:ContainsKey(data.display_key) then
                        LogWarn("\"boards[" ..
                        tostring(id) ..
                        "].display_key\" is not a valid strings.resx key. This will cause errors when opening menus.")
                    end
                else
                    LogError("\"boards[" ..
                    tostring(id) .. "].display_key\" is not a string. This may cause the library to fail.")
                end
                if type(data.location) == "table" then
                    checker.checkGroundLocationTable(data.location, "boards[" .. tostring(id) .. "].location")
                else
                    LogError("\"boards[" ..
                    tostring(id) .. "].location\" is not a table. This will cause the library to fail.")
                end
                if not data.size then
                    LogError("\"boards[" .. tostring(id) .. "].size\" is nil. This will cause the library to fail.")
                elseif type(data.size) == "number" then
                    if data.size <= 0 then
                        LogWarn("\"boards[" .. tostring(id) .. "].size\" must be greater than 0.")
                    end
                else
                    LogError("\"boards[" ..
                        tostring(id) .. "].size\" is not a number. This will cause the library to fail.")
                end
                if data.dungeons ~= nil then
                    if type(data.dungeons) == "table" then
                        if #data.dungeons > 0 then
                            for i, entry in ipairs(data.dungeons) do
                                if type(entry) ~= "string" then
                                    LogError("\"boards[" ..
                                        tostring(id) ..
                                        "].dungeons[" ..
                                        tostring(i) .. "]\" is not a valid zone id. This may cause the library to fail.")
                                end
                            end
                        else
                            LogWarn("\"boards[" .. tostring(id) .. "].dungeons\" is empty. This will make the board never generate anything.")
                        end
                    end
                end
                if type(data.job_types) == "table" then
                    for i, entry in ipairs(data.job_types) do
                        if type(entry) == "table" then
                            if not values.job_types[entry.id] then
                                LogError("\"boards[" ..
                                tostring(id) ..
                                "].job_types[" ..
                                tostring(i) .. "].id\" is not a valid job id. This may cause the library to fail.")
                            end
                            if entry.weight then
                                if type(entry.weight) == "number" then
                                    if entry.weight < 0 then
                                        LogWarn("\"boards[" ..
                                        tostring(id) ..
                                        "].job_types[" ..
                                        tostring(i) .. "].weight\" is less than 0. This may lead to unintended results.")
                                    end
                                else
                                    LogError("\"boards[" ..
                                    tostring(id) ..
                                    "].job_types[" ..
                                    tostring(i) .. "].weight\" is not number or nil. This may cause the library to fail.")
                                end
                            end
                        else
                            LogError("\"boards[" ..
                            tostring(id) ..
                            "].job_types[" .. tostring(i) .. "]\" is not a table. This will cause the library to fail.")
                        end
                    end
                else
                    LogError("\"boards[" ..
                    tostring(id) .. "].job_types\" is not a table. This will cause the library to fail.")
                end
                if not EqualToAny(type(data.condition), { "function", "nil" }) then
                    LogError("\"boards[" ..
                    tostring(id) .. "].condition\" is not a function or nil. This may cause the library to fail.")
                end
            else
                LogError("\"boards[" .. tostring(id) .. "]\" is not a table. This will cause the library to fail.")
            end
        end
    else
        LogError("\"boards\" is not a table. This will cause the library to fail.")
    end

    if not settings.extra_reward_type then
        LogWarn("\"extra_reward_type\" is nil. It will default to \"none\".")
    elseif type(settings.extra_reward_type) == "string" then
        if not EqualToAny(settings.extra_reward_type, { "exp", "rank", "none" }) then
            LogWarn("Value " ..
                tostring(settings.extra_reward_type) ..
                " is not a valid \"extra_reward_type\" id. It will default to \"none\".\n" ..
                "Valid keywords are: \"exp\", \"rank\", \"none\"")
        end
    else
        LogWarn("\"extra_reward_type\" is not a string. It will default to \"none\".")
    end

    if not settings.mission_callback_root then
        LogWarn(
        "\"hidden_floor_chance\" is nil. This will cause the library to fail if the callback functionality is used at any point.")
    elseif type(settings.mission_callback_root) ~= "table" then
        LogWarn(
        "\"hidden_floor_chance\" is not a number. This will cause the library to fail if the callback functionality is used at any point.")
    end

    if not settings.end_dungeon_day_destination then
        LogError("\"end_dungeon_day_destination\" is nil. This will cause the library to fail.")
    elseif type(settings.end_dungeon_day_destination) == "table" then
        checker.checkGroundLocationTable(settings.end_dungeon_day_destination, "end_dungeon_day_destination")
    else
        LogError("\"end_dungeon_day_destination\" is not a table. This will cause the library to fail.")
    end

    if not EqualToAny(type(settings.after_rewards_function), {"function", "nil"}) then
        LogError("\"after_rewards_function\" is not function or nil. This will cause the library to fail.")
    end

    if not settings.taken_limit then
        LogError("\"taken_limit\" is nil. This will cause the library to fail.")
    elseif type(settings.taken_limit) == "number" then
        if settings.taken_limit <= 0 then
            LogWarn("\"taken_limit\" must be greater than 0.")
        end
    else
        LogError("\"taken_limit\" is not a number. This will cause the library to fail.")
    end

    if settings.taken_jobs_start_active == nil then
        LogWarn("\"taken_jobs_start_active\" is nil. This may lead to unintended results.")
    elseif type(settings.taken_jobs_start_active) ~= "boolean" then
        LogWarn("\"taken_jobs_start_active\" is not a boolean. This may lead to unintended results.")
    end

    if not settings.max_guests then
        LogError("\"taken_limit\" is nil. This will cause the library to fail.")
    elseif type(settings.taken_limit) ~= "number" then
        LogError("\"taken_limit\" is not a number. This will cause the library to fail.")
    end

    if settings.guests_take_up_space == nil then
        LogWarn("\"guests_take_up_space\" is nil. This may lead to unintended results.")
    elseif type(settings.guests_take_up_space) ~= "boolean" then
        LogWarn("\"guests_take_up_space\" is not a boolean. This may lead to unintended results.")
    end

    if not settings.min_party_limit then
        LogError("\"min_party_limit\" is nil. This will cause the library to fail.")
    elseif type(settings.min_party_limit) == "number" then
        if settings.min_party_limit <= 0 then
            LogWarn("\"min_party_limit\" is 0 or less. It will default to 1.")
        end
    else
        LogError("\"min_party_limit\" is not a number. This will cause the library to fail.")
    end

    if settings.losing_guests_means_defeat == nil then
        LogWarn("\"losing_guests_means_defeat\" is nil. This may lead to unintended results.")
    elseif type(settings.losing_guests_means_defeat) ~= "boolean" then
        LogWarn("\"losing_guests_means_defeat\" is not a boolean. This may lead to unintended results.")
    end

    local priorities = { "dungeon_boss_steps_piority", "dungeon_gen_steps_piority", "dungeon_npc_steps_piority" }
    for _, priority_id in ipairs(priorities) do
        local priority_data = settings[priority_id] --[[@as (integer|integer[])]]
        if not priority_data then
            LogError("\"" .. tostring(priority_id) .. "\" is nil. This will cause the library to fail.")
        elseif type(priority_data) == "table" then
            for i, num in ipairs(priority_data) do
                if type(num) ~= "number" then
                    LogError("\"" ..
                    tostring(priority_id) ..
                    "[" .. tostring(i) .. "]\" is not a number. This will cause the library to fail.")
                end
            end
        elseif type(priority_data) ~= "number" then
            LogError("\"" .. tostring(priority_id) .. "\" is not number or table. This will cause the library to fail.")
        end
    end

    if not settings.guest_level_scaling then
        LogError("\"guest_level_scaling\" is nil. This will cause the library to fail.")
    elseif type(settings.guest_level_scaling) ~= "function" then
        LogError("\"guest_level_scaling\" is not a function. This will cause the library to fail.")
    end

    if not settings.outlaw_level_scaling then
        LogError("\"outlaw_level_scaling\" is nil. This will cause the library to fail.")
    elseif type(settings.outlaw_level_scaling) ~= "function" then
        LogError("\"outlaw_level_scaling\" is not a function. This will cause the library to fail.")
    end

    if not settings.apply_outlaw_changes then
        LogError("\"apply_outlaw_changes\" is nil. This will cause the library to fail.")
    elseif type(settings.apply_outlaw_changes) ~= "function" then
        LogError("\"apply_outlaw_changes\" is not a function. This will cause the library to fail.")
    end

    if not settings.fleeing_outlaw_restrictions then
        LogError("\"fleeing_outlaw_restrictions\" is nil. This will cause the library to fail.")
    elseif type(settings.fleeing_outlaw_restrictions) == "table" then
        for i, elem in ipairs(settings.fleeing_outlaw_restrictions) do
            if type(elem) == "string" then
                if not _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Element]:ContainsKey(elem) then
                    LogError("\"" ..
                    tostring(settings.fleeing_outlaw_restrictions) ..
                    "[" .. tostring(i) .. "]\" is not a valid element id and will therefore be ignored.")
                end
            else
                LogError("\"" ..
                tostring(settings.fleeing_outlaw_restrictions) ..
                "[" .. tostring(i) .. "]\" is not a string. This will cause the library to fail.")
            end
        end
    else
        LogError("\"fleeing_outlaw_restrictions\" is not a function. This will cause the library to fail.")
    end

    if not settings.outlaw_music_name then
        LogError("\"outlaw_music_name\" is nil. This will cause the library to fail.")
    elseif type(settings.outlaw_music_name) == "string" then
        --testing if the music file exists through lua seems extremely excruciating and probably not worth it. Might as well try to run it directly at this point
        local s = SOUND:GetCurrentSong()
        if not pcall(function()
                SOUND:PlayBGM(settings.outlaw_music_name, false, 1)
                SOUND:SetBGMVolume(0)
            end) then
            LogWarn("Value \"" ..
            tostring(settings.outlaw_music_name) ..
            "\" of \"outlaw_music_name\" is not a valid BGM name. This will cause errors when trying to play outlaw music.")
        end
        SOUND:PlayBGM(s, false, 1)
    else
        LogError("\"outlaw_music_name\" is not a string. This will cause the library to fail.")
    end


    if not settings.external_events then
        LogError("\"external_events\" is nil. This will cause the library to fail.")
    elseif type(settings.external_events) == "table" then
        for i, condition in ipairs(settings.external_events) do
            if type(condition) == "table" then
                if type(condition.condition) ~= "function" then
                    LogError("\"external_events[" ..
                    tostring(i) .. "].condition\" is not a function. This will cause the library to fail.")
                end
                if not EqualToAny(type(condition.icon), { "string", "nil" }) then
                    LogError("\"external_events[" ..
                    tostring(i) .. "].icon\" is not string or nil. This will cause the library to fail.")
                end
                if not EqualToAny(type(condition.message_key), { "string", "nil" }) then
                    LogError("\"external_events[" ..
                    tostring(i) .. "].message_key\" is not string or nil. This will cause the library to fail.")
                end
                if not EqualToAny(type(condition.message_args), { "function", "nil" }) then
                    LogError("\"external_events[" ..
                    tostring(i) .. "].message_args\" is not function or nil. This will cause the library to fail.")
                end
            else
                LogError("\"dungeon_list_pattern\" is not a table. This will cause the library to fail.")
            end
        end
    else
        LogError("\"external_events\" is not a string. This will cause the library to fail.")
    end

    if not settings.external_events_icon_mode then
        LogWarn("\"external_events_icon_mode\" is nil. It will default to \"ALL\".")
    elseif type(settings.external_events_icon_mode) == "string" then
        if not EqualToAny(settings.external_events_icon_mode, { "FIRST", "ALL" }) then
            LogWarn("Value " ..
                tostring(settings.external_events_icon_mode) ..
                " is not a valid \"external_events_icon_mode\" id. It will default to \"ALL\".\n" ..
                "Valid keywords are: \"FIRST\", \"ALL\"")
        end
    else
        LogWarn("\"external_events_icon_mode\" is not a string. It will default to \"none\".")
    end

    if not settings.dungeon_list_pattern then
        LogError("\"dungeon_list_pattern\" is nil. This will cause the library to fail.")
    elseif type(settings.dungeon_list_pattern) ~= "string" then
        LogError("\"dungeon_list_pattern\" is not a string. This will cause the library to fail.")
    end


    LogInfo("Sanity checker terminated with " .. tostring(warns) .. " warns and " .. tostring(errors) .. " errors.")
end

return checker
