require 'origin.common'
require 'origin.menu.juice.JuiceShopMenu'
require 'origin.menu.juice.SpecialtiesMenu'
require 'origin.menu.team.AssemblySelectMenu'
require 'origin.menu.team.TeamSelectMenu'

local base_camp_2_juice = {}



function base_camp_2_juice.Juice_Owner_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  if SV.base_town.JuiceShop == 0 then
    UI:SetSpeaker(chara)
  
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Intro']))
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Setup']))
  elseif SV.base_town.JuiceShop == 1 then
  
  local questname = "QuestBug"
  local quest = SV.missions.Missions[questname]
  
  if quest == nil then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,CH('PLAYER'))
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Help_001']))
	
	COMMON.CreateMission(questname,
	{ Complete = COMMON.MISSION_INCOMPLETE, Type = COMMON.MISSION_TYPE_LOST_ITEM,
      DestZone = "bramble_woods", DestSegment = 0, DestFloor = 4,
      FloorUnknown = false,
	  TargetItem = RogueEssence.Dungeon.InvItem("lost_item_bug"),
      ClientSpecies = RogueEssence.Dungeon.MonsterID("shuckle", 0, "normal", Gender.Male) }
	  )
	
  else
  
	COMMON.TakeMissionItem(quest)
	
    if quest.Complete == COMMON.MISSION_INCOMPLETE then
      UI:SetSpeaker(chara)
      GROUND:CharTurnToChar(chara,CH('PLAYER'))
	  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Help_002']))
    else
      base_camp_2_juice.Bug_Complete()
    end
  end
  
  elseif SV.base_town.JuiceShop >= 2 then

    base_camp_2_juice.Juice_Shop(obj, activator)

  end
  
end

function base_camp_2_juice.Bug_Complete()
  local juice = CH('Juice_Owner')
  local player = CH('PLAYER')
  
  GROUND:CharTurnToChar(juice,player)
  
  UI:SetSpeaker(juice)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Help_003']))
  
  local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_bug_silk")
  COMMON.GiftItem(player, receive_item)
  
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Help_004']))
  
  COMMON.CompleteMission("QuestBug")
  
  SV.base_town.JuiceShop = 2
end

base_camp_2_juice.boost_tbl = { }
--{ Level = 0, EXP = 100, HP = 0, Atk = 0, Def = 0, SpAtk = 0, SpDef = 0, Speed = 0, NegateExp = false, NegateStat = false, GummiEffect = nil}
base_camp_2_juice.boost_tbl["food_apple"] = { EXP = 100 }
base_camp_2_juice.boost_tbl["food_apple_big"] = { EXP = 300 }
base_camp_2_juice.boost_tbl["food_apple_huge"] = { EXP = 2500 }
base_camp_2_juice.boost_tbl["food_apple_perfect"] = { EXP = 25000 }
base_camp_2_juice.boost_tbl["food_apple_golden"] = { Level = 100 }
base_camp_2_juice.boost_tbl["food_banana"] = { EXP = 1000 }
base_camp_2_juice.boost_tbl["food_banana_big"] = { EXP = 5000 }
base_camp_2_juice.boost_tbl["food_banana_golden"] = { Level = 100 }

base_camp_2_juice.boost_tbl["berry_oran"] = { HP = 1 }
base_camp_2_juice.boost_tbl["berry_leppa"] = { HP = 1 }
base_camp_2_juice.boost_tbl["berry_sitrus"] = { HP = 1 }
base_camp_2_juice.boost_tbl["berry_lum"] = { HP = 1 }

base_camp_2_juice.boost_tbl["berry_passho"] = { HP = 1 }
base_camp_2_juice.boost_tbl["berry_colbur"] = { HP = 1 }
base_camp_2_juice.boost_tbl["berry_yache"] = { SpDef = 1 }
base_camp_2_juice.boost_tbl["berry_rindo"] = { SpDef = 1 }
base_camp_2_juice.boost_tbl["berry_tanga"] = { Speed = 1 }
base_camp_2_juice.boost_tbl["berry_shuca"] = { Atk = 1 }
base_camp_2_juice.boost_tbl["berry_chople"] = { Atk = 1 }
base_camp_2_juice.boost_tbl["berry_payapa"] = { SpAtk = 1 }
base_camp_2_juice.boost_tbl["berry_kebia"] = { Def = 1 }
base_camp_2_juice.boost_tbl["berry_kasib"] = { SpAtk = 1 }
base_camp_2_juice.boost_tbl["berry_occa"] = { SpAtk = 1 }
base_camp_2_juice.boost_tbl["berry_haban"] = { Atk = 1 }
base_camp_2_juice.boost_tbl["berry_babiri"] = { Def = 1 }
base_camp_2_juice.boost_tbl["berry_chilan"] = { HP = 1 }
base_camp_2_juice.boost_tbl["berry_wacan"] = { Speed = 1 }
base_camp_2_juice.boost_tbl["berry_coba"] = { Speed = 1 }
base_camp_2_juice.boost_tbl["berry_charti"] = { Def = 1 }
base_camp_2_juice.boost_tbl["berry_roseli"] = { SpDef = 1 }

base_camp_2_juice.boost_tbl["berry_jaboca"] = { Def = 1 }
base_camp_2_juice.boost_tbl["berry_rowap"] = { SpDef = 1 }

base_camp_2_juice.boost_tbl["berry_liechi"] = { Atk = 2 }
base_camp_2_juice.boost_tbl["berry_ganlon"] = { Def = 2 }
base_camp_2_juice.boost_tbl["berry_petaya"] = { SpAtk = 2 }
base_camp_2_juice.boost_tbl["berry_apicot"] = { SpDef = 2 }
base_camp_2_juice.boost_tbl["berry_salac"] = { Speed = 2 }
base_camp_2_juice.boost_tbl["berry_starf"] = { HP = 2 }
base_camp_2_juice.boost_tbl["berry_micle"] = { Atk = 1, SpAtk = 1 }

