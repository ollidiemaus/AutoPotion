---@diagnostic disable: undefined-global
local addonName, ham = ...

local ZONE_LOCKED_POTION_MAPS = {
  [ham.MAP_ID_THE_HINTERLANDS] = true,
  [ham.MAP_ID_DUSKWOOD] = true,
  [ham.MAP_ID_ASHENVALE] = true,
  [ham.MAP_ID_FERALAS] = true,
}

-- WoW Forever is based on Classic: the Classic Era potion list and Forever's own potions.
function ham.getPotsForForever()
  -- Base Forever potions list
  local pots = {
    ham.major,
    ham.combat,
    ham.superior,
    ham.superiorForever,
    ham.tessasTonic,
    ham.greater,
    ham.greaterForever,
    ham.perishableHealingPotion,
    ham.healingPotion,
    ham.perishableLesserHealingPotion,
    ham.lesser,
    ham.lesserForever,
    ham.perishableMinorHealingPotion,
    ham.minor,
    ham.minorForever
  }

  -- Windstone only works on Zephras Isle
  if ham.isOnInstanceMap(ham.INSTANCE_MAP_ID_ZEPHRAS_ISLE) then
    table.insert(pots, 1, ham.windstone)
  end

  -- Forever's own Major and Greater Healing Potion only work in these zones. Insert in reverse
  -- order so final priority is Major then Greater
  if ZONE_LOCKED_POTION_MAPS[C_Map.GetBestMapForUnit("player")] then
    table.insert(pots, 1, ham.greaterZoneLocked)
    table.insert(pots, 1, ham.majorZoneLocked)
  end

  -- If in a PvP battleground, prioritize battleground draughts
  local inInstance, instanceType = IsInInstance()
  local isInBattleground = inInstance and instanceType == "pvp"
  if isInBattleground then
    -- Insert in reverse order so final priority is Major then Superior
    table.insert(pots, 1, ham.superiorHealingDraught)
    table.insert(pots, 1, ham.majorHealingDraught)
  end

  return pots
end

function ham.getHealthstonesForForever()
  return {
    ham.major2,
    ham.major0,
    ham.major1,
    ham.greater2,
    ham.greater0,
    ham.greater1,
    ham.wipperRootTuber,
    ham.healtsthone2,
    ham.healtsthone0,
    ham.crystalFlakeThroatLozenge,
    ham.healtsthone1,
    ham.lesser2,
    ham.lesser0,
    ham.lesser1,
    ham.minor2,
    ham.minor0,
    ham.minor1
  }
end
