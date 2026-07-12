--[[
    common_shop.lua
    Shop items
]]--

COMMON.ESSENTIALS = {
  { Index = "food_apple", Amount = 0, Price = 50},
  { Index = "food_apple_big", Amount = 0, Price = 150},
  { Index = "food_banana", Amount = 0, Price = 500},
  { Index = "berry_oran", Amount = 0, Price = 80},
  { Index = "berry_leppa", Amount = 0, Price = 80},
  { Index = "berry_lum", Amount = 0, Price = 120},
  { Index = "seed_reviver", Amount = 0, Price = 500},
  { Index = "apricorn_plain", Amount = 0, Price = 400},
  { Index = "apricorn_plain", Amount = 0, Price = 400}
}
  
COMMON.UTILITIES = {
  { Index = "berry_jaboca", Amount = 0, Price = 100},
  { Index = "berry_rowap", Amount = 0, Price = 100},
  { Index = "seed_warp", Amount = 0, Price = 80},
  { Index = "seed_sleep", Amount = 0, Price = 80},
  { Index = "seed_blast", Amount = 0, Price = 200},
  { Index = "seed_blinker", Amount = 0, Price = 80},
  { Index = "seed_vile", Amount = 0, Price = 80},
  { Index = "seed_ice", Amount = 0, Price = 80},
  { Index = "seed_decoy", Amount = 0, Price = 80},
  { Index = "seed_last_chance", Amount = 0, Price = 150},
  { Index = "seed_ban", Amount = 0, Price = 150},
  { Index = "herb_mental", Amount = 0, Price = 120},
  { Index = "herb_power", Amount = 0, Price = 250},
  { Index = "herb_white", Amount = 0, Price = 80}
}
  
COMMON.AMMO = {
  { Index = "ammo_stick", Amount = 9, Price = 45},
  { Index = "ammo_cacnea_spike", Amount = 9, Price = 90},
  { Index = "ammo_corsola_twig", Amount = 9, Price = 90},
  { Index = "ammo_iron_thorn", Amount = 9, Price = 90},
  { Index = "ammo_silver_spike", Amount = 9, Price = 360},
  { Index = "ammo_geo_pebble", Amount = 9, Price = 45},
  { Index = "ammo_gravelerock", Amount = 9, Price = 90},
  { Index = "wand_path", Amount = 9, Price = 180},
  { Index = "wand_pounce", Amount = 9, Price = 180},
  { Index = "wand_whirlwind", Amount = 9, Price = 180},
  { Index = "wand_switcher", Amount = 9, Price = 180},
  { Index = "wand_lure", Amount = 9, Price = 180},
  { Index = "wand_slow", Amount = 9, Price = 180},
  { Index = "wand_fear", Amount = 9, Price = 180},
  { Index = "wand_topsy_turvy", Amount = 9, Price = 180},
  { Index = "wand_warp", Amount = 9, Price = 180},
  { Index = "wand_purge", Amount = 9, Price = 180},
  { Index = "wand_lob", Amount = 9, Price = 180}
}
COMMON.ORBS = {
  { Index = "orb_weather", Amount = 0, Price = 150},
  { Index = "orb_mobile", Amount = 0, Price = 250},
  { Index = "orb_fill_in", Amount = 0, Price = 250},
  { Index = "orb_all_aim", Amount = 0, Price = 150},
  { Index = "orb_scanner", Amount = 0, Price = 350},
  { Index = "orb_cleanse", Amount = 0, Price = 150},
  { Index = "orb_one_shot", Amount = 0, Price = 300},
  { Index = "orb_endure", Amount = 0, Price = 150},
  { Index = "orb_pierce", Amount = 0, Price = 150},
  { Index = "orb_all_protect", Amount = 0, Price = 250},
  { Index = "orb_trap_see", Amount = 0, Price = 200},
  { Index = "orb_trapbust", Amount = 0, Price = 200},
  { Index = "orb_slumber", Amount = 0, Price = 250},
  { Index = "orb_totter", Amount = 0, Price = 250},
  { Index = "orb_petrify", Amount = 0, Price = 250},
  { Index = "orb_freeze", Amount = 0, Price = 250},
  { Index = "orb_spurn", Amount = 0, Price = 250},
  { Index = "orb_foe_hold", Amount = 0, Price = 250},
  { Index = "orb_nullify", Amount = 0, Price = 250},
  { Index = "orb_all_dodge", Amount = 0, Price = 150},
  { Index = "orb_slow", Amount = 0, Price = 250},
  { Index = "orb_rebound", Amount = 0, Price = 150},
  { Index = "orb_mirror", Amount = 0, Price = 150},
  { Index = "orb_foe_seal", Amount = 0, Price = 250},
  { Index = "orb_halving", Amount = 0, Price = 250},
  { Index = "orb_rollcall", Amount = 0, Price = 150},
  { Index = "orb_mug", Amount = 0, Price = 250}
}
  