base_camp_2_juice.boost_tbl["berry_enigma"] = { HP = 1 }

base_camp_2_juice.boost_tbl["gummi_wonder"] = { HP = 2, Atk = 2, Def = 2, SpAtk = 2, SpDef = 2, Speed = 2 }

base_camp_2_juice.boost_tbl["gummi_blue"] = { HP = 2, GummiEffect = 'water' }
base_camp_2_juice.boost_tbl["gummi_black"] = { HP = 2, GummiEffect = 'dark' }
base_camp_2_juice.boost_tbl["gummi_clear"] = { SpDef = 2, GummiEffect = 'ice' }
base_camp_2_juice.boost_tbl["gummi_grass"] = { SpDef = 2, GummiEffect = 'grass' }
base_camp_2_juice.boost_tbl["gummi_green"] = { Speed = 2, GummiEffect = 'bug' }
base_camp_2_juice.boost_tbl["gummi_brown"] = { Atk = 2, GummiEffect = 'ground' }
base_camp_2_juice.boost_tbl["gummi_orange"] = { Atk = 2, GummiEffect = 'fighting' }
base_camp_2_juice.boost_tbl["gummi_gold"] = { SpAtk = 2, GummiEffect = 'psychic' }
base_camp_2_juice.boost_tbl["gummi_pink"] = { Def = 2, GummiEffect = 'poison' }
base_camp_2_juice.boost_tbl["gummi_purple"] = { SpAtk = 2, GummiEffect = 'ghost' }
base_camp_2_juice.boost_tbl["gummi_red"] = { SpAtk = 2, GummiEffect = 'fire' }
base_camp_2_juice.boost_tbl["gummi_royal"] = { Atk = 2, GummiEffect = 'dragon' }
base_camp_2_juice.boost_tbl["gummi_silver"] = { Def = 2, GummiEffect = 'steel' }
base_camp_2_juice.boost_tbl["gummi_white"] = { HP = 2, GummiEffect = 'normal' }
base_camp_2_juice.boost_tbl["gummi_yellow"] = { Speed = 2, GummiEffect = 'electric' }
base_camp_2_juice.boost_tbl["gummi_sky"] = { Speed = 2, GummiEffect = 'flying' }
base_camp_2_juice.boost_tbl["gummi_gray"] = { Def = 2, GummiEffect = 'rock' }
base_camp_2_juice.boost_tbl["gummi_magenta"] = { SpDef = 2, GummiEffect = 'fairy' }

base_camp_2_juice.boost_tbl["seed_plain"] = { EXP = 100 }
base_camp_2_juice.boost_tbl["seed_reviver"] = { EXP = 800 }

base_camp_2_juice.boost_tbl["seed_joy"] = { Level = 1 }
base_camp_2_juice.boost_tbl["seed_golden"] = { Level = 5 }
base_camp_2_juice.boost_tbl["seed_doom"] = { Level = -5 }

base_camp_2_juice.boost_tbl["seed_hunger"] = { EXP = 500 }

base_camp_2_juice.boost_tbl["seed_warp"] = { Speed = 1 }
base_camp_2_juice.boost_tbl["seed_sleep"] = { HP = 1 }
base_camp_2_juice.boost_tbl["seed_vile"] = { Def = 1, SpDef = 1 }
base_camp_2_juice.boost_tbl["seed_blast"] = { Atk = 1 }
base_camp_2_juice.boost_tbl["seed_blinker"] = { Speed = 1 }

base_camp_2_juice.boost_tbl["seed_pure"] = { EXP = 100 }
base_camp_2_juice.boost_tbl["seed_ice"] = { Speed = 1 }
base_camp_2_juice.boost_tbl["seed_decoy"] = { SpDef = 1 }
base_camp_2_juice.boost_tbl["seed_last_chance"] = { Atk = 1, SpAtk = 1 }
base_camp_2_juice.boost_tbl["seed_ban"] = { EXP = 100 }

base_camp_2_juice.boost_tbl["boost_nectar"] = { HP = 1, Atk = 1, Def = 1, SpAtk = 1, SpDef = 1, Speed = 1 }

base_camp_2_juice.boost_tbl["boost_hp_up"] = { HP = 8 }
base_camp_2_juice.boost_tbl["boost_protein"] = { Atk = 8 }
base_camp_2_juice.boost_tbl["boost_iron"] = { Def = 8 }
base_camp_2_juice.boost_tbl["boost_calcium"] = { SpAtk = 8 }
base_camp_2_juice.boost_tbl["boost_zinc"] = { SpDef = 8 }
base_camp_2_juice.boost_tbl["boost_carbos"] = { Speed = 8 }

base_camp_2_juice.boost_tbl["medicine_amber_tear"] = { HP = 1, Atk = 1, Def = 1, SpAtk = 1, SpDef = 1, Speed = 1 }

base_camp_2_juice.boost_tbl["herb_mental"] = { NegateStatA = true }
base_camp_2_juice.boost_tbl["herb_power"] = { NegateStatB = true }
base_camp_2_juice.boost_tbl["herb_white"] = { NegateStatC = true }

base_camp_2_juice.boost_tbl["food_grimy"] = { NegateExp = true }





