local addonName, ham = ...

-- Classic - vendor water (mana restore, no stats)
ham.refreshingSpringWater = ham.Item.new(159, "Refreshing Spring Water")
ham.iceColdMilk = ham.Item.new(1179, "Ice Cold Milk")
ham.melonJuice = ham.Item.new(1205, "Melon Juice")
ham.sweetNectar = ham.Item.new(1708, "Sweet Nectar")
ham.moonberryJuice = ham.Item.new(1645, "Moonberry Juice")
ham.morningGloryDew = ham.Item.new(8766, "Morning Glory Dew")

-- Classic - conjured (Mage), prioritized first: free and doesn't consume bag/gold
ham.conjuredWater = ham.Item.new(5350, "Conjured Water", { conjured = true })
ham.conjuredFreshWater = ham.Item.new(2288, "Conjured Fresh Water", { conjured = true })
ham.conjuredPurifiedWater = ham.Item.new(2136, "Conjured Purified Water", { conjured = true })
ham.conjuredSpringWater = ham.Item.new(3772, "Conjured Spring Water", { conjured = true })
ham.conjuredMineralWater = ham.Item.new(8077, "Conjured Mineral Water", { conjured = true })
ham.conjuredSparklingWater = ham.Item.new(8078, "Conjured Sparkling Water", { conjured = true })
ham.conjuredCrystalWater = ham.Item.new(8079, "Conjured Crystal Water", { conjured = true })

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
