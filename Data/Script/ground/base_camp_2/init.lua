require 'common'
require 'mission_gen'
require 'menu.SkillSelectMenu'
require 'menu.SkillTutorMenu'

local base_camp_2 = {}
local MapStrings = {}

MissionBoardStateType = luanet.import_type('PMDC.Dungeon.MissionBoardState')
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

  local mission_table = _DATA.UniversalEvent.UniversalStates:GetWithDefault(luanet.ctype(MissionBoardStateType))
  if mission_table == nil or mission_table.EnableMissionBoard == false then
      GROUND:Hide("Mission_Board")
  end
    
  GROUND:Hide("Locator")
  GROUND:Hide("Locator_Owner")

  if SV.TemporaryFlags.MissionCompleted then
    base_camp_2.Hand_In_Missions()
  end  
    
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

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Sister_Line_001']))
  GROUND:EntTurn(chara, Direction.DownLeft)
end

function base_camp_2.Family_Mother_Action(obj, activator)

  local group_check = base_camp_2.Isekai_Event()
  if group_check then
    return
  end
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mother_Line_001']))
  GROUND:EntTurn(chara, Direction.DownLeft)
end

function base_camp_2.Family_Father_Action(obj, activator)

  local group_check = base_camp_2.Isekai_Event()
  if group_check then
    return
  end
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Father_Line_001']))
  GROUND:EntTurn(chara, Direction.DownLeft)
end

function base_camp_2.Family_Brother_Action(obj, activator)

  local group_check = base_camp_2.Isekai_Event()
  if group_check then
    return
  end
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Brother_Line_001']))
  GROUND:EntTurn(chara, Direction.DownLeft)
end

function base_camp_2.Family_Pet_Action(obj, activator)

  local group_check = base_camp_2.Isekai_Event()
  if group_check then
    return
  end
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Pet_Line_001']))
  GROUND:EntTurn(chara, Direction.DownLeft)
end

function base_camp_2.Family_Grandma_Action(obj, activator)

  local group_check = base_camp_2.Isekai_Event()
  if group_check then
    return
  end
  
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Grandma_Line_001']))
  GROUND:EntTurn(chara, Direction.DownLeft)
end

function base_camp_2.Isekai_Event()
  
  if SV.family.TalkedReturn == false then
    if SV.guild_hut.TookCard then
		UI:ResetSpeaker()
		SV.family.TalkedReturn = true
		UI:WaitShowDialogue(STRINGS:Format(MapStrings['Isekai_Line_001']))
		GAME:FadeOut(false, 20)
		GAME:FadeIn(20)
		return true
	end
  else
    if SV.family.Sister and SV.family.Mother and SV.family.Father and SV.family.Brother and SV.family.Pet and SV.family.Grandma then
		UI:ResetSpeaker()
		SV.family.Returned = true
		UI:WaitShowDialogue(STRINGS:Format(MapStrings['Isekai_Line_002']))
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
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Food_Line_001']))
	local receive_item = RogueEssence.Dungeon.InvItem("food_apple_big")
	COMMON.GiftItem(player, receive_item)
	SV.base_camp.FoodIntro = true
  end
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Food_Line_002']))
end


function base_camp_2.NPC_Treasure_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Treasure_Line_001']))
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Treasure_Line_002']))
  UI:SetSpeakerEmotion("Happy")
  GROUND:CharSetEmote(chara, "glowing", 4)
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


function base_camp_2.NPC_Storehouse_Action(chara, activator)
  DEBUG.EnableDbgCoro() --Enable debugging this coroutine
  
  local player = CH('PLAYER')
  UI:SetSpeaker(chara)
  
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Storehouse_Line_Route']))
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
  GROUND:CharSetEmote(partner, "sweating", 1)
  SOUND:PlayBattleSE("EVT_Emote_Sweating")
  UI:SetSpeakerEmotion("Crying")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Broke_Line_002']))
  
  if SV.Experimental then
    SV.team_hunter.SpokenTo = true
  end
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
  
  if SV.Experimental then
    SV.town_elder.SpokenTo = true
  end
  
  --TODO: make him do something else after his mission?
  
end


function base_camp_2.NPC_Solo_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Solo_Line_001']))
  UI:SetSpeakerEmotion("Worried")
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Solo_Line_002']))
  
  
  SV.team_solo.SpokenTo = true
  
end


function base_camp_2.NPC_King_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['King_Line_001']))
  GROUND:EntTurn(chara, Direction.DownLeft)
