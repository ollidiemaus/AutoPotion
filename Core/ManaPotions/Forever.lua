---@diagnostic disable: undefined-global
local addonName, ham = ...

-- WoW Forever is based on Classic: the Classic Era mana potion list and Forever's own items.
function ham.getManaPotionsForForever()
  local pots = {
    ham.majorManaPotion,
    ham.majorRejuvenationPotion,
    ham.combatManaPotion,
    ham.superiorManaPotion,
    ham.superiorManaPotionForever,
    ham.greaterManaPotion,
    ham.manaTessasTonic,
    ham.manaPotion,
    ham.lesserManaPotion,
    ham.lesserManaPotionForever,
    ham.minorManaPotion,
    ham.minorManaPotionForever,
    ham.minorRejuvenationPotion,
  }

  -- Windstone only works on Zephras Isle
  if ham.isOnInstanceMap(ham.INSTANCE_MAP_ID_ZEPHRAS_ISLE) then
    table.insert(pots, 1, ham.manaWindstone)
  end

  -- If in a PvP battleground, prioritize battleground draughts
  local inInstance, instanceType = IsInInstance()
  local isInBattleground = inInstance and instanceType == "pvp"
  if isInBattleground then
    -- Insert in reverse order so final priority is Major then Superior
    table.insert(pots, 1, ham.superiorManaDraught)
    table.insert(pots, 1, ham.majorManaDraught)
  end

  return pots
end
