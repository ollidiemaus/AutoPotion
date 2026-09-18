local addonName, ham = ...

-- Retail - Mage-conjured (restores both health and mana)
ham.conjuredManaBun = ham.Item.new(113509, "Conjured Mana Bun", { conjured = true })

-- Retail - communal feast: Well Fed with a secondary stat, restores both health and mana.
-- "Hearty" is the same recipe at a higher crafting quality (Hearty Well Fed also persists through death).
ham.heartyFeastOfKnowledge = ham.Item.new(275269, "Hearty Feast of Knowledge", { buffFood = true })
ham.feastOfKnowledge = ham.Item.new(275266, "Feast of Knowledge", { buffFood = true })

-- Retail - personal Well Fed food: flat primary stat, restores health only.
ham.heartyRoyalRoast = ham.Item.new(242747, "Hearty Royal Roast", { buffFood = true })
ham.royalRoast = ham.Item.new(242275, "Royal Roast", { buffFood = true })

-- Retail - other current-tier "Well Fed" food (communal feast or personal, either primary or
-- secondary stat). Wowhead's Food & Drinks category lists dozens of cosmetic name/icon reskins
-- of the same few mechanics at the current level cap; these are the confirmed Well Fed ones,
-- included individually since a given player only ever owns one specific reskin.
-- TODO: verify Beledar's Bounty (222728), Hearty Authentic Undermine Clam Chowder (235853),
-- Spirit Sprouts (280422) - Wowhead rate-limited before these could be checked.
ham.amaniCornucopia = ham.Item.new(275264, "Amani Cornucopia", { buffFood = true })
ham.arcanoCutlets = ham.Item.new(242287, "Arcano Cutlets", { buffFood = true })
ham.bakedLuckyLoa = ham.Item.new(242279, "Baked Lucky Loa", { buffFood = true })
ham.bloodthistleWrappedCutlets = ham.Item.new(242296, "Bloodthistle-Wrapped Cutlets", { buffFood = true })
ham.bloomSkewers = ham.Item.new(242302, "Bloom Skewers", { buffFood = true })
ham.bloomingFeast = ham.Item.new(242273, "Blooming Feast", { buffFood = true })
ham.braisedBloodHunter = ham.Item.new(242276, "Braised Blood Hunter", { buffFood = true })
ham.butteredRootCrab = ham.Item.new(242280, "Buttered Root Crab", { buffFood = true })
ham.championsBento = ham.Item.new(242274, "Champion's Bento", { buffFood = true })
ham.crimsonCalamari = ham.Item.new(242277, "Crimson Calamari", { buffFood = true })
ham.eversongPudding = ham.Item.new(242292, "Eversong Pudding", { buffFood = true })
ham.farstriderRations = ham.Item.new(242309, "Farstrider Rations", { buffFood = true })
ham.felKissedFilet = ham.Item.new(242286, "Fel-Kissed Filet", { buffFood = true })
ham.felberryFigs = ham.Item.new(242294, "Felberry Figs", { buffFood = true })
ham.floraFrenzy = ham.Item.new(255848, "Flora Frenzy", { buffFood = true })
ham.foragersMedley = ham.Item.new(242306, "Forager's Medley", { buffFood = true })
ham.friedBloomtail = ham.Item.new(242291, "Fried Bloomtail", { buffFood = true })
ham.glitterSkewers = ham.Item.new(242281, "Glitter Skewers", { buffFood = true })
ham.harandarCelebration = ham.Item.new(255846, "Harandar Celebration", { buffFood = true })
ham.hearthflameSupper = ham.Item.new(242295, "Hearthflame Supper", { buffFood = true })
ham.heartyAmaniCornucopia = ham.Item.new(275267, "Hearty Amani Cornucopia", { buffFood = true })
ham.heartyArcanoCutlets = ham.Item.new(242759, "Hearty Arcano Cutlets", { buffFood = true })
ham.heartyBloodthistleWrappedCutlets = ham.Item.new(242768, "Hearty Bloodthistle-Wrapped Cutlets", { buffFood = true })
ham.heartyBloomSkewers = ham.Item.new(242769, "Hearty Bloom Skewers", { buffFood = true })
ham.heartyBloomingFeast = ham.Item.new(242745, "Hearty Blooming Feast", { buffFood = true })
ham.heartyBraisedBloodHunter = ham.Item.new(242748, "Hearty Braised Blood Hunter", { buffFood = true })
ham.heartyButteredRootCrab = ham.Item.new(242752, "Hearty Buttered Root Crab", { buffFood = true })
ham.heartyChampionsBento = ham.Item.new(242746, "Hearty Champion's Bento", { buffFood = true })
ham.heartyCrimsonCalamari = ham.Item.new(242749, "Hearty Crimson Calamari", { buffFood = true })
ham.heartyEversongPudding = ham.Item.new(242764, "Hearty Eversong Pudding", { buffFood = true })
ham.heartyFarstriderRations = ham.Item.new(242776, "Hearty Farstrider Rations", { buffFood = true })
ham.heartyFelKissedFilet = ham.Item.new(242758, "Hearty Fel-Kissed Filet", { buffFood = true })
ham.heartyFelberryFigs = ham.Item.new(242766, "Hearty Felberry Figs", { buffFood = true })
ham.heartyFloraFrenzy = ham.Item.new(267000, "Hearty Flora Frenzy", { buffFood = true })
ham.heartyFloraFrenzy2 = ham.Item.new(268680, "Hearty Flora Frenzy", { buffFood = true })
ham.heartyForagersMedley = ham.Item.new(242773, "Hearty Forager's Medley", { buffFood = true })
ham.heartyFriedBloomtail = ham.Item.new(242763, "Hearty Fried Bloomtail", { buffFood = true })
ham.heartyGlitterSkewers = ham.Item.new(242753, "Hearty Glitter Skewers", { buffFood = true })
ham.heartyHarandarCelebration = ham.Item.new(266996, "Hearty Harandar Celebration", { buffFood = true })
ham.heartyHearthflameSupper = ham.Item.new(242767, "Hearty Hearthflame Supper", { buffFood = true })
ham.heartyImpossiblyRoyalRoast = ham.Item.new(268679, "Hearty Impossibly Royal Roast", { buffFood = true })
ham.heartyLoasGathering = ham.Item.new(275268, "Hearty Loa's Gathering", { buffFood = true })
ham.heartyManaInfusedStew = ham.Item.new(242770, "Hearty Mana-Infused Stew", { buffFood = true })
ham.heartyNullAndVoidPlate = ham.Item.new(242754, "Hearty Null and Void Plate", { buffFood = true })
ham.heartyPortableSnack = ham.Item.new(242775, "Hearty Portable Snack", { buffFood = true })
ham.heartyPufferPlate = ham.Item.new(275262, "Hearty Puffer Plate", { buffFood = true })
ham.heartyQueldoreiMedley = ham.Item.new(242744, "Hearty Quel'dorei Medley", { buffFood = true })
ham.heartyQueldoreiMedley2 = ham.Item.new(266986, "Hearty Quel'dorei Medley", { buffFood = true })
ham.heartyQuickSandwich = ham.Item.new(242774, "Hearty Quick Sandwich", { buffFood = true })
ham.heartyRootlandSurprise = ham.Item.new(242751, "Hearty Rootland Surprise", { buffFood = true })
ham.heartySilvermoonParade = ham.Item.new(266985, "Hearty Silvermoon Parade", { buffFood = true })
ham.heartySilvermoonStandard = ham.Item.new(242772, "Hearty Silvermoon Standard", { buffFood = true })
ham.heartySpellfireFilet = ham.Item.new(242761, "Hearty Spellfire Filet", { buffFood = true })
ham.heartySpicedBiscuits = ham.Item.new(242771, "Hearty Spiced Biscuits", { buffFood = true })
ham.heartySunSearedLumifin = ham.Item.new(242755, "Hearty Sun-Seared Lumifin", { buffFood = true })
ham.heartySunwellDelight = ham.Item.new(242765, "Hearty Sunwell Delight", { buffFood = true })
ham.heartySweetAndSourSkewers = ham.Item.new(275263, "Hearty Sweet-And-Sour Skewers", { buffFood = true })
ham.heartyTastySmokedTetra = ham.Item.new(242750, "Hearty Tasty Smoked Tetra", { buffFood = true })
ham.heartyTwilightAnglersMedley = ham.Item.new(242760, "Hearty Twilight Angler's Medley", { buffFood = true })
ham.heartyVenomSpicedCutlets = ham.Item.new(275259, "Hearty Venom-Spiced Cutlets", { buffFood = true })
ham.heartyVoidKissedFishRolls = ham.Item.new(242756, "Hearty Void-Kissed Fish Rolls", { buffFood = true })
ham.heartyWarpedWiseWings = ham.Item.new(242757, "Hearty Warped Wise Wings", { buffFood = true })
ham.heartyWiseTails = ham.Item.new(242762, "Hearty Wise Tails", { buffFood = true })
ham.impossiblyRoyalRoast = ham.Item.new(255847, "Impossibly Royal Roast", { buffFood = true })
ham.loasGathering = ham.Item.new(275265, "Loa's Gathering", { buffFood = true })
ham.manaInfusedStew = ham.Item.new(242303, "Mana-Infused Stew", { buffFood = true })
ham.nullAndVoidPlate = ham.Item.new(242282, "Null and Void Plate", { buffFood = true })
ham.portableSnack = ham.Item.new(242308, "Portable Snack", { buffFood = true })
ham.pufferPlate = ham.Item.new(275260, "Puffer Plate", { buffFood = true })
ham.queldoreiMedley = ham.Item.new(242272, "Quel'dorei Medley", { buffFood = true })
ham.quickSandwich = ham.Item.new(242307, "Quick Sandwich", { buffFood = true })
ham.silvermoonParade = ham.Item.new(255845, "Silvermoon Parade", { buffFood = true })
ham.silvermoonStandard = ham.Item.new(242305, "Silvermoon Standard", { buffFood = true })
ham.spellfireFilet = ham.Item.new(242289, "Spellfire Filet", { buffFood = true })
ham.spicedBiscuits = ham.Item.new(242304, "Spiced Biscuits", { buffFood = true })
ham.sunSearedLumifin = ham.Item.new(242283, "Sun-Seared Lumifin", { buffFood = true })
ham.sunwellDelight = ham.Item.new(242293, "Sunwell Delight", { buffFood = true })
ham.sweetAndSourSkewers = ham.Item.new(275261, "Sweet-And-Sour Skewers", { buffFood = true })
ham.tastySmokedTetra = ham.Item.new(242278, "Tasty Smoked Tetra", { buffFood = true })
ham.twilightAnglersMedley = ham.Item.new(242288, "Twilight Angler's Medley", { buffFood = true })
ham.venomSpicedCutlets = ham.Item.new(275258, "Venom-Spiced Cutlets", { buffFood = true })
ham.voidKissedFishRolls = ham.Item.new(242284, "Void-Kissed Fish Rolls", { buffFood = true })
ham.warpedWiseWings = ham.Item.new(242285, "Warped Wise Wings", { buffFood = true })
ham.wiseTails = ham.Item.new(242290, "Wise Tails", { buffFood = true })

