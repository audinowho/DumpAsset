--[[
    common.lua
    A collection of frequently used functions and values!
]]--
require 'enable_mission_board.menu.MemberReturnMenu'
require 'enable_mission_board.common_vars'

LoadGenType = luanet.import_type('RogueEssence.LevelGen.LoadGen')
ChanceFloorGenType = luanet.import_type('RogueEssence.LevelGen.ChanceFloorGen')

COMMON.MISSION_TYPE_OUTLAW = 4
COMMON.MISSION_TYPE_EXPLORATION = 5
COMMON.MISSION_TYPE_LOST_ITEM = 6
COMMON.MISSION_TYPE_OUTLAW_ITEM = 7
COMMON.MISSION_TYPE_OUTLAW_FLEE = 8
COMMON.MISSION_TYPE_OUTLAW_MONSTER_HOUSE = 9
COMMON.MISSION_TYPE_DELIVERY = 10

COMMON.MISSION_BOARD_MISSION = 0
COMMON.MISSION_BOARD_OUTLAW = 1
COMMON.MISSION_BOARD_TAKEN = 2

local characters = {
    --Head of Police
    Magnezone = {
        species = "magnezone",
        nickname = 'Magnezone',
        instance = 'Magnezone',
        gender = Gender.Male,
        form = 0,
        skin = "normal"
    },

    Magnemite_Left = {
        species = "magnemite",
        nickname = 'Magnemite',
        instance = 'Magnemite_Left',
        gender = Gender.Male,
        form = 0,
        skin = "normal"
    },

    Magnemite_Right = {
        species = "magnemite",
        nickname = 'Magnemite',
        instance = 'Magnemite_Right',
        gender = Gender.Female,
        form = 0,
        skin = "normal"
    },
}

function COMMON.ShowDestinationMenu(dungeon_entrances, ground_entrances, force_list, speaker, confirm_msg)  --get dungeons with a taken mission
    local mission_dests = {}

    for i = 1, 8, 1 do
        local zone = SV.TakenBoard[i].Zone
        if zone ~= nil and zone ~= '' and SV.TakenBoard[i].Taken then
            mission_dests[zone] = 1
        end
    end

    local open_dests = {}

    --check for unlock of grounds
    for ii = 1,#ground_entrances,1 do
        if ground_entrances[ii].Flag then
            local ground_id = ground_entrances[ii].Zone
            local zone_summary = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(ground_id)
            local ground = _DATA:GetGround(zone_summary.Grounds[ground_entrances[ii].ID])
            local ground_name = ground:GetColoredName()
            table.insert(open_dests, { Name=ground_name, Dest=RogueEssence.Dungeon.ZoneLoc(ground_id, -1, ground_entrances[ii].ID, ground_entrances[ii].Entry) })
        end
    end

    --check for unlock of dungeons
    for ii = 1,#dungeon_entrances,1 do
        local zone = dungeon_entrances[ii]
        if GAME:DungeonUnlocked(zone) then
            local zone_summary = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(zone)
            if zone_summary.Released then
                local zone_name = ""
                if _DATA.Save:GetDungeonUnlock(zone) == RogueEssence.Data.GameProgress.UnlockState.Completed then
                    zone_name = zone_summary:GetColoredName()
                else
                    zone_name = "[color=#00FFFF]"..zone_summary.Name:ToLocal().."[color]"
                end
                if SV.MissionsEnabled then
                    if mission_dests[zone] ~= nil then
                        zone_name = STRINGS:Format("\\uE10F") .. zone_name --open letter
                    elseif COMMON.HasSidequestInZone(zone) then
                        zone_name = STRINGS:Format("\\uE111") .. zone_name --exclamation point
                    end
                end
                table.insert(open_dests, { Name=zone_name, Dest=RogueEssence.Dungeon.ZoneLoc(zone, 0, 0, 0) })
            end
        end
    end

    local dest = RogueEssence.Dungeon.ZoneLoc.Invalid
    if #open_dests > 1 or force_list then
        if before_list ~= nil then
            before_list(dest)
        end

        SOUND:PlaySE("Menu/Skip")
        default_choice = 1
        while true do
            UI:ResetSpeaker()
            UI:DestinationMenu(open_dests, default_choice)
            UI:WaitForChoice()
            default_choice = UI:ChoiceResult()

            if default_choice == nil then
                break
            end
            ask_dest = open_dests[default_choice].Dest
            if ask_dest.StructID.Segment >= 0 then
                --chosen dungeon entry
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
            --single ground entry
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
            --single dungeon entry
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
            --pre-loads the zone on a separate thread while we fade out, just for a little optimization
            _DATA:PreLoadZone(dest.ID)
            SOUND:PlayBGM("", true)
            GAME:FadeOut(false, 20)
            GAME:EnterDungeon(dest.ID, dest.StructID.Segment, dest.StructID.ID, dest.EntryPoint, RogueEssence.Data.GameProgress.DungeonStakes.Risk, true, false)
        else
            SOUND:PlayBGM("", true)
            GAME:FadeOut(false, 20)
            GAME:EnterZone(dest.ID, dest.StructID.Segment, dest.StructID.ID, dest.EntryPoint)
        end
    end
