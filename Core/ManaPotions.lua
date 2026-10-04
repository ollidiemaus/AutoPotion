local addonName, ham = ...

-- Mana potion data, researched on Wowhead (tooltip data per game flavor). Every flavor list in
-- Core/ManaPotions/*.lua is sorted by the amount of mana restored, highest first, using the
-- numbers of that flavor's own client. Where two potions restore the same amount, plain mana
-- potions come before rejuvenation potions.
--
-- Deliberately NOT included:
--  * channeled/"defenseless" potions (Potion of Concentration/Focus/Frozen Focus/Devoured Dreams, ...)
--  * potions with a downside or a random side effect (Fel Mana Potion, Crazy/Mad Alchemist's Potion,
--    Mysterious Potion, Potion of Nightmares, dreamless sleep potions, ...)
--  * zone-locked potions (Tol Barad, Blade's Edge, Tempest Keep, Coilfang)
--  * Remix-only and QA items

-- Retail - Midnight
ham.lightfusedManaPotion2 = ham.Item.new(241300, "Lightfused Mana Potion")
ham.lightfusedManaPotion1 = ham.Item.new(241301, "Lightfused Mana Potion")
ham.fleetingLightfusedManaPotion2 = ham.Item.new(245916, "Fleeting Lightfused Mana Potion")
ham.fleetingLightfusedManaPotion1 = ham.Item.new(245917, "Fleeting Lightfused Mana Potion")
-- Restores health AND mana, so it only shows up when "Include Rejuvenation Potions" is enabled
ham.manaRefreshingSerum2 = ham.Item.new(241306, "Refreshing Serum", { rejuvenation = true })
ham.manaRefreshingSerum1 = ham.Item.new(241307, "Refreshing Serum", { rejuvenation = true })

-- Retail - The War Within
ham.algariManaPotionR3 = ham.Item.new(212241, "Algari Mana Potion")
ham.algariManaPotionR2 = ham.Item.new(212240, "Algari Mana Potion")
ham.algariManaPotionR1 = ham.Item.new(212239, "Algari Mana Potion")
ham.fleetingAlgariManaPotionR3 = ham.Item.new(212947, "Fleeting Algari Mana Potion")
ham.fleetingAlgariManaPotionR2 = ham.Item.new(212946, "Fleeting Algari Mana Potion")
ham.fleetingAlgariManaPotionR1 = ham.Item.new(212945, "Fleeting Algari Mana Potion")
ham.manaCavedwellersDelightR3 = ham.Item.new(212244, "Cavedweller's Delight", { rejuvenation = true })
ham.manaCavedwellersDelightR2 = ham.Item.new(212243, "Cavedweller's Delight", { rejuvenation = true })
ham.manaCavedwellersDelightR1 = ham.Item.new(212242, "Cavedweller's Delight", { rejuvenation = true })
ham.manaFleetingCavedwellersDelightR3 = ham.Item.new(212950, "Fleeting Cavedweller's Delight", { rejuvenation = true })
ham.manaFleetingCavedwellersDelightR2 = ham.Item.new(212949, "Fleeting Cavedweller's Delight", { rejuvenation = true })
ham.manaFleetingCavedwellersDelightR1 = ham.Item.new(212948, "Fleeting Cavedweller's Delight", { rejuvenation = true })
ham.survivalistsManaPotion = ham.Item.new(224022, "Survivalist's Mana Potion") -- 20% of maximum mana

-- Retail - Dragonflight
ham.aeratedManaPotionR3 = ham.Item.new(191386, "Aerated Mana Potion")
ham.aeratedManaPotionR2 = ham.Item.new(191385, "Aerated Mana Potion")
ham.aeratedManaPotionR1 = ham.Item.new(191384, "Aerated Mana Potion")

-- Retail - Shadowlands, Battle for Azeroth, Legion, Warlords of Draenor
ham.spiritualManaPotion = ham.Item.new(171268, "Spiritual Mana Potion")
ham.soulfulManaPotion = ham.Item.new(180318, "Soulful Mana Potion")
ham.coastalManaPotion = ham.Item.new(152495, "Coastal Mana Potion")
ham.ancientManaPotion = ham.Item.new(127835, "Ancient Mana Potion")
ham.draenicManaPotion = ham.Item.new(109222, "Draenic Mana Potion")

-- Mists of Pandaria
ham.masterManaPotion = ham.Item.new(76098, "Master Mana Potion")
ham.alchemistsRejuvenation = ham.Item.new(76094, "Alchemist's Rejuvenation", { rejuvenation = true })

-- Cataclysm
ham.mythicalManaPotion = ham.Item.new(57192, "Mythical Mana Potion")
ham.mightyRejuvenationPotion = ham.Item.new(57193, "Mighty Rejuvenation Potion", { rejuvenation = true })

-- Wrath of the Lich King
ham.runicManaPotion = ham.Item.new(33448, "Runic Mana Potion")
ham.runicManaInjector = ham.Item.new(42545, "Runic Mana Injector")
ham.powerfulRejuvenationPotion = ham.Item.new(40087, "Powerful Rejuvenation Potion", { rejuvenation = true })
ham.icyManaPotion = ham.Item.new(40067, "Icy Mana Potion")
ham.argentManaPotion = ham.Item.new(43530, "Argent Mana Potion")
ham.endlessManaPotion = ham.Item.new(43570, "Endless Mana Potion") -- not consumed when used

-- The Burning Crusade
ham.superManaPotion = ham.Item.new(22832, "Super Mana Potion")
ham.auchenaiManaPotion = ham.Item.new(32948, "Auchenai Mana Potion")
ham.crystalManaPotion = ham.Item.new(33935, "Crystal Mana Potion")
ham.manaPotionInjector = ham.Item.new(33093, "Mana Potion Injector")
ham.superRejuvenationPotion = ham.Item.new(22850, "Super Rejuvenation Potion", { rejuvenation = true })
ham.unstableManaPotion = ham.Item.new(28101, "Unstable Mana Potion")
-- Battleground rewards, one per battleground (identical effect)
ham.majorCombatManaPotionAB = ham.Item.new(31840, "Major Combat Mana Potion")
ham.majorCombatManaPotionAV = ham.Item.new(31841, "Major Combat Mana Potion")
ham.majorCombatManaPotionEotS = ham.Item.new(31854, "Major Combat Mana Potion")
ham.majorCombatManaPotionWSG = ham.Item.new(31855, "Major Combat Mana Potion")

-- Classic
ham.majorManaPotion = ham.Item.new(13444, "Major Mana Potion")
ham.majorRejuvenationPotion = ham.Item.new(18253, "Major Rejuvenation Potion", { rejuvenation = true })
ham.combatManaPotion = ham.Item.new(18841, "Combat Mana Potion")
ham.superiorManaPotion = ham.Item.new(13443, "Superior Mana Potion")
ham.greaterManaPotion = ham.Item.new(6149, "Greater Mana Potion")
ham.manaPotion = ham.Item.new(3827, "Mana Potion")
ham.lesserManaPotion = ham.Item.new(3385, "Lesser Mana Potion")
ham.minorManaPotion = ham.Item.new(2455, "Minor Mana Potion")
ham.minorRejuvenationPotion = ham.Item.new(2456, "Minor Rejuvenation Potion", { rejuvenation = true })
-- Classic/TBC PvP battleground-only draughts
ham.majorManaDraught = ham.Item.new(17351, "Major Mana Draught")
ham.superiorManaDraught = ham.Item.new(17352, "Superior Mana Draught")

local function getRawManaPotions()
  if ham.isRetail and ham.getManaPotionsForRetail then return ham.getManaPotionsForRetail() end
  if ham.isClassic and ham.getManaPotionsForClassic then return ham.getManaPotionsForClassic() end
  if ham.isTBC and ham.getManaPotionsForTBC then return ham.getManaPotionsForTBC() end
  if ham.isWrath and ham.getManaPotionsForWrath then return ham.getManaPotionsForWrath() end
  if ham.isCata and ham.getManaPotionsForCata then return ham.getManaPotionsForCata() end
  if ham.isMop and ham.getManaPotionsForMists then return ham.getManaPotionsForMists() end
  if ham.isForever and ham.getManaPotionsForForever then return ham.getManaPotionsForForever() end
  return {}
end

-- Return a prioritized list of mana potions for the current client, excluding the
-- rejuvenation (health AND mana) potions when the user turned them off. Enabled by default,
-- so only an explicit `false` counts as "off" (older saved variables don't have the key).
function ham.getManaPotions()
  -- Potions are not allowed in instanced PvP on Retail, same as the health potions
  if ham.isInInstancedPvP and ham.isInInstancedPvP() then
    return {}
  end

  local list = getRawManaPotions()
  if HAMDB and HAMDB.includeRejuvenation ~= false then
    return list
  end
  local filtered = {}
  for _, item in ipairs(list) do
    if not item.hasTag("rejuvenation") then
      table.insert(filtered, item)
    end
  end
  return filtered
end
