require 'origin.common'

local base_camp_2_tutor = require 'origin.ground.base_camp_2.base_camp_2_tutor'
local base_camp_2_juice = require 'origin.ground.base_camp_2.base_camp_2_juice'

local base_camp_2 = {}


--------------------------------------------------
-- Map Callbacks
--------------------------------------------------
function base_camp_2.Init(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  PrintInfo("=>> Init_base_camp_2")

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
  COMMON.CreateWalkArea("Assembly" .. tostring(19), 400, 592, 56, 40)
  COMMON.CreateWalkArea("Assembly" .. tostring(22), 728, 352, 64, 48)
  
  COMMON.CreateWalkArea("NPC_Food", 144, 592, 32, 32)
  COMMON.CreateWalkArea("NPC_Settling", 344, 288, 48, 48)
  
  local can_talk_to = false
  
  if total >= 3 then
    local talk_to = CH('Assembly3')
    --local tbl = LTBL(talk_to)
	if talk_to.Data.MetLoc.ID ~= "" then
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
  
  GROUND:AddMapStatus("clouds_overhead")
end

function base_camp_2.Enter(map)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  base_camp_2.SetupNpcs()
  
  GAME:FadeIn(20)
end

function base_camp_2.Update(map, time)
end

function base_camp_2.SetupNpcs()
  GROUND:Unhide("NPC_Food")
  GROUND:Unhide("NPC_Queen")
  GROUND:Unhide("NPC_King")
  
  
  GROUND:Unhide("NPC_Settling")
  GROUND:Unhide("NPC_Nonbeliever")
  GROUND:Unhide("NPC_Hesitant")

  
  if SV.base_town.JuiceShop == 1 then
    
	local questname = "QuestBug"
    local quest = SV.missions.Missions[questname]
	if quest == nil then
	  local juice = CH('Juice_Owner')
	  GROUND:TeleportTo(juice, 576, 160, Direction.Down)
	end
  end

  if SV.team_hunter.Status == 0 then
    GROUND:Unhide("NPC_Broke")
  elseif SV.team_hunter.Status == 3 then
    -- TODO cycling
  end

  if SV.town_elder.Status == 0 then
    GROUND:Unhide("NPC_Elder")
  elseif SV.town_elder.Status == 3 then
    -- TODO cycling
	GROUND:Unhide("NPC_Elder")
  end

  if SV.team_catch.Status == 0 then
    GROUND:Unhide("NPC_Catch_1")
	GROUND:Unhide("NPC_Catch_2")
  elseif SV.team_catch.Status == 4 then
    -- TODO cycling
    GROUND:Unhide("NPC_Catch_1")
	GROUND:Unhide("NPC_Catch_2")
  end

  if SV.team_solo.Status == 0 then
    GROUND:Unhide("NPC_Solo")
  elseif SV.team_solo.Status == 6 then
    -- TODO cycling
  end

  if SV.supply_corps.Status >= 20 then
	if SV.supply_corps.ManagerCycle == 0 then
	  GROUND:Unhide("NPC_Carry")
	  GROUND:Unhide("NPC_Deliver")
	  GROUND:Unhide("NPC_Storehouse")
	end
  end
  
  -- family appears if Returned = false
  if SV.family.Returned == false then
    -- and if they've been saved individually
    if SV.family.Sister then
	  GROUND:Unhide("Family_Sister")
	end
    if SV.family.Mother then
	  GROUND:Unhide("Family_Mother")
	end
    if SV.family.Father then
	  GROUND:Unhide("Family_Father")
	end
    if SV.family.Brother then
	  GROUND:Unhide("Family_Brother")
	end
    if SV.family.Pet then
	  GROUND:Unhide("Family_Pet")
	end
    if SV.family.Grandma then
	  GROUND:Unhide("Family_Grandma")
	end
  end
end

--------------------------------------------------
-- Objects Callbacks
--------------------------------------------------


function base_camp_2.Family_Sister_Action(obj, activator)
  
  local group_check = base_camp_2.Isekai_Event()
  if group_check then
    return
  end
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Sister_Line_001']))
  GROUND:EntTurn(chara, Direction.DownLeft)
end

function base_camp_2.Family_Mother_Action(obj, activator)

  local group_check = base_camp_2.Isekai_Event()
  if group_check then
    return
  end
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Mother_Line_001']))
  GROUND:EntTurn(chara, Direction.DownLeft)
end

function base_camp_2.Family_Father_Action(obj, activator)

  local group_check = base_camp_2.Isekai_Event()
  if group_check then
    return
  end
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Father_Line_001']))
  GROUND:EntTurn(chara, Direction.DownLeft)
end

function base_camp_2.Family_Brother_Action(obj, activator)

  local group_check = base_camp_2.Isekai_Event()
  if group_check then
    return
  end
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Brother_Line_001']))
  GROUND:EntTurn(chara, Direction.DownLeft)
end

function base_camp_2.Family_Pet_Action(obj, activator)

  local group_check = base_camp_2.Isekai_Event()
  if group_check then
    return
  end
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Pet_Line_001']))
  GROUND:EntTurn(chara, Direction.DownLeft)
end

function base_camp_2.Family_Grandma_Action(obj, activator)

  local group_check = base_camp_2.Isekai_Event()
  if group_check then
    return
  end
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Grandma_Line_001']))
  GROUND:EntTurn(chara, Direction.DownLeft)
end

function base_camp_2.Isekai_Event()
  
  if SV.family.TalkedReturn == false then
    if SV.guild_hut.TookCard then
		UI:ResetSpeaker()
		SV.family.TalkedReturn = true
		UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Isekai_Line_001']))
		GAME:FadeOut(false, 20)
		GAME:FadeIn(20)
		return true
	end
  else
    if SV.family.Sister and SV.family.Mother and SV.family.Father and SV.family.Brother and SV.family.Pet and SV.family.Grandma then
		UI:ResetSpeaker()
		SV.family.Returned = true
		UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Isekai_Line_002']))
		GAME:FadeOut(false, 20)
		GAME:EnterGroundMap("guild_hut", "entrance_portal", false)
	  return true
	end
  end
  
  return false
end

function base_camp_2.NPC_Food_Action(chara, activator)
  local player = CH('PLAYER')
  GROUND:CharTurnToChar(chara,player)
  UI:SetSpeaker(chara)
  if not SV.base_camp.FoodIntro then
    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Food_Line_001']))
	local receive_item = RogueEssence.Dungeon.InvItem("food_apple_big")
	COMMON.GiftItem(player, receive_item)
	SV.base_camp.FoodIntro = true
  end
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Food_Line_002']))
end


function base_camp_2.NPC_Treasure_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Treasure_Line_001']))
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Treasure_Line_002']))
  UI:SetSpeakerEmotion("Happy")
  GROUND:CharSetEmote(chara, "glowing", 4)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Treasure_Line_003']))
end


function base_camp_2.NPC_Nonbeliever_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Nonbeliever_Line_001']))
  UI:SetSpeakerEmotion("Sigh")
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Nonbeliever_Line_002']))
  GROUND:EntTurn(chara, Direction.Right)
end


function base_camp_2.NPC_Storehouse_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Storehouse_Line_Route']))
end

function base_camp_2.NPC_Settling_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Settling_Line_001']))
end


function base_camp_2.NPC_Broke_Action(chara, activator)
  UI:SetSpeaker(chara)

  UI:SetSpeakerEmotion("Sad")
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Broke_Line_001']))
  GROUND:CharSetEmote(partner, "sweating", 1)
  SOUND:PlayBattleSE("EVT_Emote_Sweating")
  UI:SetSpeakerEmotion("Crying")
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Broke_Line_002']))
  
  if SV.Experimental then
    SV.team_hunter.SpokenTo = true
  end
end


function base_camp_2.NPC_Hesitant_Action(chara, activator)
  UI:SetSpeaker(chara)

  UI:SetSpeakerEmotion("Sigh")
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Hesitant_Line_001']))
end


function base_camp_2.NPC_Elder_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Elder_Line_001']))
  
  if SV.Experimental then
    SV.town_elder.SpokenTo = true
  end
  
  --TODO: make him do something else after his mission?
  
end


function base_camp_2.NPC_Solo_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Solo_Line_001']))
  UI:SetSpeakerEmotion("Worried")
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Solo_Line_002']))
  
  
  SV.team_solo.SpokenTo = true
  
end


function base_camp_2.NPC_King_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['King_Line_001']))
  GROUND:EntTurn(chara, Direction.DownLeft)