end

function COMMON.EnterDungeonMissionCheck(zoneId, segmentID)
    for name, mission in pairs(SV.TakenBoard) do
        if mission.Taken and mission.Completion == COMMON.MISSION_INCOMPLETE and zoneId == mission.Zone and mission.Client ~= "" then
            if mission.Type == COMMON.MISSION_TYPE_ESCORT or mission.Type == COMMON.MISSION_TYPE_EXPLORATION then -- escort
                -- add escort to team
                local player_count = GAME:GetPlayerPartyCount()
                local guest_count = GAME:GetPlayerGuestCount()

                --check to see if an escort is already in the team. If so, stop right here and don't assign him back in.
                for i = 0, guest_count - 1, 1 do
                    local guest_tbl = LTBL(GAME:GetPlayerGuestMember(i))
                    if guest_tbl.Escort ~= nil then return end
                end

                local mon_id = RogueEssence.Dungeon.MonsterID(mission.Client, 0, "normal", COMMON.NumToGender(mission.ClientGender))
                -- set the escort level 20% less than the expected level
                local level = math.floor(SV.ExpectedLevel[mission.Zone] * 0.80)
                local new_mob = _DATA.Save.ActiveTeam:CreatePlayer(_DATA.Save.Rand, mon_id, level, "", -1)
                local tactic = _DATA:GetAITactic("stick_together")
                new_mob.Tactic = RogueEssence.Data.AITactic(tactic);
                _DATA.Save.ActiveTeam.Guests:Add(new_mob)
                local talk_evt = RogueEssence.Dungeon.BattleScriptEvent("EscortInteract")
                new_mob.ActionEvents:Add(talk_evt)

                local tbl = LTBL(new_mob)
                tbl.Escort = name

                UI:ResetSpeaker()
                UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MISSION_ESCORT_ADD"):ToLocal(), new_mob.Name))
            end
        end
    end
end

function COMMON.NumToGender(num)
    local res = Gender.Unknown
    if num == 0 then
        res = Gender.Genderless
    elseif num == 1 then
        res = Gender.Male
    elseif num == 2 then
        res = Gender.Female
    end
    return res
end

function COMMON.ResetAnims()
    local player_count = GAME:GetPlayerPartyCount()
    local guest_count = GAME:GetPlayerGuestCount()
    for i = 0, player_count - 1, 1 do
        local player = GAME:GetPlayerPartyMember(i)
        if not player.Dead then
            local anim = RogueEssence.Dungeon.CharAnimAction()
            anim.BaseFrameType = 0 --none
            anim.AnimLoc = player.CharLoc
            anim.CharDir = player.CharDir
            TASK:WaitTask(player:StartAnim(anim))
        end
    end

    for i = 0, guest_count - 1, 1 do
        local guest = GAME:GetPlayerGuestMember(i)
        if not guest.Dead then
            local anim = RogueEssence.Dungeon.CharAnimAction()
            anim.BaseFrameType = 0 --none
            anim.AnimLoc = guest.CharLoc
            anim.CharDir = guest.CharDir
            TASK:WaitTask(guest:StartAnim(anim))
        end
    end
end

function COMMON.InArray(value, array)
    for index = 1, #array do
        if array[index] == value then
            return true
        end
    end

    return false -- We could ommit this part, as nil is like false
end

