---@diagnostic disable: undefined-global
local addonName, ham = ...

-- Sorted by mana restored, highest first (Mists of Pandaria uses flat values).
function ham.getManaPotionsForMists()
  return {
    ham.masterManaPotion,        -- 30000
    ham.alchemistsRejuvenation,  -- 30000 (+ health)
    ham.mythicalManaPotion,      -- 10000
    ham.mightyRejuvenationPotion, -- 10000 (+ health)
    ham.runicManaPotion,         -- 4300
    ham.runicManaInjector,       -- 4300
    ham.powerfulRejuvenationPotion, -- 3300 (+ health)
    ham.endlessManaPotion,       -- 2400 (not consumed)
    ham.icyManaPotion,           -- 2400
    ham.argentManaPotion,        -- 2400
    ham.superManaPotion,         -- 2400
    ham.auchenaiManaPotion,      -- 2400
    ham.crystalManaPotion,       -- 2400
    ham.manaPotionInjector,      -- 2400
    ham.superRejuvenationPotion, -- 2200 (+ health)
    ham.unstableManaPotion,      -- 1800
    ham.majorCombatManaPotionAB, -- 1800
    ham.majorCombatManaPotionAV,
    ham.majorCombatManaPotionEotS,
    ham.majorCombatManaPotionWSG,
    ham.majorManaPotion,         -- 1800
    ham.majorRejuvenationPotion, -- 1628 (+ health)
    ham.combatManaPotion,        -- 1238
    ham.superiorManaPotion,      -- 1238
    ham.greaterManaPotion,       -- 805
    ham.manaPotion,              -- 520
    ham.lesserManaPotion,        -- 381
    ham.minorManaPotion,         -- 160
    ham.minorRejuvenationPotion, -- 120 (+ health)
  }
end