function base_camp_2_juice.getTotalBoost(cart, member)
	local playerMonId = member.BaseForm
	local mon = _DATA:GetMonster(playerMonId.Species)
	local form = mon.Forms[playerMonId.Form]

	local total_boost = { EXP = 0, Level = 0, HP = 0, Atk = 0, Def = 0, SpAtk = 0, SpDef = 0, Speed = 0 }
	
	local negate_exp = false
	local negate_a = false
	local negate_b = false
	local negate_c = false
	
	for ii = 1, #cart, 1 do
		local item
		if cart[ii].IsEquipped then
			item = GAME:GetPlayerEquippedItem(cart[ii].Slot)
		else
			item = GAME:GetPlayerBagItem(cart[ii].Slot)
		end
		local boost = base_camp_2_juice.boost_tbl[item.ID]
		
		if boost ~= nil then
			if boost.GummiEffect ~= nil then
				
				local matchup = PMDC.Dungeon.PreTypeEvent.CalculateTypeMatchup(boost.GummiEffect, form.Element1)
				matchup = matchup + PMDC.Dungeon.PreTypeEvent.CalculateTypeMatchup(boost.GummiEffect, form.Element2)
				
				local main_stat = ""
				if boost.HP ~= nil then
					main_stat = "HP"
				end
				if boost.Atk ~= nil then
					main_stat = "Atk"
				end
				if boost.Def ~= nil then
					main_stat = "Def"
				end
				if boost.SpAtk ~= nil then
					main_stat = "SpAtk"
				end
				if boost.SpDef ~= nil then
					main_stat = "SpDef"
				end
				if boost.Speed ~= nil then
					main_stat = "Speed"
				end
				
				local stats = {}
				
				local main_boost = 0
				local all_boost = 0
				
				
				if boost.GummiEffect == form.Element1 or boost.GummiEffect == form.Element2 then
					main_boost = 2
					all_boost = 1
					
					table.insert(stats, "HP")
					table.insert(stats, "Atk")
					table.insert(stats, "Def")
					table.insert(stats, "SpAtk")
					table.insert(stats, "SpDef")
					table.insert(stats, "Speed")
				elseif matchup >= PMDC.Dungeon.PreTypeEvent.S_E_2 then
					main_boost = 2
					all_boost = 1
					
					top_stats = {}
					if main_stat ~= "HP" then
					  table.insert(top_stats, { RogueEssence.Data.Stat.HP, "HP"})
					end
					if main_stat ~= "Atk" then
					  table.insert(top_stats, { RogueEssence.Data.Stat.Attack, "Atk"})
					end
					if main_stat ~= "Def" then
					  table.insert(top_stats, { RogueEssence.Data.Stat.Defense, "Def"})
					end
					if main_stat ~= "SpAtk" then
					  table.insert(top_stats, { RogueEssence.Data.Stat.MAtk, "SpAtk"})
					end
					if main_stat ~= "SpDef" then
					  table.insert(top_stats, { RogueEssence.Data.Stat.MDef, "SpDef"})
					end
					if main_stat ~= "Speed" then
					  table.insert(top_stats, { RogueEssence.Data.Stat.Speed, "Speed"})
					end
					

					table.sort(top_stats, 
					  function(a, b)
					    return form:GetBaseStat(a[1]) > form:GetBaseStat(b[1])
					  end
					)
					
					table.insert(stats, top_stats[1][2])
					table.insert(stats, top_stats[2][2])
					table.insert(stats, main_stat)
				elseif matchup == PMDC.Dungeon.PreTypeEvent.NRM_2 then
					main_boost = 2
					all_boost = 0
					table.insert(stats, main_stat)
				elseif matchup > PMDC.Dungeon.PreTypeEvent.N_E_2 then
					main_boost = 1
					all_boost = 0
					table.insert(stats, main_stat)
				end
				
				for i, stat in ipairs(stats) do
				  if stat == main_stat then
				    total_boost[stat] = total_boost[stat] + main_boost
				  else
				    total_boost[stat] = total_boost[stat] + all_boost
				  end
				end
			else
				if boost.EXP ~= nil then
					total_boost.EXP = total_boost.EXP + boost.EXP
				end
				if boost.Level ~= nil then
					total_boost.Level = total_boost.Level + boost.Level
				end
				if boost.HP ~= nil then
					total_boost.HP = total_boost.HP + boost.HP
				end
				if boost.Atk ~= nil then
					total_boost.Atk = total_boost.Atk + boost.Atk
				end
				if boost.Def ~= nil then
					total_boost.Def = total_boost.Def + boost.Def
				end
				if boost.SpAtk ~= nil then
					total_boost.SpAtk = total_boost.SpAtk + boost.SpAtk
				end
				if boost.SpDef ~= nil then
					total_boost.SpDef = total_boost.SpDef + boost.SpDef
				end
				if boost.Speed ~= nil then
					total_boost.Speed = total_boost.Speed + boost.Speed
				end
			end
			
			if boost.NegateExp then
				negate_exp = true
			end
			if boost.NegateStatA then
				negate_a = true
			end
			if boost.NegateStatB then
				negate_b = true
			end
			if boost.NegateStatC then
				negate_c = true
			end
		end
	end
	
	if negate_exp and negate_a and negate_b and negate_c then
		total_boost.EXP = 0
		total_boost.Level = -100
		total_boost.HP = -256
		total_boost.Atk = -256
		total_boost.Def = -256
		total_boost.SpAtk = -256
		total_boost.SpDef = -256
		total_boost.Speed = -256
	else
	
		if negate_exp then
			total_boost.EXP = total_boost.EXP * -1
			total_boost.Level = total_boost.Level * -1
		end
		
		if negate_a and negate_b and negate_c then
			total_boost.HP = -256
			total_boost.Atk = -256
			total_boost.Def = -256
			total_boost.SpAtk = -256
			total_boost.SpDef = -256
			total_boost.Speed = -256
		elseif negate_a or negate_b or negate_c then
			total_boost.HP = total_boost.HP * -1
			total_boost.Atk = total_boost.Atk * -1
			total_boost.Def = total_boost.Def * -1
			total_boost.SpAtk = total_boost.SpAtk * -1
			total_boost.SpDef = total_boost.SpDef * -1
			total_boost.Speed = total_boost.Speed * -1
		end
	end
	
	return total_boost
