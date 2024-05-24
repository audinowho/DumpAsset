require 'common'

BATTLE_SCRIPT = {}

RedirectionType = luanet.import_type('PMDC.Dungeon.Redirected')
DmgMultType = luanet.import_type('PMDC.Dungeon.DmgMult')

function BATTLE_SCRIPT.Test(owner, ownerChar, context, args)
  PrintInfo("Test")
end

function BATTLE_SCRIPT.AllyInteract(owner, ownerChar, context, args)
	COMMON.DungeonInteract(context.User, context.Target, context.CancelState, context.TurnCancel)
end

function BATTLE_SCRIPT.ShopkeeperInteract(owner, ownerChar, context, args)

  if COMMON.CanTalk(context.Target) then
	local security_state = COMMON.GetShopPriceState()
    local price = security_state.Cart
    local sell_price = COMMON.GetDungeonSellPrice()
  
    local oldDir = context.Target.CharDir
    DUNGEON:CharTurnToChar(context.Target, context.User)
	
    if sell_price > 0 then
      context.TurnCancel.Cancel = true
      UI:SetSpeaker(context.Target)
	  UI:ChoiceMenuYesNo(STRINGS:Format(RogueEssence.StringKey(string.format("TALK_SHOP_SELL_%04d", context.Target.Discriminator)):ToLocal(), STRINGS:FormatKey("MONEY_AMOUNT", sell_price)), false)
	  UI:WaitForChoice()
	  result = UI:ChoiceResult()
	  
	  if SV.adventure.Thief then
	    COMMON.ThiefReturn()
	  elseif result then
	    -- iterate player inventory prices and remove total price
        COMMON.PayDungeonSellPrice(sell_price)
	    SOUND:PlayBattleSE("DUN_Money")
	    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(string.format("TALK_SHOP_SELL_DONE_%04d", context.Target.Discriminator)):ToLocal()))
	  else
	    -- nothing
	  end
    end
	
    if price > 0 then
      context.TurnCancel.Cancel = true
      UI:SetSpeaker(context.Target)
	  UI:ChoiceMenuYesNo(STRINGS:Format(RogueEssence.StringKey(string.format("TALK_SHOP_PAY_%04d", context.Target.Discriminator)):ToLocal(), STRINGS:FormatKey("MONEY_AMOUNT", price)), false)
	  UI:WaitForChoice()
	  result = UI:ChoiceResult()
	  if SV.adventure.Thief then
	    COMMON.ThiefReturn()
	  elseif result then
	    if price > GAME:GetPlayerMoney() then
          UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(string.format("TALK_SHOP_PAY_SHORT_%04d", context.Target.Discriminator)):ToLocal()))
	    else
	      -- iterate player inventory prices and remove total price
          COMMON.PayDungeonCartPrice(price)
	      SOUND:PlayBattleSE("DUN_Money")
	      UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(string.format("TALK_SHOP_PAY_DONE_%04d", context.Target.Discriminator)):ToLocal()))
	    end
	  else
	    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(string.format("TALK_SHOP_PAY_REFUSE_%04d", context.Target.Discriminator)):ToLocal()))
	  end
    end
	
	if price == 0 and sell_price == 0 then
      context.CancelState.Cancel = true
      UI:SetSpeaker(context.Target)
      UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(string.format("TALK_SHOP_%04d", context.Target.Discriminator)):ToLocal()))
      context.Target.CharDir = oldDir
    end
  else

    UI:ResetSpeaker()
	
	local chosen_quote = RogueEssence.StringKey("TALK_CANT"):ToLocal()
    chosen_quote = string.gsub(chosen_quote, "%[myname%]", context.Target:GetDisplayName(true))
    UI:WaitShowDialogue(chosen_quote)
  end
end

function BATTLE_SCRIPT.EscortInteract(owner, ownerChar, context, args)
  context.CancelState.Cancel = true
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  UI:SetSpeaker(context.Target)
  
  --Basic for now, but choose a different line based on mission type/special 
  --Should be expanded on in the future to be more dynamic, and to have more special lines for special pairs
  local tbl = LTBL(context.Target)
  local mission_slot = tbl.Escort
  local job = SV.TakenBoard[mission_slot]
  
  if job.Type == COMMON.MISSION_TYPE_EXPLORATION then
	  local zone_string = _DATA:GetZone(job.Zone).Segments[job.Segment]:ToString()
	  zone_string = COMMON.CreateColoredSegmentString(zone_string)
	  local floor = SV.StairType[job.Zone] .. '[color=#00FFFF]' .. tostring(job.Floor) .. '[color]' .. "F"
	  UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MISSION_EXPLORATION_INTERACT"):ToLocal(), zone_string , floor))
  elseif job.Type == COMMON.MISSION_TYPE_ESCORT then
    if job.Special == MISSION_GEN.SPECIAL_CLIENT_LOVER then
	  UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MISSION_ESCORT_LOVER_INTERACT"):ToLocal()))
	else
	  UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MISSION_ESCORT_INTERACT"):ToLocal(), _DATA:GetMonster(job.Target):GetColoredName())) 
	end
   end
  context.Target.CharDir = oldDir
