--[[
    common.lua
    A collection of frequently used functions and values!
]]--
require 'common_gen'

----------------------------------------
-- Debugging
----------------------------------------
DEBUG = 
{
  EnableDbgCoro = function() end, --Call this function inside coroutines you want to allow debugging of, at the start. Default is empty
  --FIXME: fix mobdebug and sockets
  IsDevMode = function() return false end, --RogueEssence.DiagManager.Instance.DevMode end,
  GroundAIShowDebugInfo = false,
}

DEBUG.GroundAIShowDebugInfo = false--DEBUG.IsDevMode()

--Disable debugging for non devs
if DEBUG.IsDevMode() then
  ___mobdebug = require('mobdebug')
  ___mobdebug.coro() --Enable coroutine debugging
  ___mobdebug.checkcount = 1 --Increase debugger update frequency
  ___mobdebug.verbose=true --Enable debugger verbose mode
  ___mobdebug.start() --Enable debugging
  DEBUG.EnableDbgCoro = function() require('mobdebug').on() end --Set the content of the function to this in dev mode, so it does something
end


----------------------------------------
-- Lib Definitions
----------------------------------------
--Reserve the "class" symbol for instantiating classes
Class    = require 'lib.middleclass'
--Reserve the "Mediator" symbol for instantiating the message lib class
Mediator = require 'lib.mediator' 
--Reserve the "Serpent" symbol for the serializer
Serpent = require 'lib.serpent'

----------------------------------------------------------
-- Console Writing
----------------------------------------------------------

--Prints to console!
function PrintInfo(text)
  if DiagManager then 
    DiagManager.Instance:LogInfo( '[SE]:' .. text) 
  else
    print('[SE]:' .. text)
  end
end

--Prints to console!
function PrintError(text)
  if DiagManager then 
    DiagManager.Instance:LogInfo( '[SE]:' .. text) 
  else
    print('[SE](ERROR): ' .. text)
  end
end

--Will print the stack and the specified error message
function PrintStack(err)
  PrintInfo(debug.traceback(tostring(err),2)) 
end

function PrintSVAndStrings(mapstr)
  print("DUMPING SCRIPT VARIABLE STATE..")
  print(Serpent.block(SV))
  print(Serpent.block(mapstr))
  print("-------------------------------")
end

----------------------------------------
-- Common namespace
----------------------------------------
COMMON = {}

require 'common_talk'
require 'common_shop'

--Automatically load the appropriate localization for the specified package, or defaults to english!
function COMMON.AutoLoadLocalizedStrings()
  PrintInfo("AutoLoading Strings!..")
  --Get the package path
  local packagepath = SCRIPT:CurrentScriptDir()
  
  --After we made the path, load the file
  return STRINGS:MakePackageStringTable(packagepath)
end

COMMON.MISSION_TYPE_RESCUE = 0
COMMON.MISSION_TYPE_ESCORT = 1
COMMON.MISSION_TYPE_OUTLAW = 2

COMMON.MISSION_INCOMPLETE = 0
COMMON.MISSION_COMPLETE = 1

----------------------------------------------------------
-- Convenience Scription Functions
----------------------------------------------------------
function COMMON.RespawnStarterPartner()
  -- SV.test_grounds.Starter.Gender = LUA_ENGINE:EnumToNumeric(Gender.Female)
  local character = RogueEssence.Dungeon.CharData()
  character.BaseForm = RogueEssence.Dungeon.MonsterID(SV.test_grounds.Starter.Species, SV.test_grounds.Starter.Form, SV.test_grounds.Starter.Skin, LUA_ENGINE:LuaCast(SV.test_grounds.Starter.Gender, Gender))
  GROUND:SetPlayer(character)
  GROUND:RemoveCharacter("Partner")
  local p = RogueEssence.Dungeon.CharData()
  p.BaseForm = RogueEssence.Dungeon.MonsterID(SV.test_grounds.Partner.Species, SV.test_grounds.Partner.Form, SV.test_grounds.Partner.Skin, LUA_ENGINE:LuaCast(SV.test_grounds.Partner.Gender, Gender))
  GROUND:SpawnerSetSpawn("PARTNER_SPAWN", p)
  local chara = GROUND:SpawnerDoSpawn("PARTNER_SPAWN")
end

function COMMON.RespawnAllies()
  GROUND:RefreshPlayer()
  

  local party = GAME:GetPlayerPartyTable()
  local playeridx = GAME:GetTeamLeaderIndex()

  --Place player teammates
  for i = 1,3,1
  do
    GROUND:RemoveCharacter("Teammate" .. tostring(i))
  end
  local total = 1
  for i,p in ipairs(party) do
    if i ~= (playeridx + 1) then --Indices in lua tables begin at 1
      GROUND:SpawnerSetSpawn("TEAMMATE_" .. tostring(total),p)
      local chara = GROUND:SpawnerDoSpawn("TEAMMATE_" .. tostring(total))
      --GROUND:GiveCharIdleChatter(chara)
      total = total + 1
    end
  end
end

function COMMON.ShowTeamAssemblyMenu(obj, init_fun)
  SOUND:PlaySE("Menu/Skip")
  UI:AssemblyMenu()
  UI:WaitForChoice()
  result = UI:ChoiceResult()
  if result then
    GAME:WaitFrames(10)
	SOUND:PlayBattleSE("EVT_Assembly_Bell")
	GROUND:ObjectSetAnim(obj, 6, -1, -1, RogueElements.Dir8.Down, 3)
	GAME:FadeOut(false, 20)
	init_fun()
    GAME:FadeIn(20)
  end
end