end


function base_camp_2.NPC_Queen_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Queen_Line_001']))
  GROUND:EntTurn(chara, Direction.UpRight)
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
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Catch_Line_001']))
  SOUND:PlayBattleSE("DUN_Throw_Start")
  GROUND:CharSetAnim(catch1, "Rotate", false)
  GAME:WaitFrames(18)
  SOUND:PlayBattleSE("DUN_Throw_Arc")
  itemAnim = RogueEssence.Content.ItemAnim(catch1.Bounds.Center, catch2.Bounds.Center, "Rock_Gray", 48, 1)
  GROUND:PlayVFXAnim(itemAnim, RogueEssence.Content.DrawLayer.Normal)
  
  GROUND:CharTurnToChar(player, catch2)
  GAME:WaitFrames(RogueEssence.Content.ItemAnim.ITEM_ACTION_TIME)
	
  SOUND:PlayBattleSE("DUN_Equip")
  UI:SetSpeaker(catch2)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Catch_Line_002']))
  SOUND:PlayBattleSE("DUN_Throw_Start")
  GROUND:CharSetAnim(catch2, "Rotate", false)
  GAME:WaitFrames(18)
  SOUND:PlayBattleSE("DUN_Throw_Arc")
  itemAnim = RogueEssence.Content.ItemAnim(catch2.Bounds.Center, catch1.Bounds.Center, "Rock_Gray", 48, 1)
  GROUND:PlayVFXAnim(itemAnim, RogueEssence.Content.DrawLayer.Normal)
  
  GROUND:CharTurnToChar(player, catch1)
  GAME:WaitFrames(RogueEssence.Content.ItemAnim.ITEM_ACTION_TIME)
  
  SOUND:PlayBattleSE("DUN_Equip")
  UI:SetSpeaker(catch1)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Catch_Line_003']))
  SOUND:PlayBattleSE("DUN_Throw_Start")
  GROUND:CharSetAnim(catch1, "Rotate", false)
  GAME:WaitFrames(18)
  SOUND:PlayBattleSE("DUN_Throw_Arc")
  itemAnim = RogueEssence.Content.ItemAnim(catch1.Bounds.Center, catch2.Bounds.Center, "Rock_Gray", 48, 1)
  GROUND:PlayVFXAnim(itemAnim, RogueEssence.Content.DrawLayer.Normal)
  
  GROUND:CharTurnToChar(player, catch2)
  GAME:WaitFrames(RogueEssence.Content.ItemAnim.ITEM_ACTION_TIME)
  
  SOUND:PlayBattleSE("DUN_Equip")
  UI:SetSpeaker(catch2)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Catch_Line_004']))
  SOUND:PlayBattleSE("DUN_Throw_Start")
  GROUND:CharSetAnim(catch2, "Rotate", false)
  GAME:WaitFrames(18)
  SOUND:PlayBattleSE("DUN_Throw_Arc")
  itemAnim = RogueEssence.Content.ItemAnim(catch2.Bounds.Center, catch1.Bounds.Center, "Rock_Gray", 48, 1)
  GROUND:PlayVFXAnim(itemAnim, RogueEssence.Content.DrawLayer.Normal)
  
  GROUND:CharTurnToChar(player, catch1)
  GAME:WaitFrames(RogueEssence.Content.ItemAnim.ITEM_ACTION_TIME)
  
  SOUND:PlayBattleSE("DUN_Equip")
  UI:SetSpeaker(catch1)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Catch_Line_005']))
  
  
  if SV.Experimental then
    SV.team_catch.SpokenTo = true
  end
  
  
  -- TODO cycling
end

