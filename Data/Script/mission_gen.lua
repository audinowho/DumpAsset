require 'common'

--Halcyon Custom work ported to PMDO Vanilla:
--Code in this folder is used to generate, display, and handle randomized missions
--and all that goes with that (rewards, rankups, etc)


--A job is saved as a list of variables, where each variable represents an attribute of the job, such as reward, client, destination floor, etc.
--There are 3 sets of lua lists then. One for the missions taken, one for the missions on the job board, and one for the missions on the outlaw board.
--Each of those lists can only have up to 8 jobs.

--List of mission attributes:
--Client (the pokemon in need of escort, rescue, or the person asking for an outlaw capture). Given as species string
--Target (Pokemon in need of rescue, or the one to escort to, or the mon to be arrested). Given as species string
--Escort Species - should be given as a blank if this is not an escort mission.
--Zone (dungeon)
--Segment (part of the dungeon) - this is typically the default segment
--Floor 
--Reward - given as item name's string. If money, should be given as "Money" and the amount will be based off the difficulty.
--Mission Type - outlaw, escort, or rescue
--Completion status - Incomplete or Complete. When a reward is handed out at the end of the day, any missions that are completed should be removed from the taken board.
--Taken - Was the mission on the board taken? This is also used to suspend missions that were taken off the board
--Difficulty - Letter rank that are hardcoded to represent certain number amounts
--Flavor - Flavor text for the mission, should be a string in strings.resx that can potentially be filled in by blanks.

--Hardcoded number values. Adjust those sorts of things here.
--Difficulty's point ranks
MISSION_GEN = {}

--MISSION_GEN.DUNGEON_LIST = {'tropical_path', 'faultline_ridge', 'tiny_tunnel', 'guildmaster_trail',
--							'lava_floe_island', 'castaway_cave', 'eon_island', 'lost_seas', 'inscribed_cave', 'prism_isles',
--							'faded_trail', 'bramble_woods', 'trickster_woods', 'overgrown_wilds', 'moonlit_courtyard', 'ambush_forest', 'energy_garden', 'sickly_hollow', 'secret_garden',
--							'flyaway_cliffs', 'fertile_valley', 'wayward_wetlands', 'deserted_fortress', 'bravery_road', 'geode_underpass', 'the_sky',
--							'copper_quarry', 'forsaken_desert', 'relic_tower', 'sleeping_caldera', 'royal_halls', 'starfall_heights', 'wisdom_road', 'sacred_tower',
--							'thunderstruck_pass', 'veiled_ridge', 'snowbound_path', 'treacherous_mountain', 'hope_road', 'cave_of_whispers',
--							'champions_road', 'barren_tundra', 'cave_of_solace', 'labyrinth_of_the_lost'}

--UPDATE HERE when a new dungeon gets added- note, you MUST always have a [0] for the default difficulty
--REMOVE FROM HERE if you do not want a dungeon to appear in mission gen anymore
MISSION_GEN.DUNGEON_LIST = {}
MISSION_GEN.DUNGEON_LIST["tropical_path"] = { [0] = "F" } --Tropical Path
MISSION_GEN.DUNGEON_LIST["faultline_ridge"] = { [0] = "D" } --Faultline Ridge
MISSION_GEN.DUNGEON_LIST["guildmaster_trail"] = { [0] = "STAR_2" } --Guildmaster Trail
MISSION_GEN.DUNGEON_LIST["lava_floe_island"] = { [0] = "C", [1] = "STAR_1" } --Lava Floe Island, Abyssal Island
MISSION_GEN.DUNGEON_LIST["castaway_cave"] = { [0] = "B" } --Castaway Cave
MISSION_GEN.DUNGEON_LIST["faded_trail"] = { [0] = "E", [1] = "D" } --Faded Trail, Hidden Trail
MISSION_GEN.DUNGEON_LIST["bramble_woods"] = { [0] = "E", [1] = "D" } --Bramble Woods, Bramble Thicket
MISSION_GEN.DUNGEON_LIST["trickster_woods"] = { [0] = "C", [1] = "B" } --Trickster Woods, Trickster Maze
MISSION_GEN.DUNGEON_LIST["overgrown_wilds"] = { [0] = "C", [1] = "B" } --Overgrown Wilds, Exotic Wilds
MISSION_GEN.DUNGEON_LIST["moonlit_courtyard"] = { [0] = "C", [1] = "A" } --Moonlit Courtyard, Moonlit Temple
MISSION_GEN.DUNGEON_LIST["ambush_forest"] = { [0] = "B" } --Ambush Forest
MISSION_GEN.DUNGEON_LIST["sickly_hollow"] = { [0] = "S" } --Sickly Hollow
MISSION_GEN.DUNGEON_LIST["secret_garden"] = { [0] = "STAR_3" } --Secret Garden
MISSION_GEN.DUNGEON_LIST["flyaway_cliffs"] = { [0] = "C" } --Flyaway Cliffs
MISSION_GEN.DUNGEON_LIST["fertile_valley"] = { [0] = "D", [1] = "C" } --Fertile Valley, Muddy Valley
MISSION_GEN.DUNGEON_LIST["copper_quarry"] = { [0] = "C", [1] = "B" } --Copper Quarry, Lodestone Quarry
MISSION_GEN.DUNGEON_LIST["forsaken_desert"] = { [0] = "A" } --Forsaken Desert
MISSION_GEN.DUNGEON_LIST["relic_tower"] = { [0] = "S" } --Relic Tower
MISSION_GEN.DUNGEON_LIST["sleeping_caldera"] = { [0] = "B" } --Sleeping Caldera
MISSION_GEN.DUNGEON_LIST["thunderstruck_pass"] = { [0] = "B" } --Thunderstruck Pass
MISSION_GEN.DUNGEON_LIST["veiled_ridge"] = { [0] = "B", [1] = "A" } --Veiled Ridge, Illusion Ridge
MISSION_GEN.DUNGEON_LIST["snowbound_path"] = { [0] = "A", [1] = "S" } --Snowbound Path, Glacial Path
MISSION_GEN.DUNGEON_LIST["treacherous_mountain"] = { [0] = "A" } --Treacherous Mountain
MISSION_GEN.DUNGEON_LIST["champions_road"] = { [0] = "S" } --Champion's Road (Clouded Road is not eligible for missions)


--This is mainly used for EXP rewards in base PMDO
MISSION_GEN.DIFFICULTY = {}
MISSION_GEN.DIFFICULTY[""] = 0
MISSION_GEN.DIFFICULTY["F"] = 100 --below lv 10 dungeons generally
MISSION_GEN.DIFFICULTY["E"] = 200 --lv 10-14 dungeons
MISSION_GEN.DIFFICULTY["D"] = 400 --lv 15-20 dungeons
MISSION_GEN.DIFFICULTY["C"] = 800 --lv 21-29 dungeons
MISSION_GEN.DIFFICULTY["B"] = 1250 --lv 30-39 dungeons
MISSION_GEN.DIFFICULTY["A"] = 2500 --lv 40-49 dungeons
MISSION_GEN.DIFFICULTY["S"] = 5000 --lv 50-59 dungeons
MISSION_GEN.DIFFICULTY["STAR_1"] = 10000 --lv 60+ dungeons
MISSION_GEN.DIFFICULTY["STAR_2"] = 20000 --reserved for challenge dungeons
MISSION_GEN.DIFFICULTY["STAR_3"] = 30000 --reserved for challenge dungeons
MISSION_GEN.DIFFICULTY["STAR_4"] = 40000 --reserved for challenge dungeons
MISSION_GEN.DIFFICULTY["STAR_5"] = 50000 --reserved for challenge dungeons
MISSION_GEN.DIFFICULTY["STAR_6"] = 60000 --reserved for challenge dungeons
MISSION_GEN.DIFFICULTY["STAR_7"] = 70000 --reserved for challenge dungeons
MISSION_GEN.DIFFICULTY["STAR_8"] = 80000 --reserved for challenge dungeons
MISSION_GEN.DIFFICULTY["STAR_9"] = 90000 --reserved for challenge dungeons

--order of difficulties. 
MISSION_GEN.DIFF_TO_ORDER = {}
MISSION_GEN.DIFF_TO_ORDER[""] = 1
MISSION_GEN.DIFF_TO_ORDER["F"] = 2
MISSION_GEN.DIFF_TO_ORDER["E"] = 3
MISSION_GEN.DIFF_TO_ORDER["D"] = 4
MISSION_GEN.DIFF_TO_ORDER["C"] = 5
MISSION_GEN.DIFF_TO_ORDER["B"] = 6
MISSION_GEN.DIFF_TO_ORDER["A"] = 7
MISSION_GEN.DIFF_TO_ORDER["S"] = 8
MISSION_GEN.DIFF_TO_ORDER["STAR_1"] = 9
MISSION_GEN.DIFF_TO_ORDER["STAR_2"] = 10
MISSION_GEN.DIFF_TO_ORDER["STAR_3"] = 11
MISSION_GEN.DIFF_TO_ORDER["STAR_4"] = 12
MISSION_GEN.DIFF_TO_ORDER["STAR_5"] = 13
MISSION_GEN.DIFF_TO_ORDER["STAR_6"] = 14
MISSION_GEN.DIFF_TO_ORDER["STAR_7"] = 15
MISSION_GEN.DIFF_TO_ORDER["STAR_8"] = 16
MISSION_GEN.DIFF_TO_ORDER["STAR_9"] = 17

--use this to get back from above.
MISSION_GEN.ORDER_TO_DIFF = {"", "F", "E", "D", "C", "B", "A", "S", "STAR_1","STAR_2","STAR_3","STAR_4","STAR_5","STAR_6","STAR_7","STAR_8","STAR_9"}

--mapping of difficulty to reward amounts for money
MISSION_GEN.DIFF_TO_MONEY = {}
MISSION_GEN.DIFF_TO_MONEY[""] = 0
MISSION_GEN.DIFF_TO_MONEY["F"] = 100
MISSION_GEN.DIFF_TO_MONEY["E"] = 200
MISSION_GEN.DIFF_TO_MONEY["D"] = 400
MISSION_GEN.DIFF_TO_MONEY["C"] = 600
MISSION_GEN.DIFF_TO_MONEY["B"] = 800
MISSION_GEN.DIFF_TO_MONEY["A"] = 1500
MISSION_GEN.DIFF_TO_MONEY["S"] = 3000
MISSION_GEN.DIFF_TO_MONEY["STAR_1"] = 6000
MISSION_GEN.DIFF_TO_MONEY["STAR_2"] = 10000
MISSION_GEN.DIFF_TO_MONEY["STAR_3"] = 15000
MISSION_GEN.DIFF_TO_MONEY["STAR_4"] = 20000
MISSION_GEN.DIFF_TO_MONEY["STAR_5"] = 25000
MISSION_GEN.DIFF_TO_MONEY["STAR_6"] = 30000
MISSION_GEN.DIFF_TO_MONEY["STAR_7"] = 35000
MISSION_GEN.DIFF_TO_MONEY["STAR_8"] = 40000
MISSION_GEN.DIFF_TO_MONEY["STAR_9"] = 45000

--color coding for mission difficulty letters
MISSION_GEN.DIFF_TO_COLOR = {}
MISSION_GEN.DIFF_TO_COLOR[""] = "[color=#000000]"
MISSION_GEN.DIFF_TO_COLOR["F"] = "[color=#A1A1A1]"
MISSION_GEN.DIFF_TO_COLOR["E"] = "[color=#F8F8F8]"
MISSION_GEN.DIFF_TO_COLOR["D"] = "[color=#F8C8C8]"
MISSION_GEN.DIFF_TO_COLOR["C"] = "[color=#40F840]"
MISSION_GEN.DIFF_TO_COLOR["B"] = "[color=#F8C060]"
MISSION_GEN.DIFF_TO_COLOR["A"] = "[color=#00F8F8]"
MISSION_GEN.DIFF_TO_COLOR["S"] = "[color=#F80000]"
MISSION_GEN.DIFF_TO_COLOR["STAR_1"] = "[color=#F8F800]"
MISSION_GEN.DIFF_TO_COLOR["STAR_2"] = "[color=#F8F800]"
MISSION_GEN.DIFF_TO_COLOR["STAR_3"] = "[color=#F8F800]"
MISSION_GEN.DIFF_TO_COLOR["STAR_4"] = "[color=#F8F800]"
MISSION_GEN.DIFF_TO_COLOR["STAR_5"] = "[color=#F8F800]"
MISSION_GEN.DIFF_TO_COLOR["STAR_6"] = "[color=#F8F800]"
MISSION_GEN.DIFF_TO_COLOR["STAR_7"] = "[color=#F8F800]"
MISSION_GEN.DIFF_TO_COLOR["STAR_8"] = "[color=#F8F800]"
MISSION_GEN.DIFF_TO_COLOR["STAR_9"] = "[color=#F8F800]"



MISSION_GEN.COMPLETE = 1
MISSION_GEN.INCOMPLETE = 0

SV.ExpectedLevel = {}


