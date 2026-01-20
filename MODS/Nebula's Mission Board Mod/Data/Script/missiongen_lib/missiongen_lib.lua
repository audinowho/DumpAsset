-- PMDO Mission Generation Library v1.0.3, by MistressNebula
-- Main file
-- ----------------------------------------------------------------------------------------- --
-- This is the main library file containing all functions and callbacks.
-- If you need to configure your data, please refer to missiongen_settings.lua
-- ----------------------------------------------------------------------------------------- --
-- You will need to load this file using the require() function, and save it in a
-- global variable. You should never load this file more than once.
-- ----------------------------------------------------------------------------------------- --
-- This library's documentation has been written using intellij idea with the sumnekolua plugin.

--- @alias referenceSet table<string,boolean> a generic set whose keys are strings and whose values are always ``true``
--- @alias LibraryRootStruct {boards:table<string,jobTable[]>,taken:jobTable[],dungeon_progress:table<string,table<integer, boolean>>,mission_flags:table<string, any>,previous_limit:integer,escort_jobs:integer} the structure of library.root
--- @alias jobTable {Client:monsterIDTable, Target:monsterIDTable|nil, Flavor:{[1]:string, [2]:string}, Title:string, Zone:string, Segment:integer,
--- Floor:integer, RewardType:rewardType, Reward1:itemTable|nil, Reward2:itemTable|nil, Type:jobType, Completion:integer, Taken:boolean, BackReference:string|nil,
--- Difficulty:integer, Item:string|nil, Special:string|nil, HideFloor:boolean, Callbacks:table<eventId,{name:string,args:table}>, MenuOverrides:table<string,string>} A table containing all properties of a job
--- @alias itemTable {id:string, count:integer|nil, hidden:string|nil} A table describing an InvItem object
--- @alias monsterIDTable {Species:string, Form:integer|nil, Skin:string|nil, Gender:integer|nil, Nickname:string|nil} A table that can be converted into a MonsterID object
--- @alias eventTable {cancel:boolean, job:jobTable, data:table<string, any>} A table used to handle job events
--- @alias MonsterID {Species:string, Form:integer, Skin:string, Gender:userdata} A MonsterID object
--- @alias destTable {destinations:string[], occupied:table<string,table<integer,table<integer, boolean>>>, allowed:{segment:integer, floor:integer, difficulty:string}[]} table used for randomly selecting destinations for jobs.

-- Types used for moveset generation
--- @alias categoryType "level"|"tm"|"tutor"|"egg" types of move pools
--- @alias slotType "stab"|"coverage"|"damage"|"status" types of slots that a move can be inserted into
--- @alias synergyEntry {ApplySynergy:referenceSet, RequestSynergy:referenceSet, Type:string} a table describing the state of a possible synergy in a moveset
--- @alias moveset_entry {ID:string, Type:string, Category:slotType[], Weight:integer, ApplySynergy: string[], RequestSynergy: string[]} a table describing a move and all the properties that may influence moveset generation choices
--- @alias moveset_supertable {stab:moveset_entry[],coverage:moveset_entry[],damage:moveset_entry[],status:moveset_entry[]} a table containing lists of moveset_entries, divided by slotType
--- @alias moveset_list table<string,{cat:slotType[], tables:categoryType[], value:table}> a backwards reference table that links a move to the supertables and subtables that contain it

local library = {
    --- Settings data imported from missiongen_settings.lua
    data = require("missiongen_lib.missiongen_settings"),
    --- shortcut to the root of the saved mission data, made accessible for quick reference.
    --- NEVER. EVER. CHANGE THIS VALUE.
    ---@type LibraryRootStruct
    root = SV
}
local menus = require("missiongen_lib.missiongen_menus")

--- Root for global data and enum values.
local globals = {}
---@type table<string,integer> Gender values
globals.gender = {}
globals.gender.Unknown = -1
globals.gender.Genderless = 0
globals.gender.Male = 1
globals.gender.Female = 2
---@type table<string,integer> Completion values
globals.completion = {}
globals.completion.Failed = -1
globals.completion.NotCompleted = 0
globals.completion.Completed = 1
---@type table<string,userdata> Imported C# types
globals.ctypes = {}
globals.ctypes.Integer = luanet.import_type('System.Int32')
globals.ctypes.List = luanet.import_type('System.Collections.Generic.List`1')
globals.ctypes.MobSpawn = luanet.import_type('RogueEssence.LevelGen.MobSpawn')
globals.ctypes.LoadGen = luanet.import_type('RogueEssence.LevelGen.LoadGen')
globals.ctypes.ChanceFloorGen = luanet.import_type('RogueEssence.LevelGen.ChanceFloorGen')
globals.ctypes.RarityData = luanet.import_type('PMDC.Data.RarityData')
globals.ctypes.FloorNameIDZoneStep = luanet.import_type('RogueEssence.LevelGen.FloorNameIDZoneStep')
globals.ctypes.StatusPowerEvent = luanet.import_type('PMDC.Dungeon.StatusPowerEvent')
globals.ctypes.StatusStackDifferentEvent = luanet.import_type('PMDC.Dungeon.StatusStackDifferentEvent')
globals.ctypes.MajorStatusPowerEvent = luanet.import_type('PMDC.Dungeon.StatusPowerEvent')
globals.ctypes.WeatherNeededEvent = luanet.import_type('PMDC.Dungeon.WeatherNeededEvent')
globals.ctypes.ChargeOrReleaseEvent = luanet.import_type('PMDC.Dungeon.ChargeOrReleaseEvent')
globals.ctypes.GiveMapStatusEvent = luanet.import_type('PMDC.Dungeon.GiveMapStatusEvent')
globals.ctypes.StatusBattleEvent = luanet.import_type('PMDC.Dungeon.StatusBattleEvent')
globals.ctypes.AdditionalEvent = luanet.import_type('PMDC.Dungeon.AdditionalEvent')
globals.ctypes.AddContextStateEvent = luanet.import_type('PMDC.Dungeon.AddContextStateEvent')
globals.ctypes.MajorStatusState = luanet.import_type('PMDC.Dungeon.MajorStatusState')
globals.ctypes.SleepAttack = luanet.import_type('PMDC.Dungeon.SleepAttack')
---Supported reward types data
---Hardcoded properties: item1, item2, exclusive, display_key_pointer
---@type table<string,{[1]:boolean,[2]:boolean,[3]:boolean,[4]:string}>
globals.reward_types = {}
globals.reward_types.item =       {true,  false, false, "REWARD_SINGLE"}
globals.reward_types.money =      {false, false, false, "REWARD_SINGLE"}
globals.reward_types.item_item =  {true,  true,  false, "REWARD_DOUBLE"}
globals.reward_types.money_item = {false, true,  false, "REWARD_DOUBLE"}
globals.reward_types.client =     {false, false, false, "REWARD_UNKNOWN"}
globals.reward_types.exclusive =  {true,  false, true,  "REWARD_UNKNOWN"}
--- Supported job types data
---@type table<string,{req_target:boolean,req_target_item:boolean,has_guest:boolean,target_outlaw:boolean,law_enforcement:boolean,can_hide_floor:boolean,boss:boolean}>
globals.job_types = {}
globals.job_types.RESCUE_SELF =          {req_target = false, req_target_item = false, has_guest = false, target_outlaw = false, law_enforcement = false, can_hide_floor = false, boss = false}
globals.job_types.RESCUE_FRIEND =        {req_target = true,  req_target_item = false, has_guest = false, target_outlaw = false, law_enforcement = false, can_hide_floor = true,  boss = false}
globals.job_types.ESCORT =               {req_target = true,  req_target_item = false, has_guest = true,  target_outlaw = false, law_enforcement = false, can_hide_floor = false, boss = false}
globals.job_types.EXPLORATION =          {req_target = false, req_target_item = false, has_guest = true,  target_outlaw = false, law_enforcement = false, can_hide_floor = true,  boss = false}
globals.job_types.DELIVERY =             {req_target = false, req_target_item = true,  has_guest = false, target_outlaw = false, law_enforcement = false, can_hide_floor = false, boss = false}
globals.job_types.LOST_ITEM =            {req_target = false, req_target_item = true,  has_guest = false, target_outlaw = false, law_enforcement = false, can_hide_floor = false, boss = false}
globals.job_types.OUTLAW =               {req_target = true,  req_target_item = false, has_guest = false, target_outlaw = true,  law_enforcement = true,  can_hide_floor = true,  boss = true}
globals.job_types.OUTLAW_ITEM =          {req_target = true,  req_target_item = true,  has_guest = false, target_outlaw = true,  law_enforcement = false, can_hide_floor = true,  boss = true}
globals.job_types.OUTLAW_ITEM_UNK =      {req_target = true,  req_target_item = true,  has_guest = false, target_outlaw = true,  law_enforcement = false, can_hide_floor = true,  boss = false}
globals.job_types.OUTLAW_MONSTER_HOUSE = {req_target = true,  req_target_item = false, has_guest = false, target_outlaw = true,  law_enforcement = true,  can_hide_floor = false, boss = true}
globals.job_types.OUTLAW_FLEE =          {req_target = true,  req_target_item = false, has_guest = false, target_outlaw = true,  law_enforcement = true,  can_hide_floor = true,  boss = true}
--- Keywords for client and target generation
---@type table<string,string>
globals.keywords = {}
globals.keywords.ENFORCER = "ENFORCER"
globals.keywords.OFFICER = "OFFICER"
globals.keywords.AGENT = "AGENT"
--- Keys for MenuOverrides
---@type table<string,string>
globals.overrides = {}
globals.overrides.OBJECTIVE = "OBJ"
globals.overrides.PLACE = "DUN"
globals.overrides.DIFFICULTY = "DIF"
globals.overrides.REWARD = "REW"
--- Error types
---@type table<string,string>
globals.error_types = {}
globals.error_types.DATA = "DataError"
globals.error_types.ID = "IDError"
globals.error_types.SCENE = "WrongSceneError"
globals.error_types.MAPGEN = "MapgenError"
--- Warning types
---@type table<string,string>
globals.warn_types = {}
globals.warn_types.DATA = "MissingData"
globals.warn_types.FLOOR_GEN = "InvalidFloor"
globals.warn_types.ID = "MissingID"
--- Default values for various things
---@type table<string,string>
globals.defaults = {}
globals.defaults.item = "food_apple"
--- Static display keys that are fetched from strings.resx
--- Look at the comment beside each key for info on their supported placeholders
---@type table<string,string>
globals.keys = {}
globals.keys.RESCUE_SELF = "MENU_JOB_OBJECTIVE_RESCUE_SELF" --Objective string for jobs where you rescue the client. {0} = Client
globals.keys.RESCUE_FRIEND = "MENU_JOB_OBJECTIVE_RESCUE_FRIEND" --Objective string for jobs where you rescue the target. {0} = Client, {1} = Target
globals.keys.ESCORT = "MENU_JOB_OBJECTIVE_ESCORT" --Objective string for escort jobs. {0} = Client, {1} = Target
globals.keys.EXPLORATION = "MENU_JOB_OBJECTIVE_EXPLORATION" --Objective string for exploration jobs. {0} = Client
globals.keys.DELIVERY = "MENU_JOB_OBJECTIVE_DELIVERY" --Objective string for delivery jobs. {0} = Client, {2} = Item
globals.keys.LOST_ITEM = "MENU_JOB_OBJECTIVE_LOST_ITEM" --Objective string for lost item jobs. {0} = Client, {2} = Item
globals.keys.OUTLAW = "MENU_JOB_OBJECTIVE_OUTLAW" --Objective string for regular outlaw jobs. {0} = Client, {1} = Target,
globals.keys.OUTLAW_ITEM = "MENU_JOB_OBJECTIVE_OUTLAW_ITEM"  --Objective string for stolen item outlaw jobs. {0} = Client, {1} = Target, {2} = Item
globals.keys.OUTLAW_ITEM_UNK = "MENU_JOB_OBJECTIVE_OUTLAW_ITEM_UNK" --Objective string for stolen item outlaw jobs whose target is supposed to be hidden. {0} = Client, {1} = Target, {2} = Item
globals.keys.OUTLAW_MONSTER_HOUSE = "MENU_JOB_OBJECTIVE_OUTLAW_MONSTER_HOUSE" --Objective string for outlaw monster house jobs. {0} = Client, {1} = Target
globals.keys.OUTLAW_FLEE = "MENU_JOB_OBJECTIVE_OUTLAW_FLEE" --Objective string for fleeing outlaw jobs. {0} = Client, {1} = Target
globals.keys.OBJECTIVE_DEFAULT = "MENU_JOB_OBJECTIVE_DEFAULT" --Objective string displayed when there are no jobs.
globals.keys.REACH_SEGMENT = "MENU_JOB_OBJECTIVE_REACH_SEGMENT" --Objective string displayed when there are jobs in a different segment. {0} = Segment
globals.keys.OPTION_JOBLIST = "MENU_OPTION_JOBLIST" --Name of the main menu button that displays the taken list
globals.keys.OPTION_OBJECTIVES_LIST = "MENU_OPTION_OBJECTIVES_LIST" --Name of the main menu button that displays the current objectives
globals.keys.TAKEN_TITLE = "BOARD_TAKEN_TITLE" --Name of the taken board in the board menu
globals.keys.OBJECTIVES_TITLE = "MENU_JOB_OBJECTIVES_TITLE" --Label for the button used to view mission objectives in dungeons
globals.keys.JOB_ACCEPTED = "MENU_JOB_ACCEPTED" --Displayed when viewing boards. It shows how full the taken list is. {0} Current Taken Count, {1} = Taken Limit
globals.keys.JOB_SUMMARY = "MENU_JOB_SUMMARY" --Displays the Job Summary label text
globals.keys.JOB_CLIENT = "MENU_JOB_CLIENT" --Displays the Client label text
globals.keys.JOB_OBJECTIVE = "MENU_JOB_OBJECTIVE" --Displays the Objective label text
globals.keys.JOB_PLACE = "MENU_JOB_PLACE" --Displays the Place label text
globals.keys.JOB_DIFFICULTY = "MENU_JOB_DIFFICULTY" --Displays the Difficulty label text
globals.keys.JOB_REWARD = "MENU_JOB_REWARD" --Displays the Reward label text
globals.keys.EXTRA_REWARD = "EXTRA_REWARD_AMOUNT" --Displays the Extra Reward. {0} = Amount
globals.keys.REWARD_SINGLE = "MENU_JOB_REWARD_SINGLE" --Reward string for a job with 1 reward. {0} = Reward1
globals.keys.REWARD_DOUBLE = "MENU_JOB_REWARD_DOUBLE" --Reward string for a job with 2 rewards. {0} = Reward1, {1} = Reward2
globals.keys.REWARD_UNKNOWN = "MENU_JOB_REWARD_UNKNOWN" --Reward string for special rewards. Meant to be hidden. {0} = Reward1
globals.keys.BUTTON_TAKE = "MENU_JOB_TAKE" --Label for the button used to take jobs or to activate them
globals.keys.BUTTON_DELETE = "MENU_JOB_DELETE" --Label for the button used to delete taken jobs
globals.keys.BUTTON_SUSPEND = "MENU_JOB_SUSPEND" --Label for the button used to suspend jobs
--- Static display keys that are fetched from stringsEx.resx
--- Look at the comment beside each key for info on their supported placeholders
---@type table<string,string>
globals.keysEx = {}
globals.keysEx.RESCUE_FOUND = "DLG_MISSION_RESCUE_FOUND" --Message for finding a rescue target and asking whether or not to warp it out. {0} = pokémon
globals.keysEx.RESCUE_CONFIRM = "DLG_MISSION_RESCUE_CONFIRM" --Message for agreeing to warp out a rescue target. {0} = pokémon
globals.keysEx.DELIVERY_FOUND = "DLG_MISSION_DELIVERY_FOUND" --Message for finding a delivery target and asking whether or not to give it the requested item. {0} = pokémon, {1} = item
globals.keysEx.DELIVERY_CONFIRM = "DLG_MISSION_DELIVERY_CONFIRM" --Dialogue from the target thanking the player for the item. {0} = item
globals.keysEx.DELIVERY_DENY = "DLG_MISSION_DELIVERY_DENY" --Dialogue from the target being sad about the player refusing to give the item. {0} = item
globals.keysEx.DELIVERY_NO_ITEM = "DLG_MISSION_DELIVERY_NO_ITEM" --Message for not having the requested item. {0} = pokémon, {1} = item
globals.keysEx.DELIVERY_NO_ITEM_CHAR = "DLG_MISSION_DELIVERY_NO_ITEM_CHAR" --Dialogue from the target being sad about the player not having the item. {0} = item
globals.keysEx.TARGET_LEFT = "DLG_MISSION_TARGET_LEFT" --Message for the target warping out after completing its mission. {0} = pokémon
globals.keysEx.ESCORT_ADD = "MISSION_ESCORT_ADD" --Message for adding one escort guest to the party {0} = guest
globals.keysEx.ESCORT_ADD_PLURAL = "MISSION_ESCORT_ADD_PLURAL" --Message for adding multiple escort guests to the party. {0} = list of guests
globals.keysEx.ESCORT_REACHED = "MISSION_ESCORT_REACHED" --Message for finding an escort target. {0} = client, {1} = target
globals.keysEx.ESCORT_THANKS = "MISSION_ESCORT_THANKS" --Dialogue from the guest thanking the player. {0} = target
globals.keysEx.ESCORT_DEPART = "MISSION_ESCORT_DEPART" --Message for client and target leaving the dungeon. {0} = client, {1} = target
globals.keysEx.ESCORT_UNAVAILABLE = "MISSION_ESCORT_UNAVAILABLE" --Message for the guest being fainted or not close enough to the target. {0} = client, {1} = target
globals.keysEx.ESCORT_FAINTED = "MISSION_ESCORT_FAINTED" --Message for the escort getting knocked out
globals.keysEx.EXPLORATION_REACHED = "MISSION_EXPLORATION_REACHED" --Message for reaching an exploration target floor. {0} = client, {1} = dungeon
globals.keysEx.EXPLORATION_THANKS = "MISSION_EXPLORATION_THANKS" --Dialogue from the guest thanking the player. {1} = dungeon
globals.keysEx.EXPLORATION_DEPART = "MISSION_EXPLORATION_DEPART" --Message for the exploration client leaving the dungeon. {0} = client, {1} = dungeon
globals.keysEx.LOST_ITEM_RETRIEVED = "DLG_MISSION_LOST_ITEM_RETRIEVED" --Message for retrieving a lost item. {0} = client, {1} = item
globals.keysEx.OUTLAW_SPAWN_FAIL = "DLG_MISSION_OUTLAW_SPAWN_FAIL"  --Message for whenever an outlaw fails to spawn
globals.keysEx.OUTLAW_REACHED = "DLG_MISSION_OUTLAW_REACHED" --Message for reaching an outlaw floor. {0} = outlaw
globals.keysEx.OUTLAW_FLEE = "DLG_MISSION_OUTLAW_FLEE" --Intro dialogue for a fleeing outlaw.
globals.keysEx.OUTLAW_FLED = "DLG_MISSION_OUTLAW_FLED" --Message for a fleeing outlaw managing to escape. {0} = outlaw
globals.keysEx.OUTLAW_MONSTER_HOUSE = "DLG_MISSION_OUTLAW_MONSTER_HOUSE" --Intro dialogue for an outlaw with monster house.
globals.keysEx.OUTLAW_DEFEATED = "DLG_MISSION_OUTLAW_DEFEATED" --Message for an outlaw being defeated. {0} = outlaw
globals.keysEx.OUTLAW_MINIONS_DEFEATED = "DLG_MISSION_OUTLAW_MINIONS_DEFEATED" --Dialogue from an outlaw thanking the player
globals.keysEx.OUTLAW_BOSS_DEFEATED = "DLG_MISSION_OUTLAW_BOSS_DEFEATED" --Message for an outlaw with monster house being defeated. {0} = outlaw
globals.keysEx.OUTLAW_HOUSE_DEFEATED = "DLG_MISSION_OUTLAW_HOUSE_DEFEATED" --Message for an outlaw monster house being fully defeated. {0} = outlaw
globals.keysEx.OUTLAW_ITEM_RETRIEVED = "DLG_MISSION_OUTLAW_ITEM_RETRIEVED" --Message for retrieving the stolen item from an outlaw. {0} = outlaw, {1} = item
globals.keysEx.OUTLAW_ITEM_UNK_RETRIEVED = "DLG_MISSION_OUTLAW_ITEM_UNK_RETRIEVED" --Message for retrieving the stolen item from an outlaw before defeating the outlaw. {0} = outlaw, {1} = item
globals.keysEx.OUTLAW_ITEM_UNK_DEFEATED = "DLG_MISSION_OUTLAW_ITEM_UNK_DEFEATED" --Message for defeating an outlaw whose identity was unknown and seeing it drop the stolen item. {0} = outlaw, {1} = item
globals.keysEx.CONTINUE_ONGOING = "DLG_MISSION_CONTINUE_ONGOING" --Message that asks whether or not to stay in a dungeon when there are still more jobs.
globals.keysEx.CONTINUE_CONFIRM = "DLG_MISSION_CONTINUE_CONFIRM" --Message that asks for confirmation before leaving a dungeon when there are still more jobs.
globals.keysEx.CONTINUE_NO_ONGOING = "DLG_MISSION_CONTINUE_NO_ONGOING" --Message that asks whether or not to stay in a dungeon when there are no more jobs.
globals.keysEx.CUTSCENE_AWARD_ITEM = "MISSION_COMPLETED_CUTSCENE_AWARD_ITEM" --Message used to notify the player about the item they were awarded. {0} = team, {1} = item
globals.keysEx.CUTSCENE_AWARD_ITEM_STORAGE = "MISSION_COMPLETED_CUTSCENE_AWARD_ITEM_STORAGE" --Message used to notify the player about fact that the item they were awarded was sent to storage. {0} = team, {1} = item
globals.keysEx.CUTSCENE_AWARD_MONEY = "MISSION_COMPLETED_CUTSCENE_AWARD_MONEY" --Message used to notify the player about the sum of money they were awarded. {0} = team, {1} = money
globals.keysEx.CUTSCENE_AWARD_CHAR = "MISSION_COMPLETED_CUTSCENE_AWARD_CHAR" --Dialogue from a client that wants to join the team as the reward. {0} = team
globals.keysEx.CUTSCENE_AWARD_CHAR_PROMPT = "MISSION_COMPLETED_CUTSCENE_AWARD_CHAR_PROMPT" --Message asking the player if they want the client as a team member. {0} = team, {1} = client
globals.keysEx.CUTSCENE_AWARD_EXTRA = "MISSION_COMPLETED_CUTSCENE_AWARD_EXTRA" --Message used to notify the player about the extra reward they were awarded. {0} = team, {1} = amount
globals.keysEx.CUTSCENE_AWARD_RANK_UP = "MISSION_COMPLETED_CUTSCENE_AWARD_RANK_UP" --Message used to notify the player about a rank up. {0} = team, {1} = original rank, {2} = new rank

library.globals = globals

-- ----------------------------------------------------------------------------------------- --
-- #region Data generator
-- ----------------------------------------------------------------------------------------- --
-- Here at the top for easy access and reference, so that it is possible for modders to
-- understand how the data is structured.

--- Loads the root of the main data structure, generating the specified nodes if necessary.
function library:load()
    if _DIAG.DevMode then
        local succ, checker = pcall(require, "missiongen_lib.missiongen_devcheck")
        if succ then checker.check(self) end
    end

    local rootpath = self.data.sv_root_name
    if type(rootpath) ~= "table" then
        ---@cast rootpath string[]
        rootpath = { self.data.sv_root_name --[[@as string]] }
    end
    self.root = SV
    for _, id in ipairs(rootpath) do
        self.root[id] = self.root[id] or {}
        self.root = SV[id]
    end
    self.root.mission_flags = self.root.mission_flags or {}
    self:loadDifficulties()
    self:generateBoards()
    self:loadDungeonTable()
end

--- Loads the difficulty data and generates forward and backwards reference lists.
function library:loadDifficulties()
    self.data.num_to_difficulty = self.data.difficulty_list
    self.data.difficulty_to_num = {}
    for i, diff in ipairs(self.data.num_to_difficulty) do
        self.data.difficulty_to_num[diff] = i
    end
end

--- Generates the job board data structures inside the SV table.
function library:generateBoards()
    self.root.taken = self.root.taken or {}
    self.root.boards = self.root.boards or {}
    for board_id in pairs(self.data.boards) do
        self.root.boards[board_id] = self.root.boards[board_id] or {}
    end
end

--- Loads the dungeon progress table. Any completed dungeons that are missing from this table will have only
--- their segment 0 marked as completed.
--- In other words, when a mod with this library is loaded for the first time, it will assume, for all dungeons,
--- that only segment 0 has been completed
function library:loadDungeonTable()
    self.root.dungeon_progress = self.root.dungeon_progress or {}
    local UnlockState = RogueEssence.Data.GameProgress.UnlockState
    for dungeon in pairs(self.data.dungeons) do
        if not self.root.dungeon_progress[dungeon] and _DATA.Save.DungeonUnlocks:ContainsKey(dungeon) then
            if _DATA.Save.DungeonUnlocks[dungeon] == UnlockState.Completed then
                self.root.dungeon_progress[dungeon] = {[0] = true} --default to segment 0 completed
            elseif _DATA.Save.DungeonUnlocks[dungeon] == UnlockState.Discovered then
                self.root.dungeon_progress[dungeon] = {[0] = false} --default to segment 0 unlocked
            end
        end
    end
end

