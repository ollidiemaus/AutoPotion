---@diagnostic disable: undefined-global
local addonName, ham = ...

-- Whether the player has the food buff, for "only when the buff is missing". It's found by its
-- translated name, Well Fed, whatever its strength, source or time left.

local WELL_FED = 19705 -- one of the hundreds of Well Fed spells, for the name in the client's language
local foodBuffName
if C_Spell and C_Spell.GetSpellName then
  foodBuffName = C_Spell.GetSpellName(WELL_FED)
else
  foodBuffName = GetSpellInfo(WELL_FED)
end

local known = false     -- hasBuff follows the player's auras; false while nothing needs it
local hasBuff = false
local buffInstance = nil -- the food buff's aura instance ID, where the client reports one

-- Retail and Forever hand out secret aura data in restricted states (combat, encounters, M+);
-- comparing or indexing a secret is an error, so such data leaves the remembered state as it is.
local function usable(value)
  return not (issecretvalue and issecretvalue(value))
end

-- The player's food buff by name: whether they have it, and its aura instance ID. Wrath's client
-- may lack the C_UnitAuras lookups, so AuraUtil's (FrameXML) is the fallback. The old global
-- UnitBuff isn't used: Retail and Forever don't have it.
local function findFoodBuff()
  if not foodBuffName then return false, nil end
  if C_UnitAuras and C_UnitAuras.GetAuraDataBySpellName then
    local aura = C_UnitAuras.GetAuraDataBySpellName("player", foodBuffName, "HELPFUL")
    if not usable(aura) then return hasBuff, buffInstance end
    if aura == nil then return false, nil end
    local instance = aura.auraInstanceID
    if not usable(instance) then return hasBuff, buffInstance end
    return true, instance
  end
  if AuraUtil and AuraUtil.FindAuraByName then
    return AuraUtil.FindAuraByName(foodBuffName, "player", "HELPFUL") ~= nil, nil
  end
  return false, nil
end

local function rescan()
  hasBuff, buffInstance = findFoodBuff()
  known = true
end

-- ham.options is there from ADDON_LOADED on
local function watching()
  local options = ham.options
  return options ~= nil and options.includeBuffFood and options.buffFoodOnlyWhenMissing
end

function ham.hasFoodBuff()
  if not known then rescan() end
  return hasBuff
end

-- Whether this aura update could have changed the food buff, as far as it says: without update
-- info (Wrath may send none) or with a full update, only a rescan can tell.
local function changesFoodBuff(updateInfo)
  if updateInfo == nil or updateInfo.isFullUpdate then return true end
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
      local name = aura.name
      if usable(name) and name == foodBuffName then return true end
    end
  end
  return false
end

-- UNIT_AURA for the player. A change of the food buff rebuilds the macros and redraws the open
-- settings pages' previews. While the sub-option is off nothing follows the auras, and the next
-- ham.hasFoodBuff rescans.
function ham.onPlayerAura(updateInfo)
  if not watching() then
    known = false
    return
  end
  if not known or not changesFoodBuff(updateInfo) then return end
  local had = hasBuff
  rescan()
  if hasBuff ~= had then
    ham.refreshPreviews()
    ham.requestMacroUpdate()
  end
end
