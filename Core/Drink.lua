local addonName, ham = ...

-- Retail - Mage-conjured drink (mana only; the health-restoring counterpart, Conjured
-- Souffle/Cinnamon Roll/Croissant, is declared in Core/Food.lua).
ham.conjuredTea = ham.Item.new(265099, "Conjured Tea", { conjured = true, mpPct = 120 })

-- Retail - plain drink (mana restore, no stats). Wowhead's Food & Drinks category lists
-- dozens of cosmetic name/icon reskins of the same restore-only mechanic per zone; these
-- are the confirmed drink-type items, included individually for coverage.
ham.manaLilyTea = ham.Item.new(242297, "Mana Lily Tea", { mpPct = 160 })
ham.tranquilityBloomTea = ham.Item.new(242300, "Tranquility Bloom Tea", { mpPct = 160 })
ham.purifiedCordial = ham.Item.new(260258, "Purified Cordial", { mpPct = 80 })
ham.everspringWater = ham.Item.new(260259, "Everspring Water", { mpPct = 80 })
ham.springrunnerSparkling = ham.Item.new(260260, "Springrunner Sparkling", { mpPct = 100 })
ham.bloomNectar = ham.Item.new(260261, "Bloom Nectar", { mpPct = 100 })
ham.rootJuice = ham.Item.new(260271, "Root Juice", { mpPct = 80 })
ham.crispBluffBock = ham.Item.new(260272, "Crisp Bluff Bock", { mpPct = 80 })
ham.teaOfMistsAndRain = ham.Item.new(260273, "Tea of Mists and Rain", { mpPct = 100 })
ham.denshroomDeepRoast = ham.Item.new(260274, "Denshroom Deep Roast", { mpPct = 100 })
ham.refreshingAhluaWater = ham.Item.new(260282, "Refreshing Ahl'ua Water", { mpPct = 80 })
ham.grottoGulp = ham.Item.new(260283, "Grotto Gulp", { mpPct = 80 })
ham.lashroomQuencher = ham.Item.new(260284, "Lashroom Quencher", { mpPct = 100 })
ham.extractOfLightbloom = ham.Item.new(260285, "Extract of Lightbloom", { mpPct = 100 })
ham.voidPort = ham.Item.new(260293, "Void Port", { mpPct = 80 })
ham.voidwyrmAbsinthe = ham.Item.new(260294, "Voidwyrm Absinthe", { mpPct = 80 })
ham.purifiedStormWater = ham.Item.new(260295, "Purified Storm Water", { mpPct = 100 })
ham.shadeleafTea = ham.Item.new(260296, "Shadeleaf Tea", { mpPct = 100 })
ham.goldengroveJuice = ham.Item.new(264981, "Goldengrove Juice", { mpPct = 80 })
ham.wineNot = ham.Item.new(264982, "Wine Not", { mpPct = 80 })
ham.sunwellShot = ham.Item.new(264983, "Sunwell Shot", { mpPct = 80 })
ham.darkwellDraft = ham.Item.new(264984, "Darkwell Draft", { mpPct = 80 })
ham.dawnmosa = ham.Item.new(264985, "Dawnmosa", { mpPct = 80 })
ham.magistersMead = ham.Item.new(264987, "Magister's Mead", { mpPct = 80 })
ham.dragonhawkFlight = ham.Item.new(264989, "Dragonhawk Flight", { mpPct = 80 })
ham.fairbreezeFranciacorta = ham.Item.new(264990, "Fairbreeze Franciacorta", { mpPct = 80 })
ham.buddingLight = ham.Item.new(265664, "Budding Light", { mpPct = 80 })
ham.chanterelleShandy = ham.Item.new(265665, "Chanterelle Shandy", { mpPct = 80 })
ham.worldRootBeer = ham.Item.new(265666, "World Root Beer", { mpPct = 80 })
ham.brightClaw = ham.Item.new(265667, "Bright Claw", { mpPct = 80 })

-- Retail - "Relaxed" drink: mana restore plus a secondary-stat buff, situational,
-- opt-in via the includeBuffFood option (the same toggle used for Well Fed food).
ham.argentleafTea = ham.Item.new(242298, "Argentleaf Tea", { buffFood = true, mpPct = 160 })
ham.sanguithornTea = ham.Item.new(242299, "Sanguithorn Tea", { buffFood = true, mpPct = 160 })
ham.azerootTea = ham.Item.new(242301, "Azeroot Tea", { buffFood = true, mpPct = 160 })