--- Returns an empty job table, also known as a job template.
--- @return jobTable #a new empty job template
local jobTemplate = function()
    return {
        ---@type monsterIDTable MonsterID style table describing the client
        Client = nil,
        ---@type monsterIDTable|nil MonsterID style table describing the target. Ignored if the job type expects no target
        Target = nil,
        ---@type {[1]:string, [2]:string} Pair of string keys displayed when the job details are displayed. The second key is optional
        Flavor = {"", ""},
        ---@type string String key displayed when browsing quest boards
        Title = "",
        ---@type string The id of the zone this job takes place in
        Zone = "",
        ---@type integer The specific segment this job takes place in
        Segment = -1,
        ---@type integer The destination floor of this job
        Floor = -1,
        ---@type string The id of the combination of rewards that will be awarded by this job
        RewardType = "",
        ---@type itemTable|nil Data of the first item awarded by the job. Ignored if the reward type does not include a visible item reward
        Reward1 = {},
        ---@type itemTable|nil Data of the second item awarded by the job. Ignored if the reward type does not include a hidden item reward
        Reward2 = {},
        ---@type string The id of the type of this job
        Type = "",
        ---@type integer the state of the job. -1 means failed. 0 means not completed. 1 means completed. This is always reset to 0 on day end if the job rewards are not claimed (like when an adventure is failed).
        Completion = 0,
        ---@type boolean Taken list: if true, the job is active. Boards: if true, the job is inside the taken list
        Taken = false,
        ---@type string|nil Contains the name of the board it was in. It is used only in the taken list for discarding jobs and for routing the player during the reward process.
        BackReference = nil,
        ---@type integer The difficulty index of this job.
        Difficulty = -1,
        ---@type string|nil The id of the item this job requires. Ignored if the job type requires no items.
        Item = "",
        ---@type string|nil special jobs can be triggered sometimes. If so, this will contain the special job category id.
        Special = "",
        ---@type boolean Some job types have a chance to have their floor hidden. If this is true, hide the floor.
        HideFloor = false,
        ---@type table<eventId, {name:string,args:table}> table of callbacks with their respective parameters
        Callbacks = {},
        ---@type table<string,string> String keys to be used instead of the normal ones in various places in the Job Menu
        MenuOverrides = {}
    }
end

--- Returns an empty monster id table, also known as a monster id template.
--- @return monsterIDTable #an empty MonsterID-style table
local monsterIdTemplate = function()
    ---@type monsterIDTable
    return {
        ---@type string|nil Optional. The nickname to apply to the character
        Nickname = nil,
        ---@type string The species of the character
        Species = "",
        ---@type integer|nil Optional. The form of the character. Defaults to 0
        Form = 0,
        ---@type string|nil Optional. The skin to apply to the character. Defaults to "normal"
        Skin = "normal",
        ---@type integer|nil Optional. The gender of the character. If absent or equal to -1, it will be rolled upon job generation
        Gender = -1
    }
end

---Initializes a new event table and associates to a specific job
---@param job jobTable the job associated to this event
---@return eventTable #an event table associated to a specific job
local newEvent = function(job)
    return {
        cancel = false,
        job = job,
        data = {}
    }
end
-- ----------------------------------------------------------------------------------------- --
-- #region Logging
-- ----------------------------------------------------------------------------------------- --
-- Functions that write to the output log

--- Prints a message prefixed with an error type.
--- @param error_type string the error type prefix
--- @param message string the message of the error itself
local logError = function(error_type, message)
    PrintInfo("["..error_type.."] "..message)
end

--- Same as "logError" but does not print anything outside of dev mode.
--- Used for out-of-box events that may or may not be intentional, or for
--- low-priority problems that the system can handle by itself without much issue.
--- @param warn_type string the error type prefix
--- @param message string the message of the error itself
local logWarn = function(warn_type, message)
    if _DIAG.DevMode then logError(warn_type, message) end
end

--- Debug function that prints an entire table to console.
--- @param tabl table the table to print
function library:printall(tabl)
    ---@type function
    local printall
    printall = function(tbl, level, root)
        if root == nil then print(" ") end

        if tbl == nil then print("<nil>") return end
        if level == nil then level = 0 end
        for key, value in pairs(tbl) do
            local spacing = ""
            for _=1, level*2, 1 do
                spacing = " "..spacing
            end
            if type(value) == 'table' then
                print(spacing..tostring(key).." = {")
                printall(value, level+1, false)
                print(spacing.."}")
            else
                print(spacing..tostring(key).." = "..tostring(value))
            end
        end

        if root == nil then print(" ") end
    end
    printall(tabl)
end

-- ----------------------------------------------------------------------------------------- --
-- #region Misc
-- ----------------------------------------------------------------------------------------- --
-- Miscellaneous helper functions only callable from within this file

---Takes a list and returns a new, shuffled version of the integer pairs in the list.
---The returned list is new, meaning that tbl is left unmodified, but the items inside are not copies.
---Use deepCopy afterwards if you need to edit them.
---@param tbl any[] a table to shuffle
---@return any[] a shuffled version of the table
local shuffleTable = function(tbl, replay_sensitive)
    local indices = COMMON.GetSortedKeys(tbl, true)
    local shuffled = {}
    for _=1, #tbl, 1 do
        local index, pos = library:WeightlessRandom(indices, replay_sensitive)
        table.remove(indices, pos)
        table.insert(shuffled, tbl[index])
    end
    return shuffled
end

--- Rolls a MonsterForm's gender and returns it as a number.
--- @param species string the id of the species to roll the gender of
--- @param form integer the index of the form to roll the gender of
--- @return integer #a gender index number
local rollMonsterGender = function(species, form)
    return library:GenderToNumber(_DATA:GetMonster(species).Forms[form]:RollGender(_DATA.Save.Rand))
end

--- Creates a deep copy of a table and returns it.
--- This function checks for redundant paths to avoid infinite recursion.
--- @generic T:table
--- @param tbl T the table to deep copy
--- @return T #the copy
local deepCopy = function(tbl)
    local deepcopy
    deepcopy = function(orig, copies)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            if copies[orig] then
                copy = copies[orig]
            else
                copy = {}
                copies[orig] = copy
                for orig_key, orig_value in next, orig, nil do
                    copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
                end
                setmetatable(copy, deepcopy(getmetatable(orig), copies))
            end
        else -- number, string, boolean, etc
            copy = orig
        end
        return copy
    end
    return deepcopy(tbl, {})
end


--- Creates a shallow copy of a table by simply creating a new table and copying
--- all surface level key-value pairs into it from the original.
--- @generic T : table
--- @param tbl T the table to copy
--- @return T #the copy
local shallowCopy = function(tbl)
    local copy = {}
    for key, value in pairs(tbl) do
        copy[key] = value
    end
    return copy
end

--- Sorting function used for job lists.
--- @param j1 jobTable a job table
--- @param j2 jobTable another job table
--- @return boolean true if j1 goes after j2, false otherwise
local sortJobs = function(j1, j2)
    -- If one is nil and the other is not, put the nil one at the end
    if not library.data.dungeon_order[j1.Zone] and library.data.dungeon_order[j2.Zone] then return true end
    if library.data.dungeon_order[j1.Zone] and not library.data.dungeon_order[j2.Zone] then return false end
    -- Sort by dungeon order first and foremost
    if library.data.dungeon_order[j1.Zone] == library.data.dungeon_order[j2.Zone] then
        -- Sort by zone alphabetically
        if j1.Zone == j2.Zone then
            -- Sort by segment
            if j1.Segment == j2.Segment then
                -- Sort by floor
                return j1.Floor < j2.Floor
            else
                return j1.Segment < j2.Segment
            end
        else
            return j1.Zone < j2.Zone
        end
    else
        return library.data.dungeon_order[j1.Zone] < library.data.dungeon_order[j2.Zone]
    end
end

--- Signals the triggering of an event. If the triggering job has a callback associated with it, it will be called as well.
--- @param job jobTable the job that triggered the event
--- @param event_id eventId the event that has been triggered
--- @param extra_data? table<string, any> a table that will be attached to the base event table to pass more data to the callback
--- @return eventTable #the final state of the event table
local callEvent = function(job, event_id, extra_data)
    if extra_data == nil then extra_data = {} end
    local evt = newEvent(job)
    evt.data = extra_data
    local cb = job.Callbacks[event_id]
    if cb then
        library.data.mission_callback_root[cb.name](evt, shallowCopy(cb.args or {}))
    end
    return evt
end

---Clears all effects from a Character.
---@param char Character the Character to remove effects from.
local RemoveCharEffects = function(char)
    char.StatusEffects:Clear();
    char.ProxyAtk = -1;
    char.ProxyDef = -1;
    char.ProxyMAtk = -1;
    char.ProxyMDef = -1;
    char.ProxySpeed = -1;
end

---Displays the warp out animation for the whole party, guests included.
local warpOut = function()
    local player_count = GAME:GetPlayerPartyCount()
    local guest_count = GAME:GetPlayerGuestCount()
    for i = 0, player_count - 1, 1 do
        local player = GAME:GetPlayerPartyMember(i)
        if not player.Dead then
            GAME:WaitFrames(30)
            local anim = RogueEssence.Dungeon.CharAbsentAnim(player.CharLoc, player.CharDir)
            RemoveCharEffects(player)
            TASK:WaitTask(_DUNGEON:ProcessBattleFX(player, player, _DATA.SendHomeFX))
            TASK:WaitTask(player:StartAnim(anim))
        end
    end

    for i = 0, guest_count - 1, 1 do
        local guest = GAME:GetPlayerGuestMember(i)
        if not guest.Dead then
            GAME:WaitFrames(30)
            local anim = RogueEssence.Dungeon.CharAbsentAnim(guest.CharLoc, guest.CharDir)
            RemoveCharEffects(guest)
            TASK:WaitTask(_DUNGEON:ProcessBattleFX(guest, guest, _DATA.SendHomeFX))
            TASK:WaitTask(guest:StartAnim(anim))
        end
    end
end

--- Flow of execution specific of rescue jobs.
--- @param context any c# BattleEvent context
--- @param job jobTable the job in question
local rescueReachedFlow = function(context, job)
    local targetName = context.Target:GetDisplayName(true)
    UI:ChoiceMenuYesNo(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.RESCUE_FOUND):ToLocal(), targetName), false)
    UI:WaitForChoice()
    local use_badge = UI:ChoiceResult()
    if use_badge then
        --Mark mission completion flags
        library.root.mission_flags.MissionCompleted = true
        --Clear but remember minimap state
        library.root.mission_flags.PriorMapSetting = _DUNGEON.ShowMap
        _DUNGEON.ShowMap = _DUNGEON.MinimapState.None
        GAME:WaitFrames(20)
        library:MarkJobCompleted(job)
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.RESCUE_CONFIRM):ToLocal(), targetName))
        GAME:WaitFrames(20)
        UI:SetSpeaker(context.Target)

        --different responses for special targets
        UI:SetSpeakerEmotion("Normal")
        local case = "_DEFAULT"
        if job.Special and library.data.rescue_responses.rescue_yes[job.Special] then case = job.Special end
        local caseTable = library:WeightedRandom(library.data.rescue_responses.rescue_yes[case]) --[[@as {key:string, emotion:emotionType|nil}]]
        if caseTable.emotion then UI:SetSpeakerEmotion(caseTable.emotion) end
        UI:WaitShowDialogue(RogueEssence.StringKey(caseTable.key):ToLocal())

        GAME:WaitFrames(20)
        UI:ResetSpeaker()
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.TARGET_LEFT):ToLocal(), targetName))
        GAME:WaitFrames(20)
        -- warp out
        TASK:WaitTask(_DUNGEON:ProcessBattleFX(context.Target, context.Target, _DATA.SendHomeFX))
        _DUNGEON:RemoveChar(context.Target)
        GAME:WaitFrames(50)
        library:AskMissionWarpOut()
    else
        --quickly hide the minimap for the 20 frame pause
        local map_setting = _DUNGEON.ShowMap
        _DUNGEON.ShowMap = _DUNGEON.MinimapState.None
        GAME:WaitFrames(20)
        UI:SetSpeaker(context.Target)
        UI:SetSpeakerEmotion("Normal")
        local case = "_DEFAULT"
        if job.Special and library.data.rescue_responses.rescue_no[job.Special] then case = job.Special end
        local caseTable = library:WeightedRandom(library.data.rescue_responses.rescue_no[case]) --[[@as {key:string, emotion:emotionType|nil}]]
        if caseTable.emotion then UI:SetSpeakerEmotion(caseTable.emotion) end
        UI:WaitShowDialogue(RogueEssence.StringKey(caseTable.key):ToLocal())

        --change map setting back to what it was
        _DUNGEON.ShowMap = map_setting
        GAME:WaitFrames(20)
    end
end

--- Flow of execution specific of delivery jobs.
--- @param context any c# BattleEvent context
--- @param job jobTable the job in question
local deliveryReachedFlow = function(context, job, oldDir)
    local targetName = context.Target:GetDisplayName(true)
    -- Take from inventory first before held items
    local inv_slot = GAME:FindPlayerItem(job.Item, false, true)
    if not inv_slot:IsValid() then inv_slot = GAME:FindPlayerItem(job.Item, true, false) end
    local item_name =  RogueEssence.Dungeon.InvItem(job.Item):GetDisplayName()

    if inv_slot:IsValid() then
        UI:ChoiceMenuYesNo(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.DELIVERY_FOUND):ToLocal(), targetName, item_name))
        UI:WaitForChoice()
        local deliver_item = UI:ChoiceResult()
        if deliver_item then
            library.root.mission_flags.MissionCompleted = true
            library:MarkJobCompleted(job)
            --Clear but remember minimap state
            library.root.mission_flags.PriorMapSetting = _DUNGEON.ShowMap
            _DUNGEON.ShowMap = _DUNGEON.MinimapState.None
            if not inv_slot.IsEquipped then
                GAME:TakePlayerBagItem(inv_slot.Slot)
            else
                GAME:TakePlayerEquippedItem(inv_slot.Slot)
            end
            GAME:WaitFrames(20)
            UI:SetSpeaker(context.Target)
            UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.DELIVERY_CONFIRM):ToLocal(), item_name))
            GAME:WaitFrames(20)
            UI:ResetSpeaker()
            UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.TARGET_LEFT):ToLocal(), targetName))
            GAME:WaitFrames(20)
            TASK:WaitTask(_DUNGEON:ProcessBattleFX(context.Target, context.Target, _DATA.SendHomeFX))
            _DUNGEON:RemoveChar(context.Target)
            GAME:WaitFrames(50)
            library:AskMissionWarpOut()
        else --they are sad if you dont give them the item
            --quickly hide the minimap for the 20 frame pause
            local map_setting = _DUNGEON.ShowMap
            _DUNGEON.ShowMap = _DUNGEON.MinimapState.None
            GAME:WaitFrames(20)
            UI:SetSpeaker(context.Target)
            UI:SetSpeakerEmotion("Sad")
            UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.DELIVERY_DENY):ToLocal(), item_name))
            --change map setting back to what it was
            _DUNGEON.ShowMap = map_setting
            GAME:WaitFrames(20)
        end
    else
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.DELIVERY_NO_ITEM):ToLocal(), targetName, item_name))
        --quickly hide the minimap for the 20 frame pause
        local map_setting = _DUNGEON.ShowMap
        _DUNGEON.ShowMap = _DUNGEON.MinimapState.None
        GAME:WaitFrames(20)
        UI:SetSpeaker(context.Target)
        UI:SetSpeakerEmotion("Sad")
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.DELIVERY_NO_ITEM_CHAR):ToLocal(), item_name))
        --change map setting back to what it was
        _DUNGEON.ShowMap = map_setting
        GAME:WaitFrames(20)
        context.Target.CharDir = oldDir
    end
end

--- Resets the animations of all characters in the party.
local resetAnims = function()
    local player_count = GAME:GetPlayerPartyCount()
    local guest_count = GAME:GetPlayerGuestCount()
    for i = 0, player_count - 1, 1 do
        local player = GAME:GetPlayerPartyMember(i)
        if not player.Dead then
            local anim = RogueEssence.Dungeon.CharAnimAction()
            anim.BaseFrameType = 0 --none
            anim.AnimLoc = player.CharLoc
            anim.CharDir = player.CharDir
            TASK:WaitTask(player:StartAnim(anim))
        end
    end

    for i = 0, guest_count - 1, 1 do
        local guest = GAME:GetPlayerGuestMember(i)
        if not guest.Dead then
            local anim = RogueEssence.Dungeon.CharAnimAction()
            anim.BaseFrameType = 0 --none
            anim.AnimLoc = guest.CharLoc
            anim.CharDir = guest.CharDir
            TASK:WaitTask(guest:StartAnim(anim))
        end
    end
end

--- Returns a set of all types that cover the weaknesses of a type combination.
--- @return referenceSet #a table whose keys are element ids and whose valòues are ``true``
local getCoverageTypes = function(types)
    local all_types = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Element]:GetOrderedKeys(true)
    local weaknesses = {}
    local coverage = {}
    for id in luanet.each(all_types) do
        local matchup = 0
        for _, id2 in ipairs(types) do
            matchup = matchup + PMDC.Dungeon.PreTypeEvent.CalculateTypeMatchup(id, id2)
        end
        if matchup >= PMDC.Dungeon.PreTypeEvent.S_E_2 then
            table.insert(weaknesses, id)
        end
    end
    for id in luanet.each(all_types) do
        for _, id2 in ipairs(weaknesses) do
            local matchup = PMDC.Dungeon.PreTypeEvent.CalculateTypeMatchup(id, id2)
            if matchup >= PMDC.Dungeon.PreTypeEvent.S_E then
                coverage[id] = true
                break
            end
        end
    end
    return coverage
end

--- Checks for synergies a move can make and stores them in its moveset entry
--- @param skill any a RogueEssence.Data.SkillData object
--- @param entry moveset_entry the moveset entry to store data in
local synergyLookup = function(skill, entry)
    local data = skill.Data

    local memory = {}
    for pair in luanet.each(LUA_ENGINE:MakeList(data.BeforeTryActions)) do
        if LUA_ENGINE:TypeOf(pair.Value) == luanet.ctype(globals.ctypes.WeatherNeededEvent) then
            --before try actions, WeatherNeededEvent and ChargeOrReleaseEvent, request "weather <WeatherID>"
            if memory.weather and memory.weather.chargerelease and not memory.weather.request then
                table.insert(entry.RequestSynergy, "weather "..pair.Value.WeatherID)
            end
            memory.weather = memory.weather or {}
            memory.weather.request = "weather "..pair.Value.WeatherID
        elseif LUA_ENGINE:TypeOf(pair.Value) == luanet.ctype(globals.ctypes.ChargeOrReleaseEvent) then
            --before try actions, WeatherNeededEvent and ChargeOrReleaseEvent, request "weather <WeatherID>"
            if memory.weather and memory.weather.request and not memory.weather.chargerelease then
                table.insert(entry.RequestSynergy, memory.weather.request)
            end
            memory.weather = memory.weather or {}
            memory.weather.chargerelease = true
        end
    end
    for pair in luanet.each(LUA_ENGINE:MakeList(data.BeforeActions)) do
        if LUA_ENGINE:TypeOf(pair.Value) == luanet.ctype(globals.ctypes.AddContextStateEvent) then
            --before actions, AddContextStateEvent.SleepAttack, request "user sleep"
            if not pair.Value.Global and LUA_ENGINE:TypeOf(pair.Value.AddedState) == luanet.ctype(globals.ctypes.SleepAttack) then
                table.insert(entry.RequestSynergy, "user sleep")
            end
        end
    end
    for pair in luanet.each(LUA_ENGINE:MakeList(data.OnActions)) do
        if LUA_ENGINE:TypeOf(pair.Value) == luanet.ctype(globals.ctypes.StatusStackDifferentEvent) then
            --on actions, StatusStackDifferentEvent, request "user <StatusID>"
            table.insert(entry.RequestSynergy, "user "..pair.Value.StatusID)
        elseif LUA_ENGINE:TypeOf(pair.Value) == luanet.ctype(globals.ctypes.MajorStatusPowerEvent) then
            --on actions, MajorStatusPowerEvent(num>den), request "<AffectedTarget> MajorStatus"
            if pair.Value.Numerator > pair.Value.Denominator then
                local target = "user"
                if pair.Value.AffectTarget == true then target = "target" end
                table.insert(entry.RequestSynergy, target.." major status")
            end
        end
    end
    for pair in luanet.each(LUA_ENGINE:MakeList(data.BeforeHits)) do
        if LUA_ENGINE:TypeOf(pair.Value) == luanet.ctype(globals.ctypes.StatusPowerEvent) then
            --before hits, StatusPowerEvent, request "<AffectTarget> <StatusID>"
            local target = "user"
            if pair.Value.AffectTarget == true then target = "target" end
            table.insert(entry.RequestSynergy, target.." "..pair.Value.StatusID)
        end
    end
    for pair in luanet.each(LUA_ENGINE:MakeList(data.OnHits)) do
        if LUA_ENGINE:TypeOf(pair.Value) == luanet.ctype(globals.ctypes.GiveMapStatusEvent) then
            --on hits, GiveMapStatusEvent, apply "weather <WeatherID>"
            table.insert(entry.ApplySynergy, "weather "..pair.Value.StatusID)
        elseif LUA_ENGINE:TypeOf(pair.Value) == luanet.ctype(globals.ctypes.StatusBattleEvent) then
            --on hits, StatusBattleEvent, apply "<AffectTarget> <StatusID>"
            local target = "user"
            if pair.Value.AffectTarget == true then target = "target" end
            local status = _DATA:GetStatus(pair.Value.StatusID)
            for state in luanet.each(status.StatusStates) do
                if LUA_ENGINE:TypeOf(state) == luanet.ctype(globals.ctypes.MajorStatusState) then
                    table.insert(entry.ApplySynergy, target.." major status")
                end
            end
            table.insert(entry.ApplySynergy, target.." "..pair.Value.StatusID)
        elseif LUA_ENGINE:TypeOf(pair.Value) == luanet.ctype(globals.ctypes.AdditionalEvent) then
            --on hits, AdditionalEvent.StatusBattleEvent, apply "<AffectTarget> <StatusID>"
            for event in luanet.each(pair.Value.BaseEvents) do
                if LUA_ENGINE:TypeOf(event) == luanet.ctype(globals.ctypes.StatusBattleEvent) then
                    local target = "user"
                    if pair.Value.AffectTarget == true then target = "target" end
                    local status = _DATA:GetStatus(event.StatusID)
                    for state in luanet.each(status.StatusStates) do
                        if LUA_ENGINE:TypeOf(state) == luanet.ctype(globals.ctypes.MajorStatusState) then
                            table.insert(entry.ApplySynergy, target.." major status")
                        end
                    end
                    table.insert(entry.ApplySynergy, target.." "..event.StatusID)
                end
            end
        end
    end
end

--- Generates a list of allowed moves for a specific character, taking into account how that move can be obtained.
--- @param chara any The character to check
--- @param tm_allowed boolean If true, the tm list will be populated
--- @param tutor_allowed boolean If true, the tutor list will be populated
--- @param egg_allowed boolean If true, the egg list will be populated
--- @param blacklist referenceSet a reference set of moves that must never be picked no matter what
--- @return {all:moveset_list, level:moveset_supertable,tm:moveset_supertable,tutor:moveset_supertable,egg:moveset_supertable}
local filterMoveset = function(chara, tm_allowed, tutor_allowed, egg_allowed, blacklist)
    ---@type {all:moveset_list, level:moveset_supertable,tm:moveset_supertable,tutor:moveset_supertable,egg:moveset_supertable}
    local moveset_table = {
        all = {
        },
        level = {
            stab = {},
            coverage = {},
            damage = {},
            status = {}
        },
        tm = {
            stab = {},
            coverage = {},
            damage = {},
            status = {}
        },
        tutor = {
            stab = {},
            coverage = {},
            damage = {},
            status = {}
        },
        egg = {
            stab = {},
            coverage = {},
            damage = {},
            status = {}
        }
    }
    local workPhases = {
        {"level", true,          function(form) return form.LevelSkills end},
        {"tm",    tm_allowed,    function(form) return form.TeachSkills end},
        {"tutor", tutor_allowed, function(form) return form.SecretSkills end},
        {"egg",   egg_allowed,   function(form) return form.SharedSkills end}
    }
    local stages = {}
    local evolutionStage = chara.BaseForm
    local stageData = _DATA:GetMonster(evolutionStage.Species)
    local stageForm = stageData.Forms[evolutionStage.Form]

    local types = {stageForm.Element1, stageForm.Element1}
    if stageForm.Element2 ~= "" then types[2] = stageForm.Element2 end
    local coverage = getCoverageTypes(types)
    local attackStats = {stageForm.BaseAtk, stageForm.BaseMAtk}
    while (evolutionStage:IsValid()) do
        stageData = _DATA:GetMonster(evolutionStage.Species)
        stageForm = stageData.Forms[evolutionStage.Form]
        table.insert(stages, stageForm)
        evolutionStage = RogueEssence.Dungeon.MonsterID(stageData.PromoteFrom, stageForm.PromoteForm, evolutionStage.Skin, evolutionStage.Gender);
    end

    for _, form in ipairs(stages) do
        for _, phase in ipairs(workPhases) do
            if phase[2] then
                local supertable = phase[1]
                local skillList = phase[3](form)
                for i=0, skillList.Count-1, 1 do
                    if not skillList[i].Level or skillList[i].Level<=chara.Level then
                        local skill = skillList[i].Skill
                        local value = {ID = skill, Type = "", Category = "status", Weight = 1000, ApplySynergy = {}, RequestSynergy = {}}
                        if not moveset_table.all[skill] and not blacklist[skill] then
                            local skillData = _DATA:GetSkill(skill)
                            value.Type = skillData.Element
                            local category, subtables = -1, {}
                            if skillData.Data.Category == RogueEssence.Data.BattleData.SkillCategory.Status then
                                category, subtables = 0, {"status"}
                                synergyLookup(skillData, value)
                                table.insert(moveset_table[supertable].status, value) --we save now because the other categories are damage only anyway
                            elseif skillData.Data.Category == RogueEssence.Data.BattleData.SkillCategory.Physical then
                                category, subtables = 1, {"damage"}
                            elseif skillData.Data.Category == RogueEssence.Data.BattleData.SkillCategory.Magical then
                                category, subtables = 2, {"damage"}
                            end
                            if category > 0 then
                                value.Category = "damage"
                                synergyLookup(skillData, value)
                                local PowerStateType = luanet.import_type('RogueEssence.Dungeon.BasePowerState')
                                local power = skillData.Data.SkillStates:GetWithDefault(luanet.ctype(PowerStateType))
                                if power and power.Power>0 then power = power.Power else power = 40 end
                                local weight = power * skillData.Strikes * attackStats[category]
                                if types[1] == skillData.Data.Element or types[2] == skillData.Data.Element then
                                    weight = math.floor(weight*1.5)
                                    table.insert(subtables, "stab")
                                end
                                if coverage[skillData.Data.Element] then
                                    table.insert(subtables, "coverage")
                                end
                                for _, subtable in ipairs(subtables) do
                                    value.Weight = weight
                                    table.insert(moveset_table[supertable][subtable], value)
                                end
                            end
                            if #subtables>0 then
                                moveset_table.all[skill] = {cat = subtables, tables = {supertable}, value = value}
                            end
                        else
                            for _, subtable in ipairs(moveset_table.all[skill].cat) do
                                table.insert(moveset_table[supertable][subtable], moveset_table.all[skill].value)
                            end
                            table.insert(moveset_table.all[skill].tables, supertable)
                        end
                    end
                end
            end
        end
    end

    return moveset_table