end

function BATTLE_SCRIPT.EscortInteractSister(owner, ownerChar, context, args)
  context.CancelState.Cancel = true
  local tbl = LTBL(context.Target)
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  UI:SetSpeaker(context.Target)
  
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  
  UI:SetSpeaker(context.Target)
  
  local ratio = context.Target.HP * 100 // context.Target.MaxHP
  
  if ratio <= 25 then
    UI:SetSpeakerEmotion("Pain")
    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_SISTER_PINCH"):ToLocal())
  elseif ratio <= 50 then
    UI:SetSpeakerEmotion("Worried")
    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_SISTER_HALF"):ToLocal())
  else 
    UI:SetSpeakerEmotion("Worried")
    if tbl.TalkAmount == nil then
	  UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_SISTER_FULL_001"):ToLocal())
	  tbl.TalkAmount = 1
    else
      if tbl.TalkAmount == 1 then
	    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_SISTER_FULL_002"):ToLocal())
	  elseif tbl.TalkAmount == 2 then
	    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_SISTER_FULL_003"):ToLocal())
	  else
	    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_SISTER_FULL_004"):ToLocal())
	  end
	  tbl.TalkAmount = tbl.TalkAmount + 1
    end
  end

  context.Target.CharDir = oldDir
end



function BATTLE_SCRIPT.EscortInteractMother(owner, ownerChar, context, args)
  context.CancelState.Cancel = true
  local tbl = LTBL(context.Target)
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  UI:SetSpeaker(context.Target)
  
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  
  UI:SetSpeaker(context.Target)
  
  local ratio = context.Target.HP * 100 // context.Target.MaxHP
  
  if ratio <= 25 then
    UI:SetSpeakerEmotion("Pain")
    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_MOTHER_PINCH"):ToLocal())
  elseif ratio <= 50 then
    UI:SetSpeakerEmotion("Worried")
    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_MOTHER_HALF"):ToLocal())
  else 
    UI:SetSpeakerEmotion("Worried")
    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_MOTHER_FULL_001"):ToLocal())
  end

  context.Target.CharDir = oldDir
end



function BATTLE_SCRIPT.EscortInteractFather(owner, ownerChar, context, args)
  context.CancelState.Cancel = true
  local tbl = LTBL(context.Target)
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  UI:SetSpeaker(context.Target)
  
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  
  UI:SetSpeaker(context.Target)
  
  local ratio = context.Target.HP * 100 // context.Target.MaxHP
  
  if ratio <= 25 then
    UI:SetSpeakerEmotion("Pain")
    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_FATHER_PINCH"):ToLocal())
  elseif ratio <= 50 then
    UI:SetSpeakerEmotion("Worried")
    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_FATHER_HALF"):ToLocal())
  else 
    UI:SetSpeakerEmotion("Worried")
    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_FATHER_FULL_001"):ToLocal())
  end

  context.Target.CharDir = oldDir
end


function BATTLE_SCRIPT.EscortInteractBrother(owner, ownerChar, context, args)
  context.CancelState.Cancel = true
  local tbl = LTBL(context.Target)
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  UI:SetSpeaker(context.Target)
  
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  
  UI:SetSpeaker(context.Target)
  
  local ratio = context.Target.HP * 100 // context.Target.MaxHP
  
  if ratio <= 25 then
    UI:SetSpeakerEmotion("Pain")
    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_BROTHER_PINCH"):ToLocal())
  elseif ratio <= 50 then
    UI:SetSpeakerEmotion("Worried")
    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_BROTHER_HALF"):ToLocal())
  else 
    UI:SetSpeakerEmotion("Worried")
    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_BROTHER_FULL_001"):ToLocal())
  end

  context.Target.CharDir = oldDir
end


function BATTLE_SCRIPT.EscortInteractGrandma(owner, ownerChar, context, args)
  context.CancelState.Cancel = true
  local tbl = LTBL(context.Target)
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  UI:SetSpeaker(context.Target)
  
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  
  UI:SetSpeaker(context.Target)
  
  local ratio = context.Target.HP * 100 // context.Target.MaxHP
  
  if ratio <= 25 then
    UI:SetSpeakerEmotion("Pain")
    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_GRANDMA_PINCH"):ToLocal())
  elseif ratio <= 50 then
    UI:SetSpeakerEmotion("Worried")
    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_GRANDMA_HALF"):ToLocal())
  else 
    UI:SetSpeakerEmotion("Worried")
    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_GRANDMA_FULL_001"):ToLocal())
  end

  context.Target.CharDir = oldDir
