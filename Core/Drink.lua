local addonName, ham = ...

-- Classic - vendor water (mana restore, no stats)
ham.refreshingSpringWater = ham.Item.new(159, "Refreshing Spring Water")
ham.iceColdMilk = ham.Item.new(1179, "Ice Cold Milk")
ham.melonJuice = ham.Item.new(1205, "Melon Juice")
ham.sweetNectar = ham.Item.new(1708, "Sweet Nectar")
ham.moonberryJuice = ham.Item.new(1645, "Moonberry Juice")
ham.morningGloryDew = ham.Item.new(8766, "Morning Glory Dew")

-- Classic - more plain vendor/drop water (no stats), reskins of the same mana-restore
-- mechanic at the same level tiers as the list above
ham.blendedBeanBrew = ham.Item.new(17404, "Blended Bean Brew")
ham.bottledWinterspringWater = ham.Item.new(19300, "Bottled Winterspring Water")
ham.bubblingWater = ham.Item.new(9451, "Bubbling Water")
ham.enchantedWater = ham.Item.new(4791, "Enchanted Water")
ham.fizzyFaireDrink = ham.Item.new(19299, "Fizzy Faire Drink")
ham.goldthornTea = ham.Item.new(10841, "Goldthorn Tea")
ham.hyjalNectar = ham.Item.new(18300, "Hyjal Nectar")

-- Classic - conjured (Mage), prioritized first: free and doesn't consume bag/gold
ham.conjuredWater = ham.Item.new(5350, "Conjured Water", { conjured = true })
ham.conjuredFreshWater = ham.Item.new(2288, "Conjured Fresh Water", { conjured = true })
ham.conjuredPurifiedWater = ham.Item.new(2136, "Conjured Purified Water", { conjured = true })
ham.conjuredSpringWater = ham.Item.new(3772, "Conjured Spring Water", { conjured = true })
ham.conjuredMineralWater = ham.Item.new(8077, "Conjured Mineral Water", { conjured = true })
ham.conjuredSparklingWater = ham.Item.new(8078, "Conjured Sparkling Water", { conjured = true })
ham.conjuredCrystalWater = ham.Item.new(8079, "Conjured Crystal Water", { conjured = true })

-- TBC - plain drink (mana restore, no stats), reskins of the same mechanic
ham.blackCoffee = ham.Item.new(33042, "Black Coffee")
ham.blackrockFortifiedWater = ham.Item.new(38431, "Blackrock Fortified Water")
ham.blackrockMineralWater = ham.Item.new(38430, "Blackrock Mineral Water")
ham.blackrockSpringWater = ham.Item.new(38429, "Blackrock Spring Water")
ham.conjuredGlacierWater = ham.Item.new(22018, "Conjured Glacier Water", { conjured = true })
ham.conjuredMountainSpringWater = ham.Item.new(30703, "Conjured Mountain Spring Water", { conjured = true })
ham.dosOgris = ham.Item.new(32668, "Dos Ogris")
ham.ethermead = ham.Item.new(29395, "Ethermead")
ham.filteredDraenicWater = ham.Item.new(28399, "Filtered Draenic Water")
ham.gilneasSparklingWater = ham.Item.new(30457, "Gilneas Sparkling Water")
ham.purifiedDraenicWater = ham.Item.new(27860, "Purified Draenic Water")
ham.silverwine = ham.Item.new(29454, "Silverwine")
ham.sparklingSouthshoreCider = ham.Item.new(29401, "Sparkling Southshore Cider")
ham.starsLament = ham.Item.new(32455, "Star's Lament")
ham.starsTears = ham.Item.new(32453, "Star's Tears")

-- Wrath - plain drink (mana restore, no stats), reskins of the same mechanic
ham.bitterPlasma = ham.Item.new(38698, "Bitter Plasma")
ham.crusadersWaterskin = ham.Item.new(42777, "Crusader's Waterskin")
ham.freshAppleJuice = ham.Item.new(43086, "Fresh Apple Juice")
ham.freshSqueezedLimeade = ham.Item.new(44941, "Fresh-Squeezed Limeade")
ham.frostberryJuice = ham.Item.new(37253, "Frostberry Juice")
ham.grizzleberryJuice = ham.Item.new(40357, "Grizzleberry Juice")
ham.honeymintTea = ham.Item.new(33445, "Honeymint Tea")
ham.kungaloosh = ham.Item.new(39520, "Kungaloosh")
ham.mountainWater = ham.Item.new(44750, "Mountain Water")
ham.pungentSealWhey = ham.Item.new(33444, "Pungent Seal Whey")
ham.starsSorrow = ham.Item.new(43236, "Star's Sorrow")
ham.sweetenedGoatsMilk = ham.Item.new(35954, "Sweetened Goat's Milk")
ham.yetiMilk = ham.Item.new(41731, "Yeti Milk")

-- Cata - plain drink (mana restore, no stats), reskins of the same mechanic
ham.briarootBrew = ham.Item.new(49365, "Briaroot Brew")
ham.earlBlackTea = ham.Item.new(49602, "Earl Black Tea")
ham.filteredBilgeWater = ham.Item.new(49398, "Filtered Bilge Water")
ham.freshWater = ham.Item.new(58274, "Fresh Water")
ham.fungusSqueezings = ham.Item.new(59230, "Fungus Squeezings")
ham.garrsLimeade = ham.Item.new(61382, "Garr's Limeade")
ham.gilneasSpringWater = ham.Item.new(49360, "Gilneas Spring Water")
ham.greasyWhaleMilk = ham.Item.new(59029, "Greasy Whale Milk")
ham.highlandSpringWater = ham.Item.new(58257, "Highland Spring Water")
ham.invigoratingPineapplePunch = ham.Item.new(68140, "Invigorating Pineapple Punch")
ham.meisMasterfulBrew = ham.Item.new(63251, "Mei's Masterful Brew")
ham.murkyWater = ham.Item.new(59229, "Murky Water")
ham.refreshingPineapplePunch = ham.Item.new(63530, "Refreshing Pineapple Punch")
ham.sasparillaSinker = ham.Item.new(74822, "Sasparilla Sinker")
ham.southIslandIcedTea = ham.Item.new(62672, "South Island Iced Tea")
ham.sparklingOasisWater = ham.Item.new(58256, "Sparkling Oasis Water")
ham.starfireEspresso = ham.Item.new(62675, "Starfire Espresso")
ham.stormwindSurprise = ham.Item.new(75028, "Stormwind Surprise")
ham.sweetTea = ham.Item.new(63023, "Sweet Tea")
ham.tarpCollectedDew = ham.Item.new(49254, "Tarp Collected Dew")
ham.volcanicSpringWater = ham.Item.new(49601, "Volcanic Spring Water")
ham.wellWater = ham.Item.new(60269, "Well Water")

-- Return a prioritized list of drink items for the current client.
-- Retail food restores both health and mana in a single item, so there is no
-- separate AutoDrink macro/list there.
function ham.getDrink()
  if ham.isRetail then return {} end
  if ham.isClassic and ham.getDrinkForClassic then return ham.getDrinkForClassic() end
  if ham.isTBC and ham.getDrinkForTBC then return ham.getDrinkForTBC() end
  if ham.isWrath and ham.getDrinkForWrath then return ham.getDrinkForWrath() end
  if ham.isCata and ham.getDrinkForCata then return ham.getDrinkForCata() end
  if ham.isMop and ham.getDrinkForMists then return ham.getDrinkForMists() end
  return {}
end
