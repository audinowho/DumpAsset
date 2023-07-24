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


function ZONE_GEN_SCRIPT.Mysteriosity(zoneContext, context, queue, seed, args)
  PrintInfo("Test")
end



function ZONE_GEN_SCRIPT.SpawnMissionNpcFromSV(zoneContext, context, queue, seed, args)
  -- choose a the floor to spawn it on
  local destinationFloor = false
  local outlawFloor = false
  for name, mission in pairs(SV.missions.Missions) do
    PrintInfo("Checking Mission: "..tostring(name))
    if mission.Complete == COMMON.MISSION_INCOMPLETE and zoneContext.CurrentZone == mission.DestZone
	  and zoneContext.CurrentSegment == mission.DestSegment and zoneContext.CurrentID == mission.DestFloor then
      PrintInfo("Spawning Mission Goal")
	  if mission.Type == COMMON.MISSION_TYPE_OUTLAW then -- outlaw
        local specificTeam = RogueEssence.LevelGen.SpecificTeamSpawner()
        local post_mob = RogueEssence.LevelGen.MobSpawn()
        post_mob.BaseForm = RogueEssence.Dungeon.MonsterID(mission.TargetSpecies, 0, "normal", Gender.Unknown)
        post_mob.Tactic = "boss"
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
        post_mob.BaseForm = RogueEssence.Dungeon.MonsterID(mission.TargetSpecies, 0, "normal", Gender.Unknown)
        post_mob.Tactic = "slow_patrol"
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


PresetPickerType = luanet.import_type('RogueElements.PresetPicker`1')
EffectTileType = luanet.import_type('RogueEssence.Dungeon.EffectTile')
TempTileStepType = luanet.import_type('PMDC.LevelGen.TempTileStep`1')

function FLOOR_GEN_SCRIPT.Mysteriosity(map, args)
  local total_chance = 0
  if SV.magnagate.cards > 0 then
    total_chance = args.BaseChance + SV.magnagate.cards * 5
  end
  if map.Rand:Next(100) < total_chance then
	local secretTile = RogueEssence.Dungeon.EffectTile("tile_mystery", true)
	secretTile.TileStates:Set(PMDC.Dungeon.DestState(RogueEssence.Dungeon.SegLoc(args.SegDiff, 0), true))
	local picker = LUA_ENGINE:MakeGenericType( PresetPickerType, { EffectTileType }, { secretTile })
	local trapStep = LUA_ENGINE:MakeGenericType( TempTileStepType, { MapGenContextType }, { picker, "mysterious_distortion" })
	trapStep.TileFilters:Add(PMDC.LevelGen.RoomFilterConnectivity(PMDC.LevelGen.ConnectivityRoom.Connectivity.Main))
	trapStep.TileFilters:Add(RogueElements.RoomFilterComponent(true, PMDC.LevelGen.BossRoom()))
	trapStep:Apply(map)
  end
  
end

RoomGenBlockedType = luanet.import_type('RogueElements.RoomGenBlocked`1')
RoomGenEvoType = luanet.import_type('PMDC.LevelGen.RoomGenEvo`1')

function FLOOR_GEN_SCRIPT.TestGrid(map, args)
  PrintInfo("Test Grid")
  
  -- this step operates on the grid floor of the map, assuming it has one
  -- free-form floors do not have a grid
  local floorPlan = map.GridPlan
  -- these changes will only affect the map if they are done after the grid is created (after priority -5)
  -- these changes will only affect the map if they are done before the grid is drawn to the floor plan (before priority -3)
  
  
  -- set the brush for all vertical hallways on the right half to be blocked rooms 
  for xx = floorPlan.GridWidth / 2, floorPlan.GridWidth - 1, 1 do
    for yy = 0, floorPlan.GridHeight - 2, 1 do
	  local hall = floorPlan:GetHall(RogueElements.LocRay4(RogueElements.Loc(xx, yy), Dir4.Down))
	  -- only modify existing halls
	  if hall ~= nil then
	    local hallGen = LUA_ENGINE:MakeGenericType(RoomGenBlockedType, { map:GetType() }, {  })
	    -- no need to change width and height since they will be ordered by the floors
	    hallGen.BlockWidth = RogueElements.RandRange(2)
	    hallGen.BlockHeight = RogueElements.RandRange(10)
		hallGen.BlockTerrain = RogueEssence.Dungeon.Tile("water")
		floorPlan:SetHall(RogueElements.LocRay4(RogueElements.Loc(xx, yy), Dir4.Down), hallGen, hall.Components)
	  end
	end
  end
  
  -- turns all rooms on the left side into evo rooms
  for yy = 0, floorPlan.GridHeight - 1, 1 do
	local room = floorPlan:GetRoomPlan(RogueElements.Loc(0, yy))
	if room ~= nil then
	  local roomGen = LUA_ENGINE:MakeGenericType(RoomGenEvoType, { map:GetType() }, {  })
	  room.RoomGen = roomGen
	end
  end
  
end

function FLOOR_GEN_SCRIPT.TestRooms(map, args)
  PrintInfo("Test Floor")
  
  --this step just finds all hallways and rooms and prints out their areas
  --since this step does not alter the floor, it only needs to take place after the floor plan is created (after priority -3)
  
  local floorPlan = map.RoomPlan
  
  -- coordinates are offset by the start amount.  Add them to get the true amount
  local offset = floorPlan.Start
  
  for ii = 0, floorPlan.RoomCount - 1, 1 do
    local room = floorPlan:GetRoom(ii)
	PrintInfo("Room " .. ii .. ": X".. room.Draw.Start.X + offset.X .. " Y" .. room.Draw.Start.Y + offset.Y .. " W" .. room.Draw.Size.X .. " H" .. room.Draw.Size.Y  )
  end
  
  for ii = 0, floorPlan.HallCount - 1, 1 do
    local hall = floorPlan:GetHall(ii)
	PrintInfo("Hall " .. ii .. ": X".. hall.Draw.Start.X + offset.X .. " Y" .. hall.Draw.Start.Y + offset.Y .. " W" .. hall.Draw.Size.X .. " H" .. hall.Draw.Size.Y  )
  end