end

local moveSelection = {}
--- Picks one stab move if the list is not empty. Otherwise, coverage gets called.
--- @param moveset_table {all:moveset_list, level:moveset_supertable,tm:moveset_supertable,tutor:moveset_supertable,egg:moveset_supertable} the moveset table
--- @param synergies table<"_Completed"|integer,synergyEntry|referenceSet> the synergy table
--- @param allowed table<categoryType, integer> number of allowed moves per category
function moveSelection.stab(moveset_table, synergies, allowed)
    local fallback = function() return moveSelection.coverage(moveset_table, synergies, allowed) end
    return moveSelection.selectMove(moveset_table, synergies, allowed, "stab", fallback)
end

--- Picks one coverage move if the list is not empty. Otherwise, damage gets called.
--- @param moveset_table {all:moveset_list, level:moveset_supertable,tm:moveset_supertable,tutor:moveset_supertable,egg:moveset_supertable} the moveset table
--- @param synergies table<"_Completed"|integer,synergyEntry|referenceSet> the synergy table
--- @param allowed table<categoryType, integer> number of allowed moves per category
function moveSelection.coverage(moveset_table, synergies, allowed)
    local fallback = function() return moveSelection.damage(moveset_table, synergies, allowed) end
    return moveSelection.selectMove(moveset_table, synergies, allowed, "coverage", fallback)
end

--- Picks one damaging move if the list is not empty. Otherwise, it picks one status move. If that list is also empty, it selects nothing.
--- @param moveset_table {all:moveset_list, level:moveset_supertable,tm:moveset_supertable,tutor:moveset_supertable,egg:moveset_supertable} the moveset table
--- @param synergies table<"_Completed"|integer,synergyEntry|referenceSet> the synergy table
--- @param allowed table<categoryType, integer> number of allowed moves per category
function moveSelection.damage(moveset_table, synergies, allowed)
    local pick_none = function() return "" end
    local fallback = function() return moveSelection.selectMove(moveset_table, synergies, allowed, "status", pick_none) end
    return moveSelection.selectMove(moveset_table, synergies, allowed, "damage", fallback)
end

--- Picks one status move if the list is not empty. Otherwise, it picks one damaging move. If that list is also empty, it selects nothing.
--- @param moveset_table {all:moveset_list, level:moveset_supertable,tm:moveset_supertable,tutor:moveset_supertable,egg:moveset_supertable} the moveset table
--- @param synergies table<"_Completed"|integer,synergyEntry|referenceSet> the synergy table
--- @param allowed table<categoryType, integer> number of allowed moves per category
function moveSelection.status(moveset_table, synergies, allowed)
    local pick_none = function() return "" end
    local fallback = function() return moveSelection.selectMove(moveset_table, synergies, allowed, "damage", pick_none) end
    return moveSelection.selectMove(moveset_table, synergies, allowed, "status", fallback)
end

--- Scans for possible synergies and returns a weight multiplier based on them.
--- @param data moveset_entry the data associated to a specific move
--- @param synergies table<"_Completed"|integer,synergyEntry|referenceSet> the synergy table
--- @return number #the final weight multiplier for the move
local getSynergyMultiplier = function(data, synergies)
    local mult = 1
    local fulfilled = false
    for _, syn_data in ipairs(synergies) do
        ---@cast syn_data synergyEntry
        --move allows a synergy another move requests
        for _, syn in ipairs(data.ApplySynergy) do
            if syn_data.RequestSynergy[syn] then
                mult = mult*1.75
                break
            end
        end
        --move requests a synergy another move allows
        for _, syn in ipairs(data.RequestSynergy) do
            if syn_data.ApplySynergy[syn] then
                mult = mult * 1.25
                break
            end
        end
        --discourage repeated types
        if data.Category ~= "status" and syn_data.Type == data.Type then
            mult = mult * 0.85
        end
    end
    --no move allows this synergy and this is the last move
    if #synergies == 3 and #data.RequestSynergy>0 and not fulfilled then
        return 0
    end
    return mult
end

--- Updates the synergy table by adding the synergies of the newly selected move.
--- @param data moveset_entry the synergy data for a move
--- @param synergies table<"_Completed"|integer,synergyEntry|referenceSet> the synergy table
local updateSynergies = function(data, synergies)
    ---@type synergyEntry
    local newdata = { RequestSynergy = {}, ApplySynergy = {}, Type = data.Type }
    for _, syn in ipairs(data.ApplySynergy) do
        -- don't do anything if the synergy was already completed
        if not synergies._Completed[syn] then
            for _, syn_data in ipairs(synergies) do
                ---@cast syn_data synergyEntry
                if syn_data.RequestSynergy[syn] then
                    synergies._Completed[syn] = true -- Complete the synergy if it is in requested list
                end
                if synergies._Completed[syn] then
                    syn_data.RequestSynergy = {} -- Clear synergy list. Completing one requested synergy is enough 99% of the times
                end
            end
            if not synergies._Completed[syn] then
                newdata.ApplySynergy[syn] = true -- Add to applied synergies if no picked move completed it
            end
        end
    end
    for _, syn in ipairs(data.RequestSynergy) do
        -- don't do anything if the synergy was already completed
        if not synergies._Completed[syn] then
            for _, syn_data in ipairs(synergies) do
                if syn_data.ApplySynergy[syn] then
                    synergies._Completed[syn] = true -- Complete the synergy if it is in applied list
                end
                if synergies._Completed[syn] then
                    syn_data.ApplySynergy[syn] = nil -- Remove from apply list of all moves
                end
            end
        end
        if synergies._Completed[syn] then -- not an else case because it might change status during the above loop
            newdata.RequestSynergy = {} -- Clean requested synergy list. Completing one requested synergy is enough 99% of the times
            break --RequestedSynergy is empty and it should stay that way. end the loop
        end
        newdata.RequestSynergy[syn] = true -- Add to requested synergies if no picked move completed it
    end
    table.insert(synergies, newdata)
end

---Picks one move from the subtable if the list is not empty. Otherwise, fallback gets called
---@param moveset_table {all:moveset_list, level:moveset_supertable,tm:moveset_supertable,tutor:moveset_supertable,egg:moveset_supertable} the moveset table
---@param synergies table<"_Completed"|integer,synergyEntry|referenceSet> the synergy table
---@param allowed table<categoryType, integer> number of allowed moves per category
---@param subtable slotType the slot to pick a move for
---@param fallback function function to call if the current settings would return nothing
function moveSelection.selectMove(moveset_table, synergies, allowed, subtable, fallback)
    ---@type moveset_entry[]
    local data_list = {}
    local id_list = {}
    local optional = {"tm", "tutor", "egg"}
    local phases = {"level"}
    for i, phase in ipairs(optional) do
        if allowed[phase]>0 then table.insert(phases, optional[i]) end
    end
    local maxweight = 0
    for _, tbl in ipairs(phases) do
        ---@type moveset_entry[]
        local list = deepCopy(moveset_table[tbl][subtable])
        for _, data in ipairs(list) do
            if not id_list[data.ID] then
                id_list[data.ID] = true
                if moveset_table.all[data.ID] then
                    table.insert(data_list, data)
                    --boost moves that would complete a synergy
                    data.Weight = data.Weight * getSynergyMultiplier(data, synergies)
                    maxweight = math.max(maxweight, data.Weight or 0)
                end
            end
        end
    end
    --heavily penalize lower weights, potentially removing them completely
    if #data_list>0 then
        local len = #data_list
        for i=1, len, 1 do
            local j = len -i + 1
            local data = data_list[j]
            local new_wt = data.Weight - (maxweight-data.Weight)
            if new_wt<=0 then table.remove(data_list, j)
            else
                data.Weight = math.floor(new_wt)
            end
        end
    end
    local result
    if #data_list > 0 then
        result = library:WeightedRandom(data_list, true) --[[@as moveset_entry]]
        updateSynergies(result, synergies)
        result = result.ID
        local supertables = moveset_table.all[result].tables
        allowed[supertables[1]] = allowed[supertables[1]]-1
        moveset_table.all[result] = nil
    else
        result = fallback()
    end
    return result
end

--- Returns a 2d iterator function that operates in an outwards-going, square spiral.
--- Every iteration returns a RogueElements.Loc, and an integer that's equal to the distance of the square it belongs to from the center of the spiral.
--- The function returned by this can be used to supply elements to for loops.
--- @param center {X:integer, Y:integer}
--- @param end_radius integer
--- @param start_radius? integer
--- @return fun():{X:integer, Y:integer}, integer
local iter_spiral = function(center, end_radius, start_radius)
    start_radius = start_radius or 0
    local phase_patterns = {
        fixd = { { var = "Y", sign = -1 }, { var = "X", sign = 1 }, { var = "Y", sign = 1 }, { var = "X", sign = -1 } },
        edit = { { var = "X", sign = 1 }, { var = "Y", sign = 1 }, { var = "X", sign = -1 }, { var = "Y", sign = -1 } }
    }
    local radius = start_radius
    local phase = 1 --1 = top, go right, 2 = right, go down, 3 = bottom, go left, 4 = left, go up
    local offset = 1 - radius
    return function()
        if radius == 0 then
            radius, offset = 1, 0
            return center, radius
        end

        if offset > radius then
            phase = phase + 1
            offset = 1 - radius
        end
        if phase > 4 then
            radius = radius + 1
            phase = 1
            offset = 1 - radius
        end
        ---@diagnostic disable-next-line: missing-return-value
        if radius > end_radius then return end

        local pos = { X = center.X, Y = center.Y }
        pos[phase_patterns.fixd[phase].var] = pos[phase_patterns.fixd[phase].var] +
            (phase_patterns.fixd[phase].sign * radius)
        pos[phase_patterns.edit[phase].var] = pos[phase_patterns.edit[phase].var] +
            (phase_patterns.edit[phase].sign * offset)

        offset = offset + 1
        return RogueElements.Loc(pos.X, pos.Y), radius
    end
end

--- Iterates through all enemies on the floor and calculates their average level, rounded up.
--- Used to generate the level of outlaws in reset dungeons.
--- @return integer #the average level of enemies on the floor
local getFloorAverage = function()
    local foes = LUA_ENGINE:MakeList(_ZONE.CurrentMap:IterateCharacters(false, true))
    local total = 0
    if foes.Count > 0 then
        for char in luanet.each(foes) do
            total = total + char.Level
        end
        return math.ceil(total / math.max(1, foes.Count))
    end
    --fallback for "no enemies around" case. Use players instead
    local players = _DATA.Save.ActiveTeam.Players
    for char in luanet.each(players) do
        total = total + char.Level
    end
    return math.ceil(total / players.Count)
end

--- Returns a list of valid forms for a species.
--- @param species string the id of the species to check
--- @param flee_check boolean if true, make sure that types considered a problem for fleeing outlaws are treated as non-valid
--- @return integer[] #a list of form indexes
local validForms = function(species, flee_check)
    local valid_forms = {}
    local forms = _DATA:GetMonster(species).Forms
    for i = 0, forms.Count - 1, 1 do
        if forms[i].Released and not forms[i].Temporary then
            local match = false
            if flee_check then
                for _, type in ipairs(library.data.fleeing_outlaw_restrictions) do
                    if type == forms[i].Element1 or type == forms[i].Element2 then
                        match = true
                        break
                    end
                end
            end
            if not match then
                table.insert(valid_forms, i)
            end
        end
    end
    return valid_forms
end

--- Checks if a species-form pair is valid.
--- @param species string the id of the species to check
--- @param form integer the index of the form to check
--- @param flee_check boolean if true, make sure that types considered a problem for fleeing outlaws are treated as non-valid
--- @return boolean #true if the form is valid, false otherwise
local isValidForm = function(species, form, flee_check)
    local formData = _DATA:GetMonster(species).Forms[form]
    if not formData.Released or formData.Temporary then return false end
    if flee_check then
        for _, type in ipairs(library.data.fleeing_outlaw_restrictions) do
            if type == formData.Element1 or type == formData.Element2 then
                return false
            end
        end
    end
    return true
end

--- Generates all ground characters required for the reward cutscene, then passes them to the provided callback.
--- @param jobIndex integer the index of the job to call the reward cutscene for
--- @param callback fun(job:jobTable, chars:any[])
local rewardCutscene = function(jobIndex, callback)
    local job = library.root.taken[jobIndex]

    local npc_count = 1
    local npcs = {}
    local enforcer_mode = globals.job_types[job.Type].law_enforcement
    if enforcer_mode then
        npc_count = 4
    elseif globals.job_types[job.Type].req_target and not globals.job_types[job.Type].target_outlaw then
        npc_count = 2
    end
    local unique_officers = {}
    for i = 1, npc_count, 1 do
        local monsterID
        if i == 1 then
            if enforcer_mode then
                monsterID = library.data.law_enforcement.OFFICER
            else
                monsterID = job.Client
            end
        elseif i == 2 then
            monsterID = job.Target
        elseif i > 2 then
            monsterID = library:WeightedRandomExclude(library.data.law_enforcement.AGENT, unique_officers, false, "") --[[@as AgentIDTable]]
            if monsterID.Unique then
                unique_officers[monsterID] = true
            end
        end
        ---@cast monsterID monsterIDTable
        local ID = library:TableToMonsterID(monsterID)
        local char = RogueEssence.Ground.GroundChar(ID,
            RogueElements.Loc(0, 0),
            Direction.Down, library:GetCharacterName(monsterID, true), "Job_Cutscene_Char_" .. i)
        table.insert(npcs, char)
        char:ReloadEvents()
        GAME:GetCurrentGround():AddTempChar(char)
    end

    callback(job, npcs)

    for _, char in ipairs(npcs) do
        GAME:GetCurrentGround():RemoveTempChar(char)
    end
end

-- ----------------------------------------------------------------------------------------- --
-- #region Getters
-- ----------------------------------------------------------------------------------------- --
-- Quickly get specific data regarding jobs or boards

--- Checks whether or not a job board exists.
--- @param board_id string the board to check
--- @return boolean #true if there are settings data assigned to the given board id, false otherwise
function library:BoardExists(board_id) return self.data.boards[board_id] ~= nil end

--- Checks if a board is empty or not.
--- @param board_id string the id of the board to check
--- @return boolean|nil #true if there are 0 jobs inside the board, false otherwise. Returns nil if the board does not exist
function library:IsBoardEmpty(board_id)
    if self:BoardExists(board_id) then return self:GetBoardCount(board_id) <= 0 end
    logWarn(globals.warn_types.ID, "Board table of id \"" .. board_id .. "\" does not exist. Cannot check fullness.")
end

--- Checks if a board is full or not.
--- @param board_id string the id of the board to check
--- @return boolean|nil #true if there are no more free job slots inside the board, false otherwise. Returns nil if the board does not exist
function library:IsBoardFull(board_id)
    if self:BoardExists(board_id) then return self:GetBoardCount(board_id) >= self:GetBoardSize(board_id) end
    logWarn(globals.warn_types.ID, "Board table of id \"" .. board_id .. "\" does not exist. Cannot check fullness.")
end

--- Retrieves the number of jobs inside a board.
--- @param board_id string the id of the board to check
--- @return integer|nil #The number of jobs in the board. Returns nil if the board does not exist
function library:GetBoardCount(board_id)
    if self:BoardExists(board_id) then return #self.root.boards[board_id] end
    logWarn(globals.warn_types.ID, "Board table of id \"" .. board_id .. "\" does not exist. Cannot check fullness.")
end

--- Retrieves the maximum size of a board.
--- @param board_id string the id of the board to check
--- @return integer|nil #The maximum number of jobs in the board. Returns nil if the board does not exist
function library:GetBoardSize(board_id)
    if self:BoardExists(board_id) then return self.data.boards[board_id].size end
    logWarn(globals.warn_types.ID, "Board table of id \"" .. board_id .. "\" does not exist. Cannot check size.")
end

--- Checks if a board is active by running its condition check. If a board has no check, it will be always active.
--- @param board_id string the id of the board to check
--- @return boolean|nil #true if the board's condition check passes, false otherwise. Returns nil if the board does not exist
function library:IsBoardActive(board_id)
    if self:BoardExists(board_id) then
        if self.data.boards[board_id].condition then return self.data.boards[board_id].condition(self)
        else return true end
    end
    logWarn(globals.warn_types.ID, "Board table of id \"" .. board_id .. "\" does not exist. Cannot check state.")
end

--- Checks if the player's taken job list is empty or not.
--- @return boolean #true if there are 0 jobs inside the taken list, false otherwise.
function library:IsTakenListEmpty() return #self.root.taken <= 0 end

--- Checks if the player's taken job list is full or not.
--- @return boolean #true if there are no more free job slots inside the taken list, false otherwise.
function library:IsTakenListFull() return #self.root.taken >= self:GetTakenSize() end

--- Retrieves the number of jobs inside the taken list.
--- @return integer #The number of jobs taken
function library:GetTakenCount() return #self.root.taken end

--- Retrieves the maximum number of jobs that can be put inside the taken list.
--- @return integer #The maximum number of jobs that can be taken
function library:GetTakenSize() return self.data.taken_limit end

--- Checks if the given board has a job in the requested slot.
--- @param board_id string the id of the board to check
--- @param index integer? The index of the job to check. If omitted, defaults to job 1 of the board.
--- @return boolean|nil #true if the job exists, false otherwise. Returns nil if the board does not exist
function library:BoardJobExists(board_id, index)
    if self:BoardExists(board_id) then return self:GetBoardCount(board_id) >= (index or 1) end
    logWarn(globals.warn_types.ID, "Board table of id \"" .. board_id .. "\" does not exist. Cannot check fullness.")
end

--- Returns a job from a slot in a specific board.
--- @param board_id string the id of the board to check
--- @param index integer? The index of the job to fetch.
--- @return jobTable? #the data table of the job at that position, or nil if there is no job there or the board does not exist.
function library:GetBoardJob(board_id, index)
    if self:BoardExists(board_id) then return self.root.boards[board_id][index] end
    logWarn(globals.warn_types.ID, "Board table of id \"" .. board_id .. "\" does not exist. Cannot get job.")
end

--- Returns a job from a slot in the taken list.
--- @param index integer|nil The index of the job to fetch.
--- @return jobTable #the data table of the job at that position, or nil if there is no job there.
function library:GetTakenJob( index) return self.root.taken[index] end

--- Checks whether or not two jobs have the same destination.
--- @param job1 jobTable a job
--- @param job2 jobTable another job
--- @return boolean #true if the jobs have the same Zone, Segment and Floor, false otherwise
function library:IsJobDestinationEqual(job1, job2)
    if job1.Zone == job2.Zone and job1.Segment == job2.Segment and job1.Floor == job2.Floor then
        return true
    end
    return false
end

--- Checks whether or not a job's destination is already occupied by another job in the taken list.
--- @param job jobTable a job
--- @param check_equal? boolean Optional. If true, it will only return true if the job found is not equal. Defaults to false
--- @return boolean #true if the job has the same Zone, Segment and Floor as another in the taken list, false otherwise
function library:IsJobDestinationInTaken(job, check_equal)
    for _, job2 in ipairs(self.root.taken) do
        if self:IsJobDestinationEqual(job, job2) and (not check_equal or not self:JobsEqual(job, job2)) then return true end
    end
    return false
end

--- Checks if there are completed missions to hand in.
--- @return boolean #true if there are completed missions, false otherwise
function library:HasCompletedMissions()
    return self.root.mission_flags.MissionCompleted --[[@as boolean]] or false
end

--- Checks if the provided species is registered in the game's dex.
--- @param species string a species id
--- @param obtained? boolean if true, it will only return true if the pokémon has been obtained already
--- @return boolean #true if the species is registered, false otherwise
function library:IsSpeciesRegistered(species, obtained)
    if _DATA.Save.Dex:ContainsKey(species) and _DATA.Save.Dex[species] ~= RogueEssence.Data.GameProgress.UnlockState.None then
        return not obtained or _DATA.Save.Dex[species] ~= RogueEssence.Data.GameProgress.UnlockState.Completed
    end
    return false
end

--- Checks if the provided job type requires a target. A job whose jobtype requires a target always has its Target field filled in.
--- @param jobType jobType a job type id string
--- @return boolean #true if the job type requires a target, false otherwise
function library:JobTypeHasTarget(jobType)
    return globals.job_types[jobType].req_target
end

--- Checks if the provided job type requires a target item. A job whose jobtype requires a target item always has its Item field filled in.
--- @param jobType jobType a job type id string
--- @return boolean #true if the job type requires a target item, false otherwise
function library:JobTypeHasTargetItem(jobType)
    return globals.job_types[jobType].req_target_item
end

--- Checks if the provided job type is marked as a guest job. A guest job will have its Client joining the player as a guest.
--- @param jobType jobType a job type id string
--- @return boolean #true if the job type is marked as a guest job, false otherwise
function library:JobTypeHasGuest(jobType)
    return globals.job_types[jobType].has_guest
end

--- Checks if the provided job type is marked as an outlaw job. These job types always have a Target.
--- A job whose jobtype is marked as an outlaw job will require the player to defeat its Target to be completed.
--- @param jobType jobType a job type id string
--- @return boolean #true if the job type is marked as an outlaw job, false otherwise
function library:JobTypeIsOutlaw(jobType)
    return globals.job_types[jobType].target_outlaw
end

--- Checks if the provided job type is marked as a law enforcement job. A job whose jobtype is marked as a law enforcement.
--- job will display the law enforcement characters when processing its job completion cutscene.
--- @param jobType jobType a job type id string
--- @return boolean #true if the job type requires is marked as a law enforcement job, false otherwise
function library:JobTypeIsLawEnforcement(jobType)
    return globals.job_types[jobType].law_enforcement
end

--- Checks if two jobs are equal. It compares location, job type, client and target data to do so.
--- @param j1 jobTable a job
--- @param j2 jobTable another job
--- @return boolean #true if the objects are considered equal, false otherwise
function library:JobsEqual(j1, j2)
    if j1.Zone == j2.Zone and
            j1.Segment == j2.Segment and
            j1.Floor == j2.Floor and
            j1.Type == j2.Type and
            self:CharsEqual(j1.Client, j2.Client) and
            self:CharsEqual(j1.Target, j2.Target) and
            j1.Item == j2.Item then
        return true
    end
    return false
end

--- Checks if two character tables are equal. It also checks for nicknames.
--- @param c1 monsterIDTable a character
--- @param c2 monsterIDTable another character
--- @return boolean #true if the objects are considered equal, false otherwise
function library:CharsEqual(c1, c2)
    if not c1 and not c2 then return true end
    if (c1 and not c2) or (c2 and not c1) then return false end
    if c1.Species == c2.Species and
        c1.Form == c2.Form and
        c1.Skin == c2.Skin and
        c1.Gender == c2.Gender and
        c1.Nickname == c2.Nickname then
        return true
    end
    return false
end

--- Looks for a job inside a specific board, using the same criteria as ``library.JobsEqual``.
--- @param job jobTable the job to look for
--- @param board_id string|nil the table to look in. If nil, it will immediately return -1.
--- @return integer #the index of the job, or -1 if it was not found.
function library:FindJobInBoard(job, board_id)
    if not board_id then return -1 end
    local board = self.root.boards[board_id]

    for i, job2 in ipairs(board) do
        if self:JobsEqual(job, job2) then return i end
    end
    return -1
end

--- Looks for a job inside the taken list, using the same criteria as ``library.JobsEqual``.
--- @param job jobTable the job to look for
--- @return integer #the index of the job, or -1 if it was not found.
function library:FindJobInTaken(job)
    for i, job2 in ipairs(self.root.taken) do
        if self:JobsEqual(job, job2) then return i end
    end
    return -1
end

--- Given a zone id and segment index, return a colored segment name.
--- This is obtained by removing the part containing the string "{0}" and wrapping everything else in orange
--- The string containing "{0}" is then returned separately, with the floor placeholder specifically wrapped in cyan
--- @param zone_id string the id of the zone to generate the string of
--- @param segment_index? number the index of the segment to generate the string of. Defaults to 0.
--- @return string, string #the name of the zone and the string format containing the floor string
function library:GetSegmentName(zone_id, segment_index)
if not segment_index then segment_index = 0 end
    local segment_name = zone_id.." {0}F"
    local segment = _DATA:GetZone(zone_id).Segments[segment_index]

    for step in luanet.each(segment.ZoneSteps) do
        if LUA_ENGINE:TypeOf(step):IsAssignableTo(luanet.ctype(globals.ctypes.FloorNameIDZoneStep)) then
            segment_name = step.Name:ToLocal()
            break
        end
    end

    local split_name = {}
    for str in string.gmatch(segment_name, "([^%s]+)") do
        table.insert(split_name, str)
    end

    local final_name, floor_part = '', ''

    for i = 1, #split_name, 1 do
        local cur_word = split_name[i]

        --save the "floor number" part somewhere else, reconstruct the rest
        local s = string.find(cur_word, '{0}', 1, true)
        if s then
            floor_part = cur_word
            -- assume the string is done if we found the floor part
            break
        else
            if i > 1 then
                final_name = final_name..' '
            end
            final_name = final_name..cur_word
        end
    end

    --Attach color to floor number
    if floor_part ~= "" then
        floor_part = string.gsub(floor_part, '{0}', '[color=#00FFFF]{0}[color]', 1)
    end

    return '[color=#FFC663]'..final_name..'[color]', floor_part