function COMMON.EndDungeonDay(result, zoneId, structureId, mapId, entryId)
    COMMON.EndDayCycle()

    COMMON.ResetAnims()

    GAME:EndDungeonRun(result, zoneId, structureId, mapId, entryId, true, true)
    if GAME:InRogueMode() then
        if result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
            UI:ResetSpeaker()
            local msg = STRINGS:FormatKey("DLG_TRY_AGAIN_ASK");
            UI:ChoiceMenuYesNo(msg, false)
            UI:WaitForChoice()
            result = UI:ChoiceResult()
            GAME:WaitFrames(50);
            if result then
                local curConfig = _DATA.Save.Config
                -- set current save file to main save file, this is to get the right starterlist
                -- this is hacky since it sets the current save file in an inconsisten state with the lua, but it's technically the most accurate way in lua
                -- also this state won't last long- it'll be cleared on our reset
                _DATA.Save = _DATA:GetProgress()
                local config = RogueEssence.Data.RogueConfig.RerollFromOther(curConfig)
                GAME:RestartRogue(config)
            else
                GAME:RestartToTitle()
            end
        else
            GAME:RestartToTitle()
        end
    else
        GAME:EnterZone(zoneId, structureId, mapId, entryId)
    end
end

function COMMON.GenderToNum(gender)
    local res = -1
    if gender == Gender.Genderless then
        res = 0
    elseif gender == Gender.Male then
        res = 1
    elseif gender == Gender.Female then
        res = 2
    end
    return res
end

function COMMON.TableContains(table, val)
    for i=1,#table do
        if table[i] == val then
            return true
        end
    end
    return false
end


--called whenever to warp the party out, including guests
function COMMON.WarpOut()
    local player_count = GAME:GetPlayerPartyCount()
    local guest_count = GAME:GetPlayerGuestCount()
    for i = 0, player_count - 1, 1 do
        local player = GAME:GetPlayerPartyMember(i)
        if not player.Dead then
            GAME:WaitFrames(30)
            local anim = RogueEssence.Dungeon.CharAbsentAnim(player.CharLoc, player.CharDir)
            COMMON.RemoveCharEffects(player)
            TASK:WaitTask(_DUNGEON:ProcessBattleFX(player, player, _DATA.SendHomeFX))
            TASK:WaitTask(player:StartAnim(anim))
        end
    end

    for i = 0, guest_count - 1, 1 do
        local guest = GAME:GetPlayerGuestMember(i)
        if not guest.Dead then
            GAME:WaitFrames(30)
            local anim = RogueEssence.Dungeon.CharAbsentAnim(guest.CharLoc, guest.CharDir)
            COMMON.RemoveCharEffects(guest)
            TASK:WaitTask(_DUNGEON:ProcessBattleFX(guest, guest, _DATA.SendHomeFX))
            TASK:WaitTask(guest:StartAnim(anim))
        end
    end
end

function COMMON.ResetPose()
    local player_count = GAME:GetPlayerPartyCount()
    local guest_count = GAME:GetPlayerGuestCount()
    for i = 0, player_count - 1, 1 do
        local player = GAME:GetPlayerPartyMember(i)
        if not player.Dead and player.CharLoc ~= nil and player.CharDir ~= nil then
            local anim = RogueEssence.Dungeon.CharAnimIdle(player.CharLoc, player.CharDir)
            TASK:WaitTask(player:StartAnim(anim))
        end
    end

    for i = 0, guest_count - 1, 1 do
        local guest = GAME:GetPlayerGuestMember(i)
        if not guest.Dead and guest.CharLoc ~= nil and guest.CharDir ~= nil then
            local anim = RogueEssence.Dungeon.CharAnimIdle(guest.CharLoc, guest.CharDir)
            TASK:WaitTask(guest:StartAnim(anim))
        end
    end
end