-- Retail - plain vendor food (no stats). Same reskin situation as above: dozens of cosmetic
-- flavor/zone variants of the same restore-only mechanic, included individually for coverage.
ham.bloodKnightBurger = ham.Item.new(264992, "Blood Knight Burger")
ham.akilstew = ham.Item.new(260276, "Akil'stew")
ham.alndustInfusedFeast = ham.Item.new(260288, "Alndust-Infused Feast")
ham.asteroidSoup = ham.Item.new(260292, "Asteroid Soup")
ham.astralApplePie = ham.Item.new(260298, "Astral Apple Pie")
ham.bogLegs = ham.Item.new(260270, "Bog Legs")
ham.coiledCurry = ham.Item.new(280182, "Coiled Curry")
ham.delicateDartLegs = ham.Item.new(264993, "Delicate Dart Legs")
ham.fairbreezeFeast = ham.Item.new(260262, "Fairbreeze Feast")
ham.ghostlandsPepper = ham.Item.new(260257, "Ghostlands Pepper")
ham.goldenboughPreserves = ham.Item.new(264995, "Goldenbough Preserves")
ham.goldenmistGouda = ham.Item.new(264973, "Goldenmist Gouda")
ham.harrierHotcakes = ham.Item.new(280183, "Harrier Hotcakes")
ham.jerkBoarJerky = ham.Item.new(260269, "Jerk Boar Jerky")
ham.kalethasSunsalad = ham.Item.new(260254, "Kale'thas Sunsalad")
ham.lightbloominOnion = ham.Item.new(260279, "Lightbloomin' Onion")
ham.luxuriousOmelette = ham.Item.new(260256, "Luxurious Omelette")
ham.machosMagnificentFishTacos = ham.Item.new(238896, "Macho's Magnificent \"Fish\" Tacos")
ham.managiRoll = ham.Item.new(260255, "Managi Roll")
ham.mukleechCurry = ham.Item.new(260275, "Mukleech Curry")
ham.murderRoe = ham.Item.new(264991, "Murder Roe")
ham.pangoAndMash = ham.Item.new(260268, "Pango and Mash")
ham.pickledBloomShoots = ham.Item.new(264994, "Pickled Bloom Shoots")
ham.potatoadSalad = ham.Item.new(260278, "Potatoad Salad")
ham.queldanasRations = ham.Item.new(260264, "Quel'Danas Rations")
ham.quelthalasCheese = ham.Item.new(260290, "Quel'Thalas Cheese")
ham.rendoreiRations = ham.Item.new(260289, "Ren'dorei Rations")
ham.roastedAbyssalEel = ham.Item.new(260299, "Roasted Abyssal Eel")
ham.sauteedFungalTubers = ham.Item.new(260280, "Sauteed Fungal Tubers")
ham.sedgeCrawlerGumbo = ham.Item.new(260277, "Sedge Crawler Gumbo")
ham.shroomsAndNectar = ham.Item.new(260286, "Shrooms and Nectar")
ham.silvermoonSoireeSpread = ham.Item.new(260263, "Silvermoon Soiree Spread")
ham.stargazerPudding = ham.Item.new(260291, "Stargazer Pudding")
ham.steamedHexxalorLobster = ham.Item.new(260267, "Steamed Hexx'alor Lobster")
ham.stirFriedSaptorSirloin = ham.Item.new(260281, "Stir-Fried Saptor Sirloin")
ham.sunBastedCeviche = ham.Item.new(246383, "Sun-Basted Ceviche")
ham.sweetsawSurprise = ham.Item.new(280184, "Sweetsaw Surprise")
ham.voidfarersRespite = ham.Item.new(260297, "Voidfarer's Respite")
ham.worldRootsBanquet = ham.Item.new(260287, "World Roots Banquet")

