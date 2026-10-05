---@diagnostic disable: undefined-global
local addonName, ham = ...

-- Sorted by mana restored (highest first), newest content first. Within the same amount, plain
-- mana potions come before rejuvenation potions, and "Fleeting" versions come before their
-- regular counterparts so the expiring ones get used up first (same as the health potions).
-- Legacy potions are scaled by the Retail client, so they are ordered by tier (newest first).
function ham.getManaPotionsForRetail()
  return {
    -- Midnight
    ham.fleetingLightfusedManaPotion2,  -- 26200
    ham.lightfusedManaPotion2,          -- 26200
    ham.fleetingLightfusedManaPotion1,  -- 22362
    ham.lightfusedManaPotion1,          -- 22362
    ham.manaRefreshingSerum2,           -- 22300 (+ health)
    ham.manaRefreshingSerum1,           -- 19033 (+ health)
    -- The War Within
    ham.manaFleetingCavedwellersDelightR3, -- 14012 (+ health)
    ham.manaFleetingCavedwellersDelightR2,
    ham.manaFleetingCavedwellersDelightR1,
    ham.manaCavedwellersDelightR3,
    ham.manaCavedwellersDelightR2,
    ham.manaCavedwellersDelightR1,
    ham.fleetingAlgariManaPotionR3,     -- 13707
    ham.algariManaPotionR3,
    ham.fleetingAlgariManaPotionR2,
    ham.algariManaPotionR2,
    ham.fleetingAlgariManaPotionR1,
    ham.algariManaPotionR1,
    ham.survivalistsManaPotion,         -- 20% of maximum mana
    -- Dragonflight
    ham.aeratedManaPotionR3,            -- 2328
    ham.aeratedManaPotionR2,
    ham.aeratedManaPotionR1,
    -- Shadowlands
    ham.spiritualManaPotion,
    ham.soulfulManaPotion,
    -- Battle for Azeroth, Legion, Warlords of Draenor
    ham.coastalManaPotion,
    ham.ancientManaPotion,
    ham.draenicManaPotion,
    -- Mists of Pandaria
    ham.masterManaPotion,               -- 30000
    ham.alchemistsRejuvenation,         -- 30000 (+ health)
    -- Cataclysm
    ham.mythicalManaPotion,             -- 10000
    ham.mightyRejuvenationPotion,       -- 10000 (+ health)
    -- Wrath of the Lich King
    ham.runicManaPotion,                -- 4300
    ham.runicManaInjector,              -- 4300
    ham.powerfulRejuvenationPotion,     -- 3300 (+ health)
    ham.endlessManaPotion,              -- 2400
    ham.icyManaPotion,                  -- 2400
    ham.argentManaPotion,               -- 2400
    -- The Burning Crusade
    ham.superManaPotion,                -- 2400
    ham.auchenaiManaPotion,             -- 2400
    ham.crystalManaPotion,              -- 2400
    ham.manaPotionInjector,             -- 2400
    ham.superRejuvenationPotion,        -- 2200 (+ health)
    ham.unstableManaPotion,             -- 1800
    ham.majorCombatManaPotionAB,        -- 1800
    ham.majorCombatManaPotionAV,
    ham.majorCombatManaPotionEotS,
    ham.majorCombatManaPotionWSG,
    -- Classic
    ham.majorManaPotion,                -- 1800
    ham.majorRejuvenationPotion,        -- 1600 (+ health)
    ham.combatManaPotion,               -- 1200
    ham.superiorManaPotion,             -- 1200
    ham.greaterManaPotion,              -- 800
    ham.manaPotion,                     -- 520
    ham.lesserManaPotion,               -- 320
    ham.minorManaPotion,                -- 160
    ham.minorRejuvenationPotion,        -- 120 (+ health)
  }
end