MISSION_GEN.TITLES =  {
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
	RESCUE_FRIEND =	{
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
}

MISSION_GEN.FLAVOR_TOP =  {
	RESCUE_SELF = {
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
	RESCUE_FRIEND =	{
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
	ESCORT = {
		"MISSION_BODY_TOP_ESCORT_001",
		"MISSION_BODY_TOP_ESCORT_002",
		"MISSION_BODY_TOP_ESCORT_003",
		"MISSION_BODY_TOP_ESCORT_004",
		"MISSION_BODY_TOP_ESCORT_005"
	},
	EXPLORATION = {
		"MISSION_BODY_TOP_EXPLORATION_001",
		"MISSION_BODY_TOP_EXPLORATION_002",
		"MISSION_BODY_TOP_EXPLORATION_003",
		"MISSION_BODY_TOP_EXPLORATION_004",
		"MISSION_BODY_TOP_EXPLORATION_005"
	},
	DELIVERY = {
		"MISSION_BODY_TOP_DELIVERY_001",
		"MISSION_BODY_TOP_DELIVERY_002",
		"MISSION_BODY_TOP_DELIVERY_003",
		"MISSION_BODY_TOP_DELIVERY_004",
		"MISSION_BODY_TOP_DELIVERY_005"
	},	
	LOST_ITEM = {
		"MISSION_BODY_TOP_LOST_ITEM_001",
		"MISSION_BODY_TOP_LOST_ITEM_002",
		"MISSION_BODY_TOP_LOST_ITEM_003",
		"MISSION_BODY_TOP_LOST_ITEM_004",
		"MISSION_BODY_TOP_LOST_ITEM_005"
	},
	OUTLAW = {
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
	OUTLAW_ITEM = {
		"MISSION_BODY_TOP_OUTLAW_ITEM_001",
		"MISSION_BODY_TOP_OUTLAW_ITEM_002",
		"MISSION_BODY_TOP_OUTLAW_ITEM_003",
		"MISSION_BODY_TOP_OUTLAW_ITEM_004",
		"MISSION_BODY_TOP_OUTLAW_ITEM_005"
	},	
	OUTLAW_MONSTER_HOUSE = {
		"MISSION_BODY_TOP_OUTLAW_MONSTER_HOUSE_001",
		"MISSION_BODY_TOP_OUTLAW_MONSTER_HOUSE_002",
		"MISSION_BODY_TOP_OUTLAW_MONSTER_HOUSE_003",
		"MISSION_BODY_TOP_OUTLAW_MONSTER_HOUSE_004",
		"MISSION_BODY_TOP_OUTLAW_MONSTER_HOUSE_005"
	},	
	OUTLAW_FLEE = {
		"MISSION_BODY_TOP_OUTLAW_FLEE_001",
		"MISSION_BODY_TOP_OUTLAW_FLEE_002",
		"MISSION_BODY_TOP_OUTLAW_FLEE_003",
		"MISSION_BODY_TOP_OUTLAW_FLEE_004",
		"MISSION_BODY_TOP_OUTLAW_FLEE_005"
	}
}

MISSION_GEN.FLAVOR_BOTTOM =  {
	RESCUE_SELF = {
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
	},
	RESCUE_FRIEND =	{
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
	},
	ESCORT = {
		"MISSION_BODY_BOTTOM_ESCORT_001",
		"MISSION_BODY_BOTTOM_ESCORT_002",
		"MISSION_BODY_BOTTOM_ESCORT_003",
		"MISSION_BODY_BOTTOM_ESCORT_004",
		"MISSION_BODY_BOTTOM_ESCORT_005"
	},
	EXPLORATION = {
		"MISSION_BODY_BOTTOM_EXPLORATION_001",
		"MISSION_BODY_BOTTOM_EXPLORATION_002",
		"MISSION_BODY_BOTTOM_EXPLORATION_003",
		"MISSION_BODY_BOTTOM_EXPLORATION_004",
		"MISSION_BODY_BOTTOM_EXPLORATION_005"
	},
	DELIVERY = {
		"MISSION_BODY_BOTTOM_DELIVERY_001",
		"MISSION_BODY_BOTTOM_DELIVERY_002",
		"MISSION_BODY_BOTTOM_DELIVERY_003",
		"MISSION_BODY_BOTTOM_DELIVERY_004",
		"MISSION_BODY_BOTTOM_DELIVERY_005"
	},	
	LOST_ITEM = {
		"MISSION_BODY_BOTTOM_LOST_ITEM_001",
		"MISSION_BODY_BOTTOM_LOST_ITEM_002",
		"MISSION_BODY_BOTTOM_LOST_ITEM_003",
		"MISSION_BODY_BOTTOM_LOST_ITEM_004",
		"MISSION_BODY_BOTTOM_LOST_ITEM_005"
	},
	OUTLAW = {
		"MISSION_BODY_BOTTOM_OUTLAW_001",
		"MISSION_BODY_BOTTOM_OUTLAW_002",
		"MISSION_BODY_BOTTOM_OUTLAW_003",
		"MISSION_BODY_BOTTOM_OUTLAW_004",
		"MISSION_BODY_BOTTOM_OUTLAW_005"
	},
	OUTLAW_ITEM = {
		"MISSION_BODY_BOTTOM_OUTLAW_ITEM_001",
		"MISSION_BODY_BOTTOM_OUTLAW_ITEM_002",
		"MISSION_BODY_BOTTOM_OUTLAW_ITEM_003",
		"MISSION_BODY_BOTTOM_OUTLAW_ITEM_004",
		"MISSION_BODY_BOTTOM_OUTLAW_ITEM_005"
	},	
	OUTLAW_MONSTER_HOUSE = {
		"MISSION_BODY_BOTTOM_OUTLAW_MONSTER_HOUSE_001",
		"MISSION_BODY_BOTTOM_OUTLAW_MONSTER_HOUSE_002",
		"MISSION_BODY_BOTTOM_OUTLAW_MONSTER_HOUSE_003",
		"MISSION_BODY_BOTTOM_OUTLAW_MONSTER_HOUSE_004",
		"MISSION_BODY_BOTTOM_OUTLAW_MONSTER_HOUSE_005"
	},	
	OUTLAW_FLEE = {
		"MISSION_BODY_BOTTOM_OUTLAW_FLEE_001",
		"MISSION_BODY_BOTTOM_OUTLAW_FLEE_002",
		"MISSION_BODY_BOTTOM_OUTLAW_FLEE_003",
		"MISSION_BODY_BOTTOM_OUTLAW_FLEE_004",
		"MISSION_BODY_BOTTOM_OUTLAW_FLEE_005"
	}
}

MISSION_GEN.POKEMON = {
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
	"natu","nickit","nidoran_m","nidoran_f","nincada","noibat","nosepass","numel","nymble",
	"oddish","omanyte","onix","oshawott",
 	"pansear","paras","patrat","pawmi","pawniard","petilil","phantump","pidgey","pidove","pineco","piplup","poliwag","ponyta","poochyena","popplio","porygon","psyduck","pumpkaboo","purrloin",
	"quaxly",
	"ralts","rattata","remoraid","rhyhorn","roggenrola","rowlet",
	"salandit","sandile","sandshrew","sandygast","scraggy","seedot","seel","sentret","sewaddle","shellder","shellos","shieldon","shinx","shroomish","shuppet","silcoon","sinistea","skorupi","slakoth","slowpoke","slugma","smoochum","sneasel","snivy","snom","snorunt","snover","snubbull","sobble","solosis","spearow","spheal","spinarak","spoink","sprigatito","spritzee","squirtle","starly","staryu","stufful","stunky","sunkern","surskit","swablu","swinub","swirlix",
	"taillow","tandemaus","teddiursa","tentacool","tepig","tinkatink","torchic","togepi","totodile","trapinch","treecko","trubbish","turtwig","tympole","tyrogue",

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
}

--weighting of possible client/target pokemon based on difficulty of mission
MISSION_GEN.DIFF_POKEMON = {
	F = {
		{"TIER_LOW", 10},
		{"TIER_MID", 0},
		{"TIER_HIGH", 0}
	},
	E = {
		{"TIER_LOW", 9},
		{"TIER_MID", 1},
		{"TIER_HIGH", 0}
		},
	D = {
		{"TIER_LOW", 7},
		{"TIER_MID", 3},
		{"TIER_HIGH", 0}
		},
	C = {
		{"TIER_LOW", 6},
		{"TIER_MID", 4},
		{"TIER_HIGH", 0}
		},
	B = {
		{"TIER_LOW", 2},
		{"TIER_MID", 6},
		{"TIER_HIGH", 2}
		},
	A = {
		{"TIER_LOW", 1},
		{"TIER_MID", 5},
		{"TIER_HIGH", 4}
		},
	S = {
		{"TIER_LOW", 0},
		{"TIER_MID", 5},
		{"TIER_HIGH", 5}
		},
	STAR_1 = {
		{"TIER_LOW", 0},
		{"TIER_MID", 3},
		{"TIER_HIGH", 7}
		},
	STAR_2 = {
		{"TIER_LOW", 0},
		{"TIER_MID", 1},
		{"TIER_HIGH", 9}
		},
	STAR_3 = {
		{"TIER_LOW", 0},
		{"TIER_MID", 0},
		{"TIER_HIGH", 10}
		},
	STAR_3 = {
		{"TIER_LOW", 0},
		{"TIER_MID", 0},
		{"TIER_HIGH", 10}
	},
	STAR_4 = {
		{"TIER_LOW", 0},
		{"TIER_MID", 0},
		{"TIER_HIGH", 10}
	},
	STAR_5 = {
		{"TIER_LOW", 0},
		{"TIER_MID", 0},
		{"TIER_HIGH", 10}
	},
	STAR_6 = {
		{"TIER_LOW", 0},
		{"TIER_MID", 0},
		{"TIER_HIGH", 10}
	},
	STAR_7 = {
		{"TIER_LOW", 0},
		{"TIER_MID", 0},
		{"TIER_HIGH", 10}
	},
	STAR_8 = {
		{"TIER_LOW", 0},
		{"TIER_MID", 0},
		{"TIER_HIGH", 10}
	},
	STAR_9 = {
		{"TIER_LOW", 0},
		{"TIER_MID", 0},
		{"TIER_HIGH", 10}
	}
}

--weighting of each loot table based on difficulty of mission

MISSION_GEN.DIFF_REWARDS = {
	F = {
		{"NECESSITIES", 10}, --Basic stuff (i.e. reviver seeds, escape orbs, leppa berries) *
		{"AMMO_LOW", 0},
		{"AMMO_MID", 0},
		{"AMMO_HIGH", 0},
		{"APRICORN_GENERIC", 0},
		{"APRICORN_TYPED", 0},
		{"FOOD_LOW", 0},
		{"FOOD_MID", 0},
		{"FOOD_HIGH", 0},
		{"MEDICINE_LOW", 0},
		{"MEDICINE_HIGH", 0},
		{"SEED_LOW", 0},
		{"SEED_MID", 0},
		{"SEED_HIGH", 0},
		{"HELD_LOW", 0},
		{"HELD_MID", 0},
		{"HELD_HIGH", 0},
		{"HELD_TYPE", 0},
		{"HELD_PLATES", 0},
		{"LOOT_LOW", 0},
		{"LOOT_HIGH", 0},
		{"EVO_ITEMS", 0},
		{"ORBS_LOW", 0},
		{"ORBS_MID", 0},
		{"ORBS_HIGH", 0},
		{"WANDS_LOW", 0},
		{"WANDS_MID", 0},
		{"WANDS_HIGH", 0},
		{"TM_LOW", 0},
		{"TM_MID", 0},
		{"TM_HIGH", 0},
		{"SPECIAL", 0}
	},
	E = {
		{"NECESSITIES", 10},  --Basic stuff (i.e. reviver seeds, escape orbs, leppa berries) *
		{"AMMO_LOW", 0},
		{"AMMO_MID", 0},
		{"AMMO_HIGH", 0},
		{"APRICORN_GENERIC", 10}, --Generic (non-typed) apricorns with a max catch bonus below 35 *
		{"APRICORN_TYPED", 0},
		{"FOOD_LOW", 10}, --Basic food, small chance of gummis *
		{"FOOD_MID", 0},
		{"FOOD_HIGH", 0},
		{"MEDICINE_LOW", 0},
		{"MEDICINE_HIGH", 0},
		{"SEED_LOW", 10}, --Basic seeds, berries, white herbs *
		{"SEED_MID", 0},
		{"SEED_HIGH", 0},
		{"HELD_LOW", 3}, --Basic stat boosting held items and ones with a net drawback (Iron Ball, Flame Orb, etc.)
		{"HELD_MID", 0},
		{"HELD_HIGH", 0},
		{"HELD_TYPE", 0},
		{"HELD_PLATES", 0},
		{"LOOT_LOW", 3}, --Keys, pearls, assembly boxes
		{"LOOT_HIGH", 0},
		{"EVO_ITEMS", 1}, --Evolution items, high chance of link cables
		{"ORBS_LOW", 0},
		{"ORBS_MID", 0},
		{"ORBS_HIGH", 0},
		{"WANDS_LOW", 10}, --Weak wands *
		{"WANDS_MID", 0},
		{"WANDS_HIGH", 0},
		{"TM_LOW", 0},
		{"TM_MID", 0},
		{"TM_HIGH", 0},
		{"SPECIAL", 0}
	},
	D = {
		{"NECESSITIES", 5},  --Basic stuff (i.e. reviver seeds, escape orbs, leppa berries)
		{"AMMO_LOW", 10}, --Mostly iron thorns, with some weaker ammo *
		{"AMMO_MID", 0},
		{"AMMO_HIGH", 0},
		{"APRICORN_GENERIC", 10}, --Generic (non-typed) apricorns with a max catch bonus below 35 *
		{"APRICORN_TYPED", 2}, --Type and glitter apricorns
		{"FOOD_LOW", 4}, --Basic food, small chance of gummis
		{"FOOD_MID", 0},
		{"FOOD_HIGH", 0},
		{"MEDICINE_LOW", 0},
		{"MEDICINE_HIGH", 0},
		{"SEED_LOW", 4}, --Basic seeds, berries, white herbs
		{"SEED_MID", 10}, --Advanced seeds and type berries *
		{"SEED_HIGH", 0},
		{"HELD_LOW", 10}, --Basic stat boosting held items and ones with a net drawback (Iron Ball, Flame Orb, etc.) *
		{"HELD_MID", 0},
		{"HELD_HIGH", 0},
		{"HELD_TYPE", 3}, --Held items that boost a specific type
		{"HELD_PLATES", 0},
		{"LOOT_LOW", 10}, --Keys, pearls, assembly boxes *
		{"LOOT_HIGH", 0},
		{"EVO_ITEMS", 2}, --Evolution items, high chance of link cables
		{"ORBS_LOW", 2}, --Weak wonder orbs
		{"ORBS_MID", 0},
		{"ORBS_HIGH", 0},
		{"WANDS_LOW", 4}, --Weak wands
		{"WANDS_MID", 10}, --Medium wands *
		{"WANDS_HIGH", 0},
		{"TM_LOW", 0},
		{"TM_MID", 0},
		{"TM_HIGH", 0},
		{"SPECIAL", 0}
	},
	C = {
		{"NECESSITIES", 4},  --Basic stuff (i.e. reviver seeds, escape orbs, leppa berries)
		{"AMMO_LOW", 4}, --Mostly iron thorns, with some weaker ammo 
		{"AMMO_MID", 2}, --Stronger generic ammo that you find in most dungeons
		{"AMMO_HIGH", 0},
		{"APRICORN_GENERIC", 4}, --Generic (non-typed) apricorns with a max catch bonus below 35 
		{"APRICORN_TYPED", 10}, --Type and glitter apricorns *
		{"FOOD_LOW", 4}, --Basic food, small chance of gummis
		{"FOOD_MID", 10}, --Big food, medium chance of gummis *
		{"FOOD_HIGH", 0},
		{"MEDICINE_LOW", 0},
		{"MEDICINE_HIGH", 0},
		{"SEED_LOW", 4}, --Basic seeds, berries, white herbs
		{"SEED_MID", 4}, --Advanced seeds and type berries 
		{"SEED_HIGH", 0},
		{"HELD_LOW", 4}, --Basic stat boosting held items and ones with a net drawback (Iron Ball, Flame Orb, etc.) 
		{"HELD_MID", 0},
		{"HELD_HIGH", 0},
		{"HELD_TYPE", 3}, --Held items that boost a specific type
		{"HELD_PLATES", 10}, --Held items that reduce damage from a specific type *
		{"LOOT_LOW", 4}, --Keys, pearls, assembly boxes 
		{"LOOT_HIGH", 0},
		{"EVO_ITEMS", 4}, --Evolution items, high chance of link cables
		{"ORBS_LOW", 10}, --Weak wonder orbs *
		{"ORBS_MID", 2}, --Medium wonder orbs, many can shut down a monster house
		{"ORBS_HIGH", 0},
		{"WANDS_LOW", 4}, --Weak wands
		{"WANDS_MID", 4}, --Medium wands 
		{"WANDS_HIGH", 0},
		{"TM_LOW", 10}, --TMs for weak moves *
		{"TM_MID", 0},
		{"TM_HIGH", 0},
		{"SPECIAL", 0}
	},
	B = {
		{"NECESSITIES", 3},  --Basic stuff (i.e. reviver seeds, escape orbs, leppa berries)
		{"AMMO_LOW", 0},
		{"AMMO_MID", 10}, --Stronger generic ammo that you find in most dungeons *
		{"AMMO_HIGH", 2}, --Rare ammo that are hard to find in dungeons
		{"APRICORN_GENERIC", 0},
		{"APRICORN_TYPED", 10}, --Type and glitter apricorns *
		{"FOOD_LOW", 3}, --Basic food, small chance of gummis
		{"FOOD_MID", 5}, --Big food, medium chance of gummis
		{"FOOD_HIGH", 0},
		{"MEDICINE_LOW", 2}, --Weaker medicine that can't heal all PP or HP at once
		{"MEDICINE_HIGH", 0},
		{"SEED_LOW", 0},
		{"SEED_MID", 4}, --Advanced seeds and type berries 
		{"SEED_HIGH", 3}, --Includes rare seeds and berries, skews to Pure Seeds
		{"HELD_LOW", 3}, --Basic stat boosting held items and ones with a net drawback (Iron Ball, Flame Orb, etc.) 
		{"HELD_MID", 10}, --Held items very useful for a specific strategy *
		{"HELD_HIGH", 0},
		{"HELD_TYPE", 3}, --Held items that boost a specific type
		{"HELD_PLATES", 3}, --Held items that reduce damage from a specific type
		{"LOOT_LOW", 4}, --Keys, pearls, assembly boxes 
		{"LOOT_HIGH", 0},
		{"EVO_ITEMS", 5}, --Evolution items, high chance of link cables
		{"ORBS_LOW", 4}, --Weak wonder orbs 
		{"ORBS_MID", 10}, --Medium wonder orbs, many can shut down a monster house *
		{"ORBS_HIGH", 0},
		{"WANDS_LOW", 0},
		{"WANDS_MID", 3}, --Medium wands 
		{"WANDS_HIGH", 10}, --Rare, specialty wands *
		{"TM_LOW", 4}, --TMs for weak moves
		{"TM_MID", 2}, --TMs for moderate moves
		{"TM_HIGH", 0},
		{"SPECIAL", 0}
	},
	A = {
		{"NECESSITIES", 2},  --Basic stuff (i.e. reviver seeds, escape orbs, leppa berries)
		{"AMMO_LOW", 0},
		{"AMMO_MID", 3}, --Stronger generic ammo that you find in most dungeons
		{"AMMO_HIGH", 10}, --Rare ammo that are hard to find in dungeons *
		{"APRICORN_GENERIC", 0},
		{"APRICORN_TYPED", 10}, --Type and glitter apricorns *
		{"FOOD_LOW", 0},
		{"FOOD_MID", 4}, --Big food, medium chance of gummis
		{"FOOD_HIGH", 2}, --Huge food with a high chance of wonder gummis and a chance for vitamins
		{"MEDICINE_LOW", 10}, --Weaker medicine that can't heal all PP or HP at once *
		{"MEDICINE_HIGH", 0},
		{"SEED_LOW", 0},
		{"SEED_MID", 3}, --Advanced seeds and type berries 
		{"SEED_HIGH", 10}, --Includes rare seeds and berries, skews to Pure Seeds *
		{"HELD_LOW", 0},
		{"HELD_MID", 5}, --Held items very useful for a specific strategy 
		{"HELD_HIGH", 2}, --Held items useful for anyone
		{"HELD_TYPE", 3}, --Held items that boost a specific type
		{"HELD_PLATES", 3}, --Held items that reduce damage from a specific type
		{"LOOT_LOW", 3}, --Keys, pearls, assembly boxes 
		{"LOOT_HIGH", 10}, --Rare loot, skews towards heart scales *
		{"EVO_ITEMS", 10}, --Evolution items, high chance of link cables *
		{"ORBS_LOW", 0},
		{"ORBS_MID", 4}, --Medium wonder orbs, many can shut down a monster house
		{"ORBS_HIGH", 4}, --Rare, powerful wonder orbs often with map wide effects
		{"WANDS_LOW", 0},
		{"WANDS_MID", 2}, --Medium wands 
		{"WANDS_HIGH", 5}, --Rare, specialty wands
		{"TM_LOW", 2}, --TMs for weak moves
		{"TM_MID", 10}, --TMs for moderate moves *
		{"TM_HIGH", 0},
		{"SPECIAL", 0}
	},
	S = {
		{"NECESSITIES", 2},  --Basic stuff (i.e. reviver seeds, escape orbs, leppa berries)
		{"AMMO_LOW", 0},
		{"AMMO_MID", 2}, --Stronger generic ammo that you find in most dungeons
		{"AMMO_HIGH", 5}, --Rare ammo that are hard to find in dungeons
		{"APRICORN_GENERIC", 0},
		{"APRICORN_TYPED", 5}, --Type and glitter apricorns
		{"FOOD_LOW", 0},
		{"FOOD_MID", 2}, --Big food, medium chance of gummis
		{"FOOD_HIGH", 10}, --Huge food with a high chance of wonder gummis and a chance for vitamins *
		{"MEDICINE_LOW", 4}, --Weaker medicine that can't heal all PP or HP at once
		{"MEDICINE_HIGH", 10}, --Powerful medicine that can heal everything *
		{"SEED_LOW", 0},
		{"SEED_MID", 0},
		{"SEED_HIGH", 5}, --Includes rare seeds and berries, skews to Pure Seeds
		{"HELD_LOW", 0},
		{"HELD_MID", 3}, --Held items very useful for a specific strategy 
		{"HELD_HIGH", 10}, --Held items useful for anyone *
		{"HELD_TYPE", 3}, --Held items that boost a specific type
		{"HELD_PLATES", 3}, --Held items that reduce damage from a specific type
		{"LOOT_LOW", 2}, --Keys, pearls, assembly boxes 
		{"LOOT_HIGH", 10}, --Rare loot, skews towards heart scales *
		{"EVO_ITEMS", 10}, --Evolution items, high chance of link cables *
		{"ORBS_LOW", 0},
		{"ORBS_MID", 2}, --Medium wonder orbs, many can shut down a monster house
		{"ORBS_HIGH", 5}, --Rare, powerful wonder orbs often with map wide effects
		{"WANDS_LOW", 0},
		{"WANDS_MID", 2}, --Medium wands 
		{"WANDS_HIGH", 4}, --Rare, specialty wands
		{"TM_LOW", 0},
		{"TM_MID", 4}, --TMs for moderate moves
		{"TM_HIGH", 10}, --TMs for very powerful moves *
		{"SPECIAL", 0}
	},
	STAR_1 = {
		{"NECESSITIES", 0},
		{"AMMO_LOW", 0},
		{"AMMO_MID", 2}, --Stronger generic ammo that you find in most dungeons
		{"AMMO_HIGH", 5}, --Rare ammo that are hard to find in dungeons
		{"APRICORN_GENERIC", 0},
		{"APRICORN_TYPED", 5}, --Type and glitter apricorns
		{"FOOD_LOW", 0},
		{"FOOD_MID", 0},
		{"FOOD_HIGH", 5}, --Huge food with a high chance of wonder gummis and a chance for vitamins
		{"MEDICINE_LOW", 2}, --Weaker medicine that can't heal all PP or HP at once
		{"MEDICINE_HIGH", 5}, --Powerful medicine that can heal everything
		{"SEED_LOW", 0},
		{"SEED_MID", 0},
		{"SEED_HIGH", 2}, --Includes rare seeds and berries, skews to Pure Seeds
		{"HELD_LOW", 0},
		{"HELD_MID", 2}, --Held items very useful for a specific strategy 
		{"HELD_HIGH", 5}, --Held items useful for anyone
		{"HELD_TYPE", 0}, 
		{"HELD_PLATES", 0}, 
		{"LOOT_LOW", 2}, --Keys, pearls, assembly boxes 
		{"LOOT_HIGH", 5}, --Rare loot, skews towards heart scales
		{"EVO_ITEMS", 5}, --Evolution items, high chance of link cables
		{"ORBS_LOW", 0},
		{"ORBS_MID", 2}, --Medium wonder orbs, many can shut down a monster house
		{"ORBS_HIGH", 5}, --Rare, powerful wonder orbs often with map wide effects
		{"WANDS_LOW", 0},
		{"WANDS_MID", 0},
		{"WANDS_HIGH", 3}, --Rare, specialty wands
		{"TM_LOW", 0},
		{"TM_MID", 4}, --TMs for moderate moves
		{"TM_HIGH", 5}, --TMs for very powerful moves
		{"SPECIAL", 1} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
	},
	STAR_2 = {
		{"NECESSITIES", 0},
		{"AMMO_LOW", 0},
		{"AMMO_MID", 0}, 
		{"AMMO_HIGH", 5}, --Rare ammo that are hard to find in dungeons
		{"APRICORN_GENERIC", 0},
		{"APRICORN_TYPED", 0},
		{"FOOD_LOW", 0},
		{"FOOD_MID", 0},
		{"FOOD_HIGH", 5}, --Huge food with a high chance of wonder gummis and a chance for vitamins
		{"MEDICINE_LOW", 0}, 
		{"MEDICINE_HIGH", 5}, --Powerful medicine that can heal everything
		{"SEED_LOW", 0},
		{"SEED_MID", 0},
		{"SEED_HIGH", 0}, 
		{"HELD_LOW", 0},
		{"HELD_MID", 0}, 
		{"HELD_HIGH", 5}, --Held items useful for anyone
		{"HELD_TYPE", 0}, 
		{"HELD_PLATES", 0}, 
		{"LOOT_LOW", 0}, 
		{"LOOT_HIGH", 5}, --Rare loot, skews towards heart scales
		{"EVO_ITEMS", 5}, --Evolution items, high chance of link cables
		{"ORBS_LOW", 0},
		{"ORBS_MID", 0}, 
		{"ORBS_HIGH", 5}, --Rare, powerful wonder orbs often with map wide effects
		{"WANDS_LOW", 0},
		{"WANDS_MID", 0},
		{"WANDS_HIGH", 0}, 
		{"TM_LOW", 0},
		{"TM_MID", 2}, --TMs for moderate moves
		{"TM_HIGH", 5}, --TMs for very powerful moves
		{"SPECIAL", 2} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
	},
	STAR_3 = {
		{"NECESSITIES", 0},
		{"AMMO_LOW", 0},
		{"AMMO_MID", 0},
		{"AMMO_HIGH", 5}, --Rare ammo that are hard to find in dungeons
		{"APRICORN_GENERIC", 0},
		{"APRICORN_TYPED", 0},
		{"FOOD_LOW", 0},
		{"FOOD_MID", 0},
		{"FOOD_HIGH", 5}, --Huge food with a high chance of wonder gummis and a chance for vitamins
		{"MEDICINE_LOW", 0},
		{"MEDICINE_HIGH", 5}, --Powerful medicine that can heal everything
		{"SEED_LOW", 0},
		{"SEED_MID", 0},
		{"SEED_HIGH", 0},
		{"HELD_LOW", 0},
		{"HELD_MID", 0},
		{"HELD_HIGH", 5}, --Held items useful for anyone
		{"HELD_TYPE", 0},
		{"HELD_PLATES", 0},
		{"LOOT_LOW", 0},
		{"LOOT_HIGH", 5}, --Rare loot, skews towards heart scales
		{"EVO_ITEMS", 5}, --Evolution items, high chance of link cables
		{"ORBS_LOW", 0},
		{"ORBS_MID", 0},
		{"ORBS_HIGH", 0}, 
		{"WANDS_LOW", 0},
		{"WANDS_MID", 0},
		{"WANDS_HIGH", 0},
		{"TM_LOW", 0},
		{"TM_MID", 0}, 
		{"TM_HIGH", 5}, --TMs for very powerful moves
		{"SPECIAL", 3} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
	},
	STAR_4 = {
		{"NECESSITIES", 0},
		{"AMMO_LOW", 0},
		{"AMMO_MID", 0},
		{"AMMO_HIGH", 0},
		{"APRICORN_GENERIC", 0},
		{"APRICORN_TYPED", 0},
		{"FOOD_LOW", 0},
		{"FOOD_MID", 0},
		{"FOOD_HIGH", 5}, --Huge food with a high chance of wonder gummis and a chance for vitamins
		{"MEDICINE_LOW", 0},
		{"MEDICINE_HIGH", 0}, 
		{"SEED_LOW", 0},
		{"SEED_MID", 0},
		{"SEED_HIGH", 0},
		{"HELD_LOW", 0},
		{"HELD_MID", 0},
		{"HELD_HIGH", 5}, --Held items useful for anyone
		{"HELD_TYPE", 0},
		{"HELD_PLATES", 0},
		{"LOOT_LOW", 0},
		{"LOOT_HIGH", 5}, --Rare loot, skews towards heart scales
		{"EVO_ITEMS", 5}, --Evolution items, high chance of link cables
		{"ORBS_LOW", 0},
		{"ORBS_MID", 0},
		{"ORBS_HIGH", 0},
		{"WANDS_LOW", 0},
		{"WANDS_MID", 0},
		{"WANDS_HIGH", 0},
		{"TM_LOW", 0},
		{"TM_MID", 0},
		{"TM_HIGH", 5}, --TMs for very powerful moves
		{"SPECIAL", 4} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
	},
	STAR_5 = {
		{"NECESSITIES", 0},
		{"AMMO_LOW", 0},
		{"AMMO_MID", 0},
		{"AMMO_HIGH", 0},
		{"APRICORN_GENERIC", 0},
		{"APRICORN_TYPED", 0},
		{"FOOD_LOW", 0},
		{"FOOD_MID", 0},
		{"FOOD_HIGH", 5}, --Huge food with a high chance of wonder gummis and a chance for vitamins
		{"MEDICINE_LOW", 0},
		{"MEDICINE_HIGH", 0},
		{"SEED_LOW", 0},
		{"SEED_MID", 0},
		{"SEED_HIGH", 0},
		{"HELD_LOW", 0},
		{"HELD_MID", 0},
		{"HELD_HIGH", 0},
		{"HELD_TYPE", 0},
		{"HELD_PLATES", 0},
		{"LOOT_LOW", 0},
		{"LOOT_HIGH", 0},
		{"EVO_ITEMS", 0},
		{"ORBS_LOW", 0},
		{"ORBS_MID", 0},
		{"ORBS_HIGH", 0},
		{"WANDS_LOW", 0},
		{"WANDS_MID", 0},
		{"WANDS_HIGH", 0},
		{"TM_LOW", 0},
		{"TM_MID", 0},
		{"TM_HIGH", 5}, --TMs for very powerful moves
		{"SPECIAL", 5} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
	},
	STAR_6 = {
		{"NECESSITIES", 0},
		{"AMMO_LOW", 0},
		{"AMMO_MID", 0},
		{"AMMO_HIGH", 0},
		{"APRICORN_GENERIC", 0},
		{"APRICORN_TYPED", 0},
		{"FOOD_LOW", 0},
		{"FOOD_MID", 0},
		{"FOOD_HIGH", 4}, --Huge food with a high chance of wonder gummis and a chance for vitamins
		{"MEDICINE_LOW", 0},
		{"MEDICINE_HIGH", 0},
		{"SEED_LOW", 0},
		{"SEED_MID", 0},
		{"SEED_HIGH", 0},
		{"HELD_LOW", 0},
		{"HELD_MID", 0},
		{"HELD_HIGH", 0},
		{"HELD_TYPE", 0},
		{"HELD_PLATES", 0},
		{"LOOT_LOW", 0},
		{"LOOT_HIGH", 0},
		{"EVO_ITEMS", 0},
		{"ORBS_LOW", 0},
		{"ORBS_MID", 0},
		{"ORBS_HIGH", 0},
		{"WANDS_LOW", 0},
		{"WANDS_MID", 0},
		{"WANDS_HIGH", 0},
		{"TM_LOW", 0},
		{"TM_MID", 0},
		{"TM_HIGH", 4}, --TMs for very powerful moves
		{"SPECIAL", 6} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
	},
	STAR_7 = {
		{"NECESSITIES", 0},
		{"AMMO_LOW", 0},
		{"AMMO_MID", 0},
		{"AMMO_HIGH", 0},
		{"APRICORN_GENERIC", 0},
		{"APRICORN_TYPED", 0},
		{"FOOD_LOW", 0},
		{"FOOD_MID", 0},
		{"FOOD_HIGH", 3}, --Huge food with a high chance of wonder gummis and a chance for vitamins
		{"MEDICINE_LOW", 0},
		{"MEDICINE_HIGH", 0},
		{"SEED_LOW", 0},
		{"SEED_MID", 0},
		{"SEED_HIGH", 0},
		{"HELD_LOW", 0},
		{"HELD_MID", 0},
		{"HELD_HIGH", 0},
		{"HELD_TYPE", 0},
		{"HELD_PLATES", 0},
		{"LOOT_LOW", 0},
		{"LOOT_HIGH", 0},
		{"EVO_ITEMS", 0},
		{"ORBS_LOW", 0},
		{"ORBS_MID", 0},
		{"ORBS_HIGH", 0},
		{"WANDS_LOW", 0},
		{"WANDS_MID", 0},
		{"WANDS_HIGH", 0},
		{"TM_LOW", 0},
		{"TM_MID", 0},
		{"TM_HIGH", 3}, --TMs for very powerful moves
		{"SPECIAL", 7} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
	},
	STAR_8 = {
		{"NECESSITIES", 0},
		{"AMMO_LOW", 0},
		{"AMMO_MID", 0},
		{"AMMO_HIGH", 0},
		{"APRICORN_GENERIC", 0},
		{"APRICORN_TYPED", 0},
		{"FOOD_LOW", 0},
		{"FOOD_MID", 0},
		{"FOOD_HIGH", 0},
		{"MEDICINE_LOW", 0},
		{"MEDICINE_HIGH", 0},
		{"SEED_LOW", 0},
		{"SEED_MID", 0},
		{"SEED_HIGH", 0},
		{"HELD_LOW", 0},
		{"HELD_MID", 0},
		{"HELD_HIGH", 0},
		{"HELD_TYPE", 0},
		{"HELD_PLATES", 0},
		{"LOOT_LOW", 0},
		{"LOOT_HIGH", 0},
		{"EVO_ITEMS", 0},
		{"ORBS_LOW", 0},
		{"ORBS_MID", 0},
		{"ORBS_HIGH", 0},
		{"WANDS_LOW", 0},
		{"WANDS_MID", 0},
		{"WANDS_HIGH", 0},
		{"TM_LOW", 0},
		{"TM_MID", 0},
		{"TM_HIGH", 3}, --TMs for very powerful moves
		{"SPECIAL", 8} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
	},
	STAR_9 = {
		{"NECESSITIES", 0},
		{"AMMO_LOW", 0},
		{"AMMO_MID", 0},
		{"AMMO_HIGH", 0},
		{"APRICORN_GENERIC", 0},
		{"APRICORN_TYPED", 0},
		{"FOOD_LOW", 0},
		{"FOOD_MID", 0},
		{"FOOD_HIGH", 0},
		{"MEDICINE_LOW", 0},
		{"MEDICINE_HIGH", 0},
		{"SEED_LOW", 0},
		{"SEED_MID", 0},
		{"SEED_HIGH", 0},
		{"HELD_LOW", 0},
		{"HELD_MID", 0},
		{"HELD_HIGH", 0},
		{"HELD_TYPE", 0},
		{"HELD_PLATES", 0},
		{"LOOT_LOW", 0},
		{"LOOT_HIGH", 0},
		{"EVO_ITEMS", 0},
		{"ORBS_LOW", 0},
		{"ORBS_MID", 0},
		{"ORBS_HIGH", 0},
		{"WANDS_LOW", 0},
		{"WANDS_MID", 0},
		{"WANDS_HIGH", 0},
		{"TM_LOW", 0},
		{"TM_MID", 0},
		{"TM_HIGH", 0}, 
		{"SPECIAL", 9} --Very rare, powerful treasures (Amber Tears, Ability Capsules, Golden Apples, etc.)
	},
}



--Weighted list of rewards to choose from for missions
MISSION_GEN.REWARDS = {
	--Reward tables of high and low tier loot separated by category (TM, ammo, held items, etc)
	--different mission difficulties have different chances to roll each table

	NECESSITIES = {
		{"seed_reviver", 10},
		{"berry_leppa", 5},
		{"berry_oran", 5},
		{"berry_lum", 5},
		{"food_apple", 5},
		{"orb_escape", 5},
		{"apricorn_plain", 5},
		{"key", 2}
	},
	
	AMMO_LOW = {
		{"ammo_iron_thorn", 5},
		{"ammo_geo_pebble", 1},
		{"ammo_stick", 1},
	},
	
	AMMO_MID = {
		{"ammo_geo_pebble", 5},
		{"ammo_gravelerock", 5},
		{"ammo_stick", 5},
		{"ammo_silver_spike", 5}
	},
	
	AMMO_HIGH = {
		{"ammo_rare_fossil", 5},
		{"ammo_corsola_twig", 5},
		{"ammo_cacnea_spike", 5}
	},
	
	APRICORN_GENERIC = {
		{"apricorn_plain", 12},
		{"apricorn_big", 4}
	},
	
	APRICORN_TYPED = {
		{"apricorn_blue", 5},
		{"apricorn_green", 5},
		{"apricorn_brown", 5},
		{"apricorn_purple", 5},
		{"apricorn_red", 5},
		{"apricorn_white", 5},
		{"apricorn_yellow", 5},
		{"apricorn_black", 5},
		{"apricorn_glittery", 5}
	},
	--Rare chance for gummis
	FOOD_LOW = {
		{"food_apple", 30},
		{"food_banana", 18},
		{"gummi_blue", 1},
		{"gummi_black", 1},
		{"gummi_clear", 1}, 
		{"gummi_grass", 1},
		{"gummi_green", 1},
		{"gummi_brown", 1},
		{"gummi_orange", 1},
		{"gummi_gold", 1},
		{"gummi_pink", 1},
		{"gummi_purple", 1},
		{"gummi_red", 1},
		{"gummi_royal", 1},
		{"gummi_silver", 1},
		{"gummi_white", 1},
		{"gummi_yellow", 1},
		{"gummi_sky", 1},
		{"gummi_gray", 1},
		{"gummi_magenta", 1}
	},
	--Moderate chance of gummis, rare chance of wonder gummis
	FOOD_MID = {
		{"food_apple_big", 30},
		{"food_banana_big", 18},
		{"gummi_blue", 2},
		{"gummi_black", 2},
		{"gummi_clear", 2},
		{"gummi_grass", 2},
		{"gummi_green", 2},
		{"gummi_brown", 2},
		{"gummi_orange", 2},
		{"gummi_gold", 2},
		{"gummi_pink", 2},
		{"gummi_purple", 2},
		{"gummi_red", 2},
		{"gummi_royal", 2},
		{"gummi_silver", 2},
		{"gummi_white", 2},
		{"gummi_yellow", 2},
		{"gummi_sky", 2},
		{"gummi_gray", 2},
		{"gummi_magenta", 2},
		{"gummi_wonder", 1}
	},
	--Small chance for vitamins
	FOOD_HIGH = {
		{"food_apple_huge", 30},
		{"food_apple_perfect", 18},
		{"food_banana_big", 18},
		{"gummi_wonder", 30},
		{"boost_calcium", 3},
		{"boost_protein", 3},
		{"boost_hp_up", 3},
		{"boost_zinc", 3},
		{"boost_carbos", 3},
		{"boost_iron", 3},
		{"boost_nectar", 5}
	},
	
	--Basic manufactured medicine
	MEDICINE_LOW = {
		{"medicine_potion", 20},
		{"medicine_elixir", 20},
		{"medicine_full_heal", 10},
		{"medicine_x_attack", 10},
		{"medicine_x_defense", 10},
		{"medicine_x_sp_atk", 10},
		{"medicine_x_sp_def", 10},
		{"medicine_x_speed", 10},
		{"medicine_x_accuracy", 10},
		{"medicine_dire_hit", 10}
	},
	
	--Advanced manufactued medicine
	MEDICINE_HIGH = {
		{"medicine_max_potion", 20},
		{"medicine_max_elixir", 20},
		{"medicine_full_heal", 10}
	},
	
	--includes seeds and berries, as well as white herbs
	SEED_LOW = {
		{'seed_blast', 5},
		{'seed_sleep', 5},
		{'seed_warp', 5},
		{'berry_oran', 5},
		{'berry_leppa', 5},
		{'berry_sitrus', 5},
		{'berry_lum', 5},
		{"herb_white", 10}
	},
	--Includes advanced seeds, herbs, and type berries
	SEED_MID = {
		{'seed_reviver', 25},
		{'seed_decoy', 5},
		{'seed_blinker', 5},
		{'seed_last_chance', 5},
		{'seed_doom', 5},
		{'seed_ban', 5},
		{'seed_ice', 5},
		{'seed_vile', 5},
		{'berry_tanga', 2},
		{'berry_colbur', 2},
		{'berry_wacan', 2},
		{'berry_haban', 2},
		{'berry_chople', 2},
		{'berry_occa', 2},
		{'berry_coba', 2},
		{'berry_kasib', 2},
		{'berry_rindo', 2},
		{'berry_shuca', 2},
		{'berry_yache', 2},
		{'berry_chilan', 2},
		{'berry_kebia', 2},
		{'berry_payapa', 2},
		{'berry_charti', 2},
		{'berry_babiri', 2},
		{'berry_passho', 2},
		{'berry_roseli', 2},
		{"herb_power", 10},
		{"herb_mental", 10}
	},
	
	--includes rare seeds and berries
	SEED_HIGH = {
		{'seed_pure', 15},
		{'seed_joy', 1},
		{'berry_rowap', 5},
		{'berry_jaboca', 5},
		{'berry_liechi', 5},
		{'berry_ganlon', 5},
		{'berry_salac', 5},
		{'berry_petaya', 5},
		{'berry_apicot', 5},
		{'berry_micle', 5},
		{'berry_enigma', 5},
		{'berry_starf', 5}
	}, 
	
	HELD_LOW = {
		{'held_power_band', 5},
		{'held_special_band', 5},
		{'held_defense_scarf', 5},
		{'held_zinc_band', 5},
		{'held_toxic_orb', 5},
		{'held_flame_orb', 5},
		{'held_iron_ball', 5},
		{'held_ring_target', 5}
	},

	HELD_MID = {
		{'held_pierce_band', 5},
		{'held_warp_scarf', 5},
		{'held_scope_lens', 5},
		{'held_reunion_cape', 5},
		{'held_heal_ribbon', 5},
		{'held_twist_band', 5},
		{'held_grip_claw', 5},
		{'held_binding_band', 5},
		{'held_metronome', 5},
		{'held_shed_shell', 5},
		{'held_wide_lens', 5},
		{'held_sticky_barb', 5},
		{'held_choice_band', 5},
		{'held_choice_scarf', 5},
		{'held_choice_specs', 5}
	},
	
	HELD_HIGH = {
		{'held_golden_mask', 5},
		{'held_friend_bow', 2},
		{'held_shell_bell', 5},
		{'held_mobile_scarf', 5},
		{'held_cover_band', 5},
		{'held_pass_scarf', 5},
		{'held_trap_scarf', 5},
		{'held_pierce_band', 5},
		{'held_goggle_specs', 5},
		{'held_x_ray_specs', 5},
		{'held_assault_vest', 5},
		{'held_life_orb', 5}
	},
	
	HELD_TYPE = {
		{'held_silver_powder', 5},
		{'held_black_glasses', 5},
		{'held_dragon_scale', 5},
		{'held_magnet', 5},
		{'held_pink_bow', 5},
		{'held_black_belt', 5},
		{'held_charcoal', 5},
		{'held_sharp_beak', 5},
		{'held_spell_tag', 5},
		{'held_miracle_seed', 5},
		{'held_soft_sand', 5},
		{'held_never_melt_ice', 5},
		{'held_silk_scarf', 5},
		{'held_poison_barb', 5},
		{'held_twisted_spoon', 5},
		{'held_hard_stone', 5},
		{'held_metal_coat', 5},
		{'held_mystic_water', 5}
	},
	
	HELD_PLATES = {
		{'held_insect_plate', 5},
		{'held_dread_plate', 5},
		{'held_draco_plate', 5},
		{'held_zap_plate', 5},
		{'held_pixie_plate', 5},
		{'held_fist_plate', 5},
		{'held_flame_plate', 5},
		{'held_sky_plate', 5},
		{'held_spooky_plate', 5},
		{'held_meadow_plate', 5},
		{'held_earth_plate', 5},
		{'held_icicle_plate', 5},
		{'held_blank_plate', 5},
		{'held_toxic_plate', 5},
		{'held_mind_plate', 5},
		{'held_stone_plate', 5},
		{'held_iron_plate', 5},
		{'held_splash_plate', 5}
	},
	
	--Spawns boxes, keys, heart scales, and loot
	LOOT_LOW = {
		{'loot_heart_scale', 5},
		{'loot_pearl', 10},
		{'machine_assembly_box', 10},
		{'key', 10}
	},

	LOOT_HIGH = {
		{'loot_heart_scale', 20},
		{'loot_nugget', 5},
		{'machine_recall_box', 10},
		{'machine_storage_box', 10}
	},
	
	EVO_ITEMS = {
		{'evo_link_cable', 30},
		{'evo_fire_stone', 5},
		{'evo_thunder_stone', 5},
		{'evo_water_stone', 5},
		{'evo_leaf_stone', 5},
		{'evo_moon_stone', 5},
		{'evo_sun_stone', 5},
		{'evo_magmarizer', 5},
		{'evo_electirizer', 5},
		{'evo_reaper_cloth', 5},
		{'evo_cracked_pot', 5},
		{'evo_chipped_pot', 5},
		{'evo_shiny_stone', 5},
		{'evo_dusk_stone', 5},
		{'evo_dawn_stone', 5},
		{'evo_up_grade', 5},
		{'evo_dubious_disc', 5},
		{'evo_razor_fang', 5},
		{'evo_razor_claw', 5},
		{'evo_protector', 5},
		{'evo_prism_scale', 5},
		{'evo_kings_rock', 5},
		{'evo_sun_ribbon', 5},
		{'evo_lunar_ribbon', 5},
		{'evo_ice_stone', 5}
	},

	ORBS_LOW = {
		{"orb_escape", 5},
		{"orb_weather", 5},
		{"orb_cleanse", 5},
		{"orb_endure", 5},
		{"orb_trapbust", 5},
		{"orb_petrify", 5},
		{"orb_foe_hold", 5},
		{"orb_nullify", 5},
		{"orb_all_dodge", 5},
		{"orb_rebound", 5},
		{"orb_mirror", 5},
		{"orb_foe_seal", 5},
		{"orb_rollcall", 5},
		{"orb_mug", 5},
	},

	ORBS_MID = {
		{"orb_escape", 5},
		{"orb_mobile", 5},
		{"orb_invisify", 5},
		{"orb_all_aim", 5},
		{"orb_trawl", 5},
		{"orb_one_shot", 5},
		{"orb_pierce", 5},
		{"orb_all_protect", 5},
		{"orb_trap_see", 5},
		{"orb_slumber", 5},
		{"orb_totter", 5},
		{"orb_freeze", 5},
		{"orb_spurn", 5},
		{"orb_itemizer", 5},
		{"orb_halving", 5},
	},

	ORBS_HIGH = {
		{"orb_escape", 5},
		{"orb_luminous", 5},
		{"orb_invert", 5},
		{"orb_devolve", 5},
		{"orb_revival", 5},
		{"orb_scanner", 5},
		{"orb_stayaway", 5},
		{"orb_one_room", 5},
	},
	
	WANDS_LOW = {
		{"wand_pounce", 5},
		{"wand_slow", 5},
		{"wand_topsy_turvy", 5},
		{"wand_purge", 5}
	},

	WANDS_MID = {
		{"wand_path", 5},
		{"wand_whirlwind", 5},
		{"wand_switcher", 5},
		{"wand_fear", 5},
		{"wand_warp", 5},
		{"wand_lob", 5}
	},

	WANDS_HIGH = {
		{"wand_lure", 5},
		{"wand_stayaway", 5},
		{"wand_transfer", 5},
		{"wand_vanish", 5}
	},
	
	TM_LOW = {
		{'tm_snatch', 5},
		{'tm_sunny_day', 5},
		{'tm_rain_dance', 5},
		{'tm_sandstorm', 5},
		{'tm_hail', 5},
		{'tm_taunt', 5},
		
		{'tm_safeguard', 5},
		{'tm_light_screen', 5},
		{'tm_dream_eater', 5},
		{'tm_nature_power', 5},
		{'tm_swagger', 5},
		{'tm_captivate', 5},
		{'tm_fling', 5},
		{'tm_payback', 5},
		{'tm_reflect', 5},
		{'tm_rock_polish', 5},
		{'tm_pluck', 5},
		{'tm_psych_up', 5},
		{'tm_secret_power', 5},

		{'tm_return', 5},
		{'tm_frustration', 5},
		{'tm_torment', 5},
		{'tm_endure', 5},
		{'tm_echoed_voice', 5},
		{'tm_gyro_ball', 5},
		{'tm_recycle', 5},
		{'tm_false_swipe', 5},
		{'tm_defog', 5},
		{'tm_telekinesis', 5},
		{'tm_double_team', 5},
		{'tm_thunder_wave', 5},
		{'tm_attract', 5},
		{'tm_smack_down', 5},
		{'tm_snarl', 5},
		{'tm_flame_charge', 5},

		{'tm_protect', 5},
		{'tm_round', 5},
		{'tm_rest', 5},
		{'tm_thief', 5},
		{'tm_cut', 5},
		{'tm_whirlpool', 5},
		{'tm_infestation', 5},
		{'tm_roar', 5},
		{'tm_flash', 5},
		{'tm_embargo', 5},
		{'tm_struggle_bug', 5},
		{'tm_quash', 5}},
		
	TM_MID = {
		{'tm_explosion', 5},
		{'tm_will_o_wisp', 5},
		{'tm_facade', 5},
		{'tm_water_pulse', 5},
		{'tm_shock_wave', 5},
		{'tm_brick_break', 5},
		{'tm_calm_mind', 5},
		{'tm_charge_beam', 5},
		{'tm_retaliate', 5},
		{'tm_roost', 5},
		{'tm_acrobatics', 5},
		{'tm_bulk_up', 5},


		{'tm_shadow_claw', 5},

		{'tm_steel_wing', 5},
		{'tm_snarl', 5},
		{'tm_bulldoze', 5},
		{'tm_substitute', 5},
		{'tm_brine', 5},
		{'tm_venoshock', 5},
		{'tm_u_turn', 5},
		{'tm_aerial_ace', 5},
		{'tm_hone_claws', 5},
		{'tm_rock_smash', 5},

		{'tm_hidden_power', 5},
		{'tm_rock_tomb', 5},
		{'tm_strength', 5},
		{'tm_grass_knot', 5},
		{'tm_power_up_punch', 5},
		{'tm_work_up', 5},
		{'tm_incinerate', 5},
		{'tm_bullet_seed', 5},
		{'tm_low_sweep', 5},
		{'tm_volt_switch', 5},
		{'tm_avalanche', 5},
		{'tm_dragon_tail', 5},
		{'tm_silver_wind', 5},
		{'tm_frost_breath', 5},
		{'tm_sky_drop', 5}
	},
	
	TM_HIGH = {
		{'tm_earthquake', 5},
		{'tm_hyper_beam', 5},
		{'tm_overheat', 5},
		{'tm_blizzard', 5},
		{'tm_swords_dance', 5},
		{'tm_surf', 5},
		{'tm_dark_pulse', 5},
		{'tm_psychic', 5},
		{'tm_thunder', 5},
		{'tm_shadow_ball', 5},
		{'tm_ice_beam', 5},
		{'tm_giga_impact', 5},
		{'tm_fire_blast', 5},
		{'tm_dazzling_gleam', 5},
		{'tm_flash_cannon', 5},
		{'tm_stone_edge', 5},
		{'tm_sludge_bomb', 5},
		{'tm_focus_blast', 5},

		{'tm_x_scissor', 5},
		{'tm_wild_charge', 5},
		{'tm_focus_punch', 5},
		{'tm_psyshock', 5},
		{'tm_rock_slide', 5},
		{'tm_thunderbolt', 5},
		{'tm_flamethrower', 5},
		{'tm_energy_ball', 5},
		{'tm_scald', 5},
		{'tm_waterfall', 5},
		{'tm_rock_climb', 5},

		{'tm_giga_drain', 5},
		{'tm_dive', 5},
		{'tm_poison_jab', 5},
	
		{'tm_iron_tail', 5},
	
		{'tm_dig', 5},
		{'tm_fly', 5},
		{'tm_dragon_claw', 5},
		{'tm_dragon_pulse', 5},
		{'tm_sludge_wave', 5},
		{'tm_drain_punch', 5}},
	
	--special and unique rewards, very rare
	SPECIAL = {
		{'medicine_amber_tear', 1},
		{'machine_ability_capsule', 1},
		{'ammo_golden_thorn', 1},
		{'food_apple_golden', 1},
		{'seed_golden', 1},
		{'evo_harmony_scarf', 1},
		{'apricorn_perfect', 1}
	}
}

MISSION_GEN.SPECIAL_CLIENT_RIVAL = "RIVAL"
MISSION_GEN.SPECIAL_CLIENT_CHILD = "CHILD"
MISSION_GEN.SPECIAL_CLIENT_LOVER = "LOVER"
MISSION_GEN.SPECIAL_CLIENT_FRIEND = "FRIEND"


MISSION_GEN.SPECIAL_CLIENT_OPTIONS = {
	MISSION_GEN.SPECIAL_CLIENT_LOVER,
	MISSION_GEN.SPECIAL_CLIENT_RIVAL,
	MISSION_GEN.SPECIAL_CLIENT_CHILD,
	MISSION_GEN.SPECIAL_CLIENT_FRIEND
}

--Order matters for these! First is the client, second is the target
--Titles are random from a small list. Each pair has a unique body text however included in the data below.
--Number represents that mon's gender, 1 for male, 2 for female, 0 for genderless
MISSION_GEN.SPECIAL_LOVER_PAIRS = {
	TIER_LOW = {
		{'volbeat', 1, 'illumise', 2, "MISSION_BODY_SPECIAL_LOVER_001"},
		{'minun', 1, 'plusle', 2, "MISSION_BODY_SPECIAL_LOVER_002"},
		{'mareep', 2, 'wooloo', 1, "MISSION_BODY_SPECIAL_LOVER_003"},
		{'luvdisc', 2, 'luvdisc', 2, "MISSION_BODY_SPECIAL_LOVER_004"}	
	},
	TIER_MID = {
		{'miltank', 2, 'tauros', 1, "MISSION_BODY_SPECIAL_LOVER_005"},
		{'venomoth', 1, 'butterfree', 2, "MISSION_BODY_SPECIAL_LOVER_006"},
		{'liepard', 2, 'persian', 1, "MISSION_BODY_SPECIAL_LOVER_007"},
		{'dustox', 1, 'beautifly', 2, "MISSION_BODY_SPECIAL_LOVER_008"},
		{'glalie', 1, 'froslass', 2, "MISSION_BODY_SPECIAL_LOVER_009"},
		{'ribombee', 2, 'masquerain', 1, "MISSION_BODY_SPECIAL_LOVER_010"},
		{'maractus', 2, 'cacturne', 1, "MISSION_BODY_SPECIAL_LOVER_011"},---my prickly love!
		{'lanturn', 1, 'lumineon', 2, "MISSION_BODY_SPECIAL_LOVER_012"}
	},
	TIER_HIGH = {
		{'tyranitar', 1, 'altaria', 2, "MISSION_BODY_SPECIAL_LOVER_013"},--reference to an old idea i had
		{'gyarados', 1, 'milotic', 2, "MISSION_BODY_SPECIAL_LOVER_014"},
		{'gardevoir', 2, 'gallade', 1, "MISSION_BODY_SPECIAL_LOVER_015"}
	}

}

MISSION_GEN.SPECIAL_CHILD_PAIRS = {
	TIER_LOW = {
		{'clefable', 2, 'cleffa', 2, "MISSION_BODY_SPECIAL_CHILD_001"},
		{'wigglytuff', 1, 'igglybuff', 1, "MISSION_BODY_SPECIAL_CHILD_002"},
		{'togekiss', 2, 'togepi', 1, "MISSION_BODY_SPECIAL_CHILD_003"},
		{'roserade', 2, 'budew', 2, "MISSION_BODY_SPECIAL_CHILD_004"},
		{'chimecho', 2, 'chingling', 1, "MISSION_BODY_SPECIAL_CHILD_005"},
		{'sudowoodo', 1, 'bonsly', 1, "MISSION_BODY_SPECIAL_CHILD_006"},
		{'mr_mime', 1, 'mime_jr', 1, "MISSION_BODY_SPECIAL_CHILD_007"},
		{'raticate', 1, 'rattata', 2, "MISSION_BODY_SPECIAL_CHILD_008"},--hes still not so good at gnawing!
		{'leavanny', 2, 'sewaddle', 2, "MISSION_BODY_SPECIAL_CHILD_009"}
	},
	TIER_MID = {
		{'appletun', 2, 'applin', 1, "MISSION_BODY_SPECIAL_CHILD_010"},
		{'aggron', 1, 'aron', 1, "MISSION_BODY_SPECIAL_CHILD_011"},--probably munched too much metal!
		{'jynx', 2, 'smoochum', 2, "MISSION_BODY_SPECIAL_CHILD_012"},
		{'magmortar', 2, 'magby', 2, "MISSION_BODY_SPECIAL_CHILD_013"},
		{'electivire', 1, 'elekid', 1, "MISSION_BODY_SPECIAL_CHILD_014"},
		{'tsareena', 2, 'bounsweet', 2, "MISSION_BODY_SPECIAL_CHILD_015"},
		{'hatterene', 2, 'hatenna', 2, "MISSION_BODY_SPECIAL_CHILD_016"},
		{'gothitelle', 2, 'gothita', 2, "MISSION_BODY_SPECIAL_CHILD_017"},
		{'dugtrio', 1, 'diglett', 1, "MISSION_BODY_SPECIAL_CHILD_018"}
	},	
	TIER_HIGH = {
		{'tyranitar', 2, 'larvitar', 1, "MISSION_BODY_SPECIAL_CHILD_019"},
		{'salamence', 1, 'bagon', 2, "MISSION_BODY_SPECIAL_CHILD_020"},
		{'dragonite', 2, 'dratini', 2, "MISSION_BODY_SPECIAL_CHILD_021"},
		{'noivern', 1, 'noibat', 1, "MISSION_BODY_SPECIAL_CHILD_022"},
		{'goodra', 2, 'goomy', 1, "MISSION_BODY_SPECIAL_CHILD_023"}
	}
	
	
	
	
}

MISSION_GEN.SPECIAL_FRIEND_PAIRS = {
	TIER_LOW = {
		{'applin', 1, 'cherubi', 2, "MISSION_BODY_SPECIAL_FRIEND_001"},--We both get mistaken for fruit! What if someone ate him!?
		{'mantyke', 2, 'remoraid', 1, "MISSION_BODY_SPECIAL_FRIEND_002"},--My best friend is missing! I'll never be able to evolve without him!
		{'magikarp', 1, 'feebas', 2, "MISSION_BODY_SPECIAL_FRIEND_003"},--feebas is the only one who understands what it's like to be dogshit!
		{'poliwag', 2, 'lotad', 1, "MISSION_BODY_SPECIAL_FRIEND_004"},--frog and his lilypad. I have no lilypad now, save him!
		{'teddiursa', 1, 'combee', 2, "MISSION_BODY_SPECIAL_FRIEND_005"}, --Without Combee, I have no honey! Please find them!
		{'woobat', 2, 'zubat', 1, "MISSION_BODY_SPECIAL_FRIEND_006"},--we both use ultrasonic waves to see!
		{'trubbish', 1, 'grimer', 1, "MISSION_BODY_SPECIAL_FRIEND_007"},--we both love eating garbage!
		{'shroomish', 1, 'paras', 1, "MISSION_BODY_SPECIAL_FRIEND_008"},--we both love to spread spores!
		{'chansey', 2, 'togepi', 2, "MISSION_BODY_SPECIAL_FRIEND_009"},--cares for togepi because its an egg
		{'salandit', 1, 'combee', 1, "MISSION_BODY_SPECIAL_FRIEND_010"}--they relate in being useless
	},
	TIER_MID = {
		{'lunatone', 0, 'solrock', 0, "MISSION_BODY_SPECIAL_FRIEND_011"},
		{'emolga', 2, 'pachirisu', 2, "MISSION_BODY_SPECIAL_FRIEND_012"},
		{'spinda', 2, 'hypno', 1, "MISSION_BODY_SPECIAL_FRIEND_013"}, --Hypno went missing; only he can help stop my dizziness
		{'cramorant', 1, 'pelipper', 2, "MISSION_BODY_SPECIAL_FRIEND_014"},
		{'magnemite', 0, 'nosepass', 1, "MISSION_BODY_SPECIAL_FRIEND_015"},--We're both sensitive to magnetism!
		{'dustox', 1, 'lampent', 2, "MISSION_BODY_SPECIAL_FRIEND_016"}
	},
	TIER_HIGH = {
		{'lilligant', 2, 'kricketune', 1, "MISSION_BODY_SPECIAL_FRIEND_017"},--I can't dance without Kricketune's music!
		{'wigglytuff', 2, 'exploud', 1, "MISSION_BODY_SPECIAL_FRIEND_018"}, --we love making loud, silly noises together!
		{'beedrill', 1, 'florges', 2, "MISSION_BODY_SPECIAL_FRIEND_019"},--without my flower, i have no meaning!
		{'dunsparce', 1, 'dugtrio', 1, "MISSION_BODY_SPECIAL_FRIEND_020"},--we both love to burrow!
		{'whimsicott', 2, 'jumpluff', 2, "MISSION_BODY_SPECIAL_FRIEND_021"}
	}
}

MISSION_GEN.SPECIAL_RIVAL_PAIRS = {
	TIER_LOW = {
		{'koffing', 1, 'stunky', 2, "MISSION_BODY_SPECIAL_RIVAL_001"},--they compete to see whose odor is stronger
		{'krabby', 1, 'corphish', 1, "MISSION_BODY_SPECIAL_RIVAL_002"},--compare claw strength
		{'shuppet', 2, 'duskull', 1, "MISSION_BODY_SPECIAL_RIVAL_003"},--we like to see who can pull better pranks!
		{'pidgey', 2, 'spearow', 2, "MISSION_BODY_SPECIAL_RIVAL_004"},--we compete at flying!
		{'kabuto', 1, 'omanyte', 1, "MISSION_BODY_SPECIAL_RIVAL_005"}, --we've been rivals since our ancestors' time!
		{'joltik', 2, 'spinarak', 1, "MISSION_BODY_SPECIAL_RIVAL_006"},--We like to see who can spin the better web!
		{'tyrogue', 1, 'makuhita', 1, "MISSION_BODY_SPECIAL_RIVAL_007"},--my punching bag training partner!
		{'lillipup', 2, 'poochyena', 1, "MISSION_BODY_SPECIAL_RIVAL_008"}

},
	
	TIER_MID = {
		{'vigoroth', 1, 'primeape', 1, "MISSION_BODY_SPECIAL_RIVAL_009"},--full of energy!
		{'sawsbuck', 1, 'stantler', 1, "MISSION_BODY_SPECIAL_RIVAL_010"},--butt antlers!
		{'jangmo_o', 1, 'axew', 1, "MISSION_BODY_SPECIAL_RIVAL_011"},
		{'mareanie', 2, 'corsola', 2, "MISSION_BODY_SPECIAL_RIVAL_012"}

	},
	
	TIER_HIGH = {
		{'heracross', 1, 'pinsir', 1, "MISSION_BODY_SPECIAL_RIVAL_013"},
		{'slowking', 1, 'slowbro', 1, "MISSION_BODY_SPECIAL_RIVAL_014"},--slowbro may not be as smart as me, but we're still great friends!
		{'magmortar', 2, 'electivire', 1, "MISSION_BODY_SPECIAL_RIVAL_015"}, --we need to settle who is stronger!
		{'cradily', 2, 'armaldo', 1, "MISSION_BODY_SPECIAL_RIVAL_016"}, --we've been rivals since our ancestors' time!
		{'bastiodon', 2, 'rampardos', 1, "MISSION_BODY_SPECIAL_RIVAL_017"}, --we've been rivals since our ancestors' time!
		{'archeops', 1, 'aerodactyl', 2, "MISSION_BODY_SPECIAL_RIVAL_018"}, --we've been rivals since our ancestors' time!
		{'swellow', 2, 'staraptor', 1, "MISSION_BODY_SPECIAL_RIVAL_019"}--brave birds!

	}
}



MISSION_GEN.SPECIAL_OUTLAW = {

}


MISSION_GEN.LOST_ITEMS = {
	"mission_lost_scarf",
	"mission_lost_specs",
	"mission_lost_band"
}

MISSION_GEN.STOLEN_ITEMS = {
	"mission_stolen_scarf",
	"mission_stolen_band",
	"mission_stolen_specs"
}

MISSION_GEN.DELIVERABLE_ITEMS = {
	"berry_oran",
	"berry_leppa",
	"food_apple",
	"berry_lum",
	"apricorn_plain"
}

--"order" of dungeons
SV.DungeonOrder = {}
SV.DungeonOrder[""] = 99999--empty missions should get shoved towards the end 



--Do the stairs go up or down? Blank string if up, B if down
SV.StairType = {}
SV.StairType[""] = ""

function MISSION_GEN.GetStairsType(zone_id)
	if SV.StairType[zone_id] ~= nil then
		return SV.StairType[zone_id]
	end
	
	return ''
end


function MISSION_GEN.MissionBoardIsEmpty()
	for k, v in pairs(SV.MissionBoard) do
		if v.Client ~= '' then
			return false
		end
	end
	
	return true
end


function MISSION_GEN.TakenBoardIsEmpty()
	for k, v in pairs(SV.TakenBoard) do
		if v.Client ~= '' then
			return false
		end
	end

	return true
end

function MISSION_GEN.WeightedRandom(weights)
    local summ = 0
    for i, value in pairs (weights) do
        summ = summ + value[2]
    end
    if summ == 0 then return end
    -- local value = math.random (summ) -- for integer weights only
    local rand = summ*math.random ()
    summ = 0
    for i, value in pairs (weights) do
        summ = summ + value[2]
        if rand <= summ then
            return value[1]--, weight
        end
    end
end


function MISSION_GEN.has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end



function MISSION_GEN.ResetBoards()
SV.ExpectedLevel = {}
SV.DungeonOrder = {}
SV.StairType = {}
	
--jobs on the mission board.
SV.MissionBoard =
{
	{
		Client = "",
		Target = "",
		Flavor = "",
		Title = "",
		Zone = "",
		Segment = -1,
		Floor = -1,
		Reward = "",
		Type = -1,
		Completion = -1,
		Taken = false,
		Difficulty = "",
		Item = "",
		Special = "",
		ClientGender = -1,
		TargetGender = -1,
		BonusReward = ""
	},
	{
		Client = "",
		Target = "",
		Flavor = "",
		Title = "",
		Zone = "",
		Segment = -1,
		Floor = -1,
		Reward = "",
		Type = -1,
		Completion = -1,
		Taken = false,
		Difficulty = "",
		Item = "",
		Special = "",
		ClientGender = -1,
		TargetGender = -1,
		BonusReward = ""
	},	
	{
		Client = "",
		Target = "",
		Flavor = "",
		Title = "",
		Zone = "",
		Segment = -1,
		Floor = -1,
		Reward = "",
		Type = -1,
		Completion = -1,
		Taken = false,
		Difficulty = "",
		Item = "",
		Special = "",
		ClientGender = -1,
		TargetGender = -1,
		BonusReward = ""
	},	
	{
		Client = "",
		Target = "",
		Flavor = "",
		Title = "",
		Zone = "",
		Segment = -1,
		Floor = -1,
		Reward = "",
		Type = -1,
		Completion = -1,
		Taken = false,
		Difficulty = "",
		Item = "",
		Special = "",
		ClientGender = -1,
		TargetGender = -1,
		BonusReward = ""
	},	
	{
		Client = "",
		Target = "",
		Flavor = "",
		Title = "",
		Zone = "",
		Segment = -1,
		Floor = -1,
		Reward = "",
		Type = -1,
		Completion = -1,
		Taken = false,
		Difficulty = "",
		Item = "",
		Special = "",
		ClientGender = -1,
		TargetGender = -1,
		BonusReward = ""
	},	
	{
		Client = "",
		Target = "",
		Flavor = "",
		Title = "",
		Zone = "",
		Segment = -1,
		Floor = -1,
		Reward = "",
		Type = -1,
		Completion = -1,
		Taken = false,
		Difficulty = "",
		Item = "",
		Special = "",
		ClientGender = -1,
		TargetGender = -1,
		BonusReward = ""
	},
	{
		Client = "",
		Target = "",
		Flavor = "",
		Title = "",
		Zone = "",
		Segment = -1,
		Floor = -1,
		Reward = "",
		Type = -1,
		Completion = -1,
		Taken = false,
		Difficulty = "",
		Item = "",
		Special = "",
		ClientGender = -1,
		TargetGender = -1,
		BonusReward = ""
	},	
	{
		Client = "",
		Target = "",
		Flavor = "",
		Title = "",
		Zone = "",
		Segment = -1,
		Floor = -1,
		Reward = "",
		Type = -1,
		Completion = -1,
		Taken = false,
		Difficulty = "",
		Item = "",
		Special = "",
		ClientGender = -1,
		TargetGender = -1,
		BonusReward = ""
	}

}

--Jobs on the outlaw board.
SV.OutlawBoard =
{
	{
		Client = "",
		Target = "",
		Flavor = "",
		Title = "",
		Zone = "",
		Segment = -1,
		Floor = -1,
		Reward = "",
		Type = -1,
		Completion = -1,
		Taken = false,
		Difficulty = "",
		Item = "",
		Special = "",
		ClientGender = -1,
		TargetGender = -1,
		BonusReward = ""
	},
	{
		Client = "",
		Target = "",
		Flavor = "",
		Title = "",
		Zone = "",
		Segment = -1,
		Floor = -1,
		Reward = "",
		Type = -1,
		Completion = -1,
		Taken = false,
		Difficulty = "",
		Item = "",
		Special = "",
		ClientGender = -1,
		TargetGender = -1,
		BonusReward = ""
	},	
	{
		Client = "",
		Target = "",
		Flavor = "",
		Title = "",
		Zone = "",
		Segment = -1,
		Floor = -1,
		Reward = "",
		Type = -1,
		Completion = -1,
		Taken = false,
		Difficulty = "",
		Item = "",
		Special = "",
		ClientGender = -1,
		TargetGender = -1,
		BonusReward = ""
	},	
	{
		Client = "",
		Target = "",
		Flavor = "",
		Title = "",
		Zone = "",
		Segment = -1,
		Floor = -1,
		Reward = "",
		Type = -1,
		Completion = -1,
		Taken = false,
		Difficulty = "",
		Item = "",
		Special = "",
		ClientGender = -1,
		TargetGender = -1,
		BonusReward = ""
	},	
	{
		Client = "",
		Target = "",
		Flavor = "",
		Title = "",
		Zone = "",
		Segment = -1,
		Floor = -1,
		Reward = "",
		Type = -1,
		Completion = -1,
		Taken = false,
		Difficulty = "",
		Item = "",
		Special = "",
		ClientGender = -1,
		TargetGender = -1,
		BonusReward = ""
	},	
	{
		Client = "",
		Target = "",
		Flavor = "",
		Title = "",
		Zone = "",
		Segment = -1,
		Floor = -1,
		Reward = "",
		Type = -1,
		Completion = -1,
		Taken = false,
		Difficulty = "",
		Item = "",
		Special = "",
		ClientGender = -1,
		TargetGender = -1,
		BonusReward = ""
	},
	{
		Client = "",
		Target = "",
		Flavor = "",
		Title = "",
		Zone = "",
		Segment = -1,
		Floor = -1,
		Reward = "",
		Type = -1,
		Completion = -1,
		Taken = false,
		Difficulty = "",
		Item = "",
		Special = "",
		ClientGender = -1,
		TargetGender = -1,
		BonusReward = ""
	},	
	{
		Client = "",
		Target = "",
		Flavor = "",
		Title = "",
		Zone = "",
		Segment = -1,
		Floor = -1,
		Reward = "",
		Type = -1,
		Completion = -1,
		Taken = false,
		Difficulty = "",
		Item = "",
		Special = "",
		ClientGender = -1,
		TargetGender = -1,
		BonusReward = ""
	}
}

end

function MISSION_GEN.GetDifficultyString(difficulty_val)
	local star_icon = STRINGS:Format("\\uE10C") --star icon
	local difficulty_string = ""
	local difficulty_text_strings = {}
	for str in string.gmatch(difficulty_val, "([^_]+)") do
		table.insert(difficulty_text_strings, str)
	end

	if #difficulty_text_strings == 1 then
		difficulty_string = difficulty_text_strings[1]
	elseif #difficulty_text_strings == 2 then
		--STAR
		difficulty_string = difficulty_text_strings[2] .. star_icon
	end
	
	return difficulty_string
end

--Generate a board. Board_type should be given as "Mission" or "Outlaw".
--Job/Outlaw Boards should be cleared before being regenerated.
function MISSION_GEN.GenerateBoard(result, board_type)
	local jobs_to_make = 8
	local assigned_combos = {}--floor/dungeon combinations that already have had missions genned for it. Need to consider already genned missions and missions on taken board.
	
	-- All seen Pokemon in the pokedex
	--local seen_pokemon = {}

	--for entry in luanet.each(_DATA.Save.Dex) do
	--	if entry.Value == RogueEssence.Data.GameProgress.UnlockState.Discovered then
	--		table.insert(seen_pokemon, entry.Key)
	--	end
	--end

	--print( seen_pokemon[ math.random( #seen_pokemon ) ] )
	
	--default to mission.
	local mission_type = COMMON.MISSION_BOARD_MISSION
	if board_type == COMMON.MISSION_BOARD_OUTLAW then mission_type = COMMON.MISSION_BOARD_OUTLAW end
	
	--get list of potential dungeons for missions, remove any that haven't been completed yet.
	local dungeon_candidates = {}
	local dungeon_segments = {}
	local dungeon_candidate_index_cur = 1
	local dungeon_difficulties = MISSION_GEN.ShallowCopy(MISSION_GEN.DIFFICULTY)
	for dungeon_id, cur_dungeon_segments in pairs(SV.MissionPrereq.DungeonsCompleted) do
		local dungeon_instance = _DATA:GetZone(dungeon_id)		
		local dungeon_segment_index_cur = 1
		PrintInfo("Checking to see if "..dungeon_id.." is a possible mission destination.")
		if MISSION_GEN.DUNGEON_LIST[dungeon_id] ~= nil then
			--Add the expected level
			SV.ExpectedLevel[dungeon_id] = dungeon_instance.Level
			dungeon_candidates[dungeon_candidate_index_cur] = dungeon_id
			PrintInfo("Adding dungeon "..dungeon_id.." as a possible mission destination.")
			local default_dungeon_candidate_needed = true
			for dungeon_segment, value in pairs(cur_dungeon_segments) do
				if MISSION_GEN.DUNGEON_LIST[dungeon_id][dungeon_segment] ~= nil then
					local cur_difficulty = MISSION_GEN.DUNGEON_LIST[dungeon_id][dungeon_segment]

					PrintInfo("Adding dungeon "..dungeon_id.." with segment "..dungeon_segment.." and difficulty "..cur_difficulty)

					if dungeon_segments[dungeon_candidate_index_cur] == nil then
						dungeon_segments[dungeon_candidate_index_cur] = {}
					end

					if dungeon_instance.Segments[dungeon_segment].FloorCount > 1 then
						dungeon_segments[dungeon_candidate_index_cur][dungeon_segment_index_cur] = dungeon_segment
					end
					default_dungeon_candidate_needed = false
				end
			end

			if default_dungeon_candidate_needed == true then
				if MISSION_GEN.DUNGEON_LIST[dungeon_id][0] ~= nil then
					local cur_difficulty = MISSION_GEN.DUNGEON_LIST[dungeon_id][0]

					PrintInfo("Adding dungeon "..dungeon_id.." with default segment 0 and difficulty "..cur_difficulty)

					if dungeon_segments[dungeon_candidate_index_cur] == nil then
						dungeon_segments[dungeon_candidate_index_cur] = {}
					end

					if dungeon_instance.Segments[0].FloorCount > 1 then
						dungeon_segments[dungeon_candidate_index_cur][dungeon_segment_index_cur] = 0
					end
				end
			end
			dungeon_candidate_index_cur = dungeon_candidate_index_cur + 1
		end
		SV.DungeonOrder[dungeon_id] = dungeon_candidate_index_cur
		SV.StairType[dungeon_id] = ""
	end
	
	--failsafe. Just quit if no dungeons are eligible.
	if #dungeon_candidates == 0 then return end
	
	--generate jobs
	for i = 1, jobs_to_make, 1 do
		--choose a dungeon, client, target, item, etc
		local dungeon_candidate_index = math.random(1, #dungeon_candidates)
		local dungeon = dungeon_candidates[dungeon_candidate_index]
		local client = ""
		local item = ""
		local special = ""
		local title = "Default title."
		local flavor = "Default flavor text."


		--Parse through segments for the dungeon
		local possible_segments = dungeon_segments[dungeon_candidate_index]

		local segment = 0 --Default to 0 segment if no other valid one has been unlocked

		if #possible_segments > 0 then
			segment = possible_segments[math.random(1, #possible_segments)]
		end


		--generate the objective.
		local objective
		local missionOutlawRoll = math.random(3)
		if missionOutlawRoll == 1 then
			--1 in 3 chance of outlaw
			PrintInfo("Generating new outlaw mission")
			local roll = math.random(1, 10)
			if roll <= 5 then
				--5/10 chance of regular outlaw
				objective = COMMON.MISSION_TYPE_OUTLAW
			elseif roll <= 8 then
				--3/10 chance of outlaw with an item
				objective = COMMON.MISSION_TYPE_OUTLAW_ITEM
			elseif roll <= 9 then
				--1/10 chance of outlaw monster house
				objective = COMMON.MISSION_TYPE_OUTLAW_MONSTER_HOUSE
			else
				--1/10 chance of outlaw fleeing
				objective = COMMON.MISSION_TYPE_OUTLAW_FLEE
			end
		else
			--2 in 3 chance of normal
			PrintInfo("Generating new normal mission")
			local roll = math.random(1, 10)
			if roll <= 2 then
				--if there's already an escort or exploration mission generated for this dungeon, don't gen another one and just make it a rescue.
				if roll == 1 then
					--1/10 chance of exploration (becomes regular rescue mission)
					objective = COMMON.MISSION_TYPE_EXPLORATION
				else
					--1/10 chance of escort (becomes regular rescue mission)
					objective = COMMON.MISSION_TYPE_ESCORT
				end

				--only check from 1 to i-1 to save time.
				for j = 1, i-1, 1 do
					if SV.MissionBoard[j].Zone == dungeon and (SV.MissionBoard[j].Type == COMMON.MISSION_TYPE_ESCORT or SV.MissionBoard[j].Type == COMMON.MISSION_TYPE_EXPLORATION) then
						objective = COMMON.MISSION_TYPE_RESCUE
						break
					end
				end

				for j = 1, 8, 1 do
					if SV.TakenBoard[j].Zone == dungeon and (SV.TakenBoard[j].Type == COMMON.MISSION_TYPE_ESCORT or SV.TakenBoard[j].Type == COMMON.MISSION_TYPE_EXPLORATION) then
						objective = COMMON.MISSION_TYPE_RESCUE
						break
					end
				end
			elseif roll <= 3 then
				--1/10 chance of delivery
				objective = COMMON.MISSION_TYPE_DELIVERY
			elseif roll <= 5 then
				--2/10 chance of lost item
				objective = COMMON.MISSION_TYPE_LOST_ITEM
			else
				--5/10 chance of a normal rescue mission
				objective = COMMON.MISSION_TYPE_RESCUE
			end
		end

		if objective == COMMON.MISSION_TYPE_DELIVERY then
			item = MISSION_GEN.DELIVERABLE_ITEMS[math.random(1, #MISSION_GEN.DELIVERABLE_ITEMS)]
		elseif objective == COMMON.MISSION_TYPE_OUTLAW_ITEM then
			item = MISSION_GEN.STOLEN_ITEMS[math.random(1, #MISSION_GEN.STOLEN_ITEMS)]
		elseif objective == COMMON.MISSION_TYPE_LOST_ITEM then
			item = MISSION_GEN.LOST_ITEMS[math.random(1, #MISSION_GEN.LOST_ITEMS)]
		end



		--get the zone, and max floors (counted floors of relevant segments, excluding the first LoadGen floor)
		local zoneEntry = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(dungeon)
		local zone = _DATA:GetZone(dungeon)


		local difficulty = MISSION_GEN.DUNGEON_LIST[dungeon][segment]
		local offset = 0
		--up the difficulty by 1 if its an outlaw or escort mission.
		local difficult_objectives = { COMMON.MISSION_TYPE_ESCORT, COMMON.MISSION_TYPE_EXPLORATION, COMMON.MISSION_TYPE_OUTLAW, COMMON.MISSION_TYPE_OUTLAW_FLEE, COMMON.MISSION_TYPE_OUTLAW_ITEM }
		if COMMON.TableContains(difficult_objectives, objective) then
			offset = 1
			--up the difficulty by 2 if its an outlaw monster house
		elseif objective == COMMON.MISSION_TYPE_OUTLAW_MONSTER_HOUSE then
			offset = 2
		end

		--up the difficulty in a subsegment of the dungeon
		if segment > 0 then
			offset = offset + 1
		end

		local final_order = MISSION_GEN.DIFF_TO_ORDER[difficulty]+offset

		if final_order >= #MISSION_GEN.ORDER_TO_DIFF then
			final_order = #MISSION_GEN.ORDER_TO_DIFF - 1
		end

		difficulty = MISSION_GEN.ORDER_TO_DIFF[final_order]

		--Generate a tier, then the client
		local tier = MISSION_GEN.WeightedRandom(MISSION_GEN.DIFF_POKEMON[difficulty])
		local client_candidates = MISSION_GEN.POKEMON[tier]
		client = client_candidates[math.random(1, #client_candidates)]

		--50% chance that the client and target are the same. Target is the escort if its an escort mission.
		--It is possible for this to roll the same target as the client again, which is fine.
		--Always give a target if objective is escort or a outlaw stole an item.
		--Target should always be client for 
		local target = client
		local target_candidates = MISSION_GEN.POKEMON[tier]
		if math.random(1, 2) == 1 or objective == COMMON.MISSION_TYPE_ESCORT or objective == COMMON.MISSION_TYPE_OUTLAW_ITEM then
			target = target_candidates[math.random(1, #target_candidates)]
			--print(target_candidates[1]) --to give an idea of what tier we rolled
		end

		--if its a generic outlaw mission, or a monster house / fleeing outlaw, Magna is the client. Normal mons only ask you to go after their stolen items.
		if objective == COMMON.MISSION_TYPE_OUTLAW or objective == COMMON.MISSION_TYPE_OUTLAW_FLEE or objective == COMMON.MISSION_TYPE_OUTLAW_MONSTER_HOUSE then
			client = "magna"
		end

		--if it's a delivery, exploration, or lost item, target and client should match.
		if objective == COMMON.MISSION_TYPE_EXPLORATION or objective == COMMON.MISSION_TYPE_DELIVERY or objective == COMMON.MISSION_TYPE_LOST_ITEM then
			target = client
		end


		--Reroll target if target is ghost and target is a fleeing outlaw, that shit would be too obnoxious to deal with
		local target_type_1 = _DATA:GetMonster(target).Forms[0].Element1
		local target_type_2 = _DATA:GetMonster(target).Forms[0].Element2
		while objective == COMMON.MISSION_TYPE_OUTLAW_FLEE and (target_type_1 == "ghost" or target_type_2 == "ghost") do
			print(target .. ": Rerolling cowardly ghost outlaw!!!")
			target = target_candidates[math.random(1, #target_candidates)]
			target_type_1 = _DATA:GetMonster(target).Forms[0].Element1
			target_type_2 = _DATA:GetMonster(target).Forms[0].Element2
			print("new target is " .. target)
		end

		--Roll for genders. Use base form because it PROBABLY won't ever matter.
		--because Scriptvars doesnt like saving genders instead of regular structures, use 1/2/0 for m/f/genderless respectively, and convert when needed
		local client_gender
		
		local rand = nil

		if _ZONE.CurrentMap ~= nil and _ZONE.CurrentMap.Rand ~= nil then
			rand = _ZONE.CurrentMap.Rand
		else
			rand = GAME.Rand
		end

		if client == "magna" then --Magna is a special exception
			client_gender = 0
		else
			client_gender = _DATA:GetMonster(client).Forms[0]:RollGender(rand)
			client_gender = COMMON.GenderToNum(client_gender)
		end

		local target_gender = _DATA:GetMonster(target).Forms[0]:RollGender(rand)

		target_gender = COMMON.GenderToNum(target_gender)

		--Special cases
		--Roll for the main 3 rescue special cases 
		if objective == COMMON.MISSION_TYPE_RESCUE and math.random(1, 10) <= 2 then
			local special_candidates = {}
			special = MISSION_GEN.SPECIAL_CLIENT_OPTIONS[math.random(1, #MISSION_GEN.SPECIAL_CLIENT_OPTIONS)]
			if special == MISSION_GEN.SPECIAL_CLIENT_CHILD then
				special_candidates = MISSION_GEN.SPECIAL_CHILD_PAIRS[tier]
			elseif special == MISSION_GEN.SPECIAL_CLIENT_LOVER then
				special_candidates = MISSION_GEN.SPECIAL_LOVER_PAIRS[tier]
			elseif special == MISSION_GEN.SPECIAL_CLIENT_RIVAL then
				special_candidates = MISSION_GEN.SPECIAL_RIVAL_PAIRS[tier]
			elseif special == MISSION_GEN.SPECIAL_CLIENT_FRIEND then
				special_candidates = MISSION_GEN.SPECIAL_FRIEND_PAIRS[tier]
			end


			--Set variables with special client/target info
			local special_choice = special_candidates[math.random(1, #special_candidates)]
			client = special_choice[1]
			client_gender = special_choice[2]
			target = special_choice[3]
			target_gender = special_choice[4]

			local special_title_candidates = MISSION_GEN.TITLES[special]
			title = RogueEssence.StringKey(special_title_candidates[math.random(1, #special_title_candidates)]):ToLocal()

			flavor = RogueEssence.StringKey(special_choice[5]):ToLocal()


		end




		--generate reward with hardcoded list of weighted rewards
		local reward = "money"
		--1/4 chance you get money instead of an item

		if math.random(1, 4) > 1 then
			local reward_pool = MISSION_GEN.REWARDS[MISSION_GEN.WeightedRandom(MISSION_GEN.DIFF_REWARDS[difficulty])]
			reward = MISSION_GEN.WeightedRandom(reward_pool)
		end

		--1/3 chance you get a bonus reward. Bonus reward is always an item, never money 
		local bonus_reward = ""

		if math.random(1,3) == 1 then
			local reward_pool = MISSION_GEN.REWARDS[MISSION_GEN.WeightedRandom(MISSION_GEN.DIFF_REWARDS[difficulty])]
			bonus_reward = MISSION_GEN.WeightedRandom(reward_pool)
		end

		--Choose a random title that's appropriate.
		local title_candidates = {}

		if special == "" then -- get title if special didn't already generate it
			if objective == COMMON.MISSION_TYPE_RESCUE and client ~= target then
				title_candidates = MISSION_GEN.TITLES["RESCUE_FRIEND"]
			elseif objective == COMMON.MISSION_TYPE_RESCUE and client == target then
				title_candidates = MISSION_GEN.TITLES["RESCUE_SELF"]
			elseif objective == COMMON.MISSION_TYPE_ESCORT then
				title_candidates = MISSION_GEN.TITLES["ESCORT"]
			elseif objective == COMMON.MISSION_TYPE_EXPLORATION then
				title_candidates = MISSION_GEN.TITLES["EXPLORATION"]
			elseif objective == COMMON.MISSION_TYPE_LOST_ITEM then
				title_candidates = MISSION_GEN.TITLES["LOST_ITEM"]
			elseif objective == COMMON.MISSION_TYPE_DELIVERY then
				title_candidates = MISSION_GEN.TITLES["DELIVERY"]
			elseif objective == COMMON.MISSION_TYPE_OUTLAW then
				title_candidates = MISSION_GEN.TITLES["OUTLAW"]
			elseif objective == COMMON.MISSION_TYPE_OUTLAW_ITEM then
				title_candidates = MISSION_GEN.TITLES["OUTLAW_ITEM"]
			elseif objective == COMMON.MISSION_TYPE_OUTLAW_MONSTER_HOUSE then
				title_candidates = MISSION_GEN.TITLES["OUTLAW_MONSTER_HOUSE"]
			elseif objective == COMMON.MISSION_TYPE_OUTLAW_FLEE then
				title_candidates = MISSION_GEN.TITLES["OUTLAW_FLEE"]
			end
			title = RogueEssence.StringKey(title_candidates[math.random(1, #title_candidates)]):ToLocal()

			--string substitutions, if needed.
			if string.find(title, "%[target%]") then
				title = string.gsub(title, "%[target%]", _DATA:GetMonster(target):GetColoredName())
			end

			if string.find(title, "%[dungeon%]") then
				title = string.gsub(title, "%[dungeon%]", _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(dungeon):GetColoredName())
			end

			if string.find(title, "%[item%]") then
				title = string.gsub(title, "%[item%]",  _DATA:GetItem(item):GetColoredName())
			end
		end



		--Flavor text generation
		local flavor_top_candidates = {}
		local flavor_bottom_candidates = {}

		if special == "" then -- get flavor if special didn't already generate it 
			if objective == COMMON.MISSION_TYPE_RESCUE and client ~= target then
				flavor_top_candidates = MISSION_GEN.FLAVOR_TOP["RESCUE_FRIEND"]
				flavor_bottom_candidates = MISSION_GEN.FLAVOR_BOTTOM["RESCUE_FRIEND"]
			elseif objective == COMMON.MISSION_TYPE_RESCUE and client == target then
				flavor_top_candidates = MISSION_GEN.FLAVOR_TOP["RESCUE_SELF"]
				flavor_bottom_candidates = MISSION_GEN.FLAVOR_BOTTOM["RESCUE_SELF"]
			elseif objective == COMMON.MISSION_TYPE_ESCORT then
				flavor_top_candidates = MISSION_GEN.FLAVOR_TOP["ESCORT"]
				flavor_bottom_candidates = MISSION_GEN.FLAVOR_BOTTOM["ESCORT"]
			elseif objective == COMMON.MISSION_TYPE_EXPLORATION then
				flavor_top_candidates = MISSION_GEN.FLAVOR_TOP["EXPLORATION"]
				flavor_bottom_candidates = MISSION_GEN.FLAVOR_BOTTOM["EXPLORATION"]
			elseif objective == COMMON.MISSION_TYPE_LOST_ITEM then
				flavor_top_candidates = MISSION_GEN.FLAVOR_TOP["LOST_ITEM"]
				flavor_bottom_candidates = MISSION_GEN.FLAVOR_BOTTOM["LOST_ITEM"]
			elseif objective == COMMON.MISSION_TYPE_DELIVERY then
				flavor_top_candidates = MISSION_GEN.FLAVOR_TOP["DELIVERY"]
				flavor_bottom_candidates = MISSION_GEN.FLAVOR_BOTTOM["DELIVERY"]
			elseif objective == COMMON.MISSION_TYPE_OUTLAW then
				flavor_top_candidates = MISSION_GEN.FLAVOR_TOP["OUTLAW"]
				flavor_bottom_candidates = MISSION_GEN.FLAVOR_BOTTOM["OUTLAW"]
			elseif objective == COMMON.MISSION_TYPE_OUTLAW_ITEM then
				flavor_top_candidates = MISSION_GEN.FLAVOR_TOP["OUTLAW_ITEM"]
				flavor_bottom_candidates = MISSION_GEN.FLAVOR_BOTTOM["OUTLAW_ITEM"]
			elseif objective == COMMON.MISSION_TYPE_OUTLAW_MONSTER_HOUSE then
				flavor_top_candidates = MISSION_GEN.FLAVOR_TOP["OUTLAW_MONSTER_HOUSE"]
				flavor_bottom_candidates = MISSION_GEN.FLAVOR_BOTTOM["OUTLAW_MONSTER_HOUSE"]
			elseif objective == COMMON.MISSION_TYPE_OUTLAW_FLEE then
				flavor_top_candidates = MISSION_GEN.FLAVOR_TOP["OUTLAW_FLEE"]
				flavor_bottom_candidates = MISSION_GEN.FLAVOR_BOTTOM["OUTLAW_FLEE"]
			end
			flavor = RogueEssence.StringKey(flavor_top_candidates[math.random(1, #flavor_top_candidates)]):ToLocal() .. '\n' .. RogueEssence.StringKey(flavor_bottom_candidates[math.random(1, #flavor_bottom_candidates)]):ToLocal()

			--string substitutions, if needed.
			if string.find(flavor, "%[target%]") then
				flavor = string.gsub(flavor, "%[target%]", _DATA:GetMonster(target):GetColoredName())
			end

			if string.find(flavor, "%[dungeon%]") then
				flavor = string.gsub(flavor, "%[dungeon%]", _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(dungeon):GetColoredName())
			end

			if string.find(flavor, "%[item%]") then
				flavor = string.gsub(flavor, "%[item%]",  _DATA:GetItem(item):GetColoredName())
			end

		end




		--mission floor should be in last 45% of the dungeon
		--don't pick a floor that's already been chosen for another mission in a dungeon
		--It's smart; it'll only randomly choose floors that haven't been used up yet. If all floors are used up that are possible, only then is the job thrown out.
		local used_floors = {}
		for j = 1, 8, 1 do
			if SV.OutlawBoard[j].Zone == dungeon then
				table.insert(used_floors, 1, SV.OutlawBoard[j].Floor)
			end
			if SV.MissionBoard[j].Zone == dungeon then
				table.insert(used_floors, 1, SV.MissionBoard[j].Floor)
			end
			if SV.TakenBoard[j].Zone == dungeon then
				table.insert(used_floors, 1, SV.TakenBoard[j].Floor)
			end
		end

		local current_segment = zone.Segments[segment]
		local floor_count = current_segment.FloorCount

		local floor_candidates = {}
		if segment == 0 then
			--The first segment should be the default one the player enters
			floor_candidates = MISSION_GEN.Generate_List_Range(math.floor(floor_count * .55), floor_count)
		else
			floor_candidates = MISSION_GEN.Generate_List_Range(1, floor_count)
		end
		MISSION_GEN.array_sub(used_floors, floor_candidates)

		local floor_candidates_length = #floor_candidates
		local current_index = 0
		local noMissionFloors = COMMON.GetNoMissionFloors(current_segment)
		local valid_floor_candidates = {}
		
		PrintInfo(#noMissionFloors.." no mission floors found for dungeon "..dungeon)
		 
		--Make sure that the dungeon floor added is valid
		for i = 1, floor_candidates_length, 1 do
			local cur_candidate = floor_candidates[i]
			if noMissionFloors[cur_candidate] == nil then
				local has_sidequest_on_floor = false
				
				--Make sure none of the sidequests (EscortSister, OutlawForest) take place in the same floor
				for name, mission in pairs(SV.missions.Missions) do
					if mission.DestZone == dungeon and mission.DestSegment == current_segment and mission.DestFloor == cur_candidate - 1 then
						has_sidequest_on_floor = true
						break
					end
				end

				if has_sidequest_on_floor == false then
					table.insert(valid_floor_candidates, cur_candidate)
				end
			end
		end

		local mission_floor = -1
		if #valid_floor_candidates > 0 then
			mission_floor = valid_floor_candidates[math.random(1, #valid_floor_candidates)]
		end
		
		if mission_floor == -1 then PrintInfo("Can't generate job for index "..i.." and difficulty "..difficulty..", no more floors available!") end
		
		--don't generate this particular job slot if no more are available for the dungeon.
		if mission_floor ~= -1 then 
			if mission_type == COMMON.MISSION_BOARD_OUTLAW then
				SV.OutlawBoard[i].Client = client
				SV.OutlawBoard[i].Target = target
				SV.OutlawBoard[i].Flavor = flavor
				SV.OutlawBoard[i].Title = title
				SV.OutlawBoard[i].Zone = dungeon
				SV.OutlawBoard[i].Segment = segment
				SV.OutlawBoard[i].Reward = reward
				SV.OutlawBoard[i].Floor = mission_floor
				SV.OutlawBoard[i].Type = objective
				SV.OutlawBoard[i].Completion = MISSION_GEN.INCOMPLETE
				SV.OutlawBoard[i].Taken = false
				SV.OutlawBoard[i].Difficulty = difficulty
				SV.OutlawBoard[i].Item = item
				SV.OutlawBoard[i].Special = special
				SV.OutlawBoard[i].ClientGender = client_gender
				SV.OutlawBoard[i].TargetGender = target_gender
				SV.OutlawBoard[i].BonusReward = bonus_reward
			else
				PrintInfo("Creating new mission for index "..i.." with client "..client.." difficulty "..difficulty.." title "..title.." and dungeon "..dungeon.." and segment "..segment.." and floor "..mission_floor)
				SV.MissionBoard[i].Client = client
				SV.MissionBoard[i].Target = target
				SV.MissionBoard[i].Flavor = flavor
				SV.MissionBoard[i].Title = title
				SV.MissionBoard[i].Zone = dungeon
				SV.MissionBoard[i].Segment = segment
				SV.MissionBoard[i].Reward = reward
				SV.MissionBoard[i].Floor = mission_floor
				SV.MissionBoard[i].Type = objective
				SV.MissionBoard[i].Completion = MISSION_GEN.INCOMPLETE
				SV.MissionBoard[i].Taken = false
				SV.MissionBoard[i].Difficulty = difficulty
				SV.MissionBoard[i].Item = item
				SV.MissionBoard[i].Special = special		
				SV.MissionBoard[i].ClientGender = client_gender
				SV.MissionBoard[i].TargetGender = target_gender
				SV.MissionBoard[i].BonusReward = bonus_reward
			end
		end
			
	end
	
end

function MISSION_GEN.GetJobExpReward(difficulty)
	return MISSION_GEN.DIFFICULTY[difficulty]
end

function MISSION_GEN.JobSortFunction(j1, j2)
	if (j2 == nil or j2.Zone == nil or j2.Zone == "") then
		return false
	end
	if (j1 == nil or j1.Zone == nil or j1.Zone == "") then
		return true
	end
	--if they're the same dungeon, then check floors. Otherwise, dungeon order takes presidence. 
	if SV.DungeonOrder[j1.Zone] == SV.DungeonOrder[j2.Zone] then
		return j1.Floor > j2.Floor 
	else 
		return SV.DungeonOrder[j1.Zone] > SV.DungeonOrder[j2.Zone]
	end
end

--used to get the minus of one list minus another list
function MISSION_GEN.array_sub(t1, t2)
  local t = {}
  for i = 1, #t1 do
    t[t1[i]] = true;
  end
  for i = #t2, 1, -1 do
    if t[t2[i]] then
      table.remove(t2, i);
    end
  end
end

--used to get an array of a range. For figuring out floor candidates
function MISSION_GEN.Generate_List_Range(low, up)
	local array = {}
	local count = 1
	for i = low, up, 1 do
		array[count] = i
		count = count + 1
	end
	return array
end

function MISSION_GEN.SortTaken()
	if #SV.TakenBoard > 1 then
		table.sort(SV.TakenBoard, MISSION_GEN.JobSortFunction)
	end
end

function MISSION_GEN.SortMission()
	PrintInfo("Sorting mission board with size "..#SV.MissionBoard)
	
	if #SV.MissionBoard > 1 then
		table.sort(SV.MissionBoard, MISSION_GEN.JobSortFunction)
	end
end

function MISSION_GEN.SortOutlaw()
	if #SV.OutlawBoard > 1 then
		table.sort(SV.OutlawBoard, MISSION_GEN.JobSortFunction)
	end
end

function MISSION_GEN.IsBoardFull(board)
	for i=#board, 1, -1 do
		if board[i].Client == "" then
			return false
		end
	end
	
	return true
end

--Finds the next free index in the board, returns -1 if it can't be found
function MISSION_GEN.FindFreeSpaceInBoard(board)
	for i=#board, 1, -1 do
		if board[i].Client == "" then
			return i
		end
	end

	return -1
end

--Used to create a shallow copy of a provided table (mainly for taking jobs)
function MISSION_GEN.ShallowCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


JobMenu = Class('JobMenu')

--jobs is a job board 
--job type should be taken, mission, or outlaw
--job number should be 1-8
function JobMenu:initialize(job_type, job_number, parent_board_menu)
  assert(self, "JobMenu:initialize(): Error, self is nil!")
  self.menu = RogueEssence.Menu.ScriptableMenu(32, 32, 256, 176, function(input) self:Update(input) end)
  --self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(jobs[i], RogueElements.Loc(16, 8 + 14 * (i-1))))
    
  local job 
  
  self.job_number = job_number
  
  self.job_type = job_type
  
  self.parent_board_menu = parent_board_menu
  
  --get relevant board
  local job
  if job_type == COMMON.MISSION_BOARD_TAKEN then
	job = SV.TakenBoard[job_number]
  elseif job_type == COMMON.MISSION_BOARD_OUTLAW then
  	job = SV.OutlawBoard[job_number]
  else --default to mission board
  	job = SV.MissionBoard[job_number]
  end
  
  self.taken = job.Taken
  
  self.flavor = job.Flavor
  --Magna is the only non-species name that'll show up here. So he is hardcoded in as an exception here.
  --TODO: Unhardcode this by adding in a check if string is not empty and if its not a species name, then add the color coding around it for  proper names.
  self.client = ""
  if job.Client == 'magna' then 
	self.client = '[color=#00FFFF]Magna[color]' 
  elseif job.Client ~= "" then 
	self.client = _DATA:GetMonster(job.Client):GetColoredName() 
  end

  self.target = ""
  if job.Target ~= '' then self.target = _DATA:GetMonster(job.Target):GetColoredName() end
  
	self.item = ""
	if job.Item ~= '' then self.item = _DATA:GetItem(job.Item):GetColoredName() end
  
  self.objective = ""
  self.type = job.Type
  self.taken_count = MISSION_GEN.GetTakenCount()
  
  if self.type == COMMON.MISSION_TYPE_RESCUE then
		self.objective = "Rescue " .. self.target .. "."
  elseif self.type == COMMON.MISSION_TYPE_ESCORT then
    self.objective = "Escort " .. self.client .. " to " .. self.target .. "."
	elseif self.type == COMMON.MISSION_TYPE_EXPLORATION then
		self.objective = "Explore with " .. self.client .. "."
  elseif self.type == COMMON.MISSION_TYPE_OUTLAW or self.type == COMMON.MISSION_TYPE_OUTLAW_FLEE or self.type == COMMON.MISSION_TYPE_OUTLAW_MONSTER_HOUSE then 
		self.objective = "Arrest " .. self.target .. "."
	elseif self.type == COMMON.MISSION_TYPE_LOST_ITEM then 
		self.objective = "Find " .. self.item .. " for " .. self.client .. "."
	elseif self.type == COMMON.MISSION_TYPE_DELIVERY then 
		self.objective = "Deliver " .. self.item .. " to " .. self.client .. "."
  elseif self.type == COMMON.MISSION_TYPE_OUTLAW_ITEM then 
		self.objective = "Reclaim " .. self.item .. " from " .. self.target .. "."
  end
  
  
  self.zone = ""
  if job.Zone ~= "" then
	  local zone_string = _DATA:GetZone(job.Zone).Segments[job.Segment]:ToString()
	  zone_string = COMMON.CreateColoredSegmentString(zone_string)
	  self.zone = zone_string
  end
  
  self.floor = ""
  if job.Floor ~= -1 then self.floor = MISSION_GEN.GetStairsType(job.Zone) .. '[color=#00FFFF]' .. tostring(job.Floor) .. "[color]F" end
  
  self.difficulty = ""
  if job.Difficulty ~= "" then self.difficulty = MISSION_GEN.DIFF_TO_COLOR[job.Difficulty] .. MISSION_GEN.GetDifficultyString(job.Difficulty) .. "[color]   - " ..  Text.FormatKey("MISSION_EXP_DESCRIPTION", tostring(MISSION_GEN.DIFFICULTY[job.Difficulty])) end 
  
  
  
  
  self.reward = ""
  if job.Reward ~= '' then
	--special case for money
	if job.Reward == "money" then
		self.reward = '[color=#00FFFF]' .. MISSION_GEN.DIFF_TO_MONEY[job.Difficulty] .. '[color]' .. STRINGS:Format("\\uE024")
	else
		local reward_amount = 1
		--Reward amount should be 3 for multi-stack items
		if RogueEssence.Data.DataManager.Instance:GetItem(job.Reward).MaxStack >= 3 then
			reward_amount = 3
		end
		self.reward = RogueEssence.Dungeon.InvItem(job.Reward, false, reward_amount):GetDisplayName()
    end
  end
  
  --add in the ??? for a bonus reward if one exists
  if job.BonusReward ~= "" then
	self.reward = self.reward .. ' + ?'
  end
  
  
	self:DrawJob()
  

end

function JobMenu:DrawJob()
  --Standard menu divider. Reuse this whenever you need a menu divider at the top for a title.
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(8, 8 + 12), self.menu.Bounds.Width - 8 * 2))

  --Standard title. Reuse this whenever a title is needed.
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText("Job Summary", RogueElements.Loc(16, 8)))
  
  --Accepted element 
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(8, self.menu.Bounds.Height - 24), self.menu.Bounds.Width - 8 * 2))
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText("Accepted: " .. self.taken_count .. "/8", RogueElements.Loc(96, self.menu.Bounds.Height - 20)))


  
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(self.flavor, RogueElements.Loc(16, 24)))
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText("Client:", RogueElements.Loc(16, 54)))
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText("Objective:", RogueElements.Loc(16, 68)))
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText("Place:", RogueElements.Loc(16, 82)))
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText("Difficulty:", RogueElements.Loc(16, 96)))
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText("Reward:", RogueElements.Loc(16, 110))) 

  local client = self.client 
  client = string.gsub(client, "Magna", "Magnezone")
  
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(client, RogueElements.Loc(68, 54)))
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(self.objective, RogueElements.Loc(68, 68)))
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(self.zone .. " " .. self.floor, RogueElements.Loc(68, 82)))
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(self.difficulty, RogueElements.Loc(68, 96)))
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(self.reward, RogueElements.Loc(68, 110)))
end 



--for use with submenu
function JobMenu:DeleteJob()
	local mission = SV.TakenBoard[self.job_number]
	local back_ref = mission.BackReference
	PrintInfo("Restoring taken from backref "..back_ref)
	if back_ref > 0 and back_ref ~= nil then
		local outlaw_arr = {
			COMMON.MISSION_TYPE_OUTLAW,
			COMMON.MISSION_TYPE_OUTLAW_ITEM,
			COMMON.MISSION_TYPE_OUTLAW_FLEE,
			COMMON.MISSION_TYPE_OUTLAW_MONSTER_HOUSE
		}

		--Outlaw missions are now part of the normal board
		SV.MissionBoard[back_ref].Taken = false
	end 
	
	SV.TakenBoard[self.job_number] = {
										Client = "",
										Target = "",
										Flavor = "",
										Title = "",
										Zone = "",
										Segment = -1,
										Floor = -1,
										Reward = "",
										Type = -1,
										Completion = -1,
										Taken = false,
										Difficulty = "",
										Item = "",
										Special = "",
										ClientGender = -1,
										TargetGender = -1,
										BonusReward = "",
										BackReference = -1
									}
	
	MISSION_GEN.SortTaken()
	if self.parent_board_menu ~= nil then 		
		--redraw board with potentially changed information from job board
		self.parent_board_menu.menu.MenuElements:Clear()
		self.parent_board_menu:RefreshSelf()
		self.parent_board_menu:DrawBoard()
		
		--redraw selection board with potentially changed information
		if self.parent_board_menu.parent_selection_menu ~= nil then 
			self.parent_board_menu.parent_selection_menu.menu.MenuElements:Clear()
			self.parent_board_menu.parent_selection_menu:DrawMenu()
		end
		
	end
	_MENU:RemoveMenu()
	
	--If we accessed the job via the main menu, then close the main menu if we've deleted our last job. Only need it here because only on total job deletion should the main menu ever need to change.
	if self.parent_board_menu.parent_main_menu ~= nil then 
		if self.taken_count == 1 then--1 instead of 0 as the taken_count of the last job that was just deleted would be 1
			_MENU:RemoveMenu()
		end
	end
	
end

--for use with submenu
--flips taken status of self, and also updates the appropriate SV var's taken value
function JobMenu:FlipTakenStatus()
	self.taken = not self.taken
	if self.job_type == COMMON.MISSION_BOARD_TAKEN then
		SV.TakenBoard[self.job_number].Taken = self.taken
	elseif self.job_type == COMMON.MISSION_BOARD_OUTLAW then
		SV.OutlawBoard[self.job_number].Taken = self.taken
	else 
		SV.MissionBoard[self.job_number].Taken = self.taken
	end
	if self.parent_board_menu ~= nil then 
		--redraw board with potentially changed information from job board
		self.parent_board_menu.menu.MenuElements:Clear()
		self.parent_board_menu:RefreshSelf()
		self.parent_board_menu:DrawBoard()
	end
end 

--for use with submenu
--adds the current job to the taken board, then sorts it. Then close the menu
function JobMenu:AddJobToTaken()
	--find an empty job slot
	local freeIndex = MISSION_GEN.FindFreeSpaceInBoard(SV.TakenBoard)
	if freeIndex > -1 then
		if self.job_type == COMMON.MISSION_BOARD_OUTLAW then
			--Need to copy the table rather than just pass the pointer, or you can dupe missions which is not good
			SV.TakenBoard[freeIndex] = MISSION_GEN.ShallowCopy(SV.OutlawBoard[self.job_number])
		elseif self.job_type == COMMON.MISSION_BOARD_MISSION then
			SV.TakenBoard[freeIndex] = MISSION_GEN.ShallowCopy(SV.MissionBoard[self.job_number])
		end 
		SV.TakenBoard[freeIndex].BackReference = self.job_number
		MISSION_GEN.SortTaken()
	end
	
	if self.parent_board_menu ~= nil then 
		--redraw board with potentially changed information from job board
		self.parent_board_menu.menu.MenuElements:Clear()
		self.parent_board_menu:RefreshSelf()
		self.parent_board_menu:DrawBoard()
		
		--redraw selection board with potentially changed information
		if self.parent_board_menu.parent_selection_menu ~= nil then 
			self.parent_board_menu.parent_selection_menu.menu.MenuElements:Clear()
			self.parent_board_menu.parent_selection_menu:DrawMenu()
		end
	end
	

	_MENU:RemoveMenu()
end

function JobMenu:OpenSubMenu()
	if self.job_type ~= COMMON.MISSION_BOARD_TAKEN and self.taken then 
		--This is a job from the board that was already taken!
	else 
		--create prompt menu
		local choices = {}
		--print(self.job_type .. " taken: " .. tostring(self.taken))
		if self.job_type == COMMON.MISSION_BOARD_TAKEN then
			local choice_str = "Take Job"
			if self.taken then
				choice_str = 'Suspend'
			end
			choices = {	{choice_str, true, function() self:FlipTakenStatus() _MENU:RemoveMenu() _MENU:RemoveMenu() end},
						{"Delete", true, function() self:DeleteJob() _MENU:RemoveMenu() end},
						{"Cancel", true, function() _MENU:RemoveMenu() _MENU:RemoveMenu() end} }
			
		else --outlaw/mission boards
			--we already made a check above to see if this is a job board and not taken 
			--only selectable if there's room on the taken board for the job and we haven't already taken this mission
			choices = {{"Take Job", MISSION_GEN.IsBoardFull(SV.TakenBoard) == false and not self.taken, function() self:FlipTakenStatus() 
																								 self:AddJobToTaken() _MENU:RemoveMenu() end },
					   {"Cancel", true, function() _MENU:RemoveMenu() _MENU:RemoveMenu() end} }
		end 
	
		submenu = RogueEssence.Menu.ScriptableSingleStripMenu(232, 138, 24, choices, 0, function() _MENU:RemoveMenu() _MENU:RemoveMenu() end) 
		_MENU:AddMenu(submenu, true)
		
	end
end

function JobMenu:Update(input)
    assert(self, "BaseState:Begin(): Error, self is nil!")
  if input:JustPressed(RogueEssence.FrameInput.InputType.Confirm) then  
	if self.job_type ~= COMMON.MISSION_BOARD_TAKEN and self.taken then 
		--This is a job from the board that was already taken! Play a cancel noise.
		_GAME:SE("Menu/Cancel")
	else 
		--This job has not yet been taken.  This block will never be hit because the submenu will automatically open.
	end
  elseif input:JustPressed(RogueEssence.FrameInput.InputType.Cancel) or input:JustPressed(RogueEssence.FrameInput.InputType.Menu) then
    _GAME:SE("Menu/Cancel")
    _MENU:RemoveMenu()
	--open job menu for that particular job
  else

  end
end 



BoardMenu = Class('BoardMenu')

--board type should be taken, mission, or outlaw 
function BoardMenu:initialize(board_type, parent_selection_menu, parent_main_menu)
  assert(self, "BoardMenu:initialize(): Error, self is nil!")

	self.menu = RogueEssence.Menu.ScriptableMenu(32, 32, 256, 176, function(input) self:Update(input) end)
	self.cursor = RogueEssence.Menu.MenuCursor(self.menu)

	self.board_type = board_type

	--For refreshing the parent selection menu
	self.parent_selection_menu = parent_selection_menu

	--for refreshing the main menu (esc menu) if we accessed the board menu via that
	self.parent_main_menu = parent_main_menu
	
	local source_board = SV.MissionBoard
	
	print("Debug: Refreshing self!")
	if self.board_type == COMMON.MISSION_BOARD_TAKEN then
		source_board = SV.TakenBoard
	elseif self.board_type == COMMON.MISSION_BOARD_OUTLAW then
		source_board = SV.OutlawBoard
	end
	print("Boardtype: " .. self.board_type)
	
	self.total_items = 0
	self.jobs = {}
	self.original_menu_index = {}
	
	--get total job count and add jobs to self.jobs
	for i = #source_board, 1, -1 do
		if source_board[i].Client ~= "" then
			self.total_items = self.total_items + 1
			self.jobs[self.total_items] = source_board[i]
			self.original_menu_index[self.total_items] = i
		end
	end
  
  self.current_item = 0
  self.cursor.Loc = RogueElements.Loc(9, 27)
  self.page = 1--1 or 2
  self.taken_count = MISSION_GEN.GetTakenCount()
  self.total_pages = math.ceil(self.total_items / 4)


  self:DrawBoard()

end

--refresh information from results of job menu
function BoardMenu:RefreshSelf()
  local source_board = SV.MissionBoard
	
  if self.board_type == COMMON.MISSION_BOARD_TAKEN then 
	  source_board = SV.TakenBoard
  elseif self.board_type == COMMON.MISSION_BOARD_OUTLAW then
	  source_board = SV.OutlawBoard
  end
  PrintInfo("Boardtype: " .. self.board_type)
  
  self.total_items = 0
  self.jobs = {}
  self.original_menu_index = {}
	
  --get total job count and add jobs to self.jobs
  for i = #source_board, 1, -1 do 
	if source_board[i].Client ~= "" then
		self.total_items = self.total_items + 1
		self.jobs[self.total_items] = source_board[i]
		self.original_menu_index[self.total_items] = i

		local taken_string = 'false'

		if source_board[i].Taken then
			taken_string = 'true'
		end
		PrintInfo("Debug: Refreshing from source board index "..i)
	end
  end
 
  --in the event of deleting the last item on the board, move the cursor to accomodate.
  if self:GetSelectedJobIndex() > self.total_items then 
	print("On refresh self, needed to adjust current item!")
	self.current_item = (self.total_items - 1) % 4
	
	--move cursor to reflect new current item location
	self.cursor:ResetTimeOffset()
    self.cursor.Loc = RogueElements.Loc(9, 27 + 28 * self.current_item)
  end
  
  self.total_pages = math.ceil(self.total_items / 4)

  --go to page 1 if we now only have 1 page
  if self.page == 2 and self.total_pages == 1 then
	self.page = 1
  end

  --refresh taken count
  self.taken_count = MISSION_GEN.GetTakenCount()
  
  --if there are no more missions and we're on the taken screen, close the menu.  
  if MISSION_GEN.TakenBoardIsEmpty() and self.board_type == COMMON.MISSION_BOARD_TAKEN then 
	  _MENU:RemoveMenu()
  end
end 


--NOTE: Board is hardcoded to have 4 items a page, and only to have up to 8 total items to display.
--If you want to edit this, you'll probably have to change most instances of the number 4 here and some references to page. Sorry!
function BoardMenu:DrawBoard()
  --Standard menu divider. Reuse this whenever you need a menu divider at the top for a title.
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(8, 8 + 12), self.menu.Bounds.Width - 8 * 2))

  --Standard title. Reuse this whenever a title is needed.
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText("Notice Board", RogueElements.Loc(16, 8)))
  
  --page element
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText("(" .. tostring(self.page) .. "/" .. tostring(self.total_pages) .. ")", RogueElements.Loc(self.menu.Bounds.Width - 35, 8)))

	
  --Accepted element 
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(8, self.menu.Bounds.Height - 24), self.menu.Bounds.Width - 8 * 2))
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText("Accepted: " .. tostring(self.taken_count) .. "/8", RogueElements.Loc(96, self.menu.Bounds.Height - 20)))


  self.menu.MenuElements:Add(self.cursor)
  
  --populate 4 self.jobs on a page
  for i = (4 * self.page) - 3, 4 * self.page, 1 do 
	if i > #self.jobs then break end
	  
    if self.jobs[i].Client ~= "" then
		local title = self.jobs[i].Title
		
		local taken_string = 'false'

		if self.jobs[i].Taken then
			taken_string = 'true'
		end

		PrintInfo("Creating board job for title "..title.." and zone "..self.jobs[i].Zone.." and segment "..self.jobs[i].Segment.." and taken "..taken_string)

		local zone = _DATA:GetZone(self.jobs[i].Zone).Segments[self.jobs[i].Segment]:ToString()
		zone = COMMON.CreateColoredSegmentString(zone)
		local floor =  MISSION_GEN.GetStairsType(self.jobs[i].Zone) ..'[color=#00FFFF]' .. tostring(self.jobs[i].Floor) .. "[color]F"
		local difficulty = ""
		
		--create difficulty string
		local difficult_string = MISSION_GEN.GetDifficultyString(self.jobs[i].Difficulty)

		difficulty = MISSION_GEN.DIFF_TO_COLOR[self.jobs[i].Difficulty] .. difficult_string .. "[color]"
		
		local icon = ""
		if self.board_type == COMMON.MISSION_BOARD_TAKEN then
			if self.jobs[i].Taken then
				icon = STRINGS:Format("\\uE10F")--open letter
			else
				icon = STRINGS:Format("\\uE10E")--closed letter
			end
		else
			if self.jobs[i].Taken then
				icon = STRINGS:Format("\\uE10E")--closed letter
			else
				icon = STRINGS:Format("\\uE110")--paper
			end
		end

		local location = zone .. " " .. floor


		--color everything red if job is taken and this is a job board
		if self.jobs[i].Taken and self.board_type ~= COMMON.MISSION_BOARD_TAKEN then
			location = string.gsub(location, '%b[]', '')
			title = string.gsub(title, '%b[]', '')
			difficulty = string.gsub(difficulty, '%b[]', '')

			difficulty = "[color=#FF0000]" .. difficulty .. "[color]"
			title = "[color=#FF0000]" .. title .. "[color]"
			location = "[color=#FF0000]" .. location .. "[color]"
		end

		--modulo the iterator so that if we're on the 2nd page it goes to the right spot

		self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(icon, RogueElements.Loc(21, 26 + 28 * ((i-1) % 4))))
		self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(title, RogueElements.Loc(33, 26 + 28 * ((i-1) % 4))))
		self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(location, RogueElements.Loc(33, 38 + 28 * ((i-1) % 4))))
		self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(difficulty, RogueElements.Loc(self.menu.Bounds.Width - 33, 38 + 28 * ((i-1) % 4))))
	end 
  end
end 


function BoardMenu:Update(input)
    assert(self, "BaseState:Begin(): Error, self is nil!")
  if input:JustPressed(RogueEssence.FrameInput.InputType.Confirm) then
	--open the selected job menu
	_GAME:SE("Menu/Confirm")
	local job_menu = JobMenu:new(self.board_type, self:GetOriginalSelectedJobIndex(), self)
	_MENU:AddMenu(job_menu.menu, false)
	job_menu:OpenSubMenu()
  elseif input:JustPressed(RogueEssence.FrameInput.InputType.Cancel) or input:JustPressed(RogueEssence.FrameInput.InputType.Menu) then
    _GAME:SE("Menu/Cancel")
    _MENU:RemoveMenu()
	--open job menu for that particular job
  else
    moved = false
    if RogueEssence.Menu.InteractableMenu.IsInputting(input, LUA_ENGINE:MakeLuaArray(Dir8, { Dir8.Down, Dir8.DownLeft, Dir8.DownRight })) then
      moved = true
      self.current_item = (self.current_item + 1) % 4
	  
	  --if we try to move the cursor to an empty slot on a down press, then move it to the space for the first job on the page.
	  if self:GetSelectedJobIndex() > self.total_items then 
		local new_current = 0
		--undo moved flag if we didn't actually move
		if new_current == (self.current_item - 1) % 4 then
			moved = false
		end
		self.current_item = new_current
	  end
	  
    elseif RogueEssence.Menu.InteractableMenu.IsInputting(input, LUA_ENGINE:MakeLuaArray(Dir8, { Dir8.Up, Dir8.UpLeft, Dir8.UpRight })) then
      moved = true
      self.current_item = (self.current_item - 1) % 4
	  
	  --if we try to move the cursor to an empty slot on an up press, then move it to the space for the last job on the page.
	  if self:GetSelectedJobIndex() > self.total_items then 
		local new_current = (self.total_items % 4) - 1
		--undo moved flag if we didn't actually move
		if new_current == (self.current_item + 1 ) % 4 then
			moved = false
		end
		self.current_item = new_current
	  end
	  
	elseif RogueEssence.Menu.InteractableMenu.IsInputting(input, LUA_ENGINE:MakeLuaArray(Dir8, {Dir8.Left, Dir8.Right})) then
	  --go to other menu if there are more options on the 2nd menu
	  if self.total_pages > 1 then 
	    --change the page
	    if self.page == 1 then self.page = 2 else self.page = 1 end
		moved = true
		
	  --if we try to move the cursor to an empty slot on a side press, then move it to the space for the last job on the page.
	    if self:GetSelectedJobIndex() > self.total_items then 
			local new_current = (self.total_items % 4) - 1
			self.current_item = new_current
		end
		
		
		self.menu.MenuElements:Clear()
		self:DrawBoard()
	  end
    end
    if moved then
      _GAME:SE("Menu/Select")
      self.cursor:ResetTimeOffset()
      self.cursor.Loc = RogueElements.Loc(9, 27 + 28 * self.current_item)
    end
  end
end 

--gets current job index based on the current item and the page. if self.page is 2, and current item is 0, returned answer should be 5.
function BoardMenu:GetSelectedJobIndex()
	return self.current_item + (4 * (self.page - 1) + 1)
end

--gets current job index based on the current item and the page, then translates it to the correct index in its original menu
function BoardMenu:GetOriginalSelectedJobIndex()
	return self.original_menu_index[self:GetSelectedJobIndex()]
end







------------------------
-- Board Selection Menu
------------------------
BoardSelectionMenu = Class('BoardSelectionMenu')

--Used to choose between viewing the board, your job list, or to cancel
function BoardSelectionMenu:initialize(board_type)
  assert(self, "BoardSelectionMenu:initialize(): Error, self is nil!")
  
  --I'm bad at this. Need different menu sizes depending on the board 
  if board_type == COMMON.MISSION_BOARD_OUTLAW then
	self.menu = RogueEssence.Menu.ScriptableMenu(24, 22, 128, 60, function(input) self:Update(input) end)
  else
  	self.menu = RogueEssence.Menu.ScriptableMenu(24, 22, 119, 60, function(input) self:Update(input) end)

  end 
  self.cursor = RogueEssence.Menu.MenuCursor(self.menu)
  self.board_type = board_type
  
  self.current_item = 0
  self.cursor.Loc = RogueElements.Loc(9, 8)
  
  self:DrawMenu()

end

--refreshes information and draws to the menu. This is important in case there's a change to the taken board
function BoardSelectionMenu:DrawMenu()
  
  --color this red if there's no jobs and mark there's no jobs to view.
  self.board_populated = true
  local board_name = ""
  if self.board_type == COMMON.MISSION_BOARD_OUTLAW then
	if SV.OutlawBoard[1].Client == '' then 
		board_name = "[color=#FF0000]Outlaw Notice Board[color]"
		self.board_populated = false
	else
		board_name = "Outlaw Notice Board" 
	end
  else
	if MISSION_GEN.MissionBoardIsEmpty() then 
		board_name = "[color=#FF0000]Job Bulletin Board[color]"
		self.board_populated = false
	else
		board_name = "Job Bulletin Board" 
	end	
  end
  
  --color this red if there's no jobs, mark there's no jobs taken
  self.job_list = "Job List"
  self.taken_populated = true 
  if MISSION_GEN.TakenBoardIsEmpty() then
	self.job_list = "[color=#FF0000]Job List[color]"
	self.taken_populated = false 
  end
  
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(board_name, RogueElements.Loc(21, 8)))
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(self.job_list, RogueElements.Loc(21, 22)))
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText("Exit", RogueElements.Loc(21, 36)))

  self.menu.MenuElements:Add(self.cursor)
end 


function BoardSelectionMenu:Update(input)

 if input:JustPressed(RogueEssence.FrameInput.InputType.Confirm) then
	if self.current_item == 0 then --open relevant job menu 
		if self.board_populated then 
			_GAME:SE("Menu/Confirm")
			local board_menu = BoardMenu:new(self.board_type, self)
			_MENU:AddMenu(board_menu.menu, false)
		else
			_GAME:SE("Menu/Cancel")
		end
	elseif self.current_item == 1 then--open taken missions
		if self.taken_populated then
			_GAME:SE("Menu/Confirm")
			local board_menu = BoardMenu:new(COMMON.MISSION_BOARD_TAKEN, self)
			_MENU:AddMenu(board_menu.menu, false)
		else
		    _GAME:SE("Menu/Cancel")
		end
	else 
		_GAME:SE("Menu/Cancel")
		_MENU:RemoveMenu()
	end 
  elseif input:JustPressed(RogueEssence.FrameInput.InputType.Cancel) or input:JustPressed(RogueEssence.FrameInput.InputType.Menu) then
    _GAME:SE("Menu/Cancel")
    _MENU:RemoveMenu()
	--open job menu for that particular job
  else
    moved = false
    if RogueEssence.Menu.InteractableMenu.IsInputting(input, LUA_ENGINE:MakeLuaArray(Dir8, { Dir8.Down, Dir8.DownLeft, Dir8.DownRight })) then
      moved = true
      self.current_item = (self.current_item + 1) % 3
	  
    elseif RogueEssence.Menu.InteractableMenu.IsInputting(input, LUA_ENGINE:MakeLuaArray(Dir8, { Dir8.Up, Dir8.UpLeft, Dir8.UpRight })) then
      moved = true
      self.current_item = (self.current_item - 1) % 3
	end
	
    if moved then
      _GAME:SE("Menu/Select")
      self.cursor:ResetTimeOffset()
      self.cursor.Loc = RogueElements.Loc(9, 8 + 14 * self.current_item)
    end
  end
end 




------------------------
-- DungeonJobList  Menu
------------------------
DungeonJobList = Class('DungeonJobList')

--Used to see what jobs are in this dungeon
function DungeonJobList:initialize()
  assert(self, "DungeonJobList:initialize(): Error, self is nil!")
  
  self.menu = RogueEssence.Menu.ScriptableMenu(32, 32, 256, 176, function(input) self:Update(input) end)
  self.dungeon = ""
  self.section = -1
  
  --This menu should only be accessible from dungeons, but add this as a check just in case we somehow access this menu from outside a dungeon.
  if RogueEssence.GameManager.Instance.CurrentScene == RogueEssence.Dungeon.DungeonScene.Instance then
	self.dungeon = _ZONE.CurrentZoneID
	self.section = _ZONE.CurrentMapID.Segment
  end
  
  self.jobs = SV.TakenBoard
  self.job_count = 0
  
  for i = 1, 8, 1 do
    if SV.TakenBoard[i].Client == "" then 
	  break 
    elseif SV.TakenBoard[i].Zone ~= '' and SV.TakenBoard[i].Zone == self.dungeon then 
	  self.job_count = self.job_count + 1 
	end
  end 
  self:DrawMenu()

end

--refreshes information and draws to the menu. This is important in case there's a change to the taken board
function DungeonJobList:DrawMenu() 
    --Standard menu divider. Reuse this whenever you need a menu divider at the top for a title.
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(8, 8 + 12), self.menu.Bounds.Width - 8 * 2))

  --Standard title. Reuse this whenever a title is needed.
  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText("Mission Objectives", RogueElements.Loc(16, 8)))
  
  --how many jobs have we populated so far
  local count = 0
  local side_dungeon_mission = false
  local zone_string = ''
  
  --populate jobs that are in this dungeon
  for i = 8, 1, -1 do 
	--skip all empty jobs
    if self.jobs[i].Client ~= "" then
		--only look at jobs in the current dungeon that aren't suspended
		if self.jobs[i].Zone == self.dungeon and self.jobs[i].Taken then
			if self.jobs[i].Segment == self.section then
				local floor = MISSION_GEN.GetStairsType(self.jobs[i].Zone) ..'[color=#00FFFF]' .. tostring(self.jobs[i].Floor) .. "[color]F"
				local objective = ""
				local icon = ""
				local goal = self.jobs[i].Type

				local target = _DATA:GetMonster(self.jobs[i].Target):GetColoredName()

				local client = ""
				if self.jobs[i].Client == "magna" then
					client = "[color=#00FFFF]Magna[color]"
				else
					client = _DATA:GetMonster(self.jobs[i].Client):GetColoredName()
				end

				local item = ""
				if self.jobs[i].Item ~= "" then
					item = _DATA:GetItem(self.jobs[i].Item):GetColoredName()
				end

				if goal == COMMON.MISSION_TYPE_RESCUE then
					objective = Text.FormatKey("MISSION_OBJECTIVES_RESCUE", target)
				elseif goal == COMMON.MISSION_TYPE_ESCORT then
					objective = Text.FormatKey("MISSION_OBJECTIVES_ESCORT", client, target)
				elseif goal == COMMON.MISSION_TYPE_OUTLAW then
					objective = Text.FormatKey("MISSION_OBJECTIVES_OUTLAW", target)
				elseif goal == COMMON.MISSION_TYPE_EXPLORATION then
					objective = Text.FormatKey("MISSION_OBJECTIVES_EXPLORATION", client)
				elseif goal == COMMON.MISSION_TYPE_LOST_ITEM then
					objective = Text.FormatKey("MISSION_OBJECTIVES_LOST_ITEM", item, client)
				elseif goal == COMMON.MISSION_TYPE_OUTLAW_ITEM then
					objective = Text.FormatKey("MISSION_OBJECTIVES_OUTLAW_ITEM", item, target)
				elseif goal == COMMON.MISSION_TYPE_OUTLAW_FLEE then
					objective = Text.FormatKey("MISSION_OBJECTIVES_OUTLAW_FLEE", target)
				elseif goal == COMMON.MISSION_TYPE_OUTLAW_MONSTER_HOUSE then
					objective = Text.FormatKey("MISSION_OBJECTIVES_OUTLAW_MONSTER_HOUSE", target)
				elseif goal == COMMON.MISSION_TYPE_DELIVERY then
					objective = Text.FormatKey("MISSION_OBJECTIVES_DELIVERY", item, client)
				end

				if self.jobs[i].Completion == COMMON.MISSION_INCOMPLETE then
					icon = STRINGS:Format("\\uE10F")--open letter
				else
					icon = STRINGS:Format("\\uE10A")--check mark
				end

				self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(icon, RogueElements.Loc(16, 24 + 14 * count)))
				self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(floor, RogueElements.Loc(28, 24 + 14 * count)))
				self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(objective, RogueElements.Loc(60, 24 + 14 * count)))

				count = count + 1
			else
				side_dungeon_mission = true
				zone_string = _DATA:GetZone(self.jobs[i].Zone).Segments[self.jobs[i].Segment]:ToString()
				zone_string = COMMON.CreateColoredSegmentString(zone_string)
			end
			
		end

	end


  end


  --put a special message if no jobs dependent on story progression.
  local message = ""
  if side_dungeon_mission == true and self.section == 0 then
	  message = Text.FormatKey("MISSION_OBJECTIVES_SIDE", zone_string)
	  local yloc = 12 + 14
	  if count > 0 then
		  yloc = 24 + 14 * count
	  end
	  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(message, RogueElements.Loc(16, yloc)))
  elseif count == 0 then
	  message = Text.FormatKey("MISSION_OBJECTIVES_DEFAULT")
	  self.menu.MenuElements:Add(RogueEssence.Menu.MenuText(message, RogueElements.Loc(16, 12 + 14)))
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
  end
