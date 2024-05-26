require 'enable_mission_board.common'
require 'origin.services.baseservice'
require 'origin.recruit_list'
require 'enable_mission_board.mission_gen'


local MenuTools = Class('MenuTools', BaseService)

--[[---------------------------------------------------------------
    MenuTools:initialize()
      MenuTools class constructor
---------------------------------------------------------------]]
function MenuTools:initialize()
  BaseService.initialize(self)
  PrintInfo('MenuTools:initialize()')
end

--[[---------------------------------------------------------------
    MenuTools:OnMenuButtonPressed()
      When the main menu button is pressed or the main menu should be enabled this is called!
      This is called as a coroutine.
---------------------------------------------------------------]]
function MenuTools:OnMenuButtonPressed()
    -- TODO: Remove this when the memory leak is fixed or confirmed not a leak
    if MenuTools.MainMenu == nil then
        MenuTools.MainMenu = RogueEssence.Menu.MainMenu()
    end

    MenuTools.MainMenu:SetupChoices()

    --Custom menu stuff for jobs. 
    --Check if we're in a dungeon or not. Only do main menu changes outside of a dungeon. Do others menu changes in dungeon only.
    if SV.MissionsEnabled then

        if RogueEssence.GameManager.Instance.CurrentScene == RogueEssence.Dungeon.DungeonScene.Instance then
            MenuTools.MainMenu.Choices:RemoveAt(5)
            MenuTools.MainMenu.Choices:Insert(5, RogueEssence.Menu.MenuTextChoice(Text.FormatKey("MENU_OTHERS_TITLE"), function () _MENU:AddMenu(MenuTools:CustomDungeonOthersMenu(), false) end))
        else--not in a dungeon 
            --Add Job List option
            local taken_count = MISSION_GEN.GetTakenCount()
            local job_list_color = Color.Red
            if taken_count > 0 then
                job_list_color = Color.White
            end

            MenuTools.MainMenu.Choices:Insert(4, RogueEssence.Menu.MenuTextChoice(Text.FormatKey("MENU_JOBLIST_TITLE"), function () _MENU:AddMenu(BoardMenu:new(COMMON.MISSION_BOARD_TAKEN, nil, MenuTools.MainMenu).menu, false) end, taken_count > 0, job_list_color))

        end

    else

        if RogueEssence.GameManager.Instance.CurrentScene == RogueEssence.Dungeon.DungeonScene.Instance then
            MenuTools.MainMenu.Choices[5] = RogueEssence.Menu.MenuTextChoice(STRINGS:FormatKey("MENU_OTHERS_TITLE"), function () _MENU:AddMenu(MenuTools:OthersMenuWithRecruitScan(), false) end)
        end

    end

    MenuTools.MainMenu:SetupTitleAndSummary()

    MenuTools.MainMenu:InitMenu()
    TASK:WaitTask(_MENU:ProcessMenuCoroutine(MenuTools.MainMenu))
end

function MenuTools:OthersMenuWithRecruitScan()
    -- TODO: Remove this when the memory leak is fixed or confirmed not a leak
    if MenuTools.OthersMenu == nil then
        MenuTools.OthersMenu = RogueEssence.Menu.OthersMenu()
    end
    MenuTools.OthersMenu:SetupChoices();
    if RogueEssence.GameManager.Instance.CurrentScene == RogueEssence.Dungeon.DungeonScene.Instance then
        MenuTools.OthersMenu.Choices:Insert(1, RogueEssence.Menu.MenuTextChoice(RogueEssence.StringKey("MENU_RECRUITMENT"):ToLocal(), function () _MENU:AddMenu(RecruitmentListMenu:new().menu, false) end))
    end
    MenuTools.OthersMenu:InitMenu();
    return MenuTools.OthersMenu
end



function MenuTools:CustomDungeonOthersMenu()
    local menu = RogueEssence.Menu.OthersMenu()
    menu:SetupChoices();
    if RogueEssence.GameManager.Instance.CurrentScene == RogueEssence.Dungeon.DungeonScene.Instance then
        menu.Choices:Insert(1, RogueEssence.Menu.MenuTextChoice(RogueEssence.StringKey("MENU_RECRUITMENT"):ToLocal(), function () _MENU:AddMenu(RecruitmentListMenu:new().menu, false) end))
        menu.Choices:Add(RogueEssence.Menu.MenuTextChoice("Mission Objectives", function () _MENU:AddMenu(DungeonJobList:new().menu, false) end))
    end
    menu:InitMenu();
    return menu
end


---Summary
-- Subscribe to all channels this service wants callbacks from
function MenuTools:Subscribe(med)
  med:Subscribe("MenuTools", EngineServiceEvents.MenuButtonPressed,        function() self.OnMenuButtonPressed() end )
end

---Summary
-- un-subscribe to all channels this service subscribed to
function MenuTools:UnSubscribe(med)
end


--Add our service
SCRIPT:AddService("MenuTools", MenuTools:new())

return MenuTools