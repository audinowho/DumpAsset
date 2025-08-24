--[[
    common.lua
    A collection of frequently used functions and values!
]] --
require 'nebula_mission_board.common_vars'
MissionGen = require("missiongen_lib.missiongen_lib")

function COMMON.ShowDestinationMenu(dungeon_entrances, ground_entrances, force_list, speaker, confirm_msg)
    local job_dests = MissionGen:LoadJobDestinations()

    local open_dests = {}
    -- check for unlock of grounds
    for ii = 1, #ground_entrances, 1 do
        if ground_entrances[ii].Flag then
            local ground_id = ground_entrances[ii].Zone
            local zone_summary = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(ground_id)
            local ground = _DATA:GetGround(zone_summary.Grounds[ground_entrances[ii].ID])
            local ground_name = ground:GetColoredName()
            table.insert(open_dests, {
                Name = ground_name,
                Dest = RogueEssence.Dungeon.ZoneLoc(ground_id, -1, ground_entrances[ii].ID, ground_entrances[ii].Entry)
            })
        end
    end

    -- check for unlock of dungeons
    for ii = 1, #dungeon_entrances, 1 do
        if GAME:DungeonUnlocked(dungeon_entrances[ii]) then
            local zone_summary = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(dungeon_entrances[ii])
            if zone_summary.Released then
                local zone_name = ""
                if _DATA.Save:GetDungeonUnlock(dungeon_entrances[ii]) ==
                    RogueEssence.Data.GameProgress.UnlockState.Completed then
                    zone_name = zone_summary:GetColoredName()
                else
                    zone_name = "[color=#00FFFF]" .. zone_summary.Name:ToLocal() .. "[color]"
                end
                zone_name = MissionGen:FormatDestinationMenuZoneName(job_dests, dungeon_entrances[ii], zone_name) -- missiongen_lib.lua file

                table.insert(open_dests, {
                    Name = zone_name,
                    Dest = RogueEssence.Dungeon.ZoneLoc(dungeon_entrances[ii], 0, 0, 0)
                })
            end
        end
    end

    local dest = RogueEssence.Dungeon.ZoneLoc.Invalid
    if #open_dests > 1 or force_list then
        if before_list ~= nil then
            before_list(dest)
        end

        SOUND:PlaySE("Menu/Skip")
        local default_choice = 1
        while true do
            UI:ResetSpeaker()
            UI:DestinationMenu(open_dests, default_choice)
            UI:WaitForChoice()
            default_choice = UI:ChoiceResult()

            if default_choice == nil then
                break
            end
            local ask_dest = open_dests[default_choice].Dest
            if ask_dest.StructID.Segment >= 0 then
                -- chosen dungeon entry
                if speaker ~= nil then
                    UI:SetSpeaker(speaker)
                else
                    UI:ResetSpeaker(false)
                end
                UI:DungeonChoice(open_dests[default_choice].Name, ask_dest)
                UI:WaitForChoice()
                if UI:ChoiceResult() then
                    dest = ask_dest
                    break
                end
            else
                dest = ask_dest
                break
            end
        end
    elseif #open_dests == 1 then
        if open_dests[1].Dest.StructID.Segment < 0 then
            -- single ground entry
            if speaker ~= nil then
                UI:SetSpeaker(speaker)
            else
                UI:ResetSpeaker(false)
                SOUND:PlaySE("Menu/Skip")
            end
            UI:ChoiceMenuYesNo(STRINGS:FormatKey("DLG_ASK_ENTER_GROUND", open_dests[1].Name))
            UI:WaitForChoice()
            if UI:ChoiceResult() then
                dest = open_dests[1].Dest
            end
        else
            -- single dungeon entry
            if speaker ~= nil then
                UI:SetSpeaker(speaker)
            else
                UI:ResetSpeaker(false)
                SOUND:PlaySE("Menu/Skip")
            end
            UI:DungeonChoice(open_dests[1].Name, open_dests[1].Dest)
            UI:WaitForChoice()
            if UI:ChoiceResult() then
                dest = open_dests[1].Dest
            end
        end
    else
        PrintInfo("No valid destinations found!")
    end

    if dest:IsValid() then
        if confirm_msg ~= nil then
            UI:WaitShowDialogue(confirm_msg)
        end
        if dest.StructID.Segment > -1 then
            -- pre-loads the zone on a separate thread while we fade out, just for a little optimization
            _DATA:PreLoadZone(dest.ID)
            SOUND:PlayBGM("", true)
            GAME:FadeOut(false, 20)
            GAME:EnterDungeon(dest.ID, dest.StructID.Segment, dest.StructID.ID, dest.EntryPoint,
                RogueEssence.Data.GameProgress.DungeonStakes.Risk, true, false)
        else
            SOUND:PlayBGM("", true)
            GAME:FadeOut(false, 20)
            GAME:EnterZone(dest.ID, dest.StructID.Segment, dest.StructID.ID, dest.EntryPoint)
        end
    end
end

function COMMON.EnterDungeonMissionCheck(zoneId, segmentID)
    local escort_jobs, removed_names = MissionGen:EnterDungeonPrepareParty(zoneId)
    MissionGen:PrintSentHome(removed_names)

    local added_names = MissionGen:EnterDungeonAddJobEscorts(zoneId, escort_jobs)
    for _, name in ipairs(COMMON.GetSortedKeys(SV.missions.Missions)) do
        local mission = SV.missions.Missions[name]
        if mission.Complete == COMMON.MISSION_INCOMPLETE and zoneId == mission.DestZone and segmentID ==
            mission.DestSegment then
            if mission.Type == 1 then -- escort
                -- add escort to team
                local mon_id = mission.EscortSpecies
                local new_mob = _DATA.Save.ActiveTeam:CreatePlayer(_DATA.Save.Rand, mon_id, 50, "", -1)
                _DATA.Save.ActiveTeam.Guests:Add(new_mob)

                local talk_evt = RogueEssence.Dungeon.BattleScriptEvent("EscortInteract")
                new_mob.ActionEvents:Add(talk_evt)

                local tbl = LTBL(new_mob)
                tbl.Escort = name

                table.insert(added_names, new_mob.Name)
            end
        end
    end
    MissionGen:PrintEscortAdd(added_names)
end