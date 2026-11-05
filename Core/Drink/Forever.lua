---@diagnostic disable: undefined-global
local addonName, ham = ...

-- Forever is Vanilla-based: the Classic Era list and Forever's own drinks.
function ham.getDrinkForForever()
  return {
    -- Conjured water first: free and doesn't consume bag space or gold
    ham.conjuredCrystalWater,
    ham.conjuredSparklingWater,
    ham.conjuredMineralWater,
    ham.conjuredSpringWater,
    ham.conjuredPurifiedWater,
    ham.conjuredFreshWater,
    ham.conjuredWater,
    -- Restorative Bread restores a percentage of health and mana, so it can't be sorted among
    -- the flat amounts. A full restore goes ahead of them, right below conjured items.
    ham.restorativeBread,
    -- Nutritious drinks leave the food buff - only used when the includeBuffFood option is enabled.
    -- Highest amount first.
    ham.sagesTea,
    ham.wickedSmoothie,
    ham.sunnyTea,
    ham.spicySmoothie,
    ham.triageTea,
    ham.calcifiedSmoothie,
    ham.goldthornTeaForever,
    ham.rootTea,
    ham.mrrgglSmrrthle,
    ham.royalTea,
    ham.slimySmoothie,
    ham.peaceTea,
    ham.venomousSmoothie,
    -- Dual restore (health AND mana, no stats) - shared with Core/Food/Forever.lua's list
    ham.essenceMango,
    ham.enrichedMannaBiscuit,
    ham.alteracMannaBiscuit,
    ham.graccusMinceMeatFruitcake,
    ham.refreshingRedApple,
    ham.ketharasHyjalStew,
    ham.sengginRoot,
    ham.greenTeaLeaf,
    -- Plain vendor water (no stats), highest tier first
    ham.mountainSpringWater,
    ham.hyjalNectar,
    ham.morningGloryDew,
    ham.morningGloryDewForever,
    ham.moonberryJuice,
    ham.bottledWinterspringWater,
    ham.sweetNectar,
    ham.enchantedWater,
    ham.melonJuice,
    ham.bubblingWater,
    ham.fizzyFaireDrink,
    ham.iceColdMilk,
    ham.blendedBeanBrew,
    ham.gustberryJuice,
    ham.refreshingSpringWater,
    ham.crispSpringWater,
  }
end
