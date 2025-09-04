-- PMDO Mission Generation Library v1.0.3, by MistressNebula
-- Settings file
-- ----------------------------------------------------------------------------------------- --
-- This file exists as a way to separate the library's configurable data from its functions.
-- If you are looking for the latter, please refer to missiongen_lib.lua
-- ----------------------------------------------------------------------------------------- --
-- This file is already loaded by missiongen_lib.lua. You don't need to require it
-- explicitly in your project.
-- ----------------------------------------------------------------------------------------- --
-- Make sure to also check the missiongen_service.lua file and ensure it will be able to
-- access the library by changing its "library_name" variable if necessary.

--- @alias jobType "RESCUE_SELF"|"RESCUE_FRIEND"|"ESCORT"|"EXPLORATION"|"DELIVERY"|"LOST_ITEM"|"OUTLAW"|"OUTLAW_ITEM"|"OUTLAW_ITEM_UNK"|"OUTLAW_MONSTER_HOUSE"|"OUTLAW_FLEE"
--- @alias rewardType "money"|"item"|"money_item"|"item_item"|"client"|"exclusive"
--- @alias emotionType "Normal"|"Happy"|"Pain"|"Angry"|"Worried"|"Sad"|"Crying"|"Shouting"|"Teary-Eyed"|"Determined"|"Joyous"|"Inspired"|"Surprised"|"Dizzy"|"Special0"|"Special1"|"Sigh"|"Stunned"|"Special2"|"Special3"
--- @alias eventId "JobTake"|"JobActivate"|"JobDeactivate"|"DungeonStart"|"DungeonEnd"|"FloorStart"|"JobComplete"|"JobFail"|"BeforeReward"|"AfterReward"
--- @alias AgentIDTable {Species:string, Form:integer|nil, Skin:string|nil, Gender:integer, Weight:integer|nil, Unique:boolean|nil}
--- @alias Character any RogueEssence.Dungeon.Character
--- @alias MonsterTeam any RogueEssence.Dungeon.MonsterTeam