-- Classic - vendor/cooked food (no stats)
ham.toughJerky = ham.Item.new(117, "Tough Jerky")
ham.haunchOfMeat = ham.Item.new(2287, "Haunch of Meat")
ham.muttonChop = ham.Item.new(3770, "Mutton Chop")
ham.wildHogShank = ham.Item.new(3771, "Wild Hog Shank")
ham.curedHamSteak = ham.Item.new(4599, "Cured Ham Steak")
ham.roastedQuail = ham.Item.new(8952, "Roasted Quail")

-- Classic - stat ("Well Fed") food, highly situational, opt-in via HAMDB.includeBuffFood
ham.grilledSquid = ham.Item.new(13928, "Grilled Squid", { buffFood = true }) -- Agility
ham.nightfinSoup = ham.Item.new(13931, "Nightfin Soup", { buffFood = true }) -- Mana regen
ham.runnTumTuberSurprise = ham.Item.new(18254, "Runn Tum Tuber Surprise", { buffFood = true }) -- Intellect
ham.smokedDesertDumplings = ham.Item.new(20452, "Smoked Desert Dumplings", { buffFood = true }) -- Strength
ham.dirgesKickinChimaerokChops = ham.Item.new(21023, "Dirge's Kickin' Chimaerok Chops", { buffFood = true }) -- Stamina