end

--- Given a monsterIDTable, return a colored string.
--- If the monsterIDTable contains a Nickname, it will be used to generate the name, and will always be in cyan.
--- @param char monsterIDTable the character data to generate the string of
--- @param no_color? boolean Optional. If true, the return string will not be colored
--- @return string #the display name of the character
function library:GetCharacterName(char, no_color)
    if char then
        if char.Nickname then
            if no_color then return char.Nickname end
            return '[color=#00FFFF]'..char.Nickname..'[color]'
        elseif char.Species ~= "" then
            if no_color then return _DATA:GetMonster(char.Species).Name:ToLocal() end
            return _DATA:GetMonster(char.Species):GetColoredName()
        end
    end
    local errorCause = " nil"
    if char then errorCause = "n invalid" end
    logError(globals.error_types.DATA, "GetCharacterName was called using a"..errorCause.." monsterIDTable.")
    if no_color then return "???" end
    return "[color=#FF0000]???[color]"
end

--- Given an item id or table, it returns its colored display name.
--- Invalid ids will be displayed in red, without changes.
--- @param item string|itemTable the id of the item to generate the string of
--- @param icon boolean? Optional. If true, the name will also include the item's icon. Defaults to false
--- @return string #the display name of the item
function library:GetItemName(item, icon)
    if type(item) == "string" then item = { id = item, count = 1 } end
    if not _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Item]:ContainsKey(item.id) then
        return STRINGS:Format("[color=#FF0000]{0}[color]", item.id);
    else
        item.count = item.count or 1
        local data = _DATA:GetItem(item.id)
        local itemname
        if icon then itemname = data:GetIconName()
        else itemname = data:GetColoredName() end

        if data.MaxStack > 1 then itemname = itemname.." (" .. item.count .. ")" end
        if data.UsageType == RogueEssence.Data.ItemData.UseType.Treasure then
            return STRINGS:Format("[color=#6384E6]{0}[color]", itemname); --needed to recolor the number
        else
            return STRINGS:Format("[color=#FFCEFF]{0}[color]", itemname);
        end
    end
end

--- Given a job, it returns its objective string.
--- @param job jobTable the job to generate the objective string of
--- @return string #the objective string for the job
function library:GetObjectiveString(job)
    local key, client = globals.keys[job.Type], self:GetCharacterName(job.Client)
    local target, item = "[color=#FF0000]TARGET[color]", "[color=#FF0000]ITEM[color]"
    if job.MenuOverrides and job.MenuOverrides[globals.overrides.OBJECTIVE] then key = job.MenuOverrides[globals.overrides.OBJECTIVE] end
    if job.Target then target = self:GetCharacterName(job.Target) end
    if job.Item and job.Item ~= "" then item = self:GetItemName(job.Item) end
    return STRINGS:FormatKey(key, client, target, item)
end

--- Given a job, it returns its location string, complete with floor if the job doesn't hide it.
--- @param job jobTable the job to generate the location string of
--- @return string #the location string for the job
function library:GetDestinationString(job)
    local zone_string, floor_string = "", ""
    if job.Zone ~= "" and job.Segment>=0 then
        zone_string, floor_string = self:GetSegmentName(job.Zone, job.Segment)
        floor_string = STRINGS:Format(floor_string, tostring(job.Floor))
    else
        logWarn(globals.warn_types.DATA, "Could not generate location string for segment "..tostring(job.Segment).." of "..job.Zone.." because it has no display name")
        zone_string, floor_string = job.Zone.."["..tostring(job.Segment).."]", tostring(job.Floor).."F"
    end
    if job.MenuOverrides and job.MenuOverrides[globals.overrides.PLACE] then
        zone_string = STRINGS:FormatKey(job.MenuOverrides[globals.overrides.PLACE])
    end

    if job.HideFloor then
        return zone_string
    else
        return zone_string .. " " .. floor_string
    end
end

--- Given a job, it returns its difficulty string. It can also include its extra reward.
--- @param job jobTable the job to generate the difficulty string of
--- @param include_extra? boolean if true, the extra reward string is included in the returned string. Defaults to false
--- @return string #the difficulty string for the job
function library:GetDifficultyString(job, include_extra)
    if job.MenuOverrides and job.MenuOverrides[globals.overrides.DIFFICULTY] then
        return STRINGS:FormatKey(job.MenuOverrides[globals.overrides.DIFFICULTY])
    end
    local diff_id = self:NumToDifficulty(job.Difficulty)
    local key = self.data.difficulty_data[diff_id].display_key
    local str = STRINGS:FormatKey(key)
    if include_extra and (self.data.extra_reward_type == "exp" or self.data.extra_reward_type == "rank") then
        local reward_amount = self.data.difficulty_data[self:NumToDifficulty(job.Difficulty)].extra_reward
        if reward_amount>0 then str = str .. STRINGS:Format(" ({0})", reward_amount) end
    end
    return str
end

--- Given a job, it returns its reward string.
--- @param job jobTable the job to generate the reward string of
--- @return string #the reward string for the job
function library:GetRewardString(job)
    local reward1, reward2 = "", "[color=#FF0000]REWARD2[color]"
    if globals.reward_types[job.RewardType][1] then
        reward1 = self:GetItemName(job.Reward1, true)
    elseif job.RewardType ~= "client" then
        local diff_id = self:NumToDifficulty(job.Difficulty)
        local money = self.data.difficulty_data[diff_id].money_reward
        reward1 = STRINGS:FormatKey("MONEY_AMOUNT", money)
    else
        reward1 = self:GetCharacterName(job.Client)
    end
    if globals.reward_types[job.RewardType][2] then
        reward2 = self:GetItemName(job.Reward2)
    end
    local pointer = globals.reward_types[job.RewardType][4]
    local key = globals.keys[pointer]
    if job.MenuOverrides and job.MenuOverrides[globals.overrides.REWARD] then
        key = STRINGS:FormatKey(job.MenuOverrides[globals.overrides.REWARD])
    end
    return STRINGS:FormatKey(key, reward1, reward2)
end

---Checks if there is at least one external event happening in the specified zone.
---@param zone string the zone to run the checks on
---@return boolean #true if any check returns true, false oterwise
function library:HasExternalEvents(zone)
    for _, condition_data in ipairs(self.data.external_events) do
        if condition_data.condition(zone) then return true end
    end
    return false
end

---Checks for all external events and returns a list of all events that returned true.
---@param zone string the zone to run the checks on
---@return {condition:fun(zone:string):(boolean), message_key:string|nil, message_args:fun(zone:string):(string[])|nil, icon:string|nil}[] #a list of all checks whose condition is fulfilled
function library:GetExternalEvents(zone)
    local conditions = {}
    for _, condition_data in ipairs(self.data.external_events) do
        if condition_data.condition(zone) then table.insert(conditions, condition_data) end
    end
    return conditions
end

-- ----------------------------------------------------------------------------------------- --
-- #region Data converters
-- ----------------------------------------------------------------------------------------- --
-- Functions that convert data between C# and lua representation

--- Converts a number to the Gender it represents. Invalid numbers will be marked as Unknown.
--- @param number integer a number from -1 to 2.
--- @return userdata a RogueEssence.Data.Gender object
function library:NumberToGender(number)
    local res = Gender.Unknown
    if number == globals.gender.Genderless then
        res = Gender.Genderless
    elseif number == globals.gender.Male then
        res = Gender.Male
    elseif number == globals.gender.Female then
        res = Gender.Female
    end
    return res
end

--- Converts a Gender object to its number representation.
--- @param gender userdata a RogueEssence.Data.Gender object
--- @return integer a number between -1 and 2
function library:GenderToNumber(gender)
    local res = globals.gender.Unknown
    if gender == Gender.Genderless then
        res = globals.gender.Genderless
    elseif gender == Gender.Male then
        res = globals.gender.Male
    elseif gender == Gender.Female then
        res = globals.gender.Female
    end
    return res
end

--- Fills out a MonsterIDTable's missing properties.
--- Form, String and Gender are optional. If absent, Gender is rolled randomly, while the others will be set to 0 and "normal" respectively.
--- @param table monsterIDTable a table formatted like so: {Species = string, [Form = int], [Skin = string], [Gender = int]}
--- @return monsterIDTable #the same table, but with all required data filled out
function library:NormalizeMonsterIDTable(table)
    table.Form = table.Form or 0
    table.Skin = table.Skin or "normal"
    table.Gender = table.Gender or rollMonsterGender(table.Species, table.Form)
    return table
end

--- Converts a table formatted like a MonsterID object into its c# equivalent.
--- Form, String and Gender are optional. If absent, Gender is rolled randomly, while the others will be set to 0 and "normal" respectively.
--- @param table monsterIDTable a table formatted like so: {Species = string, [Form = int], [Skin = string], [Gender = int]}
--- @return MonsterID a fully formed RogueEssence.Data.MonsterID object
function library:TableToMonsterID(table)
    table.Form = table.Form or 0
    table.Skin = table.Skin or "normal"
    table.Gender = table.Gender or rollMonsterGender(table.Species, table.Form)
    return RogueEssence.Dungeon.MonsterID(table.Species, table.Form, table.Skin, self:NumberToGender(table.Gender))
end

--- Converts a RogueEssence.Data.MonsterID object to a format that is more compatible with lua and the SV table.
--- You can include a nickname property if you so wish.
--- @param monsterId MonsterID a fully formed RogueEssence.Data.MonsterID object
--- @param nickname? string Optional. A nickname to store with the MonsterId data
--- @return monsterIDTable #a table formatted like so: {Nickname = string, Species = string, Form = int, Skin = string, Gender = int}
function library:MonsterIDToTable(monsterId, nickname)
    local table = monsterIdTemplate()
    table.Nickname = nickname
    table.Species = monsterId.Species
    table.Form = monsterId.Form
    table.Skin = monsterId.Skin
    table.Gender = self:GenderToNumber(monsterId.Gender)
    return table
end

--- Converts a difficulty id into a numerical difficulty level.
--- @param diff string the difficulty id
--- @return integer #the difficulty level
function library:DifficultyToNum(diff)
    if diff and self.data.difficulty_to_num[diff] then return self.data.difficulty_to_num[diff] end
    return 1
end