--called whenever a mission is completed
function COMMON.AskMissionWarpOut()
    local function MissionWarpOut()
        COMMON.WarpOut()
        GAME:WaitFrames(80)
        --Set minimap state back to old setting
        _DUNGEON.ShowMap = SV.TemporaryFlags.PriorMapSetting
        SV.TemporaryFlags.PriorMapSetting = nil
        TASK:WaitTask(_GAME:EndSegment(RogueEssence.Data.GameProgress.ResultType.Escaped))
    end

    local function SetMinimap()
        --to prevent accidentally doing something by pressing the button to select yes
        GAME:WaitFrames(10)
        --Set minimap state back to old setting
        _DUNGEON.ShowMap = SV.TemporaryFlags.PriorMapSetting
        SV.TemporaryFlags.PriorMapSetting = nil
    end

    local has_ongoing_mission = false
    local curr_floor = GAME:GetCurrentFloor().ID + 1
    local curr_zone = _ZONE.CurrentZoneID
    local curr_segment = _ZONE.CurrentMapID.Segment

    for _, mission in ipairs(SV.TakenBoard) do
        if mission.Floor > curr_floor and mission.Taken and mission.Completion == COMMON.MISSION_INCOMPLETE and curr_zone == mission.Zone and curr_segment == mission.Segment then
            has_ongoing_mission = true
            break
        end
    end


    UI:ResetSpeaker()
    local state = 0
    while state > -1 do
        if state == 0 then
            if has_ongoing_mission then
                UI:ChoiceMenuYesNo(STRINGS:Format(RogueEssence.StringKey("DLG_MISSION_CONTINUE_ONGOING"):ToLocal()), true)
                UI:WaitForChoice()
                local leave_dungeon = UI:ChoiceResult()
                if leave_dungeon then
                    UI:ChoiceMenuYesNo(STRINGS:Format(RogueEssence.StringKey("DLG_MISSION_CONTINUE_CONFIRM"):ToLocal()), true)
                    UI:WaitForChoice()
                    local leave_confirm = UI:ChoiceResult()
                    if leave_confirm then
                        state = -1
                        MissionWarpOut()
                    else
                        --pause between textboxes if player de-confirms
                        GAME:WaitFrames(20)
                    end
                else
                    state = -1
                    SetMinimap()
                end
            else
                UI:ChoiceMenuYesNo(STRINGS:Format(RogueEssence.StringKey("DLG_MISSION_CONTINUE_NO_ONGOING"):ToLocal()), false)
                UI:WaitForChoice()
                local leave_dungeon = UI:ChoiceResult()
                if leave_dungeon then
                    state = -1
                    MissionWarpOut()
                else
                    state = -1
                    SetMinimap()
                end
            end
        end
    end
end


function COMMON.RemoveCharEffects(char)
    char.StatusEffects:Clear();
    char.ProxyAtk = -1;
    char.ProxyDef = -1;
    char.ProxyMAtk = -1;
    char.ProxyMDef = -1;
    char.ProxySpeed = -1;
end

function COMMON.MakeCharactersFromList(list, retTable)
    retTable = retTable or false--return a table of chars rather than multiple chars if this is true
    local charTable = {}
    local chara = 0
    local length = 0
    for i = 1, #list, 1 do
        local name = list[i][1]
        length = #list[i]
        if length == 1 then--this case is so we can reference characters that aren't on the map. Put them at 0, 0 and hide them
            local monster = RogueEssence.Dungeon.MonsterID(characters[name].species,
                    characters[name].form,
                    characters[name].skin,
                    characters[name].gender)
            chara = RogueEssence.Ground.GroundChar(monster, RogueElements.Loc(0, 0), Direction.Down, name, characters[name].instance)
            chara:ReloadEvents()
            GAME:GetCurrentGround():AddTempChar(chara)
            GROUND:Hide(chara.EntName)

        elseif length == 2 then --may be inefficient to do a length lookup so often...
            local marker = MRKR(list[i][2])
            local monster = RogueEssence.Dungeon.MonsterID(characters[name].species,
                    characters[name].form,
                    characters[name].skin,
                    characters[name].gender)
            chara = RogueEssence.Ground.GroundChar(monster, RogueElements.Loc(marker.Position.X, marker.Position.Y), marker.Direction, name, characters[name].instance)
            chara:ReloadEvents()
            GAME:GetCurrentGround():AddTempChar(chara)
        else
            local x = list[i][2]
            local y = list[i][3]
            local direction = list[i][4]
            local monster = RogueEssence.Dungeon.MonsterID(characters[name].species,
                    characters[name].form,
                    characters[name].skin,
                    characters[name].gender)
            chara = RogueEssence.Ground.GroundChar(monster, RogueElements.Loc(x, y), direction, name, characters[name].instance)
            chara:ReloadEvents()
            GAME:GetCurrentGround():AddTempChar(chara)

        end
        chara:OnMapInit()
        local result = RogueEssence.Script.TriggerResult()
        TASK:WaitTask(chara:RunEvent(RogueEssence.Script.LuaEngine.EEntLuaEventTypes.EntSpawned, result, chara))
        charTable[i] = chara
    end
    if retTable then
        return charTable
    else
        return table.unpack(charTable)
    end