end

function base_camp_2_juice.Drink_Flow(boost, member)
	local any_boost = false
	local changed_stats = {}
	local changed_amounts = {}
	local any_stat_boosted = false
	local any_stat_dropped = false
	
	local old_level = member.Level
	local old_hp = member.MaxHP
	local old_atk = member.BaseAtk
	local old_def = member.BaseDef
	local old_sp_atk = member.BaseMAtk
	local old_sp_def = member.BaseMDef
	local old_speed = member.BaseSpeed
	
	if boost.HP ~= 0 then
		member.MaxHPBonus = math.max(0, math.min(member.MaxHPBonus + boost.HP, PMDC.Data.MonsterFormData.MAX_STAT_BOOST))
		local diff = member.MaxHP - old_hp
		if diff > 0 then
			table.insert(changed_stats, RogueEssence.Data.Stat.HP)
			table.insert(changed_amounts, diff)
			any_stat_boosted = true
		elseif diff < 0 then
			table.insert(changed_stats, RogueEssence.Data.Stat.HP)
			table.insert(changed_amounts, diff)
			any_stat_dropped = true
		end
	end
	if boost.Atk ~= 0 then
		member.AtkBonus = math.max(0, math.min(member.AtkBonus + boost.Atk, PMDC.Data.MonsterFormData.MAX_STAT_BOOST))
		local diff = member.BaseAtk - old_atk
		if diff > 0 then
			table.insert(changed_stats, RogueEssence.Data.Stat.Attack)
			table.insert(changed_amounts, diff)
			any_stat_boosted = true
		elseif diff < 0 then
			table.insert(changed_stats, RogueEssence.Data.Stat.Attack)
			table.insert(changed_amounts, diff)
			any_stat_dropped = true
		end
	end
	if boost.Def ~= 0 then
		member.DefBonus = math.max(0, math.min(member.DefBonus + boost.Def, PMDC.Data.MonsterFormData.MAX_STAT_BOOST))
		local diff = member.BaseDef - old_def
		if diff > 0 then
			table.insert(changed_stats, RogueEssence.Data.Stat.Defense)
			table.insert(changed_amounts, diff)
			any_stat_boosted = true
		elseif diff < 0 then
			table.insert(changed_stats, RogueEssence.Data.Stat.Defense)
			table.insert(changed_amounts, diff)
			any_stat_dropped = true
		end
	end
	if boost.SpAtk ~= 0 then
		member.MAtkBonus = math.max(0, math.min(member.MAtkBonus + boost.SpAtk, PMDC.Data.MonsterFormData.MAX_STAT_BOOST))
		local diff = member.BaseMAtk - old_sp_atk
		if diff > 0 then
			table.insert(changed_stats, RogueEssence.Data.Stat.MAtk)
			table.insert(changed_amounts, diff)
			any_stat_boosted = true
		elseif diff < 0 then
			table.insert(changed_stats, RogueEssence.Data.Stat.MAtk)
			table.insert(changed_amounts, diff)
			any_stat_dropped = true
		end
	end
	if boost.SpDef ~= 0 then
		member.MDefBonus = math.max(0, math.min(member.MDefBonus + boost.SpDef, PMDC.Data.MonsterFormData.MAX_STAT_BOOST))
		local diff = member.BaseMDef - old_sp_def
		if diff > 0 then
			table.insert(changed_stats, RogueEssence.Data.Stat.MDef)
			table.insert(changed_amounts, diff)
			any_stat_boosted = true
		elseif diff < 0 then
			table.insert(changed_stats, RogueEssence.Data.Stat.MDef)
			table.insert(changed_amounts, diff)
			any_stat_dropped = true
		end
	end
	if boost.Speed ~= 0 then
		member.SpeedBonus = math.max(0, math.min(member.SpeedBonus + boost.Speed, PMDC.Data.MonsterFormData.MAX_STAT_BOOST))
		local diff = member.BaseSpeed - old_speed
		if diff > 0 then
			table.insert(changed_stats, RogueEssence.Data.Stat.Speed)
			table.insert(changed_amounts, diff)
			any_stat_boosted = true
		elseif diff < 0 then
			table.insert(changed_stats, RogueEssence.Data.Stat.Speed)
			table.insert(changed_amounts, diff)
			any_stat_dropped = true
		end
	end
	
	if boost.EXP ~= 0 then
		member.EXP = member.EXP + boost.EXP
		
        local growth = _DATA:GetMonster(member.BaseForm.Species).EXPTable
        local growth_data = _DATA:GetGrowth(growth)
		
		while member.EXP < 0 do
			if member.Level <= 1 then
				member.EXP = 0
			else
				member.Level = member.Level - 1
				member.EXP = member.EXP + growth_data:GetExpToNext(member.Level)
			end
		end
		
		while true do
			if member.Level >= _DATA.Start.MaxLevel then
				member.EXP = 0
				break
			elseif member.EXP >= growth_data:GetExpToNext(member.Level) then
				member.EXP = member.EXP - growth_data:GetExpToNext(member.Level)
				member.Level = member.Level + 1
			else
				break
			end
		end
	end
	
	if boost.Level ~= 0 then
		member.EXP = 0
		member.Level = math.max(1, math.min(member.Level + boost.Level, _DATA.Start.MaxLevel))
	end
	
	member.HP = member.MaxHP
	
	if boost.EXP > 0 then
		UI:WaitShowDialogue(STRINGS:FormatKey("MSG_EXP_GAIN_MEMBER", member:GetDisplayName(true), boost.EXP))
		any_boost = true
	elseif boost.EXP < 0 then
		UI:WaitShowDialogue(STRINGS:FormatKey("MSG_EXP_LOSS_MEMBER", member:GetDisplayName(true), boost.EXP * -1))
		any_boost = true
	end
	
	if member.Level ~= old_level then
		if member.Level > old_level and any_stat_boosted then
			--level up fanfare
			UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MSG_LEVEL_STAT_BOOST"):ToLocal(), member:GetDisplayName(true)))
		elseif member.Level < old_level and any_stat_dropped then
			--level down fanfare
			UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MSG_LEVEL_STAT_DROP"):ToLocal(), member:GetDisplayName(true)))
		elseif any_stat_boosted or any_stat_dropped then
			--a weird stat change fanfare?
			UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MSG_LEVEL_STAT_CHANGE"):ToLocal(), member:GetDisplayName(true)))
		elseif member.Level > old_level then
			--level up fanfare
			UI:WaitShowDialogue(STRINGS:FormatKey("DLG_LEVEL_UP", member:GetDisplayName(true), member.Level))
		elseif member.Level < old_level then
			--level down fanfare
			UI:WaitShowDialogue(STRINGS:FormatKey("DLG_LEVEL_DOWN", member:GetDisplayName(true), member.Level))
		end
		--show level diff menu
		UI:SetCustomMenu(RogueEssence.Menu.LevelUpMenu(member, old_level, old_hp, old_speed, old_atk, old_def, old_sp_atk, old_sp_def))
		UI:WaitForChoice()
		any_boost = true
	elseif any_stat_boosted then
		if #changed_stats > 1 then
			--increase sound?
			UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MSG_STAT_BOOST_MULTI"):ToLocal(), member:GetDisplayName(true)))
			UI:SetCustomMenu(RogueEssence.Menu.LevelUpMenu(member, old_level, old_hp, old_speed, old_atk, old_def, old_sp_atk, old_sp_def))
			UI:WaitForChoice()
		else
			--increase sound?
			UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MSG_STAT_BOOST"):ToLocal(), member:GetDisplayName(true), RogueEssence.Text.ToLocal(changed_stats[1], nil), changed_amounts[1]))
		end
		any_boost = true
	elseif any_stat_dropped then
		if #changed_stats > 1 then
			--drop sound?
			UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MSG_STAT_DROP_MULTI"):ToLocal(), member:GetDisplayName(true)))
			UI:SetCustomMenu(RogueEssence.Menu.LevelUpMenu(member, old_level, old_hp, old_speed, old_atk, old_def, old_sp_atk, old_sp_def))
			UI:WaitForChoice()
		else
			--drop sound?
			UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MSG_STAT_DROP"):ToLocal(), member:GetDisplayName(true), RogueEssence.Text.ToLocal(changed_stats[1], nil), changed_amounts[1] * -1))
		end
		any_boost = true
	end
	
	if not any_boost then
		UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Order_Result_None'], member:GetDisplayName(true)))
	end
	