--- Converts a numerical difficulty level into a difficulty id.
--- A difficulty level outside of range will be clamped to bring it back inside the limits.
--- It only returns nil if there are no difficulties defined at all.
--- @param num integer the difficulty level
--- @return string #the difficulty id
function library:NumToDifficulty(num)
    num = math.min(math.max(1,num), #self.data.num_to_difficulty)
    return self.data.num_to_difficulty[num]
end

-- ----------------------------------------------------------------------------------------- --
-- #region Randomization
-- ----------------------------------------------------------------------------------------- --
-- Functions for randomization purposes

--- Returns a randomly chosen element of the given list.
--- Elements must have a "weight" property, otherwise their weight will default to 1.
--- @generic T:table
--- @param list T[] the list of elements to roll.
--- @param replay_sensitive? boolean if true, this function will use a replay-safe rng function. Defaults to false.
--- @return T|nil, number|nil #the element extracted and its index in the list, or nil, nil if the list was empty
function library:WeightedRandom(list, replay_sensitive)
    local entry, index = self:WeightedRandomExclude(list, {}, replay_sensitive)
    return entry, index
end

--- Returns a randomly chosen element of the given list, excluding any key in the exclude table.
--- Elements must have a "weight" property, otherwise their weight will default to 1.
--- @generic T:table
--- @param list T[] the list of elements to roll.
--- @param exclude any[] a table whose keys are the ids of the elements to exclude from the roll, and the value can be anything except "nil" and "false"
--- @param replay_sensitive? boolean if true, this function will use a replay-safe rng function. Defaults to false.
--- @param alt_id? string name of the id property, in case "id" isn't good enough. Use an empty string to require the object itself to be equal instead.
--- @return T|nil, number|nil #the element extracted and its index in the list, or nil, nil if the final list was empty
function library:WeightedRandomExclude(list, exclude, replay_sensitive, alt_id)
    local id = alt_id or "id"
    local weight = 0
    for _, element in ipairs(list) do
        local match = element
        if id ~= "" then match = element[id] end
        if not exclude[match] then
            local elem_weight = element.weight or element.Weight
            if elem_weight
            then weight = weight + elem_weight
            else weight = weight + 1
            end
        end
    end
    if weight <= 0 then return end
    local roll = -1
    if replay_sensitive
    then roll = _DATA.Save.Rand:Next(weight)+1 --this rng getter includes 0 but doesn't include the max value so +1 it is
    else roll = math.random(1, weight)
    end

    weight = 0
    for i, element in ipairs(list) do
        local match = element
        if id ~= "" then match = element[id] end
        if not exclude[match] then
            if element.weight
            then weight = weight + element.weight
            else weight = weight + 1
            end
            if weight >= roll then return element, i end
        end
    end
    return list[#list], #list -- should never hit, but just in case, return last
end

--- Returns a randomly chosen element of the given list.
--- All elements have the same chance of being returned.
--- @generic T:any
--- @param list T[] the list of elements to roll.
--- @param replay_sensitive? boolean if true, this function will use a replay-safe rng function. Defaults to false.
--- @return T|nil, number|nil #the element extracted and its index in the list, or nil, nil if the list was empty
function library:WeightlessRandom(list, replay_sensitive)
    if #list == 0 then return end
    local roll = -1
    if replay_sensitive
    then roll = _DATA.Save.Rand:Next(#list)+1 --this one includes 0 but doesn't include the max value so +1 it is
    else roll = math.random(1, #list)
    end
    return list[roll], roll
end

--- Returns a randomly chosen element of the given list, excluding any key in the exclude table.
--- All elements have the same chance of being returned.
--- @generic T:any
--- @param list T[] the list of elements to roll.
--- @param exclude T[] a table whose keys are the the elements to exclude from the roll, and the value can be anything except "nil" and "false"
--- @param replay_sensitive? boolean if true, this function will use a replay-safe rng function. Defaults to false.
--- @return T|nil, number|nil #the element extracted and its index in the list, or nil, nil if the final list was empty
function library:WeightlessRandomExclude(list, exclude, replay_sensitive)
    local num = 0
    for _, element in pairs(exclude) do
        if not exclude[element] then
            num = num + 1
        end
    end
    if num <= 0 then return nil, nil end
    local roll = -1
    if replay_sensitive
    then roll = math.random(1, num)
    else roll = _DATA.Save.Rand:Next(num)+1 --this rng getter includes 0 but doesn't include the max value so +1 it is
    end

    num = 0
    for i, element in ipairs(list) do
        if not exclude[element] then
            num= num + 1
            if num >= roll then return element, i end
        end
    end
    return list[#list], #list -- should never hit, but just in case, return last
end

-- ----------------------------------------------------------------------------------------- --
-- #region Library Hooks
-- ----------------------------------------------------------------------------------------- --
-- Core library functions, intended to be used in scripts

--- Sorts the taken jobs list.
function library:SortTaken()
    table.sort(self.root.taken, sortJobs)
end

--- Sorts all job boards.
function library:SortBoards()
    for board in pairs(self.root.boards) do self:SortBoard(board) end
end

--- Sorts a specific job board.
--- @param board_id string the id of the board to be sorted
function library:SortBoard(board_id)
    if not self.root.boards[board_id] then
        logWarn(globals.warn_types.ID, "Board table of id \""..board_id.."\" does not exist. Cannot sort")
    else
        table.sort(self.root.boards[board_id], sortJobs)
    end
end

--- Resets all boards and regenerates their contents.
--- Called on day end.
function library:UpdateBoards()
    self:loadDungeonTable()
    self:FlushBoards()
    self:PopulateBoards()
    self:SortBoards()
end

--- Clears all boards. Boards that are not supposed to exist will be deleted.
function library:FlushBoards()
    for board in pairs(self.root.boards) do
        self:FlushBoard(board)
    end
end

--- Fills all empty slots in all boards.
--- This function does not flush boards before it tries to fill them.
function library:PopulateBoards()
    local dest_data = self:CompileDestinationData()
    for board in pairs(self.data.boards) do
        if library:IsBoardActive(board) then
            self:PopulateBoard(board, dest_data)
        end
    end
end

--- Clears the requested board. It will throw an error if the board does not exist.
--- @param board_id string the id of the board to be flushed
function library:FlushBoard(board_id)
    if self.data.boards[board_id] == nil then
        --delete because it shouldn't exist
        self.root.boards[board_id] = nil
    else
        self.root.boards[board_id] = {}
    end
end

--- Checks if the floor requested is occupied by any already generated job.
--- It does so by checking a floors_occupied table, if provided, otherwise it checks the various job tables.
---	@param zone string the zone id
---	@param segment integer the 0-based segment index
---	@param floor integer the 1-based floor number
--- @param floors_occupied? table<string,table<integer,table<integer,boolean>>> the destination map returned by ```library:GetFlorsOccupied()```. If missing, it will be generated on the fly.
--- @return boolean #true if the destination data is present in the occupied map, false otherwise
function library:IsDestinationOccupied(zone, segment, floor, floors_occupied)
    if not floors_occupied then
        for _, job in ipairs(self.root.taken) do
            if self:IsJobDestinationEqual(job, { Zone = zone, Segment = segment, Floor = floor }) then return true end
        end
        for _, board in pairs(self.root.boards) do
            for _, job in ipairs(board) do
                if self:IsJobDestinationEqual(job, { Zone = zone, Segment = segment, Floor = floor }) then return true end
            end
        end
        return false
    end
    if not floors_occupied[zone] or not floors_occupied[zone][segment] or not floors_occupied[zone][segment][floor] then
        return false
    end
    return true
end

--- Returns a multi-layer map of all destinations that have a job associated to them.
--- The resulting data structure must be accessed in the order of zone, segment and then floor.
---@return table<string,table<integer,table<integer,boolean>>> #the destination map.
function library:GetFloorsOccupied()
    local floors_occupied = {}
    for _, job in ipairs(self.root.taken) do
        floors_occupied[job.Zone] = floors_occupied[job.Zone] or {}
        floors_occupied[job.Zone][job.Segment] = floors_occupied[job.Zone][job.Segment] or {}
        floors_occupied[job.Zone][job.Segment][job.Floor] = true
    end
    for _, board in pairs(self.root.boards) do
        for _, job in ipairs(board) do
            floors_occupied[job.Zone] = floors_occupied[job.Zone] or {}
            floors_occupied[job.Zone][job.Segment] = floors_occupied[job.Zone][job.Segment] or {}
            floors_occupied[job.Zone][job.Segment][job.Floor] = true
        end
    end
    return floors_occupied
end

--- Compiles a list of valid destinations in the form of zone ids. This is more of an approximation than a perfect list, as it does not
--- take into account occupied and invalid floors.
--- @return string[] #a list of zone ids.
function library:GetValidZones()
    local zones = {}
    for zone, zone_data in pairs(self.data.dungeons) do
        if self.root.dungeon_progress[zone] ~= nil and not self:HasExternalEvents(zone) then --skip segments that are locked by external conditons
            for segment, segment_data in pairs(zone_data) do
                if self.root.dungeon_progress[zone][segment] ~= nil and
                    (self.root.dungeon_progress[zone][segment] or not segment_data.must_end) then
                    table.insert(zones, zone)
                    break
                end
            end
        end
    end
    return zones
end

--- Checks if a zone has any valid destinations at all. Floors with fixed generation plans are ignored, as well as any floors already taken by another job.
--- You can pass a pre-generated floors_occupied table for greater efficiency in case you need to use it in multiple places.
--- @param zone string the zone to check for
--- @param floors_occupied? table<string,table<integer,table<integer,boolean>>> the destination map returned by ```library:GetFlorsOccupied()```. If missing, it will be generated on the fly.
--- @return boolean #true if the dungeon has even just one valid floor destination, false otherwise.
function library:ZoneHasValidDestinations(zone, floors_occupied)
    if not floors_occupied then
        floors_occupied = self:GetFloorsOccupied()
    end
    local data_zone = _DATA:GetZone(zone)
    local zone_data = self.data.dungeons[zone]
    for segment, segment_data in pairs(zone_data) do
        local zone_segment = data_zone.Segments[segment]
        if self.root.dungeon_progress[zone][segment] ~= nil and
            (self.root.dungeon_progress[zone][segment] or not segment_data.must_end) then
            local sections = segment_data.sections
            for i = sections[1].start, segment_data.max_floor, 1 do
                if i > 0 and i <= zone_segment.FloorCount then
                    if not self:IsDestinationOccupied(zone, segment, i, floors_occupied) then
                        local map_gen = zone_segment:GetMapGen(i - 1)
                        local type = LUA_ENGINE:TypeOf(map_gen)
                        if not (type:IsAssignableTo(luanet.ctype(globals.ctypes.LoadGen)) or type:IsAssignableTo(luanet.ctype(globals.ctypes.ChanceFloorGen))) then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

--- Generates a list of all valid destinations within a zone. It takes into account all segments that have been registered for it in the settings file.
--- Floors with fixed generation plans are ignored, as well as any floors already taken by another job.
--- You can pass a pre-generated floors_occupied table for greater efficiency in case you need  to use it in multiple places.
--- @param zone string the zone to compile the destination list for
--- @param floors_occupied? table<string,table<integer,table<integer,boolean>>> the destination map returned by ```library:GetFlorsOccupied()```. If missing, it will be generated on the fly.
--- @return {segment:integer, floor:integer, difficulty:string}[]
function library:GetValidDestinationsInZone(zone, floors_occupied)
    if not floors_occupied then
        floors_occupied = self:GetFloorsOccupied()
    end
    local data_zone = _DATA:GetZone(zone)
    local dests = {}
    local zone_data = self.data.dungeons[zone]
    for segment, segment_data in pairs(zone_data) do
        local zone_segment = data_zone.Segments[segment]
        if self.root.dungeon_progress[zone][segment] ~= nil and
            (self.root.dungeon_progress[zone][segment] or not segment_data.must_end) then
            local sections = segment_data.sections
            local n, section = 1, sections[1]
            for i = sections[1].start, segment_data.max_floor, 1 do
                if i > 0 and i <= zone_segment.FloorCount then
                    while sections[n + 1] and sections[n + 1].start <= i do n, section = n + 1, sections[n + 1] end
                    if not self:IsDestinationOccupied(zone, segment, i, floors_occupied) then
                        local map_gen = zone_segment:GetMapGen(i - 1)
                        local type = LUA_ENGINE:TypeOf(map_gen)
                        if type:IsAssignableTo(luanet.ctype(globals.ctypes.LoadGen)) or type:IsAssignableTo(luanet.ctype(globals.ctypes.ChanceFloorGen)) then
                            logWarn(globals.warn_types.FLOOR_GEN, "Jobs cannot be generated on " .. zone .. ", " .. segment .. ", " .. i .. " because it is of type \"" .. type.FullName .. "\"")
                        else
                            table.insert(dests, { segment = segment, floor = i, difficulty = section.difficulty })
                        end
                    end
                end
            end
        end
    end
    return dests
end

--- Initializes a destination table by calling ``library:GetValidZones`` and ``library.GetFloorsOccupied``,
--- but leaves the "allowed" table empty for more efficient use later on.
--- @return destTable the table that will be used for destination selection.
function library:CompileDestinationData()
    return {
        destinations = self:GetValidZones(),
        occupied = self:GetFloorsOccupied(),
        allowed = {} --[[@as table<string,{segment:integer, floor:integer, difficulty:string}[]>]]
    }
end

--- Given a destination data list and a list of zone ids, it returns the intersection between the valid zones and the requested ones.
--- If the zone id list is nil, it returns the list of valid zone indices, without filtering.
---@param dest_data destTable List of possible destination zones.
---@param zones string[]|table<string, boolean>|nil List or set of zone ids to filter
---@return {zone:string, index:integer}[] the list of filtered zones, paired with their original dest_data index
function library:FilterDestinationData(dest_data, zones)
    if not dest_data then return {} end
    if zones == nil then zones = dest_data.destinations end
    ---@type table<string, boolean>
    local indexer = {}
    if zones[1] == nil then -- assume it's already a set if integer indexing doesn't work
        --- @cast zones table<string, boolean>
        indexer = zones
    else
        --- @cast zones string[]
        for _, zone in ipairs(zones) do indexer[zone] = true end
    end
    local filtered = {}
    for i, zone_id in ipairs(dest_data.destinations) do
        if indexer[zone_id] then
            table.insert(filtered, {zone = zone_id, index = i})
        end
    end
    return filtered
end

--- Counts how many jobs with guests have been generated for each dungeon.
--- It counts jobs in the taken list and in all boards.
--- @return table<string,integer> #a table whose keys are zone ids and whose values are the number of guest jobs present in that dungeon
function library:GetDungeonsGuestCount()
    local guest_count = {}
    for _, job in ipairs(self.root.taken) do
        if globals.job_types[job.Type].has_guest then
            guest_count[job.Zone] = guest_count[job.Zone] or 0
            guest_count[job.Zone] = guest_count[job.Zone] +1
        end
    end
    for _, board in pairs(self.root.boards) do
        for _, job in ipairs(board) do
            --taken jobs are gonna be in the taken list above already, so they shouldn't be counted again
            if not job.Taken and globals.job_types[job.Type].has_guest then
                guest_count[job.Zone] = guest_count[job.Zone] or 0
                guest_count[job.Zone] = guest_count[job.Zone] +1
            end
        end
    end
    return guest_count
end

--- Tries to fill up as many empty slots as possible in the given board. It will keep going from wherever the board was at when this function was called.
--- It is recommended to flush the board beforehand to ensure it is actually generating new jobs.
--- @param board_id string the id of the board to generate jobs for
--- @param dest_data destTable List of possible destination zones. It also gets updated in-place for coherent and quick reuse. If absent, it will be generated in-place.
function library:PopulateBoard(board_id, dest_data)
    local data = self.data.boards[board_id]
    if not data then
        logError(globals.error_types.ID, "Board with id \"" .. board_id .. "\" does not exist. Cannot generate quests.")
        return
    end
    self.root.boards[board_id] = self.root.boards[board_id] or {}
    if not dest_data then dest_data = self:CompileDestinationData() end
    local filtered_destinations = library:FilterDestinationData(dest_data, self.data.boards[board_id].dungeons)
    local guest_count = self:GetDungeonsGuestCount()

    while (self:GetBoardCount(board_id) < self:GetBoardSize(board_id)) do

        -- choose destination
        if #filtered_destinations <= 0 then break end
        local zone_struct, struct_index = self:WeightlessRandom(filtered_destinations)
        ---@cast zone_struct {zone:string, index:integer} because we already checked there is at least 1 possible result
        local zone = zone_struct.zone

        if not dest_data.allowed[zone] then dest_data.allowed[zone] = self:GetValidDestinationsInZone(zone, dest_data.occupied) end
        if #dest_data.allowed[zone] <= 0 then
            --clean up and try again if there are no valid destinations in this dungeon
            dest_data.allowed[zone] = nil
            table.remove(dest_data.destinations, zone_struct.index)
            table.remove(filtered_destinations, struct_index)
            for _, struct in ipairs(filtered_destinations) do
                if struct.index > zone_struct.index then struct.index = struct.index - 1 end
            end
        else
            local dest2, dest2_index = self:WeightlessRandom(dest_data.allowed[zone])
            ---@cast dest2 {segment:integer, floor:integer, difficulty:string} because we already checked there is at least 1 possible result
            local segment, floor = dest2.segment, dest2.floor
            local difficulty = self:DifficultyToNum(dest2.difficulty)

            -- choose job type and finalize difficulty adjustments
            local possible_job_types = {}
            for i = #self.data.boards[board_id].job_types, 1, -1 do
                local job_type_entry = self.data.boards[board_id].job_types[i]
                local job_type_properties = self.data.job_types[job_type_entry.id]
                if not globals.job_types[job_type_entry.id] then
                    logError(globals.error_types.DATA, "\"" .. job_type_entry.id .. "\" in job board \"" .. board_id .. "\" is not a valid job type and will be ignored.")
                    table.remove(self.data.boards[board_id].job_types, i)
                elseif not job_type_properties then
                    logError(globals.error_types.DATA, "\"" .. job_type_entry.id .. "\" in job board \"" .. board_id .. "\" has no settings associated to it and will be ignored.")
                    table.remove(self.data.boards[board_id].job_types, i)
                else
                    local min_rank = job_type_properties.min_rank
                    local min_difficulty
                    if min_rank then
                        min_difficulty = self:DifficultyToNum(min_rank)
                    else
                        min_difficulty = 0
                    end
                    min_difficulty = min_difficulty - (job_type_properties.rank_modifier or 0)
                    local add = true
                    if min_difficulty > difficulty then add = false end
                    if globals.job_types[job_type_entry.id].has_guest and guest_count[zone] and guest_count[zone] >= self.data.max_guests then
                        add = false
                    end
                    if add then
                        local final_entry = { id = job_type_entry.id, weight = job_type_entry.weight }
                        if self.data.dungeon_job_modifiers[zone] and self.data.dungeon_job_modifiers[zone][job_type_entry.id] then
                            final_entry.weight = math.ceil(final_entry.weight * self.data.dungeon_job_modifiers[zone][job_type_entry.id])
                        end
                        if final_entry.weight > 0 then
                            table.insert(possible_job_types, final_entry)
                        end
                    end
                end
            end
            if #possible_job_types <= 0 then
                --weed out any floor where no jobs can spawn EVER because of the difficulty constraints.
                for i, elem in ipairs(dest_data.allowed[zone]) do
                    if self:DifficultyToNum(elem.difficulty) <= difficulty then
                        table.remove(dest_data.allowed[zone], i)
                    end
                end
                if #dest_data.allowed[zone] <= 0 then
                    --clean up if empty, then try again
                    dest_data.allowed[zone] = nil
                    table.remove(dest_data.destinations, zone_struct.index)
                    table.remove(filtered_destinations, struct_index)
                    for _, struct in ipairs(filtered_destinations) do
                        if struct.index > zone_struct.index then struct.index = struct.index - 1 end
                    end
                end
            else
                local job_type = self:WeightedRandom(possible_job_types).id --[[@as string]] --it is safe because we already checked there is at least 1 possible result
                local newJob = self:MakeNewJob(zone, segment, floor, job_type)
                if not newJob then return end --abort if failed
                self:AddJobToBoard(board_id, newJob)
                if globals.job_types[newJob.Type].has_guest then guest_count[zone] = (guest_count[zone] or 0)+1 end
                dest_data.occupied[zone] = dest_data.occupied[zone] or {}
                dest_data.occupied[zone][segment] = dest_data.occupied[zone][segment] or {}
                dest_data.occupied[zone][segment][floor] = true
                table.remove(dest_data.allowed[zone], dest2_index)
                if #dest_data.allowed[zone] <= 0 then
                    -- clean up if this dungeon is full
                    dest_data.allowed[zone] = nil
                    table.remove(dest_data.destinations, zone_struct.index)
                    table.remove(filtered_destinations, struct_index)
                    for _, struct in ipairs(filtered_destinations) do
                        if struct.index > zone_struct.index then struct.index = struct.index - 1 end
                    end
                end
            end
        end
    end
end

--- Checks if the given job's type requires a target item. If that's the case, it rolls a target item and stores it in the job's table.
---@param job jobTable the job to give a target item to
local rollTargetItem = function(job)
    if globals.job_types[job.Type].req_target_item then
        if library.data.target_items[job.Type] and #library.data.target_items[job.Type] > 0 then
            job.Item = library:WeightlessRandom(library.data.target_items[job.Type])
        else
            logError(globals.error_types.DATA, "No target items associated to job type \"" .. job.Type .. "\". Setting target to \"" .. globals.defaults.item .. "\"")
            job.Item = globals.defaults.item
        end
    end
end

--- Checks if the given job's type is allowed to hide its target floor. If that's the case, it decides whether or not to do so and stores the result of the roll in the job's table.
---@param job jobTable the job to decide whether or not to hide the floor of
local rollHiddenFloor = function(job)
    if globals.job_types[job.Type].can_hide_floor then
        if math.random() < library.data.hidden_floor_chance then job.HideFloor = true end
    end
end

--- Checks if the given job's type has one or more special cases assigend to it. If that's the case, it decides whether or not to select one and then rolls on the available special case list.
--- Finally, it stores the resulting special type in the job's table.
---@param job jobTable the job to give a special type to
local rollSpecial = function(job)
    if library.data.special_jobs[job.Type] and #library.data.special_jobs[job.Type]>0 then
        if math.random() < library.data.special_chance then
            job.Special = library:WeightlessRandom(library.data.special_jobs[job.Type])
        end
    end
end

--- Rolls the characters involved in the job, and normalizes their monsterid tables. It always chooses a client, but only selects a target if the job type requires it.
--- Law enforcement job types will always have an enforcer character as their client.
--- If the job has a special case assigned, this function will roll one of the scenarios assigned to it and store client, target and target item in the job's table,
--- ignoring the default values provided.
--- The values calculated ny this function are stored in the job's table.
--- @param job jobTable the job to assign characters to
--- @param client? string|monsterIDTable Optional default client
--- @param target? string|monsterIDTable Optional default target
local rollCharacters = function(job, client, target)
    ---@type (string|monsterIDTable)[]
    local characters = {}
    local difficulty_id = library:NumToDifficulty(job.Difficulty)
    local tier = library:WeightedRandom(library.data.difficulty_to_tier[difficulty_id]).id

    if job.Special and job.Special ~= "" then
        local special_data = library:WeightlessRandom(library.data.special_data[job.Special--[[@as string]]][tier])
        if special_data then
            if not job.Client or not job.Target then
                characters[1] = special_data.client
                characters[2] = special_data.target
            end
            if special_data.item then job.Item = special_data.item end --overwrite
            job.Flavor[1] = special_data.flavor
        end
    end

    characters = {
        characters[1] or client,
        characters[2] or target,
    }

    if not (characters[1] and characters[2]) then
        local flee_check = job.Type == "OUTLAW_FLEE"
        local pool = library.data.pokemon[tier]

        --roll on the extracted pool
        local slots = { "client", "target" }
        for i = 1, 2, 1 do
            if i == 2 and not globals.job_types[job.Type].req_target then break end
            while not characters[i] do
                if i == 1 and globals.job_types[job.Type].law_enforcement then
                    characters[i] = globals.keywords.ENFORCER
                else
                    local result, res_index = library:WeightlessRandom(pool)
                    if type(result) == "table" then
                        if isValidForm(result.Species, result.Form, flee_check) then
                            characters[i] = result
                        else
                            table.remove(pool, res_index)
                        end
                    elseif result then
                        ---@cast result string
                        if #validForms(result, flee_check) > 0 then
                            characters[i] = {
                                Species = result,
                                Form = library:WeightlessRandom(validForms(result, flee_check)) or 0
                            } --[[@as monsterIDTable]]
                        else
                            table.remove(pool, res_index)
                        end
                    else
                        error("[" .. globals.error_types.DATA .. "] Could not select pokémon for tier \"" .. tier .. "\", job type \"" .. job.Type .. "\"")
                    end
                end
            end
        end
        for i = 1, 2, 1 do
            --at the end of the last process we either filled all that needed to be filled, or we errored out
            if characters[i] then
                -- parse law enforcement keywords
                if characters[i] == globals.keywords.ENFORCER then
                    local roll = library:WeightedRandom(library.data.enforcer_chance[tier])
                    if not roll then
                        error("[" .. globals.error_types.DATA .. "] Setting \"enforcer_chance\" has no possible value for tier \"" .. tier .. "\"")
                        break
                    end
                    if roll.id == globals.keywords.OFFICER then
                        characters[i] = library.data.law_enforcement.OFFICER --[[@as monsterIDTable]]
                    elseif roll.id == globals.keywords.AGENT and roll.index and roll.index > 0 and roll.index <= #library.data.law_enforcement.AGENT then
                        characters[i] = library.data.law_enforcement.AGENT[roll.index] --[[@as monsterIDTable]]
                    else
                        characters[i] = roll.id
                    end
                end
                if characters[i] == globals.keywords.AGENT then
                    characters[i] = library:WeightedRandom(library.data.law_enforcement.AGENT) --[[@as monsterIDTable]]
                end
                ---@cast characters monsterIDTable[]
                --finalize tables
                if type(characters[i]) ~= "table" then
                    error("[" .. globals.error_types.DATA .. "] Could not generate job " .. slots[i] .. ". Its final value was: " .. tostring(characters[i]))
                end
            end
        end
    end
    ---@cast characters monsterIDTable[]
    job.Client = library:NormalizeMonsterIDTable(characters[1])
    if globals.job_types[job.Type].req_target then job.Target = library:NormalizeMonsterIDTable(characters[2]) end
end

--- Rolls reward types and items for the given job. If a reward type is provided, it wll be used directly, and any reward list will be ignored.
--- If a reward item list is provided but not a reward type, the reward type will be inferred using the list.
--- The values calculated by this function are stored in the job's table.
--- @param job jobTable the job to assign reward data to
--- @param type? rewardType Optional default reward type
--- @param items? {[1]:string|itemTable, [2]:string|itemTable} Optional reward items list. Ignored if type is set
local setupRewards = function(job, type, items)
    local xcl = false
    if type then
        job.RewardType = type
        items = {}
    elseif items then --and not type
        local combo = 0
        if items[1] then combo = combo + 1 end
        if items[2] then combo = combo + 2 end
        if combo == 0 then
            job.RewardType = "money"
        elseif combo == 1 then
            xcl = _DATA:GetItem(items[1].id).UsageType == RogueEssence.Data.ItemData.UseType.Treasure
            if xcl then
                job.RewardType = "exclusive"
            else
                job.RewardType = "item"
            end
        elseif combo == 2 then
            job.RewardType = "money_item"
        elseif combo == 3 then
            job.RewardType = "item_item"
        end
    else
        local reward_type
        local possible_reward_types = {}
        for i = #library.data.reward_types, 1, -1 do
            local reward_type_entry = library.data.reward_types[i]
            if not globals.reward_types[reward_type_entry.id] then
                logError(globals.error_types.DATA, "\"" .. reward_type_entry.id .. "\" is not a valid reward type and will be ignored.")
                table.remove(globals.reward_types, i)
            elseif not reward_type_entry.min_rank or job.Difficulty >= library:DifficultyToNum(reward_type_entry.min_rank)
                and (not library:JobTypeIsLawEnforcement(job.Type) or reward_type_entry.id ~= "client")
                and ((reward_type_entry.id ~= "client" and reward_type_entry.id ~= "exclusive") or library:IsSpeciesRegistered(job.Client.Species)) then
                table.insert(possible_reward_types, reward_type_entry)
            end
        end
        if #possible_reward_types <= 0 then
            logError(globals.error_types.DATA, "No possible reward types for quest difficulty \"" .. library:NumToDifficulty(job.Difficulty) .. "\". Setting to \"money\"")
            reward_type = "money"
        else
            reward_type = library:WeightedRandom(possible_reward_types).id --[[@as string]] --it is safe because we already checked there is at least 1 possible result
        end
        job.RewardType = reward_type
        items = {}
    end

    --type has been set up. fill in item slots
    local difficulty_id = library:NumToDifficulty(job.Difficulty)
    for i = 1, 2, 1 do
        if globals.reward_types[job.RewardType][i] then
            if globals.reward_types[job.RewardType][3] and not xcl then         -- if reward type specifies exclusive and it's not set yet
                local rarityData = _DATA.UniversalData:Get(luanet.ctype(globals.ctypes.RarityData))
                local possibleItems = {}
                local species = job.Client.Species
                if globals.job_types[job.Type].law_enforcement then
                    species = job.Target.Species
                end
                if rarityData.RarityMap:ContainsKey(species) then
                    local rarityTable = rarityData.RarityMap[species]
                    if rarityTable:ContainsKey(1) then
                        for item_id in luanet.each(rarityTable[1]) do
                            if _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Item]:Get(item_id).Released then
                                table.insert(possibleItems, item_id)
                            end
                        end
                    end
                    if #possibleItems > 0 then
                        items[i] = {id = library:WeightlessRandom(possibleItems) --[[@as string]]}
                    end
                else
                    if i == 1 then
                        job.RewardType = "item"
                    else
                        job.RewardType = "money_item"
                    end
                end
            end
            if not items[i] then
                if not library.data.rewards_per_difficulty or #library.data.rewards_per_difficulty[difficulty_id] <= 0 then
                    logError(globals.error_types.DATA, "No possible rewards for quest difficulty \"" .. difficulty_id .. "\". Setting to \"" .. globals.defaults.item .. "\"")
                    if i == 1 then
                        job.RewardType = "item"
                    else
                        job.RewardType = "money_item"
                    end
                    items[i] = { id = globals.defaults.item }
                else
                    -- redundant path check
                    local checked = {}
                    ---@type table|nil
                    local result = {}
                    local pool = library:WeightedRandom(library.data.rewards_per_difficulty[difficulty_id]).id
                    repeat
                        if not pool or not library.data.reward_pools[pool] or #library.data.reward_pools[pool] <= 0 then
                            if not pool then
                                logError(globals.error_types.DATA, "No reward pools defined for quest difficulty \"" .. difficulty_id .. "\". Setting reward type to \"money\"")
                            else
                                logError(globals.error_types.DATA, "Reward pool \"" .. pool .. "\" does not exist. Setting reward type to \"money\"")
                            end
                            job.RewardType = "money"
                            result = nil
                            break
                        else
                            checked[pool] = true
                            result = library:WeightedRandomExclude(library.data.reward_pools[pool], checked)
                            if result then
                                pool = result.id
                            else
                                result = nil
                            end
                        end
                    until not library.data.reward_pools[pool]
                    if result then
                        items[i] = result
                    end -- no else because it would only happen if the loop fails, but in that case it would already be set
                end
            end
        end
    end
    if globals.reward_types[job.RewardType][1] then job.Reward1 = { id = items[1].id, count = items[1].count, hidden = items[1].hidden } end
    if globals.reward_types[job.RewardType][2] then job.Reward2 = { id = items[2].id, count = items[2].count, hidden = items[2].hidden } end
end

--- Rolls flavor data for the given job and stores the result of the roll in the job's table.
--- @param job jobTable the job to store flevor data in
local rollFlavor = function(job)
    if job.Flavor[1] == "" then
        for i = 1, 2, 1 do
            job.Flavor[i] = library:WeightlessRandom(library.data.job_flavor[job.Type][i])
        end
    end
    if not job.Flavor[1] then
        logError(globals.error_types.DATA, "No possible flavor text for job type \"" .. job.Type .. "\"")
        job.Flavor = { "", "" }
    end
end

--- Rolls a title for the given job and stores the result of the roll in the job's table.
--- @param job jobTable the job to assign the title to
local rollTitle = function(job)
    local title_group = job.Type
    if job.Special and job.Special ~= "" then
        title_group = job.Special
    end
    local title = library:WeightlessRandom(library.data.job_titles[title_group])
    if not title then
        logError(globals.error_types.DATA, "No possible titles for quest category \"" .. title_group .. "\"")
    end
    job.Title = title or ""
end

--- Generates a new job with the specified data. Location and job type are mandatory. Any other missing parameter will be generated randomly.
--- @param zone string the id of the zone this job should take place in
--- @param segment integer the index of the segment this job should take place in
--- @param floor integer the floor this job should take place in, counting from 1
--- @param job_type jobType the id of the job type to assign to this job
--- @param client? string|monsterIDTable data that will be used for the client of this job
--- @param target? string|monsterIDTable data that will be used for the target of this job. Only used if the job type requires a target
--- @param target_item? string the id of the item that will be used as target. Only used if the job type requires an item
--- @param reward_type? rewardType the combination of rewards that will be awarded for this job. If not set but rewards is, it will be inferred from the items used
--- @param rewards? {[1]:string|itemTable, [2]:string|itemTable} the item rewards that will be awarded for this job. If not set but reward_type is, they will be generated automatically. If the first item is nil, it will award money in its place.
--- @param title? string the title string key to use for this job. If not set, it will be chosen randomly.
--- @param flavor? string[] the flavor string key or keys to use for this job. If not set, they will be chosen randomly.
--- @param hide_floor? boolean if true, the job's floor will be hidden.
--- @return jobTable? #the new job, or nil if the job generation failed
function library:MakeNewJob(zone, segment, floor, job_type, client, target, target_item, reward_type, rewards, title, flavor, hide_floor)
    local newJob = jobTemplate()
    newJob.Zone = zone
    newJob.Segment = segment
    newJob.Floor = floor
    newJob.Type = job_type
    local sections = self.data.dungeons[newJob.Zone][newJob.Segment]
    for _, section in ipairs(sections.sections) do
        if section.start > newJob.Floor then break end
        newJob.Difficulty = self:DifficultyToNum(section.difficulty)
    end
    if newJob.Difficulty < 0 then
        newJob.Difficulty = self:DifficultyToNum(sections.sections[1].difficulty) - math.ceil((sections.sections[1].start - floor) // 3)
    end
    --calc difficulty
    if self.data.job_types[newJob.Type].rank_modifier then
        newJob.Difficulty = newJob.Difficulty + self.data.job_types[newJob.Type].rank_modifier
    end
    --calc target item
    if target_item then newJob.Item = target_item
    else rollTargetItem(newJob) end
    --set hidden_floor depending on chance
    if hide_floor ~= nil then newJob.HideFloor = not not hide_floor
    else rollHiddenFloor(newJob) end

    if not client or (globals.job_types[job_type].req_target and not target) then rollSpecial(newJob) end

    local status, err = pcall(rollCharacters, newJob, client, target)
    if not status then
        PrintInfo(err)
        return
    end

    setupRewards(newJob, reward_type, rewards)

    if flavor then newJob.Flavor = flavor
    else rollFlavor(newJob) end

    if title then newJob.Title = title
    else rollTitle(newJob) end

    return newJob
end

--- Sets the floor as hidden or unhidden. Convenience function to avoid writing nil 15 times.
--- @param job jobTable the job to be edited
--- @param state? boolean what new state to set. If omitted, toggles the current state
function library:SetFloorHidden(job, state)
    if state == nil then state = not job.HideFloor end
    job.HideFloor = state
end

--- Sets a localization key that will override the given data in menus
--- @param job jobTable the job to add the override to
--- @param data_id string the data to override to set
--- @param string_key string the localization key to set
function library:SetMenuOverride(job, data_id, string_key)
    job.MenuOverrides = job.MenuOverrides or {}
    job.MenuOverrides[data_id] = string_key
end

--- Sets a localization key that will override the client string
--- @param job jobTable the job to add the override to
--- @param string_key string the localization key to set
function library:SetClientOverride(job, string_key)
    self:SetMenuOverride(job, globals.overrides.CLIENT, string_key)
end

--- Sets a localization key that will override the objective string
--- Localization placeholders:
--- {0} = Client, {1} = Target, {2} = Item
--- @param job jobTable the job to add the override to
--- @param string_key string the localization key to set
function library:SetObjectiveOverride(job, string_key)
    self:SetMenuOverride(job, globals.overrides.OBJECTIVE, string_key)
end

--- Sets a localization key that will override the dungeon string (not affecting the floor)
--- @param job jobTable the job to add the override to
--- @param string_key string the localization key to set
function library:SetDungeonOverride(job, string_key)
    self:SetMenuOverride(job, globals.overrides.PLACE, string_key)
end

--- Sets a localization key that will override the difficulty string
--- @param job jobTable the job to add the override to
--- @param string_key string the localization key to set
function library:SetDifficultyOverride(job, string_key)
    self:SetMenuOverride(job, globals.overrides.DIFFICULTY, string_key)
end

--- Sets a localization key that will override the reward string
--- Localization placeholders:
--- {0} = Reward1 (or Client), {1} = Reward2
--- @param job jobTable the job to add the override to
--- @param string_key string the localization key to set
function library:SetRewardOverride(job, string_key)
    self:SetMenuOverride(job, globals.overrides.REWARD, string_key)
end

--- Adds a job to a specific board, updating its BackReference in the process. This function ignores board limits, and fails if the board does not exists.
--- @param board_id string a board's string id
--- @param job jobTable the job to add to the board
--- @return boolean #true if the job was added correctly, false otherwise
function library:AddJobToBoard(board_id, job)
    if self:BoardExists(board_id) then
        self:SetBackReference(job, board_id)
        table.insert(self.root.boards[board_id], job)
        return true
    end
    logError(globals.error_types.ID, "Board with id \"" .. board_id .. "\" does not exist. Cannot add jobs to it.")
    return false
end

--- Sets a job's BackReference property to the given board id. Fails if the board does not exists.
--- @param job jobTable the job to add a BackReference to
--- @param board_id string the id of the board to link this job to
--- @return boolean #true if the BackReference was added correctly, false otherwise
function library:SetBackReference(job, board_id)
    if self:BoardExists(board_id) then
        job.BackReference = board_id
        return true
    end
    logError(globals.error_types.ID, "Board with id \"" .. board_id .. "\" does not exist. Cannot set BackReference.")
    return false
end

--- Runs the script responsible for interacting with a quest board.
--- It will first display a menu where players can choose to check either the board or the taken list.
--- @param board_id string the id of the board to interact with
function library:BoardInteract(board_id)
    if not self:BoardExists(board_id) then
        logError(globals.error_types.ID, "Board with id \"" .. board_id .. "\" does not exist. Cannot interact.")
        return
    end
    local choice = 1
    while choice > 0 do
        local job_selected = 1
        choice = menus.BoardSelection.run(self, board_id, choice)
        if choice == 1 then
            self:OpenBoardMenu(board_id, job_selected)
        elseif choice == 2 then
            self:OpenTakenMenu(job_selected)
        end
    end
end

--- Runs the script responsible for handling a specific board's BoardMenu.
--- @param board_id string the id of the board to interact with
--- @param default? integer the job that will be selected when first opening the menu. Defaults to 1.
function library:OpenBoardMenu(board_id, default)
    if not self:BoardExists(board_id) then
        logError(globals.error_types.ID, "Board with id \"" .. board_id .. "\" does not exist. Cannot interact.")
        return
    end
    local job_selected = default or 1
    --exit board menu if the board is empty
    while not self:IsBoardEmpty(board_id) do
        job_selected = menus.Board.run(self, board_id, job_selected)
        if job_selected > 0 then
            local action = menus.Job.run(self, board_id, job_selected)
            if action == 1 then
                self:TakeJob(board_id, job_selected)
            end
        else
            break
        end
    end
end

--- Runs the script responsible for handling the taken list's BoardMenu.
--- @param default? integer the job that will be selected when first opening the menu. Defaults to 1.
function library:OpenTakenMenu(default)
    local job_selected = default or 1
    --exit board menu if the taken list is empty
    while not self:IsTakenListEmpty() do
        job_selected = menus.Board.run(self, nil, job_selected)
        if job_selected > 0 then
            local action = menus.Job.run(self, nil, job_selected)
            if action == 1 then
                self:ToggleTakenJob(job_selected)
            elseif action == 2 then
                self:RemoveTakenJob(job_selected)
            end
        else
            break
        end
    end
end

--- Runs the callback script responsible for interacting with the taken list.
--- This function starts a coroutine as a way to mantain callback behavior consistecy.
--- When closing the taken menu, only the MainMenu will be reopened.
function library:OpenTakenMenuFromMain()
    _MENU:ClearMenus()
    TASK:StartScriptLocalCoroutine(function()
        self:OpenTakenMenu(1)
        TASK:WaitTask(LUA_ENGINE:OnMenuButtonPressed())
    end)
end

--- Runs the script responsible for displaying one specific job.
--- This function does not check if the job exists. Please call library:BoardJobExists before this.
--- @param board_id string the id of the board to interact with
--- @param index integer? The index of the job to show. If omitted, defaults to 1.
--- @return boolean #true if the job was taken, false otherwise
function library:ShowSingularJob(board_id, index)
    index = index or 1
    if not self:BoardExists(board_id) then
        logError(globals.error_types.ID, "Board with id \"" .. board_id .. "\" does not exist. Cannot interact.")
        return false
    end
    if self:GetBoardCount(board_id) < index then
        logError(globals.error_types.ID, "Board with id \"" .. board_id .. "\" does not contain " .. index .. " jobs.")
        return false
    end
    local action = menus.Job.run(self, board_id, index)
    if action == 1 then
        self:TakeJob(board_id, index)
        return true
    end
    return false
end

--- Runs the callback script responsible for displaying the list of current objectives.
--- This function only works if used while already inside a menu handling routine.
function library:OpenObjectivesMenu()
    menus.Objectives.add(self)
end

--- Marks the job as taken and adds a copy of it to the taken board.
--- The copy will have its BackReference set to board_id.
--- @param board_id string the id of the board the job is in
--- @param index integer? The index of the job to take. Defaults to 1
function library:TakeJob(board_id, index)
    index = index or 1
    if not self:BoardExists(board_id) then
        logError(globals.error_types.ID, "Board with id \"" .. board_id .. "\" does not exist. Cannot take.")
        return false
    end
    if self:GetBoardCount(board_id) < index then
        logError(globals.error_types.ID, "Board with id \"" .. board_id .. "\" does not contain " .. index .. " jobs.")
        return false
    end
    local job = self.root.boards[board_id][index]
    local taken = shallowCopy(job)
    local evt = callEvent(taken, "JobTake", {board = board_id})
    if evt.cancel then return end
    job.Taken = true
    taken.BackReference = board_id
    self:AddJobToTaken(taken, self.data.taken_jobs_start_active and not self:IsJobDestinationInTaken(job))


end

--- Adds a new job to the taken list. Then orders the list. This function does not trigger the JobTake event.
--- @param job jobTable the job to add
--- @param startActive? boolean Optional. If true, the job will be set to active automatically. Defaults to false.
function library:AddJobToTaken(job, startActive)
    job.Taken = startActive or false
    table.insert(self.root.taken, job)
    self:SortTaken()
end

--- Removes a job from the taken list.
--- The original job, if it still exists, will be marked as not Taken.
--- @param index integer The index of the job to delete
function library:RemoveTakenJob(index)
    if #self.root.taken < index then
        logError(globals.error_types.ID, "Taken list does not contain " .. index .. " jobs. Cannot remove.")
        return false
    end
    local job = self.root.taken[index]
    local bRefIndex = self:FindJobInBoard(job, job.BackReference)
    if bRefIndex > 0 then
        self.root.boards[job.BackReference][bRefIndex].Taken = false
    end
    table.remove(self.root.taken, index)
    -- no need to sort here because they are guaranteed to be in order thanks to sorting every time a job is taken
end

--- Changes a taken job's active status. This function can trigger the ``JobDeactivate`` and``JobActivate`` events depending on the job's state.
--- @param index integer The index of the job to toggle
function library:ToggleTakenJob(index)
    if #self.root.taken < index then
        logError(globals.error_types.ID, "Taken list does not contain " .. index .. " jobs. Cannot toggle state.")
        return false
    end
    local job = self.root.taken[index]
    local evt
    if self.root.taken[index].Taken then
        evt = callEvent(job, "JobDeactivate")
    else
        evt = callEvent(job, "JobActivate")
    end
    if evt.cancel then return end
    self.root.taken[index].Taken = not self.root.taken[index].Taken
end

--- Marks a job as completed and activates the flag required for the job completion cutscene to run. This function triggers the ``JobComplete`` event.
--- @param job jobTable The job being completed
function library:MarkJobCompleted(job)
    local evt = callEvent(job, "JobComplete")
    if evt.cancel then return end
    job.Completion = globals.completion.Completed
    if RogueEssence.GameManager.Instance.CurrentScene == RogueEssence.Dungeon.DungeonScene.Instance then
        self.root.mission_flags.MissionCompleted = true
    end
end

--- Marks a job as failed. This function triggers the ``JobFail`` event.
--- @param job jobTable The job being failed
function library:MarkJobFailed(job)
    local evt = callEvent(job, "JobFail")
    if evt.cancel then return end
    job.Completion = globals.completion.Failed
end

--- Registers a new callback inside a job's callback table.
---@param job jobTable the job to register the callback in
---@param event eventId the id of the event to subscribe to
---@param func string the name of the callback function. It must be stored inside the table set inside the ``mission_callback_root`` setting
---@param args? table the table of arguments to pass to this instance of the callback. Defaults to ``{}``
function library:RegisterCallback(job, event, func, args)
    job.Callbacks[event] = {name = func, args = args or {}}
end

-- ----------------------------------------------------------------------------------------- --
-- #region General support
-- ----------------------------------------------------------------------------------------- --
-- Situational support functions normally called by events. Differently from the MISC functions, these functions are not private

--- Dynamically builds a boss moveset and assigns it to a character.
--- The character's level should be assigned before running this script. Reduce the level afterwards if you want to be illegal about it.
--- The character is always allowed to have as many level-up moves as it can learn at its level. The number of other move types is arbitrary.
---@param chara any the Character to build.
---@param tm_allowed integer the maximum number of tm moves that the character is allowed to have. Defaults to 0
---@param tutor_allowed integer the maximum number of tutor moves that the character is allowed to have. Defaults to 0
---@param egg_allowed integer the maximum number of egg moves that the character is allowed to have. Defaults to 0
---@param blacklist referenceSet list of move ids that must never be included in a moveset generated by this function
---@return slotType[] #the list of slot types chosen, in the order they were applied. Slot types are "stab", "coverage", "damage" and "status". Useful to apply changes later on.
function library:AssignBossMoves(chara, tm_allowed, tutor_allowed, egg_allowed, blacklist)
    if RogueEssence.GameManager.Instance.CurrentScene ~= RogueEssence.Dungeon.DungeonScene.Instance then
        logError(globals.error_types.SCENE, "This function can only be called inside dungeons.")
        return {}
    end
    -- prepare lists
    ---@type table<categoryType, integer>
    local allowed = { level = 4 }
    allowed.tm, allowed.tutor, allowed.egg = tm_allowed or 0, tutor_allowed or 0, egg_allowed or 0
    local moveset_table = filterMoveset(chara, allowed.tm > 0, allowed.tutor > 0, allowed.egg > 0, blacklist)
    ---@type table<"_Completed"|integer,synergyEntry|referenceSet>
    local synergies = { _Completed = {} }
    ---@type slotType[][]
    local move_slot_options = {
        { "stab", "coverage", "damage", "status" },
        { "stab", "coverage", "status", "status" }
    }
    local move_slots = self:WeightlessRandom(move_slot_options, true) --[[ @as slotType[] ]]
    local shuffled_slots = shuffleTable(move_slots, true) --[[ @as slotType[] ]]
    ---@type table<slotType,string[]> keeps track of what moves are assigned to what slot type
    local slot_to_moves = {}

    -- select the moves
    for _, slot_type in pairs(shuffled_slots) do
        slot_to_moves[slot_type] = slot_to_moves[slot_type] or {}
        table.insert(slot_to_moves[slot_type], moveSelection[slot_type](moveset_table, synergies, allowed))
    end
    -- apply the moves to the character in move_slot order
    for i, slot_type in pairs(move_slots) do
        local move = slot_to_moves[slot_type][1] --FIFO
        if move == "" then
            chara:DeleteSkill(i - 1)
        else
            chara:ReplaceSkill(move, i - 1, true)
        end
        table.remove(slot_to_moves[slot_type], 1) --the slot to moves list gets progressively emptied out
    end
    return shuffled_slots
end

--- Function that asks the player if they want to warp out. It checks if the player has ongoing missions
--- and displays messages accordingly.
function library:AskMissionWarpOut()
    if RogueEssence.GameManager.Instance.CurrentScene ~= RogueEssence.Dungeon.DungeonScene.Instance then
        logError(globals.error_types.SCENE, "This function can only be called inside dungeons.")
        return
    end
    local function MissionWarpOut()
        warpOut()
        GAME:WaitFrames(80)
        --Set minimap state back to old setting
        _DUNGEON.ShowMap = library.root.mission_flags.PriorMapSetting
        library.root.mission_flags.PriorMapSetting = nil
        TASK:WaitTask(_GAME:EndSegment(RogueEssence.Data.GameProgress.ResultType.Escaped))
    end

    local function SetMinimap()
        --to prevent accidentally doing something by pressing the button to select yes
        GAME:WaitFrames(10)
        --Set minimap state back to old setting
        _DUNGEON.ShowMap = library.root.mission_flags.PriorMapSetting
        library.root.mission_flags.PriorMapSetting = nil
    end

    local has_ongoing_jobs = false
    local curr_floor = GAME:GetCurrentFloor().ID + 1
    local curr_zone = _ZONE.CurrentZoneID
    local curr_segment = _ZONE.CurrentMapID.Segment

    for _, job in ipairs(self.root.taken) do
        if job.Floor > curr_floor and job.Taken and job.Completion == globals.completion.NotCompleted and curr_zone == job.Zone and curr_segment == job.Segment then
            has_ongoing_jobs = true
            break
        end
    end

    UI:ResetSpeaker()
    local state = 0
    while state > -1 do
        if state == 0 then
            if has_ongoing_jobs then
                UI:ChoiceMenuYesNo(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.CONTINUE_ONGOING):ToLocal()), true)
                UI:WaitForChoice()
                local leave_dungeon = UI:ChoiceResult()
                if leave_dungeon then
                    UI:ChoiceMenuYesNo(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.CONTINUE_CONFIRM):ToLocal()), true)
                    UI:WaitForChoice()
                    local leave_confirm = UI:ChoiceResult()
                    if leave_confirm then
                        state = -1
                        MissionWarpOut()
                    else
                        --pause between textboxes if player de-confirms
                        GAME:WaitFrames(20)
                    end
                else
                    state = -1
                    SetMinimap()
                end
            else
                UI:ChoiceMenuYesNo(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.CONTINUE_NO_ONGOING):ToLocal()), false)
                UI:WaitForChoice()
                local leave_dungeon = UI:ChoiceResult()
                if leave_dungeon then
                    state = -1
                    MissionWarpOut()
                else
                    state = -1
                    SetMinimap()
                end
            end
        end
    end
