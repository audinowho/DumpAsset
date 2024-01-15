require 'common'
require 'menu.InventorySelectMenu'
require 'menu.TeamSelectMenu'

local base_camp_2_juice = {}
local MapStrings = {}

function base_camp_2_juice.InitStrings(mapStrings)
  MapStrings = mapStrings
end


function base_camp_2_juice.Juice_Owner_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  if SV.base_town.JuiceShop == 0 then
    UI:SetSpeaker(chara)
  
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Intro']))
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Setup']))
  elseif SV.base_town.JuiceShop == 1 then
  
  local questname = "QuestBug"
  local quest = SV.missions.Missions[questname]
  
  if quest == nil then
    UI:SetSpeaker(chara)
    GROUND:CharTurnToChar(chara,CH('PLAYER'))
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Help_001']))
	
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
	  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Help_002']))
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
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Help_003']))
  
  local receive_item = RogueEssence.Dungeon.InvItem("xcl_element_bug_silk")
  COMMON.GiftItem(player, receive_item)
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Help_004']))
  
  COMMON.CompleteMission("QuestBug")
  
  SV.base_town.JuiceShop = 2
end

base_camp_2_juice.boost_tbl = { }
--{ Level = 0, EXP = 100, HP = 0, Atk = 0, Def = 0, SpAtk = 0, SpDef = 0, Speed = 0, NegateExp = false, NegateStat = false, GummiEffect = nil}
base_camp_2_juice.boost_tbl["food_apple"] = { EXP = 100 }
base_camp_2_juice.boost_tbl["food_apple_big"] = { EXP = 300 }
base_camp_2_juice.boost_tbl["food_apple_huge"] = { EXP = 1000 }
base_camp_2_juice.boost_tbl["food_apple_perfect"] = { EXP = 5000 }
base_camp_2_juice.boost_tbl["food_apple_golden"] = { EXP = 25000 }
base_camp_2_juice.boost_tbl["food_banana"] = { EXP = 500 }
base_camp_2_juice.boost_tbl["food_banana_big"] = { EXP = 2500 }
base_camp_2_juice.boost_tbl["food_banana_golden"] = { EXP = 100000 }
base_camp_2_juice.boost_tbl["berry_oran"] = { HP = 1 }
base_camp_2_juice.boost_tbl["berry_leppa"] = { HP = 1 }
base_camp_2_juice.boost_tbl["berry_sitrus"] = { HP = 1 }
base_camp_2_juice.boost_tbl["berry_lum"] = { HP = 1 }
base_camp_2_juice.boost_tbl["berry_starf"] = { HP = 2 }
base_camp_2_juice.boost_tbl["berry_liechi"] = { Atk = 2 }
base_camp_2_juice.boost_tbl["berry_ganlon"] = { Def = 2 }
base_camp_2_juice.boost_tbl["berry_petaya"] = { SpAtk = 2 }
base_camp_2_juice.boost_tbl["berry_apicot"] = { SpDef = 2 }
base_camp_2_juice.boost_tbl["berry_salac"] = { Speed = 2 }
base_camp_2_juice.boost_tbl["berry_enigma"] = { HP = 1 }
base_camp_2_juice.boost_tbl["berry_micle"] = { Atk = 1, SpAtk = 1 }
base_camp_2_juice.boost_tbl["gummi_black"] = { GummiEffect = 'dark' }
base_camp_2_juice.boost_tbl["gummi_blue"] = { GummiEffect = 'water' }
base_camp_2_juice.boost_tbl["gummi_brown"] = { GummiEffect = 'ground' }
base_camp_2_juice.boost_tbl["gummi_clear"] = { GummiEffect = 'ice' }
base_camp_2_juice.boost_tbl["gummi_gold"] = { GummiEffect = 'psychic' }
base_camp_2_juice.boost_tbl["gummi_grass"] = { GummiEffect = 'grass' }
base_camp_2_juice.boost_tbl["gummi_gray"] = { GummiEffect = 'rock' }
base_camp_2_juice.boost_tbl["gummi_green"] = { GummiEffect = 'bug' }
base_camp_2_juice.boost_tbl["gummi_magenta"] = { GummiEffect = 'fairy' }
base_camp_2_juice.boost_tbl["gummi_orange"] = { GummiEffect = 'fighting' }
base_camp_2_juice.boost_tbl["gummi_pink"] = { GummiEffect = 'poison' }
base_camp_2_juice.boost_tbl["gummi_purple"] = { GummiEffect = 'ghost' }
base_camp_2_juice.boost_tbl["gummi_red"] = { GummiEffect = 'fire' }
base_camp_2_juice.boost_tbl["gummi_royal"] = { GummiEffect = 'dragon' }
base_camp_2_juice.boost_tbl["gummi_silver"] = { GummiEffect = 'steel' }
base_camp_2_juice.boost_tbl["gummi_sky"] = { GummiEffect = 'flying' }
base_camp_2_juice.boost_tbl["gummi_white"] = { GummiEffect = 'normal' }
base_camp_2_juice.boost_tbl["gummi_yellow"] = { GummiEffect = 'electric' }
base_camp_2_juice.boost_tbl["gummi_wonder"] = { HP = 1, Atk = 1, Def = 1, SpAtk = 1, SpDef = 1, Speed = 1 }
base_camp_2_juice.boost_tbl["boost_nectar"] = { HP = 1, Atk = 1, Def = 1, SpAtk = 1, SpDef = 1, Speed = 1 }
base_camp_2_juice.boost_tbl["boost_hp_up"] = { HP = 4 }
base_camp_2_juice.boost_tbl["boost_protein"] = { Atk = 4 }
base_camp_2_juice.boost_tbl["boost_iron"] = { Def = 4 }
base_camp_2_juice.boost_tbl["boost_calcium"] = { SpAtk = 4 }
base_camp_2_juice.boost_tbl["boost_zinc"] = { SpDef = 4 }
base_camp_2_juice.boost_tbl["boost_carbos"] = { Speed = 4 }
base_camp_2_juice.boost_tbl["seed_joy"] = { Level = 1 }
base_camp_2_juice.boost_tbl["seed_golden"] = { Level = 5 }
base_camp_2_juice.boost_tbl["seed_doom"] = { Level = -5 }
base_camp_2_juice.boost_tbl["food_grimy"] = { NegateExp = true }
base_camp_2_juice.boost_tbl["herb_white"] = { NegateStat = true }
base_camp_2_juice.boost_tbl["herb_power"] = { NegateStat = true }
base_camp_2_juice.boost_tbl["herb_mental"] = { NegateStat = true }

