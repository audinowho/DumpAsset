require 'common'


ZONE_GEN_SCRIPT = {}

function ZONE_GEN_SCRIPT.Test(zoneContext, context, queue, seed, args)
  PrintInfo("Test")
end

PresetMultiTeamSpawnerType = luanet.import_type('RogueEssence.LevelGen.PresetMultiTeamSpawner`1')
PlaceRandomMobsStepType = luanet.import_type('RogueEssence.LevelGen.PlaceRandomMobsStep`1')
PlaceEntranceMobsStepType = luanet.import_type('RogueEssence.LevelGen.PlaceEntranceMobsStep`2')
MapEffectStepType = luanet.import_type('RogueEssence.LevelGen.MapEffectStep`1')
MapGenContextType = luanet.import_type('RogueEssence.LevelGen.ListMapGenContext')
EntranceType = luanet.import_type('RogueEssence.LevelGen.MapGenEntrance')

function ZONE_GEN_SCRIPT.SpawnMissionNpcFromSV(zoneContext, context, queue, seed, args)
  -- choose a the floor to spawn it on
  local destinationFloor = false
  local outlawFloor = false
  for name, mission in pairs(SV.test_grounds.Missions) do
    PrintInfo("Checking Mission: "..tostring(name))
    if mission.Complete == COMMON.MISSION_INCOMPLETE and zoneContext.CurrentZone == mission.DestZone
	  and zoneContext.CurrentSegment == mission.DestSegment and zoneContext.CurrentID == mission.DestFloor then
      PrintInfo("Spawning Mission Goal")
	  if mission.Type == COMMON.MISSION_TYPE_OUTLAW then -- outlaw
        local specificTeam = RogueEssence.LevelGen.SpecificTeamSpawner()
        local post_mob = RogueEssence.LevelGen.MobSpawn()
        post_mob.BaseForm = RogueEssence.Dungeon.MonsterID(mission.TargetSpecies, 0, 0, Gender.Unknown)
        post_mob.Tactic = 20
        post_mob.Level = RogueElements.RandRange(50)
		post_mob.SpawnFeatures:Add(PMDC.LevelGen.MobSpawnLuaTable('{ Mission = "'..name..'" }'))
	    specificTeam.Spawns:Add(post_mob)
        PrintInfo("Creating Spawn")
        local picker = LUA_ENGINE:MakeGenericType(PresetMultiTeamSpawnerType, { MapGenContextType }, { })
	    picker.Spawns:Add(specificTeam)
        PrintInfo("Creating Step")
        local mobPlacement = LUA_ENGINE:MakeGenericType(PlaceEntranceMobsStepType, { MapGenContextType, EntranceType }, { picker })
        PrintInfo("Enqueueing")
	    -- Priority 5.2.1 is for NPC spawning in PMDO, but any dev can choose to roll with their own standard of priority.
	    local priority = RogueElements.Priority(5, 2, 1)
	    queue:Enqueue(priority, mobPlacement)
        PrintInfo("Done")
	    outlawFloor = true
	  else
        local specificTeam = RogueEssence.LevelGen.SpecificTeamSpawner()
        local post_mob = RogueEssence.LevelGen.MobSpawn()
        post_mob.BaseForm = RogueEssence.Dungeon.MonsterID(mission.TargetSpecies, 0, 0, Gender.Unknown)
        post_mob.Tactic = 21
        post_mob.Level = RogueElements.RandRange(50)
	    if mission.Type == COMMON.MISSION_TYPE_RESCUE then -- rescue
	      local dialogue = RogueEssence.Dungeon.BattleScriptEvent("RescueReached")
          post_mob.SpawnFeatures:Add(PMDC.LevelGen.MobSpawnInteractable(dialogue))
          post_mob.SpawnFeatures:Add(PMDC.LevelGen.MobSpawnLuaTable('{ Mission = "'..name..'" }'))
        elseif mission.Type == COMMON.MISSION_TYPE_ESCORT then -- escort
	      local dialogue = RogueEssence.Dungeon.BattleScriptEvent("EscortRescueReached")
          post_mob.SpawnFeatures:Add(PMDC.LevelGen.MobSpawnInteractable(dialogue))
          post_mob.SpawnFeatures:Add(PMDC.LevelGen.MobSpawnLuaTable('{ Mission = "'..name..'" }'))
	    end
	    specificTeam.Spawns:Add(post_mob)
        PrintInfo("Creating Spawn")
        local picker = LUA_ENGINE:MakeGenericType(PresetMultiTeamSpawnerType, { MapGenContextType }, { })
	    picker.Spawns:Add(specificTeam)
        PrintInfo("Creating Step")
        local mobPlacement = LUA_ENGINE:MakeGenericType(PlaceRandomMobsStepType, { MapGenContextType }, { picker })
        PrintInfo("Setting everything else")
        mobPlacement.Ally = true
        mobPlacement.Filters:Add(PMDC.LevelGen.RoomFilterConnectivity(PMDC.LevelGen.ConnectivityRoom.Connectivity.Main))
        mobPlacement.ClumpFactor = 20
        PrintInfo("Enqueueing")
	    -- Priority 5.2.1 is for NPC spawning in PMDO, but any dev can choose to roll with their own standard of priority.
	    local priority = RogueElements.Priority(5, 2, 1)
	    queue:Enqueue(priority, mobPlacement)
        PrintInfo("Done")
	    destinationFloor = true
	  end
    end
  end
  
  if destinationFloor then
    -- add destination floor notification
    local activeEffect = RogueEssence.Data.ActiveEffect()
    activeEffect.OnMapStarts:Add(-6, RogueEssence.Dungeon.SingleCharScriptEvent("DestinationFloor"))
	local destNote = LUA_ENGINE:MakeGenericType( MapEffectStepType, { MapGenContextType }, { activeEffect })
	local priority = RogueElements.Priority(-6)
	queue:Enqueue(priority, destNote)
  end
  if outlawFloor then
    -- add destination floor notification
    local activeEffect = RogueEssence.Data.ActiveEffect()
    activeEffect.OnMapStarts:Add(-6, RogueEssence.Dungeon.SingleCharScriptEvent("OutlawFloor"))
	local destNote = LUA_ENGINE:MakeGenericType( MapEffectStepType, { MapGenContextType }, { activeEffect })
	local priority = RogueElements.Priority(-6)
	queue:Enqueue(priority, destNote)
  end