end


function BATTLE_SCRIPT.EscortInteractPet(owner, ownerChar, context, args)
  context.CancelState.Cancel = true
  local tbl = LTBL(context.Target)
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  UI:SetSpeaker(context.Target)
  
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  
  UI:SetSpeaker(context.Target)
  
  local ratio = context.Target.HP * 100 // context.Target.MaxHP
  
  if ratio <= 25 then
    UI:SetSpeakerEmotion("Pain")
    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_PET_PINCH"):ToLocal())
  elseif ratio <= 50 then
    UI:SetSpeakerEmotion("Worried")
    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_PET_HALF"):ToLocal())
  else 
    UI:SetSpeakerEmotion("Worried")
    UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_PET_FULL_001"):ToLocal())
  end

  context.Target.CharDir = oldDir
end


function BATTLE_SCRIPT.RescueReached(owner, ownerChar, context, args)
    -- Set the nickname of the target, removing the gender sign
    local base_name = RogueEssence.Data.DataManager.Instance.DataIndices[RogueEssence.Data.DataManager.DataType.Monster]:Get(context.Target.BaseForm.Species).Name:ToLocal()
    GAME:SetCharacterNickname(context.Target, base_name)

    context.CancelState.Cancel = false
    context.TurnCancel.Cancel = true

    local targetName = _DATA:GetMonster(context.Target.BaseForm.Species):GetColoredName()

    local oldDir = context.Target.CharDir

    local tbl = LTBL(context.Target)
    local mission = SV.TakenBoard[tbl.Mission]
    DUNGEON:CharTurnToChar(context.Target, context.User)
    UI:ResetSpeaker()

    if mission.Type == COMMON.MISSION_TYPE_RESCUE then
        RescueCheck(context, targetName, mission)
    elseif mission.Type == COMMON.MISSION_TYPE_DELIVERY then
        DeliveryCheck(context, targetName, mission)
    end
end

function RescueCheck(context, targetName, mission)
    UI:ChoiceMenuYesNo("Yes! You've found " .. targetName .. "!\nDo you want to use your badge to rescue " .. targetName .. "?", false)
    UI:WaitForChoice()
    local use_badge = UI:ChoiceResult()
    if use_badge then
        --Mark mission completion flags
        SV.TemporaryFlags.MissionCompleted = true
        --Clear but remember minimap state
        SV.TemporaryFlags.PriorMapSetting = _DUNGEON.ShowMap
        _DUNGEON.ShowMap = _DUNGEON.MinimapState.None
        GAME:WaitFrames(20)
        mission.Completion = 1
        UI:WaitShowDialogue("Your badge shines on " .. targetName .. ", and ".. targetName .. " is transported away magically!" )
        GAME:WaitFrames(20)
        UI:SetSpeaker(context.Target)

        --different responses for special targets
        if mission.Special == MISSION_GEN.SPECIAL_CLIENT_CHILD then
            UI:SetSpeakerEmotion("Joyous")
            UI:WaitShowDialogue("Thank you for rescuing me! This place was so scary! I can't wait to see my family again!")
        elseif mission.Special == MISSION_GEN.SPECIAL_CLIENT_FRIEND then
            UI:WaitShowDialogue("Oh, my friend sent you to rescue me? Thank goodness! We'll see you at the guild later to say thanks!")
        elseif mission.Special == MISSION_GEN.SPECIAL_CLIENT_RIVAL then
            UI:WaitShowDialogue("Tch, my rival sent you to rescue me, huh? Well, thank you. We'll reward you later at the guild.")
        elseif mission.Special == MISSION_GEN.SPECIAL_CLIENT_LOVER then
            UI:SetSpeakerEmotion("Joyous")
            UI:WaitShowDialogue("Oh, my beloved " .. _DATA:GetMonster(mission.Client):GetColoredName() .. " sent you to rescue me? I can't wait to reunite with them!")
        else
            UI:WaitShowDialogue("Thanks for the rescue!\nI'll see you at the guild after with your reward!")
        end
        GAME:WaitFrames(20)
        UI:ResetSpeaker()
        UI:WaitShowDialogue(targetName .. " escaped from the dungeon!")
        GAME:WaitFrames(20)
        -- warp out
        TASK:WaitTask(_DUNGEON:ProcessBattleFX(context.Target, context.Target, _DATA.SendHomeFX))
        _DUNGEON:RemoveChar(context.Target)
        GAME:WaitFrames(50)
        COMMON.AskMissionWarpOut()
    else
        --quickly hide the minimap for the 20 frame pause
        local map_setting = _DUNGEON.ShowMap
        _DUNGEON.ShowMap = _DUNGEON.MinimapState.None
        GAME:WaitFrames(20)
        UI:SetSpeaker(context.Target)
        if mission.Special == MISSION_GEN.SPECIAL_CLIENT_CHILD then
            UI:SetSpeakerEmotion("Crying")
            UI:WaitShowDialogue("Waaah! It's s-scary here! P-please help me!")
        elseif mission.Special == MISSION_GEN.SPECIAL_CLIENT_FRIEND then
            UI:SetSpeakerEmotion("Surprised")
            UI:WaitShowDialogue("Please don't leave me here! My friend is probably worried sick!")
        elseif mission.Special == MISSION_GEN.SPECIAL_CLIENT_RIVAL then
            UI:SetSpeakerEmotion("Worried")
            UI:WaitShowDialogue("Woah, don't just leave me hanging here!")
        elseif mission.Special == MISSION_GEN.SPECIAL_CLIENT_LOVER then
            UI:SetSpeakerEmotion("Worried")
            UI:WaitShowDialogue("Please, get me out of here! I just want to see my dear " .. _DATA:GetMonster(mission.Client):GetColoredName() .. " again!")
        else
            UI:SetSpeakerEmotion("Surprised")
            UI:WaitShowDialogue("H-hey! Don't just leave me here!")
        end
        --change map setting back to what it was
        _DUNGEON.ShowMap = map_setting
        GAME:WaitFrames(20)
    end
