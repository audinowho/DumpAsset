-- PMDO Mission Generation Library v1.0.3, by MistressNebula
-- Service file
-- ----------------------------------------------------------------------------------------- --
-- This file contains the service routines required by the library, including loading the
-- library itself.
-- If you are looking for the main systems, please refer to missiongen_lib.lua
-- ----------------------------------------------------------------------------------------- --
-- This is the only file outside of missiongen_lib.lua that must be loaded by modders.
-- More specifically, you should require this file from inside your mod's main.lua.
-- ----------------------------------------------------------------------------------------- --
-- Make sure to write in the variable below, as a string, the name of the global variable you loaded the
-- missiongen_lib.lua file into:
local library_name = "MissionGen"


require 'nebula_mission_board.common'
require 'origin.services.baseservice'

local MissionTools = Class('MissionTools', BaseService)

--[[---------------------------------------------------------------
    MissionTools:initialize()
      MissionTools class constructor
---------------------------------------------------------------]]
function MissionTools:initialize()
  BaseService.initialize(self)
  PrintInfo('MissionTools:initialize()')
end

--[[---------------------------------------------------------------
    MissionTools:OnSaveLoad()
      Called when a save is loaded or created for the first time.
---------------------------------------------------------------]]
function MissionTools:OnSaveLoad()
    assert(self, 'MissionTools:OnSaveLoad() : self is null!')
    assert(_G[library_name], 'MissionTools:OnSaveLoad() : '..library_name..' is null!')
    _G[library_name]:load()
end

--[[---------------------------------------------------------------
    RecruitTools:OnDungeonFloorEnd()
      When leaving a dungeon floor this is called.
---------------------------------------------------------------]]
function MissionTools:OnDungeonFloorEnd()
    assert(self, 'MissionTools:OnDungeonFloorEnd() : self is null!')
    local zone, segment = _ZONE.CurrentZoneID, _ZONE.CurrentMapID.Segment
    --Mark the current dungeon as visited
    _G[library_name].root.dungeon_progress[zone] = _G[library_name].root.dungeon_progress[zone] or {}
    _G[library_name].root.dungeon_progress[zone][segment] = _G[library_name].root.dungeon_progress[zone][segment] or false
end

--[[---------------------------------------------------------------
    MissionTools:OnAddMenu(menu)
      When a menu is about to be added to the menu stack this is called!
---------------------------------------------------------------]]
function MissionTools:OnAddMenu(menu)
    local labels = RogueEssence.Menu.MenuLabel
    if menu:HasLabel() then
        if RogueEssence.GameManager.Instance.CurrentScene == RogueEssence.Dungeon.DungeonScene.Instance then
            if menu.Label == labels.OTHERS_MENU then
                local choices = menu:ExportChoices()
                -- put right after Recruitment Search if present
                local index = menu:GetChoiceIndexByLabel("OTH_RECRUIT")+1
                -- if failed, put right before Settings if present
                if index <0 then index = menu:GetChoiceIndexByLabel(labels.OTH_SETTINGS) end
                -- fall back to either 1 or choices count if both fail
                if index <0 then index = math.min(1, menu.Choices.Count) end
                choices:Insert(index, RogueEssence.Menu.MenuTextChoice("OTH_MISSION", STRINGS:FormatKey(_G[library_name].globals.keys.OPTION_OBJECTIVES_LIST), function () _G[library_name]:OpenObjectivesMenu() end))
                menu:ImportChoices(choices)
            end
        else
            if menu.Label == labels.MAIN_MENU then
                local choices = menu:ExportChoices()
                local taken_count = #_G[library_name].root.taken
                local job_list_color = Color.Red
                if taken_count > 0 then job_list_color = Color.White end
                -- put right before Others if present
                local index = menu:GetChoiceIndexByLabel(labels.MAIN_OTHERS)
                -- fall back to either 1 or choices count if the check fails
                if index <0 then
                    index = math.min(1, menu.Choices.Count)
                end
                choices:Insert(index, RogueEssence.Menu.MenuTextChoice("MAIN_MISSION", STRINGS:FormatKey(_G[library_name].globals.keys.OPTION_JOBLIST), function () _G[library_name]:OpenTakenMenuFromMain() end, taken_count > 0, job_list_color))
                menu:ImportChoices(choices)
            end
        end
    end
end

---Summary
-- Subscribe to all channels this service wants callbacks from
function MissionTools:Subscribe(med)
    med:Subscribe("MissionTools", EngineServiceEvents.NewGame, function(_, _) self.OnSaveLoad(self) end)
    med:Subscribe("MissionTools", EngineServiceEvents.LoadSavedData, function(_, _) self.OnSaveLoad(self) end)
    med:Subscribe("MissionTools", EngineServiceEvents.AddMenu, function(_, args) self.OnAddMenu(self, args[0]) end)
    med:Subscribe("MissionTools", EngineServiceEvents.DungeonFloorExit, function(_, _) self.OnDungeonFloorEnd(self) end)
end

---Summary
-- un-subscribe to all channels this service subscribed to
function MissionTools:UnSubscribe(med)
end


--Add our service
SCRIPT:AddService("MissionTools", MissionTools:new())
return MissionTools
