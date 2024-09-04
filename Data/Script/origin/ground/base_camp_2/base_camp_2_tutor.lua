require 'origin.common'
require 'origin.menu.skill.SkillSelectMenu'
require 'origin.menu.skill.SkillTutorMenu'
require 'origin.menu.team.AssemblySelectMenu'

local base_camp_2_tutor = {}



function base_camp_2_tutor.Tutor_Sequence()

	local chara = CH('Tutor_Owner')
	GAME:WaitFrames(10)
	GROUND:CharSetAnim(chara, "Strike", false)
	GAME:WaitFrames(15)
	local emitter = RogueEssence.Content.FlashEmitter()
	emitter.FadeInTime = 2
	emitter.HoldTime = 4
	emitter.FadeOutTime = 2
	emitter.StartColor = Color(0, 0, 0, 0)
	emitter.Layer = DrawLayer.Top
	emitter.Anim = RogueEssence.Content.BGAnimData("White", 0)
	GROUND:PlayVFX(emitter, chara.MapLoc.X, chara.MapLoc.Y)
	SOUND:PlayBattleSE("EVT_Battle_Flash")
	GAME:WaitFrames(10)
	GROUND:CharSetAnim(chara, "Idle", true)
	GAME:WaitFrames(30)
end


function base_camp_2_tutor.Tutor_Can_Remember(member)
  return GAME:CanRelearn(member)
end

function base_camp_2_tutor.Tutor_Can_Forget(member)
  return GAME:CanForget(member)
end

function base_camp_2_tutor.Tutor_Can_Tutor(member, tutor_moves)
  
  local valid_moves = COMMON.GetTutorableMoves(member, tutor_moves)
	for move_idx, skill in pairs(valid_moves) do
		return true
	end
  
  return false
end


function base_camp_2_tutor.Tutor_Remember_Flow(price)
    
	local state = 0
  local member = nil
  local move = ""
	
	if price > GAME:GetPlayerMoney() then
		UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_No_Money']))
		return
	end
    
	while state > -1 do
		if state == 0 then
			UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Remember_Who']))
			local chosen_member = AssemblySelectMenu.run(base_camp_2_tutor.Tutor_Can_Remember, false)
			
			if chosen_member ~= nil then
				state = 1
				member = chosen_member
			else
				state = -1
			end
		elseif state == 1 then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Remember_What'], member:GetDisplayName(true)))
      local result = SkillSelectMenu.runRelearnMenu(member)
      if result ~= "" then
        move = result
        state = 2
      else
        state = 0
      end
		elseif state == 2 then
        local moveEntry = _DATA:GetSkill(move)
		    local learnedMove = COMMON.LearnMoveFlow(member, move, STRINGS:Format(STRINGS.MapStrings['Tutor_Remember_Replace']))
			
			if learnedMove then
				if price > 0 then
				  SOUND:PlayBattleSE("DUN_Money")
				  GAME:RemoveFromPlayerMoney(price)
				end
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Remember_Begin']))
				base_camp_2_tutor.Tutor_Sequence()
				SOUND:PlayFanfare("Fanfare/LearnSkill")
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Remember_Success'], member:GetDisplayName(true), moveEntry:GetIconName()))
				state = -1
			else
				state = 1
			end
		end
	end
end


function base_camp_2_tutor.Tutor_Forget_Flow()
  local state = 0
  local member = nil
  local move = ""
  
  while state > -1 do
  
    if state == 0 then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Forget_Who']))
      local chosen_member = AssemblySelectMenu.run(base_camp_2_tutor.Tutor_Can_Forget, false)
	  
	  if chosen_member ~= nil then
		  state = 1
		  member = chosen_member
		  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Forget_What'], member:GetDisplayName(true)))
	  else
		  state = -1
	  end
	  
    elseif state == 1 then
      UI:ForgetMenu(member)
      UI:WaitForChoice()
      local result = UI:ChoiceResult()
      if result > -1 then
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Forget_Begin']))
        move = GAME:GetCharacterSkill(member, result)
        local moveEntry = _DATA:GetSkill(move)
        GAME:ForgetSkill(member, result)
        base_camp_2_tutor.Tutor_Sequence()
        SOUND:PlayFanfare("Fanfare/LearnSkill")
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Forget_Success'], member:GetDisplayName(true), moveEntry:GetIconName()))
        state = -1
      else
        state = 0
      end
    end
  
  end
  
end