function COMMON.ShowDestinationMenu(dungeon_entrances, ground_entrances)
  
  --check for unlock of dungeons
  local open_dests = {}
  for ii = 1,#dungeon_entrances,1 do
    if GAME:DungeonUnlocked(dungeon_entrances[ii]) then
	local zone_summary = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(dungeon_entrances[ii])
	  if zone_summary.Released then
	    local zone_name = ""
	    if _DATA.Save:GetDungeonUnlock(dungeon_entrances[ii]) == RogueEssence.Data.GameProgress.UnlockState.Completed then
		  zone_name = zone_summary:GetColoredName()
		else
		  zone_name = "[color=#00FFFF]"..zone_summary.Name:ToLocal().."[color]"
		end
        table.insert(open_dests, { Name=zone_name, Dest=RogueEssence.Dungeon.ZoneLoc(dungeon_entrances[ii], 0, 0, 0) })
	  end
	end
  end
  
  --check for unlock of grounds
  for ii = 1,#ground_entrances,1 do
    if ground_entrances[ii].Flag then
	  local ground_id = ground_entrances[ii].Zone
	  local zone = _DATA:GetZone(ground_id)
	  local ground = _DATA:GetGround(zone.GroundMaps[ground_entrances[ii].ID])
	  local ground_name = ground:GetColoredName()
      table.insert(open_dests, { Name=ground_name, Dest=RogueEssence.Dungeon.ZoneLoc(ground_id, -1, ground_entrances[ii].ID, ground_entrances[ii].Entry) })
	end
  end
  
  local dest = RogueEssence.Dungeon.ZoneLoc.Invalid
  if #open_dests == 1 then
    if open_dests[1].Dest.StructID.Segment < 0 then
	  --single ground entry
      UI:ResetSpeaker(false)
      SOUND:PlaySE("Menu/Skip")
	  UI:ChoiceMenuYesNo(STRINGS:FormatKey("DLG_ASK_ENTER_GROUND", open_dests[1].Name))
      UI:WaitForChoice()
      if UI:ChoiceResult() then
	    dest = open_dests[1].Dest
	  end
	else
	  --single dungeon entry
      UI:ResetSpeaker(false)
      SOUND:PlaySE("Menu/Skip")
	  UI:DungeonChoice(open_dests[1].Name, open_dests[1].Dest)
      UI:WaitForChoice()
      if UI:ChoiceResult() then
	    dest = open_dests[1].Dest
	  end
	end
  elseif #open_dests > 1 then
    
    UI:ResetSpeaker()
    SOUND:PlaySE("Menu/Skip")
    UI:DestinationMenu(open_dests)
	UI:WaitForChoice()
	dest = UI:ChoiceResult()
  else
    PrintInfo("No valid destinations found!")
  end
  
  if dest:IsValid() then
	if dest.StructID.Segment > -1 then
	  --pre-loads the zone on a separate thread while we fade out, just for a little optimization
	  _DATA:PreLoadZone(dest.ID)
	  SOUND:PlayBGM("", true)
      GAME:FadeOut(false, 20)
	  GAME:EnterDungeon(dest.ID, dest.StructID.Segment, dest.StructID.ID, dest.EntryPoint, RogueEssence.Data.GameProgress.DungeonStakes.Risk, true, false)
	else
	  SOUND:PlayBGM("", true)
      GAME:FadeOut(false, 20)
	  GAME:EnterZone(dest.ID, dest.StructID.Segment, dest.StructID.ID, dest.EntryPoint)
	end
  end
end

function COMMON.CreateWalkArea(name, x, y, w, h)

  --Set Char AI
  local chara = CH(name)
  if chara == nil then
    return
  end
  --Set the area to wander in
  AI:SetCharacterAI(chara,                                      --[[Entity that will use the AI]]--
                    "ai.ground_default",                         --[[Class path to the AI class to use]]--
                    RogueElements.Loc(x, y), --[[Top left corner pos of the allowed idle wander area]]--
                    RogueElements.Loc(w, h), --[[Width and Height of the allowed idle wander area]]--
                    1,                                         --[[Wandering speed]]--
                    16,                                          --[[Min move distance for a single wander]]--
                    32,                                          --[[Max move distance for a single wander]]--
                    40,                                         --[[Min delay between idle actions]]--
                    180)                                        --[[Max delay between idle actions]]--
  --chara:EnableCharacterAI(chara)
end

function COMMON.MakeWhoosh(center, y, tier, reversed)
    local whoosh1 = RogueEssence.Content.FiniteOverlayEmitter()
    whoosh1.FadeIn = 30
    whoosh1.TotalTime = 90
    whoosh1.RepeatX = true
	if reversed then
		whoosh1.Movement = RogueElements.Loc(-360, 0)
	else
		whoosh1.Movement = RogueElements.Loc(360, 0)
	end
    whoosh1.Layer = DrawLayer.Top
    whoosh1.Anim = RogueEssence.Content.BGAnimData("Pre_Battle", 1, tier, tier)
	GROUND:PlayVFX(whoosh1, center.X, center.Y + y)
end

function COMMON.BossTransition()
    local center = GAME:GetCameraCenter()
    SOUND:FadeOutBGM(20)
    local emitter = RogueEssence.Content.FlashEmitter()
    emitter.FadeInTime = 2
    emitter.HoldTime = 2
    emitter.FadeOutTime = 2
    emitter.StartColor = Color(0, 0, 0, 0)
    emitter.Layer = DrawLayer.Top
    emitter.Anim = RogueEssence.Content.BGAnimData("White", 0)
    GROUND:PlayVFX(emitter, center.X, center.Y)
    SOUND:PlayBattleSE("EVT_Battle_Flash")
    GAME:WaitFrames(16)
    GROUND:PlayVFX(emitter, center.X, center.Y)
    SOUND:PlayBattleSE("EVT_Battle_Flash")
    GAME:WaitFrames(46)
    
    SOUND:PlayBattleSE('EVT_Battle_Transition')
	COMMON.MakeWhoosh(center, -32, 0, false)
    GAME:WaitFrames(5)
	COMMON.MakeWhoosh(center, -64, 0, true)
	COMMON.MakeWhoosh(center, 0, 0, true)
    GAME:WaitFrames(5)
	COMMON.MakeWhoosh(center, -112, 1, false)
	COMMON.MakeWhoosh(center, 48, 1, false)
    GAME:WaitFrames(5)
	COMMON.MakeWhoosh(center, -144, 2, true)
	COMMON.MakeWhoosh(center, 80, 2, true)
    GAME:WaitFrames(5)
	COMMON.MakeWhoosh(center, -176, 3, false)
	COMMON.MakeWhoosh(center, 112, 3, false)
    GAME:WaitFrames(40)
    GAME:FadeOut(true, 30)
    GAME:WaitFrames(80)