function base_camp_2_juice.Drink_Order_Flow()

  local catalog = { }

  local state = 0
  local member = nil
  local cart = { }
  
  while state > -1 do
  
    if state == 0 then
      --passing in base_camp_2_juice.boost_tbl as the table of eligible items
      local filter = function(slot) return not not base_camp_2_juice.boost_tbl[slot.ID] end
      local result = InventorySelectMenu.run(STRINGS:FormatKey("MENU_ITEM_TITLE"), filter)
			
	  if #result > 0 then
		cart = result
		state = 1
	  else
		state = -1
	  end
    elseif state == 1 then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Order_Who']))
      local member = TeamSelectMenu.runPartyMenu()
	  
      if member then
	  
		for ii = #cart, 1, -1 do
			if cart[ii].IsEquipped then
				GAME:TakePlayerEquippedItem(cart[ii].Slot, true)
			else
				GAME:TakePlayerBagItem(cart[ii].Slot, true)
			end
		end
		cart = {}

        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Order_Begin']))
		SOUND:PlayBattleSE("DUN_Drink")
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Order_Drink'], member:GetDisplayName(true)))
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Order_Result_None'], member:GetDisplayName(true)))
        state = -1
      else
        state = 0
      end
    end
  
  end
  
end

function base_camp_2_juice.Drink_Specialties_Flow()

end


function base_camp_2_juice.Juice_Shop(obj, activator)

  local state = 0
  local repeated = false
  local chara = CH('Juice_Owner')
  UI:SetSpeaker(chara)
	
  if SV.guildmaster_summit.GameComplete and SV.base_town.JuiceShop == 2 then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Now_Specialty']))
    SV.base_town.JuiceShop = 3
  end
	
	while state > -1 do
		if state == 0 then
			msg = STRINGS:Format(MapStrings['Juice_Intro'])
			if repeated == true then
				msg = STRINGS:Format(MapStrings['Juice_Intro_Return'])
			end
			
			local juice_choices = {}
			juice_choices[1] = STRINGS:Format(MapStrings['Juice_Option_Order'])
			
			
			if has_specialties then
				juice_choices[2] = STRINGS:Format(MapStrings['Juice_Option_Specialties'])
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
					--TODO: use the enum instead of a hardcoded number
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Order'], STRINGS:LocalKeyString(26)))
					base_camp_2_juice.Drink_Order_Flow()
				else
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Bag_Empty']))
				end
			elseif result == 2 then
				base_camp_2_juice.Drink_Specialties_Flow()
			elseif result == 3 then
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Info_001']))
				if SV.base_town.JuiceShop == 3 then
				    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Info_002']))
				end
			else
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Goodbye']))
				state = -1
			end
		end
	end
	
end


return base_camp_2_juice