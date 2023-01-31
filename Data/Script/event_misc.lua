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
    UI:WaitShowDialogue(RogueEssence.StringKey(string.format("TALK_SHOP_START_%04d", found_shopkeep.Discriminator)):ToLocal())
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
	TASK:WaitTask(found_shopkeep:AddStatusEffect(nil, berserk, nil))
  end
  -- force everyone to skip their turn for this entire session
  _ZONE.CurrentMap.CurrentTurnMap:SkipRemainingTurns()
end

ITEM_SCRIPT = {}

function ITEM_SCRIPT.Test(owner, ownerChar, context, args)
  local text = "You got a " .. context.Item:GetDungeonName()
  local notice = _MENU:CreateNotice("Test", text)
  _DUNGEON.PendingLeaderAction = _MENU:ProcessMenuCoroutine(notice)
end

function misc_helpers.ShimmerBayShift()
  GAME:WaitFrames(60)
  _ZONE.CurrentMap.Music = "B24. Shimmer Bay 2.ogg"
  SOUND:PlayBGM(_ZONE.CurrentMap.Music, true)
  _ZONE.CurrentMap.MapEffect.OnMapTurnEnds:Add(RogueElements.Priority(15), PMDC.Dungeon.RespawnFromEligibleEvent(14, 160))
  for ii = 1, 3, 1 do
	PMDC.Dungeon.RespawnFromEligibleEvent.Respawn()
  end
end

function ITEM_SCRIPT.ShimmerBayShift(owner, ownerChar, context, args)
  if not SV.shimmer_bay.TookTreasure then
    if context.Item.Value == "egg_mystery" or context.Item.Value == "box_deluxe" then
	  SV.shimmer_bay.TookTreasure = true
	  
	end
  end
end

function misc_helpers.SleepingCalderaShift()
  SOUND:PlayBGM("", false)
  GAME:WaitFrames(60)
  --TODO: rumble, make everyone shocked
  GAME:FadeOut(true, 60)
  --set name to enraged caldera
  _ZONE.CurrentMap.Name = RogueEssence.LocalText(RogueEssence.StringKey("TITLE_ENRAGED_CALDERA"):ToLocal())
  _ZONE.CurrentMap.Music = "B11. Enraged Caldera.ogg"
  SOUND:PlayBGM(_ZONE.CurrentMap.Music, true)
  
  --set all water tiles to lava
  for xx = 0, _ZONE.CurrentMap.Width - 1, 1 do
	for yy = 0, _ZONE.CurrentMap.Height - 1, 1 do
	  local loc = RogueElements.Loc(xx, yy)
	  local tl = _ZONE.CurrentMap:GetTile()
	  if tl.ID == "water" then
		tl.ID = "lava"
		--remove any mons traversing them
		local chara = _ZONE.CurrentMap:GetCharAtLoc(loc)
		if chara ~= nil then
		  _DUNGEON:RemoveChar(chara)
		end
	  end
	end
  end
  
  --set the tileset dictionary to lava
  _ZONE.CurrentMap.TextureMap["unbreakable"] = RogueEssence.Dungeon.AutoTile("dark_crater_wall")
  _ZONE.CurrentMap.TextureMap["wall"] = RogueEssence.Dungeon.AutoTile("dark_crater_wall")
  _ZONE.CurrentMap.TextureMap["floor"] = RogueEssence.Dungeon.AutoTile("dark_crater_floor")
  --call mapmodified for the entire map
  
  _ZONE.CurrentMap.MapEffect.OnMapTurnEnds:Add(RogueElements.Priority(15), PMDC.Dungeon.RespawnFromEligibleEvent(15, 50))
  for ii = 1, 3, 1 do
	PMDC.Dungeon.RespawnFromEligibleEvent.Respawn()
  end
  
  GAME:FadeIn(60)
end

function ITEM_SCRIPT.SleepingCalderaShift(owner, ownerChar, context, args)
  if not SV.sleeping_caldera.TookTreasure then
    if context.Item.Value == "box_deluxe" then
	  SV.sleeping_caldera.TookTreasure = true
	  

	end
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