end 

--How many missions are taken? Probably shoulda just had a variable that kept track, but oh well...
function MISSION_GEN.GetTakenCount()
	local count = 0
	for i = 1, 8, 1 do
		if SV.TakenBoard[i].Client ~= "" then 
			count = count + 1 
		end 
	end 
	
	return count
end

function MISSION_GEN.RemoveMissionBackReference()
	for mission_num, _ in pairs(SV.TakenBoard) do
		SV.TakenBoard[mission_num].BackReference = -1
	end
end

function MISSION_GEN.EndOfDay(result, segmentID)
	--Mark the current dungeon as visited
	
	local cur_zone_name = _ZONE.CurrentZoneID

	if result == RogueEssence.Data.GameProgress.ResultType.Cleared then
		PrintInfo("Completed zone "..cur_zone_name.." with segment "..segmentID)
		if SV.MissionPrereq.DungeonsCompleted[cur_zone_name] == nil then
			SV.MissionPrereq.DungeonsCompleted[cur_zone_name] = { }
			SV.MissionPrereq.DungeonsCompleted[cur_zone_name][segmentID] = 1
			SV.MissionPrereq.NumDungeonsCompleted = SV.MissionPrereq.NumDungeonsCompleted + 1
		elseif SV.MissionPrereq.DungeonsCompleted[cur_zone_name][segmentID] == nil then
			SV.MissionPrereq.DungeonsCompleted[cur_zone_name][segmentID] = 1
		end
	end
	
	MISSION_GEN.RegenerateJobs(result)