end

--- Dungeon-only function that makes the entire team, guests included, turn towards a character.
--- @param char any the character to turn towards
function library:TeamTurnTo(char)
    if RogueEssence.GameManager.Instance.CurrentScene ~= RogueEssence.Dungeon.DungeonScene.Instance then
        logError(globals.error_types.SCENE, "This function can only be called inside dungeons.")
        return
    end
    local player_count = GAME:GetPlayerPartyCount()
    local guest_count = GAME:GetPlayerGuestCount()
    for i = 0, player_count - 1, 1 do
        local player = GAME:GetPlayerPartyMember(i)
        if not player.Dead then
            DUNGEON:CharTurnToChar(player, char)
        end
    end

    for i = 0, guest_count - 1, 1 do
        local guest = GAME:GetPlayerGuestMember(i)
        if not guest.Dead then
            DUNGEON:CharTurnToChar(guest, char)
        end
    end
end

-- ----------------------------------------------------------------------------------------- --
-- #region COMMON support
-- ----------------------------------------------------------------------------------------- --
-- API specific for functions that are meant for common.lua or one of its child files

--- Meant to be called in ``COMMON.ShowDestinantonMenu``
--- Creates a reference table whose keys are all the zones with at least one job in them.
---@return referenceSet
function library:LoadJobDestinations()
    local mission_dests = {}
    for _, job in ipairs(self.root.taken) do
        if job.Taken then
            if not self:HasExternalEvents(job.Zone) then
                mission_dests[job.Zone] = true
            else
                job.Taken = false
            end
        end
    end
    return mission_dests
end

--- Meant to be called in ``COMMON.ShowDestinantonMenu``
--- Takes a zone name and its id and returns a name string that also contains any related job and event icons.
--- @param mission_dests referenceSet the set of job destinations
--- @param zone_id string the zone id string to format the name of
--- @param zone_name string the starting name of the zone, as extracted from its ZoneEntrySummary
--- @return string #the zone name string containing all the icons related to it.
function library:FormatDestinationMenuZoneName(mission_dests, zone_id, zone_name)
    local mission_icon, external_icons, ext_set = "", "", {}
    -- add open letter icon to dungeons with jobs
    if mission_dests[zone_id] then mission_icon = "\\" end --open letter
    -- add external icon to dungeons with external events
    local ext_conds = self:GetExternalEvents(zone_id)
    for _, ext in ipairs(ext_conds) do
        if ext.icon and ext.icon ~= "" and not ext_set[ext.icon] then
            ext_set[ext.icon] = true
            external_icons = external_icons .. (ext.icon)
            if self.data.external_events_icon_mode == "FIRST" then break end
        end
    end
    return STRINGS:Format(self.data.dungeon_list_pattern, zone_name, STRINGS:Format(mission_icon), STRINGS:Format(external_icons))
end

--- Meant to be called in ``COMMON:EnterDungeonMissionCheck``
--- Prepares the list of guests to be spawned and reduces the team limit accordingly if missiongen_settings.guests_take_up_space is set.
--- @param zone_id string the zone id string to prepare the guest data for
--- @return integer[], string[] #the list of indexes for jobs that have guests and the list of removed ally names.
function library:EnterDungeonPrepareParty(zone_id)
    local escort_jobs = {}

    for idx, job in ipairs(library.root.taken) do

        if job.Taken and job.Completion < 1 and zone_id == job.Zone then
            callEvent(job, "DungeonStart")
            if globals.job_types[job.Type].has_guest then
                --check to see if an escort is already in the team for this job. If so, don't include it in the guest list
                local guest_found = false
                for i = 0, _DATA.Save.ActiveTeam.Guests.Count - 1, 1 do
                    local guest_tbl = GAME:GetPlayerGuestMember(i).LuaData
                    if guest_tbl.JobReference == idx then
                        guest_found = true
                    end
                end
                if not guest_found then
                    table.insert(escort_jobs, idx)
                end
            end
        end
    end

    UI:ResetSpeaker()
    -- if set to do so, remove as many characters from the team as necessary and reduce the team limit accordingly
    local removed_names = {}
    if self.data.guests_take_up_space then
        self.root.previous_limit = RogueEssence.Dungeon.ExplorerTeam.MAX_TEAM_SLOTS
        local base_max = RogueEssence.Dungeon.ExplorerTeam.MAX_TEAM_SLOTS
        local zone_summary = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(zone_id)
        if zone_summary.TeamSize > -1 and zone_summary.TeamSize < RogueEssence.Dungeon.ExplorerTeam.MAX_TEAM_SLOTS then
            base_max = zone_summary.TeamSize
        end
        self.root.escort_jobs = #escort_jobs
        RogueEssence.Dungeon.ExplorerTeam.MAX_TEAM_SLOTS = math.max(1, self.data.min_party_limit,
            base_max - self.root.escort_jobs)
        for i = _DATA.Save.ActiveTeam.Players.Count - 1, RogueEssence.Dungeon.ExplorerTeam.MAX_TEAM_SLOTS, -1 do
            local char = GAME:GetPlayerPartyMember(i)
            GAME:RemovePlayerTeam(i)
            GAME:AddPlayerAssembly(char)
            table.insert(removed_names, 1, char:GetDisplayName(true))
        end
    end
    if _DATA.Save.ActiveTeam.LeaderIndex >= RogueEssence.Dungeon.ExplorerTeam.MAX_TEAM_SLOTS then
        _DATA.Save.ActiveTeam.LeaderIndex = 0 end
    return escort_jobs, removed_names
end


--- Meant to be called in ``COMMON.EnterDungeonMissionCheck``
--- Generates the clients of the provided jobs and adds them as guests.
--- @param zone_id string the zone id string to generate the guests for
--- @param escort_jobs integer[] the list of jobs to generate guests from
--- @return string[] #the list list of added guest names.
function library:EnterDungeonAddJobEscorts(zone_id, escort_jobs)
    local zone_summary = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(zone_id)

    -- calculate party-related level parameters
    local party_tot, party_avg, party_hst, party_count = 0, 0, 0, _DATA.Save.ActiveTeam.Players.Count
    for i = 0, party_count - 1, 1 do
        local char_lvl = _DATA.Save.ActiveTeam.Players[i].Level
        party_tot = party_tot + char_lvl
        party_hst = math.max(char_lvl, party_hst)
    end
    party_avg = party_tot // party_count

    -- add escorts to team
    local added_names = {}
    for _, idx in ipairs(escort_jobs) do
        local job = self.root.taken[idx]
        local nickname = job.Client.Nickname or ""
        local mId = self:TableToMonsterID(job.Client)
        local diff = self:NumToDifficulty(job.Difficulty)
        local level = self.data.difficulty_data[diff].escort_level
        local dungeon_default = not level
        if dungeon_default then level = zone_summary.Level end
        ---@cast level integer
        if self.data.guest_level_scaling then
            level = self.data.guest_level_scaling(level, dungeon_default, party_avg, party_hst, self.data)
        end

        local new_mob = _DATA.Save.ActiveTeam:CreatePlayer(_DATA.Save.Rand, mId, level, "", -1)
        new_mob.Nickname = nickname
        local tactic = _DATA:GetAITactic("stick_together")
        new_mob.Tactic = RogueEssence.Data.AITactic(tactic);
        _DATA.Save.ActiveTeam.Guests:Add(new_mob)
        local talk_evt = RogueEssence.Dungeon.BattleScriptEvent("EscortInteract")
        new_mob.ActionEvents:Add(talk_evt)
        local tbl = new_mob.LuaData
        tbl.JobReference = idx
        table.insert(added_names, "[color=#00FF00]" .. new_mob.Name .. "[color]")
    end
    return added_names
end

--- Meant to be called in ``COMMON.EnterDungeonMissionCheck``
--- Prints a SENT_HOME message using the provided list of formatted character display names.
--- @param removed_list string[] a list of character display names
function library:PrintSentHome(removed_list)
    if #removed_list<1 then return end
    UI:ResetSpeaker()
    local list_removed = STRINGS:CreateList(removed_list) --[[@as string]]
    if #removed_list > 1 then
        UI:WaitShowDialogue(STRINGS:FormatKey("MSG_TEAM_SENT_HOME_PLURAL", list_removed))
    elseif #removed_list == 1 then
        UI:WaitShowDialogue(STRINGS:FormatKey("MSG_TEAM_SENT_HOME", list_removed))
    end
end

--- Meant to be called in ``COMMON.EnterDungeonMissionCheck``
--- Prints an ESCORT_ADD message using the provided list of formatted character display names.
--- @param added_list string[] a list of character display names
function library:PrintEscortAdd(added_list)
    if #added_list < 1 then return end
    UI:ResetSpeaker()
    local list_added = STRINGS:CreateList(added_list) --[[@as string]]
    if #added_list > 1 then
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.ESCORT_ADD_PLURAL):ToLocal(), list_added))
    elseif #added_list == 1 then
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.ESCORT_ADD):ToLocal(), list_added))
    end
end

--- Meant to be called in ``COMMON.ExitDungeonMissionCheckEx``
--- Removes all target items from the inventory and requests a board update.
--- Its return value should itself be returned by COMMON.ExitDungeonMissionCheckEx
--- Please pass all of the function's parameters to this one, in order.
function library:ExitDungeonMissionCheckEx(result, _, zone, segment)
    local resultTypes = RogueEssence.Data.GameProgress.ResultType
    --reset the escort status
    _DATA.Save.ActiveTeam.Guests:Clear()
    if self.data.guests_take_up_space then
        RogueEssence.Dungeon.ExplorerTeam.MAX_TEAM_SLOTS = self.root.previous_limit or RogueEssence.Dungeon.ExplorerTeam.MAX_TEAM_SLOTS
        self.root.escort_jobs = 0
    end

    if result == resultTypes.Cleared then
        MissionGen.root.dungeon_progress[zone] = MissionGen.root.dungeon_progress[zone] or {}
        MissionGen.root.dungeon_progress[zone][segment] = true
    end

    --Remove any lost/stolen items. If the item contains a numerical HiddenValue and that number
    --corresponds to a job_index containing its id then delete it on exiting the dungeon.
    local isItemJobTarget = function(item)
        local num = tonumber(item.HiddenValue)
        if num then
            local job = MissionGen.root.taken[num]
            if job.Item == item.ID then return true end
        end
        return false
    end

    for i = GAME:GetPlayerBagCount() - 1, 0, -1 do
        if isItemJobTarget(GAME:GetPlayerBagItem(i)) then
            GAME:TakePlayerBagItem(i)
        end
    end

    --search equipped items as well
    for i = 0, GAME:GetPlayerPartyCount() - 1, 1 do
        if isItemJobTarget(GAME:GetPlayerEquippedItem(i)) then
            GAME:TakePlayerEquippedItem(i)
        end
    end

    --reset all job completion data if exploration failed in some way
    if result == resultTypes.Failed or result == resultTypes.Downed
        or result == resultTypes.TimedOut or result == resultTypes.GaveUp then
        MissionGen.root.mission_flags.MissionCompleted = false
        for _, job in ipairs(self.root.taken) do
            job.Completion = globals.completion.NotCompleted
        end
    end

    for _, job in ipairs(self.root.taken) do
        callEvent(job, "DungeonEnd", {result = result})
    end

    if MissionGen.root.mission_flags.MissionCompleted then
        -- PlayJobsCompletedCutscene will update the boards after it's done
        resetAnims()
        COMMON.EndDungeonDay(result, self.data.end_dungeon_day_destination.zone, -1, self.data.end_dungeon_day_destination.map, 0)
        return true
    end
    -- PlayJobsCompletedCutscene will not be triggered, so the boards will be updated here
    self:UpdateBoards()
    return false
end

-- ----------------------------------------------------------------------------------------- --
-- #region GROUND support
-- ----------------------------------------------------------------------------------------- --
-- API specific for functions that are meant for ground map scripting

--- Meant to be called in all ground maps where there are job boards, and must be ran before they fade in.
--- It iterates through the taken list, checking if the next job is in this map and running the reward cutscene for it
--- until it either finds a job that needs to be awarded on a different map, in which case it moves the player there,
--- Or it runs out of jobs.
--- The game will be in a fade out state every time the callback is run.
---@param callback fun(job:jobTable, npcs:any[]) the reward cutscene callback function.
--- It takes the job data table and the GroundChar npcs as arguments.
function library:PlayJobsCompletedCutscene(callback)
    local index = 1
    self.temp = self.temp or {}
    if self.temp.reward_job_index then index = self.temp.reward_job_index end
    local CurrentZone = _ZONE.CurrentZoneID
    local CurrentMap = _ZONE.CurrentMapID.ID

    while index <= #self.root.taken do
        local job = self.root.taken[index]
        if job.Completion == globals.completion.Completed then
            if job.BackReference and job.BackReference ~= "" then
                local dest = self.data.boards[job.BackReference --[[@as string]] ].location
                if CurrentZone ~= dest.zone or CurrentMap ~= dest.map then
                    self.temp.reward_job_index = index
                    GAME:EnterZone(dest.zone, -1, dest.map, 0)
                    return
                end
            end
            GAME:FadeOut(false, 1)
            local evt = callEvent(job, "BeforeReward", {zone = CurrentZone, map = CurrentMap})
            if not evt.cancel then
                rewardCutscene(index, callback)
            end
            local evt2 = callEvent(job, "AfterReward", {zone = CurrentZone, map = CurrentMap})
            if not evt2.cancel then
                self:RemoveTakenJob(index)
            end
        else
            job.Completion = globals.completion.NotCompleted
            index = index + 1
        end
    end
    self.root.mission_flags.MissionCompleted = false
    self.temp.reward_job_index = nil
    if self.data.after_rewards_function then
    self.data.after_rewards_function() end
    self:UpdateBoards()
    GAME:CutsceneMode(false)
end

--- Meant to be called as part of a job reward callback, in all ground maps where there are job boards.
--- Gives the player the rewards of a job. You may include a speaker and up to two dialogue lines to display as part of the routine.
--- This does not remove the job from the player. Another part of the job reward routine handles that already.
--- If the library is configured to award rank points, this function will also handle ranking up, and return the reached ranks if it happened.
---@param job jobTable the job to give the reward of
---@param speaker any|nil a GroundChar to use as speaker for the lines below. If nil, the lines will have no speaker.
---@param line1? string the line to use for the first reward. Unused if the reward is the client itself. Must be already formatted.
---@param line2? string the line to use for the second reward. Unused if there is no second reward. Must be already formatted.
---@return string[] #a list of ranks reached. If no rank-ups happened, the list will be empty
function library:RewardPlayer(job, speaker, line1, line2)
    local difficulty_data = self.data.difficulty_data[self:NumToDifficulty(job.Difficulty)]
    if job.RewardType == "client" then
        GAME:WaitFrames(20)
        self:AwardChar(job, speaker)
        GAME:WaitFrames(20)
    else
        if line1 then
            GAME:WaitFrames(20)
            UI:SetSpeaker(speaker)
            UI:WaitShowDialogue(line1)
        end

        --reward the item or money sum
        GAME:WaitFrames(20)
        if globals.reward_types[job.RewardType][1] then
            self:AwardItem(job.Reward1)
        else
            self:AwardMoney(difficulty_data.money_reward)
        end
        GAME:WaitFrames(20)

        if globals.reward_types[job.RewardType][2] then
            if line2 then
                UI:SetSpeaker(speaker)
                UI:WaitShowDialogue(line2)
                GAME:WaitFrames(20)
            end
            self:AwardItem(job.Reward2)
            GAME:WaitFrames(20)
        end
    end
    local ranks = self:AwardExtra(difficulty_data.extra_reward)
    return ranks
end