end

function DeliveryCheck(context, targetName, mission)
    local inv_slot = GAME:FindPlayerItem(mission.Item, false, true)
    local team_slot = GAME:FindPlayerItem(mission.Item, true, false)
    local has_item = inv_slot:IsValid() or team_slot:IsValid()
    local item_name =  RogueEssence.Dungeon.InvItem(mission.Item):GetDisplayName()

    if has_item then
        UI:ChoiceMenuYesNo("Yes! You've located " .. targetName .. "!" .. " Do you want to deliver the requested " .. item_name .. " to " .. targetName .. "?")
        UI:WaitForChoice()
        local deliver_item = UI:ChoiceResult()
        if deliver_item then
            SV.TemporaryFlags.MissionCompleted = true
            mission.Completion = 1
            --Clear but remember minimap state
            SV.TemporaryFlags.PriorMapSetting = _DUNGEON.ShowMap
            _DUNGEON.ShowMap = _DUNGEON.MinimapState.None
            -- Take from inventory first before held items 
            if inv_slot:IsValid() then
                GAME:TakePlayerBagItem(inv_slot.Slot)
            else
                GAME:TakePlayerEquippedItem(team_slot.Slot)
            end
            GAME:WaitFrames(20)
            UI:SetSpeaker(context.Target)
            UI:WaitShowDialogue("Thanks for the " .. item_name .. "!\n I'll see you at the guild after with your reward!")
            GAME:WaitFrames(20)
            UI:ResetSpeaker()
            UI:WaitShowDialogue(targetName .. " escaped from the dungeon!")
            GAME:WaitFrames(20)
            TASK:WaitTask(_DUNGEON:ProcessBattleFX(context.Target, context.Target, _DATA.SendHomeFX))
            _DUNGEON:RemoveChar(context.Target)
            GAME:WaitFrames(50)
            COMMON.AskMissionWarpOut()
        else --they are sad if you dont give them the item
            --quickly hide the minimap for the 20 frame pause
            local map_setting = _DUNGEON.ShowMap
            _DUNGEON.ShowMap = _DUNGEON.MinimapState.None
            GAME:WaitFrames(20)
            UI:SetSpeaker(context.Target)
            UI:SetSpeakerEmotion("Sad")
            UI:WaitShowDialogue("Oh, please! I really need that " .. item_name .. "...")
            --change map setting back to what it was
            _DUNGEON.ShowMap = map_setting
            GAME:WaitFrames(20)		end
    else
        UI:WaitShowDialogue("The requested " .. item_name .. " isn't in the Treasure Bag.\nThere is nothing to deliver.")
        --quickly hide the minimap for the 20 frame pause
        local map_setting = _DUNGEON.ShowMap
        _DUNGEON.ShowMap = _DUNGEON.MinimapState.None
        GAME:WaitFrames(20)
        UI:SetSpeaker(context.Target)
        UI:SetSpeakerEmotion("Sad")
        UI:WaitShowDialogue("Huh, you don't have the " .. item_name .. "? That's too bad...")
        --change map setting back to what it was
        _DUNGEON.ShowMap = map_setting
        GAME:WaitFrames(20)
    end
end


