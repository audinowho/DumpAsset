require 'common'

misc_helpers = {}

STATUS_SCRIPT = {}

function STATUS_SCRIPT.Test(owner, ownerChar, context, args)
  PrintInfo("Test")
end


MAP_STATUS_SCRIPT = {}

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

ITEM_SCRIPT = {}

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
	  _ZONE.CurrentMap.Music = "B24. Castaway Cave 2.ogg"
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
    if context.Item.Value == "box_deluxe" then
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
	  _ZONE.CurrentMap.Music = "B11. Enraged Caldera.ogg"
	  
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
		end
	  end
	  
	  --set the tileset dictionary to lava
	  _ZONE.CurrentMap.BlankBG = RogueEssence.Dungeon.AutoTile("deep_dark_crater_wall")
	  _ZONE.CurrentMap.TextureMap["unbreakable"] = RogueEssence.Dungeon.AutoTile("deep_dark_crater_wall")
	  _ZONE.CurrentMap.TextureMap["wall"] = RogueEssence.Dungeon.AutoTile("deep_dark_crater_wall")
	  _ZONE.CurrentMap.TextureMap["floor"] = RogueEssence.Dungeon.AutoTile("deep_dark_crater_floor")
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

function ITEM_SCRIPT.MissionItemPickup(owner, ownerChar, context, args)
	local mission_num = args.Mission
	local mission = SV.TakenBoard[mission_num]
	if mission.Item == context.Item.Value then
		mission.Completion = COMMON.MISSION_COMPLETE
		SV.TemporaryFlags.MissionCompleted = true
		GAME:WaitFrames(70)
		UI:ResetSpeaker()
		UI:WaitShowDialogue("Yes! You found " .. _DATA:GetMonster(mission.Client):GetColoredName() .. "'s " .. context.Item:GetDungeonName() .. "!")
		--Clear but remember minimap state
		SV.TemporaryFlags.PriorMapSetting = _DUNGEON.ShowMap
		_DUNGEON.ShowMap = _DUNGEON.MinimapState.None

		--Slight pause before asking to warp out 
		GAME:WaitFrames(20)
		COMMON.AskMissionWarpOut()
	end
end

function ITEM_SCRIPT.OutlawItemPickup(owner, ownerChar, context, args)
	local mission_num = args.Mission
	local mission = SV.TakenBoard[mission_num]
	if mission.Item == context.Item.Value then
		SV.OutlawItemPickedUp = true
	end
end

REFRESH_SCRIPT = {}

function REFRESH_SCRIPT.Test(owner, ownerChar, character, args)
  PrintInfo("Test")
end


SKILL_CHANGE_SCRIPT = {}

function SKILL_CHANGE_SCRIPT.Test(owner, character, skillIndices, args)
  PrintInfo("Test")
end




