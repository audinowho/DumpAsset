require 'origin.common'

function STATUS_SCRIPT.Test(owner, ownerChar, context, args)
  PrintInfo("Test")
end


function MAP_STATUS_SCRIPT.Test(owner, ownerChar, character, status, msg, args)
  PrintInfo("Test")
end


function MAP_STATUS_SCRIPT.ShopGreeting(owner, ownerChar, character, status, msg, args)
  
  if status ~= owner or character ~= nil then
    return
  end
  local found_shopkeep = COMMON.FindNpcWithTable(false, "Role", "Shopkeeper")
  if found_shopkeep and COMMON.CanTalk(found_shopkeep) then
    DUNGEON:CharTurnToChar(found_shopkeep, _DUNGEON.ActiveTeam.Leader)
    UI:SetSpeaker(found_shopkeep)
    UI:WaitShowDialogue(STRINGS:Format(RogueEssence.StringKey(string.format("TALK_SHOP_START_%04d", found_shopkeep.Discriminator)):ToLocal()))
	GAME:WaitFrames(10)
  end
end


function MAP_STATUS_SCRIPT.SetShopkeeperHostile(owner, ownerChar, character, status, msg, args)
  
  if status ~= owner or character ~= nil then
    return
  end
  local found_shopkeep = COMMON.FindNpcWithTable(false, "Role", "Shopkeeper")
  if found_shopkeep then
    local teamIndex = _ZONE.CurrentMap.AllyTeams:IndexOf(found_shopkeep.MemberTeam)
	_DUNGEON:RemoveTeam(RogueEssence.Dungeon.Faction.Friend, teamIndex)
	_DUNGEON:AddTeam(RogueEssence.Dungeon.Faction.Foe, found_shopkeep.MemberTeam)
	local tactic = _DATA:GetAITactic("shopkeeper") -- shopkeeper attack tactic
	found_shopkeep.Tactic = RogueEssence.Data.AITactic(tactic)
	found_shopkeep.Tactic:Initialize(found_shopkeep)
	
	local berserk_idx = "shopkeeper"
	local berserk = RogueEssence.Dungeon.StatusEffect(berserk_idx)
	TASK:WaitTask(found_shopkeep:AddStatusEffect(nil, berserk, false))
  end
  -- force everyone to skip their turn for this entire session
  _DUNGEON:SkipRemainingTurns()
end

function ITEM_SCRIPT.Test(owner, ownerChar, context, args)
  PrintInfo("Test")
  local text = "You got a " .. context.Item:GetDungeonName()
  local notice = _MENU:CreateNotice("Test", text)
  TASK:WaitTask(_MENU:ProcessMenuCoroutine(notice))
end

function ITEM_SCRIPT.CastawayCaveShift(owner, ownerChar, context, args)
  if not SV.castaway_cave.TookTreasure then
    if (context.Item.Value == "egg_mystery" or context.Item.Value == "box_deluxe") and context.Item.HiddenValue == "empty" then
	  SV.castaway_cave.TookTreasure = true
	  GAME:WaitFrames(60)
	  _ZONE.CurrentMap.Music = "Castaway Cave 2.ogg"
	  SOUND:PlayBGM(_ZONE.CurrentMap.Music, true)
	  _ZONE.CurrentMap.MapEffect.OnMapTurnEnds:Add(RogueElements.Priority(15), PMDC.Dungeon.RespawnFromEligibleEvent(9, 50))
	  for ii = 1, 3, 1 do
		PMDC.Dungeon.RespawnFromEligibleEvent.Respawn()
	  end
	end
  end
end

