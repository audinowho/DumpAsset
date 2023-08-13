require 'common'

BATTLE_SCRIPT = {}

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
  UI:WaitShowDialogue(RogueEssence.StringKey(args.Messages[1]):ToLocal())
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
  UI:WaitShowDialogue(RogueEssence.StringKey("TALK_ESCORT_SISTER_HALF"):ToLocal())
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

function BATTLE_SCRIPT.RescueReached(owner, ownerChar, context, args)

  local tbl = LTBL(context.Target)
  local mission = SV.missions.Missions[tbl.Mission]
  mission.Complete = COMMON.MISSION_COMPLETE
  
  local oldDir = context.Target.CharDir
  DUNGEON:CharTurnToChar(context.Target, context.User)
  
  UI:SetSpeaker(context.Target)
  UI:WaitShowDialogue("Yay, you found me!")
  
  -- warp out
  TASK:WaitTask(_DUNGEON:ProcessBattleFX(context.Target, context.Target, _DATA.SendHomeFX))
  _DUNGEON:RemoveChar(context.Target)
  
  UI:ResetSpeaker()
  UI:WaitShowDialogue("Mission status set to complete. Return to quest giver for reward.")
end


function BATTLE_SCRIPT.EscortRescueReached(owner, ownerChar, context, args)
  
  local tbl = LTBL(context.Target)
  local escort = COMMON.FindMissionEscort(tbl.Mission)
  
  if escort then
    
    local mission = SV.missions.Missions[tbl.Mission]
    mission.Complete = COMMON.MISSION_COMPLETE
  
    local oldDir = context.Target.CharDir
    DUNGEON:CharTurnToChar(context.Target, context.User)
  
    UI:SetSpeaker(context.Target)
    UI:WaitShowDialogue("Yay, you brought the escort to me!")
  
    -- warp out
    TASK:WaitTask(_DUNGEON:ProcessBattleFX(escort, escort, _DATA.SendHomeFX))
    _DUNGEON:RemoveChar(escort)
	
    TASK:WaitTask(_DUNGEON:ProcessBattleFX(context.Target, context.Target, _DATA.SendHomeFX))
    _DUNGEON:RemoveChar(context.Target)
  
    UI:ResetSpeaker()
    UI:WaitShowDialogue("Mission status set to complete. Return to quest giver for reward.")
  end
end

function BATTLE_SCRIPT.EscortOutReached(owner, ownerChar, context, args)
  
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
		
		for assembly_idx = 0,total-1,1 do
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