-- Classic - vendor water (mana restore, no stats)
ham.refreshingSpringWater = ham.Item.new(159, "Refreshing Spring Water", { mp = 151.2 })
ham.iceColdMilk = ham.Item.new(1179, "Ice Cold Milk", { mp = 436.8 })
ham.melonJuice = ham.Item.new(1205, "Melon Juice", { mp = 835.2 })
ham.sweetNectar = ham.Item.new(1708, "Sweet Nectar", { mp = 1344.6 })
ham.moonberryJuice = ham.Item.new(1645, "Moonberry Juice", { mp = 1992 })
ham.morningGloryDew = ham.Item.new(8766, "Morning Glory Dew", { mp = 2934 })
ham.morningGloryDewForever = ham.Item.new(287964, "Morning Glory Dew", { mp = 2934 }) -- Forever only, level 1 version

-- Classic - more plain vendor/drop water (no stats), reskins of the same mana-restore
-- mechanic at the same level tiers as the list above
ham.blendedBeanBrew = ham.Item.new(17404, "Blended Bean Brew", { mp = 436.8 })
ham.bottledWinterspringWater = ham.Item.new(19300, "Bottled Winterspring Water", { mp = 1992 })
ham.bubblingWater = ham.Item.new(9451, "Bubbling Water", { mp = 835.2 })
ham.enchantedWater = ham.Item.new(4791, "Enchanted Water", { mp = 1344.6 })
ham.fizzyFaireDrink = ham.Item.new(19299, "Fizzy Faire Drink", { mp = 835.2 })
ham.goldthornTea = ham.Item.new(10841, "Goldthorn Tea", { mp = 1344.6 })
ham.hyjalNectar = ham.Item.new(18300, "Hyjal Nectar", { mp = 4200 })

-- Classic - conjured (Mage), prioritized first: free and doesn't consume bag/gold
ham.conjuredWater = ham.Item.new(5350, "Conjured Water", { conjured = true, mp = 151.2 })
ham.conjuredFreshWater = ham.Item.new(2288, "Conjured Fresh Water", { conjured = true, mp = 436.8 })
ham.conjuredPurifiedWater = ham.Item.new(2136, "Conjured Purified Water", { conjured = true, mp = 835.2 })
ham.conjuredSpringWater = ham.Item.new(3772, "Conjured Spring Water", { conjured = true, mp = 1344.6 })
ham.conjuredMineralWater = ham.Item.new(8077, "Conjured Mineral Water", { conjured = true, mp = 1992 })
ham.conjuredSparklingWater = ham.Item.new(8078, "Conjured Sparkling Water", { conjured = true, mp = 2934 })
ham.conjuredCrystalWater = ham.Item.new(8079, "Conjured Crystal Water", { conjured = true, mp = 4200 })

-- TBC - plain drink (mana restore, no stats), reskins of the same mechanic
ham.blackCoffee = ham.Item.new(33042, "Black Coffee", { mp = 7200 })
ham.blackrockFortifiedWater = ham.Item.new(38431, "Blackrock Fortified Water", { mp = 7200 })
ham.blackrockMineralWater = ham.Item.new(38430, "Blackrock Mineral Water", { mp = 5100 })
ham.blackrockSpringWater = ham.Item.new(38429, "Blackrock Spring Water", { mp = 2934 })
ham.conjuredGlacierWater = ham.Item.new(22018, "Conjured Glacier Water", { conjured = true, mp = 7200 })
ham.conjuredMountainSpringWater = ham.Item.new(30703, "Conjured Mountain Spring Water", { conjured = true, mp = 5100 })
ham.dosOgris = ham.Item.new(32668, "Dos Ogris", { mp = 7200 })
ham.ethermead = ham.Item.new(29395, "Ethermead", { mp = 7200 })
ham.filteredDraenicWater = ham.Item.new(28399, "Filtered Draenic Water", { mp = 5100 })
ham.gilneasSparklingWater = ham.Item.new(30457, "Gilneas Sparkling Water", { mp = 7200 })
ham.purifiedDraenicWater = ham.Item.new(27860, "Purified Draenic Water", { mp = 7200 })
ham.silverwine = ham.Item.new(29454, "Silverwine", { mp = 5100 })
ham.sparklingSouthshoreCider = ham.Item.new(29401, "Sparkling Southshore Cider", { mp = 7200 })
ham.starsLament = ham.Item.new(32455, "Star's Lament", { mp = 4200 })
ham.starsTears = ham.Item.new(32453, "Star's Tears", { mp = 7200 })

