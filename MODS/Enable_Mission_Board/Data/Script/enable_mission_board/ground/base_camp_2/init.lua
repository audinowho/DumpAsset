require 'enable_mission_board.common'
require 'enable_mission_board.mission_gen'


local base_camp_2_bulletin = {}
local MapStrings = {}

local base_init = CURMAPSCR.Init
function base_camp_2_bulletin.Init(map)
  MapStrings = COMMON.AutoLoadLocalizedStrings()
  
  base_init(map)
end

local base_enter = CURMAPSCR.Enter
function base_camp_2_bulletin.Enter(map)
    DEBUG.EnableDbgCoro() --Enable debugging this coroutine

    if SV.MissionsEnabled == true then
        GROUND:Unhide("Mission_Board")
    end

    if SV.TemporaryFlags.MissionCompleted then
        base_camp_2_bulletin.Hand_In_Missions()
    end

  base_enter(map)
end


function base_camp_2_bulletin.Mission_Board_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine

  local dungeons_needed = 3 --Number of dungeons needed to unlock the Mission Board

  local hero = CH('PLAYER')
  GROUND:CharSetAnim(hero, 'None', true)

  if SV.MissionPrereq.NumDungeonsCompleted >= dungeons_needed then
    local menu = BoardSelectionMenu:new(COMMON.MISSION_BOARD_MISSION)
    UI:SetCustomMenu(menu.menu)
    UI:WaitForChoice()
  else
    UI:ResetSpeaker()
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Board_Locked']))
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Board_Locked_2'], dungeons_needed - SV.MissionPrereq.NumDungeonsCompleted))
  end

  GROUND:CharEndAnim(hero)
end

