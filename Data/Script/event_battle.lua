require 'common'

BATTLE_SCRIPT = {}

RedirectionType = luanet.import_type('PMDC.Dungeon.Redirected')
DmgMultType = luanet.import_type('PMDC.Dungeon.DmgMult')

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
		local floor = MISSION_GEN.STAIR_TYPE[job.Zone] .. '[color=#00FFFF]' .. tostring(job.Floor) .. '[color]' .. "F"
		UI:WaitShowDialogue("Please, take me to " .. floor .. "!")
  elseif job.Type == COMMON.MISSION_TYPE_ESCORT then
    if job.Special == MISSION_GEN.SPECIAL_CLIENT_LOVER then
	  UI:WaitShowDialogue("Please, bring me to my love! I'm counting on you!")
	else
	  UI:WaitShowDialogue("I'm counting on you to bring me to " .. _DATA:GetMonster(job.Target):GetColoredName() .. "!") 
	end
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

function BATTLE_SCRIPT.EscortRescueReached(owner, ownerChar, context, args)
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
				UI:WaitShowDialogue("Yes! You completed " .. escortName .. "'s escort mission.\n" .. escortName .. " is delighted!")
				--Clear but remember minimap state
				SV.TemporaryFlags.PriorMapSetting = _DUNGEON.ShowMap
				_DUNGEON.ShowMap = _DUNGEON.MinimapState.None
				GAME:WaitFrames(20)
				
				UI:SetSpeaker(escort)
				UI:WaitShowDialogue("Thank you for escorting me to " .. _DATA:GetMonster(context.Target.CurrentForm.Species):GetColoredName() .. "!")
				GAME:WaitFrames(20)
				UI:ResetSpeaker()
				UI:WaitShowDialogue(escortName .. "'s twosome left the dungeon!")
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
				UI:WaitShowDialogue(escortName .. " doesn't seem to be around...")
			end
		end
  end
end