base_camp_2.difficulty_tbl = { }
base_camp_2.difficulty_tbl["debug_zone"] = 4
base_camp_2.difficulty_tbl["guildmaster_island"] = -1
base_camp_2.difficulty_tbl["tropical_path"] = 0
base_camp_2.difficulty_tbl["faded_trail"] = 1
base_camp_2.difficulty_tbl["flyaway_cliffs"] = 2
base_camp_2.difficulty_tbl["thunderstruck_pass"] = 3
base_camp_2.difficulty_tbl["veiled_ridge"] = 3
base_camp_2.difficulty_tbl["champions_road"] = 4
base_camp_2.difficulty_tbl["cave_of_whispers"] = 4
base_camp_2.difficulty_tbl["moonlit_courtyard"] = 3
base_camp_2.difficulty_tbl["faultline_ridge"] = 0
base_camp_2.difficulty_tbl["trickster_woods"] = 1
base_camp_2.difficulty_tbl["moonlit_courtyard"] = 3
base_camp_2.difficulty_tbl["sleeping_caldera"] = 3
base_camp_2.difficulty_tbl["lava_floe_island"] = 1
base_camp_2.difficulty_tbl["castaway_cave"] = 3
base_camp_2.difficulty_tbl["fertile_valley"] = 1
base_camp_2.difficulty_tbl["ambush_forest"] = 3
base_camp_2.difficulty_tbl["treacherous_mountain"] = 3
base_camp_2.difficulty_tbl["copper_quarry"] = 3
base_camp_2.difficulty_tbl["depleted_basin"] = 3
base_camp_2.difficulty_tbl["forsaken_desert"] = 3
base_camp_2.difficulty_tbl["snowbound_path"] = 3
base_camp_2.difficulty_tbl["relic_tower"] = 3
base_camp_2.difficulty_tbl["guildmaster_trail"] = 0
base_camp_2.difficulty_tbl["overgrown_wilds"] = 1
base_camp_2.difficulty_tbl["wayward_wetlands"] = 3
base_camp_2.difficulty_tbl["secret_garden"] = 4
base_camp_2.difficulty_tbl["cave_of_solace"] = 4
base_camp_2.difficulty_tbl["royal_halls"] = 4
base_camp_2.difficulty_tbl["the_sky"] = 4
base_camp_2.difficulty_tbl["the_abyss"] = 4
base_camp_2.difficulty_tbl["training_maze"] = 0
base_camp_2.difficulty_tbl["bramble_woods"] = 1
base_camp_2.difficulty_tbl["sickly_hollow"] = 1

