require 'common'

local base_camp_2 = {}
local MapStrings = {}
--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function base_camp_2.Init(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_base_camp_2")
  MapStrings = COMMON.AutoLoadLocalizedStrings()
  GROUND:RefreshPlayer()
  

  --get assembly ready
  local assemblyCount = GAME:GetPlayerAssemblyCount()
  
  local total = assemblyCount
  if total > 26 then
    total = 26
  end
  
  --Place player teammates
  for i = 1,total,1 do
    GROUND:RemoveCharacter("Assembly" .. tostring(i))
  end
  --TODO: randomly add the spawns
  
  for i = 1,total,1 do
    p = GAME:GetPlayerAssemblyMember(i-1)
    GROUND:SpawnerSetSpawn("ASSEMBLY_" .. tostring(i),p)
    local chara = GROUND:SpawnerDoSpawn("ASSEMBLY_" .. tostring(i))
    --GROUND:GiveCharIdleChatter(chara)
  end
  
  COMMON.CreateWalkArea("Assembly" .. tostring(2), 424, 384, 48, 48)
  COMMON.CreateWalkArea("Assembly" .. tostring(4), 576, 272, 56, 64)
  COMMON.CreateWalkArea("Assembly" .. tostring(5), 336, 208, 64, 80)
  COMMON.CreateWalkArea("Assembly" .. tostring(6), 248, 592, 64, 40)
  COMMON.CreateWalkArea("Assembly" .. tostring(10), 96, 176, 32, 72)
  COMMON.CreateWalkArea("Assembly" .. tostring(12), 216, 256, 48, 64)
  COMMON.CreateWalkArea("Assembly" .. tostring(14), 72, 264, 64, 64)
  COMMON.CreateWalkArea("Assembly" .. tostring(19), 400, 592, 56, 48)
  COMMON.CreateWalkArea("Assembly" .. tostring(22), 728, 352, 64, 48)
  COMMON.CreateWalkArea("Assembly" .. tostring(23), 584, 608, 72, 56)
  
  COMMON.CreateWalkArea("NPC_Food", 144, 592, 32, 32)
  COMMON.CreateWalkArea("NPC_Settling", 344, 288, 48, 48)
  
  local can_talk_to = false
  
  if total >= 3 then
    local talk_to = CH('Assembly3')
    --local tbl = LTBL(talk_to)
	if talk_to.Data.MetLoc.ID > -1 then
	  if base_camp_2.difficulty_tbl[talk_to.Data.MetLoc.ID] ~= -1 then
	    can_talk_to = true
	  end
	end
  end
  
  if can_talk_to then
    local talker = CH('NPC_Interactive')
	GROUND:EntTurn(talker, Direction.UpRight)
  end
  
  if SOUND:GetCurrentSong() ~= SV.base_town.Song then
    SOUND:PlayBGM(SV.base_town.Song, true)
  end
  
  
  GROUND:AddMapStatus(6)
end

function base_camp_2.Enter(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine

  GROUND:Hide("Mission_Board")
  GROUND:Hide("Locator")
  GROUND:Hide("Locator_Owner")
  GAME:FadeIn(20)
end

function base_camp_2.Update(map, time)
end

--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------
function base_camp_2.West_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GAME:FadeOut(false, 20)
  GAME:EnterGroundMap("base_camp", "entrance_east")
end

function base_camp_2.North_Exit_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GAME:FadeOut(false, 20)
  GAME:EnterGroundMap("luminous_spring", "entrance_south")
end

function base_camp_2.Post_Office_Entrance_Touch(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  GAME:FadeOut(false, 20)
  GAME:EnterGroundMap("post_office", "entrance_south", true)
end

function base_camp_2.Mission_Board_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  UI:ResetSpeaker()
  UI:SetCenter(true, true)
  UI:WaitShowDialogue("Try to show a custom menu.[scroll]Are you ready?")
  
  local choices = LUA_ENGINE:MakeGenericType(ListType, { MenuTextChoiceType }, { })
  choices:Add(RogueEssence.Menu.MenuTextChoice("Choice 0", UI:GetChoiceAction(0)))
  choices:Add(RogueEssence.Menu.MenuTextChoice("Choice one", UI:GetChoiceAction(1)))
  choices:Add(RogueEssence.Menu.MenuTextChoice("Choice two", UI:GetChoiceAction(2)))
  choices:Add(RogueEssence.Menu.MenuTextChoice("Choice tres", UI:GetChoiceAction(3)))
  choices:Add(RogueEssence.Menu.MenuTextChoice("Choice quatro", UI:GetChoiceAction(4)))
  choices:Add(RogueEssence.Menu.MenuTextChoice("Choice V", UI:GetChoiceAction(5)))
  choices:Add(RogueEssence.Menu.MenuTextChoice("Choice VI", UI:GetChoiceAction(6)))
  local custom_menu = RogueEssence.Menu.CustomMultiPageMenu(RogueElements.Loc(8, 16), 144, "Custom Menu Test", choices:ToArray(), 5, 4, UI:GetChoiceAction(-1), nil)
  UI:ChooseCustomMenu(custom_menu)
  UI:WaitForChoice()
  local chres = UI:ChoiceResult()
  if chres > -1 then
    UI:WaitShowDialogue("You chose option " .. tostring(chres))
  else
    UI:WaitShowDialogue("You cancelled.")
  end
end

function base_camp_2.Shop_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local state = 0
  local repeated = false
  local cart = {}
  local catalog = { }
  for ii = 1, #SV.base_shop, 1 do
	local base_data = SV.base_shop[ii]
	local item_data = { Item = RogueEssence.Dungeon.InvItem(base_data.Index,false,base_data.Hidden), Price = base_data.Price }
	table.insert(catalog, item_data)
  end
  
  
  local chara = CH('Shop_Owner')
  UI:SetSpeaker(chara)
  
	while state > -1 do
		if state == 0 then
			local msg = STRINGS:Format(MapStrings['Shop_Intro'])
			if repeated == true then
				msg = STRINGS:Format(MapStrings['Shop_Intro_Return'])
			end
			local shop_choices = {STRINGS:Format(MapStrings['Shop_Option_Buy']), STRINGS:Format(MapStrings['Shop_Option_Sell']),
			STRINGS:FormatKey("MENU_INFO"),
			STRINGS:FormatKey("MENU_EXIT")}
			UI:BeginChoiceMenu(msg, shop_choices, 1, 4)
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			repeated = true
			if result == 1 then
				if #catalog > 0 then
					--TODO: use the enum instead of a hardcoded number
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shop_Buy'], STRINGS:LocalKeyString(26)))
					state = 1
				else
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shop_Buy_Empty']))
				end
			elseif result == 2 then
				local bag_count = GAME:GetPlayerBagCount() + GAME:GetPlayerEquippedCount()
				if bag_count > 0 then
					--TODO: use the enum instead of a hardcoded number
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shop_Sell'], STRINGS:LocalKeyString(26)))
					state = 3
				else
					UI:SetSpeakerEmotion("Angry")
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shop_Bag_Empty']))
					UI:SetSpeakerEmotion("Normal")
				end
			elseif result == 3 then
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shop_Info_001']))
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shop_Info_002']))
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shop_Info_003']))
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shop_Info_004']))
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shop_Info_005']))
			else
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shop_Goodbye']))
				state = -1
			end
		elseif state == 1 then
			UI:ShopMenu(catalog)
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			if #result > 0 then
				local bag_count = GAME:GetPlayerBagCount() + GAME:GetPlayerEquippedCount()
				local bag_cap = GAME:GetPlayerBagLimit()
				if bag_count == bag_cap then
					UI:SetSpeakerEmotion("Angry")
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shop_Bag_Full']))
					UI:SetSpeakerEmotion("Normal")
				else
					cart = result
					state = 2
				end
			else
				state = 0
			end
		elseif state == 2 then
			local total = 0
			for ii = 1, #cart, 1 do
				total = total + catalog[cart[ii]].Price
			end
			local msg
			if total > GAME:GetPlayerMoney() then
				UI:SetSpeakerEmotion("Angry")
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shop_Buy_No_Money']))
				UI:SetSpeakerEmotion("Normal")
				state = 1
			else
				if #cart == 1 then
					local name = catalog[cart[1]].Item:GetDisplayName()
					msg = STRINGS:Format(MapStrings['Shop_Buy_One'], STRINGS:FormatKey("MONEY_AMOUNT", total), name)
				else
					msg = STRINGS:Format(MapStrings['Shop_Buy_Multi'], STRINGS:FormatKey("MONEY_AMOUNT", total))
				end
				UI:ChoiceMenuYesNo(msg, false)
				UI:WaitForChoice()
				result = UI:ChoiceResult()
				
				if result then
					GAME:RemoveFromPlayerMoney(total)
					for ii = 1, #cart, 1 do
						local item = catalog[cart[ii]].Item
						GAME:GivePlayerItem(item.ID, 1, false, item.HiddenValue)
					end
					for ii = #cart, 1, -1 do
						table.remove(catalog, cart[ii])
						table.remove(SV.base_shop, cart[ii])
					end
					
					cart = {}
					SOUND:PlayBattleSE("DUN_Money")
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shop_Buy_Complete']))
					state = 0
				else
					state = 1
				end
			end
		elseif state == 3 then
			UI:SellMenu()
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			
			if #result > 0 then
				cart = result
				state = 4
			else
				state = 0
			end
		elseif state == 4 then
			local total = 0
			for ii = 1, #cart, 1 do
				local item
				if cart[ii].IsEquipped then
					item = GAME:GetPlayerEquippedItem(cart[ii].Slot)
				else
					item = GAME:GetPlayerBagItem(cart[ii].Slot)
				end
				total = total + item:GetSellValue()
			end
			local msg
			if #cart == 1 then
				local item
				if cart[1].IsEquipped then
					item = GAME:GetPlayerEquippedItem(cart[1].Slot)
				else
					item = GAME:GetPlayerBagItem(cart[1].Slot)
				end
				msg = STRINGS:Format(MapStrings['Shop_Sell_One'], STRINGS:FormatKey("MONEY_AMOUNT", total), item:GetDisplayName())
			else
				msg = STRINGS:Format(MapStrings['Shop_Sell_Multi'], STRINGS:FormatKey("MONEY_AMOUNT", total))
			end
			UI:ChoiceMenuYesNo(msg, false)
			UI:WaitForChoice()
			result = UI:ChoiceResult()
			
			if result then
				for ii = #cart, 1, -1 do
					if cart[ii].IsEquipped then
						GAME:TakePlayerEquippedItem(cart[ii].Slot)
					else
						GAME:TakePlayerBagItem(cart[ii].Slot)
					end
				end
				SOUND:PlayBattleSE("DUN_Money")
				GAME:AddToPlayerMoney(total)
				cart = {}
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Shop_Sell_Complete']))
				state = 0
			else
				state = 3
			end
		end
	end
end


function base_camp_2.Appraisal_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local state = 0
  local repeated = false
  local cart = {}
  local price = 150
  local chara = CH('Appraisal_Owner')
  UI:SetSpeaker(chara)
	while state > -1 do
		if state == 0 then
			local msg = STRINGS:Format(MapStrings['Appraisal_Intro'], STRINGS:FormatKey("MONEY_AMOUNT", price))
			if repeated == true then
				msg = STRINGS:Format(MapStrings['Appraisal_Return'])
			end
			local shop_choices = {STRINGS:Format(MapStrings['Appraisal_Option_Open']),
			STRINGS:FormatKey("MENU_INFO"),
			STRINGS:FormatKey("MENU_EXIT")}
			UI:BeginChoiceMenu(msg, shop_choices, 1, 3)
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			repeated = true
			if result == 1 then
				local bag_count = GAME:GetPlayerBagCount() + GAME:GetPlayerEquippedCount()
				if bag_count > 0 then
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Appraisal_Choose'], "A"))
					state = 1
				else
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Appraisal_Bag_Empty']))
				end
			elseif result == 2 then
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Appraisal_Info_001']))
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Appraisal_Info_002']))
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Appraisal_Info_003']))
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Appraisal_Info_004'], STRINGS:FormatKey("MONEY_AMOUNT", price)))
			else
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Appraisal_Goodbye']))
				state = -1
			end
		elseif state == 1 then
			UI:AppraiseMenu()
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			
			if #result > 0 then
				cart = result
				state = 2
			else
				state = 0
			end
		elseif state == 2 then
			local total = #cart * price
			
			if total > GAME:GetPlayerMoney() then
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Appraisal_No_Money']))
				state = 1
			else
				local msg
				if #cart == 1 then
					local item
					if cart[1].IsEquipped then
						item = GAME:GetPlayerEquippedItem(cart[1].Slot)
					else
						item = GAME:GetPlayerBagItem(cart[1].Slot)
					end
					msg = STRINGS:Format(MapStrings['Appraisal_Choose_One'], STRINGS:FormatKey("MONEY_AMOUNT", total), item:GetDisplayName())
				else
					msg = STRINGS:Format(MapStrings['Appraisal_Choose_Multi'], STRINGS:FormatKey("MONEY_AMOUNT", total))
				end
				UI:ChoiceMenuYesNo(msg, false)
				UI:WaitForChoice()
				result = UI:ChoiceResult()
				
				local treasure = {}
				if result then
					for ii = #cart, 1, -1 do
						local box = nil
						local stack = 0
						if cart[ii].IsEquipped then
							box = GAME:GetPlayerEquippedItem(cart[ii].Slot)
							GAME:TakePlayerEquippedItem(cart[ii].Slot)
						else
							box = GAME:GetPlayerBagItem(cart[ii].Slot)
							GAME:TakePlayerBagItem(cart[ii].Slot)
						end
						
						local itemEntry = _DATA:GetItem(box.HiddenValue)
						local treasure_choice = { Box = box, Item = RogueEssence.Dungeon.InvItem(box.HiddenValue,false,itemEntry.MaxStack)}
						table.insert(treasure, treasure_choice)
						
						-- note high rarity items
						if itemEntry.Rarity > 0 then
							SV.unlocked_trades[box.HiddenValue] = true
						end
					end
					SOUND:PlayBattleSE("DUN_Money")
					GAME:RemoveFromPlayerMoney(total)
					cart = {}
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Appraisal_Start']))
					
					GROUND:MoveInDirection(chara, Direction.Up, 18, false, 2)
					GROUND:Hide("Appraisal_Owner")
					GAME:WaitFrames(10)
					local shake = RogueEssence.Content.ScreenMover(0, 8, 30)
					GROUND:MoveScreen(shake)
					SOUND:PlayBattleSE("DUN_Explosion")
					GAME:WaitFrames(60)
					GROUND:Unhide("Appraisal_Owner")
					GROUND:MoveInDirection(chara, Direction.Down, 18, false, 2)
					
					SOUND:PlayFanfare("Fanfare/Treasure")
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Appraisal_End']))
					UI:SpoilsMenu(treasure)
					UI:WaitForChoice()
					
					for ii = 1, #treasure, 1 do
						local item = treasure[ii].Item
						
						GAME:GivePlayerItem(item.ID, 1, false, item.HiddenValue)
					end
					
					state = 0
				else
					state = 1
				end
			end
		end
	end
end

function base_camp_2.Compute_Swap_Catalog()
  --silk/dust/gem/globes
  local catalog = { 
	{ Item=702, ReqItem={700,701}},
	{ Item=703, ReqItem={700, 701, 702}},
	{ Item=706, ReqItem={704,705}},
	{ Item=707, ReqItem={704, 705, 706}},
	{ Item=710, ReqItem={708,709}},
	{ Item=711, ReqItem={708, 709, 710}},
	{ Item=714, ReqItem={712,713}},
	{ Item=715, ReqItem={712, 713, 714}},
	{ Item=718, ReqItem={716,717}},
	{ Item=719, ReqItem={716, 717, 718}},
	{ Item=722, ReqItem={720,721}},
	{ Item=723, ReqItem={720, 721, 722}},
	{ Item=726, ReqItem={724,725}},
	{ Item=727, ReqItem={724, 725, 726}},
	{ Item=730, ReqItem={728,729}},
	{ Item=731, ReqItem={728, 729, 730}},
	{ Item=734, ReqItem={732,733}},
	{ Item=735, ReqItem={732, 733, 734}},
	{ Item=738, ReqItem={736,737}},
	{ Item=739, ReqItem={736, 737, 738}},
	{ Item=742, ReqItem={740,741}},
	{ Item=743, ReqItem={740, 741, 742}},
	{ Item=746, ReqItem={744,745}},
	{ Item=747, ReqItem={744, 745, 746}},
	{ Item=750, ReqItem={748,749}},
	{ Item=751, ReqItem={748, 749, 750}},
	{ Item=754, ReqItem={752,753}},
	{ Item=755, ReqItem={752, 753, 754}},
	{ Item=758, ReqItem={756,757}},
	{ Item=759, ReqItem={756, 757, 758}},
	{ Item=762, ReqItem={760,761}},
	{ Item=763, ReqItem={760, 761, 762}},
	{ Item=766, ReqItem={764,765}},
	{ Item=767, ReqItem={764, 765, 766}},
	{ Item=770, ReqItem={768,769}},
	{ Item=771, ReqItem={768, 769, 770}}
}

  --normal trades
  for ii = 1, #COMMON_GEN.TRADES, 1 do
	local base_data = COMMON_GEN.TRADES[ii]
	table.insert(catalog, base_data)
  end
  
  --random trades
  for ii = 1, #SV.base_trades, 1 do
	local base_data = SV.base_trades[ii]
	table.insert(catalog, base_data)
  end
  return catalog
end

function base_camp_2.Swap_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local catalog = base_camp_2.Compute_Swap_Catalog()
  
  local state = 0
  local repeated = false
  local cart = -1 --catalog element chosen to trade for
  local tribute = {} --item IDs chosen to trade in
  

  
  local Prices = { 1000, 5000, 20000, 50000, 100000 }
  local player = CH('PLAYER')
  local chara = CH('Swap_Owner')
  UI:SetSpeaker(chara)
  
	while state > -1 do
		if state == 0 then
			local msg = STRINGS:Format(MapStrings['Swap_Intro'])
			if repeated == true then
				msg = STRINGS:Format(MapStrings['Swap_Intro_Return'])
			end
			local shop_choices = {STRINGS:Format(MapStrings['Swap_Option_Swap']),
			STRINGS:FormatKey("MENU_INFO"),
			STRINGS:FormatKey("MENU_EXIT")}
			UI:BeginChoiceMenu(msg, shop_choices, 1, 3)
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			repeated = true
			if result == 1 then
				state = 1
			elseif result == 2 then
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Swap_Info_001']))
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Swap_Info_002']))
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Swap_Info_003']))
			else
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Swap_Goodbye']))
				state = -1
			end
		elseif state == 1 then
			--only show the items that can be swapped for, checking inv, held, and storage
			--allow trade from storage, and find a way around multi-select for storage.
			if not UI:CanSwapMenu(catalog) then
				UI:SetSpeakerEmotion("Sigh")
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Swap_None']))
				UI:SetSpeaker(chara)
				state = 0
			else
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Swap_Choose']))
				UI:SwapMenu(catalog, Prices)
				UI:WaitForChoice()
				local result = UI:ChoiceResult()
				if result > -1 then
					cart = result
					state = 2
				else
					state = 0
				end
			end
		elseif state == 2 then
			local trade = catalog[cart]
			local receive_item = RogueEssence.Dungeon.InvItem(trade.Item)
			local free_slots = 0
			tribute = {}
			for ii = 1, #trade.ReqItem, 1 do
				if trade.ReqItem[ii] == -1 then
					free_slots = free_slots + 1
				else
					table.insert(tribute, trade.ReqItem[ii])
				end
			end
			
			if free_slots > 0 then
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Swap_Give_Choose'], receive_item:GetDisplayName()))
				--tribute simply aggregates all items period
				--this means that choosing multiple of one item will be impossible
				--must choose all DIFFERENT specific items
				UI:TributeMenu(free_slots)
				UI:WaitForChoice()
				local result = UI:ChoiceResult()
				if #result > 0 then
					for ii = 1, #result, 1 do
						table.insert(tribute, result[ii])
					end
					state = 3
				else
					state = 0
				end
			else
				state = 3
			end
		elseif state == 3 then
			local trade = catalog[cart]
			local receive_item = RogueEssence.Dungeon.InvItem(trade.Item)
			local give_items = {}
			for ii = 1, #tribute, 1 do
				local give_item = RogueEssence.Dungeon.InvItem(tribute[ii])
				table.insert(give_items, give_item:GetDisplayName())
			end
			
			local itemEntry = _DATA:GetItem(trade.Item)
			local total = Prices[itemEntry.Rarity]
			
			UI:WaitShowDialogue(STRINGS:Format(MapStrings['Swap_Confirm_001'], STRINGS:CreateList(give_items), receive_item:GetDisplayName()))
			UI:ChoiceMenuYesNo(STRINGS:Format(MapStrings['Swap_Confirm_002'], STRINGS:FormatKey("MONEY_AMOUNT", total)), false)
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			
			if result then
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
				SOUND:PlayBattleSE("DUN_Money")
				GAME:RemoveFromPlayerMoney(total)
				
				UI:SetSpeakerEmotion("Angry")
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Swap_Complete_001']))
				UI:SetSpeakerEmotion("Stunned")
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Swap_Complete_002']))
				UI:SetSpeakerEmotion("Normal")
				
				UI:ResetSpeaker()
				SOUND:PlayFanfare("Fanfare/Treasure")
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Swap_Give'], player:GetDisplayName(), receive_item:GetDisplayName()))
				
				--local bag_count = GAME:GetPlayerBagCount() + GAME:GetPlayerEquippedCount()
				--local bag_cap = GAME:GetPlayerBagLimit()
				--if bag_count < bag_cap then
				--	GAME:GivePlayerItem(trade.Item, 1, false, 0)
				--else--TODO: load universal strings alongside local strings
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Item_Give_Storage'], receive_item:GetDisplayName()))
				GAME:GivePlayerStorageItem(trade.Item, 1, false, 0)
				--end
				
				UI:SetSpeaker(chara)
				
				--remove the trade if it was a base trade
				local base_trade_idx = cart - (#catalog - #SV.base_trades)
				if base_trade_idx > 0 then
					table.remove(SV.base_trades, base_trade_idx)
				end
				-- recompute the available trades
				catalog = base_camp_2.Compute_Swap_Catalog()
				
				tribute = {}
				cart = -1
				
				state = 0
			else
				state = 1
			end
		end
	end
end

function base_camp_2.Tutor_Sequence(member, moveEntry)

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

function base_camp_2.Tutor_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local price = 500
  local state = 0
  local repeated = false
  local member = nil
  local move = -1
  local chara = CH('Tutor_Owner')
  UI:SetSpeaker(chara)
  
	while state > -1 do
		if state == 0 then
			local msg = STRINGS:Format(MapStrings['Tutor_Intro'], STRINGS:FormatKey("MONEY_AMOUNT", price))
			if repeated == true then
				msg = STRINGS:Format(MapStrings['Tutor_Intro_Return'])
			end
			
			local tutor_choices = {RogueEssence.StringKey("MENU_RECALL_SKILL"):ToLocal(),
			RogueEssence.StringKey("MENU_FORGET_SKILL"):ToLocal(),
			STRINGS:FormatKey("MENU_INFO"),
			STRINGS:FormatKey("MENU_EXIT")}
			UI:BeginChoiceMenu(msg, tutor_choices, 1, 4)
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			repeated = true
			if result == 1 then
				if price > GAME:GetPlayerMoney() then
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_No_Money']))
				else
					state = 1
				end
			elseif result == 2 then
				state = 4
			elseif result == 3 then
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Info_001']))
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Info_002']))
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Info_003']))
			else
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Goodbye']))
				state = -1
			end
		elseif state == 1 then
			UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Remember_Who']))
			UI:TutorTeamMenu()
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			if result > -1 then
				state = 2
				member = GAME:GetPlayerPartyMember(result)
			else
				state = 0
			end
		elseif state == 2 then
			if not GAME:CanRelearn(member) then
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Cant_Remember']))
				state = 1
			else
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Remember_What'], member:GetDisplayName(true)))
				UI:RelearnMenu(member)
				UI:WaitForChoice()
				local result = UI:ChoiceResult()
				if result > -1 then
					move = result
					state = 3
				else
					state = 1
				end
			end
		elseif state == 3 then
			local moveEntry = _DATA:GetSkill(move)
			if GAME:CanLearn(member) then
				SOUND:PlayBattleSE("DUN_Money")
				GAME:RemoveFromPlayerMoney(price)
				GAME:LearnSkill(member, move)
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Remember_Begin']))
				base_camp_2.Tutor_Sequence()
				SOUND:PlayFanfare("Fanfare/LearnSkill")
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Remember_Success'], member:GetDisplayName(true), moveEntry:GetIconName()))
				state = 0
			else
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Remember_Replace']))
				local result = UI:LearnMenu(member, move)
				UI:WaitForChoice()
				local result = UI:ChoiceResult()
				if result > -1 and result < 4 then
					SOUND:PlayBattleSE("DUN_Money")
					GAME:RemoveFromPlayerMoney(price)
					GAME:SetCharacterSkill(member, move, result)
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Remember_Begin']))
					base_camp_2.Tutor_Sequence()	
				    SOUND:PlayFanfare("Fanfare/LearnSkill")
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Remember_Success'], member:GetDisplayName(true), moveEntry:GetIconName()))
					state = 0
				else
					state = 2
				end
			end
		elseif state == 4 then
			UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Forget_Who']))
			UI:TutorTeamMenu()
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			if result > -1 then
				member = GAME:GetPlayerPartyMember(result)
				if not GAME:CanForget(member) then
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Cant_Forget']))
				else
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Forget_What'], member:GetDisplayName(true)))
					state = 5
				end
			else
				state = 0
			end
		elseif state == 5 then
			local result = UI:ForgetMenu(member)
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			if result > -1 then
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Forget_Begin']))
				base_camp_2.Tutor_Sequence()
				move = GAME:GetCharacterSkill(member, result)
				local moveEntry = _DATA:GetSkill(move)
				GAME:ForgetSkill(member, result)
				SOUND:PlayFanfare("Fanfare/LearnSkill")
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Forget_Success'], member:GetDisplayName(true), moveEntry:GetIconName()))
				state = 0
			else
				state = 4
			end
		end
	end
end



function base_camp_2.Locator_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local chara = CH('Locator_Owner')
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Locator_Intro']))
  UI:WaitShowDialogue(STRINGS:Format("We're still setting up![pause=0] Come back later!"))
end

function base_camp_2.Music_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local chara = CH('Music_Owner')
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Music_Intro']))
  local unlocks = {}
  if SV.cliff_camp.ExpositionComplete then
    table.insert(unlocks, "MAIN_001")
  end
  UI:ShowMusicMenu(unlocks)
  UI:WaitForChoice()
  local result = UI:ChoiceResult()
  if result ~= nil then
	SV.base_town.Song = result
  end
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Music_End']))
end


function base_camp_2.Juice_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local chara = CH('Juice_Owner')
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Intro']))
  UI:WaitShowDialogue(STRINGS:Format("We're not open right now...[pause=0] Come back later."))
end


function base_camp_2.NPC_Food_Action(chara, activator)
  local player = CH('PLAYER')
  GROUND:CharTurnToChar(chara,player)
  UI:SetSpeaker(chara)
  if not SV.base_camp.FoodIntro then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Food_Line_001']))
	local receive_item = RogueEssence.Dungeon.InvItem(2)
	COMMON.GiftItem(player, receive_item)
	SV.base_camp.FoodIntro = true
	UI:SetSpeaker(chara)
  end
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Food_Line_002']))
end


function base_camp_2.NPC_Treasure_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Treasure_Line_001']))
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Treasure_Line_002']))
  UI:SetSpeakerEmotion("Happy")
  GROUND:CharSetEmote(chara, 4, 4)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Treasure_Line_003']))
end


function base_camp_2.NPC_Nonbeliever_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Nonbeliever_Line_001']))
  UI:SetSpeakerEmotion("Sigh")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Nonbeliever_Line_002']))
  GROUND:EntTurn(chara, Direction.Right)
end

function base_camp_2.NPC_Catch_1_Action(chara, activator)
  DEBUG.EnableDbgCoro()
  
  base_camp_2.Catch_Action()
end

function base_camp_2.NPC_Catch_2_Action(chara, activator)
  DEBUG.EnableDbgCoro()
  base_camp_2.Catch_Action()
  
end

function base_camp_2.Catch_Action()
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local catch1 = CH('NPC_Catch_1')
  local catch2 = CH('NPC_Catch_2')
  local player = CH('PLAYER')
  local itemAnim = nil
  
  GROUND:CharTurnToChar(player, catch1)
  UI:SetSpeaker(catch1)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Line_001']))
  SOUND:PlayBattleSE("DUN_Throw_Start")
  GROUND:CharSetAnim(catch1, "Rotate", false)
  GAME:WaitFrames(18)
  SOUND:PlayBattleSE("DUN_Throw_Arc")
  itemAnim = RogueEssence.Content.ItemAnim(catch1.MapLoc, catch2.MapLoc, "Rock_Gray", 48, 1)
  GROUND:PlayVFXAnim(itemAnim, RogueEssence.Content.DrawLayer.Normal)
  
  GROUND:CharTurnToChar(player, catch2)
  GAME:WaitFrames(RogueEssence.Content.ItemAnim.ITEM_ACTION_TIME)
	
  SOUND:PlayBattleSE("DUN_Equip")
  UI:SetSpeaker(catch2)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Line_002']))
  SOUND:PlayBattleSE("DUN_Throw_Start")
  GROUND:CharSetAnim(catch2, "Rotate", false)
  GAME:WaitFrames(18)
  SOUND:PlayBattleSE("DUN_Throw_Arc")
  itemAnim = RogueEssence.Content.ItemAnim(catch2.MapLoc, catch1.MapLoc, "Rock_Gray", 48, 1)
  GROUND:PlayVFXAnim(itemAnim, RogueEssence.Content.DrawLayer.Normal)
  
  GROUND:CharTurnToChar(player, catch1)
  GAME:WaitFrames(RogueEssence.Content.ItemAnim.ITEM_ACTION_TIME)
  
  SOUND:PlayBattleSE("DUN_Equip")
  UI:SetSpeaker(catch1)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Line_003']))
  SOUND:PlayBattleSE("DUN_Throw_Start")
  GROUND:CharSetAnim(catch1, "Rotate", false)
  GAME:WaitFrames(18)
  SOUND:PlayBattleSE("DUN_Throw_Arc")
  itemAnim = RogueEssence.Content.ItemAnim(catch1.MapLoc, catch2.MapLoc, "Rock_Gray", 48, 1)
  GROUND:PlayVFXAnim(itemAnim, RogueEssence.Content.DrawLayer.Normal)
  
  GROUND:CharTurnToChar(player, catch2)
  GAME:WaitFrames(RogueEssence.Content.ItemAnim.ITEM_ACTION_TIME)
  
  SOUND:PlayBattleSE("DUN_Equip")
  UI:SetSpeaker(catch2)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Line_004']))
  SOUND:PlayBattleSE("DUN_Throw_Start")
  GROUND:CharSetAnim(catch2, "Rotate", false)
  GAME:WaitFrames(18)
  SOUND:PlayBattleSE("DUN_Throw_Arc")
  itemAnim = RogueEssence.Content.ItemAnim(catch2.MapLoc, catch1.MapLoc, "Rock_Gray", 48, 1)
  GROUND:PlayVFXAnim(itemAnim, RogueEssence.Content.DrawLayer.Normal)
  
  GROUND:CharTurnToChar(player, catch1)
  GAME:WaitFrames(RogueEssence.Content.ItemAnim.ITEM_ACTION_TIME)
  
  SOUND:PlayBattleSE("DUN_Equip")
  UI:SetSpeaker(catch1)
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Line_005']))
end

base_camp_2.difficulty_tbl = { }
base_camp_2.difficulty_tbl[-1] = -1
base_camp_2.difficulty_tbl[0] = 4
base_camp_2.difficulty_tbl[1] = -1
base_camp_2.difficulty_tbl[2] = 0
base_camp_2.difficulty_tbl[3] = 1
base_camp_2.difficulty_tbl[4] = 2
base_camp_2.difficulty_tbl[5] = 3
base_camp_2.difficulty_tbl[6] = 3
base_camp_2.difficulty_tbl[7] = 4
base_camp_2.difficulty_tbl[8] = 4
base_camp_2.difficulty_tbl[9] = 3
base_camp_2.difficulty_tbl[10] = 0
base_camp_2.difficulty_tbl[11] = 3
base_camp_2.difficulty_tbl[12] = 1
base_camp_2.difficulty_tbl[13] = 1
base_camp_2.difficulty_tbl[14] = 3
base_camp_2.difficulty_tbl[15] = 3
base_camp_2.difficulty_tbl[16] = 3
base_camp_2.difficulty_tbl[17] = 3
base_camp_2.difficulty_tbl[18] = 3
base_camp_2.difficulty_tbl[19] = 0
base_camp_2.difficulty_tbl[20] = 1
base_camp_2.difficulty_tbl[21] = 3
base_camp_2.difficulty_tbl[22] = 4
base_camp_2.difficulty_tbl[23] = 4
base_camp_2.difficulty_tbl[24] = 4
base_camp_2.difficulty_tbl[25] = 4
base_camp_2.difficulty_tbl[26] = 4
base_camp_2.difficulty_tbl[27] = 4
base_camp_2.difficulty_tbl[28] = 4
base_camp_2.difficulty_tbl[29] = 4
base_camp_2.difficulty_tbl[30] = 4
base_camp_2.difficulty_tbl[31] = 4
base_camp_2.difficulty_tbl[32] = 4
base_camp_2.difficulty_tbl[33] = 4
base_camp_2.difficulty_tbl[34] = 4
base_camp_2.difficulty_tbl[35] = 0
base_camp_2.difficulty_tbl[36] = 1
base_camp_2.difficulty_tbl[37] = 1
base_camp_2.difficulty_tbl[38] = 4
base_camp_2.difficulty_tbl[39] = 4
base_camp_2.difficulty_tbl[40] = 4
base_camp_2.difficulty_tbl[41] = 4
base_camp_2.difficulty_tbl[42] = 4
base_camp_2.difficulty_tbl[43] = 4
base_camp_2.difficulty_tbl[44] = 4
base_camp_2.difficulty_tbl[45] = 4
base_camp_2.difficulty_tbl[46] = 4
base_camp_2.difficulty_tbl[47] = 4
base_camp_2.difficulty_tbl[48] = 4
base_camp_2.difficulty_tbl[49] = 4

function base_camp_2.NPC_Interactive_Action(chara, activator)
  
  local assemblyCount = GAME:GetPlayerAssemblyCount()
  UI:SetSpeaker(chara)
  
  
  local can_talk_to = false
  if assemblyCount >= 3 then
    talk_to = CH('Assembly3')
    --local tbl = LTBL(talk_to)
	can_talk_to = true
	if base_camp_2.difficulty_tbl[talk_to.Data.MetLoc.ID] == -1 then
	  can_talk_to = false
	else
	  local zone = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone].Entries[talk_to.Data.MetLoc.ID]
	  local zone_name = zone:GetColoredName()
	  local cur_team = _DATA.Save.ActiveTeam.Name
	  if talk_to.Data.OriginalUUID ~= _DATA.Save.UUID then
	    local old_team = talk_to.Data.OriginalTeam
		UI:WaitShowDialogue(STRINGS:Format(MapStrings['Interactive_Trade_Line_001'], cur_team, old_team))
	  elseif base_camp_2.difficulty_tbl[talk_to.Data.MetLoc.ID] == 0 then
	    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Interactive_Phase_001_Line_001'], zone_name, cur_team))
	  elseif base_camp_2.difficulty_tbl[talk_to.Data.MetLoc.ID] == 1 then
	    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Interactive_Phase_002_Line_001'], zone_name, cur_team))
	    UI:SetSpeakerEmotion("Happy")
	    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Interactive_Phase_002_Line_002']))
	  elseif base_camp_2.difficulty_tbl[talk_to.Data.MetLoc.ID] == 2 then
	    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Interactive_Phase_003_Line_001'], zone_name))
	    UI:SetSpeakerEmotion("Sigh")
	    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Interactive_Phase_003_Line_002']))
	  elseif base_camp_2.difficulty_tbl[talk_to.Data.MetLoc.ID] == 3 then
	    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Interactive_Phase_004_Line_001'], zone_name))
	    UI:SetSpeakerEmotion("Happy")
	    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Interactive_Phase_004_Line_002'], cur_team))
	  else
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Interactive_Phase_005_Line_001'], zone_name))
		
        GAME:WaitFrames(30)
        GROUND:CharSetEmote(chara, 8, 1)
        SOUND:PlayBattleSE("EVT_Emote_Shock_Bad")
        GAME:WaitFrames(30)
  
        UI:SetSpeakerEmotion("Surprised")
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Interactive_Phase_005_Line_002'], cur_team))
	  end
	end
  end
  
  if not can_talk_to then
    GROUND:CharTurnToChar(chara,CH('PLAYER'))
	UI:WaitShowDialogue(STRINGS:Format(MapStrings['Interactive_Line_001']))
  end
  
end


function base_camp_2.NPC_Settling_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Settling_Line_001']))
end


function base_camp_2.NPC_Broke_Action(chara, activator)
  UI:SetSpeaker(chara)

  UI:SetSpeakerEmotion("Sad")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Broke_Line_001']))
  GROUND:CharSetEmote(partner, 5, 1)
  SOUND:PlayBattleSE("EVT_Emote_Sweating")
  UI:SetSpeakerEmotion("Crying")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Broke_Line_002']))
end


function base_camp_2.NPC_Hesitant_Action(chara, activator)
  UI:SetSpeaker(chara)

  UI:SetSpeakerEmotion("Sigh")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Hesitant_Line_001']))
end


function base_camp_2.NPC_Elder_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Elder_Line_001']))
end


function base_camp_2.NPC_History_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['History_Line_001']))
  UI:SetSpeakerEmotion("Worried")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['History_Line_002']))
end


function base_camp_2.NPC_Father_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Father_Line_001']))
  GROUND:EntTurn(chara, Direction.DownLeft)
end


function base_camp_2.NPC_Mother_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mother_Line_001']))
  GROUND:EntTurn(chara, Direction.UpRight)
end


function base_camp_2.Assembly1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly4_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly5_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly6_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly7_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly8_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly9_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly10_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly11_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly12_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly13_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly14_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly15_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly16_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly17_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly18_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly19_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly20_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly21_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly22_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly23_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly24_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly25_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly26_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly27_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly28_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly29_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly30_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly31_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly32_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly33_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly34_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly35_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly36_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly37_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly38_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly39_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end

function base_camp_2.Assembly40_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  COMMON.GroundInteract(activator, chara, false)
end




return base_camp_2