COMMON.SPECIAL = {
  { Index = "key", Amount = 3, Price = 4000},
  { Index = "machine_storage_box", Amount = 3, Price = 1200},
  { Index = "orb_revival", Amount = 0, Price = 1000},
  { Index = "orb_escape", Amount = 0, Price = 150},
  { Index = "orb_escape", Amount = 0, Price = 150}
}

COMMON.JUICE = {}
COMMON.JUICE.BOOSTS = {
  --{ Level = 0, EXP = 100, HP = 0, Atk = 0, Def = 0, SpAtk = 0, SpDef = 0, Speed = 0, NegateExp = false, NegateStat = false, GummiEffect = nil}
  food_apple = { EXP = 100 },
  food_apple_big = { EXP = 300 },
  food_apple_huge = { EXP = 2500 },
  food_apple_perfect = { EXP = 25000 },
  food_apple_golden = { Level = 100 },
  food_banana = { EXP = 1000 },
  food_banana_big = { EXP = 5000 },
  food_banana_golden = { Level = 100 },

  berry_oran = { HP = 1 },
  berry_leppa = { HP = 1 },
  berry_sitrus = { HP = 1 },
  berry_lum = { HP = 1 },

  berry_passho = { HP = 1 },
  berry_colbur = { HP = 1 },
  berry_yache = { SpDef = 1 },
  berry_rindo = { SpDef = 1 },
  berry_tanga = { Speed = 1 },
  berry_shuca = { Atk = 1 },
  berry_chople = { Atk = 1 },
  berry_payapa = { SpAtk = 1 },
  berry_kebia = { Def = 1 },
  berry_kasib = { SpAtk = 1 },
  berry_occa = { SpAtk = 1 },
  berry_haban = { Atk = 1 },
  berry_babiri = { Def = 1 },
  berry_chilan = { HP = 1 },
  berry_wacan = { Speed = 1 },
  berry_coba = { Speed = 1 },
  berry_charti = { Def = 1 },
  berry_roseli = { SpDef = 1 },

  berry_jaboca = { Def = 1 },
  berry_rowap = { SpDef = 1 },

  berry_liechi = { Atk = 2 },
  berry_ganlon = { Def = 2 },
  berry_petaya = { SpAtk = 2 },
  berry_apicot = { SpDef = 2 },
  berry_salac = { Speed = 2 },
  berry_starf = { HP = 2 },
  berry_micle = { Atk = 1, SpAtk = 1 },

  berry_enigma = { HP = 1 },

  gummi_wonder = { HP = 2, Atk = 2, Def = 2, SpAtk = 2, SpDef = 2, Speed = 2 },

  gummi_blue = { HP = 2, GummiEffect = 'water' },
  gummi_black = { HP = 2, GummiEffect = 'dark' },
  gummi_clear = { SpDef = 2, GummiEffect = 'ice' },
  gummi_grass = { SpDef = 2, GummiEffect = 'grass' },
  gummi_green = { Speed = 2, GummiEffect = 'bug' },
  gummi_brown = { Atk = 2, GummiEffect = 'ground' },
  gummi_orange = { Atk = 2, GummiEffect = 'fighting' },
  gummi_gold = { SpAtk = 2, GummiEffect = 'psychic' },
  gummi_pink = { Def = 2, GummiEffect = 'poison' },
  gummi_purple = { SpAtk = 2, GummiEffect = 'ghost' },
  gummi_red = { SpAtk = 2, GummiEffect = 'fire' },
  gummi_royal = { Atk = 2, GummiEffect = 'dragon' },
  gummi_silver = { Def = 2, GummiEffect = 'steel' },
  gummi_white = { HP = 2, GummiEffect = 'normal' },
  gummi_yellow = { Speed = 2, GummiEffect = 'electric' },
  gummi_sky = { Speed = 2, GummiEffect = 'flying' },
  gummi_gray = { Def = 2, GummiEffect = 'rock' },
  gummi_magenta = { SpDef = 2, GummiEffect = 'fairy' },

  seed_plain = { EXP = 100 },
  seed_reviver = { EXP = 800 },

  seed_joy = { Level = 1 },
  seed_golden = { Level = 5 },
  seed_doom = { Level = -5 },

  seed_hunger = { EXP = 500 },

  seed_warp = { Speed = 1 },
  seed_sleep = { HP = 1 },
  seed_vile = { Def = 1, SpDef = 1 },
  seed_blast = { Atk = 1 },
  seed_blinker = { Speed = 1 },

  seed_pure = { EXP = 100 },
  seed_ice = { Speed = 1 },
  seed_decoy = { SpDef = 1 },
  seed_last_chance = { Atk = 1, SpAtk = 1 },
  seed_ban = { EXP = 100 },

  boost_nectar = { HP = 1, Atk = 1, Def = 1, SpAtk = 1, SpDef = 1, Speed = 1 },

  boost_hp_up = { HP = 8 },
  boost_protein = { Atk = 8 },
  boost_iron = { Def = 8 },
  boost_calcium = { SpAtk = 8 },
  boost_zinc = { SpDef = 8 },
  boost_carbos = { Speed = 8 },

  medicine_amber_tear = { HP = 1, Atk = 1, Def = 1, SpAtk = 1, SpDef = 1, Speed = 1 },

  herb_mental = { NegateStatA = true },
  herb_power = { NegateStatB = true },
  herb_white = { NegateStatC = true },

  food_grimy = { NegateExp = true },
}