end


function base_camp_2.NPC_Queen_Action(chara, activator)
  GROUND:CharTurnToChar(chara,CH('PLAYER'))
  UI:SetSpeaker(chara)

  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Queen_Line_001']))
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
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Line_001']))
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
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Line_002']))
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
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Line_003']))
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
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Line_004']))
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
  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Catch_Line_005']))
  
  
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
        GROUND:CharSetEmote(chara, "shock", 1)
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
						GAME:GivePlayerItem(item.ID, item.Amount, false)
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
						GAME:TakePlayerEquippedItem(cart[ii].Slot, true)
					else
						GAME:TakePlayerBagItem(cart[ii].Slot, true)
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
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Appraisal_Choose'], STRINGS:LocalKeyString(26)))
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
				elseif #cart < 24 then
					msg = STRINGS:Format(MapStrings['Appraisal_Choose_Multi'], STRINGS:FormatKey("MONEY_AMOUNT", total))
				else
					UI:SetSpeakerEmotion("Surprised")
					msg = STRINGS:Format(MapStrings['Appraisal_Choose_Max'], STRINGS:FormatKey("MONEY_AMOUNT", total))
					
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
					  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Appraisal_Start_Max']))
					
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
					  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Appraisal_End_Max_001']))
					  SOUND:PlayFanfare("Fanfare/Treasure")
					  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Appraisal_End_Max_002']))
					
					elseif #treasure >= 8 then
					  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Appraisal_Start_002']))
					
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
					  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Appraisal_End']))
					else
					  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Appraisal_Start_001']))
					
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
				if trade.ReqItem[ii] == "" then
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
				
				
				--remove the trade if it was a base trade
				local base_trade_idx = cart - (#catalog - #SV.base_trades)
				if base_trade_idx > 0 then
					table.remove(SV.base_trades, base_trade_idx)
				end
				
				SV.base_town.ValueTradeItem = trade.Item
				if itemEntry.Rarity == 5 then
				  UI:SetSpeakerEmotion("Inspired")
				  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Swap_Complete_Max_001']))
				  
				  -- sableye gets so obsessed with his treasure he forgets about you, once
				  if SV.base_town.ValueTraded == false then
				    UI:SetSpeakerEmotion("Joyous")
				    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Swap_Complete_Max_002']))
				    return
				  end
				end
				
				state = 4
			else
				state = 1
			end
				
		elseif state == 4 then
			
			local itemEntry = _DATA:GetItem(SV.base_town.ValueTradeItem)
			if itemEntry.Rarity == 5 then
			  if SV.base_town.ValueTraded == false then
			  
			    SOUND:PlayBattleSE("EVT_Emote_Exclaim_2")
			    GROUND:CharSetEmote(chara, "exclaim", 1)
			    UI:SetSpeakerEmotion("Stunned")
			  
			    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Swap_Complete_Max_003']))
			    UI:SetSpeakerEmotion("Normal")
			  else
				
			    UI:SetSpeakerEmotion("Happy")
			    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Swap_Complete_Max_004']))
			    UI:SetSpeakerEmotion("Normal")
			  end
			  SV.base_town.ValueTraded = true
			  
			else
			  UI:SetSpeakerEmotion("Normal")
			  UI:WaitShowDialogue(STRINGS:Format(MapStrings['Swap_Complete']))
			end
			
			local receive_item = RogueEssence.Dungeon.InvItem(SV.base_town.ValueTradeItem)
			UI:ResetSpeaker()
			SOUND:PlayFanfare("Fanfare/Treasure")
			UI:WaitShowDialogue(STRINGS:Format(MapStrings['Swap_Give'], player:GetDisplayName(), receive_item:GetDisplayName()))
			
			UI:WaitShowDialogue(STRINGS:Format(MapStrings['Item_Give_Storage'], receive_item:GetDisplayName()))
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

function base_camp_2.Tutor_Sequence()

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


function base_camp_2.Tutor_Can_Remember(member)
  return GAME:CanRelearn(member)
end

function base_camp_2.Tutor_Can_Forget(member)
  return GAME:CanForget(member)
end

function base_camp_2.Tutor_Can_Tutor(member, tutor_moves)
  
  local valid_moves = COMMON.GetTutorableMoves(member, tutor_moves)
	for move_idx, skill in pairs(valid_moves) do
		return true
	end
  
  return false
end


function base_camp_2.Tutor_Remember_Flow(price)
    
	local state = 0
  local member = nil
  local move = ""
	
	if price > GAME:GetPlayerMoney() then
		UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_No_Money']))
		return
	end
    
	while state > -1 do
		if state == 0 then
			UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Remember_Who']))
			UI:TutorTeamMenu(base_camp_2.Tutor_Can_Remember)
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			if result > -1 then
				state = 1
				member = GAME:GetPlayerPartyMember(result)
			else
				state = -1
			end
		elseif state == 1 then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Remember_What'], member:GetDisplayName(true)))
      local result = SkillSelectMenu.runRelearnMenu(member)
      if result ~= "" then
        move = result
        state = 2
      else
        state = 0
      end
		elseif state == 2 then
        local moveEntry = _DATA:GetSkill(move)
		    local learnedMove = COMMON.LearnMoveFlow(member, move, STRINGS:Format(MapStrings['Tutor_Remember_Replace']))
			
			if learnedMove then
				if price > 0 then
				  SOUND:PlayBattleSE("DUN_Money")
				  GAME:RemoveFromPlayerMoney(price)
				end
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Remember_Begin']))
				base_camp_2.Tutor_Sequence()
				SOUND:PlayFanfare("Fanfare/LearnSkill")
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Remember_Success'], member:GetDisplayName(true), moveEntry:GetIconName()))
				state = -1
			else
				state = 1
			end
		end
	end
end


function base_camp_2.Tutor_Forget_Flow()
  local state = 0
  local member = nil
  local move = ""
  
  while state > -1 do
  
    if state == 0 then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Forget_Who']))
      UI:TutorTeamMenu(base_camp_2.Tutor_Can_Forget)
      UI:WaitForChoice()
      local result = UI:ChoiceResult()
      if result > -1 then
        member = GAME:GetPlayerPartyMember(result)
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Forget_What'], member:GetDisplayName(true)))
        state = 1
      else
        state = -1
      end
    elseif state == 1 then
      UI:ForgetMenu(member)
      UI:WaitForChoice()
      local result = UI:ChoiceResult()
      if result > -1 then
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Forget_Begin']))
        move = GAME:GetCharacterSkill(member, result)
        local moveEntry = _DATA:GetSkill(move)
        GAME:ForgetSkill(member, result)
        base_camp_2.Tutor_Sequence()
        SOUND:PlayFanfare("Fanfare/LearnSkill")
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Forget_Success'], member:GetDisplayName(true), moveEntry:GetIconName()))
        state = -1
      else
        state = 0
      end
    end
  
  end
  
end


function base_camp_2.Tutor_Teach_Flow(tutor_moves)
    
	local state = 0
    local member = nil
    local move = ""
	
	while state > -1 do
		if state == 0 then
			UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Teach_Who']))
			UI:TutorTeamMenu(function(chara) return base_camp_2.Tutor_Can_Tutor(chara, tutor_moves) end)
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			if result > -1 then
				state = 1
				member = GAME:GetPlayerPartyMember(result)
			else
				state = -1
			end
		elseif state == 1 then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Teach_What'], member:GetDisplayName(true)))
	  local valid_moves = COMMON.GetTutorableMoves(member, tutor_moves) --moved out here
	  local result = SkillTutorMenu.runTutorMenu(valid_moves, "loot_heart_scale")
      if result ~= "" then
        move = result
        state = 2
      else
        state = 0
      end
		elseif state == 2 then
      local moveEntry = _DATA:GetSkill(move)
			local learnedMove = COMMON.LearnMoveFlow(member, move, STRINGS:Format(MapStrings['Tutor_Remember_Replace']))
			
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
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Remember_Begin']))
				base_camp_2.Tutor_Sequence()
				SOUND:PlayFanfare("Fanfare/LearnSkill")
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Teach_Success'], member:GetDisplayName(true), moveEntry:GetIconName()))
				state = -1
			else
				state = 1
			end
		end
	end
end

function base_camp_2.Tutor_Action(obj, activator)
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
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Now_Free']))
    SV.base_town.FreeRelearn = true
  end
  
  if can_tutor and SV.base_town.TutorOpen == false then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Now_Teaches']))
	SV.base_town.TutorOpen = true
  end
  
  if SV.base_town.FreeRelearn then
    price = 0
  end
  
  
	while state > -1 do
		if state == 0 then
			local msg = STRINGS:Format(MapStrings['Tutor_Intro'], STRINGS:FormatKey("MONEY_AMOUNT", price))
			if price == 0 then
			  msg = STRINGS:Format(MapStrings['Tutor_Intro_Free'])
			end
			
			if repeated == true then
				msg = STRINGS:Format(MapStrings['Tutor_Intro_Return'])
			end
			
			local tutor_choices = {}
			tutor_choices[1] = RogueEssence.StringKey("MENU_RECALL_SKILL"):ToLocal()
			tutor_choices[2] = RogueEssence.StringKey("MENU_FORGET_SKILL"):ToLocal()
			
			if can_tutor then
				tutor_choices[3] = STRINGS:Format(MapStrings['Tutor_Option_Tutor'])
			end
			
			tutor_choices[4] = STRINGS:FormatKey("MENU_INFO")
			tutor_choices[5] = STRINGS:FormatKey("MENU_EXIT")
			
			UI:BeginChoiceMenu(msg, tutor_choices, 1, 5)
			
			UI:WaitForChoice()
			local result = UI:ChoiceResult()
			
			repeated = true
			if result == 1 then
			    base_camp_2.Tutor_Remember_Flow(price)
			elseif result == 2 then
				base_camp_2.Tutor_Forget_Flow()
			elseif result == 3 then
			    base_camp_2.Tutor_Teach_Flow(tutor_moves)
			elseif result == 4 then
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Info_001']))
				if SV.base_town.FreeRelearn then
				    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Info_003']))
				else
				    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Info_002']))
				end
				if SV.base_town.TutorOpen then
				    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Info_004']))
				end
			else
				UI:WaitShowDialogue(STRINGS:Format(MapStrings['Tutor_Goodbye']))
				state = -1
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
  local chara = CH('Juice_Owner')
  base_camp_2.Juice_Owner_Action(chara, activator)
end

function base_camp_2.Juice_Owner_Action(chara, activator)
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
      base_camp_2.Bug_Complete()
    end
  end
  
  elseif SV.base_town.JuiceShop >= 2 then

    base_camp_2.Juice_Shop(obj, activator)

  end
  
end

function base_camp_2.Bug_Complete()
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

base_camp_2.boost_tbl = { }
--{ Level = 0, EXP = 100, HP = 0, Atk = 0, Def = 0, SpAtk = 0, SpDef = 0, Speed = 0, NegateExp = false, NegateStat = false }
base_camp_2.boost_tbl["food_apple"] = { EXP = 100 }
base_camp_2.boost_tbl["food_apple_big"] = { EXP = 300 }
base_camp_2.boost_tbl["food_apple_huge"] = { EXP = 1000 }
base_camp_2.boost_tbl["food_apple_perfect"] = { EXP = 5000 }
base_camp_2.boost_tbl["food_apple_golden"] = { EXP = 25000 }
base_camp_2.boost_tbl["food_banana"] = { EXP = 500 }
base_camp_2.boost_tbl["food_banana_big"] = { EXP = 2500 }
base_camp_2.boost_tbl["food_banana_golden"] = { EXP = 100000 }
base_camp_2.boost_tbl["berry_oran"] = { HP = 1 }
base_camp_2.boost_tbl["berry_leppa"] = { HP = 1 }
base_camp_2.boost_tbl["berry_sitrus"] = { HP = 1 }
base_camp_2.boost_tbl["berry_lum"] = { HP = 1 }
base_camp_2.boost_tbl["berry_starf"] = { HP = 2 }
base_camp_2.boost_tbl["berry_liechi"] = { Atk = 2 }
base_camp_2.boost_tbl["berry_ganlon"] = { Def = 2 }
base_camp_2.boost_tbl["berry_petaya"] = { SpAtk = 2 }
base_camp_2.boost_tbl["berry_apicot"] = { SpDef = 2 }
base_camp_2.boost_tbl["berry_salac"] = { Speed = 2 }
base_camp_2.boost_tbl["berry_enigma"] = { HP = 1 }
base_camp_2.boost_tbl["berry_micle"] = { Atk = 1, SpAtk = 1 }
base_camp_2.boost_tbl["boost_nectar"] = { HP = 1, Atk = 1, Def = 1, SpAtk = 1, SpDef = 1, Speed = 1 }
base_camp_2.boost_tbl["boost_hp_up"] = { HP = 4 }
base_camp_2.boost_tbl["boost_protein"] = { Atk = 4 }
base_camp_2.boost_tbl["boost_iron"] = { Def = 4 }
base_camp_2.boost_tbl["boost_calcium"] = { SpAtk = 4 }
base_camp_2.boost_tbl["boost_zinc"] = { SpDef = 4 }
base_camp_2.boost_tbl["boost_carbos"] = { Speed = 4 }
base_camp_2.boost_tbl["seed_joy"] = { Level = 1 }
base_camp_2.boost_tbl["seed_golden"] = { Level = 5 }
base_camp_2.boost_tbl["seed_doom"] = { Level = -5 }
base_camp_2.boost_tbl["food_grimy"] = { NegateExp = true }
base_camp_2.boost_tbl["herb_white"] = { NegateStat = true }
base_camp_2.boost_tbl["herb_power"] = { NegateStat = true }
base_camp_2.boost_tbl["herb_mental"] = { NegateStat = true }

function base_camp_2.Drink_Order_Flow()

  local catalog = { }

  local state = 0
  local member = nil
  local cart = { }
  
  while state > -1 do
  
    if state == 0 then
	  --pass in base_camp_2.boost_tbl as the table of eligible items
	  UI:SellMenu()
	  UI:WaitForChoice()
	  local result = UI:ChoiceResult()
			
	  if #result > 0 then
		cart = result
		state = 1
	  else
		state = -1
	  end
    elseif state == 1 then
      UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Order_Who']))
      UI:TutorTeamMenu(base_camp_2.Tutor_Can_Forget)
      UI:WaitForChoice()
      local result = UI:ChoiceResult()
	  
      if result > -1 then
	  
		for ii = #cart, 1, -1 do
			if cart[ii].IsEquipped then
				GAME:TakePlayerEquippedItem(cart[ii].Slot, true)
			else
				GAME:TakePlayerBagItem(cart[ii].Slot, true)
			end
		end
		cart = {}
	  
	    member = GAME:GetPlayerPartyMember(result)
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

function base_camp_2.Drink_Specialties_Flow()

end


function base_camp_2.Juice_Shop(obj, activator)

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
					base_camp_2.Drink_Order_Flow()
				else
					UI:WaitShowDialogue(STRINGS:Format(MapStrings['Juice_Bag_Empty']))
				end
			elseif result == 2 then
				base_camp_2.Drink_Specialties_Flow()
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


--Allows mission gen to work here
function base_camp_2.Mission_Board_Action(obj, activator)
    DEBUG.EnableDbgCoro() --Enable debugging this coroutine
    local dungeons_needed = 3 --Number of dungeons needed to unlock the Mission Board
    
    local hero = CH('PLAYER')
    GROUND:CharSetAnim(hero, 'None', true)
    
    if SV.MissionPrereq.NumDungeonsCompleted >= dungeons_needed then
        local menu = BoardSelectionMenu:new(COMMON.MISSION_BOARD_MISSION)
        UI:SetCustomMenu(menu.menu)
        UI:WaitForChoice()
    else
        UI:ResetSpeaker()
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Board_Locked']))
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Board_Locked_2'], dungeons_needed - SV.MissionPrereq.NumDungeonsCompleted))
    end

    GROUND:CharEndAnim(hero)
end

function base_camp_2.Hand_In_Missions()
    for i = 8, 1, -1 do
        if SV.TakenBoard[i].Client ~= "" and SV.TakenBoard[i].Completion == MISSION_GEN.COMPLETE then
            if SV.TakenBoard[i].Type == COMMON.MISSION_TYPE_OUTLAW or SV.TakenBoard[i].Type == COMMON.MISSION_TYPE_OUTLAW_ITEM
            or SV.TakenBoard[i].Type == COMMON.MISSION_TYPE_OUTLAW_FLEE or SV.TakenBoard[i].Type == COMMON.MISSION_TYPE_OUTLAW_MONSTER_HOUSE then
                base_camp_2.Outlaw_Job_Clear(SV.TakenBoard[i])
            else
                base_camp_2.Mission_Job_Clear(SV.TakenBoard[i])
            end
            --short pause between fadeins
            GAME:WaitFrames(20)
            
            --clear the job
            SV.TakenBoard[i] = 	{
            Client = "",
            Target = "",
            Flavor = "",
            Title = "",
            Zone = "",
            Segment = -1,
            Floor = -1,
            Reward = "",
            Type = -1,
            Completion = -1,
            Taken = false,
            Difficulty = "",
            Item = "",
            Special = "",
            ClientGender = -1,
            TargetGender = -1,
            BonusReward = "",
            BackReference = -1
            }
        end
    end
    --reset this flag
    SV.TemporaryFlags.MissionCompleted = false
    
    GAME:MoveCamera(0, 0, 1, true)
    SOUND:PlayBGM(SV.base_town.Song, true)
    MISSION_GEN.RegenerateJobs(result)
    
    --sort taken jobs now that we're removed completed ones
    MISSION_GEN.SortTaken()
end

--takes a job and plays an outlaw reward scene depending on the job.
function base_camp_2.Outlaw_Job_Clear(job)
    local hero = CH('PLAYER')
    GAME:CutsceneMode(true)
    UI:ResetSpeaker()
    
    GROUND:TeleportTo(hero, 100, 600, Direction.Up)
    GAME:MoveCamera(90, 565, 1, false)
    
    SOUND:StopBGM()
    
    local money = false
    if job.Reward == 'money' then money = true end
    
    --client is magna, he and the magnemite take the outlaw away
    if job.Client == 'magna' then
        local magnemite_left, magnemite_right, magna =
        COMMON.MakeCharactersFromList({
        --{'Sandile', 100, 555, Direction.Down},
        {'Magnemite_Left', 80, 555, Direction.Down},
        {'Magnemite_Right', 120, 555, Direction.Down},
        {'Magnezone', 100, 575, Direction.Down}
        })
        
        local outlaw_gender = job.TargetGender
        outlaw_gender = COMMON.NumToGender(outlaw_gender)
        
        local outlaw_monster = RogueEssence.Dungeon.MonsterID(job.Target, 0, "normal", outlaw_gender)
        
        local outlaw = RogueEssence.Ground.GroundChar(outlaw_monster, RogueElements.Loc(100, 555), Direction.Down, outlaw_monster.Species, 'Outlaw')
        outlaw:ReloadEvents()
        GAME:GetCurrentGround():AddTempChar(outlaw)
        
        GAME:FadeIn(40)
        SOUND:PlayBGM("Job Clear!.ogg", true)
        UI:SetSpeaker(magna)
        
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Outlaw_Capture_Cutscene_001'], _DATA:GetMonster(outlaw.CurrentForm.Species):GetColoredName()))
        
        GAME:WaitFrames(20)
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Outlaw_Capture_Cutscene_002']))
        GAME:WaitFrames(20)
        
        --reward the item 
        if money then
            COMMON.RewardItem(MISSION_GEN.DIFF_TO_MONEY[job.Difficulty], true)
        else
            COMMON.RewardItem(job.Reward)
        end
        
        
        if job.BonusReward ~= '' then
            UI:SetSpeaker(magna)
            GAME:WaitFrames(20)
            UI:WaitShowDialogue(STRINGS:Format(MapStrings['Outlaw_Capture_Cutscene_003']))
            GAME:WaitFrames(20)
            COMMON.RewardItem(job.BonusReward)
        end
        
        GAME:WaitFrames(20)
        base_camp_2.RewardEXP(job)
        
        GAME:WaitFrames(20)
        
        UI:SetSpeaker(magna)
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Outlaw_Capture_Cutscene_004']))
        
        GROUND:CharSetEmote(magnemite_left, "happy", 0)
        GROUND:CharSetEmote(magnemite_right, "happy", 0)
        local coro1 = TASK:BranchCoroutine(function() GROUND:CharSetAction(magna, RogueEssence.Ground.PoseGroundAction(magna.Position, magna.Direction, RogueEssence.Content.GraphicsManager.GetAnimIndex("Pose"))) end)
        local coro2 = TASK:BranchCoroutine(function() GROUND:CharSetAction(magnemite_left, RogueEssence.Ground.PoseGroundAction(magnemite_left.Position, magnemite_left.Direction, RogueEssence.Content.GraphicsManager.GetAnimIndex("Pose"))) end)
        local coro3 = TASK:BranchCoroutine(function() GROUND:CharSetAction(magnemite_right, RogueEssence.Ground.PoseGroundAction(magnemite_right.Position, magnemite_right.Direction, RogueEssence.Content.GraphicsManager.GetAnimIndex("Pose"))) end)
        local coro4 = TASK:BranchCoroutine(function() GAME:WaitFrames(12) SOUND:PlayBattleSE('DUN_Magnet_Bomb') end)
        
        TASK:JoinCoroutines({coro1, coro2, coro3, coro4})
        GAME:WaitFrames(60)
        
        GROUND:CharEndAnim(magna)
        GROUND:CharEndAnim(magnemite_left)
        GROUND:CharEndAnim(magnemite_right)
        GROUND:CharSetEmote(magnemite_left, "", 0)
        GROUND:CharSetEmote(magnemite_right, "", 0)
        GAME:WaitFrames(20)
        
        --fade out and clean up any temporary characters
        SOUND:FadeOutBGM(40)
        GAME:FadeOut(false, 40)
        GAME:GetCurrentGround():RemoveTempChar(magna)
        GAME:GetCurrentGround():RemoveTempChar(magnemite_left)
        GAME:GetCurrentGround():RemoveTempChar(magnemite_right)
        GAME:GetCurrentGround():RemoveTempChar(outlaw)
        
        
    else--client is some random mon
        local client_gender = job.ClientGender
        client_gender = COMMON.NumToGender(client_gender)
        client_gender = client_gender
        
        local client_monster = RogueEssence.Dungeon.MonsterID(job.Client, 0, "normal", client_gender)
        
        local client = RogueEssence.Ground.GroundChar(client_monster, RogueElements.Loc(100, 575), Direction.Down, job.Client:gsub("^%l", string.upper), client_monster.Species)
        client:ReloadEvents()
        GAME:GetCurrentGround():AddTempChar(client)
        
        GAME:FadeIn(40)
        SOUND:PlayBGM("Job Clear!.ogg", true)
        UI:SetSpeaker(client)
        
        
        local item = RogueEssence.Dungeon.InvItem(job.Item)
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Outlaw_Retrieve_Cutscene'], item:GetDisplayName()))
        GAME:WaitFrames(20)
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Generic_Reward']))
        GAME:WaitFrames(20)
        
        --reward the item 
        if money then
            COMMON.RewardItem(MISSION_GEN.DIFF_TO_MONEY[job.Difficulty], true)
        else
            COMMON.RewardItem(job.Reward)
        end
        
        if job.BonusReward ~= '' then
            UI:SetSpeaker(client)
            GAME:WaitFrames(20)
            UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Generic_Reward_2']))
            GAME:WaitFrames(20)
            COMMON.RewardItem(job.BonusReward)
        end
        
        GAME:WaitFrames(20)
        base_camp_2.RewardEXP(job)
        GAME:WaitFrames(20)
        
        --fade out and clean up any temporary characters
        SOUND:FadeOutBGM(40)
        GAME:FadeOut(false, 40)
        GAME:GetCurrentGround():RemoveTempChar(client)
    end
    
    GAME:CutsceneMode(false)
end

--takes a job and plays an regular mission reward scene depending on the job.
function base_camp_2.Mission_Job_Clear(job)
    local hero = CH('PLAYER')
    GAME:CutsceneMode(true)
    UI:ResetSpeaker()
    
    GROUND:TeleportTo(hero, 100, 600, Direction.Up)
    GAME:MoveCamera(90, 565, 1, false)
    SOUND:StopBGM()
    
    local money = false
    if job.Reward == 'money' then money = true end
    
    --client is target. Check on escort is needed in case the escort is to the same species.
    if job.Client == job.Target and job.Type ~= COMMON.MISSION_TYPE_ESCORT then
    local client_gender = job.ClientGender
    client_gender = COMMON.NumToGender(client_gender)
    
    local client_monster = RogueEssence.Dungeon.MonsterID(job.Client, 0, "normal", client_gender)
    local client = RogueEssence.Ground.GroundChar(client_monster, RogueElements.Loc(100, 575), Direction.Down, job.Client:gsub("^%l", string.upper), client_monster.Species)
    client:ReloadEvents()
    GAME:GetCurrentGround():AddTempChar(client)
    
    GAME:FadeIn(40)
    SOUND:PlayBGM("Job Clear!.ogg", true)
    UI:SetSpeaker(client)
    
    --different thank you message depending on the job type
    if job.Type == COMMON.MISSION_TYPE_RESCUE then
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Rescue']))
    elseif job.Type == COMMON.MISSION_TYPE_EXPLORATION then
    local zone = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(job.Zone)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Exploration'], zone:GetColoredName()))
    elseif job.Type == COMMON.MISSION_TYPE_LOST_ITEM then
    local item = RogueEssence.Dungeon.InvItem(job.Item)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Lost_Item'], item:GetDisplayName()))
    else--delivery 
    local item = RogueEssence.Dungeon.InvItem(job.Item)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Delivery_Item'], item:GetDisplayName()))
    end
    
    GAME:WaitFrames(20)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Generic_Reward']))
    GAME:WaitFrames(20)
    
    --reward the item 
    if money then
    COMMON.RewardItem(MISSION_GEN.DIFF_TO_MONEY[job.Difficulty], true)
    else
    COMMON.RewardItem(job.Reward)
    end
    
    if job.BonusReward ~= '' then
    UI:SetSpeaker(client)
    GAME:WaitFrames(20)
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Generic_Reward_2']))
    GAME:WaitFrames(20)
    COMMON.RewardItem(job.BonusReward)
    end
    
    GAME:WaitFrames(20)
    base_camp_2.RewardEXP(job)
    GAME:WaitFrames(20)
    
    
    --fade out and clean up any temporary characters
    SOUND:FadeOutBGM(40)
    GAME:FadeOut(false, 40)
    GAME:GetCurrentGround():RemoveTempChar(client)



    else--client not the target
        local client_gender = job.ClientGender
        client_gender = COMMON.NumToGender(client_gender)


        local client_monster = RogueEssence.Dungeon.MonsterID(job.Client, 0, "normal", client_gender)

        local client = RogueEssence.Ground.GroundChar(client_monster, RogueElements.Loc(80, 575), Direction.Down, job.Client:gsub("^%l", string.upper), client_monster.Species)
        client:ReloadEvents()
        GAME:GetCurrentGround():AddTempChar(client)

        local target_gender = job.TargetGender
        target_gender = COMMON.NumToGender(target_gender)

        local target_monster = RogueEssence.Dungeon.MonsterID(job.Target, 0, "normal", target_gender)
        target_monster.Gender = _DATA:GetMonster(job.Target).Forms[0]:RollGender(_ZONE.CurrentGround.Rand)

        local target = RogueEssence.Ground.GroundChar(target_monster, RogueElements.Loc(120, 575), Direction.Down, job.Target:gsub("^%l", string.upper), target_monster.Species)
        target:ReloadEvents()
        GAME:GetCurrentGround():AddTempChar(target)


        GAME:FadeIn(40)
        SOUND:PlayBGM("Job Clear!.ogg", true)
        UI:SetSpeaker(client)

        if job.Type == COMMON.MISSION_TYPE_ESCORT then
            UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Escort']))
        else
            if job.Special == MISSION_GEN.SPECIAL_CLIENT_LOVER then
                UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Lover']))
            elseif job.Special == MISSION_GEN.SPECIAL_CLIENT_RIVAL then
                UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Rival']))
            elseif job.Special == MISSION_GEN.SPECIAL_CLIENT_CHILD then
                UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Child']))
            else
                UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Response_Rescue_Friend']))
            end
        end
        GAME:WaitFrames(20)
        UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Generic_Reward']))
        GAME:WaitFrames(20)

        --reward the item 
        if money then
            COMMON.RewardItem(MISSION_GEN.DIFF_TO_MONEY[job.Difficulty], true)
        else
            COMMON.RewardItem(job.Reward)
        end

        if job.BonusReward ~= '' then
            UI:SetSpeaker(client)
            GAME:WaitFrames(20)
            UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Generic_Reward_2']))
            GAME:WaitFrames(20)
            COMMON.RewardItem(job.BonusReward)
        end

        GAME:WaitFrames(20)
        base_camp_2.RewardEXP(job)
        GAME:WaitFrames(20)


        --fade out and clean up any temporary characters
        SOUND:FadeOutBGM(40)
        GAME:FadeOut(false, 40)
        GAME:GetCurrentGround():RemoveTempChar(client)
        GAME:GetCurrentGround():RemoveTempChar(target)
    end
    GAME:CutsceneMode(false)
end

function base_camp_2.RewardEXP(job)
    --Reward EXP for your party
    local exp_reward = MISSION_GEN.GetJobExpReward(job.Difficulty)
    local exp_reward_string = "[color=#00FFFF]"..exp_reward.."[color]"
    UI:ResetSpeaker()
    UI:WaitShowDialogue(STRINGS:Format(MapStrings['Mission_Handout_EXP'], exp_reward_string))
    PrintInfo("Rewarding EXP for job with difficulty "..job.Difficulty.." and reward "..exp_reward_string)
    local player_count = _DATA.Save.ActiveTeam.Players.Count
    for player_idx = 0, player_count-1, 1 do
        TASK:WaitTask(GROUND:_HandoutEXP(_DATA.Save.ActiveTeam.Players[player_idx], exp_reward))
    end
end

return base_camp_2