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

-- Retail - plain vendor food (no stats), restores health only.
ham.bloodKnightBurger = ham.Item.new(264992, "Blood Knight Burger")

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
