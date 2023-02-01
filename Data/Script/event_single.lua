require 'common'

SINGLE_CHAR_SCRIPT = {}

function SINGLE_CHAR_SCRIPT.Test(owner, ownerChar, context, args)
  PrintInfo("Test")
end


function SINGLE_CHAR_SCRIPT.ShimmerBayAltMusic(owner, ownerChar, context, args)
  if context.User ~= nil then
    return
  end
  if not SV.shimmer_bay.TookTreasure then
    --keep the map music as is
  else
	_ZONE.CurrentMap.Music = "B24. Shimmer Bay 2.ogg"
  end
  
  SOUND:PlayBGM(_ZONE.CurrentMap.Music, true)
end


function SINGLE_CHAR_SCRIPT.ShimmerBayAltEnemies(owner, ownerChar, context, args)
  if context.User ~= nil then
    return
  end
  if not SV.shimmer_bay.TookTreasure then
    return
  end
  
  _ZONE.CurrentMap.MapEffect.OnMapTurnEnds:Add(RogueElements.Priority(15), PMDC.Dungeon.RespawnFromEligibleEvent(14, 160))
  for ii = 1, 3, 1 do
	PMDC.Dungeon.RespawnFromEligibleEvent.Respawn()
  end
end



function SINGLE_CHAR_SCRIPT.SleepingCalderaAltData(owner, ownerChar, context, args)
  if context.User ~= nil then
    return
  end
  if not SV.sleeping_caldera.TookTreasure then
    --keep the map music as is
  else
	_ZONE.CurrentMap.Name = RogueEssence.LocalText(STRINGS:Format(RogueEssence.StringKey("TITLE_ENRAGED_CALDERA"):ToLocal(), _ZONE.CurrentMap.ID + 1))
	_ZONE.CurrentMap.Music = "B11. Enraged Caldera.ogg"
  end
  
  SOUND:PlayBGM(_ZONE.CurrentMap.Music, true)
end

function SINGLE_CHAR_SCRIPT.SleepingCalderaAltTiles(owner, ownerChar, context, args)
  if context.User ~= nil then
    return
  end
  if not SV.sleeping_caldera.TookTreasure then
    return
  end
  
  --set all water tiles to lava
  for xx = 0, _ZONE.CurrentMap.Width - 1, 1 do
	for yy = 0, _ZONE.CurrentMap.Height - 1, 1 do
	  local loc = RogueElements.Loc(xx, yy)
	  local tl = _ZONE.CurrentMap:GetTile(loc)
	  if tl.ID == "water" then
		tl.ID = "lava"
		--remove any mons traversing them
		local chara = _ZONE.CurrentMap:GetCharAtLoc(loc)
		if chara ~= nil then
		  if chara.MemberTeam ~= _DUNGEON.ActiveTeam then
			_DUNGEON:RemoveChar(chara)
		  end
		end
	  end
	  --also remove any stairs down
	  if tl.Effect.ID == "stairs_go_down" then
		tl.Effect = RogueEssence.Dungeon.EffectTile(loc)
	  end
	end
  end
  --set the tileset dictionary to lava
  if _ZONE.CurrentMap.ID < 6 then
    _ZONE.CurrentMap.BlankBG = RogueEssence.Dungeon.AutoTile("dark_crater_wall")
    _ZONE.CurrentMap.TextureMap["unbreakable"] = RogueEssence.Dungeon.AutoTile("dark_crater_wall")
    _ZONE.CurrentMap.TextureMap["wall"] = RogueEssence.Dungeon.AutoTile("dark_crater_wall")
    _ZONE.CurrentMap.TextureMap["floor"] = RogueEssence.Dungeon.AutoTile("dark_crater_floor")
  else
    _ZONE.CurrentMap.BlankBG = RogueEssence.Dungeon.AutoTile("deep_dark_crater_wall")
    _ZONE.CurrentMap.TextureMap["unbreakable"] = RogueEssence.Dungeon.AutoTile("deep_dark_crater_wall")
    _ZONE.CurrentMap.TextureMap["wall"] = RogueEssence.Dungeon.AutoTile("deep_dark_crater_wall")
    _ZONE.CurrentMap.TextureMap["floor"] = RogueEssence.Dungeon.AutoTile("deep_dark_crater_floor")
  end
  --call recalculate all autotiles for the entire map
  _ZONE.CurrentMap:CalculateAutotiles(RogueElements.Loc(0, 0), RogueElements.Loc(_ZONE.CurrentMap.Width, _ZONE.CurrentMap.Height))
  _ZONE.CurrentMap:CalculateTerrainAutotiles(RogueElements.Loc(0, 0), RogueElements.Loc(_ZONE.CurrentMap.Width, _ZONE.CurrentMap.Height))
end