function BATTLE_SCRIPT.EscortReached(owner, ownerChar, context, args)
    context.CancelState.Cancel = false
    context.TurnCancel.Cancel = true
    --Mark this as the last dungeon entered.
    local tbl = LTBL(context.Target)
    if tbl ~= nil and tbl.Mission ~= nil then
        local mission = SV.TakenBoard[tbl.Mission]
        local escort = COMMON.FindMissionEscort(tbl.Mission)
        local escortName = _DATA:GetMonster(mission.Client):GetColoredName()
        if escort then
            local oldDir = context.Target.CharDir
            DUNGEON:CharTurnToChar(context.Target, context.User)
            UI:ResetSpeaker()
            if math.abs(escort.CharLoc.X - context.Target.CharLoc.X) <= 4 and math.abs(escort.CharLoc.Y - context.Target.CharLoc.Y) <= 4 then
                --Mark mission completion flags
                SV.TemporaryFlags.MissionCompleted = true
                mission.Completion = 1
                UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MISSION_ESCORT_REACHED"):ToLocal(), escortName))
                --Clear but remember minimap state
                SV.TemporaryFlags.PriorMapSetting = _DUNGEON.ShowMap
                _DUNGEON.ShowMap = _DUNGEON.MinimapState.None
                GAME:WaitFrames(20)

                UI:SetSpeaker(escort)
                UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MISSION_ESCORT_THANKS"):ToLocal(), _DATA:GetMonster(context.Target.CurrentForm.Species):GetColoredName()))
                GAME:WaitFrames(20)
                UI:ResetSpeaker()
                UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MISSION_ESCORT_DEPART"):ToLocal(), escortName))
                GAME:WaitFrames(20)

                --Set max team size to 4 as the guest is no longer "taking" up a party slot
                RogueEssence.Dungeon.ExplorerTeam.MAX_TEAM_SLOTS = 4

                -- warp out
                TASK:WaitTask(_DUNGEON:ProcessBattleFX(escort, escort, _DATA.SendHomeFX))
                _DUNGEON:RemoveChar(escort)
                _ZONE.CurrentMap.DisplacedChars:Remove(escort)
                GAME:WaitFrames(70)
                TASK:WaitTask(_DUNGEON:ProcessBattleFX(context.Target, context.Target, _DATA.SendHomeFX))
                _DUNGEON:RemoveChar(context.Target)

                GAME:WaitFrames(50)
                COMMON.AskMissionWarpOut()
            else
                UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MISSION_ESCORT_UNAVAILABLE"):ToLocal(), escortName))
            end
        end
    end
end

function BATTLE_SCRIPT.SidequestRescueReached(owner, ownerChar, context, args)

    local tbl = LTBL(context.Target)
    local mission = SV.missions.Missions[tbl.Mission]

  local oldDir = context.Target.CharDir
    DUNGEON:CharTurnToChar(context.Target, context.User)

    UI:ResetSpeaker()
    local target_name = _DATA:GetMonster(mission.TargetSpecies.Species).Name
    UI:ChoiceMenuYesNo(STRINGS:Format(RogueEssence.StringKey("DLG_MISSION_RESCUE_ASK"):ToLocal(), target_name:ToLocal()), false)
    UI:WaitForChoice()
    result = UI:ChoiceResult()
    if result then

        mission.Complete = COMMON.MISSION_COMPLETE

        local poseAction = RogueEssence.Dungeon.CharAnimPose(context.User.CharLoc, context.User.CharDir, 50, 0)
        DUNGEON:CharSetAction(context.User, poseAction)
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("DLG_MISSION_RESCUE_DONE"):ToLocal(), target_name:ToLocal()))

        UI:SetSpeaker(context.Target)
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("DLG_MISSION_RESCUE_THANKS"):ToLocal()))

        -- warp out
        TASK:WaitTask(_DUNGEON:ProcessBattleFX(context.Target, context.Target, _DATA.SendHomeFX))
        _DUNGEON:RemoveChar(context.Target)

        DUNGEON:CharEndAnim(context.User)

	context.TurnCancel.Cancel = true
  else
	context.Target.CharDir = oldDir
	context.CancelState.Cancel = true
    end
end

function BATTLE_SCRIPT.SidequestEscortReached(owner, ownerChar, context, args)

    local tbl = LTBL(context.Target)
    local escort = COMMON.FindMissionEscort(tbl.Mission)

    PrintInfo("Completing escort out mission")
    if escort then

        local mission = SV.missions.Missions[tbl.Mission]
        mission.Complete = COMMON.MISSION_COMPLETE

        local oldDir = context.Target.CharDir
        DUNGEON:CharTurnToChar(context.Target, context.User)

        --UI:SetSpeaker(context.Target)
        UI:ResetSpeaker()
        local client_name = _DATA:GetMonster(mission.ClientSpecies.Species).Name
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("DLG_MISSION_ESCORT_DONE"):ToLocal(), client_name:ToLocal()))

        -- warp out
        TASK:WaitTask(_DUNGEON:ProcessBattleFX(escort, escort, _DATA.SendHomeFX))
        _DUNGEON:RemoveChar(escort)

        TASK:WaitTask(_DUNGEON:ProcessBattleFX(context.Target, context.Target, _DATA.SendHomeFX))
        _DUNGEON:RemoveChar(context.Target)

        UI:ResetSpeaker()
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("DLG_MISSION_REMINDER"):ToLocal(), client_name:ToLocal()))
	
	context.TurnCancel.Cancel = true
  else
	context.CancelState.Cancel = true
    end