-- Classic - conjured (Mage), prioritized first: free and doesn't consume bag/gold
ham.conjuredMuffin = ham.Item.new(5349, "Conjured Muffin", { conjured = true })
ham.conjuredBread = ham.Item.new(1113, "Conjured Bread", { conjured = true })
ham.conjuredRye = ham.Item.new(1114, "Conjured Rye", { conjured = true })
ham.conjuredPumpernickel = ham.Item.new(1487, "Conjured Pumpernickel", { conjured = true })
ham.conjuredSourdough = ham.Item.new(8075, "Conjured Sourdough", { conjured = true })
ham.conjuredSweetRoll = ham.Item.new(8076, "Conjured Sweet Roll", { conjured = true })
ham.conjuredCinnamonRoll = ham.Item.new(22895, "Conjured Cinnamon Roll", { conjured = true })

local function getRawFood()
  if ham.isRetail and ham.getFoodForRetail then return ham.getFoodForRetail() end
  if ham.isClassic and ham.getFoodForClassic then return ham.getFoodForClassic() end
  if ham.isTBC and ham.getFoodForTBC then return ham.getFoodForTBC() end
  if ham.isWrath and ham.getFoodForWrath then return ham.getFoodForWrath() end
  if ham.isCata and ham.getFoodForCata then return ham.getFoodForCata() end
  if ham.isMop and ham.getFoodForMists then return ham.getFoodForMists() end
  return {}
end

-- Return a prioritized list of food items for the current client, excluding
-- "buff food" (situational Well Fed stat food) unless the user opted in.
function ham.getFood()
  local list = getRawFood()
  if HAMDB and HAMDB.includeBuffFood then
    return list
  end
  local filtered = {}
  for _, item in ipairs(list) do
    if not item.hasTag("buffFood") then
      table.insert(filtered, item)
    end
  end
  return filtered
end