end

function COMMON.TeamTurnTo(char)
    local player_count = GAME:GetPlayerPartyCount()
    local guest_count = GAME:GetPlayerGuestCount()
    for i = 0, player_count - 1, 1 do
        local player = GAME:GetPlayerPartyMember(i)
        if not player.Dead then
            DUNGEON:CharTurnToChar(player, char)
        end
    end

    for i = 0, guest_count - 1, 1 do
        local guest = GAME:GetPlayerGuestMember(i)
        if not guest.Dead then
            DUNGEON:CharTurnToChar(guest, char)
        end
    end
end

--used to reward items to the player, sends the item to storage if inv is full
function COMMON.RewardItem(itemID, money, amount)
    --if money is true, the itemID is instead the amount of money to award
    if money == nil then money = false end

    UI:ResetSpeaker(false)--disable text noise
    UI:SetCenter(true)


    SOUND:PlayFanfare("Fanfare/Item")

    if money then
        UI:WaitShowDialogue("Team " .. GAME:GetTeamName() .. " received " .. "[color=#00FFFF]" .. itemID .. "[color]" .. STRINGS:Format("\\uE024") .. ".[pause=40]")
        GAME:AddToPlayerMoney(itemID)
    else
        local itemEntry = RogueEssence.Data.DataManager.Instance:GetItem(itemID)

        --for stackable items, always give 3 of them as a reward

        --give at least 1 item
        if amount == nil then amount = 1 end
        if itemEntry.MaxStack >= 3 then
            --for stackable items, always give 3 of them as a reward
            amount = 3
        end

        local item = RogueEssence.Dungeon.InvItem(itemID, false, amount)

        local article = "a"

        local first_letter = string.upper(string.sub(_DATA:GetItem(item.ID).Name:ToLocal(), 1, 1))

        if first_letter == "A" or first_letter == 'E' or first_letter == 'I' or first_letter == 'O' or first_letter == 'U' then article = 'an' end

        UI:WaitShowDialogue("Team " .. GAME:GetTeamName() .. " received " .. article .. " " .. item:GetDisplayName() ..".[pause=40]")

        --bag is full - equipped count is separate from bag and must be included in the calc
        if GAME:GetPlayerBagCount() + GAME:GetPlayerEquippedCount() >= GAME:GetPlayerBagLimit() then
            UI:WaitShowDialogue("The " .. item:GetDisplayName() .. " was sent to storage.")
            GAME:GivePlayerStorageItem(item.ID, amount)
        else
            GAME:GivePlayerItem(item.ID, amount)
        end

    end
    UI:SetCenter(false)
    UI:ResetSpeaker()


end

--Given a segment name string obtained by segment.ToString(), return a colored segment.
--This is obtained by removing the last part of the segment name as it is the floor indicator and wrapping yellow around it
function COMMON.CreateColoredSegmentString(segment_name)
    local split_name = {}

    local index = 1

    for str in string.gmatch(segment_name, "([^%s]+)") do
        table.insert(split_name, index, str)
        index = index + 1
    end

    local final_name = ''

    for i = 1, #split_name, 1 do
        local cur_word = split_name[i]

        if i == 1 then
            final_name = cur_word
        elseif i ~= #split_name then
            final_name = final_name .. ' ' .. cur_word
        end
    end

    return '[color=#FFC663]'..final_name..'[color]'
end


function COMMON.GetNoMissionFloors(current_segment)
    local no_mission_floors = {}
    local floor_count = current_segment.FloorCount
    for i=0, floor_count - 1, 1 do
        local map_gen = current_segment:GetMapGen(i)
        local type = LUA_ENGINE:TypeOf(map_gen)
        if type:IsAssignableTo(luanet.ctype(LoadGenType)) or type:IsAssignableTo(luanet.ctype(ChanceFloorGenType)) then
            PrintInfo("Type is of "..type.FullName..", "..i.." is a no mission floor!")
            no_mission_floors[i+1] = 1
        end
    end
    return no_mission_floors
end