end

function BATTLE_SCRIPT.SidequestEscortOutReached(owner, ownerChar, context, args)

    local tbl = LTBL(context.Target)

    local mission = SV.missions.Missions[tbl.Mission]

    local oldDir = context.Target.CharDir
    DUNGEON:CharTurnToChar(context.Target, context.User)

    UI:SetSpeaker(context.Target)
    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(args.EscortStartMsg):ToLocal()))

    -- ask to join
    UI:ResetSpeaker()
    UI:ChoiceMenuYesNo(STRINGS:Format(RogueEssence.StringKey("TALK_ESCORT_ASK"):ToLocal()), false)
    UI:WaitForChoice()
    result = UI:ChoiceResult()
    if result then
        -- join the team

        _DUNGEON:RemoveChar(context.Target)
        local tactic = _DATA:GetAITactic(_DATA.DefaultAI)
        context.Target.Tactic =  RogueEssence.Data.AITactic(tactic)
        _DATA.Save.ActiveTeam.Guests:Add(context.Target)
        context.Target:RefreshTraits()
        context.Target.Tactic:Initialize(context.Target)

        context.Target:FullRestore()

        context.Target.ActionEvents:Clear()
        local talk_evt = RogueEssence.Dungeon.BattleScriptEvent(args.EscortInteract)
        context.Target.ActionEvents:Add(talk_evt)

        SOUND:PlayFanfare("Fanfare/Note")
        UI:ResetSpeaker()
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MSG_RECRUIT_GUEST"):ToLocal(), context.Target:GetDisplayName(true)))
        UI:SetSpeaker(context.Target)
        UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(args.EscortAcceptMsg):ToLocal()))

        context.TurnCancel.Cancel = true
    else
        context.Target.CharDir = oldDir
        context.CancelState.Cancel = true
    end

end

function BATTLE_SCRIPT.CountTalkTest(owner, ownerChar, context, args)
  context.CancelState.Cancel = true
  
  local tbl = LTBL(context.Target)
  
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  
  UI:SetSpeaker(context.Target)
  
  if tbl.TalkAmount == nil then
    UI:WaitShowDialogue("I will remember how many times I've been talked to.")
	tbl.TalkAmount = 1
  else
	tbl.TalkAmount = tbl.TalkAmount + 1
  end
  UI:WaitShowDialogue("You've talked to me "..tostring(tbl.TalkAmount).." times.")
  
  context.Target.CharDir = oldDir
end


function BATTLE_SCRIPT.PairTalk(owner, ownerChar, context, args)
  context.CancelState.Cancel = true
  
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  
  UI:SetSpeaker(context.Target)
  
  if args.Pair == 0 then
    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_ADVICE_TEAM_MODE"):ToLocal(), _DIAG:GetControlString(RogueEssence.FrameInput.InputType.TeamMode)))
  else
    if _DIAG.GamePadActive then
	  UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_ADVICE_SWITCH_GAMEPAD"):ToLocal(), _DIAG:GetControlString(RogueEssence.FrameInput.InputType.LeaderSwapBack), _DIAG:GetControlString(RogueEssence.FrameInput.InputType.LeaderSwapForth)))
	else
	  UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_ADVICE_SWITCH_KEYBOARD"):ToLocal(), _DIAG:GetControlString(RogueEssence.FrameInput.InputType.LeaderSwap1), _DIAG:GetControlString(RogueEssence.FrameInput.InputType.LeaderSwap2), _DIAG:GetControlString(RogueEssence.FrameInput.InputType.LeaderSwap3), _DIAG:GetControlString(RogueEssence.FrameInput.InputType.LeaderSwap4)))
	end
  end
  
  
  context.Target.CharDir = oldDir
end


StackType = luanet.import_type('RogueEssence.Dungeon.StackState')

function BATTLE_SCRIPT.AccuracyTalk(owner, ownerChar, context, args)
  context.CancelState.Cancel = true
  
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  
  UI:SetSpeaker(context.Target)
  
  local sanded = false
  local acc_mod = context.Target:GetStatusEffect("mod_accuracy")
  if acc_mod ~= nil then
    local stack = acc_mod.StatusStates:Get(luanet.ctype(StackType))
	if stack.Stack < 0 then
	  sanded = true
	end
  end
  
  if sanded then
    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_ADVICE_STAT_DROP"):ToLocal()))
  else
    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_ADVICE_STAT_DROP_CLEAR"):ToLocal()))
  end
  
  context.Target.CharDir = oldDir