function SINGLE_CHAR_SCRIPT.SleepingCalderaAltEnemies(owner, ownerChar, context, args)
  if context.User ~= nil then
    return
  end
  if not SV.sleeping_caldera.TookTreasure then
    return
  end
  
  _ZONE.CurrentMap.MapEffect.OnMapTurnEnds:Add(RogueElements.Priority(15), PMDC.Dungeon.RespawnFromEligibleEvent(15, 50))
  for ii = 1, 3, 1 do
	PMDC.Dungeon.RespawnFromEligibleEvent.Respawn()
  end
end

function SINGLE_CHAR_SCRIPT.SleepingCalderaSummonHeatran(owner, ownerChar, context, args)
  if context.User ~= nil then
    return
  end
  if not SV.sleeping_caldera.TookTreasure then
    return
  end
  
  if SV.sleeping_caldera.GotHeatran then
    return
  end
  
  -- spawn heatran- try 10 times; not guaranteed but not crucial
  local origin = _DUNGEON.ActiveTeam.Leader.CharLoc
  for ii = 1, 10, 1 do
    local testLoc = RogueElements.Loc(_DATA.Save.Rand:Next(origin.X - 7, origin.X + 7 + 1), _DATA.Save.Rand:Next(origin.Y - 4, origin.Y + 4 + 1))
	local tile_block = _ZONE.CurrentMap:TileBlocked(testLoc)
	local char_at = _ZONE.CurrentMap:GetCharAtLoc(testLoc)
	if tile_block == false and char_at == nil then
	  --spawn it here
	  DUNGEON:MoveScreen(RogueEssence.Content.ScreenMover(3, 6, 30))
	  GAME:WaitFrames(10)
	  
	  local new_team = RogueEssence.Dungeon.MonsterTeam()
	  local mob_data = RogueEssence.Dungeon.CharData()
	  mob_data.BaseForm = RogueEssence.Dungeon.MonsterID("heatran", 0, "normal", Gender.Male)
	  mob_data.Level = 40;
	  mob_data.BaseSkills[0] = RogueEssence.Dungeon.SlotSkill("magma_storm")
	  mob_data.BaseSkills[1] = RogueEssence.Dungeon.SlotSkill("iron_head")
	  mob_data.BaseSkills[2] = RogueEssence.Dungeon.SlotSkill("scary_face")
	  mob_data.BaseSkills[3] = RogueEssence.Dungeon.SlotSkill("crunch")
	  mob_data.BaseIntrinsics[0] = "flash_fire"
	  local new_mob = RogueEssence.Dungeon.Character(mob_data)
	  local tactic = _DATA:GetAITactic("wander_smart")
	  new_mob.Tactic = RogueEssence.Data.AITactic(tactic)
	  new_mob.CharLoc = testLoc
	  new_mob.CharDir = _ZONE.CurrentMap:ApproximateClosestDir8(new_mob.CharLoc, _DUNGEON.ActiveTeam.Leader.CharLoc)
	  new_team.Players:Add(new_mob)
	  player_tbl = LTBL(new_mob)
	  player_tbl.IsLegend = true
	  
	  --with fanfare
	  SOUND:PlayBattleSE("_UNK_EVT_003")
	  local arriveAnim = RogueEssence.Content.StaticAnim(RogueEssence.Content.AnimData("Sacred_Fire_Ranger", 3), 1)
	  arriveAnim:SetupEmitted(RogueElements.Loc(new_mob.CharLoc.X * 24, new_mob.CharLoc.Y * 24), 32, RogueElements.Dir8.Down)
	  DUNGEON:PlayVFXAnim(arriveAnim, RogueEssence.Content.DrawLayer.Front)
	  
	  GAME:WaitFrames(3)
	  
	  _ZONE.CurrentMap.MapTeams:Add(new_team)
	  new_mob:RefreshTraits()
	  
      TASK:WaitTask(_DUNGEON:SpecialIntro(new_mob))
      TASK:WaitTask(new_mob:OnMapStart())
	  
	  _ZONE.CurrentMap:UpdateExploration(new_mob)
	  
	  break
	end
  end
  
end

function SINGLE_CHAR_SCRIPT.GuildBlock(owner, ownerChar, character, args)
  
  if not SV.guildmaster_summit.BattleComplete then
    UI:SetAutoFinish(true)
    UI:WaitShowDialogue(RogueEssence.StringKey("DLG_LOCK_GUILD"):ToLocal())
  else
    UI:ResetSpeaker()
    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey("DLG_LOCK_GUILD_OPEN"):ToLocal(), character:GetDisplayName(true)))
    TASK:WaitTask(owner:InteractWithTile(character))
  end
end

ShopSecurityType = luanet.import_type('PMDC.Dungeon.ShopSecurityState')
MapIndexType = luanet.import_type('RogueEssence.Dungeon.MapIndexState')