function base_camp_2_tutor.Tutor_Teach_Flow(tutor_moves)
    
	local state = 0
    local member = nil
    local move = ""
	
	while state > -1 do
		if state == 0 then
			UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Teach_Who']))
			local chosen_member = AssemblySelectMenu.run(function(chara) return base_camp_2_tutor.Tutor_Can_Tutor(chara, tutor_moves) end, false)
			
			if chosen_member ~= nil then
				state = 1
				member = chosen_member
			else
				state = -1
			end
	  
		elseif state == 1 then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Teach_What'], member:GetDisplayName(true)))
	  local valid_moves = COMMON.GetTutorableMoves(member, tutor_moves) --moved out here
	  local result = SkillTutorMenu.runTutorMenu(valid_moves, "loot_heart_scale", false, true)
      if result ~= "" then
        move = result
        state = 2
      else
        state = 0
      end
		elseif state == 2 then
      local moveEntry = _DATA:GetSkill(move)
			local learnedMove = COMMON.LearnMoveFlow(member, move, STRINGS:Format(STRINGS.MapStrings['Tutor_Remember_Replace']))
			
			if learnedMove then
				local price = COMMON.TUTOR[move].Cost
				SOUND:PlayBattleSE("DUN_Money")
				for ii = 1, price, 1 do
					local item_slot = GAME:FindPlayerItem("loot_heart_scale", true, true)
					if not item_slot:IsValid() then
						--it is a certainty that there is an item in storage, due to previous checks
						GAME:TakePlayerStorageItem("loot_heart_scale")
					elseif item_slot.IsEquipped then
						GAME:TakePlayerEquippedItem(item_slot.Slot)
					else
						GAME:TakePlayerBagItem(item_slot.Slot)
					end
				end
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Remember_Begin']))
				base_camp_2_tutor.Tutor_Sequence()
				SOUND:PlayFanfare("Fanfare/LearnSkill")
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Teach_Success'], member:GetDisplayName(true), moveEntry:GetIconName()))
				state = -1
			else
				state = 1
			end
		end
	end
end

function base_camp_2_tutor.Tutor_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local price = 250
  local tutor_moves = {}
  local can_tutor = false
  for move_key in pairs(SV.base_town.TutorMoves) do
    if COMMON.TUTOR[move_key] ~= nil then
      tutor_moves[move_key] = COMMON.TUTOR[move_key]
	  can_tutor = true
    end
  end
  
  
  local state = 0
  local repeated = false
  local chara = CH('Tutor_Owner')
  UI:SetSpeaker(chara)
  
  if SV.guildmaster_summit.GameComplete and SV.base_town.FreeRelearn == false then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Now_Free']))
    SV.base_town.FreeRelearn = true
  end
  
  if can_tutor and SV.base_town.TutorOpen == false then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Now_Teaches']))
	SV.base_town.TutorOpen = true
  end
  
  if SV.base_town.FreeRelearn then
    price = 0
  end
  
  
	while state > -1 do
		if state == 0 then
			local msg = STRINGS:Format(STRINGS.MapStrings['Tutor_Intro'], STRINGS:FormatKey("MONEY_AMOUNT", price))
			if price == 0 then
			  msg = STRINGS:Format(STRINGS.MapStrings['Tutor_Intro_Free'])
			end
			
			if repeated == true then
				msg = STRINGS:Format(STRINGS.MapStrings['Tutor_Intro_Return'])
			end
			
			local tutor_choices = {}
			tutor_choices[1] = RogueEssence.StringKey("MENU_RECALL_SKILL"):ToLocal()
			tutor_choices[2] = RogueEssence.StringKey("MENU_FORGET_SKILL"):ToLocal()
			
			if can_tutor then
				tutor_choices[3] = STRINGS:Format(STRINGS.MapStrings['Tutor_Option_Tutor'])
			end
			
			tutor_choices[4] = STRINGS:FormatKey("MENU_INFO")
			tutor_choices[5] = STRINGS:FormatKey("MENU_EXIT")
			
			UI:BeginChoiceMenu(msg, tutor_choices, 1, 5)
			
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			
			repeated = true
			if result == 1 then
			    base_camp_2_tutor.Tutor_Remember_Flow(price)
			elseif result == 2 then
				base_camp_2_tutor.Tutor_Forget_Flow()
			elseif result == 3 then
			    base_camp_2_tutor.Tutor_Teach_Flow(tutor_moves)
			elseif result == 4 then
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Info_001']))
				if SV.base_town.FreeRelearn then
				    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Info_003']))
				else
				    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Info_002']))
				end
				if SV.base_town.TutorOpen then
				    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Info_004']))
				end
			else
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Tutor_Goodbye']))
				state = -1
			end
		end
	end
end

return base_camp_2_tutor