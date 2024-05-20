require 'origin.common'


function BATTLE_SCRIPT.GenderCapsuleEvent(owner, ownerChar, context, args)
	local gender_choices = {RogueEssence.Text.ToLocal(Gender.Male), RogueEssence.Text.ToLocal(Gender.Female), RogueEssence.Text.ToLocal(Gender.Genderless), STRINGS:FormatKey("MENU_EXIT")}
	UI:BeginChoiceMenu(RogueEssence.StringKey("DLG_CHOOSE_GENDER"):ToLocal(), gender_choices, 1, 4)
	UI:WaitForChoice()
	result = UI:ChoiceResult()
	if result == 1 then
		--TODO: create a custom context state
		local learn = PMDC.Dungeon.AbilityLearnContext()
		learn.ReplaceSlot = 1
		context.ContextStates:Set(learn)
	elseif result == 2 then
		local learn = PMDC.Dungeon.AbilityLearnContext()
		learn.ReplaceSlot = 2
		context.ContextStates:Set(learn)
	elseif result == 3 then
		local learn = PMDC.Dungeon.AbilityLearnContext()
		learn.ReplaceSlot = 0
		context.ContextStates:Set(learn)
	elseif result == 4 then
		context.CancelState.Cancel = true
	end
end

AbilityLearnContextType = luanet.import_type('PMDC.Dungeon.AbilityLearnContext')

function BATTLE_SCRIPT.GenderLearnEvent(owner, ownerChar, context, args)
	local gender = Gender.Unknown
	local learn = context.ContextStates:GetWithDefault(luanet.ctype(AbilityLearnContextType))
	if learn ~= nil then
		gender = LUA_ENGINE:LuaCast(learn.ReplaceSlot, Gender)
	end
	
	if gender ~= Gender.Unknown then
		_GAME:SE("Fanfare/LearnSkill");
		context.User.BaseForm = RogueEssence.Dungeon.MonsterID(context.User.BaseForm.Species, context.User.BaseForm.Form, context.User.BaseForm.Skin, gender)
		context.User:RestoreForm()
		_DUNGEON:LogMsg(STRINGS:Format(RogueEssence.StringKey("DLG_LEARN_GENDER"):ToLocal(), context.User:GetDisplayName(false), RogueEssence.Text.ToLocal(gender)))
	end
end