end

function COMMON.GiftItem(player, receive_item)
  COMMON.GiftItemFull(player, receive_item, true, false)
end

function COMMON.GiftItemFull(player, receive_item, fanfare, force_storage)
  if fanfare then
    SOUND:PlayFanfare("Fanfare/Item")
  end
  UI:ResetSpeaker(false)
  UI:SetCenter(true)
  if not force_storage and GAME:GetPlayerBagCount() + GAME:GetPlayerEquippedCount() < GAME:GetPlayerBagLimit() then
    --give to inventory
	UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("DLG_RECEIVE_ITEM"):ToLocal(), player:GetDisplayName(), receive_item:GetDisplayName()))
	GAME:GivePlayerItem(receive_item)
  else
    --give to storage
	UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("DLG_RECEIVE_ITEM_STORAGE"):ToLocal(), player:GetDisplayName(), receive_item:GetDisplayName()))
	GAME:GivePlayerStorageItem(receive_item)
  end
  UI:SetCenter(false)
  UI:ResetSpeaker()
end


function COMMON.JoinTeamWithFanfare(recruit, from_dungeon)
  if from_dungeon then
    recruit.MetAt = _ZONE.CurrentMap:GetColoredName()
  else
    recruit.MetAt = _ZONE.CurrentGround:GetColoredName()
  end
  recruit.MetLoc = RogueEssence.Dungeon.ZoneLoc(_ZONE.CurrentZoneID, _ZONE.CurrentMapID)
  
  if _DATA.Save.ActiveTeam.Players.Count < _DATA.Save.ActiveTeam:GetMaxTeam(_ZONE.CurrentZone) then
    _DATA.Save.ActiveTeam.Players:Add(recruit)
  else
    _DATA.Save.ActiveTeam.Assembly:Add(recruit)
  end
  SOUND:PlayFanfare("Fanfare/JoinTeam")
  _DATA.Save:RegisterMonster(recruit.BaseForm.Species)
  _DATA.Save:RogueUnlockMonster(recruit.BaseForm.Species)
	
  UI:ResetSpeaker()
  
  if _DATA.Save.ActiveTeam.Name ~= "" then
    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MSG_RECRUIT"):ToLocal(), recruit:GetDisplayName(true), _DATA.Save.ActiveTeam.Name))
  else
    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("MSG_RECRUIT_ANY"):ToLocal(), recruit:GetDisplayName(true)))
  end
end


function COMMON.UnlockWithFanfare(dungeon_id, from_dungeon)
  if not GAME:DungeonUnlocked(dungeon_id) then
    local zone = _DATA.DataIndices[RogueEssence.Data.DataManager.DataType.Zone]:Get(dungeon_id)
	if zone.Released == false then
      GAME:UnlockDungeon(dungeon_id)
	  PrintInfo("Dungeon unlocked silently as it has not been released yet.")
	  return
	end
    if from_dungeon then
      UI:ResetSpeaker()
      UI:SetCenter(true)
      UI:WaitShowDialogue(STRINGS:FormatKey("DLG_NEW_AREA_TO"))
	end
    GAME:UnlockDungeon(dungeon_id)
    UI:ResetSpeaker(false)
	UI:SetCenter(true)
	
    SOUND:PlayFanfare("Fanfare/NewArea")
    UI:WaitShowDialogue(STRINGS:FormatKey("DLG_NEW_AREA", zone:GetColoredName()))
    UI:SetCenter(false)
    UI:ResetSpeaker()
  end

end

function COMMON.ClearPlayerPrices()
  local item_count = GAME:GetPlayerBagCount()
  for item_idx = 0, item_count-1, 1 do
    local inv_item = GAME:GetPlayerBagItem(item_idx)
	inv_item.Price = 0
  end
  local player_count = _DUNGEON.ActiveTeam.Players.Count
  for player_idx = 0, player_count-1, 1 do
    local inv_item = GAME:GetPlayerEquippedItem(player_idx)
	inv_item.Price = 0
  end
  
  COMMON.ClearMapTeamPrices(_ZONE.CurrentMap.AllyTeams)
  COMMON.ClearMapTeamPrices(_ZONE.CurrentMap.MapTeams)
end

function COMMON.ClearMapTeamPrices(team_list)

  local team_count = team_list.Count
  for team_idx = 0, team_count-1, 1 do
	local player_count = team_list[team_idx].Players.Count
	for player_idx = 0, player_count-1, 1 do
      local inv_item = team_list[team_idx].Players[player_idx].EquippedItem
	  inv_item.Price = 0
	end
  end
end

function COMMON.ClearAllPrices()
  COMMON.ClearPlayerPrices()

  -- clear map prices
  local item_count = _ZONE.CurrentMap.Items.Count
  for item_idx = 0, item_count-1, 1 do
    local map_item = _ZONE.CurrentMap.Items[item_idx]
	map_item.Price = 0
  end
end

function COMMON.PayDungeonCartPrice(price)
  COMMON.ClearPlayerPrices()
  GAME:RemoveFromPlayerMoney(price)
  
  local security_price = COMMON.GetShopPriceState()
  security_price.Amount = security_price.Amount - price
  security_price.Cart = 0
end