-- Wrath - plain drink (mana restore, no stats), reskins of the same mechanic
ham.bitterPlasma = ham.Item.new(38698, "Bitter Plasma", { mp = 12840 })
ham.crusadersWaterskin = ham.Item.new(42777, "Crusader's Waterskin", { mp = 19200 })
ham.freshAppleJuice = ham.Item.new(43086, "Fresh Apple Juice", { mp = 12840 })
ham.freshSqueezedLimeade = ham.Item.new(44941, "Fresh-Squeezed Limeade", { mp = 12840 })
ham.frostberryJuice = ham.Item.new(37253, "Frostberry Juice", { mp = 7200 })
ham.grizzleberryJuice = ham.Item.new(40357, "Grizzleberry Juice", { mp = 7200 })
ham.honeymintTea = ham.Item.new(33445, "Honeymint Tea", { mp = 19200 })
ham.kungaloosh = ham.Item.new(39520, "Kungaloosh", { mp = 19200 })
ham.mountainWater = ham.Item.new(44750, "Mountain Water", { mp = 7200 })
ham.pungentSealWhey = ham.Item.new(33444, "Pungent Seal Whey", { mp = 12840 })
ham.starsSorrow = ham.Item.new(43236, "Star's Sorrow", { mp = 19200 })
ham.sweetenedGoatsMilk = ham.Item.new(35954, "Sweetened Goat's Milk", { mp = 7200 })
ham.yetiMilk = ham.Item.new(41731, "Yeti Milk", { mp = 19200 })

-- Cata - plain drink (mana restore, no stats), reskins of the same mechanic
ham.briarootBrew = ham.Item.new(49365, "Briaroot Brew", { mp = 436.8 })
ham.earlBlackTea = ham.Item.new(49602, "Earl Black Tea", { mp = 436.8 })
ham.filteredBilgeWater = ham.Item.new(49398, "Filtered Bilge Water", { mp = 436.8 })
ham.freshWater = ham.Item.new(58274, "Fresh Water", { mp = 19200 })
ham.fungusSqueezings = ham.Item.new(59230, "Fungus Squeezings", { mp = 45000 })
ham.garrsLimeade = ham.Item.new(61382, "Garr's Limeade", { mp = 1344.6 })
ham.gilneasSpringWater = ham.Item.new(49360, "Gilneas Spring Water", { mp = 436.8 })
ham.greasyWhaleMilk = ham.Item.new(59029, "Greasy Whale Milk", { mp = 45000 })
ham.highlandSpringWater = ham.Item.new(58257, "Highland Spring Water", { mp = 96000 })
ham.invigoratingPineapplePunch = ham.Item.new(68140, "Invigorating Pineapple Punch", { mp = 96000 })
ham.meisMasterfulBrew = ham.Item.new(63251, "Mei's Masterful Brew", { mp = 96000 })
ham.murkyWater = ham.Item.new(59229, "Murky Water", { mp = 19200 })
ham.refreshingPineapplePunch = ham.Item.new(63530, "Refreshing Pineapple Punch", { mp = 436.8 })
ham.sasparillaSinker = ham.Item.new(74822, "Sasparilla Sinker", { mp = 96000 })
ham.southIslandIcedTea = ham.Item.new(62672, "South Island Iced Tea", { mp = 96000 })
ham.sparklingOasisWater = ham.Item.new(58256, "Sparkling Oasis Water", { mp = 45000 })
ham.starfireEspresso = ham.Item.new(62675, "Starfire Espresso", { mp = 96000 })
ham.stormwindSurprise = ham.Item.new(75028, "Stormwind Surprise", { mpPct = 60 })
ham.sweetTea = ham.Item.new(63023, "Sweet Tea", { mp = 1992 })
ham.tarpCollectedDew = ham.Item.new(49254, "Tarp Collected Dew", { mp = 151.2 })
ham.volcanicSpringWater = ham.Item.new(49601, "Volcanic Spring Water", { mp = 436.8 })
ham.wellWater = ham.Item.new(60269, "Well Water", { mp = 151.2 })