end


FLOOR_GEN_SCRIPT = {}

function FLOOR_GEN_SCRIPT.Test(map, args)
  PrintInfo("Test")
  
  --A demo of various tile operations possible with scripting
  
  --Set the top-left corner to room tile. Note that unbreakable blocks are left untouched.
  for xx = 0, map.Width / 2, 1 do
    for yy = 0, map.Height / 2, 1 do
      map:TrySetTile(RogueElements.Loc(xx, yy), map.RoomTerrain)
    end  
  end
  
  --Set the center of the corner to Block tile
  for xx = map.Width / 4 - 1, map.Width / 4 + 1, 1 do
    for yy = map.Height / 4 - 1, map.Height / 4 + 1, 1 do
      map:TrySetTile(RogueElements.Loc(xx, yy), map.WallTerrain)
    end
  end
  
  --set a single coordinate to unbreakable
  map:TrySetTile(RogueElements.Loc(map.Width / 2 - 1, map.Height / 2 - 1), map.UnbreakableTerrain)
  
  --Set the bottom-right corner to water, but only if the existing tiles aren't ground.  MapGenContext has built-in members for Ground, Wall, and Impassable, but the rest must be specified.
  for xx = map.Width / 2, map.Width - 1, 1 do
    for yy = map.Height / 2, map.Height - 1, 1 do
	  local loc = RogueElements.Loc(xx, yy)
	  if not map:GetTile(loc):TileEquivalent(map.RoomTerrain) then
        map:TrySetTile(loc, RogueEssence.Dungeon.Tile(3))
	  end
    end  
  end
  
  --Set the center of the corner to Block tile of a custom tileset.
  for xx = map.Width * 3 / 4 - 1, map.Width * 3 / 4 + 1, 1 do
    for yy = map.Height * 3 / 4 - 1, map.Height * 3 / 4 + 1, 1 do
	  local customTerrain = RogueEssence.Dungeon.Tile(2, true) -- set StableTex to true, which prevents the map's autotexturing
	  customTerrain.Data.TileTex = RogueEssence.Dungeon.AutoTile(6)
      map:TrySetTile(RogueElements.Loc(xx, yy), customTerrain)
    end
  end
  
  --Place a trap on 2,2.  Slumber trap, revealed.
  --map:PlaceItem(RogueElements.Loc(2, 2), RogueEssence.Dungeon.EffectTile(4, true))
  local trap_tile = map:GetTile(RogueElements.Loc(2, 2))
  trap_tile.Effect = RogueEssence.Dungeon.EffectTile(4, true)
  
  --Place item on 3,2.  Banana, sticky
  --map:PlaceItem(RogueElements.Loc(3, 2), RogueEssence.Dungeon.MapItem(6))
  local new_item = RogueEssence.Dungeon.MapItem(6)
  new_item.Cursed = true
  new_item.TileLoc = RogueElements.Loc(3, 2)
  map.Items:Add(new_item)
  
  --Place item on 3,3.  Random amount of G between 50 and 100
  --map:PlaceItem(RogueElements.Loc(3, 3), RogueEssence.Dungeon.MapItem(true, 100))
  new_item = RogueEssence.Dungeon.MapItem(true, map.Rand:Next(50, 101)) -- you must use the map.Rand, or else seeds wont be consistent
  new_item.TileLoc = RogueElements.Loc(3, 3)
  map.Items:Add(new_item)
  
  --Place enemies on 4,4, 4,5, together in a team, with AI of Normal Wander
  local new_team = RogueEssence.Dungeon.MonsterTeam()
  
  local mob_data = RogueEssence.Dungeon.CharData()
  mob_data.BaseForm = RogueEssence.Dungeon.MonsterID(150, 0, 0, Gender.Male)
  mob_data.Level = 20;
  mob_data.BaseSkills[0] = RogueEssence.Dungeon.SlotSkill(1)
  mob_data.BaseSkills[1] = RogueEssence.Dungeon.SlotSkill(2)
  mob_data.BaseSkills[2] = RogueEssence.Dungeon.SlotSkill(3)
  mob_data.BaseSkills[3] = RogueEssence.Dungeon.SlotSkill(4)
  mob_data.BaseIntrinsics[0] = 2
  local new_mob = RogueEssence.Dungeon.Character(mob_data)
  local tactic = _DATA:GetAITactic(7)
  new_mob.Tactic = RogueEssence.Data.AITactic(tactic)
  new_mob.CharLoc = RogueElements.Loc(4, 4)
  new_mob.CharDir = Dir8.Down
  new_team.Players:Add(new_mob)
  
  mob_data = RogueEssence.Dungeon.CharData()
  mob_data.BaseForm = RogueEssence.Dungeon.MonsterID(151, 0, 0, Gender.Female)
  mob_data.Level = 25
  mob_data.BaseSkills[0] = RogueEssence.Dungeon.SlotSkill(5)
  mob_data.BaseIntrinsics[0] = 3
  new_mob = RogueEssence.Dungeon.Character(mob_data)
  tactic = _DATA:GetAITactic(7)
  new_mob.Tactic = RogueEssence.Data.AITactic(tactic)
  new_mob.CharLoc = RogueElements.Loc(5, 4)
  new_mob.CharDir = Dir8.Up
  new_team.Players:Add(new_mob)
  
  map.MapTeams:Add(new_team)
  
  --Place the player spawn just above the unbreakable wall (doesn't work if you already have one)
  map.GenEntrances:Add(RogueEssence.LevelGen.MapGenEntrance(RogueElements.Loc(map.Width / 2 - 1, map.Height / 2 - 2), Dir8.UpRight))
end