function base_camp_2.NPC_Interactive_Action(chara, activator)
  
  local assemblyCount = GAME:GetPlayerAssemblyCount()
  UI:SetSpeaker(chara)
  
  
  local can_talk_to = false
  if assemblyCount >= 3 then
    talk_to = CH('Assembly3')
    --local tbl = LTBL(talk_to)
	can_talk_to = true
	if base_camp_2.difficulty_tbl[talk_to.Data.MetLoc.ID] == nil then
	  can_talk_to = false
	else
	  local zone = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(talk_to.Data.MetLoc.ID)
	  local zone_name = zone:GetColoredName()
	  local cur_team = _DATA.Save.ActiveTeam.Name
	  if talk_to.Data.OriginalUUID ~= _DATA.Save.UUID then
	    local old_team = talk_to.Data.OriginalTeam
		UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Interactive_Trade_Line_001'], cur_team, old_team))
	  elseif base_camp_2.difficulty_tbl[talk_to.Data.MetLoc.ID] == 0 then
	    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Interactive_Phase_001_Line_001'], zone_name, cur_team))
	  elseif base_camp_2.difficulty_tbl[talk_to.Data.MetLoc.ID] == 1 then
	    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Interactive_Phase_002_Line_001'], zone_name, cur_team))
	    UI:SetSpeakerEmotion("Happy")
	    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Interactive_Phase_002_Line_002']))
	  elseif base_camp_2.difficulty_tbl[talk_to.Data.MetLoc.ID] == 2 then
	    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Interactive_Phase_003_Line_001'], zone_name))
	    UI:SetSpeakerEmotion("Sigh")
	    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Interactive_Phase_003_Line_002']))
	  elseif base_camp_2.difficulty_tbl[talk_to.Data.MetLoc.ID] == 3 then
	    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Interactive_Phase_004_Line_001'], zone_name))
	    UI:SetSpeakerEmotion("Happy")
	    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Interactive_Phase_004_Line_002'], cur_team))
	  else
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Interactive_Phase_005_Line_001'], zone_name))
		
        GAME:WaitFrames(30)
        GROUND:CharSetEmote(chara, "shock", 1)
        SOUND:PlayBattleSE("EVT_Emote_Shock_Bad")
        GAME:WaitFrames(30)
  
        UI:SetSpeakerEmotion("Surprised")
        UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Interactive_Phase_005_Line_002'], cur_team))
	  end
	end
  end
  
  if not can_talk_to then
    GROUND:CharTurnToChar(chara,CH('PLAYER'))
	UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Interactive_Line_001']))
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
	local item_data = { Item = RogueEssence.Dungeon.InvItem(base_data.Index, false, base_data.Amount), Price = base_data.Price }
	table.insert(catalog, item_data)
  end
  
  
  local chara = CH('Shop_Owner')
  UI:SetSpeaker(chara)
  
	while state > -1 do
		if state == 0 then
			local msg = STRINGS:Format(STRINGS.MapStrings['Shop_Intro'])
			if repeated == true then
				msg = STRINGS:Format(STRINGS.MapStrings['Shop_Intro_Return'])
			end
			local shop_choices = {STRINGS:Format(STRINGS.MapStrings['Shop_Option_Buy']), STRINGS:Format(STRINGS.MapStrings['Shop_Option_Sell']),
			STRINGS:FormatKey("MENU_INFO"),
			STRINGS:FormatKey("MENU_EXIT")}
			UI:BeginChoiceMenu(msg, shop_choices, 1, 4)
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			repeated = true
			if result == 1 then
				if #catalog > 0 then
					--TODO: use the enum instead of a hardcoded number
					UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shop_Buy'], STRINGS:LocalKeyString(26)))
					state = 1
				else
					UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shop_Buy_Empty']))
				end
			elseif result == 2 then
				local bag_count = GAME:GetPlayerBagCount() + GAME:GetPlayerEquippedCount()
				if bag_count > 0 then
					--TODO: use the enum instead of a hardcoded number
					UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shop_Sell'], STRINGS:LocalKeyString(26)))
					state = 3
				else
					UI:SetSpeakerEmotion("Angry")
					UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shop_Bag_Empty']))
					UI:SetSpeakerEmotion("Normal")
				end
			elseif result == 3 then
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shop_Info_001']))
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shop_Info_002']))
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shop_Info_003']))
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shop_Info_004']))
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shop_Info_005']))
			else
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shop_Goodbye']))
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
					UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shop_Bag_Full']))
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
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shop_Buy_No_Money']))
				UI:SetSpeakerEmotion("Normal")
				state = 1
			else
				if #cart == 1 then
					local name = catalog[cart[1]].Item:GetDisplayName()
					msg = STRINGS:Format(STRINGS.MapStrings['Shop_Buy_One'], STRINGS:FormatKey("MONEY_AMOUNT", total), name)
				else
					msg = STRINGS:Format(STRINGS.MapStrings['Shop_Buy_Multi'], STRINGS:FormatKey("MONEY_AMOUNT", total))
				end
				UI:ChoiceMenuYesNo(msg, false)
				UI:WaitForChoice()
				result = UI:ChoiceResult()
				
				if result then
					GAME:RemoveFromPlayerMoney(total)
					for ii = 1, #cart, 1 do
						local item = catalog[cart[ii]].Item
						GAME:GivePlayerItem(item.ID, item.Amount, false)
					end
					for ii = #cart, 1, -1 do
						table.remove(catalog, cart[ii])
						table.remove(SV.base_shop, cart[ii])
					end
					
					cart = {}
					SOUND:PlayBattleSE("DUN_Money")
					UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shop_Buy_Complete']))
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
				msg = STRINGS:Format(STRINGS.MapStrings['Shop_Sell_One'], STRINGS:FormatKey("MONEY_AMOUNT", total), item:GetDisplayName())
			else
				msg = STRINGS:Format(STRINGS.MapStrings['Shop_Sell_Multi'], STRINGS:FormatKey("MONEY_AMOUNT", total))
			end
			UI:ChoiceMenuYesNo(msg, false)
			UI:WaitForChoice()
			result = UI:ChoiceResult()
			
			if result then
				for ii = #cart, 1, -1 do
					if cart[ii].IsEquipped then
						GAME:TakePlayerEquippedItem(cart[ii].Slot, true)
					else
						GAME:TakePlayerBagItem(cart[ii].Slot, true)
					end
				end
				SOUND:PlayBattleSE("DUN_Money")
				GAME:AddToPlayerMoney(total)
				cart = {}
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Shop_Sell_Complete']))
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
			local msg = STRINGS:Format(STRINGS.MapStrings['Appraisal_Intro'], STRINGS:FormatKey("MONEY_AMOUNT", price))
			if repeated == true then
				msg = STRINGS:Format(STRINGS.MapStrings['Appraisal_Return'])
			end
			local shop_choices = {STRINGS:Format(STRINGS.MapStrings['Appraisal_Option_Open']),
			STRINGS:FormatKey("MENU_INFO"),
			STRINGS:FormatKey("MENU_EXIT")}
			UI:BeginChoiceMenu(msg, shop_choices, 1, 3)
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			repeated = true
			if result == 1 then
				local bag_count = GAME:GetPlayerBagCount() + GAME:GetPlayerEquippedCount()
				if bag_count > 0 then
					UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Appraisal_Choose'], STRINGS:LocalKeyString(26)))
					state = 1
				else
					UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Appraisal_Bag_Empty']))
				end
			elseif result == 2 then
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Appraisal_Info_001']))
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Appraisal_Info_002']))
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Appraisal_Info_003']))
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Appraisal_Info_004'], STRINGS:FormatKey("MONEY_AMOUNT", price)))
			else
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Appraisal_Goodbye']))
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
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Appraisal_No_Money']))
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
					msg = STRINGS:Format(STRINGS.MapStrings['Appraisal_Choose_One'], STRINGS:FormatKey("MONEY_AMOUNT", total), item:GetDisplayName())
				elseif #cart < 24 then
					msg = STRINGS:Format(STRINGS.MapStrings['Appraisal_Choose_Multi'], STRINGS:FormatKey("MONEY_AMOUNT", total))
				else
					UI:SetSpeakerEmotion("Surprised")
					msg = STRINGS:Format(STRINGS.MapStrings['Appraisal_Choose_Max'], STRINGS:FormatKey("MONEY_AMOUNT", total))
					
				end
				UI:ChoiceMenuYesNo(msg, false)
				UI:WaitForChoice()
				result = UI:ChoiceResult()
				
				UI:SetSpeakerEmotion("Normal")
				
				local treasure = {}
				if result then
					for ii = #cart, 1, -1 do
						local box = nil
						local stack = 0
						if cart[ii].IsEquipped then
							box = GAME:GetPlayerEquippedItem(cart[ii].Slot)
							GAME:TakePlayerEquippedItem(cart[ii].Slot, true)
						else
							box = GAME:GetPlayerBagItem(cart[ii].Slot)
							GAME:TakePlayerBagItem(cart[ii].Slot, true)
						end
						
						local treasure_item = box.HiddenValue
						local itemEntry = _DATA:GetItem(treasure_item)
						local treasure_choice = { Box = box, Item = RogueEssence.Dungeon.InvItem(treasure_item,false,itemEntry.MaxStack)}
						table.insert(treasure, treasure_choice)
						
						-- note high rarity items
						if itemEntry.Rarity > 0 then
							SV.unlocked_trades[treasure_item] = true
						end
					end
					SOUND:PlayBattleSE("DUN_Money")
					GAME:RemoveFromPlayerMoney(total)
					cart = {}
					
					if #treasure >= 24 then
					  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Appraisal_Start_Max']))
					
					  GROUND:MoveInDirection(chara, Direction.Up, 18, false, 2)
					  GROUND:Hide("Appraisal_Owner")
					  GAME:WaitFrames(10)
					  local shake = RogueEssence.Content.ScreenMover(0, 12, 20)
					  GROUND:MoveScreen(shake)
					  SOUND:PlayBattleSE("DUN_Explosion")
					  GAME:WaitFrames(30)
					  shake = RogueEssence.Content.ScreenMover(0, 12, 20)
					  GROUND:MoveScreen(shake)
					  SOUND:PlayBattleSE("DUN_Explosion")
					  GAME:WaitFrames(30)
					  shake = RogueEssence.Content.ScreenMover(0, 12, 20)
					  GROUND:MoveScreen(shake)
					  SOUND:PlayBattleSE("DUN_Explosion")
					  GAME:WaitFrames(30)
					  shake = RogueEssence.Content.ScreenMover(0, 12, 50)
					  GROUND:MoveScreen(shake)
					  SOUND:PlayBattleSE("DUN_Explosion")
					  GAME:WaitFrames(10)
					  SOUND:PlayBattleSE("DUN_Explosion")
					  GAME:WaitFrames(10)
					  SOUND:PlayBattleSE("DUN_Explosion")
					  GAME:WaitFrames(10)
					  shake = RogueEssence.Content.ScreenMover(0, 16, 30)
					  GROUND:MoveScreen(shake)
					  SOUND:PlayBattleSE("DUN_Explosion")
					  GAME:WaitFrames(10)
					  local coro1 = TASK:BranchCoroutine(GAME:_FadeOut(true, 30))
					  SOUND:PlayBattleSE("DUN_Explosion")
					  GAME:WaitFrames(10)
					  shake = RogueEssence.Content.ScreenMover(0, 20, 30)
					  GROUND:MoveScreen(shake)
					  SOUND:PlayBattleSE("DUN_Explosion")
					  GAME:WaitFrames(10)
					  SOUND:PlayBattleSE("DUN_Explosion")
					  TASK:JoinCoroutines({coro1})
					  GAME:WaitFrames(30)
					  
					  emitter = RogueEssence.Content.StaticAreaEmitter(RogueEssence.Content.AnimData("Smoke_White", 3))
					  emitter.Range = 72
					  emitter.Bursts = 30
					  emitter.BurstTime = 2
					  emitter.ParticlesPerBurst = 1
					  GROUND:PlayVFX(emitter, chara.MapLoc.X, chara.MapLoc.Y - 32)
					  
					  GAME:WaitFrames(30)
					  GAME:FadeIn(60)
					  GROUND:Unhide("Appraisal_Owner")
					  GROUND:MoveInDirection(chara, Direction.Down, 36, false, 1)
					  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Appraisal_End_Max_001']))
					  SOUND:PlayFanfare("Fanfare/Treasure")
					  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Appraisal_End_Max_002']))
					
					elseif #treasure >= 8 then
					  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Appraisal_Start_002']))
					
					  GROUND:MoveInDirection(chara, Direction.Up, 18, false, 2)
					  GROUND:Hide("Appraisal_Owner")
					  GAME:WaitFrames(20)
					  local shake = RogueEssence.Content.ScreenMover(0, 12, 30)
					  GROUND:MoveScreen(shake)
					  SOUND:PlayBattleSE("DUN_Explosion")
					  GAME:WaitFrames(10)
					  SOUND:PlayBattleSE("DUN_Explosion")
					  GAME:WaitFrames(10)
					  SOUND:PlayBattleSE("DUN_Explosion")
					  GAME:WaitFrames(60)
					  GROUND:Unhide("Appraisal_Owner")
					  GROUND:MoveInDirection(chara, Direction.Down, 18, false, 2)
					  SOUND:PlayFanfare("Fanfare/Treasure")
					  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Appraisal_End']))
					else
					  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Appraisal_Start_001']))
					
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
					  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Appraisal_End']))
					end

					UI:SpoilsMenu(treasure)
					UI:WaitForChoice()
					
					for ii = 1, #treasure, 1 do
						local item = treasure[ii].Item
						
						GAME:GivePlayerItem(item.ID, item.Amount, false, item.HiddenValue)
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
	{ Item="xcl_element_bug_gem", ReqItem={"xcl_element_bug_silk","xcl_element_bug_dust"}},
	{ Item="xcl_element_bug_globe", ReqItem={"xcl_element_bug_silk", "xcl_element_bug_dust", "xcl_element_bug_gem"}},
	{ Item="xcl_element_dark_gem", ReqItem={"xcl_element_dark_silk","xcl_element_dark_dust"}},
	{ Item="xcl_element_dark_globe", ReqItem={"xcl_element_dark_silk", "xcl_element_dark_dust", "xcl_element_dark_gem"}},
	{ Item="xcl_element_dragon_gem", ReqItem={"xcl_element_dragon_silk","xcl_element_dragon_dust"}},
	{ Item="xcl_element_dragon_globe", ReqItem={"xcl_element_dragon_silk", "xcl_element_dragon_dust", "xcl_element_dragon_gem"}},
	{ Item="xcl_element_electric_gem", ReqItem={"xcl_element_electric_silk","xcl_element_electric_dust"}},
	{ Item="xcl_element_electric_globe", ReqItem={"xcl_element_electric_silk", "xcl_element_electric_dust", "xcl_element_electric_gem"}},
	{ Item="xcl_element_fairy_gem", ReqItem={"xcl_element_fairy_silk","xcl_element_fairy_dust"}},
	{ Item="xcl_element_fairy_globe", ReqItem={"xcl_element_fairy_silk", "xcl_element_fairy_dust", "xcl_element_fairy_gem"}},
	{ Item="xcl_element_fighting_gem", ReqItem={"xcl_element_fighting_silk","xcl_element_fighting_dust"}},
	{ Item="xcl_element_fighting_globe", ReqItem={"xcl_element_fighting_silk", "xcl_element_fighting_dust", "xcl_element_fighting_gem"}},
	{ Item="xcl_element_fire_gem", ReqItem={"xcl_element_fire_silk","xcl_element_fire_dust"}},
	{ Item="xcl_element_fire_globe", ReqItem={"xcl_element_fire_silk", "xcl_element_fire_dust", "xcl_element_fire_gem"}},
	{ Item="xcl_element_flying_gem", ReqItem={"xcl_element_flying_silk","xcl_element_flying_dust"}},
	{ Item="xcl_element_flying_globe", ReqItem={"xcl_element_flying_silk", "xcl_element_flying_dust", "xcl_element_flying_gem"}},
	{ Item="xcl_element_ghost_gem", ReqItem={"xcl_element_ghost_silk","xcl_element_ghost_dust"}},
	{ Item="xcl_element_ghost_globe", ReqItem={"xcl_element_ghost_silk", "xcl_element_ghost_dust", "xcl_element_ghost_gem"}},
	{ Item="xcl_element_grass_gem", ReqItem={"xcl_element_grass_silk","xcl_element_grass_dust"}},
	{ Item="xcl_element_grass_globe", ReqItem={"xcl_element_grass_silk", "xcl_element_grass_dust", "xcl_element_grass_gem"}},
	{ Item="xcl_element_ground_gem", ReqItem={"xcl_element_ground_silk","xcl_element_ground_dust"}},
	{ Item="xcl_element_ground_globe", ReqItem={"xcl_element_ground_silk", "xcl_element_ground_dust", "xcl_element_ground_gem"}},
	{ Item="xcl_element_ice_gem", ReqItem={"xcl_element_ice_silk","xcl_element_ice_dust"}},
	{ Item="xcl_element_ice_globe", ReqItem={"xcl_element_ice_silk", "xcl_element_ice_dust", "xcl_element_ice_gem"}},
	{ Item="xcl_element_normal_gem", ReqItem={"xcl_element_normal_silk","xcl_element_normal_dust"}},
	{ Item="xcl_element_normal_globe", ReqItem={"xcl_element_normal_silk", "xcl_element_normal_dust", "xcl_element_normal_gem"}},
	{ Item="xcl_element_poison_gem", ReqItem={"xcl_element_poison_silk","xcl_element_poison_dust"}},
	{ Item="xcl_element_poison_globe", ReqItem={"xcl_element_poison_silk", "xcl_element_poison_dust", "xcl_element_poison_gem"}},
	{ Item="xcl_element_psychic_gem", ReqItem={"xcl_element_psychic_silk","xcl_element_psychic_dust"}},
	{ Item="xcl_element_psychic_globe", ReqItem={"xcl_element_psychic_silk", "xcl_element_psychic_dust", "xcl_element_psychic_gem"}},
	{ Item="xcl_element_rock_gem", ReqItem={"xcl_element_rock_silk","xcl_element_rock_dust"}},
	{ Item="xcl_element_rock_globe", ReqItem={"xcl_element_rock_silk", "xcl_element_rock_dust", "xcl_element_rock_gem"}},
	{ Item="xcl_element_steel_gem", ReqItem={"xcl_element_steel_silk","xcl_element_steel_dust"}},
	{ Item="xcl_element_steel_globe", ReqItem={"xcl_element_steel_silk", "xcl_element_steel_dust", "xcl_element_steel_gem"}},
	{ Item="xcl_element_water_gem", ReqItem={"xcl_element_water_silk","xcl_element_water_dust"}},
	{ Item="xcl_element_water_globe", ReqItem={"xcl_element_water_silk", "xcl_element_water_dust", "xcl_element_water_gem"}}
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
  
  -- for special case when spoken to after forgetting to hold up their end of the trade, one off gag
  if SV.base_town.ValueTradeItem ~= "" then
    state = 4
	repeated = true
  end

  
  local Prices = { 1000, 5000, 25000 }
  local player = CH('PLAYER')
  local chara = CH('Swap_Owner')
  UI:SetSpeaker(chara)
  
	while state > -1 do
		if state == 0 then
			local msg = STRINGS:Format(STRINGS.MapStrings['Swap_Intro'])
			if repeated == true then
				msg = STRINGS:Format(STRINGS.MapStrings['Swap_Intro_Return'])
			end
			local shop_choices = {STRINGS:Format(STRINGS.MapStrings['Swap_Option_Swap']),
			STRINGS:FormatKey("MENU_INFO"),
			STRINGS:FormatKey("MENU_EXIT")}
			UI:BeginChoiceMenu(msg, shop_choices, 1, 3)
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			repeated = true
			if result == 1 then
				state = 1
			elseif result == 2 then
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Swap_Info_001']))
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Swap_Info_002']))
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Swap_Info_003']))
			else
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Swap_Goodbye']))
				state = -1
			end
		elseif state == 1 then
			--only show the items that can be swapped for, checking inv, held, and storage
			--allow trade from storage, and find a way around multi-select for storage.
			if not UI:CanSwapMenu(catalog) then
				UI:SetSpeakerEmotion("Sigh")
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Swap_None']))
				UI:SetSpeaker(chara)
				state = 0
			else
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Swap_Choose']))
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
				if trade.ReqItem[ii] == "" then
					free_slots = free_slots + 1
				else
					table.insert(tribute, trade.ReqItem[ii])
				end
			end
			
			if free_slots > 0 then
				UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Swap_Give_Choose'], receive_item:GetDisplayName()))
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
			
			UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Swap_Confirm_001'], STRINGS:CreateList(give_items), receive_item:GetDisplayName()))
			UI:ChoiceMenuYesNo(STRINGS:Format(STRINGS.MapStrings['Swap_Confirm_002'], STRINGS:FormatKey("MONEY_AMOUNT", total)), false)
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
				
				
				--remove the trade if it was a base trade
				local base_trade_idx = cart - (#catalog - #SV.base_trades)
				if base_trade_idx > 0 then
					table.remove(SV.base_trades, base_trade_idx)
				end
				
				SV.base_town.ValueTradeItem = trade.Item
				if itemEntry.Rarity == 3 then
				  UI:SetSpeakerEmotion("Inspired")
				  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Swap_Complete_Max_001']))
				  
				  -- sableye gets so obsessed with his treasure he forgets about you, once
				  if SV.base_town.ValueTraded == false then
				    UI:SetSpeakerEmotion("Joyous")
				    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Swap_Complete_Max_002']))
				    return
				  end
				end
				
				state = 4
			else
				state = 1
			end
				
		elseif state == 4 then
			
			local itemEntry = _DATA:GetItem(SV.base_town.ValueTradeItem)
			if itemEntry.Rarity == 3 then
			  if SV.base_town.ValueTraded == false then
			  
			    SOUND:PlayBattleSE("EVT_Emote_Exclaim_2")
			    GROUND:CharSetEmote(chara, "exclaim", 1)
			    UI:SetSpeakerEmotion("Stunned")
			  
			    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Swap_Complete_Max_003']))
			    UI:SetSpeakerEmotion("Normal")
			  else
				
			    UI:SetSpeakerEmotion("Happy")
			    UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Swap_Complete_Max_004']))
			    UI:SetSpeakerEmotion("Normal")
			  end
			  SV.base_town.ValueTraded = true
			  
			else
			  UI:SetSpeakerEmotion("Normal")
			  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Swap_Complete']))
			end
			
			local receive_item = RogueEssence.Dungeon.InvItem(SV.base_town.ValueTradeItem)
			UI:ResetSpeaker()
			SOUND:PlayFanfare("Fanfare/Treasure")
			UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Swap_Give'], player:GetDisplayName(), receive_item:GetDisplayName()))
			
			UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Item_Give_Storage'], receive_item:GetDisplayName()))
			GAME:GivePlayerStorageItem(SV.base_town.ValueTradeItem, 1, false, "")
			
			UI:SetSpeaker(chara)
			
			-- recompute the available trades
			catalog = base_camp_2.Compute_Swap_Catalog()
			SV.base_town.ValueTradeItem = ""
			
			tribute = {}
			cart = -1
			
			state = 0
		end
	end
end


function base_camp_2.Locator_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local chara = CH('Locator_Owner')
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Locator_Intro']))
  UI:WaitShowDialogue(STRINGS:Format("We're still setting up![pause=0] Come back later!"))
end

base_camp_2.music_tbl = { }
base_camp_2.music_tbl["Aftermath 2.ogg"] = { "GUILDMASTER" }
base_camp_2.music_tbl["Aftermath.ogg"] = { "GUILDMASTER" }
base_camp_2.music_tbl["Ambush Forest 2.ogg"] = { "DUN_ambush_forest" }
base_camp_2.music_tbl["Ambush Forest 3.ogg"] = { "DUN_ambush_forest" }
base_camp_2.music_tbl["Ambush Forest.ogg"] = { "DUN_ambush_forest" }
base_camp_2.music_tbl["Base Town.ogg"] = { "MAIN_00" }
base_camp_2.music_tbl["Boss Battle 2.ogg"] = { "MAIN_01" }
base_camp_2.music_tbl["Boss Battle.ogg"] = { "GUILDMASTER" }
base_camp_2.music_tbl["Bramble Thicket.ogg"] = { "DUN_bramble_woods" }
base_camp_2.music_tbl["Bramble Woods.ogg"] = { "DUN_bramble_woods" }
base_camp_2.music_tbl["Canyon Camp.ogg"] = { "MAIN_03" }
base_camp_2.music_tbl["Castaway Cave 2.ogg"] = { "DUN_castaway_cave" }
base_camp_2.music_tbl["Castaway Cave.ogg"] = { "DUN_castaway_cave" }
base_camp_2.music_tbl["Cave Camp.ogg"] = { "MAIN_04" }
base_camp_2.music_tbl["Champion Road 2.ogg"] = { "DUN_champions_road", "DUN_guildmaster_trail" }
base_camp_2.music_tbl["Champion Road.ogg"] = { "GUILDMASTER" }
base_camp_2.music_tbl["Cliff Camp.ogg"] = { "MAIN_02" }
base_camp_2.music_tbl["Copper Quarry.ogg"] = { "DUN_copper_quarry" }
base_camp_2.music_tbl["Demonstration 2.ogg"] = { "MAIN_00" }
base_camp_2.music_tbl["Demonstration 3.ogg"] = { "DUN_secret_garden" }
base_camp_2.music_tbl["Demonstration.ogg"] = { "MAIN_00" }
base_camp_2.music_tbl["Depleted Basin.ogg"] = { "DUN_depleted_basin" }
base_camp_2.music_tbl["Enraged Caldera.ogg"] = { "DUN_sleeping_caldera" }
base_camp_2.music_tbl["Faded Trail.ogg"] = { "DUN_faded_trail" }
base_camp_2.music_tbl["Faultline Ridge.ogg"] = { "DUN_faultline_ridge", "DUN_guildmaster_trail" }
base_camp_2.music_tbl["Fertile Valley.ogg"] = { "DUN_fertile_valley" }
base_camp_2.music_tbl["Final Battle.ogg"] = { "GUILDMASTER" }
base_camp_2.music_tbl["Flyaway Cliffs.ogg"] = { "DUN_flyaway_cliffs", "DUN_guildmaster_trail" }
base_camp_2.music_tbl["Forsaken Desert.ogg"] = { "DUN_forsaken_desert" }
base_camp_2.music_tbl["Glacial Path.ogg"] = { "DUN_snowbound_path", "DUN_guildmaster_trail" }
base_camp_2.music_tbl["Guildmaster.ogg"] = { "GUILDMASTER" }
base_camp_2.music_tbl["Lava Floe Island Fire.ogg"] = { "DUN_lava_floe_island" }
base_camp_2.music_tbl["Lava Floe Island Water.ogg"] = { "DUN_lava_floe_island" }
base_camp_2.music_tbl["Luminous Spring.ogg"] = { "MAIN_00" }
base_camp_2.music_tbl["Magnetic Quarry.ogg"] = { "DUN_copper_quarry" }
base_camp_2.music_tbl["Monster House.ogg"] = { "MAIN_04" }
base_camp_2.music_tbl["Muddy Valley.ogg"] = { "DUN_fertile_valley", "DUN_sleeping_caldera" }
base_camp_2.music_tbl["Mysterious Passage 2.ogg"] = { "GUILDMASTER" }
base_camp_2.music_tbl["Mysterious Passage.ogg"] = { "GUILDMASTER" }
base_camp_2.music_tbl["Outlaw.ogg"] = { "MAIN_03" }
base_camp_2.music_tbl["Overgrown Wilds.ogg"] = { "DUN_overgrown_wilds", "DUN_secret_garden" }
base_camp_2.music_tbl["Relic Tower.ogg"] = { "DUN_relic_tower", "DUN_moonlit_courtyard" }
base_camp_2.music_tbl["Rescue.ogg"] = { "MAIN_00" }
base_camp_2.music_tbl["Shop.ogg"] = { "MAIN_03" }
base_camp_2.music_tbl["Sickly Hollow 2.ogg"] = { "DUN_sickly_hollow" }
base_camp_2.music_tbl["Sickly Hollow.ogg"] = { "DUN_sickly_hollow", "DUN_veiled_ridge" }
base_camp_2.music_tbl["Snow Camp.ogg"] = { "MAIN_05" }
base_camp_2.music_tbl["Snowbound Path.ogg"] = { "DUN_snowbound_path" }
base_camp_2.music_tbl["Summit.ogg"] = { "GUILDMASTER" }
base_camp_2.music_tbl["Threat.ogg"] = { "MAIN_04" }
base_camp_2.music_tbl["Thunderstruck Pass.ogg"] = { "DUN_thunderstruck_pass" }
base_camp_2.music_tbl["Title.ogg"] = { "MAIN_00" }
base_camp_2.music_tbl["Treacherous Mountain 2.ogg"] = { "DUN_treacherous_mountain" }
base_camp_2.music_tbl["Treacherous Mountain 3.ogg"] = { "DUN_treacherous_mountain" }
base_camp_2.music_tbl["Treacherous Mountain.ogg"] = { "DUN_treacherous_mountain" }
base_camp_2.music_tbl["Trickster Woods.ogg"] = { "DUN_trickster_woods", "DUN_secret_garden" }
base_camp_2.music_tbl["Tropical Path.ogg"] = { "DUN_tropical_path" }
base_camp_2.music_tbl["Veiled Ridge.ogg"] = { "DUN_veiled_ridge" }
base_camp_2.music_tbl["Wind.ogg"] = { "MAIN_05" }


function base_camp_2.Music_Action(obj, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  local chara = CH('Music_Owner')
  UI:SetSpeaker(chara)
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Music_Intro']))
  local unlocks = {}
  unlocks["MAIN_00"] = true
  if SV.forest_camp.ExpositionComplete then
    unlocks["MAIN_01"] = true
  end
  if SV.cliff_camp.ExpositionComplete then
    unlocks["MAIN_02"] = true
  end
  if SV.canyon_camp.ExpositionComplete then
    unlocks["MAIN_03"] = true
  end
  if SV.rest_stop.ExpositionComplete then
    unlocks["MAIN_04"] = true
  end
  if SV.final_stop.ExpositionComplete then
    unlocks["MAIN_05"] = true
  end
  if SV.guildmaster_summit.GameComplete then
    unlocks["GUILDMASTER"] = true
  end
  
  zones = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:GetOrderedKeys(false)
  for zone_idx = 0, zones.Count - 1, 1  do
    zone = zones[zone_idx]
    if _DATA.Save:GetDungeonUnlock(zone) == RogueEssence.Data.GameProgress.UnlockState.Completed then
      unlocks["DUN_" .. zone] = true
    end
  end
  
  
  local spoilers = {}
  for key, unlock_reqs in pairs(base_camp_2.music_tbl) do
    contains_unlock = false
    for ii = 1,#unlock_reqs,1 do
      if unlocks[unlock_reqs[ii]] == true then
        contains_unlock = true
      end
    end
    if not contains_unlock then
      table.insert(spoilers, key)
    end
  end
  
  
  UI:ShowMusicMenu(false, spoilers)
  UI:WaitForChoice()
  local result = UI:ChoiceResult()
  if result ~= nil then
	SV.base_town.Song = result
  end
  UI:WaitShowDialogue(STRINGS:Format(STRINGS.MapStrings['Music_End']))
end

function base_camp_2.Tutor_Action(obj, activator)
  base_camp_2_tutor.Tutor_Action(obj, activator)
end

function base_camp_2.Juice_Action(obj, activator)
  local chara = CH('Juice_Owner')
  base_camp_2_juice.Juice_Owner_Action(chara, activator)
end

function base_camp_2.Juice_Owner_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2_juice.Juice_Owner_Action(chara, activator)
end



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

function base_camp_2.AssemblyInteract(chara, target)
  GROUND:CharTurnToChar(target, chara)
  UI:SetSpeaker(target)
  
  local mon = _DATA:GetMonster(target.CurrentForm.Species)
  local form = mon.Forms[target.CurrentForm.Form]
  
  local personality = form:GetPersonalityType(target.Data.Discriminator)
  
  local talk_string = nil
  
  --TODO: accept variations of the talkstrings (VAR_XX)
  --look for a talkstring of this species, form, gender
  if talk_string == nil then
    local var_key = string.format("TALK_REST_%04d_%02d_%02d_VAR_00", mon.IndexNum, target.CurrentForm.Form, LUA_ENGINE:EnumToNumeric(target.CurrentForm.Gender))
    if RogueEssence.Text.StringsEx:ContainsKey(var_key) then
      talk_string = RogueEssence.Text.StringsEx[var_key]
    end
  end
  
  if talk_string == nil then
    --if talkstring is nil, look for a talkstring of this species, form
	local var_key = string.format("TALK_REST_%04d_%02d_VAR_00", mon.IndexNum, target.CurrentForm.Form)
    if RogueEssence.Text.StringsEx:ContainsKey(var_key) then
      talk_string = RogueEssence.Text.StringsEx[var_key]
    end
  end
  
  if talk_string == nil then
    --if talkstring is nil, look for a talkstring of this species
	local var_key = string.format("TALK_REST_%04d_VAR_00", mon.IndexNum)
    if RogueEssence.Text.StringsEx:ContainsKey(var_key) then
      talk_string = RogueEssence.Text.StringsEx[var_key]
    end
  end
  
  if talk_string == nil then
    --if talkstring is still nil, fall back to groundinteract
	COMMON.GroundInteract(chara, target)
  else
    --otherwise, print the talkstring
	UI:WaitShowDialogue(STRINGS:Format(talk_string))
  end
  
  
end


function base_camp_2.Assembly1_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly2_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly3_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly4_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly5_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly6_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly7_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly8_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly9_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly10_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly11_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly12_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly13_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly14_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly15_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly16_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly17_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly18_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly19_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly20_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly21_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly22_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly23_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly24_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly25_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly26_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly27_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly28_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly29_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly30_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly31_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly32_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly33_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly34_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly35_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly36_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly37_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly38_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly39_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end

function base_camp_2.Assembly40_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  base_camp_2.AssemblyInteract(activator, chara)
end




return base_camp_2