-- Mists - plain drink (mana restore, no stats), reskins of the same mechanic
ham.blackTea = ham.Item.new(90660, "Black Tea", { mp = 835.2 })
ham.carbonatedWater = ham.Item.new(81924, "Carbonated Water", { mp = 200000 })
ham.coboCola = ham.Item.new(81923, "Cobo Cola", { mp = 300000 })
ham.cupOfKafa = ham.Item.new(88578, "Cup of Kafa", { mp = 300000 })
ham.funkyMonkeyBrew = ham.Item.new(105711, "Funky Monkey Brew", { mp = 300000 })
ham.goldenCarpConsomme = ham.Item.new(74636, "Golden Carp Consomme", { mp = 300000 })
ham.jadeWitchBrew = ham.Item.new(75037, "Jade Witch Brew", { mp = 300000 })
ham.jasmineTea = ham.Item.new(90659, "Jasmine Tea", { mp = 436.8 })
ham.lotusWater = ham.Item.new(88532, "Lotus Water", { mp = 300000 })
ham.timelessTea = ham.Item.new(104348, "Timeless Tea", { mp = 300000 })
ham.viseclawSoup = ham.Item.new(85501, "Viseclaw Soup", { mp = 200000 })

-- Forever - plain drink
ham.mountainSpringWater = ham.Item.new(231778, "Mountain Spring Water", { mp = 5100 }) -- Forever only
ham.gustberryJuice = ham.Item.new(252027, "Gustberry Juice", { mp = 436.8 }) -- Forever only
ham.crispSpringWater = ham.Item.new(252031, "Crisp Spring Water", { mp = 151.2 }) -- Forever only

-- Forever - Nutritious drinks, buff food: they leave the food buff
ham.sagesTea = ham.Item.new(249870, "Sage's Tea", { buffFood = true, mp = 2934 }) -- Forever only
ham.wickedSmoothie = ham.Item.new(249876, "Wicked Smoothie", { buffFood = true, mp = 2934 }) -- Forever only
ham.sunnyTea = ham.Item.new(249869, "Sunny Tea", { buffFood = true, mp = 1992 }) -- Forever only
ham.spicySmoothie = ham.Item.new(249875, "Spicy Smoothie", { buffFood = true, mp = 1992 }) -- Forever only
ham.triageTea = ham.Item.new(249868, "Triage Tea", { buffFood = true, mp = 1344.6 }) -- Forever only
ham.calcifiedSmoothie = ham.Item.new(249874, "Calcified Smoothie", { buffFood = true, mp = 1344.6 }) -- Forever only
ham.rootTea = ham.Item.new(249867, "Root Tea", { buffFood = true, mp = 835.2 }) -- Forever only
ham.mrrgglSmrrthle = ham.Item.new(249873, "Mrrggl Smrrthle", { buffFood = true, mp = 835.2 }) -- Forever only
ham.royalTea = ham.Item.new(249866, "Royal Tea", { buffFood = true, mp = 436.8 }) -- Forever only
ham.slimySmoothie = ham.Item.new(249872, "Slimy Smoothie", { buffFood = true, mp = 436.8 }) -- Forever only
ham.peaceTea = ham.Item.new(249865, "Peace Tea", { buffFood = true, mp = 151.2 }) -- Forever only
ham.venomousSmoothie = ham.Item.new(249871, "Venomous Smoothie", { buffFood = true, mp = 151.2 }) -- Forever only
-- Plain on the other flavors, Nutritious on Forever
ham.goldthornTeaForever = ham.Item.new(10841, "Goldthorn Tea", { buffFood = true, mp = 1344.6 })

local function getRawDrink()
  if ham.isRetail and ham.getDrinkForRetail then return ham.getDrinkForRetail() end
  if ham.isClassic and ham.getDrinkForClassic then return ham.getDrinkForClassic() end
  if ham.isTBC and ham.getDrinkForTBC then return ham.getDrinkForTBC() end
  if ham.isWrath and ham.getDrinkForWrath then return ham.getDrinkForWrath() end
  if ham.isCata and ham.getDrinkForCata then return ham.getDrinkForCata() end
  if ham.isMop and ham.getDrinkForMists then return ham.getDrinkForMists() end
  if ham.isForever and ham.getDrinkForForever then return ham.getDrinkForForever() end
  return {}
end

-- Return a prioritized list of drink items for the current client, best first or, with "Weakest
-- Drink First", weakest first (ham.weakestFirst), buff drinks placed by Relaxed on Retail and by
-- the food buff on Forever, whose Nutritious drinks leave that.
function ham.getDrink()
  local list = getRawDrink()
  if ham.options.weakestDrinkFirst then list = ham.weakestFirst(list, "mp") end
  return ham.orderBuffFood(list, ham.isForever and ham.hasFoodBuff or ham.isRelaxed)
end
