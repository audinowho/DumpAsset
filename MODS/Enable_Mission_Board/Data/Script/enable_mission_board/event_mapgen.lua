require 'enable_mission_board.common'

function ZONE_GEN_SCRIPT.GenerateMissionFromSV(zoneContext, context, queue, seed, args)
    if _DATA.Save.Rescue ~= nil and _DATA.Save.Rescue.Rescuing then
        return
    end

    if not SV.MissionsEnabled then
        return
    end

    SV.DestinationFloorNotified = false
    SV.MonsterHouseMessageNotified = false
    SV.OutlawDefeated = false
    SV.OutlawGoonsDefeated = false
    SV.OutlawItemPickedUp = false
    --local partner = GAME:GetPlayerPartyMember(1)
    --local tbl = LTBL(partner)
    --tbl.MissionNumber = nil
    --tbl.MissionType = nil
    --tbl.EscortMissionNum = nil

    local curMission = nil
    local missionType = nil
    local missionNum = nil
    local escortMissionNum = nil
    local destinationFloor = false
    local outlawFloor = false
    local escortDeathEvent = false
    local activeEffect = RogueEssence.Data.ActiveEffect()

    for _, name in ipairs(COMMON.GetSortedKeys(SV.TakenBoard)) do
        mission = SV.TakenBoard[name]
        if mission.Taken and mission.Completion == COMMON.MISSION_INCOMPLETE and zoneContext.CurrentZone == mission.Zone and mission.BackReference ~= COMMON.FLEE_BACKREFERENCE then
            if mission.Type == COMMON.MISSION_TYPE_ESCORT or mission.Type == COMMON.MISSION_TYPE_EXPLORATION then
                PrintInfo("Adding escort death event...")
                escortDeathEvent = true
                escortMissionNum = name
            end
            if zoneContext.CurrentSegment == mission.Segment and zoneContext.CurrentID + 1 == mission.Floor then
                curMission = mission
                missionNum = name
                missionType = mission.Type
                PrintInfo("Spawning Mission Goal")
                local outlaw_arr = {
                    COMMON.MISSION_TYPE_OUTLAW,
                    COMMON.MISSION_TYPE_OUTLAW_ITEM,
                    COMMON.MISSION_TYPE_OUTLAW_FLEE,
                    COMMON.MISSION_TYPE_OUTLAW_MONSTER_HOUSE
                }

                if COMMON.TableContains(outlaw_arr, mission.Type) then -- outlaw
                    outlawFloor = true
                else
                    if mission.Type == COMMON.MISSION_TYPE_RESCUE or mission.Type == COMMON.MISSION_TYPE_DELIVERY or mission.Type == COMMON.MISSION_TYPE_ESCORT then
                        local specificTeam = RogueEssence.LevelGen.SpecificTeamSpawner()
                        local post_mob = RogueEssence.LevelGen.MobSpawn()
                        post_mob.BaseForm = RogueEssence.Dungeon.MonsterID(mission.Target, 0, "normal", COMMON.NumToGender(mission.TargetGender))
                        post_mob.Tactic = "slow_wander"
                        post_mob.Level = RogueElements.RandRange(50)
                        if mission.Type == COMMON.MISSION_TYPE_RESCUE or mission.Type == COMMON.MISSION_TYPE_DELIVERY then -- rescue
                            local dialogue = RogueEssence.Dungeon.BattleScriptEvent("RescueReached")
                            post_mob.SpawnFeatures:Add(PMDC.LevelGen.MobSpawnInteractable(dialogue))
                            post_mob.SpawnFeatures:Add(PMDC.LevelGen.MobSpawnLuaTable('{ Mission = '..name..' }'))
                        elseif mission.Type == COMMON.MISSION_TYPE_ESCORT then -- escort
                            local dialogue = RogueEssence.Dungeon.BattleScriptEvent("EscortReached")
                            post_mob.SpawnFeatures:Add(PMDC.LevelGen.MobSpawnInteractable(dialogue))
                            post_mob.SpawnFeatures:Add(PMDC.LevelGen.MobSpawnLuaTable('{ Mission = '..name..' }'))
                        end
                        specificTeam.Spawns:Add(post_mob)
                        PrintInfo("Creating Spawn")
                        local picker = LUA_ENGINE:MakeGenericType(PresetMultiTeamSpawnerType, { MapGenContextType }, { })
                        picker.Spawns:Add(specificTeam)
                        PrintInfo("Creating Step")
                        local mobPlacement = LUA_ENGINE:MakeGenericType(PlaceRandomMobsStepType, { MapGenContextType }, { picker })
                        PrintInfo("Setting everything else")

                        mobPlacement.Ally = true
                        mobPlacement.Filters:Add(PMDC.LevelGen.RoomFilterConnectivity(PMDC.LevelGen.ConnectivityRoom.Connectivity.Main))
                        mobPlacement.ClumpFactor = 20
                        PrintInfo("Enqueueing")
                        -- Priority 5.2.1 is for NPC spawning in PMDO, but any dev can choose to roll with their own standard of priority.
                        local priority = RogueElements.Priority(5, 2, 1)
                        queue:Enqueue(priority, mobPlacement)
                    elseif mission.Type == COMMON.MISSION_TYPE_LOST_ITEM then
                        local lost_item = RogueEssence.Dungeon.MapItem(mission.Item)
                        PrintInfo("Spawning Lost Item "..lost_item.Value)
                        local preset_picker = LUA_ENGINE:MakeGenericType(PresetPickerType, { MapItemType }, { lost_item })
                        local multi_preset_picker = LUA_ENGINE:MakeGenericType(PresetMultiRandType, { MapItemType }, { preset_picker })
                        local picker_spawner = LUA_ENGINE:MakeGenericType(PickerSpawnType, {  MapGenContextType, MapItemType }, { multi_preset_picker })
                        local random_room_spawn = LUA_ENGINE:MakeGenericType(RandomRoomSpawnStepType, { MapGenContextType, MapItemType }, { })
                        random_room_spawn.Spawn = picker_spawner
                        random_room_spawn.Filters:Add(PMDC.LevelGen.RoomFilterConnectivity(PMDC.LevelGen.ConnectivityRoom.Connectivity.Main))
                        local priority = RogueElements.Priority(5, 2, 1)
                        queue:Enqueue(priority, random_room_spawn)
                    end
                    destinationFloor = true
                end
            end
        end
    end
    if missionNum ~= nil then
        --tbl.MissionNumber = missionNum
    end

    if escortDeathEvent then
        --tbl.EscortMissionNum = escortMissionNum
        activeEffect.OnDeaths:Add(6, RogueEssence.Dungeon.SingleCharScriptEvent("MissionGuestCheck", '{ Mission = '..escortMissionNum..' }'))
    end
    if destinationFloor then
        -- add destination floor notification
        activeEffect.OnMapStarts:Add(-6, RogueEssence.Dungeon.SingleCharScriptEvent("DestinationFloor", '{ Mission = '..missionNum..' }'))

        if missionType == COMMON.MISSION_TYPE_EXPLORATION and curMission ~= nil then --Exploration
            local escort = COMMON.FindMissionEscort(missionNum)
            local clientName = curMission.Client
            if escort ~= nil then
                PrintInfo("Client name: "..clientName)
                curMission.Completion = 1
                activeEffect.OnMapStarts:Add(-6, RogueEssence.Dungeon.SingleCharScriptEvent("ExplorationReached", '{  Mission = '..escortMissionNum..' }'))
            end
        elseif missionType == COMMON.MISSION_TYPE_LOST_ITEM then
            activeEffect.OnPickups:Add(-6, RogueEssence.Dungeon.ItemScriptEvent("MissionItemPickup", '{ Mission = '..missionNum..' }'))
        end

        local npcMissions = { COMMON.MISSION_TYPE_DELIVERY, COMMON.MISSION_TYPE_ESCORT, COMMON.MISSION_TYPE_RESCUE }
        if COMMON.TableContains(npcMissions, missionType) then
            activeEffect.OnMapTurnEnds:Add(-6, RogueEssence.Dungeon.SingleCharScriptEvent("MobilityEndTurn", '{ Mission = '..missionNum..' }'))
        end
        --tbl.MissionType = COMMON.MISSION_BOARD_MISSION
    end
    if outlawFloor then
        activeEffect.OnDeaths:Add(-6, RogueEssence.Dungeon.SingleCharScriptEvent("OnOutlawDeath", '{ Mission = '..missionNum..' }'))
        if missionType == COMMON.MISSION_TYPE_OUTLAW then
            activeEffect.OnTurnEnds:Add(-6, RogueEssence.Dungeon.SingleCharScriptEvent("OutlawCheck", '{ Mission = '..missionNum..' }'))
        elseif missionType == COMMON.MISSION_TYPE_OUTLAW_FLEE then
            activeEffect.OnMapTurnEnds:Add(-6, RogueEssence.Dungeon.SingleCharScriptEvent("OutlawFleeStairsCheck", '{ Mission = '..missionNum..' }'))
            activeEffect.OnTurnEnds:Add(-6, RogueEssence.Dungeon.SingleCharScriptEvent("OutlawCheck", '{ Mission = '..missionNum..' }'))
        elseif missionType == COMMON.MISSION_TYPE_OUTLAW_ITEM then
            activeEffect.OnPickups:Add(-6, RogueEssence.Dungeon.ItemScriptEvent("OutlawItemPickup", '{ Mission = '..missionNum..' }'))
            activeEffect.OnTurnEnds:Add(-6, RogueEssence.Dungeon.SingleCharScriptEvent("OutlawItemCheck", '{ Mission = '..missionNum..' }'))
        elseif missionType == COMMON.MISSION_TYPE_OUTLAW_MONSTER_HOUSE then
            activeEffect.OnTurnEnds:Add(-6, RogueEssence.Dungeon.SingleCharScriptEvent("OnMonsterHouseOutlawCheck", '{ Mission = '..missionNum..' }'))
        end

        activeEffect.OnMapStarts:Add(-11, RogueEssence.Dungeon.SingleCharScriptEvent("SpawnOutlaw", '{ Mission = '..missionNum..' }'))
        activeEffect.OnMapStarts:Add(-6, RogueEssence.Dungeon.SingleCharScriptEvent("OutlawFloor", '{ Mission = '..missionNum..' }'))
        --tbl.MissionType = COMMON.MISSION_BOARD_MISSION 
    end

    if escortDeathEvent or destinationFloor or outlawFloor then
        local destNote = LUA_ENGINE:MakeGenericType( MapEffectStepType, { MapGenContextType }, { activeEffect })
        local priority = RogueElements.Priority(-6)
        queue:Enqueue(priority, destNote)
    end
end