require 'nebula_mission_board.common'


local base_camp_2_bulletin = {}

local base_init = CURMAPSCR.Init
function base_camp_2_bulletin.Init(map)
    base_init(map)
end

local base_enter = CURMAPSCR.Enter
function base_camp_2_bulletin.Enter(map)
    DEBUG.EnableDbgCoro() --Enable debugging this coroutine
    GROUND:Unhide("Mission_Board")
    if MISSION_GEN:HasCompletedMissions() then
        MISSION_GEN:PlayJobsCompletedCutscene(base_camp_2_bulletin.Hand_In_Missions)
    end

    local species = "murkrow"
    local nickname = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Monster]:Get(species).Name:ToLocal()
    local name = "NPC_Reroll"
    local temp_monster = RogueEssence.Dungeon.MonsterID(species, 0, "normal", Gender.Genderless)
    local npc = RogueEssence.Ground.GroundChar(temp_monster, RogueElements.Loc(80, 528), Direction.DownLeft, nickname, name)
    npc:ReloadEvents()
    GAME:GetCurrentGround():AddMapChar(npc)

    base_enter(map)
end


function base_camp_2_bulletin.Mission_Board_Action(obj, activator)
    DEBUG.EnableDbgCoro()   --Enable debugging this coroutine

    local dungeons_needed = 3 --Number of dungeons needed to unlock the Mission Board

    local hero = CH('PLAYER')
    GROUND:CharSetAnim(hero, 'None', true)
    local required = 3

    ---@type LibraryRootStruct
    local root = MISSION_GEN.root
    for _, segments in pairs(root.dungeon_progress) do
        for _, state in pairs(segments) do
            if state then
                required = required - 1
                break
            end
        end
        if required < 1 then break end
    end

    if required<1 then
        _GAME:SE("Menu/Confirm")
        MISSION_GEN:BoardInteract("quest_board")
    else
        UI:ResetSpeaker()
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Board_Locked']))
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Board_Locked_2'], required))
    end

    GROUND:CharEndAnim(hero)
end

function base_camp_2_bulletin.NPC_Reroll_Action(obj, activator)
    local char = CH("NPC_Reroll")
    local anyTaken = false
    local added_price = 0
    for _, job in ipairs(MISSION_GEN.root.boards["quest_board"]) do
        local diff_mult = job.Difficulty
        if job.Difficulty > 7 then diff_mult = diff_mult + job.Difficulty - 7 end
        added_price = added_price + 30*diff_mult
        if job.Taken then
            anyTaken = true
            break
        end
    end

    UI:SetSpeaker(char)
    if SV.jobs.rerolls == nil then
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Board_Reroll_1']))
    end

    if not anyTaken then
        if SV.jobs.rerolls == nil then
            UI:ChoiceMenuYesNo(STRINGS:Format(STRINGS.MapStrings['Mission_Board_Reroll_2']), false)
            SV.jobs.rerolls = 0
        else
            UI:ChoiceMenuYesNo(STRINGS:Format(STRINGS.MapStrings['Mission_Board_Reroll_2a']), false)
        end
        UI:WaitForChoice()
        if UI:ChoiceResult() then
            local rerolls = SV.jobs.rerolls or 0
            local base = 250+500*(2^rerolls)
            local cost = base + added_price
            UI:ChoiceMenuYesNo(STRINGS:Format(STRINGS.MapStrings['Mission_Board_Reroll_Accept'], STRINGS:FormatKey("MONEY_AMOUNT", cost)), true)
            UI:WaitForChoice()
            if UI:ChoiceResult() then
                if GAME:GetPlayerMoney() >= cost then
                    SV.jobs.rerolls = rerolls + 1
	                SOUND:PlayBattleSE("DUN_Money")
                    MISSION_GEN:UpdateBoards()
                    GAME:RemoveFromPlayerMoney(cost)
                    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Board_Reroll_Confirm_1']))
                    GAME:FadeOut(false, 40)
                    GAME:WaitFrames(40)
                    GAME:FadeIn(40)
                    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Board_Reroll_Confirm_2']))
                else
                    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Board_Reroll_NoMoney']))
                end
            else
                UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Board_Reroll_Refuse']))
            end
        else
            UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Board_Reroll_Refuse']))
        end
    else
        if SV.jobs.rerolls == nil then
            UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Board_Reroll_2']))
            SV.jobs.rerolls = 0
        else
            UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Board_Reroll_2a']))
        end
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Board_Reroll_Cannot_1']))
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Board_Reroll_Cannot_2']))
    end
end

-------------------------------------------------------------------------------------------------------------