local settings = {
    --- Name of the SV table that will contain all stored data. Use a table to specify a deeper path.
    --- If not present in the SV structure, the defined path will be generated automatically.
    --- An empty list would just use SV as root.
    --- Examples:
    --- * "jobs" would use SV.jobs as its root.
    --- * {"adventure", "jobs"} would use SV.adventure.jobs as its root.
    ---@type string|string[]
    sv_root_name = "jobs",
    --- A list of board ids and the data necessary to define their behavior.
    --- Format: <board_id> = {display_key = string, size = integer, location = {zone = string, map = integer}, condition = function, job_types = {{id = string, weight = integer}}}
    --- * <board_id>: you can use any string in place of this. It will be used to identify the board in scripts
    --- * display_key: the string key used when displaying the job menu for this board.  The localized strings are fetched from the Menu Text list (strings.resx)
    --- * size: the amount of quests this board can hold at a time
    --- * location: a zone id and a map index. This data is where the player will be brought for the job completion cutscene. All of these maps must call library:PlayJobsCompletedCutscene before fade-in for the reward sequence to work correctly.
    --- * condition: Optional. A function called to determine if library:PopulateBoards() should fill out this board. It receives the library object as an argument and returns a boolean. If it returns true, the board is filled out. If it returns false, it is left empty. If this property is missing, this board will always be active.
    --- * job_types: a list of job types and their probability weight. Higher weight means more common.
    ---@type table<string, {display_key:string, size:integer, condition:fun(library:table):(boolean)|nil, location:{zone:string, map:integer}, job_types:{id:string, weight:integer}[], dungeons:string[]|nil}>
    boards = {
        quest_board = {
            display_key = "BOARD_QUEST_TITLE",
            size = 8,
            location = {zone = "guildmaster_island", map = 2},
            condition = function (library)
                ---@type LibraryRootStruct
                local root = library.root
                local completed = 0
                for _, segments in pairs(root.dungeon_progress) do
                    for _, state in pairs(segments) do
                        if state then
                            completed = completed + 1
                            if completed>=3 then return true end
                            break --count only once no matter how many segments are completed
                        end
                    end
                end
                return false
            end,
            job_types = {
                {id = "RESCUE_SELF", weight = 5},
                {id = "RESCUE_FRIEND", weight = 5},
                {id = "ESCORT", weight = 2},
                {id = "EXPLORATION", weight = 2},
                {id = "DELIVERY", weight = 2},
                {id = "LOST_ITEM", weight = 4},
                {id = "OUTLAW", weight =  5},
                {id = "OUTLAW_ITEM", weight = 2},
                {id = "OUTLAW_ITEM_UNK", weight = 1},
                {id = "OUTLAW_MONSTER_HOUSE", weight = 1},
                {id = "OUTLAW_FLEE", weight = 1}
            }
        }
    },
    --- Zone and map id of the ground map where players will be sent to when a day ends and there is at least one mission to hand in.
    --- This map must contain a call to library:PlayJobsCompletedCutscene
    --- Format: {zone = string, map = integer}
    ---@type {zone:string, map:integer}
    end_dungeon_day_destination = { zone = "guildmaster_island", map = 2 },
    --- Function ran after the game is done with the job completion cutscene.
    --- It takes no arguments, and is not expected to return anything.
    --- You can use it to fix up the game state however you like before returning control to the player.
    ---@type fun()
    after_rewards_function = function()
        GAME:MoveCamera(0, 0, 1, true)
        SOUND:PlayBGM(SV.base_town.Song, true)
    end,
    --- The maximum number of jobs that can be taken from job boards at a time.
    ---@type integer
    taken_limit = 8,
    --- If true, taken jobs will be activated automatically. Players can always deactivate them manually if they so choose.
    ---@type boolean
    taken_jobs_start_active = true,
    --- The maximum amount of guest-based jobs that can be generated in the same dungeon.
    --- Guest-based jobs are: ESCORT, EXPLORATION
    ---@type integer
    max_guests = 1,
    --- If true, guests will reduce the party size by 1 each.
    --- This cannot lower the party size below 1, for obvious reasons.
    --- Any excess guests will simply add to the party count.
    ---@type boolean
    guests_take_up_space = true,
    --- Minimum number for the party limit when it is reduced because of guests.
    --- This value cannot be lower than 1, for obvious reasons.
    --- Any excess guests will simply add to the party count, without reducing the limit.
    ---@type integer
    min_party_limit = 1,
    --- If true, losing any guest will count as a loss for the entire exploration.
    --- If false, it will simply mark that specific job as failed.
    ---@type boolean
    losing_guests_means_defeat = false,
    --- The priority of the SpawnOutlaw handler event.
    --- This value should always be lower than dungeon_gen_steps_piority.
    ---@type integer|integer[]
    dungeon_boss_steps_piority = -11,
    --- The priority that most of the job handlers will have when being added to the event list.
    --- This value should always be equal to or higher than the priority set for the event that calls library:GenerateJobInFloor.
    ---@type integer|integer[]
    dungeon_gen_steps_piority = -6,
    --- The priority that job npc spawners will have when being added to the event list.
    --- This value should always be equal to or higher than dungeon_gen_steps_piority.
    ---@type integer|integer[]
    dungeon_npc_steps_piority = {5, 2, 1},
    --- Define here, in the order you want them to be in, the list of all difficulty rank ids you want to use.
    ---@type string[]
    difficulty_list = {"F", "E", "D", "C", "B", "A", "S", "STAR_1", "STAR_2", "STAR_3", "STAR_4", "STAR_5", "STAR_6", "STAR_7", "STAR_8", "STAR_9"},
    --- Clone of difficulty_list. Autogenerated on startup. Any value written here will be lost on load.
    ---@type table<integer,string>
    num_to_difficulty = {},
    --- Backwards reference for difficulty_list. Autogenerated on startup. Any value written here will be lost on load.
    ---@type table<string,integer>
    difficulty_to_num = {},
    --- All the data required to define difficulty rank behavior. There must be an entry for every rank defined in difficulty_list:
    --- Format : <diff_id> = {display_key, money_reward, extra_reward, outlaw_level, escort_level}
    --- * <diff_id> = one of the difficulties defined in "difficulty_list"
    --- * display_key: string key used when displaying the name of the rank.  The localized strings are fetched from the Menu Text list (strings.resx)
    --- * money_reward: the amount of money awarded at the end of the job. If set to 0, money rewards will simply not award anything
    --- * extra_reward: the points of extra reward awarded at the end of the job. What these points are depends on extra_reward_type. If set to 0, extra_reward_type will be considered to be "none"
    --- * outlaw_level: Optional. The base level of all outlaws spawned by jobs with this difficulty. If omitted, it will be equal to the dungeon's expected level.
    --- * escort_level: Optional. The level of all guests spawned by jobs with this difficulty. If omitted, it will be equal to the dungeon's expected level.
    ---@type table<string, {display_key:string, money_reward:integer, extra_reward:integer, outlaw_level:integer|nil, escort_level:integer|nil}>
    difficulty_data = {
        F = {display_key = "RANK_STRING_F", money_reward = 100, extra_reward = 0},
        E = {display_key = "RANK_STRING_E", money_reward = 200, extra_reward = 100},
        D = {display_key = "RANK_STRING_D", money_reward = 400, extra_reward = 200},
        C = {display_key = "RANK_STRING_C", money_reward = 600, extra_reward = 400},
        B = {display_key = "RANK_STRING_B", money_reward = 700, extra_reward = 1250},
        A = {display_key = "RANK_STRING_A", money_reward = 1500, extra_reward = 2500},
        S = {display_key = "RANK_STRING_S", money_reward = 3000, extra_reward = 5000},
        STAR_1 = {display_key = "RANK_STRING_STAR_1", money_reward = 6000, extra_reward = 10000},
        STAR_2 = {display_key = "RANK_STRING_STAR_2", money_reward = 10000, extra_reward = 20000},
        STAR_3 = {display_key = "RANK_STRING_STAR_3", money_reward = 15000, extra_reward = 30000},
        STAR_4 = {display_key = "RANK_STRING_STAR_4", money_reward = 20000, extra_reward = 40000},
        STAR_5 = {display_key = "RANK_STRING_STAR_5", money_reward = 25000, extra_reward = 50000},
        STAR_6 = {display_key = "RANK_STRING_STAR_6", money_reward = 30000, extra_reward = 60000},
        STAR_7 = {display_key = "RANK_STRING_STAR_7", money_reward = 35000, extra_reward = 70000},
        STAR_8 = {display_key = "RANK_STRING_STAR_8", money_reward = 40000, extra_reward = 80000},
        STAR_9 = {display_key = "RANK_STRING_STAR_9", money_reward = 45000, extra_reward = 90000}
    },
    --- Function that changes the level of guests based on the player's level. It must return the new level for the guest, or it will have no effect.
    --- Arguments:
    --- * lvl: base level of the guest.
    --- * dungeon: if true, the level is the dungeon's recommended level. If false, it's taken from the difficulty data.
    --- * avg_team_lvl: average level of the player team. It may or may not be an integer.
    --- * hst_team_lvl: highest level in the player team.
    --- * settings: the settings data structure itself
    ---@type fun(lvl:integer, dungeon:boolean, avg_team_lvl:integer, hst_team_lvl:integer, settings: table): integer
    guest_level_scaling = function(lvl, dungeon, avg_team_lvl, hst_team_lvl, settings)
        local add = 0
        if dungeon then lvl = lvl*4//5 end -- set to 80% of dungeon default
        if avg_team_lvl > lvl then add = (avg_team_lvl - lvl) // 10 end -- add 10% of the level difference between guest and average
        return lvl + add
    end,
    --- Function that changes the level of outlaws based on the player's level. It must return the new level for the outlaw, or it will have no effect.
    --- * lvl: base level of the outlaw.
    --- * dungeon: if true, the level is the dungeon's recommended level. If false, it's taken from the difficulty data.
    --- * avg_team_lvl: average level of the player team. It may or may not be an integer.
    --- * hst_team_lvl: highest level in the player team.
    --- * settings: the settings data structure itself
    ---@type fun(lvl:integer, dungeon:boolean, avg_team_lvl:integer, hst_team_lvl:integer, settings: table): integer
    outlaw_level_scaling = function(lvl, dungeon, avg_team_lvl, hst_team_lvl, settings)
        local add = 0
        if dungeon then lvl = lvl*23//20 end -- set to 115% of dungeon default
        if avg_team_lvl > lvl then add = (avg_team_lvl - lvl) // 8 end -- add 10% of the level difference between outlaw and average
        add = add + (hst_team_lvl - avg_team_lvl) // 4 -- add 25% of the level difference between average and highest in the team
        return lvl + add
    end,
    --- Function that allows you to edit an outlaw's data just before they are spawned.
    --- You can change just about anything except its position and recruitability state. Its HP will also
    --- always be automatically set to full after this function is called.
    --- You will also be unable to change the EquippedItem of an "OUTLAW_ITEM" or "OUTLAW_ITEM_UNK" outlaw.
    ---@type fun(outlaw:Character, job:jobTable)
    apply_outlaw_changes = function(outlaw, job)
        local max_boost = PMDC.Data.MonsterFormData.MAX_STAT_BOOST
        outlaw.MaxHPBonus = math.min(outlaw.Level * max_boost // 64, max_boost);
        if job.Type == "OUTLAW_FLEE" then
            local speedMin = math.floor(outlaw.Level * 4 // 3)
            local speedMax = math.floor(outlaw.Level * 6 // 2)
            outlaw.SpeedBonus = math.min(_DATA.Save.Rand:Next(speedMin, speedMax), 100)
        end
    end,
    --- A list of ids for types that are banned from ever being picked as fleeing outlaws.
    ---@type string[]
    fleeing_outlaw_restrictions = {"ghost"},
    --- The name of the outlaw music file. This file will be sourced from the Content/Music folder.
    ---@type string
    outlaw_music_name = "Outlaw.ogg",
    --- This is where dungeon difficulty is set. Quests can only generate for dungeons inside this list.
    --- Given the complexity of this structure, it is best generated using the "AddDungeonSection" function near the bottom of this file.
    ---@type table<string, table<integer, {max_floor:integer, must_end:boolean, sections:{start:integer, difficulty:string}[]}>>
    dungeons = {},
    --- Jobs are sorted by dungeon, following this order. Missing dungeons are shoved at the bottom and sorted alphabetically.
    --- This list is automatically populated in call order when using the "AddDungeonSection" function near the bottom of this file.
    ---@type table<string, integer>
    dungeon_order = {},
    --- A list of events unrelated to this library that can cause job generation to ignore a specific dungeon.
    --- They can also be displayed in the objectives log if you so choose.
    --- Format: {condition = function, message_key = string, message_args = function, icon = string}
    --- * condition: a function that takes a zone and returns a boolean. If it returns true,
    ---   jobs will not be generated for this dungeon, and all already taken jobs will be automatically suspended.
    --- * message_key: Optional. It will be used in the objectives log instead of the default message if the condition is true.
    --- * message_args: Optional. If the message's localization string contains placeholders, this function is in charge of
    ---   taking a zone and returning a list of values that will be used for those placeholders in the form of a table array (Up to 5).
    --- * icon: Optional. The icon that will be displayed beside the corresponding dungeon in the dungeon selection menu
    ---   if the condition is true for any of its segments. Defaults to ""
    ---@type {condition:fun(zone:string):(boolean), message_key:string|nil,
    ---       message_args:fun(zone:string):(string[])|nil, icon:string|nil}[]
    external_events = {
        {condition = function(zone) return COMMON.HasSidequestInZone(zone) end, icon = "\\uE111", message_key = "MENU_JOB_OBJECTIVE_DEFAULT"}
    },
    --- How to display external event icons in the dungeon list. This value can only be either "FIRST" or ALL".
    --- * If set to "ALL", they will always be displayed in the order defined by external_events.
    --- Only one copy of the same icon will be shown, no matter how many conditions require it.
    --- * If set to "FIRST", only the first event in the list's order will be displayed, no matter how many events are actually there.
    --- This setting does not prevent multiple messages from appearing in the objectives list.
    ---@type "FIRST"|"ALL"
    external_events_icon_mode = "FIRST",
    --- The pattern that will define how to display entries in the dungeon list.
    --- {0} is the placeholder for the dungeon name, {1} for pending job icon and {2} for external condition icons.
    ---@type string
    dungeon_list_pattern = "{2}{1}{0}",
    --- Use this table to determine various properties regarding job types.
    --- Remove a job type entirely to disable its generation altogether.
    --- Format: <job_type_id> = {rank_modifier = integer, min_rank = string}
    --- * <job_type_id>: one of RESCUE_SELF, RESCUE_FRIEND, ESCORT, EXPLORATION, DELIVERY, LOST_ITEM, OUTLAW, OUTLAW_ITEM, OUTLAW_ITEM_UNK, OUTLAW_MONSTER_HOUSE, OUTLAW_FLEE
    --- * rank_modifier (optional): these jobs will always have this modifier applied to their rank.
    --- * min_rank (optional): this type of jobs can never be of a rank lower than this.
    --- This influences possible dungeon spawn: a rank_modifier 1 job with min_rank "C" can also spawn in "D" rank dungeons.
    ---@type table<jobType,{rank_modifier:integer|nil, min_rank:string|nil}>
    job_types = {
        RESCUE_SELF = {rank_modifier = 0, min_rank = "F"},
        RESCUE_FRIEND = {rank_modifier = 0, min_rank = "E"},
        ESCORT = {rank_modifier = 1, min_rank = "C"},
        EXPLORATION = {rank_modifier = 1, min_rank = "C"},
        DELIVERY = {rank_modifier = 0, min_rank = "D"},
        LOST_ITEM = {rank_modifier = 0, min_rank = "D"},
        OUTLAW = {rank_modifier = 1, min_rank = "C"},
        OUTLAW_ITEM = {rank_modifier = 1, min_rank = "C"},
        OUTLAW_ITEM_UNK = {rank_modifier = 1, min_rank = "C"},
        OUTLAW_MONSTER_HOUSE = {rank_modifier = 2, min_rank = "S"},
        OUTLAW_FLEE = {rank_modifier = 1, min_rank = "B"}
    },
    --- This is a special table where you can specify chance multipliers for job types depending on the dungeon.
    --- Format: <dungeon_id> = {<job_type_id> = \<multiplier\>}
    --- * <dungeon_id>: the string id of a dungeon
    --- * <job_type_id>: one of RESCUE_SELF, RESCUE_FRIEND, ESCORT, EXPLORATION, DELIVERY, LOST_ITEM, OUTLAW, OUTLAW_ITEM, OUTLAW_ITEM_UNK, OUTLAW_MONSTER_HOUSE, OUTLAW_FLEE
    --- * \<multiplier\>: a multiplier number. It doesn't need to be an integer. It will be multiplied with the board's base chances, rounding up, when choosing the type of a job.
    --- Set it to 0 or less to disable the job type altogether.
    --- @type table<string, table<jobType, number>>
    dungeon_job_modifiers = {
        ambush_forest = {
            OUTLAW = 3,
            OUTLAW_ITEM = 3,
            OUTLAW_ITEM_UNK = 3,
            OUTLAW_MONSTER_HOUSE = 3,
            OUTLAW_FLEE = 3
        },
        treacherous_mountain = {
            OUTLAW = 3,
            OUTLAW_ITEM = 3,
            OUTLAW_ITEM_UNK = 3,
            OUTLAW_MONSTER_HOUSE = 3,
            OUTLAW_FLEE = 3
        }
    },
    --- Chance of special missions to be generated. Special missions are just handcrafted scenarios with specific
    --- client and target pairs and custom flavor texts. Set to 0 to disable altogether.
    ---@type number
    special_chance = 0.2,
    --- This is where you can define special cases for specific types of jobs.
    --- Format: <job_type_id> = {<special_id>}
    --- * <job_type_id>: one of RESCUE_SELF, RESCUE_FRIEND, ESCORT, EXPLORATION, DELIVERY, LOST_ITEM, OUTLAW, OUTLAW_ITEM, OUTLAW_ITEM_UNK, OUTLAW_MONSTER_HOUSE, OUTLAW_FLEE
    --- * <special_id>: any id of your choosing except RESCUE_SELF, RESCUE_FRIEND, ESCORT, EXPLORATION, DELIVERY, LOST_ITEM, OUTLAW, OUTLAW_ITEM, OUTLAW_ITEM_UNK, OUTLAW_MONSTER_HOUSE, OUTLAW_FLEE
    ---@type table<jobType,string[]>
    special_jobs = {
        RESCUE_FRIEND = {"CHILD", "LOVER", "RIVAL", "FRIEND"}
    },
    --- Chance for supported quest types to have their destination floor hidden. Set to 0 to disable altogether.
    --- Players will still be notified when reaching the floor. It just won't show in the quest description.
    --- Job types that can have their floor hidden are: RESCUE_FRIEND, EXPLORATION, OUTLAW, OUTLAW_ITEM, OUTLAW_ITEM_UNK, OUTLAW_FLEE.
    ---@type number
    hidden_floor_chance = 0.15,
    --- A list of all types of rewards to be offered to players.
    --- Format: {id = string, weight = integer, min_rank = string}
    --- * id: one of the supported reward types. You can use duplicate values to alter odds depending on job rank.
    --- Supported reward types are: item, money, item_item, money_item, client, exclusive
    --- * weight: Chance of appearing. Set to 0 or delete altogether to stop a type of reward from being offered.
    --- * min_rank: optional. If set, this type of reward will only be offered if the job is this rank or higher.
    ---@type {id:rewardType, weight:integer, min_rank:string|nil}[]
    reward_types = {
        {id = "item", weight = 6},
        {id = "money", weight = 2},
        {id = "item_item", weight = 3},  -- second item hidden
        {id = "money_item", weight = 1}, -- item is hidden
        {id = "client", weight = 1, min_rank = "STAR_1"},     -- appears as ???
        {id = "exclusive", weight = 1, min_rank = "STAR_4"}   -- appears as ???. Award a 1* xcl item of client, or of target if law enforcement mission.
    },
    --- The type of extra reward for all quests. It can be "none", "rank" or "exp". Any other value will result in "none".
    ---@type "none"|"rank"|"exp"
    extra_reward_type = "exp",
    --- Use this table to assign different weights to reward pools depending on the difficulty rank of the mission.
    --- <diff_id> = {{id = string, weight = integer}}
    --- * <diff_id> = one of the difficulties defined in "difficulty_list"
    --- * id = the id of one of the reward pools defined in "reward_pools"
    --- * weight = Chance of appearing. Set to 0 or delete altogether to stop a reward pool from being picked.
    --- @type table<string,{id:string, weight:integer}[]>
    rewards_per_difficulty = {
        F = {
            {id = "NECESSITIES", weight = 10}, --Basic stuff (i.e. reviver seeds, escape orbs, leppa berries) *
            {id = "AMMO_LOW", weight = 0},
            {id = "AMMO_MID", weight = 0},
            {id = "AMMO_HIGH", weight = 0},
            {id = "APRICORN_GENERIC", weight = 0},
            {id = "APRICORN_TYPED", weight = 0},
            {id = "FOOD_LOW", weight = 0},
            {id = "FOOD_MID", weight = 0},
            {id = "FOOD_HIGH", weight = 0},
            {id = "MEDICINE_LOW", weight = 0},
            {id = "MEDICINE_HIGH", weight = 0},
            {id = "SEED_LOW", weight = 0},
            {id = "SEED_MID", weight = 0},
            {id = "SEED_HIGH", weight = 0},
            {id = "HELD_LOW", weight = 0},
            {id = "HELD_MID", weight = 0},
            {id = "HELD_HIGH", weight = 0},
            {id = "HELD_TYPE", weight = 0},
            {id = "HELD_PLATES", weight = 0},
            {id = "LOOT_LOW", weight = 0},
            {id = "LOOT_HIGH", weight = 0},
            {id = "EVO_ITEMS", weight = 0},
            {id = "ORBS_LOW", weight = 0},
            {id = "ORBS_MID", weight = 0},
            {id = "ORBS_HIGH", weight = 0},
            {id = "WANDS_LOW", weight = 0},
            {id = "WANDS_MID", weight = 0},
            {id = "WANDS_HIGH", weight = 0},
            {id = "TM_LOW", weight = 0},
            {id = "TM_MID", weight = 0},
            {id = "TM_HIGH", weight = 0},
            {id = "SPECIAL", weight = 0}
        },
        E = {
            {id = "NECESSITIES", weight = 10},  --Basic stuff (i.e. reviver seeds, escape orbs, leppa berries) *
            {id = "AMMO_LOW", weight = 0},
            {id = "AMMO_MID", weight = 0},
            {id = "AMMO_HIGH", weight = 0},
            {id = "APRICORN_GENERIC", weight = 10}, --Generic (non-typed) apricorns with a max catch bonus below 35 *
            {id = "APRICORN_TYPED", weight = 0},
            {id = "FOOD_LOW", weight = 10}, --Basic food, small chance of gummis *
            {id = "FOOD_MID", weight = 0},
            {id = "FOOD_HIGH", weight = 0},
            {id = "MEDICINE_LOW", weight = 0},
            {id = "MEDICINE_HIGH", weight = 0},
            {id = "SEED_LOW", weight = 10}, --Basic seeds, berries, white herbs *
            {id = "SEED_MID", weight = 0},
            {id = "SEED_HIGH", weight = 0},
            {id = "HELD_LOW", weight = 3}, --Basic stat boosting held items and ones with a net drawback (Iron Ball, Flame Orb, etc.)
            {id = "HELD_MID", weight = 0},
            {id = "HELD_HIGH", weight = 0},
            {id = "HELD_TYPE", weight = 0},
            {id = "HELD_PLATES", weight = 0},
            {id = "LOOT_LOW", weight = 3}, --Keys, pearls, assembly boxes
            {id = "LOOT_HIGH", weight = 0},
            {id = "EVO_ITEMS", weight = 1}, --Evolution items, high chance of link cables
            {id = "ORBS_LOW", weight = 0},
            {id = "ORBS_MID", weight = 0},
            {id = "ORBS_HIGH", weight = 0},
            {id = "WANDS_LOW", weight = 10}, --Weak wands *
            {id = "WANDS_MID", weight = 0},
            {id = "WANDS_HIGH", weight = 0},
            {id = "TM_LOW", weight = 0},
            {id = "TM_MID", weight = 0},
            {id = "TM_HIGH", weight = 0},
            {id = "SPECIAL", weight = 0}
        },
        D = {
            {id = "NECESSITIES", weight = 5},  --Basic stuff (i.e. reviver seeds, escape orbs, leppa berries)
            {id = "AMMO_LOW", weight = 10}, --Mostly iron thorns, with some weaker ammo *
            {id = "AMMO_MID", weight = 0},
            {id = "AMMO_HIGH", weight = 0},
            {id = "APRICORN_GENERIC", weight = 10}, --Generic (non-typed) apricorns with a max catch bonus below 35 *
            {id = "APRICORN_TYPED", weight = 2}, --Type and glitter apricorns
            {id = "FOOD_LOW", weight = 4}, --Basic food, small chance of gummis
            {id = "FOOD_MID", weight = 0},
            {id = "FOOD_HIGH", weight = 0},
            {id = "MEDICINE_LOW", weight = 0},
            {id = "MEDICINE_HIGH", weight = 0},
            {id = "SEED_LOW", weight = 4}, --Basic seeds, berries, white herbs
            {id = "SEED_MID", weight = 10}, --Advanced seeds and type berries *
            {id = "SEED_HIGH", weight = 0},
            {id = "HELD_LOW", weight = 10}, --Basic stat boosting held items and ones with a net drawback (Iron Ball, Flame Orb, etc.) *
            {id = "HELD_MID", weight = 0},
            {id = "HELD_HIGH", weight = 0},
            {id = "HELD_TYPE", weight = 3}, --Held items that boost a specific type
            {id = "HELD_PLATES", weight = 0},
            {id = "LOOT_LOW", weight = 10}, --Keys, pearls, assembly boxes *
            {id = "LOOT_HIGH", weight = 0},
            {id = "EVO_ITEMS", weight = 2}, --Evolution items, high chance of link cables
            {id = "ORBS_LOW", weight = 2}, --Weak wonder orbs
            {id = "ORBS_MID", weight = 0},
            {id = "ORBS_HIGH", weight = 0},
            {id = "WANDS_LOW", weight = 4}, --Weak wands
            {id = "WANDS_MID", weight = 10}, --Medium wands *
            {id = "WANDS_HIGH", weight = 0},
            {id = "TM_LOW", weight = 0},
            {id = "TM_MID", weight = 0},
            {id = "TM_HIGH", weight = 0},
            {id = "SPECIAL", weight = 0}
        },
        C = {
            {id = "NECESSITIES", weight = 4},  --Basic stuff (i.e. reviver seeds, escape orbs, leppa berries)
            {id = "AMMO_LOW", weight = 4}, --Mostly iron thorns, with some weaker ammo
            {id = "AMMO_MID", weight = 2}, --Stronger generic ammo that you find in most dungeons
            {id = "AMMO_HIGH", weight = 0},
            {id = "APRICORN_GENERIC", weight = 4}, --Generic (non-typed) apricorns with a max catch bonus below 35
            {id = "APRICORN_TYPED", weight = 10}, --Type and glitter apricorns *
            {id = "FOOD_LOW", weight = 4}, --Basic food, small chance of gummis
            {id = "FOOD_MID", weight = 10}, --Big food, medium chance of gummis *
            {id = "FOOD_HIGH", weight = 0},
            {id = "MEDICINE_LOW", weight = 0},
            {id = "MEDICINE_HIGH", weight = 0},
            {id = "SEED_LOW", weight = 4}, --Basic seeds, berries, white herbs
            {id = "SEED_MID", weight = 4}, --Advanced seeds and type berries
            {id = "SEED_HIGH", weight = 0},
            {id = "HELD_LOW", weight = 4}, --Basic stat boosting held items and ones with a net drawback (Iron Ball, Flame Orb, etc.)
            {id = "HELD_MID", weight = 0},
            {id = "HELD_HIGH", weight = 0},
            {id = "HELD_TYPE", weight = 3}, --Held items that boost a specific type
            {id = "HELD_PLATES", weight = 10}, --Held items that reduce damage from a specific type *
            {id = "LOOT_LOW", weight = 4}, --Keys, pearls, assembly boxes
            {id = "LOOT_HIGH", weight = 0},
            {id = "EVO_ITEMS", weight = 4}, --Evolution items, high chance of link cables
            {id = "ORBS_LOW", weight = 10}, --Weak wonder orbs *
            {id = "ORBS_MID", weight = 2}, --Medium wonder orbs, many can shut down a monster house
            {id = "ORBS_HIGH", weight = 0},
            {id = "WANDS_LOW", weight = 4}, --Weak wands
            {id = "WANDS_MID", weight = 4}, --Medium wands
            {id = "WANDS_HIGH", weight = 0},
            {id = "TM_LOW", weight = 10}, --TMs for weak moves *
            {id = "TM_MID", weight = 0},
            {id = "TM_HIGH", weight = 0},
            {id = "SPECIAL", weight = 0}
        },
        B = {
            {id = "NECESSITIES", weight = 3},  --Basic stuff (i.e. reviver seeds, escape orbs, leppa berries)
            {id = "AMMO_LOW", weight = 0},
            {id = "AMMO_MID", weight = 10}, --Stronger generic ammo that you find in most dungeons *
            {id = "AMMO_HIGH", weight = 2}, --Rare ammo that are hard to find in dungeons
            {id = "APRICORN_GENERIC", weight = 0},
            {id = "APRICORN_TYPED", weight = 10}, --Type and glitter apricorns *
            {id = "FOOD_LOW", weight = 3}, --Basic food, small chance of gummis
            {id = "FOOD_MID", weight = 5}, --Big food, medium chance of gummis
            {id = "FOOD_HIGH", weight = 0},
            {id = "MEDICINE_LOW", weight = 2}, --Weaker medicine that can't heal all PP or HP at once
            {id = "MEDICINE_HIGH", weight = 0},
            {id = "SEED_LOW", weight = 0},
            {id = "SEED_MID", weight = 4}, --Advanced seeds and type berries
            {id = "SEED_HIGH", weight = 3}, --Includes rare seeds and berries, skews to Pure Seeds
            {id = "HELD_LOW", weight = 3}, --Basic stat boosting held items and ones with a net drawback (Iron Ball, Flame Orb, etc.)
            {id = "HELD_MID", weight = 10}, --Held items very useful for a specific strategy *
            {id = "HELD_HIGH", weight = 0},
            {id = "HELD_TYPE", weight = 3}, --Held items that boost a specific type
            {id = "HELD_PLATES", weight = 3}, --Held items that reduce damage from a specific type
            {id = "LOOT_LOW", weight = 4}, --Keys, pearls, assembly boxes
            {id = "LOOT_HIGH", weight = 0},
            {id = "EVO_ITEMS", weight = 5}, --Evolution items, high chance of link cables
            {id = "ORBS_LOW", weight = 4}, --Weak wonder orbs
            {id = "ORBS_MID", weight = 10}, --Medium wonder orbs, many can shut down a monster house *
            {id = "ORBS_HIGH", weight = 0},
            {id = "WANDS_LOW", weight = 0},
            {id = "WANDS_MID", weight = 3}, --Medium wands
            {id = "WANDS_HIGH", weight = 10}, --Rare, specialty wands *
            {id = "TM_LOW", weight = 4}, --TMs for weak moves
            {id = "TM_MID", weight = 2}, --TMs for moderate moves
            {id = "TM_HIGH", weight = 0},
            {id = "SPECIAL", weight = 0}
        },
        A = {
            {id = "NECESSITIES", weight = 2},  --Basic stuff (i.e. reviver seeds, escape orbs, leppa berries)
            {id = "AMMO_LOW", weight = 0},
            {id = "AMMO_MID", weight = 3}, --Stronger generic ammo that you find in most dungeons
            {id = "AMMO_HIGH", weight = 10}, --Rare ammo that are hard to find in dungeons *
            {id = "APRICORN_GENERIC", weight = 0},
            {id = "APRICORN_TYPED", weight = 10}, --Type and glitter apricorns *
            {id = "FOOD_LOW", weight = 0},
            {id = "FOOD_MID", weight = 4}, --Big food, medium chance of gummis
            {id = "FOOD_HIGH", weight = 2}, --Huge food with a high chance of wonder gummis and a chance for vitamins
            {id = "MEDICINE_LOW", weight = 10}, --Weaker medicine that can't heal all PP or HP at once *
            {id = "MEDICINE_HIGH", weight = 0},
            {id = "SEED_LOW", weight = 0},
            {id = "SEED_MID", weight = 3}, --Advanced seeds and type berries
            {id = "SEED_HIGH", weight = 10}, --Includes rare seeds and berries, skews to Pure Seeds *
            {id = "HELD_LOW", weight = 0},
            {id = "HELD_MID", weight = 5}, --Held items very useful for a specific strategy
            {id = "HELD_HIGH", weight = 2}, --Held items useful for anyone
            {id = "HELD_TYPE", weight = 3}, --Held items that boost a specific type
            {id = "HELD_PLATES", weight = 3}, --Held items that reduce damage from a specific type
            {id = "LOOT_LOW", weight = 3}, --Keys, pearls, assembly boxes
            {id = "LOOT_HIGH", weight = 10}, --Rare loot, skews towards heart scales *
            {id = "EVO_ITEMS", weight = 10}, --Evolution items, high chance of link cables *
            {id = "ORBS_LOW", weight = 0},
            {id = "ORBS_MID", weight = 4}, --Medium wonder orbs, many can shut down a monster house
            {id = "ORBS_HIGH", weight = 4}, --Rare, powerful wonder orbs often with map wide effects
            {id = "WANDS_LOW", weight = 0},
            {id = "WANDS_MID", weight = 2}, --Medium wands
            {id = "WANDS_HIGH", weight = 5}, --Rare, specialty wands
            {id = "TM_LOW", weight = 2}, --TMs for weak moves
            {id = "TM_MID", weight = 10}, --TMs for moderate moves *
            {id = "TM_HIGH", weight = 0},
            {id = "SPECIAL", weight = 0}
        },
        S = {
            {id = "NECESSITIES", weight = 2},  --Basic stuff (i.e. reviver seeds, escape orbs, leppa berries)
            {id = "AMMO_LOW", weight = 0},
            {id = "AMMO_MID", weight = 2}, --Stronger generic ammo that you find in most dungeons
            {id = "AMMO_HIGH", weight = 5}, --Rare ammo that are hard to find in dungeons
            {id = "APRICORN_GENERIC", weight = 0},
            {id = "APRICORN_TYPED", weight = 5}, --Type and glitter apricorns
            {id = "FOOD_LOW", weight = 0},
            {id = "FOOD_MID", weight = 2}, --Big food, medium chance of gummis
            {id = "FOOD_HIGH", weight = 10}, --Huge food with a high chance of wonder gummis and a chance for vitamins *
            {id = "MEDICINE_LOW", weight = 4}, --Weaker medicine that can't heal all PP or HP at once
            {id = "MEDICINE_HIGH", weight = 10}, --Powerful medicine that can heal everything *
            {id = "SEED_LOW", weight = 0},
            {id = "SEED_MID", weight = 0},
            {id = "SEED_HIGH", weight = 5}, --Includes rare seeds and berries, skews to Pure Seeds
            {id = "HELD_LOW", weight = 0},
            {id = "HELD_MID", weight = 3}, --Held items very useful for a specific strategy
            {id = "HELD_HIGH", weight = 10}, --Held items useful for anyone *
            {id = "HELD_TYPE", weight = 3}, --Held items that boost a specific type
            {id = "HELD_PLATES", weight = 3}, --Held items that reduce damage from a specific type
            {id = "LOOT_LOW", weight = 2}, --Keys, pearls, assembly boxes
            {id = "LOOT_HIGH", weight = 10}, --Rare loot, skews towards heart scales *
            {id = "EVO_ITEMS", weight = 10}, --Evolution items, high chance of link cables *
            {id = "ORBS_LOW", weight = 0},
            {id = "ORBS_MID", weight = 2}, --Medium wonder orbs, many can shut down a monster house
            {id = "ORBS_HIGH", weight = 5}, --Rare, powerful wonder orbs often with map wide effects
            {id = "WANDS_LOW", weight = 0},
            {id = "WANDS_MID", weight = 2}, --Medium wands
            {id = "WANDS_HIGH", weight = 4}, --Rare, specialty wands
            {id = "TM_LOW", weight = 0},
            {id = "TM_MID", weight = 4}, --TMs for moderate moves
            {id = "TM_HIGH", weight = 10}, --TMs for very powerful moves *
            {id = "SPECIAL", weight = 0}
        },
        STAR_1 = {
            {id = "NECESSITIES", weight = 0},
            {id = "AMMO_LOW", weight = 0},
            {id = "AMMO_MID", weight = 2}, --Stronger generic ammo that you find in most dungeons
            {id = "AMMO_HIGH", weight = 5}, --Rare ammo that are hard to find in dungeons
            {id = "APRICORN_GENERIC", weight = 0},
            {id = "APRICORN_TYPED", weight = 5}, --Type and glitter apricorns
            {id = "FOOD_LOW", weight = 0},
            {id = "FOOD_MID", weight = 0},
            {id = "FOOD_HIGH", weight = 5}, --Huge food with a high chance of wonder gummis and a chance for vitamins
            {id = "MEDICINE_LOW", weight = 2}, --Weaker medicine that can't heal all PP or HP at once
            {id = "MEDICINE_HIGH", weight = 5}, --Powerful medicine that can heal everything
            {id = "SEED_LOW", weight = 0},
            {id = "SEED_MID", weight = 0},
            {id = "SEED_HIGH", weight = 2}, --Includes rare seeds and berries, skews to Pure Seeds
            {id = "HELD_LOW", weight = 0},
            {id = "HELD_MID", weight = 2}, --Held items very useful for a specific strategy
            {id = "HELD_HIGH", weight = 5}, --Held items useful for anyone
            {id = "HELD_TYPE", weight = 0},
            {id = "HELD_PLATES", weight = 0},
            {id = "LOOT_LOW", weight = 2}, --Keys, pearls, assembly boxes
            {id = "LOOT_HIGH", weight = 5}, --Rare loot, skews towards heart scales
            {id = "EVO_ITEMS", weight = 5}, --Evolution items, high chance of link cables
            {id = "ORBS_LOW", weight = 0},
            {id = "ORBS_MID", weight = 2}, --Medium wonder orbs, many can shut down a monster house
            {id = "ORBS_HIGH", weight = 5}, --Rare, powerful wonder orbs often with map wide effects
            {id = "WANDS_LOW", weight = 0},
            {id = "WANDS_MID", weight = 0},
            {id = "WANDS_HIGH", weight = 3}, --Rare, specialty wands
            {id = "TM_LOW", weight = 0},
            {id = "TM_MID", weight = 4}, --TMs for moderate moves
            {id = "TM_HIGH", weight = 5}, --TMs for very powerful moves
            {id = "SPECIAL", weight = 1} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
        },
        STAR_2 = {
            {id = "NECESSITIES", weight = 0},
            {id = "AMMO_LOW", weight = 0},
            {id = "AMMO_MID", weight = 0},
            {id = "AMMO_HIGH", weight = 5}, --Rare ammo that are hard to find in dungeons
            {id = "APRICORN_GENERIC", weight = 0},
            {id = "APRICORN_TYPED", weight = 0},
            {id = "FOOD_LOW", weight = 0},
            {id = "FOOD_MID", weight = 0},
            {id = "FOOD_HIGH", weight = 5}, --Huge food with a high chance of wonder gummis and a chance for vitamins
            {id = "MEDICINE_LOW", weight = 0},
            {id = "MEDICINE_HIGH", weight = 5}, --Powerful medicine that can heal everything
            {id = "SEED_LOW", weight = 0},
            {id = "SEED_MID", weight = 0},
            {id = "SEED_HIGH", weight = 0},
            {id = "HELD_LOW", weight = 0},
            {id = "HELD_MID", weight = 0},
            {id = "HELD_HIGH", weight = 5}, --Held items useful for anyone
            {id = "HELD_TYPE", weight = 0},
            {id = "HELD_PLATES", weight = 0},
            {id = "LOOT_LOW", weight = 0},
            {id = "LOOT_HIGH", weight = 5}, --Rare loot, skews towards heart scales
            {id = "EVO_ITEMS", weight = 5}, --Evolution items, high chance of link cables
            {id = "ORBS_LOW", weight = 0},
            {id = "ORBS_MID", weight = 0},
            {id = "ORBS_HIGH", weight = 5}, --Rare, powerful wonder orbs often with map wide effects
            {id = "WANDS_LOW", weight = 0},
            {id = "WANDS_MID", weight = 0},
            {id = "WANDS_HIGH", weight = 0},
            {id = "TM_LOW", weight = 0},
            {id = "TM_MID", weight = 2}, --TMs for moderate moves
            {id = "TM_HIGH", weight = 5}, --TMs for very powerful moves
            {id = "SPECIAL", weight = 2} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
        },
        STAR_3 = {
            {id = "NECESSITIES", weight = 0},
            {id = "AMMO_LOW", weight = 0},
            {id = "AMMO_MID", weight = 0},
            {id = "AMMO_HIGH", weight = 5}, --Rare ammo that are hard to find in dungeons
            {id = "APRICORN_GENERIC", weight = 0},
            {id = "APRICORN_TYPED", weight = 0},
            {id = "FOOD_LOW", weight = 0},
            {id = "FOOD_MID", weight = 0},
            {id = "FOOD_HIGH", weight = 5}, --Huge food with a high chance of wonder gummis and a chance for vitamins
            {id = "MEDICINE_LOW", weight = 0},
            {id = "MEDICINE_HIGH", weight = 5}, --Powerful medicine that can heal everything
            {id = "SEED_LOW", weight = 0},
            {id = "SEED_MID", weight = 0},
            {id = "SEED_HIGH", weight = 0},
            {id = "HELD_LOW", weight = 0},
            {id = "HELD_MID", weight = 0},
            {id = "HELD_HIGH", weight = 5}, --Held items useful for anyone
            {id = "HELD_TYPE", weight = 0},
            {id = "HELD_PLATES", weight = 0},
            {id = "LOOT_LOW", weight = 0},
            {id = "LOOT_HIGH", weight = 5}, --Rare loot, skews towards heart scales
            {id = "EVO_ITEMS", weight = 5}, --Evolution items, high chance of link cables
            {id = "ORBS_LOW", weight = 0},
            {id = "ORBS_MID", weight = 0},
            {id = "ORBS_HIGH", weight = 0},
            {id = "WANDS_LOW", weight = 0},
            {id = "WANDS_MID", weight = 0},
            {id = "WANDS_HIGH", weight = 0},
            {id = "TM_LOW", weight = 0},
            {id = "TM_MID", weight = 0},
            {id = "TM_HIGH", weight = 5}, --TMs for very powerful moves
            {id = "SPECIAL", weight = 3} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
        },
        STAR_4 = {
            {id = "NECESSITIES", weight = 0},
            {id = "AMMO_LOW", weight = 0},
            {id = "AMMO_MID", weight = 0},
            {id = "AMMO_HIGH", weight = 0},
            {id = "APRICORN_GENERIC", weight = 0},
            {id = "APRICORN_TYPED", weight = 0},
            {id = "FOOD_LOW", weight = 0},
            {id = "FOOD_MID", weight = 0},
            {id = "FOOD_HIGH", weight = 5}, --Huge food with a high chance of wonder gummis and a chance for vitamins
            {id = "MEDICINE_LOW", weight = 0},
            {id = "MEDICINE_HIGH", weight = 0},
            {id = "SEED_LOW", weight = 0},
            {id = "SEED_MID", weight = 0},
            {id = "SEED_HIGH", weight = 0},
            {id = "HELD_LOW", weight = 0},
            {id = "HELD_MID", weight = 0},
            {id = "HELD_HIGH", weight = 5}, --Held items useful for anyone
            {id = "HELD_TYPE", weight = 0},
            {id = "HELD_PLATES", weight = 0},
            {id = "LOOT_LOW", weight = 0},
            {id = "LOOT_HIGH", weight = 5}, --Rare loot, skews towards heart scales
            {id = "EVO_ITEMS", weight = 5}, --Evolution items, high chance of link cables
            {id = "ORBS_LOW", weight = 0},
            {id = "ORBS_MID", weight = 0},
            {id = "ORBS_HIGH", weight = 0},
            {id = "WANDS_LOW", weight = 0},
            {id = "WANDS_MID", weight = 0},
            {id = "WANDS_HIGH", weight = 0},
            {id = "TM_LOW", weight = 0},
            {id = "TM_MID", weight = 0},
            {id = "TM_HIGH", weight = 5}, --TMs for very powerful moves
            {id = "SPECIAL", weight = 4} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
        },
        STAR_5 = {
            {id = "NECESSITIES", weight = 0},
            {id = "AMMO_LOW", weight = 0},
            {id = "AMMO_MID", weight = 0},
            {id = "AMMO_HIGH", weight = 0},
            {id = "APRICORN_GENERIC", weight = 0},
            {id = "APRICORN_TYPED", weight = 0},
            {id = "FOOD_LOW", weight = 0},
            {id = "FOOD_MID", weight = 0},
            {id = "FOOD_HIGH", weight = 5}, --Huge food with a high chance of wonder gummis and a chance for vitamins
            {id = "MEDICINE_LOW", weight = 0},
            {id = "MEDICINE_HIGH", weight = 0},
            {id = "SEED_LOW", weight = 0},
            {id = "SEED_MID", weight = 0},
            {id = "SEED_HIGH", weight = 0},
            {id = "HELD_LOW", weight = 0},
            {id = "HELD_MID", weight = 0},
            {id = "HELD_HIGH", weight = 0},
            {id = "HELD_TYPE", weight = 0},
            {id = "HELD_PLATES", weight = 0},
            {id = "LOOT_LOW", weight = 0},
            {id = "LOOT_HIGH", weight = 0},
            {id = "EVO_ITEMS", weight = 0},
            {id = "ORBS_LOW", weight = 0},
            {id = "ORBS_MID", weight = 0},
            {id = "ORBS_HIGH", weight = 0},
            {id = "WANDS_LOW", weight = 0},
            {id = "WANDS_MID", weight = 0},
            {id = "WANDS_HIGH", weight = 0},
            {id = "TM_LOW", weight = 0},
            {id = "TM_MID", weight = 0},
            {id = "TM_HIGH", weight = 5}, --TMs for very powerful moves
            {id = "SPECIAL", weight = 5} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
        },
        STAR_6 = {
            {id = "NECESSITIES", weight = 0},
            {id = "AMMO_LOW", weight = 0},
            {id = "AMMO_MID", weight = 0},
            {id = "AMMO_HIGH", weight = 0},
            {id = "APRICORN_GENERIC", weight = 0},
            {id = "APRICORN_TYPED", weight = 0},
            {id = "FOOD_LOW", weight = 0},
            {id = "FOOD_MID", weight = 0},
            {id = "FOOD_HIGH", weight = 4}, --Huge food with a high chance of wonder gummis and a chance for vitamins
            {id = "MEDICINE_LOW", weight = 0},
            {id = "MEDICINE_HIGH", weight = 0},
            {id = "SEED_LOW", weight = 0},
            {id = "SEED_MID", weight = 0},
            {id = "SEED_HIGH", weight = 0},
            {id = "HELD_LOW", weight = 0},
            {id = "HELD_MID", weight = 0},
            {id = "HELD_HIGH", weight = 0},
            {id = "HELD_TYPE", weight = 0},
            {id = "HELD_PLATES", weight = 0},
            {id = "LOOT_LOW", weight = 0},
            {id = "LOOT_HIGH", weight = 0},
            {id = "EVO_ITEMS", weight = 0},
            {id = "ORBS_LOW", weight = 0},
            {id = "ORBS_MID", weight = 0},
            {id = "ORBS_HIGH", weight = 0},
            {id = "WANDS_LOW", weight = 0},
            {id = "WANDS_MID", weight = 0},
            {id = "WANDS_HIGH", weight = 0},
            {id = "TM_LOW", weight = 0},
            {id = "TM_MID", weight = 0},
            {id = "TM_HIGH", weight = 4}, --TMs for very powerful moves
            {id = "SPECIAL", weight = 6} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
        },
        STAR_7 = {
            {id = "NECESSITIES", weight = 0},
            {id = "AMMO_LOW", weight = 0},
            {id = "AMMO_MID", weight = 0},
            {id = "AMMO_HIGH", weight = 0},
            {id = "APRICORN_GENERIC", weight = 0},
            {id = "APRICORN_TYPED", weight = 0},
            {id = "FOOD_LOW", weight = 0},
            {id = "FOOD_MID", weight = 0},
            {id = "FOOD_HIGH", weight = 3}, --Huge food with a high chance of wonder gummis and a chance for vitamins
            {id = "MEDICINE_LOW", weight = 0},
            {id = "MEDICINE_HIGH", weight = 0},
            {id = "SEED_LOW", weight = 0},
            {id = "SEED_MID", weight = 0},
            {id = "SEED_HIGH", weight = 0},
            {id = "HELD_LOW", weight = 0},
            {id = "HELD_MID", weight = 0},
            {id = "HELD_HIGH", weight = 0},
            {id = "HELD_TYPE", weight = 0},
            {id = "HELD_PLATES", weight = 0},
            {id = "LOOT_LOW", weight = 0},
            {id = "LOOT_HIGH", weight = 0},
            {id = "EVO_ITEMS", weight = 0},
            {id = "ORBS_LOW", weight = 0},
            {id = "ORBS_MID", weight = 0},
            {id = "ORBS_HIGH", weight = 0},
            {id = "WANDS_LOW", weight = 0},
            {id = "WANDS_MID", weight = 0},
            {id = "WANDS_HIGH", weight = 0},
            {id = "TM_LOW", weight = 0},
            {id = "TM_MID", weight = 0},
            {id = "TM_HIGH", weight = 3}, --TMs for very powerful moves
            {id = "SPECIAL", weight = 7} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
        },
        STAR_8 = {
            {id = "NECESSITIES", weight = 0},
            {id = "AMMO_LOW", weight = 0},
            {id = "AMMO_MID", weight = 0},
            {id = "AMMO_HIGH", weight = 0},
            {id = "APRICORN_GENERIC", weight = 0},
            {id = "APRICORN_TYPED", weight = 0},
            {id = "FOOD_LOW", weight = 0},
            {id = "FOOD_MID", weight = 0},
            {id = "FOOD_HIGH", weight = 0},
            {id = "MEDICINE_LOW", weight = 0},
            {id = "MEDICINE_HIGH", weight = 0},
            {id = "SEED_LOW", weight = 0},
            {id = "SEED_MID", weight = 0},
            {id = "SEED_HIGH", weight = 0},
            {id = "HELD_LOW", weight = 0},
            {id = "HELD_MID", weight = 0},
            {id = "HELD_HIGH", weight = 0},
            {id = "HELD_TYPE", weight = 0},
            {id = "HELD_PLATES", weight = 0},
            {id = "LOOT_LOW", weight = 0},
            {id = "LOOT_HIGH", weight = 0},
            {id = "EVO_ITEMS", weight = 0},
            {id = "ORBS_LOW", weight = 0},
            {id = "ORBS_MID", weight = 0},
            {id = "ORBS_HIGH", weight = 0},
            {id = "WANDS_LOW", weight = 0},
            {id = "WANDS_MID", weight = 0},
            {id = "WANDS_HIGH", weight = 0},
            {id = "TM_LOW", weight = 0},
            {id = "TM_MID", weight = 0},
            {id = "TM_HIGH", weight = 3}, --TMs for very powerful moves
            {id = "SPECIAL", weight = 8} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
        },
        STAR_9 = {
            {id = "NECESSITIES", weight = 0},
            {id = "AMMO_LOW", weight = 0},
            {id = "AMMO_MID", weight = 0},
            {id = "AMMO_HIGH", weight = 0},
            {id = "APRICORN_GENERIC", weight = 0},
            {id = "APRICORN_TYPED", weight = 0},
            {id = "FOOD_LOW", weight = 0},
            {id = "FOOD_MID", weight = 0},
            {id = "FOOD_HIGH", weight = 0},
            {id = "MEDICINE_LOW", weight = 0},
            {id = "MEDICINE_HIGH", weight = 0},
            {id = "SEED_LOW", weight = 0},
            {id = "SEED_MID", weight = 0},
            {id = "SEED_HIGH", weight = 0},
            {id = "HELD_LOW", weight = 0},
            {id = "HELD_MID", weight = 0},
            {id = "HELD_HIGH", weight = 0},
            {id = "HELD_TYPE", weight = 0},
            {id = "HELD_PLATES", weight = 0},
            {id = "LOOT_LOW", weight = 0},
            {id = "LOOT_HIGH", weight = 0},
            {id = "EVO_ITEMS", weight = 0},
            {id = "ORBS_LOW", weight = 0},
            {id = "ORBS_MID", weight = 0},
            {id = "ORBS_HIGH", weight = 0},
            {id = "WANDS_LOW", weight = 0},
            {id = "WANDS_MID", weight = 0},
            {id = "WANDS_HIGH", weight = 0},
            {id = "TM_LOW", weight = 0},
            {id = "TM_MID", weight = 0},
            {id = "TM_HIGH", weight = 0},
            {id = "SPECIAL", weight = 9} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
        }
    },
    --- List of all reward pools and the items they contain. You must at least include all pools referenced in the rewards_per_difficulty table, but you can add more.
    --- Entry ids may be either items or other pools. A pool doesn't have to only contain one of the two.
    --- Format: <pool_id> = {id = string, count = integer, hidden = string, weight = integer}
    --- * <pool_id> = the id of the pool. It should be used somewhere else either in this table or in rewards_per_difficulty.
    --- * id = item_id or pool_id. If it matches a pool, count and hidden will be ignored.
    --- * count = Optional. The amount of items awarded. It cannot be higher than the item's max stack. Defaults to the item's max stack.
    --- * hidden = Optional. Hidden value that can be used for various purposes depending on the item. Defaults to "".
    --- * weight = Chance of appearing. Set to 0 or delete altogether to stop an entry from being picked.
    --- @type table<string,{id:string, count:integer|nil, hidden:string|nil, weight:integer}[]>
    reward_pools = {
        NECESSITIES = {
            {id = "seed_reviver", weight = 10},
            {id = "berry_leppa", weight = 5},
            {id = "berry_oran", weight = 5},
            {id = "berry_lum", weight = 5},
            {id = "food_apple", weight = 5},
            {id = "orb_escape", weight = 5},
            {id = "apricorn_plain", weight = 5},
            {id = "key",count = 3,  weight = 2}
        },
        AMMO_LOW = {
            {id = "ammo_iron_thorn", count = 3, weight = 5},
            {id = "ammo_geo_pebble", count = 3, weight = 1},
            {id = "ammo_stick", count = 3, weight = 1},
        },
        AMMO_MID = {
            {id = "ammo_geo_pebble", count = 3, weight = 5},
            {id = "ammo_gravelerock", count = 3, weight = 5},
            {id = "ammo_stick", count = 3, weight = 5},
            {id = "ammo_silver_spike", count = 3, weight = 5}
        },
        AMMO_HIGH = {
            {id = "ammo_rare_fossil", count = 3, weight = 5},
            {id = "ammo_corsola_twig", count = 3, weight = 5},
            {id = "ammo_cacnea_spike", count = 3, weight = 5}
        },
        APRICORN_GENERIC = {
            {id = "apricorn_plain", weight = 12},
            {id = "apricorn_big", weight = 4}
        },
        APRICORN_TYPED = {
            {id = "apricorn_blue", weight = 5},
            {id = "apricorn_green", weight = 5},
            {id = "apricorn_brown", weight = 5},
            {id = "apricorn_purple", weight = 5},
            {id = "apricorn_red", weight = 5},
            {id = "apricorn_white", weight = 5},
            {id = "apricorn_yellow", weight = 5},
            {id = "apricorn_black", weight = 5},
            {id = "apricorn_glittery", weight = 5}
        },
        --Rare chance for gummis
        FOOD_LOW = {
            {id = "food_apple", weight = 30},
            {id = "food_banana", weight = 18},
            {id = "gummi_blue", weight = 1},
            {id = "gummi_black", weight = 1},
            {id = "gummi_clear", weight = 1},
            {id = "gummi_grass", weight = 1},
            {id = "gummi_green", weight = 1},
            {id = "gummi_brown", weight = 1},
            {id = "gummi_orange", weight = 1},
            {id = "gummi_gold", weight = 1},
            {id = "gummi_pink", weight = 1},
            {id = "gummi_purple", weight = 1},
            {id = "gummi_red", weight = 1},
            {id = "gummi_royal", weight = 1},
            {id = "gummi_silver", weight = 1},
            {id = "gummi_white", weight = 1},
            {id = "gummi_yellow", weight = 1},
            {id = "gummi_sky", weight = 1},
            {id = "gummi_gray", weight = 1},
            {id = "gummi_magenta", weight = 1}
        },
        --Moderate chance of gummis, rare chance of wonder gummis
        FOOD_MID = {
            {id = "food_apple_big", weight = 30},
            {id = "food_banana_big", weight = 18},
            {id = "gummi_blue", weight = 2},
            {id = "gummi_black", weight = 2},
            {id = "gummi_clear", weight = 2},
            {id = "gummi_grass", weight = 2},
            {id = "gummi_green", weight = 2},
            {id = "gummi_brown", weight = 2},
            {id = "gummi_orange", weight = 2},
            {id = "gummi_gold", weight = 2},
            {id = "gummi_pink", weight = 2},
            {id = "gummi_purple", weight = 2},
            {id = "gummi_red", weight = 2},
            {id = "gummi_royal", weight = 2},
            {id = "gummi_silver", weight = 2},
            {id = "gummi_white", weight = 2},
            {id = "gummi_yellow", weight = 2},
            {id = "gummi_sky", weight = 2},
            {id = "gummi_gray", weight = 2},
            {id = "gummi_magenta", weight = 2},
            {id = "gummi_wonder", weight = 1}
        },
        --Small chance for vitamins
        FOOD_HIGH = {
            {id = "food_apple_huge", weight = 30},
            {id = "food_apple_perfect", weight = 18},
            {id = "food_banana_big", weight = 18},
            {id = "gummi_wonder", weight = 30},
            {id = "boost_calcium", weight = 3},
            {id = "boost_protein", weight = 3},
            {id = "boost_hp_up", weight = 3},
            {id = "boost_zinc", weight = 3},
            {id = "boost_carbos", weight = 3},
            {id = "boost_iron", weight = 3},
            {id = "boost_nectar", weight = 5}
        },
        --Basic manufactured medicine
        MEDICINE_LOW = {
            {id = "medicine_potion", weight = 20},
            {id = "medicine_elixir", weight = 20},
            {id = "medicine_full_heal", weight = 10},
            {id = "medicine_x_attack", weight = 10},
            {id = "medicine_x_defense", weight = 10},
            {id = "medicine_x_sp_atk", weight = 10},
            {id = "medicine_x_sp_def", weight = 10},
            {id = "medicine_x_speed", weight = 10},
            {id = "medicine_x_accuracy", weight = 10},
            {id = "medicine_dire_hit", weight = 10}
        },
        --Advanced manufactued medicine
        MEDICINE_HIGH = {
            {id = "medicine_max_potion", weight = 20},
            {id = "medicine_max_elixir", weight = 20},
            {id = "medicine_full_heal", weight = 10}
        },
        --includes seeds and berries, as well as white herbs
        SEED_LOW = {
            {id = "seed_blast", weight = 5},
            {id = "seed_sleep", weight = 5},
            {id = "seed_warp", weight = 5},
            {id = "berry_oran", weight = 5},
            {id = "berry_leppa", weight = 5},
            {id = "berry_sitrus", weight = 5},
            {id = "berry_lum", weight = 5},
            {id = "herb_white", weight = 10}
        },
        --Includes advanced seeds, herbs, and type berries
        SEED_MID = {
            {id = "seed_reviver", weight = 25},
            {id = "seed_decoy", weight = 5},
            {id = "seed_blinker", weight = 5},
            {id = "seed_last_chance", weight = 5},
            {id = "seed_doom", weight = 5},
            {id = "seed_ban", weight = 5},
            {id = "seed_ice", weight = 5},
            {id = "seed_vile", weight = 5},
            {id = "berry_tanga", weight = 2},
            {id = "berry_colbur", weight = 2},
            {id = "berry_wacan", weight = 2},
            {id = "berry_haban", weight = 2},
            {id = "berry_chople", weight = 2},
            {id = "berry_occa", weight = 2},
            {id = "berry_coba", weight = 2},
            {id = "berry_kasib", weight = 2},
            {id = "berry_rindo", weight = 2},
            {id = "berry_shuca", weight = 2},
            {id = "berry_yache", weight = 2},
            {id = "berry_chilan", weight = 2},
            {id = "berry_kebia", weight = 2},
            {id = "berry_payapa", weight = 2},
            {id = "berry_charti", weight = 2},
            {id = "berry_babiri", weight = 2},
            {id = "berry_passho", weight = 2},
            {id = "berry_roseli", weight = 2},
            {id = "herb_power", weight = 10},
            {id = "herb_mental", weight = 10}
        },
        --includes rare seeds and berries
        SEED_HIGH = {
            {id = "seed_pure", weight = 15},
            {id = "seed_joy", weight = 1},
            {id = "berry_rowap", weight = 5},
            {id = "berry_jaboca", weight = 5},
            {id = "berry_liechi", weight = 5},
            {id = "berry_ganlon", weight = 5},
            {id = "berry_salac", weight = 5},
            {id = "berry_petaya", weight = 5},
            {id = "berry_apicot", weight = 5},
            {id = "berry_micle", weight = 5},
            {id = "berry_enigma", weight = 5},
            {id = "berry_starf", weight = 5}
        },
        HELD_LOW = {
            {id = "held_power_band", weight = 5},
            {id = "held_special_band", weight = 5},
            {id = "held_defense_scarf", weight = 5},
            {id = "held_zinc_band", weight = 5},
            {id = "held_toxic_orb", weight = 5},
            {id = "held_flame_orb", weight = 5},
            {id = "held_iron_ball", weight = 5},
            {id = "held_ring_target", weight = 5}
        },
        HELD_MID = {
            {id = "held_pierce_band", weight = 5},
            {id = "held_warp_scarf", weight = 5},
            {id = "held_scope_lens", weight = 5},
            {id = "held_reunion_cape", weight = 5},
            {id = "held_heal_ribbon", weight = 5},
            {id = "held_twist_band", weight = 5},
            {id = "held_grip_claw", weight = 5},
            {id = "held_binding_band", weight = 5},
            {id = "held_metronome", weight = 5},
            {id = "held_shed_shell", weight = 5},
            {id = "held_wide_lens", weight = 5},
            {id = "held_sticky_barb", weight = 5},
            {id = "held_choice_band", weight = 5},
            {id = "held_choice_scarf", weight = 5},
            {id = "held_choice_specs", weight = 5}
        },
        HELD_HIGH = {
            {id = "held_golden_mask", weight = 5},
            {id = "held_friend_bow", weight = 2},
            {id = "held_shell_bell", weight = 5},
            {id = "held_mobile_scarf", weight = 5},
            {id = "held_cover_band", weight = 5},
            {id = "held_pass_scarf", weight = 5},
            {id = "held_trap_scarf", weight = 5},
            {id = "held_pierce_band", weight = 5},
            {id = "held_goggle_specs", weight = 5},
            {id = "held_x_ray_specs", weight = 5},
            {id = "held_assault_vest", weight = 5},
            {id = "held_life_orb", weight = 5}
        },
        HELD_TYPE = {
            {id = "held_silver_powder", weight = 5},
            {id = "held_black_glasses", weight = 5},
            {id = "held_dragon_scale", weight = 5},
            {id = "held_magnet", weight = 5},
            {id = "held_pink_bow", weight = 5},
            {id = "held_black_belt", weight = 5},
            {id = "held_charcoal", weight = 5},
            {id = "held_sharp_beak", weight = 5},
            {id = "held_spell_tag", weight = 5},
            {id = "held_miracle_seed", weight = 5},
            {id = "held_soft_sand", weight = 5},
            {id = "held_never_melt_ice", weight = 5},
            {id = "held_silk_scarf", weight = 5},
            {id = "held_poison_barb", weight = 5},
            {id = "held_twisted_spoon", weight = 5},
            {id = "held_hard_stone", weight = 5},
            {id = "held_metal_coat", weight = 5},
            {id = "held_mystic_water", weight = 5}
        },
        HELD_PLATES = {
            {id = "held_insect_plate", weight = 5},
            {id = "held_dread_plate", weight = 5},
            {id = "held_draco_plate", weight = 5},
            {id = "held_zap_plate", weight = 5},
            {id = "held_pixie_plate", weight = 5},
            {id = "held_fist_plate", weight = 5},
            {id = "held_flame_plate", weight = 5},
            {id = "held_sky_plate", weight = 5},
            {id = "held_spooky_plate", weight = 5},
            {id = "held_meadow_plate", weight = 5},
            {id = "held_earth_plate", weight = 5},
            {id = "held_icicle_plate", weight = 5},
            {id = "held_blank_plate", weight = 5},
            {id = "held_toxic_plate", weight = 5},
            {id = "held_mind_plate", weight = 5},
            {id = "held_stone_plate", weight = 5},
            {id = "held_iron_plate", weight = 5},
            {id = "held_splash_plate", weight = 5}
        },
        --Spawns boxes, keys, heart scales, and loot
        LOOT_LOW = {
            {id = "loot_heart_scale", count = 3, weight = 5},
            {id = "loot_pearl", count = 3, weight = 10},
            {id = "machine_assembly_box", weight = 10},
            {id = "key", count = 3, weight = 10}
        },
        LOOT_HIGH = {
            {id = "loot_heart_scale", count = 3, weight = 20},
            {id = "loot_nugget", weight = 5},
            {id = "machine_recall_box", weight = 10},
            {id = "machine_storage_box", count = 3, weight = 10}
        },
        EVO_ITEMS = {
            {id = "evo_link_cable", weight = 30},
            {id = "evo_fire_stone", weight = 5},
            {id = "evo_thunder_stone", weight = 5},
            {id = "evo_water_stone", weight = 5},
            {id = "evo_leaf_stone", weight = 5},
            {id = "evo_moon_stone", weight = 5},
            {id = "evo_sun_stone", weight = 5},
            {id = "evo_magmarizer", weight = 5},
            {id = "evo_electirizer", weight = 5},
            {id = "evo_reaper_cloth", weight = 5},
            {id = "evo_cracked_pot", weight = 5},
            {id = "evo_chipped_pot", weight = 5},
            {id = "evo_shiny_stone", weight = 5},
            {id = "evo_dusk_stone", weight = 5},
            {id = "evo_dawn_stone", weight = 5},
            {id = "evo_up_grade", weight = 5},
            {id = "evo_dubious_disc", weight = 5},
            {id = "evo_razor_fang", weight = 5},
            {id = "evo_razor_claw", weight = 5},
            {id = "evo_protector", weight = 5},
            {id = "evo_prism_scale", weight = 5},
            {id = "evo_kings_rock", weight = 5},
            {id = "evo_sun_ribbon", weight = 5},
            {id = "evo_lunar_ribbon", weight = 5},
            {id = "evo_ice_stone", weight = 5}
        },
        ORBS_LOW = {
            {id = "orb_escape", weight = 5},
            {id = "orb_weather", weight = 5},
            {id = "orb_cleanse", weight = 5},
            {id = "orb_endure", weight = 5},
            {id = "orb_trapbust", weight = 5},
            {id = "orb_petrify", weight = 5},
            {id = "orb_foe_hold", weight = 5},
            {id = "orb_nullify", weight = 5},
            {id = "orb_all_dodge", weight = 5},
            {id = "orb_rebound", weight = 5},
            {id = "orb_mirror", weight = 5},
            {id = "orb_foe_seal", weight = 5},
            {id = "orb_rollcall", weight = 5},
            {id = "orb_mug", weight = 5},
        },
        ORBS_MID = {
            {id = "orb_escape", weight = 5},
            {id = "orb_mobile", weight = 5},
            {id = "orb_invisify", weight = 5},
            {id = "orb_all_aim", weight = 5},
            {id = "orb_trawl", weight = 5},
            {id = "orb_one_shot", weight = 5},
            {id = "orb_pierce", weight = 5},
            {id = "orb_all_protect", weight = 5},
            {id = "orb_trap_see", weight = 5},
            {id = "orb_slumber", weight = 5},
            {id = "orb_totter", weight = 5},
            {id = "orb_freeze", weight = 5},
            {id = "orb_spurn", weight = 5},
            {id = "orb_itemizer", weight = 5},
            {id = "orb_halving", weight = 5},
        },
        ORBS_HIGH = {
            {id = "orb_escape", weight = 5},
            {id = "orb_luminous", weight = 5},
            {id = "orb_invert", weight = 5},
            {id = "orb_devolve", weight = 5},
            {id = "orb_revival", weight = 5},
            {id = "orb_scanner", weight = 5},
            {id = "orb_stayaway", weight = 5},
            {id = "orb_one_room", weight = 5},
        },
        WANDS_LOW = {
            {id = "wand_pounce", count = 3, weight = 5},
            {id = "wand_slow", count = 3, weight = 5},
            {id = "wand_topsy_turvy", count = 3, weight = 5},
            {id = "wand_purge", count = 3, weight = 5}
        },
        WANDS_MID = {
            {id = "wand_path", count = 3, weight = 5},
            {id = "wand_whirlwind", count = 3, weight = 5},
            {id = "wand_switcher", count = 3, weight = 5},
            {id = "wand_fear", count = 3, weight = 5},
            {id = "wand_warp", count = 3, weight = 5},
            {id = "wand_lob", count = 3, weight = 5}
        },
        WANDS_HIGH = {
            {id = "wand_lure", count = 3, weight = 5},
            {id = "wand_stayaway", count = 3, weight = 5},
            {id = "wand_transfer", count = 3, weight = 5},
            {id = "wand_vanish", count = 3, weight = 5}
        },
        TM_LOW = {
            {id = "tm_snatch", weight = 5},
            {id = "tm_sunny_day", weight = 5},
            {id = "tm_rain_dance", weight = 5},
            {id = "tm_sandstorm", weight = 5},
            {id = "tm_hail", weight = 5},
            {id = "tm_taunt", weight = 5},
            {id = "tm_safeguard", weight = 5},
            {id = "tm_light_screen", weight = 5},
            {id = "tm_dream_eater", weight = 5},
            {id = "tm_nature_power", weight = 5},
            {id = "tm_swagger", weight = 5},
            {id = "tm_captivate", weight = 5},
            {id = "tm_fling", weight = 5},
            {id = "tm_payback", weight = 5},
            {id = "tm_reflect", weight = 5},
            {id = "tm_rock_polish", weight = 5},
            {id = "tm_pluck", weight = 5},
            {id = "tm_psych_up", weight = 5},
            {id = "tm_secret_power", weight = 5},
            {id = "tm_return", weight = 5},
            {id = "tm_frustration", weight = 5},
            {id = "tm_torment", weight = 5},
            {id = "tm_endure", weight = 5},
            {id = "tm_echoed_voice", weight = 5},
            {id = "tm_gyro_ball", weight = 5},
            {id = "tm_recycle", weight = 5},
            {id = "tm_false_swipe", weight = 5},
            {id = "tm_defog", weight = 5},
            {id = "tm_telekinesis", weight = 5},
            {id = "tm_double_team", weight = 5},
            {id = "tm_thunder_wave", weight = 5},
            {id = "tm_attract", weight = 5},
            {id = "tm_smack_down", weight = 5},
            {id = "tm_snarl", weight = 5},
            {id = "tm_flame_charge", weight = 5},
            {id = "tm_protect", weight = 5},
            {id = "tm_round", weight = 5},
            {id = "tm_rest", weight = 5},
            {id = "tm_thief", weight = 5},
            {id = "tm_cut", weight = 5},
            {id = "tm_whirlpool", weight = 5},
            {id = "tm_infestation", weight = 5},
            {id = "tm_roar", weight = 5},
            {id = "tm_flash", weight = 5},
            {id = "tm_embargo", weight = 5},
            {id = "tm_struggle_bug", weight = 5},
            {id = "tm_quash", weight = 5}
        },
        TM_MID = {
            {id = "tm_explosion", weight = 5},
            {id = "tm_will_o_wisp", weight = 5},
            {id = "tm_facade", weight = 5},
            {id = "tm_water_pulse", weight = 5},
            {id = "tm_shock_wave", weight = 5},
            {id = "tm_brick_break", weight = 5},
            {id = "tm_calm_mind", weight = 5},
            {id = "tm_charge_beam", weight = 5},
            {id = "tm_retaliate", weight = 5},
            {id = "tm_roost", weight = 5},
            {id = "tm_acrobatics", weight = 5},
            {id = "tm_bulk_up", weight = 5},
            {id = "tm_shadow_claw", weight = 5},
            {id = "tm_steel_wing", weight = 5},
            {id = "tm_snarl", weight = 5},
            {id = "tm_bulldoze", weight = 5},
            {id = "tm_substitute", weight = 5},
            {id = "tm_brine", weight = 5},
            {id = "tm_venoshock", weight = 5},
            {id = "tm_u_turn", weight = 5},
            {id = "tm_aerial_ace", weight = 5},
            {id = "tm_hone_claws", weight = 5},
            {id = "tm_rock_smash", weight = 5},
            {id = "tm_hidden_power", weight = 5},
            {id = "tm_rock_tomb", weight = 5},
            {id = "tm_strength", weight = 5},
            {id = "tm_grass_knot", weight = 5},
            {id = "tm_power_up_punch", weight = 5},
            {id = "tm_work_up", weight = 5},
            {id = "tm_incinerate", weight = 5},
            {id = "tm_bullet_seed", weight = 5},
            {id = "tm_low_sweep", weight = 5},
            {id = "tm_volt_switch", weight = 5},
            {id = "tm_avalanche", weight = 5},
            {id = "tm_dragon_tail", weight = 5},
            {id = "tm_silver_wind", weight = 5},
            {id = "tm_frost_breath", weight = 5},
            {id = "tm_sky_drop", weight = 5}
        },
        TM_HIGH = {
            {id = "tm_earthquake", weight = 5},
            {id = "tm_hyper_beam", weight = 5},
            {id = "tm_overheat", weight = 5},
            {id = "tm_blizzard", weight = 5},
            {id = "tm_swords_dance", weight = 5},
            {id = "tm_surf", weight = 5},
            {id = "tm_dark_pulse", weight = 5},
            {id = "tm_psychic", weight = 5},
            {id = "tm_thunder", weight = 5},
            {id = "tm_shadow_ball", weight = 5},
            {id = "tm_ice_beam", weight = 5},
            {id = "tm_giga_impact", weight = 5},
            {id = "tm_fire_blast", weight = 5},
            {id = "tm_dazzling_gleam", weight = 5},
            {id = "tm_flash_cannon", weight = 5},
            {id = "tm_stone_edge", weight = 5},
            {id = "tm_sludge_bomb", weight = 5},
            {id = "tm_focus_blast", weight = 5},
            {id = "tm_x_scissor", weight = 5},
            {id = "tm_wild_charge", weight = 5},
            {id = "tm_focus_punch", weight = 5},
            {id = "tm_psyshock", weight = 5},
            {id = "tm_rock_slide", weight = 5},
            {id = "tm_thunderbolt", weight = 5},
            {id = "tm_flamethrower", weight = 5},
            {id = "tm_energy_ball", weight = 5},
            {id = "tm_scald", weight = 5},
            {id = "tm_waterfall", weight = 5},
            {id = "tm_rock_climb", weight = 5},
            {id = "tm_giga_drain", weight = 5},
            {id = "tm_dive", weight = 5},
            {id = "tm_poison_jab", weight = 5},
            {id = "tm_iron_tail", weight = 5},
            {id = "tm_dig", weight = 5},
            {id = "tm_fly", weight = 5},
            {id = "tm_dragon_claw", weight = 5},
            {id = "tm_dragon_pulse", weight = 5},
            {id = "tm_sludge_wave", weight = 5},
            {id = "tm_drain_punch", weight = 5}
        },
        --special and unique rewards, very rare
        SPECIAL = {
            {id = "medicine_amber_tear", count = 3, weight = 1},
            {id = "machine_ability_capsule", count = 3, weight = 1},
            {id = "ammo_golden_thorn", count = 3, weight = 1},
            {id = "food_apple_golden", weight = 1},
            {id = "seed_golden", weight = 1},
            {id = "evo_harmony_scarf", weight = 1},
            {id = "apricorn_perfect", weight = 1}
        }
    },
    --- Ids of items that can be used as targets, divided depending on the job type.
    --- Make sure they're either easy enough to obtain or impossible to lose, depending on the job.
    --- Using stackable items is highly discouraged for all job types, as it may result in odd behaviors.
    --- Format: <job_type_id> = {<item_id>}
    --- * <job_type_id> = the id of a job type defined inside "job_types"
    --- * <item_id> = the id of the item to use
    ---@type table<string, string[]>
    target_items = {
        LOST_ITEM = {
            "mission_lost_scarf",
            "mission_lost_specs",
            "mission_lost_band"
        },
        OUTLAW_ITEM = {
            "mission_stolen_scarf",
            "mission_stolen_band",
            "mission_stolen_specs"
        },
        OUTLAW_ITEM_UNK = {}, --Filled at the end of the settings table
        DELIVERY = {
            "berry_oran",
            "berry_leppa",
            "food_apple",
            "berry_lum",
            "apricorn_plain"
        }
    },
    --- Weighted table that associates mission difficulty to a specific tier of characters and outlaws.
    --- Format: <diff_id> = {{id = string, weight = integer}}
    --- * <diff_id> = one of the difficulties defined in "difficulty_list"
    --- * id = A string that defines a pokémon tier id.
    --- * weight: Chance of being picked. Set to 0 or delete altogether to stop an entry from being picked.
    --- @type table<string,{id:string, weight:integer}[]>
    difficulty_to_tier = {
        F = {
            {id = "TIER_LOW", weight = 10},
            {id = "TIER_MID", weight = 0},
            {id = "TIER_HIGH", weight = 0}
        },
        E = {
            {id = "TIER_LOW", weight = 9},
            {id = "TIER_MID", weight = 1},
            {id = "TIER_HIGH", weight = 0}
        },
        D = {
            {id = "TIER_LOW", weight = 7},
            {id = "TIER_MID", weight = 3},
            {id = "TIER_HIGH", weight = 0}
        },
        C = {
            {id = "TIER_LOW", weight = 6},
            {id = "TIER_MID", weight = 4},
            {id = "TIER_HIGH", weight = 0}
        },
        B = {
            {id = "TIER_LOW", weight = 2},
            {id = "TIER_MID", weight = 6},
            {id = "TIER_HIGH", weight = 2}
        },
        A = {
            {id = "TIER_LOW", weight = 1},
            {id = "TIER_MID", weight = 5},
            {id = "TIER_HIGH", weight = 4}
        },
        S = {
            {id = "TIER_LOW", weight = 0},
            {id = "TIER_MID", weight = 5},
            {id = "TIER_HIGH", weight = 5}
        },
        STAR_1 = {
            {id = "TIER_LOW", weight = 0},
            {id = "TIER_MID", weight = 3},
            {id = "TIER_HIGH", weight = 7}
        },
        STAR_2 = {
            {id = "TIER_LOW", weight = 0},
            {id = "TIER_MID", weight = 1},
            {id = "TIER_HIGH", weight = 9}
        },
        STAR_3 = {
            {id = "TIER_LOW", weight = 0},
            {id = "TIER_MID", weight = 0},
            {id = "TIER_HIGH", weight = 10}
        },
        STAR_4 = {
            {id = "TIER_LOW", weight = 0},
            {id = "TIER_MID", weight = 0},
            {id = "TIER_HIGH", weight = 10}
        },
        STAR_5 = {
            {id = "TIER_LOW", weight = 0},
            {id = "TIER_MID", weight = 0},
            {id = "TIER_HIGH", weight = 10}
        },
        STAR_6 = {
            {id = "TIER_LOW", weight = 0},
            {id = "TIER_MID", weight = 0},
            {id = "TIER_HIGH", weight = 10}
        },
        STAR_7 = {
            {id = "TIER_LOW", weight = 0},
            {id = "TIER_MID", weight = 0},
            {id = "TIER_HIGH", weight = 10}
        },
        STAR_8 = {
            {id = "TIER_LOW", weight = 0},
            {id = "TIER_MID", weight = 0},
            {id = "TIER_HIGH", weight = 10}
        },
        STAR_9 = {
            {id = "TIER_LOW", weight = 0},
            {id = "TIER_MID", weight = 0},
            {id = "TIER_HIGH", weight = 10}
        }
    },
    --- A list of Pokémon that will be used for job generation, sorted by arbitrary quest tiers.
    --- Any of these entries may be picked when choosing client and target.
    --- If the client picked is not in the dex, the reward type can never be "client" nor "exclusive"
    --- Format: \<tier> = {<monster_id>}
    --- * \<tier> = one of the tier ids used in difficulty_to_tier
    --- * <monster_id> = either the species id of a pokémon or a monsterId table
    --- @type table<string,(string|monsterIDTable)[]>
    pokemon = {
        --weak mons for easy missions
        TIER_LOW =
        {"abra","amaura","anorith","applin","archen","aron","arrokuda","axew","azurill",
         "baltoy","bagon","barboach","bayleef","beldum","bellsprout","bidoof","bonsly","bounsweet","bronzor","budew","buizel","bulbasaur","buneary","burmy",
         "cacnea","carvanha","cascoon","caterpie","charcadet","charmander","cherubi","chespin","chikorita","chimchar","chinchou","chingling","clamperl","clauncher","cleffa","clobbopus","combee","corphish","cottonee","cranidos","croagunk","cubchoo","cutiefly","cyndaquil",
         "darumaka","deerling","deino","diglett","doduo","dratini","drifloon","dreepy","drowzee","duskull",
         "ekans","electrike","elekid","elgyem","espurr","exeggcute",
         "feebas","fennekin","ferroseed","fidough","finneon","flabebe","fletchling","fomantis","foongus","froakie","fuecoco",
         "gastly","geodude","gible","glameow","goldeen","goomy","gothita","grimer","growlithe","gulpin",
         "happiny","hatenna","helioptile","hippopotas","honedge","hoothoot","hoppip","horsea","houndour",
         "igglybuff",
         "jangmo_o","joltik",
         "kabuto","kakuna","koffing","krabby","kricketot",
         "larvesta","larvitar","ledyba","lileep","lillipup","litleo","litten","litwick","lotad","luvdisc",
         "machop","magby","magikarp","magnemite","makuhita","mankey","mantyke","mareanie","mareep","meditite","metapod","mienfoo","mime_jr","minccino","morelull","mudbray","munna","mudkip","murkrow",
         "natu","nickit","nincada","noibat","nosepass","numel","nymble",
         "oddish","omanyte","onix","oshawott",
         "pansear","paras","patrat","pawmi","pawniard","petilil","phantump","pidgey","pidove","pineco","piplup","poliwag","ponyta","poochyena","popplio","porygon","psyduck","pumpkaboo","purrloin",
         "quaxly",
         "ralts","rattata","remoraid","rhyhorn","roggenrola","rowlet",
         "salandit","sandile","sandshrew","sandygast","scraggy","seedot","seel","sentret","sewaddle","shellder","shellos","shieldon","shinx","shroomish","shuppet","silcoon","sinistea","skorupi","slakoth","slowpoke","slugma","smoochum","sneasel","snivy","snom","snorunt","snover","snubbull","sobble","solosis","spearow","spheal","spinarak","spoink","sprigatito","spritzee","squirtle","starly","staryu","stufful","stunky","sunkern","surskit","swablu","swinub","swirlix",
         "taillow","teddiursa","tentacool","tepig","tinkatink","torchic","togepi","totodile","trapinch","treecko","trubbish","turtwig","tympole","tyrogue",

         "vanillite","venonat","voltorb",
         "wailmer","watchog","weedle","whismur","woobat","wooloo","wooper","wurmple","wynaut",


         "zigzagoon","zubat"},

        --middling mons for medium missions
        TIER_MID =
        {"aipom","arbok","ariados","audino",
         "beautifly","beedrill","bibarel","bisharp","braixen","breloom","brionne","butterfree",
         "carbink","carnivine","castform","chansey","charmeleon","chatot","cherrim","chimecho","clefairy","combusken","comfey","corsola","cramorant","croconaw",
         "dartrix","delibird","dewott","dhelmise","ditto","dodrio","doublade","dragalge","dragonair","drakloak","dunsparce","duosion","dustox",
         "eiscue","electabuzz","emboar","emolga",
         "farfetchd","finizen","flaaffy","flapple","floette","fraxure","furret","furfrou",
         "gabite","girafarig","gligar","gloom","golbat","gothorita","granbull","graveler","grotle","grovyle",
         "hattrem","hakamo_o","haunter","herdier",
         "illumise","indeedee","ivysaur",
         "jigglypuff","jynx",
         "kadabra","kangaskhan","kirlia","klefki","kricketune",
         "lairon","lampent","ledian","liepard","linoone","lombre","loudred","lunatone","luxio",
         "machoke","magmar","magneton","maractus","marill","marshtomp","masquerain","mawile","metang","mightyena","miltank","mimikyu","minior","minun","misdreavus","monferno","morgrem","morpeko","mothim","mr_mime","munchlax",
         "nidorina","nidorino","ninjask","noctowl","nuzleaf",

         "pachirisu","palpitoad","parasect","pidgeotto","pignite","piloswine","plusle","poliwhirl","porygon2","prinplup","pupitar",
         "quilava","qwilfish",
         "raboot","raticate","relicanth","ribombee","roselia",
         "sableye","scyther","seadra","sealeo","servine","seviper","shedinja","shelgon","shuckle","skiploom","sliggoo","smeargle","solrock","spinda","stantler","staravia","steenee","sudowoodo","sunflora","swadloon",
         "tangela","thievul","tinkatuff","togedemaru","togetic","torkoal","tropius",

         "vanillish","venomoth","vespiquen","vibrava","vigoroth","volbeat",
         "wartortle","weepinbell","wobbuffet","wormadam",

         "yanma",
         "zangoose","zorua","zweilous"},

        --strong pokemon for difficult missions
        TIER_HIGH =
        {"absol","aerodactyl","aegislash","aggron","alakazam","alcremie","altaria","ambipom","ampharos","appletun","arcanine","archeops","armaldo","aurorus","azumarill",
         "banette","bastiodon","bellibolt","bellossom","blissey","blastoise","blaziken","braviary","bronzong",
         "cacturne","camerupt","chandelure","charizard","cinderace","clawitzer","claydol","clefable","cloyster","corviknight","cradily","crawdaunt","crobat","cursola",
         "decidueye","delphox","dewgong","donphan","dragapult","dragonite","drampa","drapion","drifblim","dugtrio","dusclops","dusknoir",
         "eldegoss","electivire","empoleon","escavalier","exeggutor","exploud",
         "fearow","feraligatr","ferrothorn","floatzel","florges","flygon","forretress","froslass","frosmoth",
         "gallade","galvantula","garchomp","gardevoir","gastrodon","gengar","glalie","glimmora","gliscor","golduck","golem","golisopod","goodra","gorebyss","gothitelle","gourgeist","greninja","grumpig","gyarados",
         "hariyama","hatterene","haxorus","heliolisk","heracross","hippowdon","hitmonchan","hitmonlee","hitmontop","honchkrow","houndoom","huntail","hydreigon","hypno",
         "incineroar","infernape",
         "jumpluff",
         "kabutops","kingdra","kingambit","kingler","kommo_o",
         "lanturn","lapras","leavanny","lilligant","lopunny","ludicolo","lumineon","lurantis","luxray","lycanroc",
         "machamp","magcargo","magmortar","magnezone","mamoswine","mandibuzz","manectric","mantine","maushold","medicham","meganium","meowstic","metagross","mienshao","milotic","mismagius","muk","musharna",
         "nidoking","nidoqueen","noivern",
         "octillery","omastar","overqwil",
         "pawmot","pidgeot","pinsir","politoed","poliwrath","porygon_z","primarina","primeape","probopass","purugly",
         "quagsire",
         "rampardos","rapidash","reuniclus","rhydon","rhyperior","roserade",
         "salamence","salazzle","samurott","sandslash","sawsbuck","sceptile","scizor","scolipede","scorbunny","scrafty","seaking","serperior","sharpedo","shiftry","sirfetchd","skarmory","skuntank","slaking","slowbro","slowking","snorlax","spiritomb","staraptor","starmie","steelix","stoutland","swalot","swampert","swellow","swoobat",
         "tangrowth","tauros","tentacruel","tinkaton","togekiss","torterra","toxicroak","toxtricity","tsareena","typhlosion","tyranitar",
         "ursaring",
         "vanilluxe","venusaur","victreebel","vileplume","volcanion",
         "wailord","walrein","weezing","whimsicott","whiscash","wigglytuff",
         "xatu",
         "yamask","yanmega",
         "zoroark"}
    },
    --- A list of all possible job display titles, divided by job type.
    --- You must also include lists for any special job types you intend to use.
    --- Format: <job_type_id> = {<string_key>}
    --- * <job_type_id> = either the id of a job type defined inside "job_types", or the id of a special job type
    --- * <string_key> = the localization key used for the title. The localized strings are fetched from the Menu Text list (strings.resx)
    ---
    --- Localization placeholders:
    --- * {0}: target
    --- * {1}: dungeon
    --- * {2}: item
    --- * {3}: client (almost never used, hence why at the end)
    --- @type table<string,string[]>
    job_titles =  {
        RESCUE_SELF = {
            "MISSION_TITLE_RESCUE_SELF_001",
            "MISSION_TITLE_RESCUE_SELF_002",
            "MISSION_TITLE_RESCUE_SELF_003",
            "MISSION_TITLE_RESCUE_SELF_004",
            "MISSION_TITLE_RESCUE_SELF_005",
            "MISSION_TITLE_RESCUE_SELF_006",
            "MISSION_TITLE_RESCUE_SELF_007",
            "MISSION_TITLE_RESCUE_SELF_008",
            "MISSION_TITLE_RESCUE_SELF_009",
            "MISSION_TITLE_RESCUE_SELF_010"
        },
        RESCUE_FRIEND = {
            "MISSION_TITLE_RESCUE_FRIEND_001",
            "MISSION_TITLE_RESCUE_FRIEND_002",
            "MISSION_TITLE_RESCUE_FRIEND_003",
            "MISSION_TITLE_RESCUE_FRIEND_004",
            "MISSION_TITLE_RESCUE_FRIEND_005",
            "MISSION_TITLE_RESCUE_FRIEND_006",
            "MISSION_TITLE_RESCUE_FRIEND_007",
            "MISSION_TITLE_RESCUE_FRIEND_008",
            "MISSION_TITLE_RESCUE_FRIEND_009",
            "MISSION_TITLE_RESCUE_FRIEND_010"
        },
        ESCORT = {
            "MISSION_TITLE_ESCORT_001",
            "MISSION_TITLE_ESCORT_002",
            "MISSION_TITLE_ESCORT_003",
            "MISSION_TITLE_ESCORT_004",
            "MISSION_TITLE_ESCORT_005"
        },
        EXPLORATION = {
            "MISSION_TITLE_EXPLORATION_001",
            "MISSION_TITLE_EXPLORATION_002",
            "MISSION_TITLE_EXPLORATION_003",
            "MISSION_TITLE_EXPLORATION_004",
            "MISSION_TITLE_EXPLORATION_005"
        },
        DELIVERY = {
            "MISSION_TITLE_DELIVERY_001",
            "MISSION_TITLE_DELIVERY_002",
            "MISSION_TITLE_DELIVERY_003",
            "MISSION_TITLE_DELIVERY_004",
            "MISSION_TITLE_DELIVERY_005"
        },
        LOST_ITEM = {
            "MISSION_TITLE_LOST_ITEM_001",
            "MISSION_TITLE_LOST_ITEM_002",
            "MISSION_TITLE_LOST_ITEM_003",
            "MISSION_TITLE_LOST_ITEM_004",
            "MISSION_TITLE_LOST_ITEM_005"
        },
        OUTLAW = {
            "MISSION_TITLE_OUTLAW_001",
            "MISSION_TITLE_OUTLAW_002",
            "MISSION_TITLE_OUTLAW_003",
            "MISSION_TITLE_OUTLAW_004",
            "MISSION_TITLE_OUTLAW_005",
            "MISSION_TITLE_OUTLAW_006",
            "MISSION_TITLE_OUTLAW_007",
            "MISSION_TITLE_OUTLAW_008",
            "MISSION_TITLE_OUTLAW_009",
            "MISSION_TITLE_OUTLAW_010",
        },
        OUTLAW_ITEM = {
            "MISSION_TITLE_OUTLAW_ITEM_001",
            "MISSION_TITLE_OUTLAW_ITEM_002",
            "MISSION_TITLE_OUTLAW_ITEM_003",
            "MISSION_TITLE_OUTLAW_ITEM_004",
            "MISSION_TITLE_OUTLAW_ITEM_005"
        },
        OUTLAW_ITEM_UNK = {
            "MISSION_TITLE_OUTLAW_ITEM_UNK_001",
            "MISSION_TITLE_OUTLAW_ITEM_UNK_002",
            "MISSION_TITLE_OUTLAW_ITEM_UNK_003",
            "MISSION_TITLE_OUTLAW_ITEM_UNK_004",
            "MISSION_TITLE_OUTLAW_ITEM_UNK_005"
        },
        OUTLAW_MONSTER_HOUSE = {
            "MISSION_TITLE_OUTLAW_MONSTER_HOUSE_001",
            "MISSION_TITLE_OUTLAW_MONSTER_HOUSE_002",
            "MISSION_TITLE_OUTLAW_MONSTER_HOUSE_003",
            "MISSION_TITLE_OUTLAW_MONSTER_HOUSE_004",
            "MISSION_TITLE_OUTLAW_MONSTER_HOUSE_005"
        },
        OUTLAW_FLEE = {
            "MISSION_TITLE_OUTLAW_FLEE_001",
            "MISSION_TITLE_OUTLAW_FLEE_002",
            "MISSION_TITLE_OUTLAW_FLEE_003",
            "MISSION_TITLE_OUTLAW_FLEE_004",
            "MISSION_TITLE_OUTLAW_FLEE_005"
        },

        --For special client/targets
        RIVAL = {
            "MISSION_TITLE_SPECIAL_RIVAL_001",
            "MISSION_TITLE_SPECIAL_RIVAL_002",
            "MISSION_TITLE_SPECIAL_RIVAL_003"
        },

        CHILD = {
            "MISSION_TITLE_SPECIAL_CHILD_001",
            "MISSION_TITLE_SPECIAL_CHILD_002",
            "MISSION_TITLE_SPECIAL_CHILD_003"
        },
        FRIEND = {
            "MISSION_TITLE_SPECIAL_FRIEND_001",
            "MISSION_TITLE_SPECIAL_FRIEND_002",
            "MISSION_TITLE_SPECIAL_FRIEND_003"
        },
        LOVER = {
            "MISSION_TITLE_SPECIAL_LOVER_001",
            "MISSION_TITLE_SPECIAL_LOVER_002",
            "MISSION_TITLE_SPECIAL_LOVER_003"
        }
    },
    --- A list of all possible job flavor text entries, divided by job type and by line.
    --- Format: <job_type_id> = {{<string_key>},{<string_key>}}
    --- * <job_type_id> = either the id of a job type defined inside "job_types", or the id of a special job type
    --- * <string_key> = the localization key used for the flavor text. Every job has 2 lists assigned: one for the top string and one for the bottom one.
    --- If only the first list is specified, the second one will be left empty.
    --- The localized strings are fetched from the Menu Text list (strings.resx)
    ---
    --- Localization placeholders:
    --- * {0}: target
    --- * {1}: dungeon
    --- * {2}: item
    --- * {3}: client (almost never used, hence why at the end)
    --- @type table<string,{[1]:string[], [2]:string[]}>
    job_flavor =  {
        RESCUE_SELF = {
            {
                "MISSION_BODY_TOP_RESCUE_SELF_001",
                "MISSION_BODY_TOP_RESCUE_SELF_002",
                "MISSION_BODY_TOP_RESCUE_SELF_003",
                "MISSION_BODY_TOP_RESCUE_SELF_004",
                "MISSION_BODY_TOP_RESCUE_SELF_005",
                "MISSION_BODY_TOP_RESCUE_SELF_006",
                "MISSION_BODY_TOP_RESCUE_SELF_007",
                "MISSION_BODY_TOP_RESCUE_SELF_008",
                "MISSION_BODY_TOP_RESCUE_SELF_009",
                "MISSION_BODY_TOP_RESCUE_SELF_010"
            },
            {
                "MISSION_BODY_BOTTOM_RESCUE_SELF_001",
                "MISSION_BODY_BOTTOM_RESCUE_SELF_002",
                "MISSION_BODY_BOTTOM_RESCUE_SELF_003",
                "MISSION_BODY_BOTTOM_RESCUE_SELF_004",
                "MISSION_BODY_BOTTOM_RESCUE_SELF_005",
                "MISSION_BODY_BOTTOM_RESCUE_SELF_006",
                "MISSION_BODY_BOTTOM_RESCUE_SELF_007",
                "MISSION_BODY_BOTTOM_RESCUE_SELF_008",
                "MISSION_BODY_BOTTOM_RESCUE_SELF_009",
                "MISSION_BODY_BOTTOM_RESCUE_SELF_010"
            }
        },
        RESCUE_FRIEND = {
            {
                "MISSION_BODY_TOP_RESCUE_FRIEND_001",
                "MISSION_BODY_TOP_RESCUE_FRIEND_002",
                "MISSION_BODY_TOP_RESCUE_FRIEND_003",
                "MISSION_BODY_TOP_RESCUE_FRIEND_004",
                "MISSION_BODY_TOP_RESCUE_FRIEND_005",
                "MISSION_BODY_TOP_RESCUE_FRIEND_006",
                "MISSION_BODY_TOP_RESCUE_FRIEND_007",
                "MISSION_BODY_TOP_RESCUE_FRIEND_008",
                "MISSION_BODY_TOP_RESCUE_FRIEND_009",
                "MISSION_BODY_TOP_RESCUE_FRIEND_010"
            },
            {
                "MISSION_BODY_BOTTOM_RESCUE_FRIEND_001",
                "MISSION_BODY_BOTTOM_RESCUE_FRIEND_002",
                "MISSION_BODY_BOTTOM_RESCUE_FRIEND_003",
                "MISSION_BODY_BOTTOM_RESCUE_FRIEND_004",
                "MISSION_BODY_BOTTOM_RESCUE_FRIEND_005",
                "MISSION_BODY_BOTTOM_RESCUE_FRIEND_006",
                "MISSION_BODY_BOTTOM_RESCUE_FRIEND_007",
                "MISSION_BODY_BOTTOM_RESCUE_FRIEND_008",
                "MISSION_BODY_BOTTOM_RESCUE_FRIEND_009",
                "MISSION_BODY_BOTTOM_RESCUE_FRIEND_010"
            }
        },
        ESCORT = {
            {
                "MISSION_BODY_TOP_ESCORT_001",
                "MISSION_BODY_TOP_ESCORT_002",
                "MISSION_BODY_TOP_ESCORT_003",
                "MISSION_BODY_TOP_ESCORT_004",
                "MISSION_BODY_TOP_ESCORT_005"
            },
            {
                "MISSION_BODY_BOTTOM_ESCORT_001",
                "MISSION_BODY_BOTTOM_ESCORT_002",
                "MISSION_BODY_BOTTOM_ESCORT_003",
                "MISSION_BODY_BOTTOM_ESCORT_004",
                "MISSION_BODY_BOTTOM_ESCORT_005"
            }
        },
        EXPLORATION = {
            {
                "MISSION_BODY_TOP_EXPLORATION_001",
                "MISSION_BODY_TOP_EXPLORATION_002",
                "MISSION_BODY_TOP_EXPLORATION_003",
                "MISSION_BODY_TOP_EXPLORATION_004",
                "MISSION_BODY_TOP_EXPLORATION_005"
            },
            {
                "MISSION_BODY_BOTTOM_EXPLORATION_001",
                "MISSION_BODY_BOTTOM_EXPLORATION_002",
                "MISSION_BODY_BOTTOM_EXPLORATION_003",
                "MISSION_BODY_BOTTOM_EXPLORATION_004",
                "MISSION_BODY_BOTTOM_EXPLORATION_005"
            }
        },
        DELIVERY = {
            {
                "MISSION_BODY_TOP_DELIVERY_001",
                "MISSION_BODY_TOP_DELIVERY_002",
                "MISSION_BODY_TOP_DELIVERY_003",
                "MISSION_BODY_TOP_DELIVERY_004",
                "MISSION_BODY_TOP_DELIVERY_005"
            },
            {
                "MISSION_BODY_BOTTOM_DELIVERY_001",
                "MISSION_BODY_BOTTOM_DELIVERY_002",
                "MISSION_BODY_BOTTOM_DELIVERY_003",
                "MISSION_BODY_BOTTOM_DELIVERY_004",
                "MISSION_BODY_BOTTOM_DELIVERY_005"
            }
        },
        LOST_ITEM = {
            {
                "MISSION_BODY_TOP_LOST_ITEM_001",
                "MISSION_BODY_TOP_LOST_ITEM_002",
                "MISSION_BODY_TOP_LOST_ITEM_003",
                "MISSION_BODY_TOP_LOST_ITEM_004",
                "MISSION_BODY_TOP_LOST_ITEM_005"
            },
            {
                "MISSION_BODY_BOTTOM_LOST_ITEM_001",
                "MISSION_BODY_BOTTOM_LOST_ITEM_002",
                "MISSION_BODY_BOTTOM_LOST_ITEM_003",
                "MISSION_BODY_BOTTOM_LOST_ITEM_004",
                "MISSION_BODY_BOTTOM_LOST_ITEM_005"
            }
        },
        OUTLAW = {
            {
                "MISSION_BODY_TOP_OUTLAW_001",
                "MISSION_BODY_TOP_OUTLAW_002",
                "MISSION_BODY_TOP_OUTLAW_003",
                "MISSION_BODY_TOP_OUTLAW_004",
                "MISSION_BODY_TOP_OUTLAW_005",
                "MISSION_BODY_TOP_OUTLAW_006",
                "MISSION_BODY_TOP_OUTLAW_007",
                "MISSION_BODY_TOP_OUTLAW_008",
                "MISSION_BODY_TOP_OUTLAW_009",
                "MISSION_BODY_TOP_OUTLAW_010"
            },
            {
                "MISSION_BODY_BOTTOM_OUTLAW_001",
                "MISSION_BODY_BOTTOM_OUTLAW_002",
                "MISSION_BODY_BOTTOM_OUTLAW_003",
                "MISSION_BODY_BOTTOM_OUTLAW_004",
                "MISSION_BODY_BOTTOM_OUTLAW_005"
            }
        },
        OUTLAW_ITEM = {
            {
                "MISSION_BODY_TOP_OUTLAW_ITEM_001",
                "MISSION_BODY_TOP_OUTLAW_ITEM_002",
                "MISSION_BODY_TOP_OUTLAW_ITEM_003",
                "MISSION_BODY_TOP_OUTLAW_ITEM_004",
                "MISSION_BODY_TOP_OUTLAW_ITEM_005"
            },
            {
                "MISSION_BODY_BOTTOM_OUTLAW_ITEM_001",
                "MISSION_BODY_BOTTOM_OUTLAW_ITEM_002",
                "MISSION_BODY_BOTTOM_OUTLAW_ITEM_003",
                "MISSION_BODY_BOTTOM_OUTLAW_ITEM_004",
                "MISSION_BODY_BOTTOM_OUTLAW_ITEM_005"
            }
        },
        OUTLAW_ITEM_UNK = {
            {
                "MISSION_BODY_TOP_OUTLAW_ITEM_UNK_001",
                "MISSION_BODY_TOP_OUTLAW_ITEM_UNK_002",
                "MISSION_BODY_TOP_OUTLAW_ITEM_UNK_003",
                "MISSION_BODY_TOP_OUTLAW_ITEM_UNK_004",
                "MISSION_BODY_TOP_OUTLAW_ITEM_UNK_005"
            },
            {
                "MISSION_BODY_BOTTOM_OUTLAW_ITEM_UNK_001",
                "MISSION_BODY_BOTTOM_OUTLAW_ITEM_UNK_002",
                "MISSION_BODY_BOTTOM_OUTLAW_ITEM_UNK_003",
                "MISSION_BODY_BOTTOM_OUTLAW_ITEM_UNK_004",
                "MISSION_BODY_BOTTOM_OUTLAW_ITEM_UNK_005"
            }
        },
        OUTLAW_MONSTER_HOUSE = {
            {
                "MISSION_BODY_TOP_OUTLAW_MONSTER_HOUSE_001",
                "MISSION_BODY_TOP_OUTLAW_MONSTER_HOUSE_002",
                "MISSION_BODY_TOP_OUTLAW_MONSTER_HOUSE_003",
                "MISSION_BODY_TOP_OUTLAW_MONSTER_HOUSE_004",
                "MISSION_BODY_TOP_OUTLAW_MONSTER_HOUSE_005"
            },
            {
                "MISSION_BODY_BOTTOM_OUTLAW_MONSTER_HOUSE_001",
                "MISSION_BODY_BOTTOM_OUTLAW_MONSTER_HOUSE_002",
                "MISSION_BODY_BOTTOM_OUTLAW_MONSTER_HOUSE_003",
                "MISSION_BODY_BOTTOM_OUTLAW_MONSTER_HOUSE_004",
                "MISSION_BODY_BOTTOM_OUTLAW_MONSTER_HOUSE_005"
            }
        },
        OUTLAW_FLEE = {
            {
                "MISSION_BODY_TOP_OUTLAW_FLEE_001",
                "MISSION_BODY_TOP_OUTLAW_FLEE_002",
                "MISSION_BODY_TOP_OUTLAW_FLEE_003",
                "MISSION_BODY_TOP_OUTLAW_FLEE_004",
                "MISSION_BODY_TOP_OUTLAW_FLEE_005"
            },
            {
                "MISSION_BODY_BOTTOM_OUTLAW_FLEE_001",
                "MISSION_BODY_BOTTOM_OUTLAW_FLEE_002",
                "MISSION_BODY_BOTTOM_OUTLAW_FLEE_003",
                "MISSION_BODY_BOTTOM_OUTLAW_FLEE_004",
                "MISSION_BODY_BOTTOM_OUTLAW_FLEE_005"
            }
        }
    },
    --- Law enforcement characters in your setting. All OUTLAW jobs except OUTLAW_ITEM
    --- and OUTLAW_ITEM_UNK use these characters as job clients.
    --- You may specify only 1 officer, and then a list containing any number of agents. 2 will be randomly
    --- picked every time the job completion cutscene is played.
    --- You may add a weight property to agents to specify a custom chance of being picked. Any without will
    --- have a weight of 1.
    --- Add "unique = true" to the MonsterIDTable to stop an agent from being picked twice. You must
    --- have at least either 1 non-unique agent or 2 unique ones for this list table to be valid.
    --- Officer format: OFFICER = MonsterIDTable
    --- Agent format: AGENT = {MonsterIDTable}
    --- Format of MonsterIDTable: see the "monsterIdTemplate" function in missiongen_lib.lua
    ---@type {OFFICER:monsterIDTable, AGENT:AgentIDTable[]}
    law_enforcement = {
        OFFICER = {Species = "magnezone", Gender = 0},
        AGENT = {
            {Species = "magnemite", Gender = 0, Weight = 31},
            {Species = "magnemite", Gender = 0, Skin = "shiny", Weight = 1, Unique = true}
        }
    },
    --- Defines the chance of either the officer or an agent being the client of a mission depending on
    --- the character tier of the mission, as defined in difficulty_to_tier.
    --- Format: \<tier> = {id = string, weight = integer}
    --- * \<tier> = one of the tier ids used in difficulty_to_tier
    --- * id = One of: OFFICER, AGENT
    --- * index: Optional. Ignored if id is OFFICER. You can set it to specify a specific agent instead of rolling using their chance in "law_enforcement".
    --- * weight: Chance of being picked. Set to 0 or delete altogether to stop an entry from being picked.
    --- @type table<string,{id:"OFFICER"|"AGENT", index:integer|nil, weight:integer}[]>
    enforcer_chance = {
        TIER_LOW = {
            {id = "OFFICER", weight = 2},
            {id = "AGENT", weight = 8}
        },
        TIER_MID = {
            {id = "OFFICER", weight = 5},
            {id = "AGENT", weight = 5}
        },
        TIER_HIGH = {
            {id = "OFFICER", weight = 8},
            {id = "AGENT", weight = 2}
        }

    },
    --- Data of characters and flavor key used for special jobs, divided by tier.
    --- In outlaw related quests, you may use ENFORCER as a keyword for a random law enforcement character.
    --- You may also use OFFICER or AGENT to specify a more specific selection.
    --- These keywords can only be used in place of MonsterIDTables.
    --- Format: <special_type> = {\<tier> = {client = MonsterIDTable, target = MonsterIDTable, item = string, flavor = string}}
    --- * <special_type> = an id of your choosing. It must be different from any basic job id
    --- * \<tier> = one of the tier ids used in difficulty_to_tier
    --- * client = the data used to generate this Pokémon.
    --- * target = the data used to generate this Pokémon.  Only used in job types that require a target.
    --- * item = the id of the item that will be used for this job. Only used in job types that require an item.
    --- * flavor: flavor string key used for the job, sourced from the Menu Text list (strings.resx)
    --- Format of MonsterIDTable: see the "monsterIdTemplate" function in missiongen_lib.lua
    ---
    --- Localization placeholders:
    --- * {0}: target
    --- * {1}: dungeon
    --- * {2}: item
    --- * {3}: client (almost never used, hence why at the end)
    ---@type table<string, table<string,{client:monsterIDTable|"ENFORCER"|"OFFICER"|"AGENT", target:monsterIDTable|string|nil, item: string|nil, flavor:string}[]>>
    special_data = {
        LOVER = {
            TIER_LOW = {
                {client = {Species = "volbeat", Gender = 1}, target = {Species = "illumise", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_LOVER_001"},
                {client = {Species = "minun", Gender = 1}, target = {Species = "plusle", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_LOVER_002"},
                {client = {Species = "mareep", Gender = 2}, target = {Species = "wooloo", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_LOVER_003"},
                {client = {Species = "luvdisc", Gender = 2}, target = {Species = "luvdisc", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_LOVER_004"}
            },
            TIER_MID = {
                {client = {Species = "miltank", Gender = 2}, target = {Species = "tauros", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_LOVER_005"},
                {client = {Species = "venomoth", Gender = 1}, target = {Species = "butterfree", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_LOVER_006"},
                {client = {Species = "liepard", Gender = 2}, target = {Species = "persian", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_LOVER_007"},
                {client = {Species = "dustox", Gender = 1}, target = {Species = "beautifly", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_LOVER_008"},
                {client = {Species = "glalie", Gender = 1}, target = {Species = "froslass", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_LOVER_009"},
                {client = {Species = "ribombee", Gender = 2}, target = {Species = "masquerain", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_LOVER_010"},
                {client = {Species = "maractus", Gender = 2}, target = {Species = "cacturne", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_LOVER_011"},---my prickly love!
                {client = {Species = "lanturn", Gender = 1}, target = {Species = "lumineon", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_LOVER_012"}
            },
            TIER_HIGH = {
                {client = {Species = "tyranitar", Gender = 1}, target = {Species = "altaria", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_LOVER_013"},--reference to an old idea palika had
                {client = {Species = "gyarados", Gender = 1}, target = {Species = "milotic", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_LOVER_014"},
                {client = {Species = "gardevoir", Gender = 2}, target = {Species = "gallade", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_LOVER_015"}
            }
        },
        CHILD = {
            TIER_LOW = {
                {client = {Species = "clefable", Gender = 2}, target = {Species = "cleffa", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_CHILD_001"},
                {client = {Species = "wigglytuff", Gender = 1}, target = {Species = "igglybuff", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_CHILD_002"},
                {client = {Species = "togekiss", Gender = 2}, target = {Species = "togepi", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_CHILD_003"},
                {client = {Species = "roserade", Gender = 2}, target = {Species = "budew", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_CHILD_004"},
                {client = {Species = "chimecho", Gender = 2}, target = {Species = "chingling", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_CHILD_005"},
                {client = {Species = "sudowoodo", Gender = 1}, target = {Species = "bonsly", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_CHILD_006"},
                {client = {Species = "mr_mime", Gender = 1}, target = {Species = "mime_jr", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_CHILD_007"},
                {client = {Species = "raticate", Gender = 1}, target = {Species = "rattata", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_CHILD_008"},--hes still not so good at gnawing!
                {client = {Species = "leavanny", Gender = 2}, target = {Species = "sewaddle", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_CHILD_009"}
            },
            TIER_MID = {
                {client = {Species = "appletun", Gender = 2}, target = {Species = "applin", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_CHILD_010"},
                {client = {Species = "aggron", Gender = 1}, target = {Species = "aron", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_CHILD_011"},--probably munched too much metal!
                {client = {Species = "jynx", Gender = 2}, target = {Species = "smoochum", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_CHILD_012"},
                {client = {Species = "magmortar", Gender = 2}, target = {Species = "magby", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_CHILD_013"},
                {client = {Species = "electivire", Gender = 1}, target = {Species = "elekid", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_CHILD_014"},
                {client = {Species = "tsareena", Gender = 2}, target = {Species = "bounsweet", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_CHILD_015"},
                {client = {Species = "hatterene", Gender = 2}, target = {Species = "hatenna", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_CHILD_016"},
                {client = {Species = "gothitelle", Gender = 2}, target = {Species = "gothita", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_CHILD_017"},
                {client = {Species = "dugtrio", Gender = 1}, target = {Species = "diglett", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_CHILD_018"}
            },
            TIER_HIGH = {
                {client = {Species = "tyranitar", Gender = 2}, target = {Species = "larvitar", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_CHILD_019"},
                {client = {Species = "salamence", Gender = 1}, target = {Species = "bagon", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_CHILD_020"},
                {client = {Species = "dragonite", Gender = 2}, target = {Species = "dratini", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_CHILD_021"},
                {client = {Species = "noivern", Gender = 1}, target = {Species = "noibat", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_CHILD_022"},
                {client = {Species = "goodra", Gender = 2}, target = {Species = "goomy", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_CHILD_023"}
            }
        },
        FRIEND = {
            TIER_LOW = {
                {client = {Species = "applin", Gender = 1}, target = {Species = "cherubi", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_FRIEND_001"},--We both get mistaken for fruit! What if someone ate him!?
                {client = {Species = "mantyke", Gender = 2}, target = {Species = "remoraid", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_FRIEND_002"},--My best friend is missing! I'll never be able to evolve without him!
                {client = {Species = "magikarp", Gender = 1}, target = {Species = "feebas", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_FRIEND_003"},--feebas is the only one who understands what it's like to be dogshit!
                {client = {Species = "poliwag", Gender = 2}, target = {Species = "lotad", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_FRIEND_004"},--frog and his lilypad. I have no lilypad now, save him!
                {client = {Species = "teddiursa", Gender = 1}, target = {Species = "combee", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_FRIEND_005"}, --Without Combee, I have no honey! Please find them!
                {client = {Species = "woobat", Gender = 2}, target = {Species = "zubat", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_FRIEND_006"},--we both use ultrasonic waves to see!
                {client = {Species = "trubbish", Gender = 1}, target = {Species = "grimer", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_FRIEND_007"},--we both love eating garbage!
                {client = {Species = "shroomish", Gender = 1}, target = {Species = "paras", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_FRIEND_008"},--we both love to spread spores!
                {client = {Species = "chansey", Gender = 2}, target = {Species = "togepi", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_FRIEND_009"},--cares for togepi because its an egg
                {client = {Species = "salandit", Gender = 1}, target = {Species = "combee", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_FRIEND_010"}--they relate in being useless
            },
            TIER_MID = {
                {client = {Species = "lunatone", Gender = 0}, target = {Species = "solrock", Gender = 0}, flavor = "MISSION_BODY_SPECIAL_FRIEND_011"},
                {client = {Species = "emolga", Gender = 2}, target = {Species = "pachirisu", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_FRIEND_012"},
                {client = {Species = "spinda", Gender = 2}, target = {Species = "hypno", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_FRIEND_013"}, --Hypno went missing; only he can help stop my dizziness
                {client = {Species = "cramorant", Gender = 1}, target = {Species = "pelipper", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_FRIEND_014"},
                {client = {Species = "magnemite", Gender = 0}, target = {Species = "nosepass", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_FRIEND_015"},--We're both sensitive to magnetism!
                {client = {Species = "dustox", Gender = 1}, target = {Species = "lampent", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_FRIEND_016"}
            },
            TIER_HIGH = {
                {client = {Species = "lilligant", Gender = 2}, target = {Species = "kricketune", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_FRIEND_017"},--I can't dance without Kricketune's music!
                {client = {Species = "wigglytuff", Gender = 2}, target = {Species = "exploud", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_FRIEND_018"}, --we love making loud, silly noises together!
                {client = {Species = "beedrill", Gender = 1}, target = {Species = "florges", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_FRIEND_019"},--without my flower, i have no meaning!
                {client = {Species = "dunsparce", Gender = 1}, target = {Species = "dugtrio", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_FRIEND_020"},--we both love to burrow!
                {client = {Species = "whimsicott", Gender = 2}, target = {Species = "jumpluff", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_FRIEND_021"}
            }
        },
        RIVAL = {
            TIER_LOW = {
                {client = {Species = "koffing", Gender = 1}, target = {Species = "stunky", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_RIVAL_001"},--they compete to see whose odor is stronger
                {client = {Species = "krabby", Gender = 1}, target = {Species = "corphish", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_RIVAL_002"},--compare claw strength
                {client = {Species = "shuppet", Gender = 2}, target = {Species = "duskull", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_RIVAL_003"},--we like to see who can pull better pranks!
                {client = {Species = "pidgey", Gender = 2}, target = {Species = "spearow", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_RIVAL_004"},--we compete at flying!
                {client = {Species = "kabuto", Gender = 1}, target = {Species = "omanyte", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_RIVAL_005"}, --we've been rivals since our ancestors' time!
                {client = {Species = "joltik", Gender = 2}, target = {Species = "spinarak", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_RIVAL_006"},--We like to see who can spin the better web!
                {client = {Species = "tyrogue", Gender = 1}, target = {Species = "makuhita", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_RIVAL_007"},--my punching bag training partner!
                {client = {Species = "lillipup", Gender = 2}, target = {Species = "poochyena", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_RIVAL_008"}
            },

            TIER_MID = {
                {client = {Species = "vigoroth", Gender = 1}, target = {Species = "primeape", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_RIVAL_009"},--full of energy!
                {client = {Species = "sawsbuck", Gender = 1}, target = {Species = "stantler", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_RIVAL_010"},--butt antlers!
                {client = {Species = "jangmo_o", Gender = 1}, target = {Species = "axew", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_RIVAL_011"},
                {client = {Species = "mareanie", Gender = 2}, target = {Species = "corsola", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_RIVAL_012"}
            },

            TIER_HIGH = {
                {client = {Species = "heracross", Gender = 1}, target = {Species = "pinsir", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_RIVAL_013"},
                {client = {Species = "slowking", Gender = 1}, target = {Species = "slowbro", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_RIVAL_014"},--slowbro may not be as smart as me, but we're still great friends!
                {client = {Species = "magmortar", Gender = 2}, target = {Species = "electivire", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_RIVAL_015"}, --we need to settle who is stronger!
                {client = {Species = "cradily", Gender = 2}, target = {Species = "armaldo", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_RIVAL_016"}, --we've been rivals since our ancestors' time!
                {client = {Species = "bastiodon", Gender = 2}, target = {Species = "rampardos", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_RIVAL_017"}, --we've been rivals since our ancestors' time!
                {client = {Species = "archeops", Gender = 1}, target = {Species = "aerodactyl", Gender = 2}, flavor = "MISSION_BODY_SPECIAL_RIVAL_018"}, --we've been rivals since our ancestors' time!
                {client = {Species = "swellow", Gender = 2}, target = {Species = "staraptor", Gender = 1}, flavor = "MISSION_BODY_SPECIAL_RIVAL_019"}--brave birds!
            }
        }
    },
    --- String keys to be used whenever the player interacts with an escort mission client, depending on the job type.
    --- You can also include tables for special escort jobs. If no such table exists for a specific case, the generic
    --- table for the job type will be used.
    --- Format: <job_type_id> = {<string_key>}
    --- * <job_type_id> = "ESCORT", "EXPLORATION", or the id of a special job type that corresponds to one of these job types
    --- * <string_key> = the localization key of possible messages. The localized strings are fetched from the Gameplay Text list (stringsEx.resx)
    ---
    --- Localization placeholders:
    --- * {0}: target
    --- * {1}: dungeon
    --- * {2}: item
    ---@type table<string,string[]>
    escort_talks = {
        ESCORT = {
            "MISSION_ESCORT_INTERACT"
        },
        EXPLORATION = {
            "MISSION_EXPLORATION_INTERACT"
        }
    },
    --- Strings keys to be used whenever the player interacts with a pokémon that needs rescue, depending on the job type and the response given.
    --- You must include a "_DEFAULT" table, but you can also include tables for special job types. _DEFAULT will still be used for any special
    --- case that doesn't have a table associated with it.
    --- Format: {rescue_yes = {<case_id> = {{key = string, emotion = string}}}, rescue_no = {<case_id> = {{key = string, emotion = string}}}}
    --- * <case_id> = "_DEFAULT", or the id of a special job type that corresponds to either "RESCUE_SELF" or "RESCUE_FRIEND"
    --- * key = the localization key of possible messages. The localized strings are fetched from the Gameplay Text list (stringsEx.resx)
    --- * emotion = Optional. An emotion id to use with this specific message. Defaults to "Normal"
    ---
    --- Localization placeholders:
    --- * {0}: client
    --- * {1}: target
    --- * {2}: dungeon
    ---@type {rescue_yes:table<"_DEFAULT"|string,{key:string,emotion:emotionType|nil}[]>,rescue_no:table<"_DEFAULT"|string,{key:string,emotion:emotionType|nil}[]>}
    rescue_responses = {
        rescue_yes = {
            _DEFAULT = { {key = "MISSION_RESCUE_CONFIRM_DEFAULT"} },
            CHILD  = { {key = "MISSION_RESCUE_CONFIRM_CHILD", emotion = "Joyous"} },
            FRIEND = { {key = "MISSION_RESCUE_CONFIRM_FRIEND"} },
            RIVAL  = { {key = "MISSION_RESCUE_CONFIRM_RIVAL"} },
            LOVER  = { {key = "MISSION_RESCUE_CONFIRM_LOVER", emotion = "Joyous"} }
        },
        rescue_no = {
            _DEFAULT = { {key = "MISSION_RESCUE_DENY_DEFAULT", emotion = "Surprised"} },
            CHILD  = { {key = "MISSION_RESCUE_DENY_CHILD", emotion = "Crying"} },
            FRIEND = { {key = "MISSION_RESCUE_DENY_FRIEND", emotion = "Surprised"} },
            RIVAL  = { {key = "MISSION_RESCUE_DENY_RIVAL", emotion = "Stunned"} },
            LOVER  = { {key = "MISSION_RESCUE_DENY_LOVER", emotion = "Stunned"} }
        }
    },
    --- The object that contains job callback functions. It is recommended to define this object somewhere else.
    --- Job callbacks are stored inside jobs as strings. These strings are then used as an index in the callback root object to retrieve the
    --- actual function. They will be passed two parameters, the first one being a table structured like so:
    --- {cancel: boolean, job: jobTable}
    --- * cancel: set this to true to stop the event for whatever reason. For example, canceling BeforeReward will stop a job from performing the normal reward cutscene.
    --- * job: the job that requested this callback.
    ---
    --- The second parameter is the list of arguments defined during the callback registration.
    ---
    --- List of events:
    --- * JobTake: Ran right before the job is taken from a board or otherwise obtained using ```library:TakeJob```. The job provided is the copy that would be added to the taken list.
    --- * JobActivate: Ran right before the job is activated from the taken list menu or by calling ```library:ToggleTakenJob``` on an inactive job. Does NOT run when taken from a board while "taken_jobs_start_active" is true.
    --- * JobDeactivate: Ran right before the job is deactivated from the taken list menu or by calling ```library:ToggleTakenJob``` on an active job.
    --- * DungeonStart: Ran when entering the dungeon this job is located in. Canceling this event does nothing.
    --- * FloorStart: Ran at the start of the target floor of the job.
    --- * JobComplete: Ran when the job is marked as completed during an exploration or otherwised marked as such using ```library:MarkJobCompleted```.
    --- * JobFail: Ran when the job is marked as failed during an exploration or otherwised marked as such using ```library:MarkJobFailed```.
    --- * BeforeReward: Ran before this specific job's reward cutscene is started. Canceling this skips the entire reward routine and go straight to deleting the job from the taken list.
    --- * AfterReward: Ran after this specific job's reward cutscene is started. Canceling this event will prevent the job from being removed from the taken list.
    mission_callback_root = COMMON
}
settings.target_items.OUTLAW_ITEM_UNK = settings.target_items.OUTLAW_ITEM --copy list because it should be the same anyway

--- Adds a new dungeon section to the list of possible job destinations.
--- Section start values must always be added in ascending order. Failing to do so may cause inconsistent behaviors.
--- @param zone string the string id of the dungeon zone.
--- @param segment integer the numeric id of the dungeon segment.
--- @param start integer the starting floor of this dungeon section (start counting from 1 for this).
--- @param difficulty string the string id of the difficulty assigned to this section.
--- @param finish? integer Only considered when first adding a segment to the list.Can be omitted otherwise.  This will be the last floor of the segment where jobs can spawn (start counting from 1 for this). If higher than the dungeon floors, it will default to the full dungeon length.
--- @param must_end? boolean Only considered when first adding a segment to the list. Can be omitted otherwise. If true, this segment must be completed before jobs can spawn in it. If false, the segment must be accessed at least once, unless it's segment 0, which just needs to be unlocked. Defaults to true.
function settings.AddDungeonSection(zone, segment, start, difficulty, finish, must_end)
    if must_end == nil then must_end = true end
    if settings.dungeons[zone] == nil then
        if not settings.dungeon_order._count then
            settings.dungeon_order._count = 0
            for _, val in pairs(settings.dungeon_order) do settings.dungeon_order._count = math.max(settings.dungeon_order._count, val) end
        end
        settings.dungeon_order._count = settings.dungeon_order._count +1
        settings.dungeon_order[zone] = settings.dungeon_order._count
    end
    settings.dungeons[zone] = settings.dungeons[zone] or {}
    settings.dungeons[zone][segment] = settings.dungeons[zone][segment] or {max_floor = finish, must_end = must_end, sections = {}}
    table.insert(settings.dungeons[zone][segment].sections, {start = start, difficulty = difficulty})
end

settings.AddDungeonSection("tropical_path", 0, 3, "F", 4)
settings.AddDungeonSection("faultline_ridge", 0, 6, "D", 10)
settings.AddDungeonSection("guildmaster_trail", 0, 15, "STAR_2", 30, false)
settings.AddDungeonSection("guildmaster_trail", 0, 19, "STAR_3")
settings.AddDungeonSection("guildmaster_trail", 0, 23, "STAR_4")
settings.AddDungeonSection("guildmaster_trail", 0, 27, "STAR_5")
settings.AddDungeonSection("lava_floe_island", 0, 9, "C", 16)
settings.AddDungeonSection("lava_floe_island", 1, 1, "STAR_1", 9)
settings.AddDungeonSection("castaway_cave", 0, 7, "B", 12)
settings.AddDungeonSection("faded_trail", 0, 4, "E", 7)
settings.AddDungeonSection("faded_trail", 1, 1, "D", 3)
settings.AddDungeonSection("bramble_woods", 0, 4, "E", 7)
settings.AddDungeonSection("bramble_woods", 1, 1, "D", 3)
settings.AddDungeonSection("trickster_woods", 0, 6, "C", 10)
settings.AddDungeonSection("trickster_woods", 1, 1, "B", 4)
settings.AddDungeonSection("overgrown_wilds", 0, 7, "C", 12)
settings.AddDungeonSection("overgrown_wilds", 1, 1, "B", 4)
settings.AddDungeonSection("moonlit_courtyard", 0, 8, "C", 14)
settings.AddDungeonSection("moonlit_courtyard", 0, 12, "B")
settings.AddDungeonSection("moonlit_courtyard", 1, 1, "A", 6)
settings.AddDungeonSection("ambush_forest", 0, 11, "B", 20)
settings.AddDungeonSection("ambush_forest", 0, 16, "A")
settings.AddDungeonSection("sickly_hollow", 0, 9, "S", 16, false)
settings.AddDungeonSection("sickly_hollow", 0, 13, "STAR_1")
settings.AddDungeonSection("secret_garden", 0, 15, "STAR_3", 40, false)
settings.AddDungeonSection("secret_garden", 0, 20, "STAR_4")
settings.AddDungeonSection("secret_garden", 0, 25, "STAR_5")
settings.AddDungeonSection("secret_garden", 0, 30, "STAR_6")
settings.AddDungeonSection("secret_garden", 0, 34, "STAR_7")
settings.AddDungeonSection("secret_garden", 0, 38, "STAR_8")
settings.AddDungeonSection("flyaway_cliffs", 0, 6, "C", 10)
settings.AddDungeonSection("fertile_valley", 0, 5, "D", 8)
settings.AddDungeonSection("fertile_valley", 1, 1, "C", 5)
settings.AddDungeonSection("copper_quarry", 0, 7, "C", 11)
settings.AddDungeonSection("copper_quarry", 0, 1, "B", 4)
settings.AddDungeonSection("depleted_basin", 0, 5, "C", 9)
settings.AddDungeonSection("forsaken_desert", 0, 2, "S", 4)
settings.AddDungeonSection("relic_tower", 0, 8, "S", 13)
settings.AddDungeonSection("relic_tower", 0, 11, "STAR_1")
settings.AddDungeonSection("sleeping_caldera", 0, 10, "B", 18)
settings.AddDungeonSection("sleeping_caldera", 0, 15, "A")
settings.AddDungeonSection("thunderstruck_pass", 0, 8, "B", 14)
settings.AddDungeonSection("veiled_ridge", 0, 9, "B", 16)
settings.AddDungeonSection("veiled_ridge", 1, 1, "A", 6)
settings.AddDungeonSection("snowbound_path", 0, 10, "B", 18)
settings.AddDungeonSection("snowbound_path", 1, 1, "A", 6)
settings.AddDungeonSection("treacherous_mountain", 0, 11, "A", 20)
settings.AddDungeonSection("treacherous_mountain", 0, 16, "S")
settings.AddDungeonSection("champions_road", 0, 13, "S", 23)
settings.AddDungeonSection("champions_road", 0, 19, "STAR_1")

return settings