function SINGLE_CHAR_SCRIPT.ThiefCheck(owner, ownerChar, context, args)
  local baseLoc = _DUNGEON.ActiveTeam.Leader.CharLoc
  local tile = _ZONE.CurrentMap.Tiles[baseLoc.X][baseLoc.Y]
  
  local thief_idx = "thief"
  
  local price = COMMON.GetDungeonCartPrice()
  local security_price = COMMON.GetShopPriceState()
  if price < 0 then
    --lost merchandise was placed back in shop, readjust the security price and clear the current price
    security_price.Amount = security_price.Amount - price
  elseif price < security_price.Cart then
    --merchandise was returned.  doesn't matter who did it.
    security_price.Cart = price
  elseif price > security_price.Cart then
    local char_index = _ZONE.CurrentMap:GetCharIndex(context.User)
    if char_index.Faction ~= RogueEssence.Dungeon.Faction.Player then
      --non-player was responsible for taking/destroying merchandise, just readjust the security price and clear the current price
      security_price.Amount = security_price.Amount - price + security_price.Cart
	else
	  --player was responsible for taking/destroying merchandise, add to the cart
      security_price.Cart = price
    end
  end

  
  if tile.Effect.ID ~= "area_shop" then
	if security_price.Cart > 0 then
	  _GAME:BGM("", false)
      COMMON.ClearAllPrices()
	  
	  SV.adventure.Thief = true
	  local index_from = owner.StatusStates:Get(luanet.ctype(MapIndexType))
	  _DUNGEON:LogMsg(RogueEssence.StringKey(string.format("TALK_SHOP_THIEF_%04d", index_from.Index)):ToLocal())
		
	  -- create thief status
	  local thief_status = RogueEssence.Dungeon.MapStatus(thief_idx)
      thief_status:LoadFromData()
	  -- put spawner from security status in thief status
	  local security_to = thief_status.StatusStates:Get(luanet.ctype(ShopSecurityType))
	  local security_from = owner.StatusStates:Get(luanet.ctype(ShopSecurityType))
	  security_to.Security = security_from.Security
      TASK:WaitTask(_DUNGEON:RemoveMapStatus(owner.ID))
      TASK:WaitTask(_DUNGEON:AddMapStatus(thief_status))
	  GAME:WaitFrames(60)
	end
  else
    local shop_idx = "shopping"
	if not _ZONE.CurrentMap.Status:ContainsKey(thief_idx) and not _ZONE.CurrentMap.Status:ContainsKey(shop_idx) then
	  
	  local shop_status = RogueEssence.Dungeon.MapStatus(shop_idx)
      shop_status:LoadFromData()
      TASK:WaitTask(_DUNGEON:AddMapStatus(shop_status))
	end
  end
end