--- Offers the player a Character as reward. The character will be at the level it would've been if spawned now as a guest.
--- The player can refuse the new team member if the so choose.
---@param job jobTable the job to source the character from
---@param char Character the character that will be used as speaker for the cutscene
---@param talk? boolean if true, there will be a dialogue line before the prompt. If false, there won't be. Defaults to true.
---@return boolean true if the player accepted the new team member, false otherwise
function library:AwardChar(job, char, talk)
    if talk == true or talk == nil then
        UI:SetSpeaker(char)
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.CUTSCENE_AWARD_CHAR):ToLocal(), GAME:GetTeamName()))
    end
    GAME:WaitFrames(20)
    UI:ResetSpeaker()
    UI:ChoiceMenuYesNo( STRINGS:Format(RogueEssence.StringKey(globals.keysEx.CUTSCENE_AWARD_CHAR_PROMPT):ToLocal(), GAME:GetTeamName(), char:GetDisplayName()), true)
    UI:WaitForChoice()
    if UI:ChoiceResult() then
        local zone_summary = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(job.Zone)

        -- calculate party-related level parameters
        local party_tot, party_avg, party_hst, party_count = 0, 0, 0, _DATA.Save.ActiveTeam.Players.Count
        for i = 0, party_count - 1, 1 do
            local char_lvl = _DATA.Save.ActiveTeam.Players[i].Level
            party_tot = party_tot + char_lvl
            party_hst = math.max(char_lvl, party_hst)
        end
        party_avg = party_tot // party_count

        local nickname = job.Client.Nickname or ""
        local mId = self:TableToMonsterID(job.Client)
        local diff = self:NumToDifficulty(job.Difficulty)
        local level = self.data.difficulty_data[diff].escort_level
        local dungeon_default = not level
        if dungeon_default then level = zone_summary.Level end
        ---@cast level integer
        if self.data.guest_level_scaling then
            level = self.data.guest_level_scaling(level, dungeon_default, party_avg, party_hst, self.data)
        end

        local new_mob = _DATA.Save.ActiveTeam:CreatePlayer(_DATA.Save.Rand, mId, level, "", -1)
        new_mob.Nickname = nickname
        _DATA.Save.ActiveTeam.Assembly:Add(new_mob)

        UI:ResetSpeaker(false) --disable text noise
        UI:SetCenter(true)
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MSG_RECRUIT"):ToLocal(), self:GetCharacterName(job.Client), GAME:GetTeamName()))
        UI:SetCenter(false)
        UI:ResetSpeaker()
        return true
    end
    return false
end

--- Gives the player a sum of money as reward.
---@param amount integer the sum of money that will be given
function library:AwardMoney(amount)
    if amount <= 0 then return end
    UI:ResetSpeaker(false)--disable text noise
    UI:SetCenter(true)
    SOUND:PlayFanfare("Fanfare/Item")
    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.CUTSCENE_AWARD_MONEY):ToLocal(), GAME:GetTeamName(), STRINGS:FormatKey("MONEY_AMOUNT", amount)))
    GAME:AddToPlayerMoney(amount)
    UI:SetCenter(false)
    UI:ResetSpeaker()
end

--- Gives the player an InvItem as reward.
---@param itemTable itemTable the item to give. If its count is nil, it will default to the item's max stack
function library:AwardItem(itemTable)
    UI:ResetSpeaker(false) --disable text noise
    UI:SetCenter(true)

    local itemEntry = RogueEssence.Data.DataManager.Instance:GetItem(itemTable.id)

    --give at least 1 item
    if not itemTable.count then
        if itemEntry.MaxStack > 1 then
            itemTable.count = itemEntry.MaxStack
        else
            itemTable.count = 1
        end
    end
    itemTable.count = math.min(itemTable.count, itemEntry.MaxStack)

    local item = RogueEssence.Dungeon.InvItem(itemTable.id, false, itemTable.count)
    if itemTable.hidden then item.HiddenValue = itemTable.hidden end

    SOUND:PlayFanfare("Fanfare/Item")
    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.CUTSCENE_AWARD_ITEM):ToLocal(), GAME:GetTeamName(), item:GetDisplayName()))

    --bag is full - equipped count is separate from bag and must be included in the calc
    if GAME:GetPlayerBagCount() + GAME:GetPlayerEquippedCount() >= GAME:GetPlayerBagLimit() then
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.CUTSCENE_AWARD_ITEM_STORAGE):ToLocal(), GAME:GetTeamName(), item:GetDisplayName()))
        GAME:GivePlayerStorageItem(item.ID, itemTable.count)
    else
        GAME:GivePlayerItem(item.ID, itemTable.count)
    end
    UI:SetCenter(false)
    UI:ResetSpeaker()
end

--- Gives the player the job's extra reward. If the extra reward is set to "rank", then it will also rank the player team up and return the list of ranks reached.
---@param amount integer the amount of extra reward that will be given
---@return string[] #a list of ranks reached. If no rank-ups happened, the list will be empty
function library:AwardExtra(amount)
    local ranks_reached = {}
    if amount <= 0 then return ranks_reached end
    UI:ResetSpeaker(false) --disable text noise
    UI:SetCenter(true)
    SOUND:PlayFanfare("Fanfare/Item")
    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.CUTSCENE_AWARD_EXTRA):ToLocal(), GAME:GetTeamName(), STRINGS:FormatKey(globals.keys.EXTRA_REWARD, amount)))
    if self.data.extra_reward_type == "exp" then
        --Reward EXP for your party
        local player_count = _DATA.Save.ActiveTeam.Players.Count
        for player_idx = 0, player_count - 1, 1 do
            TASK:WaitTask(GROUND:_HandoutEXP(_DATA.Save.ActiveTeam.Players[player_idx], amount))
        end
    elseif self.data.extra_reward_type == "rank" then

        --check if a rank up is needed
        local start_rank = _DATA.Save.ActiveTeam.Rank
        local current_rank = start_rank
        local end_rank = start_rank
        local rankdata = _DATA:GetRank(current_rank)
        local to_go = rankdata.FameToNext - _DATA.Save.ActiveTeam.Fame
        --rank up if there's another rank to go. FameToNext will be 0 or -1 if there's no more ranks after.
        while amount >= to_go and rankdata.FameToNext > 0 do
            end_rank = rankdata.Next
            amount = amount - to_go
            if end_rank.FameToNext <= 0 then amount = 0 end
            --reset fame, go to next rank
            _DATA.Save.ActiveTeam:SetRank(end_rank)
            _DATA.Save.ActiveTeam.Fame = 0

            current_rank = end_rank
            rankdata = _DATA:GetRank(current_rank)
            table.insert(ranks_reached, current_rank)
            _DATA.Save.ActiveTeam.Fame = _DATA.Save.ActiveTeam.Fame + amount
        end
        SOUND:PlayFanfare("Fanfare/RankUp")
        UI:ResetSpeaker()
        UI:SetCenter(true)

        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.CUTSCENE_AWARD_RANK_UP):ToLocal(), GAME:GetTeamName(), _DATA:GetRank(start_rank).Name:ToLocal(), _DATA:GetRank(end_rank).Name:ToLocal()))
    end
    UI:SetCenter(false)
    UI:ResetSpeaker()
    GAME:WaitFrames(20)
    return ranks_reached
end

-- ----------------------------------------------------------------------------------------- --
-- #region BATTLE_SCRIPT support
-- ----------------------------------------------------------------------------------------- --
-- API specific for functions that are meant for event_battle.lua

--- Meant to be called in ``BATTLE_SCRIPT.EscortInteract``. It implements the entire EscortInteract event used by the library.
--- It displays a dialogue box containing one of the talk strings corresponding to the character's associated job type.
--- Please pass all of the event's parameters to this function, in order.
function library:EscortInteract(_, _, context, _)
    context.CancelState.Cancel = true
    local oldDir = context.Target.CharDir
    DUNGEON:CharTurnToChar(context.Target, context.User)
    UI:SetSpeaker(context.Target)

    local tbl = context.Target.LuaData
    local job = self.root.taken[tbl.JobReference] --[[@as jobTable]]

    local target = "[color=#FF0000]???[color]"
    if job.Target then target = self:GetCharacterName(job.Target) end
    local dungeon = self:GetSegmentName(job.Zone, job.Segment)
    local item = self:GetItemName(job.Item)

    local talk_options = self.data.escort_talks[job.Type]
    if job.Special and self.data.escort_talks[job.Special] then
        talk_options = self.data.escort_talks[job.Special]
    end
    local talk = self:WeightlessRandom(talk_options)

    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(talk):ToLocal(), target, dungeon, item))
    context.Target.CharDir = oldDir
end

--- Meant to be called in ``BATTLE_SCRIPT.EscortReached``. It implements the entire EscortReached event used by the library.
--- It is called when interacting with an escort mission target. It checks for escort proximity and completes the job if possible.
--- Please pass all of the event's parameters to this function, in order.
function library:EscortReached(_, _, context, _)
    context.CancelState.Cancel = false
    context.TurnCancel.Cancel = true
    --Mark this as the last dungeon entered.
    local tbl = context.Target.LuaData
    if tbl and tbl.JobReference then
        local job = self.root.taken[tbl.JobReference]
        local escort = nil
        for i = 0, _DATA.Save.ActiveTeam.Guests.Count - 1, 1 do
            local guest = GAME:GetPlayerGuestMember(i)
            if guest.LuaData and guest.LuaData.JobReference == tbl.JobReference then
                escort = guest
                break
            end
        end

        if escort and not escort.Dead then
            context.Target.Nickname = self:GetCharacterName(job.Target, true)
            local escortName = escort:GetDisplayName(true)
            local targetName = context.Target:GetDisplayName(true)
            local oldDir = context.Target.CharDir
            DUNGEON:CharTurnToChar(context.Target, context.User)
            UI:ResetSpeaker()
            if math.abs(escort.CharLoc.X - context.Target.CharLoc.X) <= 4 and math.abs(escort.CharLoc.Y - context.Target.CharLoc.Y) <= 4 then
                --Mark mission completion flags
                self.root.mission_flags.MissionCompleted = true
                self:MarkJobCompleted(job)
                UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.ESCORT_REACHED):ToLocal(), escortName, targetName))
                --Clear but remember minimap state
                self.root.mission_flags.PriorMapSetting = _DUNGEON.ShowMap
                _DUNGEON.ShowMap = _DUNGEON.MinimapState.None
                GAME:WaitFrames(20)

                UI:SetSpeaker(escort)
                UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.ESCORT_THANKS):ToLocal(), targetName))
                GAME:WaitFrames(20)
                UI:ResetSpeaker()
                UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.ESCORT_DEPART):ToLocal(), escortName, targetName))
                GAME:WaitFrames(20)

                -- warp out
                TASK:WaitTask(_DUNGEON:ProcessBattleFX(escort, escort, _DATA.SendHomeFX))
                _DUNGEON:RemoveChar(escort)
                _ZONE.CurrentMap.DisplacedChars:Remove(escort)
                GAME:WaitFrames(70)
                TASK:WaitTask(_DUNGEON:ProcessBattleFX(context.Target, context.Target, _DATA.SendHomeFX))
                _DUNGEON:RemoveChar(context.Target)

                GAME:WaitFrames(50)
                self:AskMissionWarpOut()
            else
                UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.ESCORT_UNAVAILABLE):ToLocal(), escortName))
                context.Target.CharDir = oldDir
            end
        else
            UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.ESCORT_UNAVAILABLE):ToLocal(), self:GetCharacterName(job.Client)))
        end
    end
end

--- Meant to be called in ``BATTLE_SCRIPT.RescueReached``. It implements the entire RescueReached event used by the library.
--- It is called when interacting with a rescue or delivery mission target. It checks for the delivery item if necessary and then
--- completes the job if possible.
--- Please pass all of the event's parameters to this function, in order.
function library:RescueReached(_, _, context, _)
    -- Set the nickname of the target, removing the gender sign
    local job = self.root.taken[context.Target.LuaData.JobReference]
    local tbl = context.Target.LuaData
    if tbl and tbl.JobReference then
        local char = job.Target or job.Client
        local base_name = self:GetCharacterName(char, true)
        GAME:SetCharacterNickname(context.Target, base_name)

        context.CancelState.Cancel = false
        context.TurnCancel.Cancel = true

        local oldDir = context.Target.CharDir

        DUNGEON:CharTurnToChar(context.Target, context.User)
        UI:ResetSpeaker()

        if job.Type == "RESCUE_SELF" or job.Type == "RESCUE_FRIEND" then
            rescueReachedFlow(context, job)
        elseif job.Type == "DELIVERY" then
            deliveryReachedFlow(context, job, oldDir)
        end
    end
end

-- ----------------------------------------------------------------------------------------- --
-- #region ZONE_GEN_SCRIPT support
-- ----------------------------------------------------------------------------------------- --
-- API specific for functions that are meant for event_mapgen.lua

--- Meant to be called in a ``ZONE_GEN_SCRIPT`` event. It handles checking for active jobs and generating every single event necessary for them to function.
--- Please pass all of the event's parameters to this function, in order.
---
--- The event calling this function is the only one that needs to be added directly to the game via dev mode:
--- go to Constants>Universal and add it to the ZoneSteps list as a ScriptZoneStep. No arguments required.
function library:GenerateJobInFloor(zoneContext, context, queue, seed, _)
    if _DATA.Save.Rescue ~= nil and _DATA.Save.Rescue.Rescuing then
        return
    end
    self.root.mission_flags.PriorMapSetting = nil
    self.root.mission_flags.MonsterHouseMessageNotified = false
    self.root.mission_flags.OutlawItemState = 0
    self.root.mission_flags.OutlawDefeated = false
    self.root.mission_flags.ItemPickedUp = false

    local job = nil
    local jobIndex = nil
    local escortMissions = false
    local npcMission = false
    local activeEffect = RogueEssence.Data.ActiveEffect()


    for i, entry in ipairs(self.root.taken) do
        if entry.Taken and entry.Completion == globals.completion.NotCompleted and zoneContext.CurrentZone == entry.Zone then
            -- if this job is an escort mission
            if self.globals.job_types[entry.Type].has_guest then escortMissions = true end
            if zoneContext.CurrentSegment == entry.Segment and zoneContext.CurrentID + 1 == entry.Floor then
                job, jobIndex = entry, i
                break
            end
        end
    end

    local prio_boss = self.data.dungeon_boss_steps_piority
    local prio_gen = self.data.dungeon_gen_steps_piority
    local prio_npc = self.data.dungeon_npc_steps_piority
    if type(prio_boss) ~= "table" then prio_boss = {prio_boss} end
    if type(prio_gen)  ~= "table" then prio_gen  = {prio_gen}  end
    if type(prio_npc)  ~= "table" then prio_npc  = {prio_npc}  end
    local priority_boss = RogueElements.Priority(LUA_ENGINE:MakeLuaArray(globals.ctypes.Integer, prio_boss))
    local priority_gen  = RogueElements.Priority(LUA_ENGINE:MakeLuaArray(globals.ctypes.Integer, prio_gen))
    local priority_npc  = RogueElements.Priority(LUA_ENGINE:MakeLuaArray(globals.ctypes.Integer, prio_npc))

    if escortMissions then
        activeEffect.OnDeaths:Add(priority_gen, RogueEssence.Dungeon.SingleCharScriptEvent("EscortDeathCheck", '{}'))
    end
    if job then
        local evt = callEvent(job, "FloorStart", {zoneContext = zoneContext, context = context, queue = queue, seed = seed})
        if evt.cancel then return end

        ---@cast job jobTable
        if globals.job_types[job.Type].target_outlaw then
            activeEffect.OnDeaths:Add(priority_gen,
                RogueEssence.Dungeon.SingleCharScriptEvent("OutlawDeathCheck", '{ JobReference = ' .. jobIndex .. ' }'))
            if job.Type == "OUTLAW" then
                activeEffect.OnTurnEnds:Add(priority_gen,
                    RogueEssence.Dungeon.SingleCharScriptEvent("OutlawCheck", '{ JobReference = ' .. jobIndex .. ' }'))
            elseif job.Type == "OUTLAW_FLEE" then
                activeEffect.OnMapTurnEnds:Add(priority_gen,
                    RogueEssence.Dungeon.SingleCharScriptEvent("OutlawFleeStairsCheck",
                        '{ JobReference = ' .. jobIndex .. ' }'))
                activeEffect.OnTurnEnds:Add(priority_gen,
                    RogueEssence.Dungeon.SingleCharScriptEvent("OutlawCheck", '{ JobReference = ' .. jobIndex .. ' }'))
            elseif job.Type == "OUTLAW_ITEM" or job.Type == "OUTLAW_ITEM_UNK" then
                activeEffect.OnTurnEnds:Add(priority_gen,
                    RogueEssence.Dungeon.SingleCharScriptEvent("OutlawItemCheckItem",
                        '{ JobReference = ' .. jobIndex .. ' }'))
                activeEffect.OnTurnEnds:Add(priority_gen,
                    RogueEssence.Dungeon.SingleCharScriptEvent("OutlawItemCheck", '{ JobReference = ' .. jobIndex .. ' }'))
            elseif job.Type == "OUTLAW_MONSTER_HOUSE" then
                activeEffect.OnTurnEnds:Add(priority_gen,
                    RogueEssence.Dungeon.SingleCharScriptEvent("MonsterHouseOutlawCheck",
                        '{ JobReference = ' .. jobIndex .. ' }'))
            end
            activeEffect.OnMapStarts:Add(priority_boss,
                RogueEssence.Dungeon.SingleCharScriptEvent("SpawnOutlaw", '{ JobReference = ' .. jobIndex .. ' }'))
            activeEffect.OnMapStarts:Add(priority_gen,
                RogueEssence.Dungeon.SingleCharScriptEvent("OutlawFloor", '{ JobReference = ' .. jobIndex .. ' }'))
        elseif job.Type == "RESCUE_SELF" or job.Type == "RESCUE_FRIEND" or job.Type == "DELIVERY" or job.Type == "ESCORT" then
            npcMission = true
            local char = job.Client
            if job.Type == "RESCUE_FRIEND" or job.Type == "ESCORT" then char = job.Target --[[@as monsterIDTable]] end
            local specificTeam = RogueEssence.LevelGen.SpecificTeamSpawner()
            local post_mob = RogueEssence.LevelGen.MobSpawn()
            post_mob.BaseForm = self:TableToMonsterID(char)
            post_mob.Tactic = "slow_wander"
            post_mob.Level = RogueElements.RandRange(50)
            local dialogue
            if job.Type == "RESCUE_SELF" or job.Type == "RESCUE_FRIEND" or job.Type == "DELIVERY" then
                dialogue = RogueEssence.Dungeon.BattleScriptEvent("RescueReached")
            elseif job.Type == "ESCORT" then
                dialogue = RogueEssence.Dungeon.BattleScriptEvent("EscortReached")
            end
            post_mob.SpawnFeatures:Add(PMDC.LevelGen.MobSpawnInteractable(dialogue))
            post_mob.SpawnFeatures:Add(PMDC.LevelGen.MobSpawnLuaTable('{ JobReference = ' .. jobIndex .. ' }'))
            post_mob.SpawnFeatures:Add(PMDC.LevelGen.MobSpawnUnrecruitable())
            --It is not possible to nickname in a spawn step. It'll happen on interact instead.

            specificTeam.Spawns:Add(post_mob)
            PrintInfo("Creating Spawn")
            local picker = LUA_ENGINE:MakeGenericType(PresetMultiTeamSpawnerType, { MapGenContextType }, {})
            picker.Spawns:Add(specificTeam)
            PrintInfo("Creating Step")
            local mobPlacement = LUA_ENGINE:MakeGenericType(PlaceRandomMobsStepType, { MapGenContextType }, { picker })

            PrintInfo("Setting everything else")
            mobPlacement.Ally = true
            mobPlacement.Filters:Add(PMDC.LevelGen.RoomFilterConnectivity(PMDC.LevelGen.ConnectivityRoom.Connectivity.Main))
            mobPlacement.ClumpFactor = 20
            PrintInfo("Enqueueing")
            queue:Enqueue(priority_npc, mobPlacement)
        elseif job.Type == "LOST_ITEM" then
            local lost_item = RogueEssence.Dungeon.MapItem(job.Item)
            lost_item.HiddenValue = tostring(jobIndex)
            lost_item.Cursed = true
            PrintInfo("Spawning Lost Item " .. lost_item.Value)
            local preset_picker = LUA_ENGINE:MakeGenericType(PresetPickerType, { MapItemType }, { lost_item })
            local multi_preset_picker = LUA_ENGINE:MakeGenericType(PresetMultiRandType, { MapItemType },
                { preset_picker })
            local picker_spawner = LUA_ENGINE:MakeGenericType(PickerSpawnType, { MapGenContextType, MapItemType },
                { multi_preset_picker })
            local random_room_spawn = LUA_ENGINE:MakeGenericType(RandomRoomSpawnStepType,
                { MapGenContextType, MapItemType }, {})
            random_room_spawn.Spawn = picker_spawner
            random_room_spawn.Filters:Add(PMDC.LevelGen.RoomFilterConnectivity(PMDC.LevelGen.ConnectivityRoom
                .Connectivity.Main))
            queue:Enqueue(priority_npc, random_room_spawn)
        end

        -- add destination floor notification, except for bossfight-style outlaws
        if not globals.job_types[job.Type].target_outlaw or job.Type == "OUTLAW_ITEM_UNK" then
            activeEffect.OnMapStarts:Add(priority_gen, RogueEssence.Dungeon.SingleCharScriptEvent("DestinationFloor", "{}"))
        end

        if job.Type == "EXPLORATION" then
            local escort = false
            for i = 0, _DATA.Save.ActiveTeam.Guests.Count - 1, 1 do
                local guest = GAME:GetPlayerGuestMember(i)
                if guest.LuaData and guest.LuaData.JobReference == jobIndex then
                    escort = true
                    break
                end
            end
            if escort then
                activeEffect.OnMapStarts:Add(priority_gen, RogueEssence.Dungeon.SingleCharScriptEvent("ExplorationReached", '{  JobReference = ' .. jobIndex .. ' }'))
            end
        elseif job.Type == "LOST_ITEM" then
            activeEffect.OnTurnEnds:Add(priority_gen,
                RogueEssence.Dungeon.SingleCharScriptEvent("MissionItemCheck", '{ JobReference = ' .. jobIndex .. ' }'))
        end

        if npcMission then
            activeEffect.OnMapTurnEnds:Add(priority_gen,
                RogueEssence.Dungeon.SingleCharScriptEvent("MobilityEndTurn", '{}'))
        end

        local destNote = LUA_ENGINE:MakeGenericType(MapEffectStepType, { MapGenContextType }, { activeEffect })
        local priority = RogueElements.Priority(priority_gen)
        queue:Enqueue(priority, destNote)
    end
end

-- ----------------------------------------------------------------------------------------- --
-- #region SINGLE_CHAR_SCRIPT support
-- ----------------------------------------------------------------------------------------- --
-- API specific for functions that are meant for event_single.lua