end
  
function FLOOR_GEN_SCRIPT.Test(map, args)
  PrintInfo("Test Tile")
  
  --A demo of various tile operations possible with scripting
  --This step should be added after everything else. (prefer 7)
  
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
        map:TrySetTile(loc, RogueEssence.Dungeon.Tile("water"))
	  end
    end  
  end
  
  --Set the center of the corner to Block tile of a custom tileset.
  for xx = map.Width * 3 / 4 - 1, map.Width * 3 / 4 + 1, 1 do
    for yy = map.Height * 3 / 4 - 1, map.Height * 3 / 4 + 1, 1 do
	  local customTerrain = RogueEssence.Dungeon.Tile("wall", true) -- set StableTex to true, which prevents the map's autotexturing
	  customTerrain.Data.TileTex = RogueEssence.Dungeon.AutoTile("tiny_woods_wall")
      map:TrySetTile(RogueElements.Loc(xx, yy), customTerrain)
    end
  end
  
  --Place a trap on 2,2.  Slumber trap, revealed.
  --map:PlaceItem(RogueElements.Loc(2, 2), RogueEssence.Dungeon.EffectTile("trap_slumber", true))
  local trap_tile = map:GetTile(RogueElements.Loc(2, 2))
  trap_tile.Effect = RogueEssence.Dungeon.EffectTile("trap_slumber", true)
  
  --Place item on 3,2.  Banana, sticky
  --map:PlaceItem(RogueElements.Loc(3, 2), RogueEssence.Dungeon.MapItem(6))
  local new_item = RogueEssence.Dungeon.MapItem(6)
  new_item.Cursed = true
  new_item.TileLoc = RogueElements.Loc(3, 2)
  map.Items:Add(new_item)
  
  --Place item on 3,3.  Random amount of G between 50 and 100
  --map:PlaceItem(RogueElements.Loc(3, 3), RogueEssence.Dungeon.MapItem(true, 100))
  new_item = RogueEssence.Dungeon.MapItem.CreateMoney(map.Rand:Next(50, 101)) -- you must use the map.Rand, or else seeds wont be consistent
  new_item.TileLoc = RogueElements.Loc(3, 3)
  map.Items:Add(new_item)
  
  --Place enemies on 4,4, 4,5, together in a team, with AI of Normal Wander
  local new_team = RogueEssence.Dungeon.MonsterTeam()
  
  local mob_data = RogueEssence.Dungeon.CharData()
  mob_data.BaseForm = RogueEssence.Dungeon.MonsterID("mewtwo", 0, "normal", Gender.Male)
  mob_data.Level = 20;
  mob_data.BaseSkills[0] = RogueEssence.Dungeon.SlotSkill("pound")
  mob_data.BaseSkills[1] = RogueEssence.Dungeon.SlotSkill("fire_punch")
  mob_data.BaseSkills[2] = RogueEssence.Dungeon.SlotSkill("ice_punch")
  mob_data.BaseSkills[3] = RogueEssence.Dungeon.SlotSkill("thunder_punch")
  mob_data.BaseIntrinsics[0] = "drizzle"
  local new_mob = RogueEssence.Dungeon.Character(mob_data)
  local tactic = _DATA:GetAITactic("wander_normal")
  new_mob.Tactic = RogueEssence.Data.AITactic(tactic)
  new_mob.CharLoc = RogueElements.Loc(4, 4)
  new_mob.CharDir = Dir8.Down
  new_team.Players:Add(new_mob)
  
  mob_data = RogueEssence.Dungeon.CharData()
  mob_data.BaseForm = RogueEssence.Dungeon.MonsterID("mew", 0, "normal", Gender.Female)
  mob_data.Level = 25
  mob_data.BaseSkills[0] = RogueEssence.Dungeon.SlotSkill("pound")
  mob_data.BaseIntrinsics[0] = "speed_boost"
  new_mob = RogueEssence.Dungeon.Character(mob_data)
  tactic = _DATA:GetAITactic("wander_normal")
  new_mob.Tactic = RogueEssence.Data.AITactic(tactic)
  new_mob.CharLoc = RogueElements.Loc(5, 4)
  new_mob.CharDir = Dir8.Up
  new_team.Players:Add(new_mob)
  
  map.MapTeams:Add(new_team)
  
  --Place the player spawn just above the unbreakable wall (doesn't work if you already have one)
  map.GenEntrances:Add(RogueEssence.LevelGen.MapGenEntrance(RogueElements.Loc(map.Width / 2 - 1, map.Height / 2 - 2), Dir8.UpRight))
end


function FLOOR_GEN_SCRIPT.ShimmerBayRevisit(map, args)
  if not SV.manaphy_egg.Taken then
    return
  end
  
  local item = nil
  
  for ii = 0, map.Items.Count - 1, 1 do
	if map.Items[ii].Value == "egg_mystery" then
	  item = map.Items[ii]
	  break
	end
  end
  
  if item ~= nil then
    item.Value = "box_deluxe"
	item.HiddenValue = "empty"
  end
  
end