end

function MISSION_GEN.RegenerateJobs(result)
	--Regenerate jobs
	MISSION_GEN.ResetBoards()
	MISSION_GEN.RemoveMissionBackReference()
	MISSION_GEN.GenerateBoard(result, COMMON.MISSION_BOARD_MISSION)
	--MISSION_GEN.GenerateBoard(COMMON.MISSION_BOARD_OUTLAW)
	MISSION_GEN.SortMission()
	MISSION_GEN.SortOutlaw()
end

function MISSION_GEN.GetDebugMissionInfo(board, slot)
	if board == "outlaw" then
		print("client = " .. SV.OutlawBoard[slot].Client)
		print("target = " .. SV.OutlawBoard[slot].Target)
		print("flavor = " .. SV.OutlawBoard[slot].Flavor)
		print("title = " .. SV.OutlawBoard[slot].Title)
		print("zone = " .. SV.OutlawBoard[slot].Zone)
		print("segment = " .. SV.OutlawBoard[slot].Segment)
		print("floor = " .. SV.OutlawBoard[slot].Floor)
		print("reward = " .. SV.OutlawBoard[slot].Reward)
		print("type = " .. SV.OutlawBoard[slot].Type)
		print("Completion = " .. SV.OutlawBoard[slot].Completion)
		print("Taken = " .. tostring(SV.OutlawBoard[slot].Taken))
		print("Difficulty = " .. SV.OutlawBoard[slot].Difficulty)
		print("item = " .. SV.OutlawBoard[slot].Item)
		print("Special = " .. SV.OutlawBoard[slot].Special)
		local client_gender = SV.OutlawBoard[slot].ClientGender
		if client_gender == 1 then
			print("ClientGender = male")
		elseif client_gender == 2 then
			print("ClientGender = female")
		elseif client_gender == 0 then
			print("ClientGender = genderless")
		else 
			print("Non valid gender!!!!!!")
		end
		
		local target_Gender = SV.OutlawBoard[slot].ClientGender
		if target_Gender == 1 then
			print("TargetGender = male")
		elseif target_Gender == 2 then
			print("TargetGender = female")
		elseif target_Gender == 0 then
			print("TargetGender = genderless")
		else 
			print("Non valid gender!!!!!!")
		end
		print("Bonus = " .. SV.OutlawBoard[slot].BonusReward)

	elseif board == "mission" then
		print("client = " .. SV.MissionBoard[slot].Client)
		print("target = " .. SV.MissionBoard[slot].Target)
		print("flavor = " .. SV.MissionBoard[slot].Flavor)
		print("title = " .. SV.MissionBoard[slot].Title)
		print("zone = " .. SV.MissionBoard[slot].Zone)
		print("segment = " .. SV.MissionBoard[slot].Segment)
		print("floor = " .. SV.MissionBoard[slot].Floor)
		print("reward = " .. SV.MissionBoard[slot].Reward)
		print("type = " .. SV.MissionBoard[slot].Type)
		print("Completion = " .. SV.MissionBoard[slot].Completion)
		print("Taken = " .. tostring(SV.MissionBoard[slot].Taken))
		print("Difficulty = " .. SV.MissionBoard[slot].Difficulty)
		print("item = " .. SV.MissionBoard[slot].Item)
		print("Special = " .. SV.MissionBoard[slot].Special)
		local client_gender = SV.MissionBoard[slot].ClientGender
		if client_gender == 1 then
			print("ClientGender = male")
		elseif client_gender == 2 then
			print("ClientGender = female")
		elseif client_gender == 0 then
			print("ClientGender = genderless")
		else 
			print("Non valid gender!!!!!!")
		end
		
		local target_Gender = SV.MissionBoard[slot].ClientGender
		if target_Gender == 1 then
			print("TargetGender = male")
		elseif target_Gender == 2 then
			print("TargetGender = female")
		elseif target_Gender == 0 then
			print("TargetGender = genderless")
		else 
			print("Non valid gender!!!!!!")
		end
		print("Bonus = " .. SV.MissionBoard[slot].BonusReward)
	else
		print("client = " .. SV.TakenBoard[slot].Client)
		print("target = " .. SV.TakenBoard[slot].Target)
		print("flavor = " .. SV.TakenBoard[slot].Flavor)
		print("title = " .. SV.TakenBoard[slot].Title)
		print("zone = " .. SV.TakenBoard[slot].Zone)
		print("segment = " .. SV.TakenBoard[slot].Segment)
		print("floor = " .. SV.TakenBoard[slot].Floor)
		print("reward = " .. SV.TakenBoard[slot].Reward)
		print("type = " .. SV.TakenBoard[slot].Type)
		print("Completion = " .. SV.TakenBoard[slot].Completion)
		print("Taken = " .. tostring(SV.TakenBoard[slot].Taken))
		print("Difficulty = " .. SV.TakenBoard[slot].Difficulty)
		print("item = " .. SV.TakenBoard[slot].Item)
		print("Special = " .. SV.TakenBoard[slot].Special)
		print("BackReference = " .. SV.TakenBoard[slot].BackReference)
		local client_gender = SV.TakenBoard[slot].ClientGender
		if client_gender == 1 then
			print("ClientGender = male")
		elseif client_gender == 2 then
			print("ClientGender = female")
		elseif client_gender == 0 then
			print("ClientGender = genderless")
		else 
			print("Non valid gender!!!!!!")
		end
		
		local target_Gender = SV.TakenBoard[slot].ClientGender
		if target_Gender == 1 then
			print("TargetGender = male")
		elseif target_Gender == 2 then
			print("TargetGender = female")
		elseif target_Gender == 0 then
			print("TargetGender = genderless")
		else 
			print("Non valid gender!!!!!!")
		end
		print("Bonus = " .. SV.TakenBoard[slot].BonusReward)
	end
end