COMMON.JUICE.SPECIALTIES = { 
	{ 
		Name = "Ambrosia",
		Desc = "Flavor Text here. Boosts level to 100 and maximizes all stats.",
		Sizes = 
		{
			{ Name = "One Size for All", Desc = "Boosts level to 100 and maximizes all stats.", Effect = { Level = 100, HP = 256, Atk = 256, Def = 256, SpAtk = 256, SpDef = 256, Speed = 256 } }
		}
	},
	{ 
		Name = "+Lv Dish",
		Desc = "Flavor Text here. Increases Level.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Boosts level by 1.", Effect = { Level = 1 } },
			{ Name = "Medium", Desc = "Boosts level by 5.", Effect = { Level = 5 } },
			{ Name = "Large", Desc = "Boosts level by 10.", Effect = { Level = 10 } },
			{ Name = "Super", Desc = "Boosts level by 25.", Effect = { Level = 25 } },
			{ Name = "MAX", Desc = "Boosts level to 100.", Effect = { Level = 100 } }
		}
	},
	{ 
		Name = "+All EV Dish",
		Desc = "Flavor Text here. Increases Stats.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Boosts all stat EVs by 8.", Effect = { HP = 8, Atk = 8, Def = 8, SpAtk = 8, SpDef = 8, Speed = 8 } },
			{ Name = "Medium", Desc = "Boosts all stat EVs by 16.", Effect = { HP = 16, Atk = 16, Def = 16, SpAtk = 16, SpDef = 16, Speed = 16 } },
			{ Name = "Large", Desc = "Boosts all stat EVs by 32.", Effect = { HP = 32, Atk = 32, Def = 32, SpAtk = 32, SpDef = 32, Speed = 32 } },
			{ Name = "Super", Desc = "Boosts all stat EVs by 64.", Effect = { HP = 64, Atk = 64, Def = 64, SpAtk = 64, SpDef = 64, Speed = 64 } },
			{ Name = "MAX", Desc = "Maximizes all stats.", Effect = { HP = 256, Atk = 256, Def = 256, SpAtk = 256, SpDef = 256, Speed = 256 } }
		}
	},
	{ 
		Name = "+HP EV Dish",
		Desc = "Flavor Text here. Increases HP.",
		Sizes =
		{
			{ Name = "Small", Desc = "Boosts HP EVs by 8.", Effect = { HP = 8 } },
			{ Name = "Medium", Desc = "Boosts HP EVs by 16.", Effect = { HP = 16 } },
			{ Name = "Large", Desc = "Boosts HP EVs by 32.", Effect = { HP = 32 } },
			{ Name = "Super", Desc = "Boosts HP EVs by 64.", Effect = { HP = 64 } },
			{ Name = "MAX", Desc = "Maximizes HP EVs.", Effect = { HP = 256 } }
		}
	},
	{ 
		Name = "+ATK EV Dish",
		Desc = "Flavor Text here. Increases Atk.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Boosts Atk EVs by 8.", Effect = { Atk = 8 } },
			{ Name = "Medium", Desc = "Boosts Atk EVs by 16.", Effect = { Atk = 16 } },
			{ Name = "Large", Desc = "Boosts Atk EVs by 32.", Effect = { Atk = 32 } },
			{ Name = "Super", Desc = "Boosts Atk EVs by 64.", Effect = { Atk = 64 } },
			{ Name = "MAX", Desc = "Maximizes Atk EVs.", Effect = { Atk = 256 } }
		}
	},
	{ 
		Name = "+DEF EV Dish",
		Desc = "Flavor Text here. Increases Def.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Boosts Def EVs by 8.", Effect = { Def = 8 } },
			{ Name = "Medium", Desc = "Boosts Def EVs by 16.", Effect = { Def = 16 } },
			{ Name = "Large", Desc = "Boosts Def EVs by 32.", Effect = { Def = 32 } },
			{ Name = "Super", Desc = "Boosts Def EVs by 64.", Effect = { Def = 64 } },
			{ Name = "MAX", Desc = "Maximizes Def EVs.", Effect = { Def = 256 } }
		}
	},
	{ 
		Name = "+SP.ATK EV Dish",
		Desc = "Flavor Text here. Increases Sp.Atk.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Boosts Sp.Atk EVs by 8.", Effect = { SpAtk = 8 } },
			{ Name = "Medium", Desc = "Boosts Sp.Atk EVs by 16.", Effect = { SpAtk = 16 } },
			{ Name = "Large", Desc = "Boosts Sp.Atk EVs by 32.", Effect = { SpAtk = 32 } },
			{ Name = "Super", Desc = "Boosts Sp.Atk EVs by 64.", Effect = { SpAtk = 64 } },
			{ Name = "MAX", Desc = "Maximizes Sp.Atk EVs.", Effect = { SpAtk = 256 } }
		}
	},
	{ 
		Name = "+SP.DEF EV Dish",
		Desc = "Flavor Text here. Increases Sp.Def.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Boosts Sp.Def EVs by 8.", Effect = { SpDef = 8 } },
			{ Name = "Medium", Desc = "Boosts Sp.Def EVs by 16.", Effect = { SpDef = 16 } },
			{ Name = "Large", Desc = "Boosts Sp.Def EVs by 32.", Effect = { SpDef = 32 } },
			{ Name = "Super", Desc = "Boosts Sp.Def EVs by 64.", Effect = { SpDef = 64 } },
			{ Name = "MAX", Desc = "Maximizes Sp.Def EVs.", Effect = { SpDef = 256 } }
		}
	},
	{ 
		Name = "+SPEED EV Dish",
		Desc = "Flavor Text here. Increases Speed.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Boosts Speed EVs by 8.", Effect = { Speed = 8 } },
			{ Name = "Medium", Desc = "Boosts Speed EVs by 16.", Effect = { Speed = 16 } },
			{ Name = "Large", Desc = "Boosts Speed EVs by 32.", Effect = { Speed = 32 } },
			{ Name = "Super", Desc = "Boosts Speed EVs by 64.", Effect = { Speed = 64 } },
			{ Name = "MAX", Desc = "Maximizes Speed EVs.", Effect = { Speed = 256 } }
		}
	},

	{ 
		Name = "-Lv Dish",
		Desc = "Flavor Text here. Decreases Level.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Boosts level by 1.", Effect = { Level = -1 } },
			{ Name = "Medium", Desc = "Boosts level by 5.", Effect = { Level = -5 } },
			{ Name = "Large", Desc = "Boosts level by 10.", Effect = { Level = -10 } },
			{ Name = "Super", Desc = "Boosts level by 25.", Effect = { Level = -25 } },
			{ Name = "MAX", Desc = "Boosts level to 100.", Effect = { Level = -100 } }
		}
	},
	{ 
		Name = "-All EV Dish",
		Desc = "Flavor Text here. Decreases Stats.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Drops all stat EVs by 8.", Effect = { HP = -8, Atk = -8, Def = -8, SpAtk = -8, SpDef = -8, Speed = -8 } },
			{ Name = "Medium", Desc = "Drops all stat EVs by 16.", Effect = { HP = -16, Atk = -16, Def = -16, SpAtk = -16, SpDef = -16, Speed = -16 } },
			{ Name = "Large", Desc = "Drops all stat EVs by 32.", Effect = { HP = -32, Atk = -32, Def = -32, SpAtk = -32, SpDef = -32, Speed = -32 } },
			{ Name = "Super", Desc = "Drops all stat EVs by 64.", Effect = { HP = -64, Atk = -64, Def = -64, SpAtk = -64, SpDef = -64, Speed = -64 } },
			{ Name = "MAX", Desc = "Clears all stat EVs.", Effect = { HP = -256, Atk = -256, Def = -256, SpAtk = -256, SpDef = -256, Speed = -256 } }
		}
	},
	{ 
		Name = "-HP EV Dish",
		Desc = "Flavor Text here. Decreases HP.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Drops HP EVs by 8.", Effect = { HP = -8 } },
			{ Name = "Medium", Desc = "Drops HP EVs by 16.", Effect = { HP = -16 } },
			{ Name = "Large", Desc = "Drops HP EVs by 32.", Effect = { HP = -32 } },
			{ Name = "Super", Desc = "Drops HP EVs by 64.", Effect = { HP = -64 } },
			{ Name = "MAX", Desc = "Clears all HP EVs.", Effect = { HP = -256 } }
		}
	},
	{ 
		Name = "-ATK EV Dish",
		Desc = "Flavor Text here. Decreases Atk.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Drops Atk EVs by 8.", Effect = { Atk = -8 } },
			{ Name = "Medium", Desc = "Drops Atk EVs by 16.", Effect = { Atk = -16 } },
			{ Name = "Large", Desc = "Drops Atk EVs by 32.", Effect = { Atk = -32 } },
			{ Name = "Super", Desc = "Drops Atk EVs by 64.", Effect = { Atk = -64 } },
			{ Name = "MAX", Desc = "Clears all Atk EVs.", Effect = { Atk = -256 } }
		}
	},
	{ 
		Name = "-DEF EV Dish",
		Desc = "Flavor Text here. Decreases Def.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Drops Def EVs by 8.", Effect = { Def = -8 } },
			{ Name = "Medium", Desc = "Drops Def EVs by 16.", Effect = { Def = -16 } },
			{ Name = "Large", Desc = "Drops Def EVs by 32.", Effect = { Def = -32 } },
			{ Name = "Super", Desc = "Drops Def EVs by 64.", Effect = { Def = -64 } },
			{ Name = "MAX", Desc = "Clears all Def EVs.", Effect = { Def = -256 } }
		}
	},
	{ 
		Name = "-SP.ATK EV Dish",
		Desc = "Flavor Text here. Decreases Sp.Atk.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Drops Sp.Atk EVs by 8.", Effect = { SpAtk = -8 } },
			{ Name = "Medium", Desc = "Drops Sp.Atk EVs by 16.", Effect = { SpAtk = -16 } },
			{ Name = "Large", Desc = "Drops Sp.Atk EVs by 32.", Effect = { SpAtk = -32 } },
			{ Name = "Super", Desc = "Drops Sp.Atk EVs by 64.", Effect = { SpAtk = -64 } },
			{ Name = "MAX", Desc = "Clears all Sp.Atk EVs.", Effect = { SpAtk = -256 } }
		}
	},
	{ 
		Name = "-SP.DEF EV Dish",
		Desc = "Flavor Text here. Decreases Sp.Def.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Drops Sp.Def EVs by 8.", Effect = { SpDef = -8 } },
			{ Name = "Medium", Desc = "Drops Sp.Def EVs by 16.", Effect = { SpDef = -16 } },
			{ Name = "Large", Desc = "Drops Sp.Def EVs by 32.", Effect = { SpDef = -32 } },
			{ Name = "Super", Desc = "Drops Sp.Def EVs by 64.", Effect = { SpDef = -64 } },
			{ Name = "MAX", Desc = "Clears all Sp.Def EVs.", Effect = { SpDef = -256 } }
		}
	},
	{ 
		Name = "-SPEED EV Dish",
		Desc = "Flavor Text here. Decreases Speed.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Drops Speed EVs by 8.", Effect = { Speed = -8 } },
			{ Name = "Medium", Desc = "Drops Speed EVs by 16.", Effect = { Speed = -16 } },
			{ Name = "Large", Desc = "Drops Speed EVs by 32.", Effect = { Speed = -32 } },
			{ Name = "Super", Desc = "Drops Speed EVs by 64.", Effect = { Speed = -64 } },
			{ Name = "MAX", Desc = "Clears all Speed EVs.", Effect = { Speed = -256 } }
		}
	},
	{ 
		Name = "Grimace Shake",
		Desc = "Flavor text here. Removes all EVs and resets level to 1.",
		Sizes = 
		{
			{ Name = "One Size for All", Desc = "Removes all EVs and resets level to 1.", Effect = { Level = -100, HP = -256, Atk = -256, Def = -256, SpAtk = -256, SpDef = -256, Speed = -256 } }
		}
	}
}