function base_camp_2_bulletin.Hand_In_Missions(job, npcs)
    ---@cast job jobTable
    local hero = CH('PLAYER')
    GAME:CutsceneMode(true)
    UI:ResetSpeaker()

    GROUND:TeleportTo(hero, 100, 600, Direction.Up)
    GAME:MoveCamera(90, 565, 1, false)

    if #npcs == 4 then
        GROUND:TeleportTo(npcs[1], 100, 575, Direction.Down) --client
        GROUND:TeleportTo(npcs[2], 100, 555, Direction.Down) --outlaw
        GROUND:TeleportTo(npcs[3], 80, 555, Direction.Down)  --left
        GROUND:TeleportTo(npcs[4], 120, 555, Direction.Down) --right
    elseif #npcs == 2 then
        GROUND:TeleportTo(npcs[1], 80, 575, Direction.Down)  --client
        GROUND:TeleportTo(npcs[2], 120, 575, Direction.Down) --target
    else
        GROUND:TeleportTo(npcs[1], 100, 575, Direction.Down) --client
    end

    UI:ResetSpeaker()
    GAME:MoveCamera(90, 565, 1, false)
    SOUND:StopBGM()

    GAME:FadeIn(40)
    SOUND:PlayBGM("Job Clear!.ogg", true)
    UI:SetSpeaker(npcs[1])
    local reward_line1 = STRINGS:Format(STRINGS.MapStrings['Mission_Generic_Reward'])
    local reward_line2 = STRINGS:Format(STRINGS.MapStrings['Mission_Generic_Reward_2'])

    if MISSION_GEN:JobTypeIsLawEnforcement(job.Type) then
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Outlaw_Capture_Cutscene_001'], MISSION_GEN:GetCharacterName(job.Target)))
        GAME:WaitFrames(20)
        reward_line1 = STRINGS:Format(STRINGS.MapStrings['Outlaw_Capture_Cutscene_002'])
        reward_line2 = STRINGS:Format(STRINGS.MapStrings['Outlaw_Capture_Cutscene_003'])
    elseif MISSION_GEN:JobTypeIsOutlaw(job.Type) then
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Outlaw_Retrieve_Cutscene'],
            MISSION_GEN:GetItemName(job.Item)))
    elseif job.Type == "RESCUE_SELF" then
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Response_Rescue']))
    elseif job.Type == "EXPLORATION" then
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Response_Exploration'],
            MISSION_GEN:GetSegmentName(job.Zone, job.Segment)))
    elseif job.Type == "LOST_ITEM" then
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Response_Lost_Item'],
            MISSION_GEN:GetItemName(job.Item)))
    elseif job.Type == "DELIVERY" then
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Response_Delivery_Item'],
            MISSION_GEN:GetItemName(job.Item)))
    elseif job.Type == "ESCORT" then
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Response_Escort']))
    else
        ---RESCUE_FRIEND. this following check is fine because it's the only case with special jobs in this specific project
        if job.Special == "LOVER" then
            UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Response_Lover']))
        elseif job.Special == "RIVAL" then
            UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Response_Rival']))
        elseif job.Special == "CHILD" then
            UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Response_Child']))
        else --if job.Special == "FRIEND" or any other case
            UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mission_Response_Rescue_Friend']))
        end
    end

    GAME:WaitFrames(20)
    MISSION_GEN:RewardPlayer(job, npcs[1], reward_line1, reward_line2)
    GAME:WaitFrames(20)

    if MISSION_GEN:JobTypeIsLawEnforcement(job.Type) then
        UI:SetSpeaker(npcs[1])
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Outlaw_Capture_Cutscene_004']))

        GROUND:CharSetEmote(npcs[3], "happy", 0)
        GROUND:CharSetEmote(npcs[4], "happy", 0)
        local coro1 = TASK:BranchCoroutine(function()
            GROUND:CharSetAction(npcs[1],
                RogueEssence.Ground.PoseGroundAction(npcs[1].Position, npcs[1].Direction,
                    RogueEssence.Content.GraphicsManager.GetAnimIndex("Pose")))
        end)
        local coro2 = TASK:BranchCoroutine(function()
            GROUND:CharSetAction(npcs[3],
                RogueEssence.Ground.PoseGroundAction(npcs[3].Position, npcs[3].Direction,
                    RogueEssence.Content.GraphicsManager.GetAnimIndex("Pose")))
        end)
        local coro3 = TASK:BranchCoroutine(function()
            GROUND:CharSetAction(npcs[4],
                RogueEssence.Ground.PoseGroundAction(npcs[4].Position, npcs[4].Direction,
                    RogueEssence.Content.GraphicsManager.GetAnimIndex("Pose")))
        end)
        local coro4 = TASK:BranchCoroutine(function()
            GAME:WaitFrames(12)
            SOUND:PlayBattleSE('DUN_Magnet_Bomb')
        end)

        TASK:JoinCoroutines({ coro1, coro2, coro3, coro4 })
        GAME:WaitFrames(60)

        GROUND:CharEndAnim(npcs[1])
        GROUND:CharEndAnim(npcs[3])
        GROUND:CharEndAnim(npcs[4])
        GROUND:CharSetEmote(npcs[3], "", 0)
        GROUND:CharSetEmote(npcs[4], "", 0)
        GAME:WaitFrames(20)
    end
    GAME:FadeOut(false, 20)
    GAME:CutsceneMode(false)
end

return base_camp_2_bulletin