function COMMON.PayDungeonSellPrice(price)
  -- set prices for all items placed on the shop
  local item_count = _ZONE.CurrentMap.Items.Count
  for item_idx = 0, item_count-1, 1 do
    local map_item = _ZONE.CurrentMap.Items[item_idx]
	-- they should not already have a price
	if map_item.Price <= 0 then
	  local sell_value = map_item:GetSellValue()
	  -- they should have value as sold items
	  if sell_value > 0 then
	    local tile = _ZONE.CurrentMap.Tiles[map_item.TileLoc.X][map_item.TileLoc.Y]
	    -- only add price if on shop mat
	    if tile.Effect.ID == "area_shop" then
	      map_item.Price = sell_value * 2
	    end
	  end
	end
  end
  
  GAME:AddToPlayerMoney(price)
  local security_price = COMMON.GetShopPriceState()
  security_price.Amount = security_price.Amount + price * 2
end

ShopPriceType = luanet.import_type('PMDC.Dungeon.ShopPriceState')
function COMMON.GetShopPriceState()
  local security_status = "shop_security"
  local status = _DUNGEON:GetMapStatus(security_status)
  if status then
	if status.StatusStates:Contains(luanet.ctype(ShopPriceType)) then
	  return status.StatusStates:Get(luanet.ctype(ShopPriceType))
	end
  end
  return nil
end

function COMMON.GetDungeonCartPrice()

  local price = 0
  local security_price = COMMON.GetShopPriceState()
  price = security_price.Amount
  
  -- iterate items on shop mats and subtract total price
  local item_count = _ZONE.CurrentMap.Items.Count
  for item_idx = 0, item_count-1, 1 do
    local map_item = _ZONE.CurrentMap.Items[item_idx]
	if map_item.Price > 0 then
	  local tile = _ZONE.CurrentMap.Tiles[map_item.TileLoc.X][map_item.TileLoc.Y]
	  -- only subtract price if on shop mat
	  if tile.Effect.ID == "area_shop" then
	    price = price - map_item.Price
	  end
	end
  end
  return price
end

function COMMON.GetDungeonSellPrice()

  local price = 0
  -- iterate items on shop mats and add total price
  local item_count = _ZONE.CurrentMap.Items.Count
  for item_idx = 0, item_count-1, 1 do
    local map_item = _ZONE.CurrentMap.Items[item_idx]
	-- they should not already have a price
	if map_item.Price <= 0 then
	  local sell_value = map_item:GetSellValue()
	  -- they should have value as sold items
	  if sell_value > 0 then
	    local tile = _ZONE.CurrentMap.Tiles[map_item.TileLoc.X][map_item.TileLoc.Y]
	    -- only add price if on shop mat
	    if tile.Effect.ID == "area_shop" then
	      price = price + sell_value
	    end
	  end
	end
  end
  return price
end


function COMMON.ThiefReturn()
  _GAME:BGM("", false)
  COMMON.ClearAllPrices()
  
  local thief_check_idx = "shop_security"
  local thief_idx = "thief"
  local check_status = _DUNGEON:GetMapStatus(thief_check_idx)
  
  local index_from = check_status.StatusStates:Get(luanet.ctype(MapIndexType))
  UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(string.format("TALK_SHOP_SUSPECT_%04d", index_from.Index)):ToLocal()))
  _DUNGEON:LogMsg(STRINGS:Format(RogueEssence.StringKey(string.format("TALK_SHOP_THIEF_RETURN_%04d", index_from.Index)):ToLocal()))
  
  local thief_status = RogueEssence.Dungeon.MapStatus(thief_idx)
  thief_status:LoadFromData()
  -- put spawner from security status in thief status
  local security_to = thief_status.StatusStates:Get(luanet.ctype(ShopSecurityType))
  local security_from = check_status.StatusStates:Get(luanet.ctype(ShopSecurityType))
  security_to.Security = security_from.Security
  TASK:WaitTask(_DUNGEON:RemoveMapStatus(thief_check_idx))
  TASK:WaitTask(_DUNGEON:AddMapStatus(thief_status))
  GAME:WaitFrames(60)
end

function COMMON.ShopTileCheck(baseLoc, dir)
  local dirLoc = RogueElements.DirExt.GetLoc(dir)
  local loc = RogueElements.Loc(baseLoc.X + dirLoc.X, baseLoc.Y + dirLoc.Y)
  if not RogueElements.Collision.InBounds(_ZONE.CurrentMap.Width, _ZONE.CurrentMap.Height, loc) then
    return false
  end
  return (_ZONE.CurrentMap.Tiles[loc.X][loc.Y].Effect.ID == "area_shop")
end



function COMMON.FindNpcWithTable(foes, key, value)
  local team_list = _ZONE.CurrentMap.AllyTeams
  if foes then
    team_list = _ZONE.CurrentMap.MapTeams
  end
  local team_count = team_list.Count
  for team_idx = 0, team_count-1, 1 do
	-- search for a wild mon with the table value
	local player_count = team_list[team_idx].Players.Count
	for player_idx = 0, player_count-1, 1 do
	  player = team_list[team_idx].Players[player_idx]
	  local player_tbl = LTBL(player)
	  if player_tbl[key] == value then
		return player
	  end
	end
  end
  return nil
end

function COMMON.CanTalk(chara)
  if chara:GetStatusEffect("sleep") ~= nil then
    return false
  end
  if chara:GetStatusEffect("freeze") ~= nil then
    return false
  end
  if chara:GetStatusEffect("confuse") ~= nil then
    return false
  end
  return true
end