--- Meant to be called in ``SINGLE_CHAR_SCRIPT.SpawnOutlaw``. It implements the entire SpawnOutlaw event used by the library.
--- It is called at the start of an outlaw job's destination floor. It scans for a spawn point for the outlaw, then generates
--- the character and adds it in that tile.
--- Please pass all of the event's parameters to this function, in order.
function library:SpawnOutlaw(_, _, context, args)
    if context.User ~= nil then
        return
    end
    local jobIndex = args.JobReference
    local job = self.root.taken[jobIndex]
    if job.Completion == globals.completion.NotCompleted then
        local origins = { _DATA.Save.ActiveTeam.Leader.CharLoc }
        local minRadius, maxRadius = 3, 5

        local lastradius = 0
        local spawn_candidates = {}

        if job.Type == "OUTLAW_ITEM_UNK" then
            minRadius = maxRadius
            origins = {}
            local diam = minRadius*2 +1
            for x = minRadius, _ZONE.CurrentMap.Width, diam do
                for y = minRadius, _ZONE.CurrentMap.Height, diam do
                    table.insert(origins, RogueElements.Loc(x,y))
                end
            end
        end

        while #origins > 0 and #spawn_candidates<=0 do
            local origin, oIndex = self:WeightlessRandom(origins, true)
            ---@cast origin {X:integer, Y:integer}
            table.remove(origins, oIndex)
            for pos, radius in iter_spiral(origin, maxRadius, 2) do
                if radius > minRadius and radius > lastradius and #spawn_candidates > 0 then break end


                if not _ZONE.CurrentMap:TileBlocked(pos) and not _ZONE.CurrentMap:GetCharAtLoc(pos) then

                    local next_to_player_units = false
                    --don't spawn the outlaw directly next to the player or their teammates
                    for i = 1, GAME:GetPlayerPartyCount(), 1 do
                        local party_member = GAME:GetPlayerPartyMember(i - 1)
                        if math.abs(party_member.CharLoc.X - pos.X) <= 1 and math.abs(party_member.CharLoc.Y - pos.Y) <= 1 then
                            next_to_player_units = true
                            break
                        end
                    end
                    --guests too!
                    if not next_to_player_units then
                        for i = 1, GAME:GetPlayerGuestCount(), 1 do
                            local party_member = GAME:GetPlayerGuestMember(i - 1)
                            if math.abs(party_member.CharLoc.X - pos.X) <= 1 and math.abs(party_member.CharLoc.Y - pos.Y) <= 1 then
                                next_to_player_units = true
                                break
                            end
                        end
                    end
                    if not next_to_player_units then
                        table.insert(spawn_candidates, pos)
                    end
                end
            end
        end

        if #spawn_candidates < 1 then
            logError(globals.error_types.MAPGEN, "Outlaw couldn't spawn for current floor, not enough spawn candidates.")
            UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.OUTLAW_SPAWN_FAIL):ToLocal(), self:GetCharacterName(job.Target)))
            return
        end

        -- Pick a valid space and generate the outlaw
        local spawn_loc = self:WeightlessRandom(spawn_candidates, true)
        local new_team = RogueEssence.Dungeon.MonsterTeam()
        local mob_data = RogueEssence.Dungeon.CharData(true)
        local form = _DATA:GetMonster(job.Target.Species).Forms[job.Target.Form]
        mob_data.BaseForm = self:TableToMonsterID(job.Target)

        local party_tot, party_avg, party_hst, party_count = 0, 0, 0, _DATA.Save.ActiveTeam.Players.Count
        for i = 0, party_count - 1, 1 do
            local char_lvl = _DATA.Save.ActiveTeam.Players[i].Level
            party_tot = party_tot + char_lvl
            party_hst = math.max(char_lvl, party_hst)
        end
        party_avg = party_tot // party_count

        local diff = self:NumToDifficulty(job.Difficulty)
        local orig_level = self.data.difficulty_data[diff].outlaw_level
        local dungeon_default = not orig_level
        local zone = _ZONE.CurrentZone
        if dungeon_default then
            if zone.LevelCap then
                orig_level = getFloorAverage() --deal with level reset dungeon separately
            else
                orig_level = zone.Level
            end
        end
        ---@cast orig_level integer
        local level = orig_level
        if self.data.outlaw_level_scaling then
            self.data.outlaw_level_scaling(orig_level, dungeon_default, party_avg, party_hst, self.data)
        end
        local ability = form:RollIntrinsic(_DATA.Save.Rand, 3)
        mob_data.BaseIntrinsics[0] = ability
        local new_mob = RogueEssence.Dungeon.Character(mob_data)
        new_mob.Level = level

        local skill_blacklist = {'teleport', 'guillotine', 'sheer_cold', 'horn_drill', 'fissure', 'memento',
            'healing_wish', 'lunar_dance', 'self_destruct', 'explosion', 'final_gambit', 'perish_song',
            'dragon_rage' }
        local blacklist = {}
        for _, skill_id in ipairs(skill_blacklist) do blacklist[skill_id] = true end
        local eggMoveChance = {
            {val=0, Weight=#self.data.difficulty_list-job.Difficulty},
            {val=1, Weight=#self.data.difficulty_list+job.Difficulty-2}
        }
        local tms = new_mob.Level//25 --1 every 25 levels
        local tutors = math.max(0, new_mob.Level//20-2) --1 every 20 levels, starting from lv40
        local eggs = self:WeightedRandom(eggMoveChance, true).val --50% to 100% chance to have one, depending on job difficulty
        self:AssignBossMoves(new_mob, tms, tutors, eggs, blacklist)

        local tactic = nil
        if job.Type =="OUTLAW_FLEE" then
            tactic = _DATA:GetAITactic("super_flee_stairs")
        elseif job.Type == "OUTLAW_ITEM_UNK" then
            tactic = _DATA:GetAITactic("wander_smart")
        else
            tactic = _DATA:GetAITactic("boss")
        end

        if self.data.apply_outlaw_changes then
            self.data.apply_outlaw_changes(new_mob, job)
        end

        if job.Type == "OUTLAW_ITEM" or job.Type == "OUTLAW_ITEM_UNK" then
            new_mob.EquippedItem = RogueEssence.Dungeon.InvItem(job.Item)
            new_mob.EquippedItem.HiddenValue = tostring(jobIndex)
            new_mob.EquippedItem.Cursed = true
        end

        new_mob.HP = new_mob.MaxHP;
        new_mob.Unrecruitable = true
        new_mob.Tactic = tactic
        new_mob.CharLoc = spawn_loc
        new_team.Players:Add(new_mob)

        local tbl = new_mob.LuaData
        tbl.OutlawReference = jobIndex

        _ZONE.CurrentMap.MapTeams:Add(new_team)
        new_mob:RefreshTraits()
        _ZONE.CurrentMap:UpdateExploration(new_mob)

        local base_name = RogueEssence.Data.DataManager.Instance.DataIndices[RogueEssence.Data.DataManager.DataType.Monster]:Get(new_mob.BaseForm.Species).Name:ToLocal()
        GAME:SetCharacterNickname(new_mob, job.Client.Nickname or base_name)
        return new_mob
    end
end

--- Meant to be called in ``SINGLE_CHAR_SCRIPT.OutlawFloor``. It implements the entire OutlawFloor event used by the library.
--- It is called at the start of an outlaw job's destination floor, only if the outlaw spawned successfully.
--- It displays different introduction messages depending on the job type, starts the outlaw music if the outlaw is not unknown,
--- and spawns a monster house if the job requires it.
--- Please pass all of the event's parameters to this function, in order.
function library:OutlawFloor(owner, ownerChar, context, args)
    local outlaw = context.User
    if outlaw == nil then
        return
    end
    local tbl = outlaw.LuaData
    if tbl and tbl.OutlawReference then
        local jobIndex = args.JobReference
        local job = self.root.taken[jobIndex]
        if job.Type ~= "OUTLAW_ITEM_UNK" then
            outlaw.Nickname = RogueEssence.Dungeon.CharData.GetFullFormName(self:TableToMonsterID(job.Target))
            SOUND:PlayBGM(self.data.outlaw_music_name, true, 20)
            UI:ResetSpeaker()
            DUNGEON:CharTurnToChar(outlaw, GAME:GetPlayerPartyMember(0))
            self:TeamTurnTo(outlaw)
            if globals.job_types[job.Type].boss then
                UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.OUTLAW_REACHED):ToLocal()))
            end

            GAME:WaitFrames(20)
            UI:SetSpeaker(outlaw)
            if job.Type == "OUTLAW_FLEE" then
                UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.OUTLAW_FLEE):ToLocal()))
                outlaw.CharDir = _DUNGEON.ActiveTeam.Leader.CharDir
            elseif job.Type == "OUTLAW_MONSTER_HOUSE" then
                UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.OUTLAW_MONSTER_HOUSE):ToLocal()))
                SOUND:FadeOutBGM(20)
                GAME:WaitFrames(20)

                -- ===========Monster house spawning logic============
                local goon_spawn_radius = 5

                local origin = _DUNGEON.ActiveTeam.Leader.CharLoc

                local leftmost_x = math.maxinteger
                local rightmost_x = math.mininteger

                local downmost_y = math.mininteger
                local upmost_y = math.maxinteger


                local topLeft = RogueElements.Loc(origin.X - goon_spawn_radius, origin.Y - goon_spawn_radius)
                local bottomRight = RogueElements.Loc(origin.X + goon_spawn_radius, origin.Y + goon_spawn_radius)

                PrintInfo("Spawning monster house with top left " ..
                    topLeft.X .. ", " .. topLeft.Y .. " and bottom right " .. bottomRight.X .. ", " .. bottomRight.Y)

                local valid_tile_total = 0
                for x = math.max(topLeft.X, 0), math.min(bottomRight.X, _ZONE.CurrentMap.Width - 1), 1 do
                    for y = math.max(topLeft.Y, 0), math.min(bottomRight.Y, _ZONE.CurrentMap.Height - 1), 1 do
                        local testLoc = RogueElements.Loc(x, y)
                        local tile_block = _ZONE.CurrentMap:TileBlocked(testLoc)
                        local char_at = _ZONE.CurrentMap:GetCharAtLoc(testLoc)

                        if tile_block == false and char_at == nil then
                            valid_tile_total = valid_tile_total + 1
                            leftmost_x = math.min(testLoc.X, leftmost_x)
                            rightmost_x = math.max(testLoc.X, rightmost_x)
                            downmost_y = math.max(testLoc.Y, downmost_y)
                            upmost_y = math.min(testLoc.Y, upmost_y)
                        end
                    end
                end

                local house_event = PMDC.Dungeon.MonsterHouseMapEvent();

                local tl = RogueElements.Loc(leftmost_x - 1, upmost_y - 1)
                local br = RogueElements.Loc(rightmost_x + 1, downmost_y + 1)

                local bounds = RogueElements.Rect.FromPoints(tl, br)
                house_event.Bounds = bounds

                local min_goons = math.floor(valid_tile_total / 5)
                local max_goons = math.floor(valid_tile_total / 4)
                local total_goons = _DATA.Save.Rand:Next(min_goons, max_goons)

                local all_spawns = LUA_ENGINE:MakeGenericType(globals.ctypes.List, { globals.ctypes.MobSpawn }, {})
                for i = 0, _ZONE.CurrentMap.TeamSpawns.Count - 1, 1 do
                    local possible_spawns = _ZONE.CurrentMap.TeamSpawns:GetSpawn(i):GetPossibleSpawns()
                    for j = 0, possible_spawns.Count - 1, 1 do
                        local spawn = possible_spawns:GetSpawn(j):Copy()
                        all_spawns:Add(spawn)
                    end
                end

                for _ = 1, total_goons, 1 do
                    local randint = _DATA.Save.Rand:Next(0, all_spawns.Count)
                    local spawn = all_spawns[randint]
                    spawn.SpawnFeatures:Add(PMDC.LevelGen.MobSpawnLuaTable('{ Goon = ' .. jobIndex .. ' }'))
                    spawn.SpawnFeatures:Add(PMDC.LevelGen.MobSpawnUnrecruitable())
                    house_event.Mobs:Add(spawn)
                end
                local charaContext = RogueEssence.Dungeon.SingleCharContext(_DUNGEON.ActiveTeam.Leader)
                TASK:WaitTask(house_event:Apply(owner, ownerChar, charaContext))
                GAME:WaitFrames(20)
            else
                --to prevent accidental button mashing making you waste your turn
                GAME:WaitFrames(20)
            end

            --Starts the player in team mode which they likely want to be in, this can help prevent desyncs as well
            _DUNGEON:SetTeamMode(true)
        else

        end
    end
end

--- Meant to be called in ``SINGLE_CHAR_SCRIPT.OutlawDeathCheck``. It implements the entire OutlawDeathCheck event used by the library.
--- It is called whenever a pokémon faints. If the pokémon is an outlaw, then this information will be saved for future handling.
--- Please pass all of the event's parameters to this function, in order.
function library:OutlawDeathCheck(_, _, context, _)
    local subject = context.User
    if subject.LuaData and subject.LuaData.OutlawReference then
        self.root.mission_flags.OutlawDefeated = true
    end

    subject.LuaData.OutlawReference = nil
    subject.LuaData.Goon = nil
end

--- Meant to be called in ``SINGLE_CHAR_SCRIPT.OutlawCheck``. It implements the entire OutlawCheck event used by the library.
--- It is called on turn end during a regular OUTLAW job, and checks whether the outlaw is marked as defeated or not.
--- If it is, the outlaw music will stop, and the player will be prompted to leave.
--- Please pass all of the event's parameters to this function, in order.
function library:OutlawCheck(_, _, _, args)
    local jobIndex = args.JobReference
    local job = self.root.taken[jobIndex] --[[@as jobTable]]
    if job.Completion == globals.completion.NotCompleted and self.root.mission_flags.OutlawDefeated then
        local outlaw_name = self:GetCharacterName(job.Target)
        SOUND:PlayBGM(_ZONE.CurrentMap.Music, true)
        self.root.mission_flags.MissionCompleted = true
        library:MarkJobCompleted(job)
        GAME:WaitFrames(50)
        UI:ResetSpeaker()
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.OUTLAW_DEFEATED):ToLocal(), outlaw_name))

        self.root.mission_flags.PriorMapSetting = _DUNGEON.ShowMap
        _DUNGEON.ShowMap = _DUNGEON.MinimapState.None
        self:AskMissionWarpOut()
    end
end

--- Meant to be called in ``SINGLE_CHAR_SCRIPT.OutlawFleeStairsCheck``. It implements the entire OutlawFleeStairsCheck event used by the library.
--- It is called on turn end during an OUTLAW_FLEE job, and checks whether the outlaw has reached the stairs or not.
--- If it has, the outlaw music will stop, the outlaw will disappear, and the job will be marked as failed.
--- Please pass all of the event's parameters to this function, in order.
function library:OutlawFleeStairsCheck(_, _, _, args)
    local stairs_arr = {
        "stairs_back_down", "stairs_back_up", "stairs_exit_down",
        "stairs_exit_up", "stairs_go_up", "stairs_go_down"
    }
    local stairs_set = {}
    for _, id in ipairs(stairs_arr) do stairs_set[id] = true end

    local jobIndex = args.JobReference
    local job = self.root.taken[jobIndex]

    local outlaw
    for char in luanet.each(LUA_ENGINE:MakeList(_ZONE.CurrentMap:IterateCharacters(false, true))) do
        if char.LuaData and char.LuaData.OutlawReference == jobIndex then
            outlaw = char
            break
        end
    end

    if outlaw then
        local targetName = outlaw:GetDisplayName(true)
        local map = _ZONE.CurrentMap;
        local charLoc = outlaw.CharLoc
        local tile = map:GetTile(charLoc)
        local tile_effect_id = tile.Effect.ID
        if tile and stairs_set[tile_effect_id] then
            GAME:WaitFrames(20)
            _DUNGEON:RemoveChar(outlaw)
            GAME:WaitFrames(20)
            UI:ResetSpeaker()
            UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.OUTLAW_FLED):ToLocal(), targetName))
            library:MarkJobFailed(job)
            SOUND:PlayBGM(_ZONE.CurrentMap.Music, true)
            GAME:WaitFrames(20)
        end
    end
end

--- Meant to be called in ``SINGLE_CHAR_SCRIPT.MonsterHouseOutlawCheck``. It implements the entire MonsterHouseOutlawCheck event used by the library.
--- It is called on turn end during an OUTLAW_MONSTER_HOUSE job, and looks for both the outlaw and its goons, checking how many of them are defeated.
--- It will prompt different messages depending on whether the outlaw or the monster house are defeated first. When all of them are fainted,
--- the monster house music will stop, and the player will be prompted to leave.
--- Please pass all of the event's parameters to this function, in order.
function library:MonsterHouseOutlawCheck(_, _, _, args)
    local jobIndex = args.JobReference
    local job = self.root.taken[jobIndex]
    local outlaw_name = self:GetCharacterName(job.Target)

    if job.Completion == globals.completion.NotCompleted then
        local found_outlaw, found_goon = false, false
        local outlaw = nil
        for char in luanet.each(LUA_ENGINE:MakeList(_ZONE.CurrentMap:IterateCharacters(false, true))) do
            if char.LuaData then
                if char.LuaData.OutlawReference == jobIndex then
                    found_outlaw = true
                    outlaw = char
                elseif char.LuaData.Goon == jobIndex then
                    found_goon = true
                end
            end
            if found_goon and found_outlaw then break end
        end

        if not self.root.mission_flags.MonsterHouseMessageNotified then
            if found_goon and not found_outlaw then
                GAME:WaitFrames(20)
                UI:ResetSpeaker()
                UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.OUTLAW_BOSS_DEFEATED):ToLocal(), outlaw_name))
                self.root.mission_flags.MonsterHouseMessageNotified = true
            end
            if not found_goon and found_outlaw then
                GAME:WaitFrames(40)
                UI:SetSpeaker(outlaw)
                UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.OUTLAW_MINIONS_DEFEATED):ToLocal()))
                self.root.mission_flags.MonsterHouseMessageNotified = true
            end
        end

        if not (found_goon or found_outlaw) then
            SOUND:PlayBGM(_ZONE.CurrentMap.Music, true)
            self.root.mission_flags.MissionCompleted = true
            self:MarkJobCompleted(job)
            GAME:WaitFrames(20)
            UI:ResetSpeaker()
            UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.OUTLAW_HOUSE_DEFEATED):ToLocal(), outlaw_name))
            self.root.mission_flags.PriorMapSetting = _DUNGEON.ShowMap
            _DUNGEON.ShowMap = _DUNGEON.MinimapState.None
            self:AskMissionWarpOut()
        end
    end
end

--- Meant to be called in ``SINGLE_CHAR_SCRIPT.OutlawItemCheckItem``. It implements the entire OutlawItemCheckItem event used by the library.
--- It is called on turn end during an OUTLAW_ITEM or OUTLAW_ITEM_UNK job, and checks whether the outlaw item is in the player's inventory.
--- If it is, then this information will be saved for future handling.
--- Please pass all of the event's parameters to this function, in order.
function library:OutlawItemCheckItem(_, _, _, args)
    if not self.root.mission_flags.ItemPickedUp then
        local jobIndex = args.JobReference
        local job = self.root.taken[jobIndex]

        for i = 0, GAME:GetPlayerBagCount()-1, 1 do
            local invItem = GAME:GetPlayerBagItem(i)
            if invItem.ID == job.Item and invItem.HiddenValue == tostring(jobIndex) then
                self.root.mission_flags.ItemPickedUp = true
                break
            end
        end
        if not self.root.mission_flags.ItemPickedUp then
            for i = 0, GAME:GetPlayerPartyCount()-1, 1 do
                local equipItem = GAME:GetPlayerEquippedItem(i)
                if equipItem and equipItem.ID == job.Item and equipItem.HiddenValue == tostring(jobIndex) then
                    self.root.mission_flags.ItemPickedUp = true
                    break
                end
            end
        end
    end
end

--- Meant to be called in ``SINGLE_CHAR_SCRIPT.OutlawItemCheck``. It implements the entire OutlawItemCheck event used by the library.
--- It is called on turn end during an OUTLAW_ITEM or OUTLAW_ITEM_UNK job, and checks whether the outlaw is marked as defeated or not,
--- and if the item has been retrieved.
--- It will display different messages depending on the specific job type and its completion state.
--- When the outlaw is defeated and the item retrieved, the outlaw music will stop, and the player will be prompted to leave.
--- Please pass all of the event's parameters to this function, in order.
function library:OutlawItemCheck(_, _, _, args)
    local jobIndex = args.JobReference
    local job = self.root.taken[jobIndex]
    local outlawName = self:GetCharacterName(job.Target)
    local item_name = RogueEssence.Dungeon.InvItem(job.Item):GetDisplayName()
    local complete_job = function(keyEx)
        self.root.mission_flags.MissionCompleted = true
        self:MarkJobCompleted(job)
        SOUND:PlayBGM(_ZONE.CurrentMap.Music, true)
        GAME:WaitFrames(50)
        UI:ResetSpeaker()
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(keyEx):ToLocal(), outlawName, item_name))
        --Clear but remember minimap state
        self.root.mission_flags.PriorMapSetting = _DUNGEON.ShowMap
        _DUNGEON.ShowMap = _DUNGEON.MinimapState.None
        self:AskMissionWarpOut()
    end

    if job.Completion == globals.completion.NotCompleted then
        if self.root.mission_flags.OutlawItemState == 0 then --nothing done yet
            if self.root.mission_flags.OutlawDefeated then
                self.root.mission_flags.OutlawItemState = 1
                if job.Type == "OUTLAW_ITEM_UNK" then
                    GAME:WaitFrames(50)
                    UI:ResetSpeaker()
                    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.OUTLAW_ITEM_UNK_DEFEATED):ToLocal(), outlawName,item_name))
                else
                    SOUND:PlayBGM(_ZONE.CurrentMap.Music, true)
                end
            elseif self.root.mission_flags.ItemPickedUp then
                self.root.mission_flags.OutlawItemState = 2
                if job.Type == "OUTLAW_ITEM_UNK" then
                    GAME:WaitFrames(50)
                    UI:ResetSpeaker()
                    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.OUTLAW_ITEM_UNK_RETRIEVED):ToLocal(), outlawName, item_name))
                else
                    GAME:WaitFrames(50)
                    UI:ResetSpeaker()
                    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.OUTLAW_ITEM_RETRIEVED):ToLocal(), outlawName, item_name))
                end
            end
        end
        if self.root.mission_flags.OutlawItemState == 1 and self.root.mission_flags.ItemPickedUp then     --outlaw already defeated, item taken now
            complete_job(globals.keysEx.OUTLAW_ITEM_RETRIEVED)
        elseif self.root.mission_flags.OutlawItemState == 2 and self.root.mission_flags.OutlawDefeated then     --item already taken, outlaw defeated now
            complete_job(globals.keysEx.OUTLAW_DEFEATED)
        end
    end
end

--- Meant to be called in ``SINGLE_CHAR_SCRIPT.ExplorationReached``. It implements the entire ExplorationReached event used by the library.
--- It is called on floor start during an EXPLORATION job. The guest will thank the party and leave, and then the player will be prompted to leave as well.
--- Please pass all of the event's parameters to this function, in order.
function library:ExplorationReached(_, _, context, args)
    if context.User ~= nil then
        return
    end
    local jobIndex = args.JobReference
    local job = self.root.taken[jobIndex]
    local escort
    for i = 0, _DATA.Save.ActiveTeam.Guests.Count - 1, 1 do
        local guest = GAME:GetPlayerGuestMember(i)
        if guest.LuaData and guest.LuaData.JobReference == jobIndex then
            escort = guest
            break
        end
    end
    PrintInfo("Exploration reached at index " .. jobIndex .. " !")
    if escort and not escort.Dead then
        local curr_zone = _ZONE.CurrentZoneID
        local curr_segment = _ZONE.CurrentMapID.Segment

        local escortName = escort:GetDisplayName(true)
        local dungeon_name = self:GetSegmentName(curr_zone, curr_segment)
        UI:ResetSpeaker()
        self.root.mission_flags.MissionCompleted = true
        self:MarkJobCompleted(job)
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.EXPLORATION_REACHED):ToLocal(), escortName, dungeon_name))
        self.root.mission_flags.PriorMapSetting = _DUNGEON.ShowMap
        _DUNGEON.ShowMap = _DUNGEON.MinimapState.None
        GAME:WaitFrames(20)
        UI:SetSpeaker(escort)
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.EXPLORATION_THANKS):ToLocal(), dungeon_name))
        GAME:WaitFrames(20)
        UI:ResetSpeaker()
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.EXPLORATION_DEPART):ToLocal(), escortName, dungeon_name))
        GAME:WaitFrames(20)

        -- warp out
        TASK:WaitTask(_DUNGEON:ProcessBattleFX(escort, escort, _DATA.SendHomeFX))
        _DUNGEON:RemoveChar(escort)
        _ZONE.CurrentMap.DisplacedChars:Remove(escort)
        self.root.escort_jobs = self.root.escort_jobs-1
        RogueEssence.Dungeon.ExplorerTeam.MAX_TEAM_SLOTS = math.max(1, self.data.min_party_limit, self.root.previous_limit - self.root.escort_jobs)

        GAME:WaitFrames(50)
        self:AskMissionWarpOut()
    else
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.ESCORT_UNAVAILABLE):ToLocal(), self:GetCharacterName(job.Client)))
    end
end

--- Meant to be called in ``SINGLE_CHAR_SCRIPT.MissionItemCheck``. It implements the entire MissionItemCheck event used by the library.
--- It is called on turn end during a LOST_ITEM job, and checks if item has been retrieved.
--- When it is, this function will display a message, and then the player will be prompted to leave.
--- Please pass all of the event's parameters to this function, in order.
function library:MissionItemCheck(_, _, _, args)
    if not self.root.mission_flags.ItemPickedUp then
        local jobIndex = args.JobReference
        local job = self.root.taken[jobIndex]
        local itemFound = function()
            self:MarkJobCompleted(job)
            self.root.mission_flags.ItemPickedUp = true
            self.root.mission_flags.MissionCompleted = true
            GAME:WaitFrames(70)
            UI:ResetSpeaker()
            UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.LOST_ITEM_RETRIEVED):ToLocal(), self:GetCharacterName(job.Client), self:GetItemName(job.Item)))
            --Clear but remember minimap state
            self.root.mission_flags.PriorMapSetting = _DUNGEON.ShowMap
            _DUNGEON.ShowMap = _DUNGEON.MinimapState.None

            --Slight pause before asking to warp out
            GAME:WaitFrames(20)
            self:AskMissionWarpOut()
        end

        for i = 0, GAME:GetPlayerBagCount()-1, 1 do
            local invItem = GAME:GetPlayerBagItem(i)
            if invItem.ID == job.Item and invItem.HiddenValue == tostring(jobIndex) then
                itemFound()
                break
            end
        end
        if not self.root.mission_flags.ItemPickedUp then
            for i = 0, GAME:GetPlayerPartyCount()-1, 1 do
                local equipItem = GAME:GetPlayerEquippedItem(i)
                if equipItem and equipItem.ID == job.Item and equipItem.HiddenValue == tostring(jobIndex) then
                    itemFound()
                    break
                end
            end
        end
    end
end

--- Meant to be called in ``SINGLE_CHAR_SCRIPT.MissionGuestCheck``. It implements the entire MissionGuestCheck event used by the library.
--- It is called on turn end during a LOST_ITEM job. It checks if the requested item is in the player's inventory, and, if it is,
--- the player will be prompted to leave.
--- Please pass all of the event's parameters to this function, in order.
function library:MissionGuestCheck(_, _, context, _)
    if not context.User.Dead then
        return
    end
    local tbl = context.User.LuaData
    if tbl and tbl.JobReference then
        local targetName = context.User:GetDisplayName(true)
        UI:ResetSpeaker()
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(globals.keysEx.ESCORT_FAINTED):ToLocal(), targetName))
        GAME:WaitFrames(40)
        self.root.escort_jobs = self.root.escort_jobs-1
        RogueEssence.Dungeon.ExplorerTeam.MAX_TEAM_SLOTS = math.max(1, self.data.min_party_limit, self.root.previous_limit - self.root.escort_jobs)

        if self.data.losing_guests_means_defeat then
            warpOut()
            GAME:WaitFrames(80)
            TASK:WaitTask(_GAME:EndSegment(RogueEssence.Data.GameProgress.ResultType.Failed))
        end
    end
end

--- Meant to be called in ``SINGLE_CHAR_SCRIPT.MobilityEndTurn``. It implements the entire MobilityEndTurn event used by the library.
--- It is called on turn end during any job that has an Ally character somehwere on the floor. It constantly resets the character's movement
--- capabilities, ensuring it is always set to only walk on solid ground.
--- Please pass all of the event's parameters to this function, in order.
function library:MobilityEndTurn(_, _, _, _)
    for char in luanet.each(LUA_ENGINE:MakeList(_ZONE.CurrentMap:IterateCharacters(true, false))) do
        if char.MemberTeam ~= _DATA.Save.ActiveTeam and char.LuaData and char.LuaData.JobReference and self.root.taken[char.LuaData.JobReference].Completion == globals.completion.NotCompleted then
            char.Mobility = RogueEssence.Data.TerrainData.Mobility.Passable
        end
    end
end

return library