end


function BATTLE_SCRIPT.Tutor_Sequence(chara)

	GAME:WaitFrames(10)
	DUNGEON:CharStartAnim(chara, "Strike", false)
	GAME:WaitFrames(15)
	local emitter = RogueEssence.Content.FlashEmitter()
	emitter.FadeInTime = 2
	emitter.HoldTime = 4
	emitter.FadeOutTime = 2
	emitter.StartColor = Color(0, 0, 0, 0)
	emitter.Layer = DrawLayer.Top
	emitter.Anim = RogueEssence.Content.BGAnimData("White", 0)
	DUNGEON:PlayVFX(emitter, chara.MapLoc.X, chara.MapLoc.Y)
	SOUND:PlayBattleSE("EVT_Battle_Flash")
	GAME:WaitFrames(30)
end

function BATTLE_SCRIPT.TutorTalk(owner, ownerChar, context, args)

    local oldDir = context.Target.CharDir
    DUNGEON:CharTurnToChar(context.Target, context.User)
  
    UI:SetSpeaker(context.Target)
	
	local tbl = LTBL(context.Target)
	
	if tbl.TaughtMove ~= nil then
	  UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_TUTOR_DONE"):ToLocal()))
	  
	  context.Target.CharDir = oldDir
	  context.CancelState.Cancel = true
	  return
	end
	
	local move_idx = context.Target.BaseSkills[0].SkillNum
	local skill_data = _DATA:GetSkill(move_idx)
	
	local already_learned = context.User:HasBaseSkill(move_idx)
	if already_learned then
	  UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_TUTOR_ALREADY"):ToLocal(), skill_data:GetIconName()))

	  SV.base_town.TutorMoves[move_idx] = true
		context.TurnCancel.Cancel = true
	  return
	end
	
	
	  local team_id = context.User.BaseForm
	  local mon = _DATA:GetMonster(team_id.Species)
	  local form = mon.Forms[team_id.Form]
	
	local can_learn = false
	local skill = COMMON.TUTOR[move_idx]
	  if not skill.Special then
		--iterate the shared skills
		for learnable in luanet.each(form.SharedSkills) do
		  if learnable.Skill == move_idx then
			can_learn = true
			break
		  end
		end
	  else
		--iterate the secret skills
		for learnable in luanet.each(form.SecretSkills) do
		  if learnable.Skill == move_idx then
			can_learn = true
			break
		  end
		end
	  end
	
	if can_learn then
		UI:ChoiceMenuYesNo(STRINGS:Format(RogueEssence.StringKey("TALK_TUTOR_ASK"):ToLocal(), skill_data:GetIconName()), false)
		UI:WaitForChoice()
		result = UI:ChoiceResult()
		
		if result then
			local replace_msg = STRINGS:Format(RogueEssence.StringKey("TALK_TUTOR_REPLACE"):ToLocal(), skill_data:GetIconName())
			result = COMMON.LearnMoveFlow(context.User, move_idx, replace_msg)
		end

		if result then
			-- attempt to learn move
			UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_TUTOR_ACCEPT"):ToLocal(), skill_data:GetIconName()))

			--attack in a 90-degree turn from the talk
			context.Target.CharDir = Direction.Down
			context.User.CharDir = Direction.Down

			BATTLE_SCRIPT.Tutor_Sequence(context.Target)

			--player does the same animation offset by a little time
			BATTLE_SCRIPT.Tutor_Sequence(context.User)

			SOUND:PlayFanfare("Fanfare/LearnSkill")
			local orig_settings = UI:ExportSpeakerSettings()
			UI:ResetSpeaker(false)
			UI:WaitShowDialogue(STRINGS:FormatKey("DLG_SKILL_LEARN", context.User:GetDisplayName(true), skill_data:GetIconName()))
			UI:ImportSpeakerSettings(orig_settings)

			DUNGEON:CharTurnToChar(context.Target, context.User)
			DUNGEON:CharTurnToChar(context.User, context.Target)

			tbl.TaughtMove = true
			UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_TUTOR_VISIT"):ToLocal()))
		else
			UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_TUTOR_DECLINE"):ToLocal(), skill_data:GetIconName()))
		end

		SV.base_town.TutorMoves[move_idx] = true

		context.TurnCancel.Cancel = true
	else
		UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_TUTOR"):ToLocal(), skill_data:GetIconName()))

	  context.Target.CharDir = oldDir
	  context.CancelState.Cancel = true
	end
end