function COMMON.DungeonInteract(chara, target, action_cancel, turn_cancel)
  action_cancel.Cancel = true
  -- TODO: create a charstate for being unable to talk and have talk-interfering statuses cause it
  if COMMON.CanTalk(target) then
    
    local ratio = target.HP * 100 // target.MaxHP
    
    local mon = _DATA:GetMonster(target.BaseForm.Species)
    local form = mon.Forms[target.BaseForm.Form]
    
    UI:SetSpeaker(target)
  
    local personality = form:GetPersonalityType(target.Discriminator)
    
    local personality_group = COMMON.PERSONALITY[personality]
    local pool = {}
    local key = ""
    if ratio <= 25 then
      UI:SetSpeakerEmotion("Pain")
      pool = personality_group.PINCH
      key = "TALK_PINCH_%04d"
    elseif ratio <= 50 then
      UI:SetSpeakerEmotion("Worried")
      pool = personality_group.HALF
      key = "TALK_HALF_%04d"
    else
      pool = personality_group.FULL
      key = "TALK_FULL_%04d"
    end
    
    local running_pool = {table.unpack(pool)}
    local valid_quote = false
    local chosen_quote = ""
    
    while not valid_quote and #running_pool > 0 do
      valid_quote = true
      local chosen_idx = math.random(1, #running_pool)
  	  local chosen_pool_idx = running_pool[chosen_idx]
      chosen_quote = RogueEssence.StringKey(string.format(key, chosen_pool_idx)):ToLocal()
  	
      chosen_quote = string.gsub(chosen_quote, "%[player%]", chara:GetDisplayName(true))
      chosen_quote = string.gsub(chosen_quote, "%[myname%]", target:GetDisplayName(true))
      
      if string.find(chosen_quote, "%[move%]") then
        local moves = {}
  	    for move_idx = 0, 3 do
  	      if target.BaseSkills[move_idx].SkillNum ~= "" then
  	        table.insert(moves, target.BaseSkills[move_idx].SkillNum)
  	      end
  	    end
  	    if #moves > 0 then
  	      local chosen_move = _DATA:GetSkill(moves[math.random(1, #moves)])
  	      chosen_quote = string.gsub(chosen_quote, "%[move%]", chosen_move:GetIconName())
  	    else
  	      valid_quote = false
  	    end
      end
      
      if string.find(chosen_quote, "%[kind%]") then
  	    if GAME:GetCurrentFloor().TeamSpawns.CanPick then
          local team_spawn = GAME:GetCurrentFloor().TeamSpawns:Pick(GAME.Rand)
  	      local chosen_list = team_spawn:ChooseSpawns(GAME.Rand)
  	      if chosen_list.Count > 0 then
  	        local chosen_mob = chosen_list[math.random(0, chosen_list.Count-1)]
  	        local mon = _DATA:GetMonster(chosen_mob.BaseForm.Species)
            chosen_quote = string.gsub(chosen_quote, "%[kind%]", mon:GetColoredName())
  	      else
  	        valid_quote = false
  	      end
  	    else
  	      valid_quote = false
  	    end
      end
      
      if string.find(chosen_quote, "%[item%]") then
        if GAME:GetCurrentFloor().ItemSpawns.CanPick then
          local item = GAME:GetCurrentFloor().ItemSpawns:Pick(GAME.Rand)
          chosen_quote = string.gsub(chosen_quote, "%[item%]", item:GetDisplayName())
  	    else
  	      valid_quote = false
  	    end
      end
  	
  	  if not valid_quote then
        -- PrintInfo("Rejected "..chosen_quote)
  	    table.remove(running_pool, chosen_idx)
  	    chosen_quote = ""
  	  end
    end
    -- PrintInfo("Selected "..chosen_quote)
	
	local oldDir = target.CharDir
    DUNGEON:CharTurnToChar(target, chara)
  
    UI:WaitShowDialogue(STRINGS:Format(chosen_quote))
  
    target.CharDir = oldDir
  else
  
    UI:ResetSpeaker()
	
	local chosen_quote = RogueEssence.StringKey("TALK_CANT"):ToLocal()
    chosen_quote = string.gsub(chosen_quote, "%[myname%]", target:GetDisplayName(true))
	
    UI:WaitShowDialogue(chosen_quote)
  
  end
  
  --characters can comment on:

  --flavour for the dungeon (talk about the area and its lore)
  --being able to evolve
  --nearly reaching the end of the dungeon
  --being hungry
  --out of PP
  --being able to recruit someone
  --tutorial tips
  ---gaining EXP while in assembly
  ---apricorns
  ---sleeping pokemon
  --commenting on how long they've been on the team
  ---I know we just met, but...
  ---We've been together for over 10 floors now, don't leave me now!
  --beginning a fight "do you think we can take them?"
  --upon recruitment "explore the world, you say?  I'm in!" "yay, friends!" "fine, I'll come with you.  just don't slow me down" "oh my... you smell heavenly.  can I come with you?"
  --"you look tasty- I mean X, can I come with you?", "Team X, huh?  I like the sound of that!", "you lot seem smart/wise, I think you have what it takes to reach the top."
  --when/after someone faints "X isn't with us anymore... but we have to keep going."
  --"if you faint as the leader, I'll gladly take your place."
  --specific personalities for mechanical creatures
  --specific personalities for childish creatures
  --verbal tics (chirp/tweet, meow, woof/arf, squeak, pika)
  --third-person dialogue
  --burned "ow, ow ,ow!  hot, hot!, hot!"
  --paralyzed "I can't feel my legs..." (check body type for this)
  --when there's only 2 members left, and no means to summon more recruits "we're the only ones left." "come on!  we can't give up!"
  --"I wonder what [fainted mon] would've done..."
  --lore on the legendary guildmasters
  ---
  --the rise of recent disasters- mystery dungeons
  --the guildmaster's treasures?
  --a challenge that no one has passed yet; people stopped bothering
  --but as the disasters appear, the pokemon begin to search for a leader
  --At low HP: "X's resolve is being tested..."
  --isn't my fur just luxurious? (vain personality)
  --first priority is for phrases that occur at each break point
  --would you like to hear a song? (if knows sing, round, or perish song)
  --"so it's just us now, huh?" (two pokemon, one or more has fainted)
  --We're going to be okay, right?  Tell me we're going to be okay.
  --Hey... if I don't make it out of here, tell (assembly mon) I love her.
  --talk about how one of their moves is a type, and it will be super-effective on an enemy found on the floor
  --rumors spread of a treasure in a dangerous location
  ----actually a trap; an ambush spot
  --My body wasn't ready for this...
  --Hey, what is it like to have arms?
  --That Red apricorn you have there.  We can use it to recruit a Fire-type Pokemon.
  --Let's find a strong Fire-type Pokemon to give that Red Apricorn to.
  --That Oran Berry we just picked up should help us in a pinch.
  --Those Mankeys are fighting-type Pokemon.  We should hit them with Flying type moves!
  --So why are you in this exploration? [Treasure][Meet Pokemon][Guildmaster][I dunno]
  --To set foot in this dungeon... you're either very brave, or foolhardy.
  --I've gotta hand it to you. Not many Exploration teams make it this far.
  --Too bad I don't have any hands.
  --You know what's weird?  We've been talking all this time and those (visible Pokemon) over there haven't made a single step towards us.  Do you think they're just that polite?
  --I don't like the look that (enemy pokemon) is giving me...
  --But enough talk, we need to get to the next floor.
  --But enough talk, we've got a situation here! (if multiple enemies are in sight)
  --Anyways, we need to keep moving.
  --Finally!  The stairs! (cheer when the stairs come into view, and load this dialogue up in time)
  --sleep
  --"Zzz...[pause=0] another five minutes please..."
  --"Zzz...[pause=10] Zzz..."
  --decoy
  --"...What?"
  --"...What's a \"decoy\"?"
  --"Do I look like I know what a \"decoy\" is?"
  --"Hey Einstein, I'm on your side!"
  --"Is there something on my face?"

  --evolve
  --"Hey, I think I'm ready to evolve now!"
  --"Hey, I think I can evolve into a {0} now!"
  --"I sense something... getting ready to evolve now"
  --"Did you know?  I'm ready to evolve now!"
  --"What should I evolve into?  Any ideas?"
  --"Oh, I just can't wait till I evolve!"
  --"I'm getting excited just thinking about it!"
  --"I swear to god when I evolve, I am going to kill you all!"

  --"Let's make it all the way to the end!"
  --"I wanna be...[pause=0]\nthe very best..."
  --"You teach me, and I'll teach you."
  --"I'll rescue you and if I do you gotta rescue me."
  --"Who should we recruit next?"
  --"Some apricorns can only recruit certain types of Pokémon.[pause=0] You know that, yes?"
  --"Rumor has it that whoever reaches the summit will be given the title of Guildmaster."
  --"So why do they call you the {0} Pokémon?", DataManager.Instance.GetMonster(character.BaseForm.Species).Title.ToLocal()

  --"Press {0} if you want me to lead the team.", (ii + 1).ToString()
  --"press 1 if you feel bad for [fainted mon]"

  
end

function COMMON.ShowTeamStorageMenu()
  UI:ResetSpeaker()
  
  local state = 0
  
  while state > -1 do
    
	local has_items = GAME:GetPlayerBagCount() + GAME:GetPlayerEquippedCount() > 0
	local has_storage = GAME:GetPlayerStorageCount() > 0
	
	
	local storage_choices = { { STRINGS:FormatKey('MENU_STORAGE_STORE'), has_items},
	{ STRINGS:FormatKey('MENU_STORAGE_TAKE_ITEM'), has_storage},
	{ STRINGS:FormatKey('MENU_STORAGE_STORE_ALL'), has_items},
	{ STRINGS:FormatKey("MENU_STORAGE_MONEY"), true},
	{ STRINGS:FormatKey("MENU_CANCEL"), true}}
	UI:BeginChoiceMenu(STRINGS:FormatKey('DLG_WHAT_DO'), storage_choices, 1, 5)
	UI:WaitForChoice()
	local result = UI:ChoiceResult()
	
	if result == 1 then
	  UI:StorageMenu()
	  UI:WaitForChoice()
	elseif result == 2 then
	  UI:WithdrawMenu()
	  UI:WaitForChoice()
    elseif result == 3 then
	    UI:ChoiceMenuYesNo(STRINGS:FormatKey('DLG_STORE_ALL_CONFIRM'), false);
	    UI:WaitForChoice()
	    if UI:ChoiceResult() then
	      GAME:DepositAll()
	    end
	elseif result == 4 then
	  UI:BankMenu()
	  UI:WaitForChoice()
	
	elseif result == 5 then
	  state = -1
	end
	
  end
  
end

function COMMON.GroundInteract(chara, target)
  GROUND:CharTurnToChar(target, chara)
  UI:SetSpeaker(target)
  
  local mon = _DATA:GetMonster(target.CurrentForm.Species)
  local form = mon.Forms[target.CurrentForm.Form]
  
  local personality = form:GetPersonalityType(target.Data.Discriminator)
  
  local personality_group = COMMON.PERSONALITY[personality]
  local pool = personality_group.WAIT
  local key = "TALK_WAIT_%04d"
  
  local running_pool = {table.unpack(pool)}
  local valid_quote = false
  local chosen_quote = ""
  
  while not valid_quote and #running_pool > 0 do
    valid_quote = true
    local chosen_idx = math.random(1, #running_pool)
	local chosen_pool_idx = running_pool[chosen_idx]
    chosen_quote = RogueEssence.StringKey(string.format(key, chosen_pool_idx)):ToLocal()
	
    chosen_quote = string.gsub(chosen_quote, "%[hero%]", chara:GetDisplayName())
    
	if not valid_quote then
      -- PrintInfo("Rejected "..chosen_quote)
	  table.remove(running_pool, chosen_idx)
	  chosen_quote = ""
	end
  end
  -- PrintInfo("Selected "..chosen_quote)
  
  
  UI:WaitShowDialogue(STRINGS:Format(chosen_quote))
end

function COMMON.Rescued(zone, name, mail)
  

  if _DATA.CurrentReplay ~= nil then
    SOUND:PlayBattleSE("EVT_Title_Intro")
    GAME:FadeOut(true, 0)
    GAME:FadeIn(20)
    SOUND:PlayBGM("C05. Rescue.ogg", true)
	_DUNGEON:LogMsg(STRINGS:FormatKey("MSG_RESCUED_BY", name))
  else
                --//spawn the rescuers based on mail
    local leaderLoc = null;

    local team = RogueEssence.Dungeon.ExplorerTeam()
    team.Name = mail.RescuedBy

                --for (int ii = 0; ii < mail.RescuingTeam.Length; ii++)
                --{
                --    CharData character = new CharData();
                --    character.BaseForm = mail.RescuingTeam[ii];
                --    character.Nickname = mail.RescuingNames[ii];
                --    character.Level = 1;

                --    Character new_mob = new Character(character, team);

                --    Loc? destLoc = ZoneManager.Instance.CurrentMap.GetClosestTileForChar(new_mob, leaderLoc.HasValue ? leaderLoc.Value : ActiveTeam.Leader.CharLoc);

                --    if (destLoc == null)
                --        break;

                --    leaderLoc = destLoc;

                --    team.Players.Add(new_mob);
                --    new_mob.CharLoc = destLoc.Value;
                --    new_mob.CharDir = DirExt.ApproximateDir8(ActiveTeam.Leader.CharLoc - destLoc.Value);
                --    AITactic tactic = DataManager.Instance.GetAITactic(0);
                --    new_mob.Tactic = new AITactic(tactic);
                --}
                --ZoneManager.Instance.CurrentMap.MapTeams.Add(team);

                --//foreach (Character member in team.Players)
                --//    member.RefreshTraits();

    SOUND:PlayBattleSE("EVT_Title_Intro")
    GAME:FadeOut(true, 0)
    GAME:FadeIn(20)
                --yield return CoroutineManager.Instance.StartCoroutine(GameManager.Instance.FadeIn());

    SOUND:PlayBGM("C05. Rescue.ogg", true)
    TASK:WaitTask(_MENU:SetDialogue(STRINGS:FormatKey("MSG_RESCUES_LEFT", _DATA.Save.RescuesLeft)))
    GAME:WaitFrames(10)
  


                --//TODO: make the rescuers talk
                --yield return CoroutineManager.Instance.StartCoroutine(MenuManager.Instance.SetDialogue(team.Leader.Appearance, team.Leader:GetDisplayName(true), new EmoteStyle(Emotion.Normal), true, Text.Format("{0}, right?", ActiveTeam:GetDisplayName())));
                --yield return CoroutineManager.Instance.StartCoroutine(MenuManager.Instance.SetDialogue(team.Leader.Appearance, team.Leader:GetDisplayName(true), new EmoteStyle(Emotion.Normal), true, Text.Format("Glad we could make it! We got your SOS just in time!")));
                --yield return CoroutineManager.Instance.StartCoroutine(MenuManager.Instance.SetDialogue(team.Leader.Appearance, team.Leader:GetDisplayName(true), new EmoteStyle(Emotion.Normal), true, Text.Format("It's all in a day's work for {0}!", team:GetDisplayName())));
                --yield return CoroutineManager.Instance.StartCoroutine(MenuManager.Instance.SetDialogue(team.Leader.Appearance, team.Leader:GetDisplayName(true), new EmoteStyle(Emotion.Normal), true, Text.Format("Good luck, the rest is up to you!")));

                --//warp them out

                --for (int ii = team.Players.Count - 1; ii >= 0; ii--)
                --{
                --    GameManager.Instance.BattleSE("DUN_Send_Home");
                --    SingleEmitter emitter = new SingleEmitter(new BeamAnimData("Column_Yellow", 3));
                --    emitter.Layer = DrawLayer.Front;
                --    emitter.SetupEmit(team.Players[ii].MapLoc, team.Players[ii].MapLoc, team.Players[ii].CharDir);
                --    CreateAnim(emitter, DrawLayer.NoDraw);
                --    yield return CoroutineManager.Instance.StartCoroutine(team.Players[ii].DieSilent());
                --    yield return new WaitForFrames(20);
                --}
                --RemoveDeadTeams();
  end
  
  local rescue_idx = "rescued"
  local rescue_status = RogueEssence.Dungeon.MapStatus(rescue_idx)
  rescue_status:LoadFromData()
  TASK:WaitTask(_DUNGEON:AddMapStatus(rescue_status))
end

function COMMON.EndRescue(zone, result, rescue, segmentID)
  COMMON.EndDayCycle()
  local zoneId = 'guildmaster_island'
  local structureId = -1
  local mapId = 12
  local entryId = 1
  GAME:EndDungeonRun(result, zoneId, structureId, mapId, entryId, true, true)
  SV.General.Rescue = result
  GAME:EnterZone(zoneId, structureId, mapId, entryId)
end

function COMMON.BeginDungeon(zoneId, segmentID, mapId)
  COMMON.EnterDungeonMissionCheck(zoneId, segmentID)
end

function COMMON.EnterDungeonMissionCheck(zoneId, segmentID)
  for name, mission in pairs(SV.missions.Missions) do
    PrintInfo("Checking Mission: "..tostring(name))
	if mission.Complete == 0 and zoneId == mission.DestZone and segmentID == mission.DestSegment then
	  if mission.Type == 1 then -- escort
		
		-- add escort to team
		local mon_id = RogueEssence.Dungeon.MonsterID(mission.EscortSpecies, 0, "normal", Gender.Male)
        local new_mob = _DATA.Save.ActiveTeam:CreatePlayer(_DATA.Save.Rand, mon_id, 50, "", -1)
        _DATA.Save.ActiveTeam.Guests:Add(new_mob)
		
		-- place in a legal position on map
		local dest = _ZONE.CurrentMap:GetClosestTileForChar(new_mob, _DATA.Save.ActiveTeam.Leader.CharLoc)
        local endLoc = _DATA.Save.ActiveTeam.Leader.CharLoc
		if dest ~= nil then
		  endLoc = dest
		end
        new_mob.CharLoc = endLoc
		
		local talk_evt = RogueEssence.Dungeon.BattleScriptEvent("EscortInteract")
        new_mob.ActionEvents:Add(talk_evt)
		
		local tbl = LTBL(new_mob)
		tbl.Escort = name
	    
        UI:ResetSpeaker()
        UI:WaitShowDialogue("Added ".. new_mob.Name .." to the party as a guest.")
	  end
	end
  end
end


function COMMON.ExitDungeonMissionCheck(zoneId, segmentID)
  for name, mission in pairs(SV.missions.Missions) do
    PrintInfo("Checking Mission: "..tostring(name))
	if mission.Complete == 0 and zoneId == mission.DestZone and segmentID == mission.DestSegment then
	  if mission.Type == 1 then -- escort
	    -- remove the escort from the party
		local escort = COMMON.FindMissionEscort(name)
		if escort then
		  _DUNGEON:RemoveChar(escort)
		end
	  end
	end
  end
end



function COMMON.FindMissionEscort(missionId)
  local escort = nil
  PrintInfo("Name: "..missionId)
  local party = GAME:GetPlayerGuestTable()
  for i, p in ipairs(party) do
    local e_tbl = LTBL(p)
	PrintInfo("Escort: "..e_tbl.Escort)
	if e_tbl.Escort == missionId then
	  escort = p
	  break
	end
  end
  return escort
end

function COMMON.EndDungeonDay(result, zoneId, structureId, mapId, entryId)
  COMMON.EndDayCycle()
  GAME:EndDungeonRun(result, zoneId, structureId, mapId, entryId, true, true)
  if GAME:InRogueMode() then
    if result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
      UI:ResetSpeaker()
      local msg = STRINGS:FormatKey("DLG_TRY_AGAIN_ASK");
      UI:ChoiceMenuYesNo(msg, false)
      UI:WaitForChoice()
      result = UI:ChoiceResult()
      GAME:WaitFrames(50);
      if result then
        local config = RogueEssence.Data.RogueConfig.RerollFromOther(_DATA.Save.Config)
        GAME:RestartRogue(config)
      else 
        GAME:RestartToTitle()
      end
    else
      GAME:RestartToTitle()
    end
  else
	  GAME:EnterZone(zoneId, structureId, mapId, entryId)
  end
end

function COMMON.EndSession(result, zoneId, structureId, mapId, entryId)
  GAME:EndDungeonRun(result, zoneId, structureId, mapId, entryId, false, false)
  GAME:EnterZone(zoneId, structureId, mapId, entryId)
end


function COMMON.EndDayCycle()
  --reshuffle items

  SV.adventure.Thief = false
  SV.base_shop = { }
  
  math.randomseed(GAME:GetDailySeed())
  --roll a random index from 1 to length of category
  --add the item in that index category to the shop
  --2 essentials, always
  local type_count = 2
	for ii = 1, type_count, 1 do
		local base_data = COMMON.ESSENTIALS[math.random(1, #COMMON.ESSENTIALS)]
		table.insert(SV.base_shop, base_data)
	end
  
  --1-2 ammo, always
  type_count = math.random(1, 2)
	for ii = 1, type_count, 1 do
		local base_data = COMMON.AMMO[math.random(1, #COMMON.AMMO)]
		table.insert(SV.base_shop, base_data)
	end
  
  --2-3 utilities, always
  type_count = math.random(3, 4)
	for ii = 1, type_count, 1 do
		local base_data = COMMON.UTILITIES[math.random(1, #COMMON.UTILITIES)]
		table.insert(SV.base_shop, base_data)
	end
  
  --1-2 orbs, always
  type_count = math.random(1, 2)
	for ii = 1, type_count, 1 do
		local base_data = COMMON.ORBS[math.random(1, #COMMON.ORBS)]
		table.insert(SV.base_shop, base_data)
	end
  
  --1-2 special item, always
  type_count = math.random(1, 2)
	for ii = 1, type_count, 1 do
		local base_data = COMMON.SPECIAL[math.random(1, #COMMON.SPECIAL)]
		table.insert(SV.base_shop, base_data)
	end
  
  
  local catalog = {}
  
  for ii = 1, #COMMON_GEN.TRADES_RANDOM, 1 do
    local base_data = { Item=COMMON_GEN.TRADES_RANDOM[ii].Item, ReqItem=COMMON_GEN.TRADES_RANDOM[ii].ReqItem }
    
    -- check if the item has been acquired before, or if it's a 1* item and dex has been seen
    if SV.unlocked_trades[COMMON_GEN.TRADES_RANDOM[ii].Item] ~= nil then
      table.insert(catalog, base_data)
    elseif #COMMON_GEN.TRADES_RANDOM[ii].ReqItem == 2 then
      if _DATA.Save:GetMonsterUnlock(COMMON_GEN.TRADES_RANDOM[ii].Dex) == RogueEssence.Data.GameProgress.UnlockState.Discovered then
        table.insert(catalog, base_data)
      end
    end
  end

  SV.base_trades = { }
  if #catalog < 25 then
    type_count = 0
  elseif #catalog < 50 then
    type_count = 1
  elseif #catalog < 75 then
    type_count = 2
  elseif #catalog < 100 then
    type_count = 3
  elseif #catalog < 150 then
    type_count = 4
  elseif #catalog < 250 then
    type_count = 5
  elseif #catalog < 350 then
    type_count = 6
  else
    type_count = 7
  end
  
	for ii = 1, type_count, 1 do
		local idx = math.random(1, #catalog)
		local base_data = catalog[idx]
		table.insert(SV.base_trades, base_data)
		table.remove(catalog, idx)
	end
end
