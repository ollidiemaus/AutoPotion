---@diagnostic disable: undefined-global
local addonName, ham = ...

-- Whether the player has the food buff or Relaxed, for "only when the buff is missing", and the
-- order of buff food that follows from it. The food buff is any buff that the flavor's buff food
-- leaves, whatever its strength, source or time left. Well Fed and Retail's Hearty Well Fed are
-- found by their translated names. The older flavors' stat food buffs are found by spell ID:
-- their names ("Increased Stamina", ...) also belong to buffs no food leaves.

local function spellName(spellId)
  if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(spellId) end
  return (GetSpellInfo(spellId))
end

-- one spell of each name (there are hundreds of Well Fed), for the name in the client's language
local NAMED_BY = { 19705 } -- Well Fed
if ham.isRetail then
  table.insert(NAMED_BY, 454188) -- Hearty Well Fed
end
local foodBuffNames = {} -- { [name] = true }
for _, spellId in ipairs(NAMED_BY) do
  local name = spellName(spellId)
  if name then foodBuffNames[name] = true end
end

-- Classic Era to Mists: food buffs whose name isn't Well Fed. Forever's food leaves Well Fed.
local foodBuffSpells = {} -- { [spellId] = true }
if not ham.isRetail and not ham.isForever then
  for _, spellId in ipairs({
    25661, 18191, 145635,  -- Increased Stamina (145635: Mists' Mightfish Steak)
    18192, 22730, 18193,   -- Increased Agility, Intellect, Spirit
    18194, 18125, 43722,   -- Mana Regeneration, Blessed Sunfruit, Enlightened
    111840, 127784, 127881, -- Healthy, Grummlecake, Squirmy Feeling
  }) do
    foodBuffSpells[spellId] = true
  end
end

-- Retail's buff drinks leave Relaxed, found by its translated name. It's separate from the food
-- buff: the food buff orders AutoFood, Relaxed orders AutoDrink.
local relaxedNames = {} -- { [name] = true }
if ham.isRetail then
  local name = spellName(1269152) -- one of the Relaxed spells, for the name
  if name then relaxedNames[name] = true end
end

-- Retail and Forever hand out secret aura data in restricted states (combat, encounters, M+);
-- comparing or indexing a secret is an error, so such data leaves the remembered state as it is.
local function usable(value)
  return not (issecretvalue and issecretvalue(value))
end

-- The game also hides auras from addons (Retail and Forever: encounters, M+, PvP, sometimes out
-- of combat): the lookups then find nothing, which says nothing about the buff.
local function aurasHidden()
  return C_Secrets ~= nil and C_Secrets.ShouldAurasBeSecret ~= nil and C_Secrets.ShouldAurasBeSecret()
end

-- Whether an aura lookup's answer is the buff, its aura instance ID, and whether it was
-- readable (not secret).
local function fromAura(aura)
  if not usable(aura) then return false, nil, false end
  if aura == nil then return false, nil, true end
  local instance = aura.auraInstanceID
  if not usable(instance) then return false, nil, false end
  return true, instance, true
end

-- The same for the player's buff of this name. Wrath's client may lack the C_UnitAuras lookups,
-- so AuraUtil's (FrameXML) is the fallback. The old global UnitBuff isn't used: Retail and
-- Forever don't have it.
local function findByName(name)
  if C_UnitAuras and C_UnitAuras.GetAuraDataBySpellName then
    return fromAura(C_UnitAuras.GetAuraDataBySpellName("player", name, "HELPFUL"))
  end
  if AuraUtil and AuraUtil.FindAuraByName then
    return AuraUtil.FindAuraByName(name, "player", "HELPFUL") ~= nil, nil, true
  end
  return false, nil, true
end

-- The same by spell ID, for the flavors with foodBuffSpells; their API docs all list this lookup.
local function findBySpell(spellId)
  if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
    return fromAura(C_UnitAuras.GetPlayerAuraBySpellID(spellId))
  end
  return false, nil, true
end

-- Follows whether the player has one buff, any aura with one of these names ({ [name] = true })
-- or spell IDs ({ [spellId] = true }).
local function newBuffWatch(names, spells)
  local known = false     -- hasBuff follows the player's auras; false while nothing needs it
  local hasBuff = false
  local buffInstance = nil -- the buff's aura instance ID, where the client reports one
  local stale = false      -- the last rescan couldn't read the auras; hasBuff is remembered

  -- Whether the player has the buff, its aura instance ID where the client reports one, and
  -- whether the auras could be read (not hidden, not secret).
  local function find()
    if aurasHidden() then return false, nil, false end
    for name in pairs(names) do
      local found, instance, readable = findByName(name)
      if not readable or found then return found, instance, readable end
    end
    for spellId in pairs(spells) do
      local found, instance, readable = findBySpell(spellId)
      if not readable or found then return found, instance, readable end
    end
    return false, nil, true
  end

  -- Auras that can't be read leave the remembered state as it is, until a later rescan can.
  local function rescan()
    local found, instance, readable = find()
    if readable then hasBuff, buffInstance = found, instance end
    stale = not readable
    known = true
  end

  -- Whether this aura update could have changed the buff, as far as it says: without update
  -- info (Wrath may send none) or with a full update, only a rescan can tell.
  local function changes(updateInfo)
    if stale or updateInfo == nil or updateInfo.isFullUpdate then return true end
    if hasBuff then
      if buffInstance == nil then return true end
      local removed = updateInfo.removedAuraInstanceIDs
      if removed then
        for _, id in ipairs(removed) do
          if usable(id) and id == buffInstance then return true end
        end
      end
      return false
    end
    local added = updateInfo.addedAuras
    if added then
      for _, aura in ipairs(added) do
        local name, spellId = aura.name, aura.spellId
        if usable(name) and names[name] then return true end
        if usable(spellId) and spells[spellId] then return true end
      end
    end
    return false
  end

  local watch = {}

  function watch.has()
    if not known then rescan() end
    return hasBuff
  end

  -- Forget the buff: nothing follows the auras until the next has() rescans.
  function watch.forget()
    known = false
  end

  local function rescanChanged()
    local had = hasBuff
    rescan()
    return hasBuff ~= had
  end

  -- Follows an aura update; returns whether the buff came or went. While auras are hidden the
  -- update's own data may be secret too, so any update marks the buff for a later rescan.
  function watch.update(updateInfo)
    if not known then return false end
    if aurasHidden() then
      stale = true
      return false
    end
    return changes(updateInfo) and rescanChanged()
  end

  -- Rescans if an earlier rescan couldn't read the auras; returns whether the buff came or went.
  function watch.recheckIfStale()
    return known and stale and rescanChanged()
  end

  return watch
end

local foodBuff = newBuffWatch(foodBuffNames, foodBuffSpells)
local relaxed = newBuffWatch(relaxedNames, {})

function ham.hasFoodBuff()
  return foodBuff.has()
end

function ham.isRelaxed()
  return relaxed.has()
end

-- Buff food (items tagged buffFood) of a food or drink list for the options: left out unless
-- "Include Buff Food" is on. With "only when the buff is missing" it goes first, ahead of
-- conjured food, while buffActive() says the player lacks its buff (the food buff or Relaxed),
-- and last while they have it. Either way it keeps its relative order.
function ham.orderBuffFood(list, buffActive)
  local options = ham.options
  if options.includeBuffFood and not options.buffFoodOnlyWhenMissing then
    return list
  end
  local buffFood, otherFood = {}, {}
  for _, item in ipairs(list) do
    if item.hasTag("buffFood") then
      table.insert(buffFood, item)
    else
      table.insert(otherFood, item)
    end
  end
  if not options.includeBuffFood then
    return otherFood
  end
  local first, last = buffFood, otherFood
  if buffActive() then first, last = otherFood, buffFood end
  for _, item in ipairs(last) do
    table.insert(first, item)
  end
  return first
end

-- ham.options is there from ADDON_LOADED on
local function watching()
  local options = ham.options
  return options ~= nil and options.includeBuffFood and options.buffFoodOnlyWhenMissing
end

-- A change of the food buff or Relaxed rebuilds the macros and redraws the open settings pages'
-- previews.
local function rebuildIf(changed)
  if changed then
    ham.refreshPreviews()
    ham.requestMacroUpdate()
  end
end

-- UNIT_AURA for the player. While the sub-option is off nothing follows the auras, and
-- the next lookup rescans.
function ham.onPlayerAura(updateInfo)
  if not watching() then
    foodBuff.forget()
    relaxed.forget()
    return
  end
  local foodBuffChanged = foodBuff.update(updateInfo)
  rebuildIf(relaxed.update(updateInfo) or foodBuffChanged)
end

-- ADDON_RESTRICTION_STATE_CHANGED: an encounter, M+ or PvP match began or ended. Once auras can
-- be read again, what changed while they were hidden counts.
function ham.onRestrictionChanged()
  if not watching() then return end
  local foodBuffChanged = foodBuff.recheckIfStale()
  rebuildIf(relaxed.recheckIfStale() or foodBuffChanged)
end