function BATTLE_SCRIPT.DisguiseTalk(owner, ownerChar, context, args)
  context.TurnCancel.Cancel = true
  
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  
  local appearance = context.Target.Appearance
  local name = _DATA:GetMonster(appearance.Species).Name:ToLocal()
  UI:SetSpeaker("[color=#00FF00]"..name.."[color]", true, appearance.Species, appearance.Form, appearance.Skin, appearance.Gender)
  
  local tbl = LTBL(context.Target)

  if tbl.TalkAmount == nil then
    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_OUTLAW_DISGUISE_001"):ToLocal()))
    tbl.TalkAmount = 1
  else
    if tbl.TalkAmount == 1 then
      UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_OUTLAW_DISGUISE_002"):ToLocal()))
    elseif tbl.TalkAmount == 2 then
      UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_OUTLAW_DISGUISE_003"):ToLocal()))
    else
      SOUND:PlayBGM("", false)
      UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_OUTLAW_DISGUISE_004"):ToLocal()))
      UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_OUTLAW_DISGUISE_005"):ToLocal()))
      
        local teamIndex = _ZONE.CurrentMap.AllyTeams:IndexOf(context.Target.MemberTeam)
      _DUNGEON:RemoveTeam(RogueEssence.Dungeon.Faction.Friend, teamIndex)
      _DUNGEON:AddTeam(RogueEssence.Dungeon.Faction.Foe, context.Target.MemberTeam)
      local tactic = _DATA:GetAITactic("boss") -- shopkeeper attack tactic
      context.Target.Tactic = RogueEssence.Data.AITactic(tactic)
      context.Target.Tactic:Initialize(context.Target)
      TASK:WaitTask(context.Target:RemoveStatusEffect("attack_response", false))
    
      TASK:WaitTask(context.Target:RemoveStatusEffect("illusion", true))
      
      COMMON.TriggerAdHocMonsterHouse(owner, ownerChar, context.Target)
    end
	tbl.TalkAmount = tbl.TalkAmount + 1
  end
end


function BATTLE_SCRIPT.DisguiseHit(owner, ownerChar, context, args)
  
  DUNGEON:CharTurnToChar(context.Target, context.User)
  
  local appearance = context.Target.Appearance
  local name = _DATA:GetMonster(appearance.Species).Name:ToLocal()
  UI:SetSpeaker("[color=#00FF00]"..name.."[color]", true, appearance.Species, appearance.Form, appearance.Skin, appearance.Gender)


  SOUND:PlayBGM("", false)
  UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_OUTLAW_DISGUISE_ATTACKED"):ToLocal()))
	
  UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("TALK_OUTLAW_DISGUISE_005"):ToLocal()))
	  
      local teamIndex = _ZONE.CurrentMap.AllyTeams:IndexOf(context.Target.MemberTeam)
	  _DUNGEON:RemoveTeam(RogueEssence.Dungeon.Faction.Friend, teamIndex)
	  _DUNGEON:AddTeam(RogueEssence.Dungeon.Faction.Foe, context.Target.MemberTeam)
	  local tactic = _DATA:GetAITactic("boss") -- shopkeeper attack tactic
	  context.Target.Tactic = RogueEssence.Data.AITactic(tactic)
	  context.Target.Tactic:Initialize(context.Target)
	
	
	  TASK:WaitTask(context.Target:RemoveStatusEffect("attack_response", false))
  TASK:WaitTask(context.Target:RemoveStatusEffect("illusion", true))
	  
  COMMON.TriggerAdHocMonsterHouse(owner, ownerChar, context.Target)
end


function BATTLE_SCRIPT.LegendRecruitCheck(owner, ownerChar, context, args)

  --TODO: check to see if heatran is in the party/assembly
  --if so set gotHeatran to true
  if not SV.sleeping_caldera.GotHeatran then
    --check for item throw, the only way to recruit
	if context.ActionType == RogueEssence.Dungeon.BattleActionType.Throw then
	  local found_legend = nil
	  local player_count = _DUNGEON.ActiveTeam.Players.Count
	  for player_idx = 0, player_count-1, 1 do
	    player = _DUNGEON.ActiveTeam.Players[player_idx]
	    --if so, iterate the team and the assembly for heatran
	    --check for a lua table that marks it as THE guardian
		local player_tbl = LTBL(player)
	    if player.BaseForm.Species == "heatran" and player_tbl.IsLegend == true then
		  found_legend = player
		  break
		end
	  end
	  
	  if found_legend == nil then
	    local assemblyCount = GAME:GetPlayerAssemblyCount()
		
		for assembly_idx = 0,assemblyCount-1,1 do
		  player = GAME:GetPlayerAssemblyMember(assembly_idx)
		  local player_tbl = LTBL(player)
		  if player.BaseForm.Species == "heatran" and player_tbl.IsLegend == true then
			found_legend = player
			break
		  end
		end
	  end
	  
	  if found_legend ~= nil then
	    --if so, set obtained to true
	    SV.sleeping_caldera.GotHeatran = true
	    --remove the lua table
		local player_tbl = LTBL(found_legend)
		player_tbl.FoundLegend = nil
	  end
	end
  end
end