end


function base_camp_2_juice.Drink_Order_Flow()

  local state = 0
  local member = nil
  local cart = { }
  
  while state > -1 do
  
    if state == 0 then
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Order_Who']))
	  member = TeamSelectMenu.runPartyMenu()
      if member then
		state = 1
	  else
		state = -1
	  end
    elseif state == 1 then
	  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Order_What'], STRINGS:LocalKeyString(26)))

	  local result = JuiceShopMenu.run(STRINGS:FormatKey("MENU_ITEM_TITLE"), member, base_camp_2_juice.boost_tbl, true, SV.base_town.JuiceShop > 2, function(cart, member) return base_camp_2_juice.getTotalBoost(cart, member) end) -- preview is set to be post game only

	  if #result > 0 then
		cart = result

		local total_boost = base_camp_2_juice.getTotalBoost(cart, member)
		
		for ii = #cart, 1, -1 do
			if cart[ii].IsEquipped then
				GAME:TakePlayerEquippedItem(cart[ii].Slot, true)
			else
				GAME:TakePlayerBagItem(cart[ii].Slot, true)
			end
		end
		cart = {}

        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Order_Begin']))
		SOUND:PlayBattleSE("DUN_Drink")
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Order_Drink'], member:GetDisplayName(true)))
		base_camp_2_juice.Drink_Flow(total_boost, member)
        state = -1
      else
        state = 0
      end
    end
  
  end
  
end


