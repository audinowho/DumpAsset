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
	

    if _DATA.Save:GetDungeonUnlock("deserted_fortress") ~= RogueEssence.Data.GameProgress.UnlockState.None then
      if SV.missions.Missions["EscortFather"] == nil and SV.missions.FinishedMissions["EscortFather"] == nil then
        SV.missions.Missions["EscortFather"] = 
        {
          DestZone = "deserted_fortress",
          DestSegment = 0,
          DestFloor = 6,
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

    if _DATA.Save:GetDungeonUnlock("barren_tundra") ~= RogueEssence.Data.GameProgress.UnlockState.None then
      if SV.missions.Missions["EscortBrother"] == nil and SV.missions.FinishedMissions["EscortBrother"] == nil then
        SV.missions.Missions["EscortBrother"] = 
        {
          DestZone = "barren_tundra",
          DestSegment = 0,
          DestFloor = 10,
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
	

    if _DATA.Save:GetDungeonUnlock("wayward_wetlands") ~= RogueEssence.Data.GameProgress.UnlockState.None then
      if SV.missions.Missions["EscortPet"] == nil and SV.missions.FinishedMissions["EscortPet"] == nil then
        SV.missions.Missions["EscortPet"] = 
        {
          DestZone = "wayward_wetlands",
          DestSegment = 0,
          DestFloor = 10,
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

    if _DATA.Save:GetDungeonUnlock("the_sky") ~= RogueEssence.Data.GameProgress.UnlockState.None then
      if SV.missions.Missions["EscortGrandma"] == nil and SV.missions.FinishedMissions["EscortGrandma"] == nil then
        SV.missions.Missions["EscortGrandma"] = 
        {
          DestZone = "the_sky",
          DestSegment = 0,
          DestFloor = 15,
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

  
end

