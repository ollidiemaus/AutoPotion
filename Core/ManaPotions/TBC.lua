---@diagnostic disable: undefined-global
local addonName, ham = ...

-- Sorted by mana restored (average of the TBC range), highest first.
function ham.getManaPotionsForTBC()
  local pots = {
    ham.superManaPotion,         -- 1800-3000
    ham.auchenaiManaPotion,      -- 1800-3000
    ham.crystalManaPotion,       -- 1800-3000
    ham.manaPotionInjector,      -- 1800-3000
    ham.superRejuvenationPotion, -- 1650-2750 (+ health)
    ham.unstableManaPotion,      -- 1350-2250
    ham.majorCombatManaPotionAB, -- 1350-2250
    ham.majorCombatManaPotionAV,
    ham.majorCombatManaPotionEotS,
    ham.majorCombatManaPotionWSG,
    ham.majorManaPotion,         -- 1350-2250
    ham.majorRejuvenationPotion, -- 1440-1760 (+ health)
    ham.combatManaPotion,        -- 900-1500
    ham.superiorManaPotion,      -- 900-1500
    ham.greaterManaPotion,       -- 700-900
    ham.manaPotion,              -- 455-585
    ham.lesserManaPotion,        -- 280-360
    ham.minorManaPotion,         -- 140-180
    ham.minorRejuvenationPotion, -- 90-150 (+ health)
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