base_camp_2_juice.specialties = { 
	{ 
		Name = "Ambrosia",
		Desc = "Flavor Text here. Boosts level to 100 and maximizes all stats.",
		Sizes = 
		{
			{ Name = "One Size for All", Desc = "Boosts level to 100 and maximizes all stats.", Effect = { Level = 100, HP = 256, Atk = 256, Def = 256, SpAtk = 256, SpDef = 256, Speed = 256 } }
		}
	},
	{ 
		Name = "+Lv Dish",
		Desc = "Flavor Text here. Increases Level.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Boosts level by 1.", Effect = { Level = 1 } },
			{ Name = "Medium", Desc = "Boosts level by 5.", Effect = { Level = 5 } },
			{ Name = "Large", Desc = "Boosts level by 10.", Effect = { Level = 10 } },
			{ Name = "Super", Desc = "Boosts level by 25.", Effect = { Level = 25 } },
			{ Name = "MAX", Desc = "Boosts level to 100.", Effect = { Level = 100 } }
		}
	},
	{ 
		Name = "+All EV Dish",
		Desc = "Flavor Text here. Increases Stats.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Boosts all stat EVs by 8.", Effect = { HP = 8, Atk = 8, Def = 8, SpAtk = 8, SpDef = 8, Speed = 8 } },
			{ Name = "Medium", Desc = "Boosts all stat EVs by 16.", Effect = { HP = 16, Atk = 16, Def = 16, SpAtk = 16, SpDef = 16, Speed = 16 } },
			{ Name = "Large", Desc = "Boosts all stat EVs by 32.", Effect = { HP = 32, Atk = 32, Def = 32, SpAtk = 32, SpDef = 32, Speed = 32 } },
			{ Name = "Super", Desc = "Boosts all stat EVs by 64.", Effect = { HP = 64, Atk = 64, Def = 64, SpAtk = 64, SpDef = 64, Speed = 64 } },
			{ Name = "MAX", Desc = "Maximizes all stats.", Effect = { HP = 256, Atk = 256, Def = 256, SpAtk = 256, SpDef = 256, Speed = 256 } }
		}
	},
	{ 
		Name = "+HP EV Dish",
		Desc = "Flavor Text here. Increases HP.",
		Sizes =
		{
			{ Name = "Small", Desc = "Boosts HP EVs by 8.", Effect = { HP = 8 } },
			{ Name = "Medium", Desc = "Boosts HP EVs by 16.", Effect = { HP = 16 } },
			{ Name = "Large", Desc = "Boosts HP EVs by 32.", Effect = { HP = 32 } },
			{ Name = "Super", Desc = "Boosts HP EVs by 64.", Effect = { HP = 64 } },
			{ Name = "MAX", Desc = "Maximizes HP EVs.", Effect = { HP = 256 } }
		}
	},
	{ 
		Name = "+ATK EV Dish",
		Desc = "Flavor Text here. Increases Atk.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Boosts Atk EVs by 8.", Effect = { Atk = 8 } },
			{ Name = "Medium", Desc = "Boosts Atk EVs by 16.", Effect = { Atk = 16 } },
			{ Name = "Large", Desc = "Boosts Atk EVs by 32.", Effect = { Atk = 32 } },
			{ Name = "Super", Desc = "Boosts Atk EVs by 64.", Effect = { Atk = 64 } },
			{ Name = "MAX", Desc = "Maximizes Atk EVs.", Effect = { Atk = 256 } }
		}
	},
	{ 
		Name = "+DEF EV Dish",
		Desc = "Flavor Text here. Increases Def.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Boosts Def EVs by 8.", Effect = { Def = 8 } },
			{ Name = "Medium", Desc = "Boosts Def EVs by 16.", Effect = { Def = 16 } },
			{ Name = "Large", Desc = "Boosts Def EVs by 32.", Effect = { Def = 32 } },
			{ Name = "Super", Desc = "Boosts Def EVs by 64.", Effect = { Def = 64 } },
			{ Name = "MAX", Desc = "Maximizes Def EVs.", Effect = { Def = 256 } }
		}
	},
	{ 
		Name = "+SP.ATK EV Dish",
		Desc = "Flavor Text here. Increases Sp.Atk.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Boosts Sp.Atk EVs by 8.", Effect = { SpAtk = 8 } },
			{ Name = "Medium", Desc = "Boosts Sp.Atk EVs by 16.", Effect = { SpAtk = 16 } },
			{ Name = "Large", Desc = "Boosts Sp.Atk EVs by 32.", Effect = { SpAtk = 32 } },
			{ Name = "Super", Desc = "Boosts Sp.Atk EVs by 64.", Effect = { SpAtk = 64 } },
			{ Name = "MAX", Desc = "Maximizes Sp.Atk EVs.", Effect = { SpAtk = 256 } }
		}
	},
	{ 
		Name = "+SP.DEF EV Dish",
		Desc = "Flavor Text here. Increases Sp.Def.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Boosts Sp.Def EVs by 8.", Effect = { SpDef = 8 } },
			{ Name = "Medium", Desc = "Boosts Sp.Def EVs by 16.", Effect = { SpDef = 16 } },
			{ Name = "Large", Desc = "Boosts Sp.Def EVs by 32.", Effect = { SpDef = 32 } },
			{ Name = "Super", Desc = "Boosts Sp.Def EVs by 64.", Effect = { SpDef = 64 } },
			{ Name = "MAX", Desc = "Maximizes Sp.Def EVs.", Effect = { SpDef = 256 } }
		}
	},
	{ 
		Name = "+SPEED EV Dish",
		Desc = "Flavor Text here. Increases Speed.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Boosts Speed EVs by 8.", Effect = { Speed = 8 } },
			{ Name = "Medium", Desc = "Boosts Speed EVs by 16.", Effect = { Speed = 16 } },
			{ Name = "Large", Desc = "Boosts Speed EVs by 32.", Effect = { Speed = 32 } },
			{ Name = "Super", Desc = "Boosts Speed EVs by 64.", Effect = { Speed = 64 } },
			{ Name = "MAX", Desc = "Maximizes Speed EVs.", Effect = { Speed = 256 } }
		}
	},

	{ 
		Name = "-Lv Dish",
		Desc = "Flavor Text here. Decreases Level.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Boosts level by 1.", Effect = { Level = -1 } },
			{ Name = "Medium", Desc = "Boosts level by 5.", Effect = { Level = -5 } },
			{ Name = "Large", Desc = "Boosts level by 10.", Effect = { Level = -10 } },
			{ Name = "Super", Desc = "Boosts level by 25.", Effect = { Level = -25 } },
			{ Name = "MAX", Desc = "Boosts level to 100.", Effect = { Level = -100 } }
		}
	},
	{ 
		Name = "-All EV Dish",
		Desc = "Flavor Text here. Decreases Stats.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Drops all stat EVs by 8.", Effect = { HP = -8, Atk = -8, Def = -8, SpAtk = -8, SpDef = -8, Speed = -8 } },
			{ Name = "Medium", Desc = "Drops all stat EVs by 16.", Effect = { HP = -16, Atk = -16, Def = -16, SpAtk = -16, SpDef = -16, Speed = -16 } },
			{ Name = "Large", Desc = "Drops all stat EVs by 32.", Effect = { HP = -32, Atk = -32, Def = -32, SpAtk = -32, SpDef = -32, Speed = -32 } },
			{ Name = "Super", Desc = "Drops all stat EVs by 64.", Effect = { HP = -64, Atk = -64, Def = -64, SpAtk = -64, SpDef = -64, Speed = -64 } },
			{ Name = "MAX", Desc = "Clears all stat EVs.", Effect = { HP = -256, Atk = -256, Def = -256, SpAtk = -256, SpDef = -256, Speed = -256 } }
		}
	},
	{ 
		Name = "-HP EV Dish",
		Desc = "Flavor Text here. Decreases HP.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Drops HP EVs by 8.", Effect = { HP = -8 } },
			{ Name = "Medium", Desc = "Drops HP EVs by 16.", Effect = { HP = -16 } },
			{ Name = "Large", Desc = "Drops HP EVs by 32.", Effect = { HP = -32 } },
			{ Name = "Super", Desc = "Drops HP EVs by 64.", Effect = { HP = -64 } },
			{ Name = "MAX", Desc = "Clears all HP EVs.", Effect = { HP = -256 } }
		}
	},
	{ 
		Name = "-ATK EV Dish",
		Desc = "Flavor Text here. Decreases Atk.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Drops Atk EVs by 8.", Effect = { Atk = -8 } },
			{ Name = "Medium", Desc = "Drops Atk EVs by 16.", Effect = { Atk = -16 } },
			{ Name = "Large", Desc = "Drops Atk EVs by 32.", Effect = { Atk = -32 } },
			{ Name = "Super", Desc = "Drops Atk EVs by 64.", Effect = { Atk = -64 } },
			{ Name = "MAX", Desc = "Clears all Atk EVs.", Effect = { Atk = -256 } }
		}
	},
	{ 
		Name = "-DEF EV Dish",
		Desc = "Flavor Text here. Decreases Def.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Drops Def EVs by 8.", Effect = { Def = -8 } },
			{ Name = "Medium", Desc = "Drops Def EVs by 16.", Effect = { Def = -16 } },
			{ Name = "Large", Desc = "Drops Def EVs by 32.", Effect = { Def = -32 } },
			{ Name = "Super", Desc = "Drops Def EVs by 64.", Effect = { Def = -64 } },
			{ Name = "MAX", Desc = "Clears all Def EVs.", Effect = { Def = -256 } }
		}
	},
	{ 
		Name = "-SP.ATK EV Dish",
		Desc = "Flavor Text here. Decreases Sp.Atk.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Drops Sp.Atk EVs by 8.", Effect = { SpAtk = -8 } },
			{ Name = "Medium", Desc = "Drops Sp.Atk EVs by 16.", Effect = { SpAtk = -16 } },
			{ Name = "Large", Desc = "Drops Sp.Atk EVs by 32.", Effect = { SpAtk = -32 } },
			{ Name = "Super", Desc = "Drops Sp.Atk EVs by 64.", Effect = { SpAtk = -64 } },
			{ Name = "MAX", Desc = "Clears all Sp.Atk EVs.", Effect = { SpAtk = -256 } }
		}
	},
	{ 
		Name = "-SP.DEF EV Dish",
		Desc = "Flavor Text here. Decreases Sp.Def.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Drops Sp.Def EVs by 8.", Effect = { SpDef = -8 } },
			{ Name = "Medium", Desc = "Drops Sp.Def EVs by 16.", Effect = { SpDef = -16 } },
			{ Name = "Large", Desc = "Drops Sp.Def EVs by 32.", Effect = { SpDef = -32 } },
			{ Name = "Super", Desc = "Drops Sp.Def EVs by 64.", Effect = { SpDef = -64 } },
			{ Name = "MAX", Desc = "Clears all Sp.Def EVs.", Effect = { SpDef = -256 } }
		}
	},
	{ 
		Name = "-SPEED EV Dish",
		Desc = "Flavor Text here. Decreases Speed.",
		Sizes = 
		{
			{ Name = "Small", Desc = "Drops Speed EVs by 8.", Effect = { Speed = -8 } },
			{ Name = "Medium", Desc = "Drops Speed EVs by 16.", Effect = { Speed = -16 } },
			{ Name = "Large", Desc = "Drops Speed EVs by 32.", Effect = { Speed = -32 } },
			{ Name = "Super", Desc = "Drops Speed EVs by 64.", Effect = { Speed = -64 } },
			{ Name = "MAX", Desc = "Clears all Speed EVs.", Effect = { Speed = -256 } }
		}
	},
	{ 
		Name = "Grimace Shake",
		Desc = "Flavor text here. Removes all EVs and resets level to 1.",
		Sizes = 
		{
			{ Name = "One Size for All", Desc = "Removes all EVs and resets level to 1.", Effect = { Level = -100, HP = -256, Atk = -256, Def = -256, SpAtk = -256, SpDef = -256, Speed = -256 } }
		}
	}
}

