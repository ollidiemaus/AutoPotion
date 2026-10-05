---@diagnostic disable: undefined-global
local addonName, ham = ...

-- Sorted by mana restored (average of the Cataclysm range), highest first.
function ham.getManaPotionsForCata()
  return {
    ham.mythicalManaPotion,      -- 9250-10750
    ham.mightyRejuvenationPotion, -- 9000-11000 (+ health)
    ham.runicManaPotion,         -- 4200-4400
    ham.runicManaInjector,       -- 4200-4400
    ham.powerfulRejuvenationPotion, -- 2475-4125 (+ health)
    ham.endlessManaPotion,       -- 1800-3000 (not consumed)
    ham.icyManaPotion,           -- 1800-3000
    ham.argentManaPotion,        -- 1800-3000
    ham.superManaPotion,         -- 1800-3000
    ham.auchenaiManaPotion,      -- 1800-3000
    ham.crystalManaPotion,       -- 1800-3000
    ham.manaPotionInjector,      -- 1800-3000
    ham.superRejuvenationPotion, -- 2100-2300 (+ health)
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
end
