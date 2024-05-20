--[[
    scriptvars.lua
      This file contains all the default values for the script variables. AKA on a new game this file is loaded!
      Script variables are stored in a table  that gets saved when the game is saved.
      Its meant to be used for scripters to add data to be saved and loaded during a playthrough.
      
      You can simply refer to the "SV" global table like any other table in any scripts!
      You don't need to write a default value in this lua script to add a new value.
      However its good practice to set a default value when you can!
      
    --Examples:
    SV.SomeVariable = "Smiles go for miles!"
    SV.AnotherVariable = 2526
    SV.AnotherVariable = { something={somethingelse={} } }
    SV.AnotherVariable = function() print('lmao') end
]]--

SV.MissionsEnabled = false

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