--will eating this have ANY effect?
function base_camp_2_juice.Can_Eat(target, effect)

	if effect.Level ~= nil then
		if effect.Level > 0 and target.Level < _DATA.Start.MaxLevel then
			return true
		elseif effect.Level < 0 and target.Level > 1 then
			return true
		end
	end
	
	if effect.HP ~= nil then
		if effect.HP > 0 and target.MaxHPBonus < PMDC.Data.MonsterFormData.MAX_STAT_BOOST then
			return true
		elseif effect.HP < 0 and target.MaxHPBonus > 0 then
			return true
		end
	end
	
	if effect.Atk ~= nil then
		if effect.Atk > 0 and target.AtkBonus < PMDC.Data.MonsterFormData.MAX_STAT_BOOST then
			return true
		elseif effect.Atk < 0 and target.AtkBonus > 0 then
			return true
		end
	end
	
	if effect.Def ~= nil then
		if effect.Def > 0 and target.DefBonus < PMDC.Data.MonsterFormData.MAX_STAT_BOOST then
			return true
		elseif effect.Def < 0 and target.DefBonus > 0 then
			return true
		end
	end
	
	if effect.SpAtk ~= nil then
		if effect.SpAtk > 0 and target.MAtkBonus < PMDC.Data.MonsterFormData.MAX_STAT_BOOST then
			return true
		elseif effect.SpAtk < 0 and target.MAtkBonus > 0 then
			return true
		end
	end
	
	if effect.SpDef ~= nil then
		if effect.SpDef > 0 and target.MDefBonus < PMDC.Data.MonsterFormData.MAX_STAT_BOOST then
			return true
		elseif effect.SpDef < 0 and target.MDefBonus > 0 then
			return true
		end
	end
	
	if effect.Speed ~= nil then
		if effect.Speed > 0 and target.SpeedBonus < PMDC.Data.MonsterFormData.MAX_STAT_BOOST then
			return true
		elseif effect.Speed < 0 and target.SpeedBonus > 0 then
			return true
		end
	end

	return false
