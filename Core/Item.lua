local addonName, ham = ...

ham.Item = {}

-- What a food or drink item restores over the whole eat, from its tags: hp / mp flat totals,
-- hpPct / mpPct shares of maximum health / mana, scaled = true when the amount follows the player's
-- level. A flavor whose client differs has a table of its own under its name ({ hp = 552,
-- forever = { hp = 243.6 } }), whose amounts replace the item's there. scripts/wago_check.py
-- checks them against client data.
local RESTORE_KEYS = { "hp", "mp", "hpPct", "mpPct", "scaled" }

-- The item's table for the current flavor, nil without one.
local function flavorTags(tags)
  local own = ham.flavor and tags[ham.flavor]
  if type(own) == "table" then return own end
end

local function restoresOf(tags)
  local own = tags
  local flavorOwn = flavorTags(tags)
  if flavorOwn then
    for _, key in ipairs(RESTORE_KEYS) do
      if flavorOwn[key] ~= nil then own = flavorOwn break end
    end
  end
  local restores = {}
  for _, key in ipairs(RESTORE_KEYS) do restores[key] = own[key] end
  return restores
end

-- Buff food's buff kinds (GLOSSARY.md), { [kind] = true }: its buff tag ({ buff = { ap = true } }),
-- or the one in the flavor's table where the buff differs there. Buff food without one counts as
-- Other. scripts/wago_check.py checks them against client data (ADR 0002).
local OTHER_ONLY = { other = true }

local function buffKindsOf(tags)
  if not tags.buffFood then return nil end
  local flavorOwn = flavorTags(tags)
  return (flavorOwn and flavorOwn.buff) or tags.buff or OTHER_ONLY
end

-- Unusable items (GLOSSARY.md) -----------------------------------------------------------------

-- The player's level, read on first use and kept current by PLAYER_LEVEL_UP and
-- PLAYER_LEVEL_CHANGED (Party Sync and the like), which pass the new level (UnitLevel can still
-- report the old one while PLAYER_LEVEL_UP runs).
local playerLevel

-- { [itemId] = true } for the items whose required level the item cache didn't have yet
local waitingForInfo = {}

-- After GET_ITEM_INFO_RECEIVED: true when an item whose usability wasn't known yet loaded.
function ham.Item.infoReceived(itemId)
  if not waitingForInfo[itemId] then return false end
  waitingForInfo[itemId] = nil
  return true
end

function ham.Item.setPlayerLevel(level)
  playerLevel = level
end

local function currentPlayerLevel()
  if not playerLevel or playerLevel == 0 then playerLevel = UnitLevel("player") end
  return playerLevel
end

-- First Aid: the skill line bandages require (Forever's own is 2942) and the spell that teaches
-- its first rank, named like the skill line in every locale, for the clients that list skills
-- by name only.
local FIRST_AID_SKILL = ham.isForever and 2942 or 129
local FIRST_AID_SPELL = 3273

-- The player's First Aid rank: 0 without the skill, nil while it can't be told (Retail, which has
-- no First Aid, or a client that hasn't listed the skills yet), which leaves every bandage usable.
local function readFirstAidRank()
  if ham.isRetail then return nil end
  -- Forever
  if C_SkillInfo and C_SkillInfo.GetSkillLineInfoByID then
    if C_SkillInfo.GetNumSkillLines() == 0 then return nil end
    local info = C_SkillInfo.GetSkillLineInfoByID(FIRST_AID_SKILL)
    return info and info.rank or 0
  end
  -- Cata and Mists: First Aid is a secondary profession
  if GetProfessions then
    local prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions()
    if firstAid then return (select(3, GetProfessionInfo(firstAid))) end
    if prof1 or prof2 or archaeology or fishing or cooking then return 0 end
    return nil
  end
  -- Classic Era, TBC and Wrath list skills by name; a collapsed header hides its skills
  if GetSkillLineInfo then
    local count = GetNumSkillLines()
    if count == 0 then return nil end
    local name, hidden = ham.getSpellName(FIRST_AID_SPELL), false
    for i = 1, count do
      local skillName, isHeader, isExpanded, rank = GetSkillLineInfo(i)
      if isHeader then
        hidden = hidden or not isExpanded
      elseif skillName == name then
        return rank
      end
    end
    if hidden then return nil end
    return 0
  end
end

local firstAidRank, firstAidRead = nil, false

local function currentFirstAidRank()
  if not firstAidRead then
    firstAidRank = readFirstAidRank()
    firstAidRead = firstAidRank ~= nil
  end
  return firstAidRank
end

-- Rereads the skills after SKILL_LINES_CHANGED. Returns true when the First Aid rank changed, so
-- a bandage may have become usable; other skills (weapon skills in Classic Era) change often.
function ham.Item.refreshFirstAidRank()
  local before = firstAidRank
  firstAidRead = false
  return currentFirstAidRank() ~= before
end

ham.Item.new = function(id, name, tags)
  local self = {}

  self.id = id
  self.name = name
  self.tags = tags or {}
  self.restores = restoresOf(self.tags)
  self.buffKinds = buffKindsOf(self.tags)

  local function setName()
    local itemInfoName = C_Item.GetItemInfo(self.id)
    if itemInfoName ~= nil then
      self.name = itemInfoName
    end
  end

  function self.getId()
    return self.id
  end

  -- the item's required level; nil until the item cache has the item, which counts as usable
  local requiredLevel

  local function isUsable()
    if requiredLevel == nil then
      local _, _, _, _, minLevel = C_Item.GetItemInfo(self.id)
      requiredLevel = minLevel
      if minLevel == nil then waitingForInfo[self.id] = true end
    end
    if requiredLevel and requiredLevel > currentPlayerLevel() then return false end
    local firstAid = self.tags.firstAid
    if firstAid then
      local rank = currentFirstAidRank()
      if rank and firstAid > rank then return false end
    end
    return true
  end

  -- How many the bags hold, 0 for an unusable item: every caller treats one as if it weren't there.
  function self.getCount()
    local count = C_Item.GetItemCount(self.id, false, false)
    if count > 0 and not isUsable() then return 0 end
    return count
  end

  function self.getTags()
    return self.tags
  end

  function self.hasTag(tagName)
    return self.tags[tagName] == true
  end

  return self
end