function ITEM_SCRIPT.SleepingCalderaShift(owner, ownerChar, context, args)
  if not SV.sleeping_caldera.TookTreasure then
    if context.Item.Value == "box_deluxe" or context.Item.Value == "loot_secret_slab" then
	  SV.sleeping_caldera.TookTreasure = true
	  GAME:WaitFrames(60)
	  SOUND:PlayBGM("", false)
	  --rumble
	  DUNGEON:MoveScreen(RogueEssence.Content.ScreenMover(3, 6, 120))
	  SOUND:LoopBattleSE("EVT_Tower_Tremor_Weak")
	  --make everyone shocked
      local emoteData = _DATA:GetEmote("shock")
	  local player_count = _DUNGEON.ActiveTeam.Players.Count
	  for player_idx = 0, player_count-1, 1 do
	    player = _DUNGEON.ActiveTeam.Players[player_idx]
	    player:StartEmote(RogueEssence.Content.Emote(emoteData.Anim, emoteData.LocHeight, 1))
	  end
	  
	  GAME:WaitFrames(120)
	  SOUND:PlayBattleSE("_UNK_EVT_003")
	  SOUND:StopBattleSE("EVT_Tower_Tremor_Weak")
	  DUNGEON:MoveScreen(RogueEssence.Content.ScreenMover(6, 9, 30))
	  GAME:FadeOut(true, 30)
	  --set name to enraged caldera
	  _ZONE.CurrentMap.Name = RogueEssence.LocalText(STRINGS:Format(RogueEssence.StringKey("TITLE_ENRAGED_CALDERA"):ToLocal(), _ZONE.CurrentMap.ID + 1))
	  _ZONE.CurrentMap.Music = "Enraged Caldera.ogg"
	  
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
		  if tl.Effect.ID == "stairs_go_down" or tl.Effect.ID == "tile_boss" then
			tl.Effect = RogueEssence.Dungeon.EffectTile(loc)
		  end
		end
	  end
	  
	  --set the tileset dictionary to lava
	  if _ZONE.CurrentMap.ID < 14 then
	    _ZONE.CurrentMap.BlankBG = RogueEssence.Dungeon.AutoTile("deep_dark_crater_wall")
	    _ZONE.CurrentMap.TextureMap["unbreakable"] = RogueEssence.Dungeon.AutoTile("deep_dark_crater_wall")
	    _ZONE.CurrentMap.TextureMap["wall"] = RogueEssence.Dungeon.AutoTile("deep_dark_crater_wall")
	    _ZONE.CurrentMap.TextureMap["floor"] = RogueEssence.Dungeon.AutoTile("deep_dark_crater_floor")
	  else
	    _ZONE.CurrentMap.BlankBG = RogueEssence.Dungeon.AutoTile("magma_cavern_3_wall")
	    _ZONE.CurrentMap.TextureMap["unbreakable"] = RogueEssence.Dungeon.AutoTile("magma_cavern_3_wall")
	    _ZONE.CurrentMap.TextureMap["wall"] = RogueEssence.Dungeon.AutoTile("magma_cavern_3_wall")
	    _ZONE.CurrentMap.TextureMap["floor"] = RogueEssence.Dungeon.AutoTile("magma_cavern_3_floor")
	  end
	  --call recalculate all autotiles for the entire map
	  _ZONE.CurrentMap:CalculateAutotiles(RogueElements.Loc(0, 0), RogueElements.Loc(_ZONE.CurrentMap.Width, _ZONE.CurrentMap.Height))
	  _ZONE.CurrentMap:CalculateTerrainAutotiles(RogueElements.Loc(0, 0), RogueElements.Loc(_ZONE.CurrentMap.Width, _ZONE.CurrentMap.Height))
	  
	  _ZONE.CurrentMap.MapEffect.OnMapTurnEnds:Add(RogueElements.Priority(15), PMDC.Dungeon.RespawnFromEligibleEvent(15, 160))
	  for ii = 1, 3, 1 do
		PMDC.Dungeon.RespawnFromEligibleEvent.Respawn()
	  end
	  
	  GAME:WaitFrames(30)
	  SOUND:PlayBGM(_ZONE.CurrentMap.Music, true)
	  GAME:FadeIn(60)
	end
  end
end

function GROUND_ITEM_EVENT_SCRIPT.GroundSlabEvent(context, args)
  
  local chara = CH("PLAYER")
  SOUND:PlayBattleSE("EVT_Emote_Confused")
  GROUND:CharSetEmote(chara, "question", 1)
  GAME:WaitFrames(60)
  
  local total_str = ""
  
  local current_ground = GAME:GetCurrentGround()
  if current_ground.AssetName == "guildmaster_summit" and SV.secret.New == false then
    total_str = total_str .. STRINGS:Format(RogueEssence.StringKey("SIGN_SLAB_MYTH_NEW"):ToLocal()) .. "\n"
  end
  
  if current_ground.AssetName == "luminous_spring" and SV.secret.Time == false then
    total_str = total_str .. STRINGS:Format(RogueEssence.StringKey("SIGN_SLAB_MYTH_TIME"):ToLocal()) .. "\n"
  end
  
  if current_ground.AssetName == "rest_stop" and SV.secret.Wish == false then
    total_str = total_str .. STRINGS:Format(RogueEssence.StringKey("SIGN_SLAB_MYTH_WISH"):ToLocal()) .. "\n"
  end
  
  total_str = STRINGS:ShiftString(total_str, 57344)
  
  SOUND:PlaySE("Menu/Skip")
  UI:SetCustomMenu(_MENU:CreateNotice(context.Item:GetDisplayName(), total_str))
  UI:WaitForChoice()
end

function REFRESH_SCRIPT.Test(owner, ownerChar, character, args)
  PrintInfo("Test")
end


function SKILL_CHANGE_SCRIPT.Test(owner, character, skillIndices, args)
  PrintInfo("Test")
end