function base_camp_2_bulletin.Hand_In_Missions()
  for i = 8, 1, -1 do
    if SV.TakenBoard[i].Client ~= "" and SV.TakenBoard[i].Completion == MISSION_GEN.COMPLETE then
      if SV.TakenBoard[i].Type == COMMON.MISSION_TYPE_OUTLAW or SV.TakenBoard[i].Type == COMMON.MISSION_TYPE_OUTLAW_ITEM
              or SV.TakenBoard[i].Type == COMMON.MISSION_TYPE_OUTLAW_FLEE or SV.TakenBoard[i].Type == COMMON.MISSION_TYPE_OUTLAW_MONSTER_HOUSE then
        base_camp_2_bulletin.Outlaw_Job_Clear(SV.TakenBoard[i])
      else
        base_camp_2_bulletin.Mission_Job_Clear(SV.TakenBoard[i])
      end
      --short pause between fadeins
      GAME:WaitFrames(20)

      --clear the job
      SV.TakenBoard[i] = 	{
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
    end
  end
  --reset this flag
  SV.TemporaryFlags.MissionCompleted = false

  GAME:MoveCamera(0, 0, 1, true)
  SOUND:PlayBGM(SV.base_town.Song, true)
  MISSION_GEN.RegenerateJobs(result)

  --sort taken jobs now that we're removed completed ones
  MISSION_GEN.SortTaken()
end

--takes a job and plays an outlaw reward scene depending on the job.
function base_camp_2_bulletin.Outlaw_Job_Clear(job)
  local hero = CH('PLAYER')
  GAME:CutsceneMode(true)
  UI:ResetSpeaker()

  GROUND:TeleportTo(hero, 100, 600, Direction.Up)
  GAME:MoveCamera(90, 565, 1, false)

  SOUND:StopBGM()

  local money = false
  if job.Reward == 'money' then money = true end

  --client is magna, he and the magnemite take the outlaw away
  if job.Client == 'magna' then
    local magnemite_left, magnemite_right, magna =
    COMMON.MakeCharactersFromList({
      --{'Sandile', 100, 555, Direction.Down},
      {'Magnemite_Left', 80, 555, Direction.Down},
      {'Magnemite_Right', 120, 555, Direction.Down},
      {'Magnezone', 100, 575, Direction.Down}
    })

    local outlaw_gender = job.TargetGender
    outlaw_gender = COMMON.NumToGender(outlaw_gender)

    local outlaw_monster = RogueEssence.Dungeon.MonsterID(job.Target, 0, "normal", outlaw_gender)

    local outlaw = RogueEssence.Ground.GroundChar(outlaw_monster, RogueElements.Loc(100, 555), Direction.Down, outlaw_monster.Species, 'Outlaw')
    outlaw:ReloadEvents()
    GAME:GetCurrentGround():AddTempChar(outlaw)

    GAME:FadeIn(40)
    SOUND:PlayBGM("Job Clear!.ogg", true)
    UI:SetSpeaker(magna)

    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Outlaw_Capture_Cutscene_001'], _DATA:GetMonster(outlaw.CurrentForm.Species):GetColoredName()))

    GAME:WaitFrames(20)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Outlaw_Capture_Cutscene_002']))
    GAME:WaitFrames(20)

    --reward the item 
    if money then
      COMMON.RewardItem(MISSION_GEN.DIFF_TO_MONEY[job.Difficulty], true)
    else
      COMMON.RewardItem(job.Reward)
    end


    if job.BonusReward ~= '' then
      UI:SetSpeaker(magna)
      GAME:WaitFrames(20)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Outlaw_Capture_Cutscene_003']))
      GAME:WaitFrames(20)
      COMMON.RewardItem(job.BonusReward)
    end

    GAME:WaitFrames(20)
    base_camp_2_bulletin.RewardEXP(job)

    GAME:WaitFrames(20)

    UI:SetSpeaker(magna)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Outlaw_Capture_Cutscene_004']))

    GROUND:CharSetEmote(magnemite_left, "happy", 0)
    GROUND:CharSetEmote(magnemite_right, "happy", 0)
    local coro1 = TASK:BranchCoroutine(function() GROUND:CharSetAction(magna, RogueEssence.Ground.PoseGroundAction(magna.Position, magna.Direction, RogueEssence.Content.GraphicsManager.GetAnimIndex("Pose"))) end)
    local coro2 = TASK:BranchCoroutine(function() GROUND:CharSetAction(magnemite_left, RogueEssence.Ground.PoseGroundAction(magnemite_left.Position, magnemite_left.Direction, RogueEssence.Content.GraphicsManager.GetAnimIndex("Pose"))) end)
    local coro3 = TASK:BranchCoroutine(function() GROUND:CharSetAction(magnemite_right, RogueEssence.Ground.PoseGroundAction(magnemite_right.Position, magnemite_right.Direction, RogueEssence.Content.GraphicsManager.GetAnimIndex("Pose"))) end)
    local coro4 = TASK:BranchCoroutine(function() GAME:WaitFrames(12) SOUND:PlayBattleSE('DUN_Magnet_Bomb') end)

    TASK:JoinCoroutines({coro1, coro2, coro3, coro4})
    GAME:WaitFrames(60)

    GROUND:CharEndAnim(magna)
    GROUND:CharEndAnim(magnemite_left)
    GROUND:CharEndAnim(magnemite_right)
    GROUND:CharSetEmote(magnemite_left, "", 0)
    GROUND:CharSetEmote(magnemite_right, "", 0)
    GAME:WaitFrames(20)

    --fade out and clean up any temporary characters
    SOUND:FadeOutBGM(40)
    GAME:FadeOut(false, 40)
    GAME:GetCurrentGround():RemoveTempChar(magna)
    GAME:GetCurrentGround():RemoveTempChar(magnemite_left)
    GAME:GetCurrentGround():RemoveTempChar(magnemite_right)
    GAME:GetCurrentGround():RemoveTempChar(outlaw)


  else--client is some random mon
    local client_gender = job.ClientGender
    client_gender = COMMON.NumToGender(client_gender)
    client_gender = client_gender

    local client_monster = RogueEssence.Dungeon.MonsterID(job.Client, 0, "normal", client_gender)

    local client = RogueEssence.Ground.GroundChar(client_monster, RogueElements.Loc(100, 575), Direction.Down, job.Client:gsub("^%l", string.upper), client_monster.Species)
    client:ReloadEvents()
    GAME:GetCurrentGround():AddTempChar(client)

    GAME:FadeIn(40)
    SOUND:PlayBGM("Job Clear!.ogg", true)
    UI:SetSpeaker(client)


    local item = RogueEssence.Dungeon.InvItem(job.Item)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Outlaw_Retrieve_Cutscene'], item:GetDisplayName()))
    GAME:WaitFrames(20)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Generic_Reward']))
    GAME:WaitFrames(20)

    --reward the item 
    if money then
      COMMON.RewardItem(MISSION_GEN.DIFF_TO_MONEY[job.Difficulty], true)
    else
      COMMON.RewardItem(job.Reward)
    end

    if job.BonusReward ~= '' then
      UI:SetSpeaker(client)
      GAME:WaitFrames(20)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Generic_Reward_2']))
      GAME:WaitFrames(20)
      COMMON.RewardItem(job.BonusReward)
    end

    GAME:WaitFrames(20)
    base_camp_2_bulletin.RewardEXP(job)
    GAME:WaitFrames(20)

    --fade out and clean up any temporary characters
    SOUND:FadeOutBGM(40)
    GAME:FadeOut(false, 40)
    GAME:GetCurrentGround():RemoveTempChar(client)
  end

  GAME:CutsceneMode(false)
end

--takes a job and plays an regular mission reward scene depending on the job.
function base_camp_2_bulletin.Mission_Job_Clear(job)
  local hero = CH('PLAYER')
  GAME:CutsceneMode(true)
  UI:ResetSpeaker()

  GROUND:TeleportTo(hero, 100, 600, Direction.Up)
  GAME:MoveCamera(90, 565, 1, false)
  SOUND:StopBGM()

  local money = false
  if job.Reward == 'money' then money = true end

  --client is target. Check on escort is needed in case the escort is to the same species.
  if job.Client == job.Target and job.Type ~= COMMON.MISSION_TYPE_ESCORT then
    local client_gender = job.ClientGender
    client_gender = COMMON.NumToGender(client_gender)

    local client_monster = RogueEssence.Dungeon.MonsterID(job.Client, 0, "normal", client_gender)
    local client = RogueEssence.Ground.GroundChar(client_monster, RogueElements.Loc(100, 575), Direction.Down, job.Client:gsub("^%l", string.upper), client_monster.Species)
    client:ReloadEvents()
    GAME:GetCurrentGround():AddTempChar(client)

    GAME:FadeIn(40)
    SOUND:PlayBGM("Job Clear!.ogg", true)
    UI:SetSpeaker(client)

    --different thank you message depending on the job type
    if job.Type == COMMON.MISSION_TYPE_RESCUE then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Rescue']))
    elseif job.Type == COMMON.MISSION_TYPE_EXPLORATION then
      local zone = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(job.Zone)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Exploration'], zone:GetColoredName()))
    elseif job.Type == COMMON.MISSION_TYPE_LOST_ITEM then
      local item = RogueEssence.Dungeon.InvItem(job.Item)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Lost_Item'], item:GetDisplayName()))
    else--delivery 
      local item = RogueEssence.Dungeon.InvItem(job.Item)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Delivery_Item'], item:GetDisplayName()))
    end

    GAME:WaitFrames(20)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Generic_Reward']))
    GAME:WaitFrames(20)

    --reward the item 
    if money then
      COMMON.RewardItem(MISSION_GEN.DIFF_TO_MONEY[job.Difficulty], true)
    else
      COMMON.RewardItem(job.Reward)
    end

    if job.BonusReward ~= '' then
      UI:SetSpeaker(client)
      GAME:WaitFrames(20)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Generic_Reward_2']))
      GAME:WaitFrames(20)
      COMMON.RewardItem(job.BonusReward)
    end

    GAME:WaitFrames(20)
    base_camp_2_bulletin.RewardEXP(job)
    GAME:WaitFrames(20)


    --fade out and clean up any temporary characters
    SOUND:FadeOutBGM(40)
    GAME:FadeOut(false, 40)
    GAME:GetCurrentGround():RemoveTempChar(client)



  else--client not the target
    local client_gender = job.ClientGender
    client_gender = COMMON.NumToGender(client_gender)


    local client_monster = RogueEssence.Dungeon.MonsterID(job.Client, 0, "normal", client_gender)

    local client = RogueEssence.Ground.GroundChar(client_monster, RogueElements.Loc(80, 575), Direction.Down, job.Client:gsub("^%l", string.upper), client_monster.Species)
    client:ReloadEvents()
    GAME:GetCurrentGround():AddTempChar(client)

    local target_gender = job.TargetGender
    target_gender = COMMON.NumToGender(target_gender)

    local target_monster = RogueEssence.Dungeon.MonsterID(job.Target, 0, "normal", target_gender)
    target_monster.Gender = _DATA:GetMonster(job.Target).Forms[0]:RollGender(_ZONE.CurrentGround.Rand)

    local target = RogueEssence.Ground.GroundChar(target_monster, RogueElements.Loc(120, 575), Direction.Down, job.Target:gsub("^%l", string.upper), target_monster.Species)
    target:ReloadEvents()
    GAME:GetCurrentGround():AddTempChar(target)


    GAME:FadeIn(40)
    SOUND:PlayBGM("Job Clear!.ogg", true)
    UI:SetSpeaker(client)

    if job.Type == COMMON.MISSION_TYPE_ESCORT then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Escort']))
    else
      if job.Special == MISSION_GEN.SPECIAL_CLIENT_LOVER then
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Lover']))
      elseif job.Special == MISSION_GEN.SPECIAL_CLIENT_RIVAL then
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Rival']))
      elseif job.Special == MISSION_GEN.SPECIAL_CLIENT_CHILD then
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Child']))
      else
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Rescue_Friend']))
      end
    end
    GAME:WaitFrames(20)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Generic_Reward']))
    GAME:WaitFrames(20)

    --reward the item 
    if money then
      COMMON.RewardItem(MISSION_GEN.DIFF_TO_MONEY[job.Difficulty], true)
    else
      COMMON.RewardItem(job.Reward)
    end

    if job.BonusReward ~= '' then
      UI:SetSpeaker(client)
      GAME:WaitFrames(20)
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Generic_Reward_2']))
      GAME:WaitFrames(20)
      COMMON.RewardItem(job.BonusReward)
    end

    GAME:WaitFrames(20)
    base_camp_2_bulletin.RewardEXP(job)
    GAME:WaitFrames(20)


    --fade out and clean up any temporary characters
    SOUND:FadeOutBGM(40)
    GAME:FadeOut(false, 40)
    GAME:GetCurrentGround():RemoveTempChar(client)
    GAME:GetCurrentGround():RemoveTempChar(target)
  end
  GAME:CutsceneMode(false)
end

function base_camp_2_bulletin.RewardEXP(job)
  --Reward EXP for your party
  local exp_reward = MISSION_GEN.GetJobExpReward(job.Difficulty)
  local exp_reward_string = "[color=#00FFFF]"..exp_reward.."[color]"
  UI:ResetSpeaker()
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Handout_EXP'], exp_reward_string))
  PrintInfo("Rewarding EXP for job with difficulty "..job.Difficulty.." and reward "..exp_reward_string)
  local player_count = _DATA.Save.ActiveTeam.Players.Count
  for player_idx = 0, player_count-1, 1 do
    TASK:WaitTask(GROUND:_HandoutEXP(_DATA.Save.ActiveTeam.Players[player_idx], exp_reward))
  end
end

return base_camp_2_bulletin