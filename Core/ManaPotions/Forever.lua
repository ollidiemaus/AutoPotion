---@diagnostic disable: undefined-global
local addonName, ham = ...

-- WoW Forever is based on Classic, starting from the same mana potion list until beta testing shows otherwise.
function ham.getManaPotionsForForever()
  local pots = {
    ham.majorManaPotion,
    ham.majorRejuvenationPotion,
    ham.combatManaPotion,
    ham.superiorManaPotion,
    ham.superiorManaPotionForever,
    ham.greaterManaPotion,
    ham.manaPotion,
    ham.lesserManaPotion,
    ham.lesserManaPotionForever,
    ham.minorManaPotion,
    ham.minorManaPotionForever,
    ham.minorRejuvenationPotion,
  }

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
