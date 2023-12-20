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
  UI:WaitShowDialogue(RogueEssence.StringKey("TALK_FULL_0820"):ToLocal())
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



function BATTLE_SCRIPT.RescueReached(owner, ownerChar, context, args)

  context.CancelState.Cancel = true
  
  local tbl = LTBL(context.Target)
  local mission = SV.missions.Missions[tbl.Mission]
  
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
  end
end


function BATTLE_SCRIPT.EscortRescueReached(owner, ownerChar, context, args)
  
  context.CancelState.Cancel = true
  
  local tbl = LTBL(context.Target)
  local escort = COMMON.FindMissionEscort(tbl.Mission)
  
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



