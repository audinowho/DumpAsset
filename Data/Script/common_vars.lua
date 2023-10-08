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
  
  if SV.family.Sister == 0 then
    SV.family.SisterActiveDays = SV.family.SisterActiveDays + 1
  end
  
end