function SINGLE_CHAR_SCRIPT.ShopCheckout(owner, ownerChar, context, args)
  local baseLoc = _DUNGEON.ActiveTeam.Leader.CharLoc
  local tile = _ZONE.CurrentMap.Tiles[baseLoc.X][baseLoc.Y]

  if tile.Effect.ID ~= "area_shop" then
	local found_shopkeep = COMMON.FindNpcWithTable(false, "Role", "Shopkeeper")
    if found_shopkeep and COMMON.CanTalk(found_shopkeep) then
	  local security_state = COMMON.GetShopPriceState()
      local price = security_state.Cart
	  local sell_price = COMMON.GetDungeonSellPrice()
  
      if price > 0 or sell_price > 0 then
	    local is_near = false
		local loc_diff = _DUNGEON.ActiveTeam.Leader.CharLoc - found_shopkeep.CharLoc
		if loc_diff:Dist8() > 1 then
		  -- check to see if the shopkeeper can see the player and warp there
		  local near_mat = false
		  local dirs = { Direction.Down, Direction.DownLeft, Direction.Left, Direction.UpLeft, Direction.Up, Direction.UpRight, Direction.Right, Direction.DownRight }
		  for idx, dir in pairs(dirs) do
            if COMMON.ShopTileCheck(baseLoc, dir) then
		      near_mat = true
		    end
		  end
		  
		  if (near_mat or found_shopkeep:CanSeeCharacter(_DUNGEON.ActiveTeam.Leader)) then
	        -- attempt to warp the shopkeeper next to the player
		    local cand_locs = _ZONE.CurrentMap:FindNearLocs(found_shopkeep, baseLoc, 1)
		    if cand_locs.Count > 0 then
		      TASK:WaitTask(_DUNGEON:PointWarp(found_shopkeep, cand_locs[0], false))
			  is_near = true
		    end
		  end
		else
		  is_near = true
		end

		-- if it can't, fall through
		if is_near then
		  DUNGEON:CharTurnToChar(found_shopkeep, _DUNGEON.ActiveTeam.Leader)
		  DUNGEON:CharTurnToChar(_DUNGEON.ActiveTeam.Leader, found_shopkeep)
          UI:SetSpeaker(found_shopkeep)
		  
		  if sell_price > 0 then
		    UI:ChoiceMenuYesNo(STRINGS:Format(RogueEssence.StringKey(string.format("TALK_SHOP_SELL_%04d", found_shopkeep.Discriminator)):ToLocal(), STRINGS:FormatKey("MONEY_AMOUNT", sell_price)), false)
		    UI:WaitForChoice()
		    result = UI:ChoiceResult()
		  
		    if SV.adventure.Thief then
			  COMMON.ThiefReturn()
		    elseif result then
			  -- iterate player inventory prices and remove total price
			  COMMON.PayDungeonSellPrice(sell_price)
			  SOUND:PlayBattleSE("DUN_Money")
			  UI:WaitShowDialogue(RogueEssence.StringKey(string.format("TALK_SHOP_SELL_DONE_%04d", found_shopkeep.Discriminator)):ToLocal())
		    else
			  -- nothing
		    end
		  end
		  
		  if price > 0 then
	        UI:ChoiceMenuYesNo(STRINGS:Format(RogueEssence.StringKey(string.format("TALK_SHOP_PAY_%04d", found_shopkeep.Discriminator)):ToLocal(), STRINGS:FormatKey("MONEY_AMOUNT", price)), false)
	        UI:WaitForChoice()
	        result = UI:ChoiceResult()
	        if SV.adventure.Thief then
			  COMMON.ThiefReturn()
		    elseif result then
	          if price > GAME:GetPlayerMoney() then
                UI:WaitShowDialogue(RogueEssence.StringKey(string.format("TALK_SHOP_PAY_SHORT_%04d", found_shopkeep.Discriminator)):ToLocal())
	          else
	            -- iterate player inventory prices and remove total price
                COMMON.PayDungeonCartPrice(price)
		        SOUND:PlayBattleSE("DUN_Money")
	            UI:WaitShowDialogue(RogueEssence.StringKey(string.format("TALK_SHOP_PAY_DONE_%04d", found_shopkeep.Discriminator)):ToLocal())
	          end
	        end
		  end
		end
      else
        UI:SetSpeaker(found_shopkeep)
        UI:WaitShowDialogue(RogueEssence.StringKey(string.format("TALK_SHOP_END_%04d", found_shopkeep.Discriminator)):ToLocal())
      end
	end
  end
end

function SINGLE_CHAR_SCRIPT.DestinationFloor(owner, ownerChar, context, args)
  if context.User ~= nil then
    return
  end
  SOUND:PlayFanfare("Fanfare/Note")
  UI:ResetSpeaker()
  UI:WaitShowDialogue("You've reached a destination floor!")
end


function SINGLE_CHAR_SCRIPT.OutlawFloor(owner, ownerChar, context, args)
  if context.User ~= nil then
    return
  end
  SOUND:PlayBGM("C07. Outlaw.ogg", false)
  UI:ResetSpeaker()
  UI:WaitShowDialogue("Wanted outlaw spotted!")
  
  -- add a map status for outlaw clear check
  local checkClearStatus = "outlaw_clear_check" -- outlaw clear check
  local status = RogueEssence.Dungeon.MapStatus(checkClearStatus)
  status:LoadFromData()
  TASK:WaitTask(_DUNGEON:AddMapStatus(status))
end

function SINGLE_CHAR_SCRIPT.OutlawClearCheck(owner, ownerChar, context, args)
  -- check for no outlaw in the mission list
  remaining_outlaw = false
  for name, mission in pairs(SV.missions.Missions) do
    PrintInfo("Checking Mission: "..tostring(name))
    if mission.Complete == COMMON.MISSION_INCOMPLETE and _ZONE.CurrentZoneID == mission.DestZone
	  and _ZONE.CurrentMapID.Segment == mission.DestSegment and _ZONE.CurrentMapID.ID == mission.DestFloor then
	  local found_outlaw = COMMON.FindNpcWithTable(true, "Mission", name)
      if found_outlaw then
	    remaining_outlaw = true
	  else
	    -- if no outlaws of the mission list, mark quest as complete
		mission.Complete = 1
		UI:ResetSpeaker()
        UI:WaitShowDialogue("Mission status set to complete. Return to quest giver for reward.")
	  end
    end
  end
  if not remaining_outlaw then
    -- if no outlaws are found in the map, return music to normal and remove this status from the map
    SOUND:PlayBGM(_ZONE.CurrentMap.Music, true)
    local checkClearStatus = "outlaw_clear_check" -- outlaw clear check
	TASK:WaitTask(_DUNGEON:RemoveMapStatus(checkClearStatus))
  end
end


