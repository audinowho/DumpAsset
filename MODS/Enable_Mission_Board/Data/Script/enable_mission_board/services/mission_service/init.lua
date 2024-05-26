--[[
    Example Service
    
    This is an example to demonstrate how to use the BaseService class to implement a game service.
    
    **NOTE:** After declaring you service, you have to include your package inside the main.lua file!
]]--
require 'enable_mission_board.common'
require 'origin.services.baseservice'

--Declare class MissionService
local MissionService = Class('MissionService', BaseService)

--[[---------------------------------------------------------------
    MissionService:initialize()
      MissionService class constructor
---------------------------------------------------------------]]
function MissionService:initialize()
  BaseService.initialize(self)
  self.mapname = ""
  PrintInfo('MissionService:initialize()')
end

--[[---------------------------------------------------------------
    MissionService:OnInit()
      Called on initialization of the script engine by the game!
---------------------------------------------------------------]]
function MissionService:OnInit()
  assert(self, 'MissionService:OnInit() : self is null!')
  PrintInfo("\n<!> ExampleSvc: Init..")
end

--[[---------------------------------------------------------------
    MissionService:OnDeinit()
      Called on de-initialization of the script engine by the game!
---------------------------------------------------------------]]
function MissionService:OnDeinit()
  assert(self, 'MissionService:OnDeinit() : self is null!')
  PrintInfo("\n<!> ExampleSvc: Deinit..")
end

function MissionService:OnNewGame()
  assert(self, 'MissionService:OnNewGame() : self is null!')

  SV.MissionsEnabled = true

end

function MissionService:OnUpgrade()
  assert(self, 'MissionService:OnUpgrade() : self is null!')
  
  
if SV.MissionsEnabled == nil then
    SV.MissionPrereq =
    {
        DungeonsCompleted = {}, --Uses a bitmap to determine which sections are complete (
        NumDungeonsCompleted = 0
    }
    SV.DestinationFloorNotified = false
    SV.MonsterHouseMessageNotified = false
    SV.OutlawDefeated = false
    SV.OutlawGoonsDefeated = false
    SV.MapTurnCounter = -1
    SV.TemporaryFlags =
    {
        MissionCompleted = false,--used to mark if there are any pending missions to hand in.
        PriorMapSetting = nil,--Used to mark what the player had their minimap setting whenever the game needs to temporarily change it to something else.
    }
    --empty string or a -1 indicates that there's nothing there currently.
    --board of jobs you've actually taken.
    SV.TakenBoard =
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
            BonusReward = "",
            BackReference = -1
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
            BonusReward = "",
            BackReference = -1
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
            BonusReward = "",
            BackReference = -1
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
            BonusReward = "",
            BackReference = -1
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
            BonusReward = "",
            BackReference = -1
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
            BonusReward = "",
            BackReference = -1
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
            BonusReward = "",
            BackReference = -1
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
            BonusReward = "",
            BackReference = -1
        }
    }
    --Needed to save data about dungeons
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
            Type = 1,
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
  
SV.MissionsEnabled = true
  
end

---Summary
-- Subscribe to all channels this service wants callbacks from
function MissionService:Subscribe(med)
  med:Subscribe("MissionService", EngineServiceEvents.Init,                function() self.OnInit(self) end )
  med:Subscribe("MissionService", EngineServiceEvents.Deinit,              function() self.OnDeinit(self) end )
  med:Subscribe("MissionService", EngineServiceEvents.NewGame,            function() self.OnNewGame(self) end )
  med:Subscribe("MissionService", EngineServiceEvents.UpgradeSave,        function() self.OnUpgrade(self) end )
end

---Summary
-- un-subscribe to all channels this service subscribed to
function MissionService:UnSubscribe(med)
end

---Summary
-- The update method is run as a coroutine for each services.
function MissionService:Update(gtime)
--  while(true)
--    coroutine.yield()
--  end
end

--Add our service
SCRIPT:AddService("MissionService", MissionService:new())
return MissionService