end

function base_camp_2_juice.Compute_Total_Tribute(target, effect)
	--TODO
	
	return {}
end

function base_camp_2_juice.Drink_Specialties_Flow()

  local state = 0
  local selection = nil
  
  while state > -1 do
  
    if state == 0 then
      selection = SpecialtiesMenu.run("Specialties", base_camp_2_juice.specialties)
      if selection then
		state = 1
	  else
		state = -1
	  end
    elseif state == 1 then
	  local effect = base_camp_2_juice.specialties[selection.Choice].Sizes[selection.Size].Effect
	  local total_boost = { EXP = 0, Level = 0, HP = 0, Atk = 0, Def = 0, SpAtk = 0, SpDef = 0, Speed = 0 }
	  if effect.Level ~= nil then
		total_boost.Level = effect.Level
	  end
	  if effect.HP ~= nil then
		total_boost.HP = effect.HP
	  end
	  if effect.Atk ~= nil then
		total_boost.Atk = effect.Atk
	  end
	  if effect.Def ~= nil then
		total_boost.Def = effect.Def
	  end
	  if effect.SpAtk ~= nil then
		total_boost.SpAtk = effect.SpAtk
	  end
	  if effect.SpDef ~= nil then
		total_boost.SpDef = effect.SpDef
	  end
	  if effect.Speed ~= nil then
		total_boost.Speed = effect.Speed
	  end
	  
      UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Order_Who_Multi'], STRINGS:LocalKeyString(26)))
	  --change this to pick multiple team members.  You may want to make an AssemblySelectMenu instead...
	  --the filter determines whether the menu option is enabled or not.  We disable choosing those who cannot be boosted further
	  local members = AssemblyMultiSelectMenu.runMultiMenu(function(target) return base_camp_2_juice.Can_Eat(target, total_boost) end)

	  if #members > 0 then
		local tribute = base_camp_2_juice.Compute_Total_Tribute(target, total_boost)

		for ii = #tribute, 1, -1 do
			local item_slot = GAME:FindPlayerItem(tribute[ii], true, true)
			if not item_slot:IsValid() then
				--it is a certainty that there is an item in storage, due to previous checks
				GAME:TakePlayerStorageItem(tribute[ii])
			elseif item_slot.IsEquipped then
				GAME:TakePlayerEquippedItem(item_slot.Slot)
			else
				GAME:TakePlayerBagItem(item_slot.Slot)
			end
		end

        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Order_Begin']))
		SOUND:PlayBattleSE("DUN_Drink")
		
		for idx, member in pairs(members) do
			base_camp_2_juice.Drink_Flow(total_boost, member)
		end
        state = -1
      else
        state = 0
      end
    end
  
  end
end


function base_camp_2_juice.Juice_Shop(obj, activator)

  local state = 0
  local repeated = false
  local chara = CH('Juice_Owner')
  UI:SetSpeaker(chara)
	
  if SV.guildmaster_summit.GameComplete and SV.base_town.JuiceShop == 2 then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Now_Specialty']))
    SV.base_town.JuiceShop = 3
  end
	
	while state > -1 do
		if state == 0 then
			msg = STRINGS:Format(STRINGS.MapStrings['Juice_Intro'])
			if repeated == true then
				msg = STRINGS:Format(STRINGS.MapStrings['Juice_Intro_Return'])
			end
			
			local juice_choices = {}
			juice_choices[1] = STRINGS:Format(STRINGS.MapStrings['Juice_Option_Order'])
			
			
			if SV.base_town.JuiceShop == 3 then
				juice_choices[2] = STRINGS:Format(STRINGS.MapStrings['Juice_Option_Specialties'])
			end
			
			juice_choices[3] = STRINGS:FormatKey("MENU_INFO")
			juice_choices[4] = STRINGS:FormatKey("MENU_EXIT")
			
			UI:BeginChoiceMenu(msg, juice_choices, 1, 4)
			
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			
			repeated = true
			if result == 1 then
				local bag_count = GAME:GetPlayerBagCount() + GAME:GetPlayerEquippedCount()
				if bag_count > 0 then
					base_camp_2_juice.Drink_Order_Flow()
				else
					UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Bag_Empty']))
				end
			elseif result == 2 then
				base_camp_2_juice.Drink_Specialties_Flow()
			elseif result == 3 then
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Info_001']))
				if SV.base_town.JuiceShop == 3 then
				    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Info_002']))
				end
			else
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Juice_Goodbye']))
				state = -1
			end
		end
	end
	
end


return base_camp_2_juice