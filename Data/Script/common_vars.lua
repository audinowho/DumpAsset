--[[
    common_vars.lua
    Save vars
]]--

function COMMON.UpdateDayEndVars()

  if SV.Experimental ~= nil then
    if _DATA.Save:GetDungeonUnlock("faultline_ridge") ~= RogueEssence.Data.GameProgress.UnlockState.None then
      if SV.missions.Missions["EscortSister"] == nil and SV.missions.FinishedMissions["EscortSister"] == nil then
        SV.missions.Missions["EscortSister"] = 
        {
          DestZone = "faultline_ridge",
          DestSegment = 0,
          DestFloor = 5,
          FloorUnknown = true,
          TargetSpecies = RogueEssence.Dungeon.MonsterID("chikorita", 0, "normal", Gender.Female),
          ClientSpecies = RogueEssence.Dungeon.MonsterID("chikorita", 0, "normal", Gender.Female),
          Complete = COMMON.MISSION_INCOMPLETE,
          Type = COMMON.MISSION_TYPE_ESCORT_OUT,
          EscortTable = { EscortStartMsg = "TALK_ESCORT_SISTER_START", EscortAcceptMsg = "TALK_ESCORT_SISTER_ACCEPT", EscortInteract = "EscortInteractSister" }
        }
      end
	  
	  if SV.family.Sister == false then
		SV.family.SisterActiveDays = SV.family.SisterActiveDays + 1
	  end
    end
	

    if _DATA.Save:GetDungeonUnlock("castaway_cave") ~= RogueEssence.Data.GameProgress.UnlockState.None then
      if SV.missions.Missions["EscortMother"] == nil and SV.missions.FinishedMissions["EscortMother"] == nil then
        SV.missions.Missions["EscortMother"] = 
        {
          DestZone = "castaway_cave",
          DestSegment = 0,
          DestFloor = 7,
          FloorUnknown = true,
          TargetSpecies = RogueEssence.Dungeon.MonsterID("swellow", 0, "normal", Gender.Female),
          ClientSpecies = RogueEssence.Dungeon.MonsterID("swellow", 0, "normal", Gender.Female),
          Complete = COMMON.MISSION_INCOMPLETE,
          Type = COMMON.MISSION_TYPE_ESCORT_OUT,
          EscortTable = { EscortStartMsg = "TALK_ESCORT_MOTHER_START", EscortAcceptMsg = "TALK_ESCORT_MOTHER_ACCEPT", EscortInteract = "EscortInteractMother" }
        }
      end
	  
	  if SV.family.Mother == false then
		SV.family.MotherActiveDays = SV.family.MotherActiveDays + 1
	  end
    end
	
	--TODO: should be deserted_fortress
    if _DATA.Save:GetDungeonUnlock("overgrown_wilds") ~= RogueEssence.Data.GameProgress.UnlockState.None then
      if SV.missions.Missions["EscortFather"] == nil and SV.missions.FinishedMissions["EscortFather"] == nil then
        SV.missions.Missions["EscortFather"] = 
        {
          DestZone = "overgrown_wilds",
          DestSegment = 1,
          DestFloor = 1,
          FloorUnknown = true,
          TargetSpecies = RogueEssence.Dungeon.MonsterID("azumarill", 0, "normal", Gender.Male),
          ClientSpecies = RogueEssence.Dungeon.MonsterID("azumarill", 0, "normal", Gender.Male),
          Complete = COMMON.MISSION_INCOMPLETE,
          Type = COMMON.MISSION_TYPE_ESCORT_OUT,
          EscortTable = { EscortStartMsg = "TALK_ESCORT_FATHER_START", EscortAcceptMsg = "TALK_ESCORT_FATHER_ACCEPT", EscortInteract = "EscortInteractFather" }
        }
      end
	  
	  if SV.family.Father == false then
		SV.family.FatherActiveDays = SV.family.FatherActiveDays + 1
	  end
    end
	
	-- TODO: should be barren_tundra
    if _DATA.Save:GetDungeonUnlock("snowbound_path") ~= RogueEssence.Data.GameProgress.UnlockState.None then
      if SV.missions.Missions["EscortBrother"] == nil and SV.missions.FinishedMissions["EscortBrother"] == nil then
        SV.missions.Missions["EscortBrother"] = 
        {
          DestZone = "snowbound_path",
          DestSegment = 1,
          DestFloor = 1,
          FloorUnknown = true,
          TargetSpecies = RogueEssence.Dungeon.MonsterID("wooper", 0, "normal", Gender.Male),
          ClientSpecies = RogueEssence.Dungeon.MonsterID("wooper", 0, "normal", Gender.Male),
          Complete = COMMON.MISSION_INCOMPLETE,
          Type = COMMON.MISSION_TYPE_ESCORT_OUT,
          EscortTable = { EscortStartMsg = "TALK_ESCORT_BROTHER_START", EscortAcceptMsg = "TALK_ESCORT_BROTHER_ACCEPT", EscortInteract = "EscortInteractBrother" }
        }
      end
	  
	  if SV.family.Brother == false then
		SV.family.BrotherActiveDays = SV.family.BrotherActiveDays + 1
	  end
    end
	
	-- TODO: should be wayward_wetlands
    if _DATA.Save:GetDungeonUnlock("veiled_ridge") ~= RogueEssence.Data.GameProgress.UnlockState.None then
      if SV.missions.Missions["EscortPet"] == nil and SV.missions.FinishedMissions["EscortPet"] == nil then
        SV.missions.Missions["EscortPet"] = 
        {
          DestZone = "veiled_ridge",
          DestSegment = 1,
          DestFloor = 1,
          FloorUnknown = true,
          TargetSpecies = RogueEssence.Dungeon.MonsterID("haxorus", 0, "normal", Gender.Male),
          ClientSpecies = RogueEssence.Dungeon.MonsterID("haxorus", 0, "normal", Gender.Male),
          Complete = COMMON.MISSION_INCOMPLETE,
          Type = COMMON.MISSION_TYPE_ESCORT_OUT,
          EscortTable = { EscortStartMsg = "TALK_ESCORT_PET_START", EscortAcceptMsg = "TALK_ESCORT_PET_ACCEPT", EscortInteract = "EscortInteractPet" }
        }
      end
	  
	  if SV.family.Pet == false then
		SV.family.PetActiveDays = SV.family.PetActiveDays + 1
	  end
    end

	-- TODO: should be the_sky
    if _DATA.Save:GetDungeonUnlock("champions_road") ~= RogueEssence.Data.GameProgress.UnlockState.None then
      if SV.missions.Missions["EscortGrandma"] == nil and SV.missions.FinishedMissions["EscortGrandma"] == nil then
        SV.missions.Missions["EscortGrandma"] = 
        {
          DestZone = "champions_road",
          DestSegment = 1,
          DestFloor = 1,
          FloorUnknown = true,
          TargetSpecies = RogueEssence.Dungeon.MonsterID("carbink", 0, "normal", Gender.Male),
          ClientSpecies = RogueEssence.Dungeon.MonsterID("carbink", 0, "normal", Gender.Male),
          Complete = COMMON.MISSION_INCOMPLETE,
          Type = COMMON.MISSION_TYPE_ESCORT_OUT,
          EscortTable = { EscortStartMsg = "TALK_ESCORT_GRANDMA_START", EscortAcceptMsg = "TALK_ESCORT_GRANDMA_ACCEPT", EscortInteract = "EscortInteractGrandma" }
        }
      end
	  
	  if SV.family.Grandma == false then
		SV.family.GrandmaActiveDays = SV.family.GrandmaActiveDays + 1
	  end
    end
	
  end
  
  if SV.base_camp.CenterStatueDate == nil or SV.base_camp.CenterStatueDate == "" then
    if SV.guildmaster_summit.GameComplete == true then
      SV.base_camp.CenterStatueDate = os.date("%B %m, %Y")
	end
  end
  
  if SV.base_camp.LeftStatueDate == nil or SV.base_camp.LeftStatueDate == "" then
    local all_done = false
    if all_done == true then
      SV.base_camp.LeftStatueDate = os.date("%B %m, %Y")
	end
  end
  
  if SV.base_camp.RightStatueDate == nil or SV.base_camp.RightStatueDate == "" then
    local all_done = false
    if all_done == true then
      SV.base_camp.RightStatueDate = os.date("%B %m, %Y")
	end
  end
  
  if SV.Experimental then
  
  if SV.base_town.JuiceShop == 0 and SV.forest_camp.ExpositionComplete then
    SV.base_town.JuiceShop = 1
  end
  
  if SV.team_hunter.Status == 0 and SV.team_hunter.SpokenTo and SV.canyon_camp.ExpositionComplete then
    COMMON.UpdateCheckpointStatus(SV.team_hunter, 2)
  elseif SV.team_hunter.Status == 2 and SV.team_hunter.SpokenTo then
    COMMON.UpdateCheckpointStatus(SV.team_hunter, 1)
  end
  
  if SV.town_elder.Status == 0 and SV.town_elder.SpokenTo and _DATA.Save:GetDungeonUnlock("ambush_forest") == RogueEssence.Data.GameProgress.UnlockState.Completed then
    COMMON.UpdateCheckpointStatus(SV.town_elder, 3)
  elseif SV.town_elder.Status == 2 then
    COMMON.UpdateCheckpointStatus(SV.town_elder, 1)
  end
  
  if SV.forest_child.Status == 0 and SV.forest_child.SpokenTo and SV.rest_stop.ExpositionComplete then
    COMMON.UpdateCheckpointStatus(SV.forest_child, 3)
  elseif SV.forest_child.Status == 2 then
    COMMON.UpdateCheckpointStatus(SV.forest_child, 1)
  end
  
  if SV.team_catch.Status == 0 and SV.team_catch.SpokenTo then
    COMMON.UpdateCheckpointStatus(SV.team_catch, 1)
  elseif SV.team_catch.Status == 1 and SV.team_catch.SpokenTo and SV.forest_camp.ExpositionComplete then
    COMMON.UpdateCheckpointStatus(SV.team_catch, 2)
  elseif SV.team_catch.Status == 2 and SV.team_catch.SpokenTo and _DATA.Save:GetDungeonUnlock("overgrown_wilds") ~= RogueEssence.Data.GameProgress.UnlockState.None then
    COMMON.UpdateCheckpointStatus(SV.team_catch, 1)
  elseif SV.team_catch.Status == 4 then
	SV.team_catch.Cycle = math.random(1, 6)
  end
  
  if SV.team_rivals.Status == 0 and SV.team_rivals.SpokenTo then
    COMMON.UpdateCheckpointStatus(SV.team_rivals, 1)
  elseif SV.team_rivals.Status == 1 and SV.team_rivals.SpokenTo and SV.rest_stop.ExpositionComplete then
    COMMON.UpdateCheckpointStatus(SV.team_rivals, 1)
  elseif SV.team_rivals.Status == 3 then
    COMMON.UpdateCheckpointStatus(SV.team_rivals, 1)
  elseif SV.team_rivals.Status == 4 then
    COMMON.UpdateCheckpointStatus(SV.team_rivals, 1)
  elseif SV.team_rivals.Status == 6 then
    COMMON.UpdateCheckpointStatus(SV.team_rivals, 1)
  elseif SV.team_rivals.Status == 7 and SV.guildmaster_summit.GameComplete then
    COMMON.UpdateCheckpointStatus(SV.team_rivals, 4)
  elseif SV.team_rivals.Status == 8 and SV.team_rivals.SpokenTo then
    COMMON.UpdateCheckpointStatus(SV.team_rivals, 1)
  elseif SV.team_rivals.Status == 9 then
	SV.team_rivals.Cycle = math.random(1, 6)
  end
  
  if SV.team_kidnapped.Status == 0 and SV.team_kidnapped.SpokenTo then
    COMMON.UpdateCheckpointStatus(SV.team_kidnapped, 1)
  elseif SV.team_kidnapped.Status == 1 and SV.team_kidnapped.SpokenTo then
    COMMON.UpdateCheckpointStatus(SV.team_kidnapped, 1)
	-- TODO: should be oblivion valley
  elseif SV.team_kidnapped.Status == 2 and SV.team_kidnapped.SpokenTo and _DATA.Save:GetDungeonUnlock("secret_garden") ~= RogueEssence.Data.GameProgress.UnlockState.None then
    COMMON.UpdateCheckpointStatus(SV.team_kidnapped, 2)
  elseif SV.team_kidnapped.Status == 4 then
    COMMON.UpdateCheckpointStatus(SV.team_kidnapped, 1)
  elseif SV.team_kidnapped.Status == 5 then
	SV.team_kidnapped.Cycle = math.random(1, 6)
  end
  
  if SV.team_retreat.Status == 0 and SV.team_retreat.SpokenTo then
    COMMON.UpdateCheckpointStatus(SV.team_retreat, 2)
	
	-- TODO: should be deserted_fortress
  elseif SV.team_retreat.Status == 1 and SV.team_retreat.SpokenTo and _DATA.Save:GetDungeonUnlock("trickster_woods") ~= RogueEssence.Data.GameProgress.UnlockState.None then
    COMMON.UpdateCheckpointStatus(SV.team_retreat, 2)
  elseif SV.team_retreat.Status == 3 then
    COMMON.UpdateCheckpointStatus(SV.team_retreat, 1)
  elseif SV.team_retreat.Status == 4 then
	SV.team_retreat.Cycle = math.random(1, 6)
  end
  
  if SV.team_meditate.Status == 0 and SV.team_meditate.SpokenTo then
    COMMON.UpdateCheckpointStatus(SV.team_meditate, 1)
  elseif SV.team_meditate.Status == 1 and SV.team_meditate.SpokenTo then
    COMMON.UpdateCheckpointStatus(SV.team_meditate, 1)
  elseif SV.team_meditate.Status == 2 then
    COMMON.UpdateCheckpointStatus(SV.team_meditate, 4)
  elseif SV.team_meditate.Status == 3 then
    SV.team_meditate.DaysSinceCheckpoint = SV.team_meditate.DaysSinceCheckpoint + 1
  elseif SV.team_meditate.Status == 4 then
    COMMON.UpdateCheckpointStatus(SV.team_meditate, 1)
  elseif SV.team_meditate.Status == 6 then
	SV.team_meditate.Cycle = math.random(3, 6)
  end
  

  if SV.team_steel.Argued then
    if not SV.team_steel.Rescued then
      SV.team_steel.DaysSinceArgue = SV.team_steel.DaysSinceArgue + 1
	end
  end
  
  if SV.team_solo.Status == 0 and SV.team_solo.SpokenTo then
    COMMON.UpdateCheckpointStatus(SV.team_solo, 1)
  elseif SV.team_solo.Status == 1 and SV.team_solo.SpokenTo then
    COMMON.UpdateCheckpointStatus(SV.team_solo, 1)
  elseif SV.team_solo.Status == 2 and SV.team_solo.SpokenTo then
    COMMON.UpdateCheckpointStatus(SV.team_solo, 2)
  elseif SV.team_solo.Status == 3 and SV.team_solo.SpokenTo then
    COMMON.UpdateCheckpointStatus(SV.team_solo, 2)
  elseif SV.team_solo.Status == 5 then
    COMMON.UpdateCheckpointStatus(SV.team_solo, 1)
  elseif SV.team_solo.Status == 6 then
	SV.team_solo.Cycle = math.random(3, 6)
  end
  
  if SV.team_psychic.Status == 0 and _DATA.Save:GetDungeonUnlock("sleeping_caldera") == RogueEssence.Data.GameProgress.UnlockState.Completed then
    COMMON.UpdateCheckpointStatus(SV.team_psychic, 1)
  elseif SV.team_psychic.Status == 1 and SV.rest_stop.ExpositionComplete then
    COMMON.UpdateCheckpointStatus(SV.team_psychic, 1)
  elseif SV.team_psychic.Status == 2 and SV.team_psychic.SpokenTo then
    COMMON.UpdateCheckpointStatus(SV.team_psychic, 1)
    COMMON.UpdateCheckpointStatus(SV.team_dark, 1)
  elseif SV.team_psychic.Status == 3 and _DATA.Save:GetDungeonUnlock("relic_tower") ~= RogueEssence.Data.GameProgress.UnlockState.None then
    COMMON.UpdateCheckpointStatus(SV.team_psychic, 2)
  elseif SV.team_psychic.Status == 5 then
    COMMON.UpdateCheckpointStatus(SV.team_psychic, 1)
  elseif SV.team_psychic.Status == 6 then
	SV.team_psychic.Cycle = math.random(3, 6)
  end
  
  if SV.team_dark.Status == 1 then
    COMMON.UpdateCheckpointStatus(SV.team_dark, 3)
  elseif SV.team_dark.Status == 2 then
    COMMON.UpdateCheckpointStatus(SV.team_dark, 3)
  elseif SV.team_dark.Status == 4 then
    COMMON.UpdateCheckpointStatus(SV.team_dark, 1)
  elseif SV.team_dragon.Status == 5 then
	SV.team_dragon.Cycle = math.random(3, 6)
  end
  
  
  if SV.team_dragon.Status == 0 and SV.team_dragon.SpokenTo then
    COMMON.UpdateCheckpointStatus(SV.team_dragon, 1)
  elseif SV.team_dragon.Status == 1 and SV.team_dragon.SpokenTo and SV.rest_stop.ExpositionComplete then
    COMMON.UpdateCheckpointStatus(SV.team_dragon, 1)
  elseif SV.team_dragon.Status == 2 and SV.team_dragon.SpokenTo and SV.final_stop.ExpositionComplete then
    COMMON.UpdateCheckpointStatus(SV.team_dragon, 1)
  elseif SV.team_dragon.Status == 4 then
    COMMON.UpdateCheckpointStatus(SV.team_dragon, 1)
  elseif SV.team_dragon.Status == 5 and SV.team_dragon.SpokenTo and SV.guildmaster_summit.GameComplete then
    COMMON.UpdateCheckpointStatus(SV.team_dragon, 1)
  elseif SV.team_dragon.Status == 6 and SV.team_dragon.SpokenTo then
    COMMON.UpdateCheckpointStatus(SV.team_dragon, 1)
  elseif SV.team_dragon.Status == 8 then
	SV.team_dragon.Cycle = math.random(3, 6)
  end
  
  
  if SV.team_firecracker.Status == 0 and SV.team_firecracker.SpokenTo and SV.canyon_camp.ExpositionComplete then
    COMMON.UpdateCheckpointStatus(SV.team_firecracker, 2)
  elseif SV.team_firecracker.Status == 1 and SV.team_firecracker.SpokenTo and SV.rest_stop.ExpositionComplete then
    COMMON.UpdateCheckpointStatus(SV.team_firecracker, 3)
  elseif SV.team_firecracker.Status == 2 and SV.team_firecracker.SpokenTo and SV.final_stop.ExpositionComplete then
    COMMON.UpdateCheckpointStatus(SV.team_firecracker, 3)
  elseif SV.team_firecracker.Status == 4 then
    SV.team_firecracker.Status = 5
	SV.team_firecracker.DaysSinceCheckpoint = 0
	SV.team_firecracker.SpokenTo = false
	SV.team_firecracker.Cycle = 2
  elseif SV.team_firecracker.Status == 5 then
    local max_cycle = 5
	if SV.guildmaster_summit.GameComplete then
	  max_cycle = 6
	end
	SV.team_firecracker.Cycle = math.random(2, max_cycle)
  end
  
  end
  
  if SV.supply_corps.Status == 1 then
    SV.supply_corps.Status = 2
  elseif SV.supply_corps.Status == 3 then
    SV.supply_corps.Status = 4
  elseif SV.supply_corps.Status == 5 then
    SV.supply_corps.Status = 6
  elseif SV.supply_corps.Status == 7 then
    SV.supply_corps.Status = 8
  elseif SV.supply_corps.Status == 9 and SV.rest_stop.ExpositionComplete then
    SV.supply_corps.Status = 10
  elseif SV.supply_corps.Status == 11 then
    SV.supply_corps.Status = 12
  elseif SV.supply_corps.Status == 13 and SV.final_stop.ExpositionComplete then
    SV.supply_corps.Status = 14
  elseif SV.supply_corps.Status == 15 then
    SV.supply_corps.Status = 16
  elseif SV.supply_corps.Status == 17 then
    SV.supply_corps.Status = 18
  elseif SV.supply_corps.Status == 19 and SV.guildmaster_summit.GameComplete then
    SV.supply_corps.Status = 20
  elseif SV.supply_corps.Status == 20 then
    --cycle
	SV.supply_corps.DaysSinceCheckpoint = SV.supply_corps.DaysSinceCheckpoint + 1
	SV.supply_corps.CarryCycle = SV.supply_corps.DaysSinceCheckpoint % 5 + 1
	SV.supply_corps.DeliverCycle = math.random(1, 5)
	SV.supply_corps.ManagerCycle = SV.supply_corps.DaysSinceCheckpoint % 12
	if SV.supply_corps.ManagerCycle > 6 then
	  SV.supply_corps.ManagerCycle = 6 - (SV.supply_corps.ManagerCycle - 6)
	end
  end

  
  if SV.rest_stop.ExpositionComplete then
    if not SV.rest_stop.BossSolved then
      SV.rest_stop.DaysSinceBoss = SV.rest_stop.DaysSinceBoss + 1
	end
  end
  
end

function COMMON.UpdateCheckpointStatus(checkpoint, limit)
  checkpoint.DaysSinceCheckpoint = checkpoint.DaysSinceCheckpoint + 1
	if checkpoint.DaysSinceCheckpoint >= limit then
      checkpoint.Status = checkpoint.Status + 1
	  checkpoint.DaysSinceCheckpoint = 0
	  checkpoint.SpokenTo = false
	end
end

