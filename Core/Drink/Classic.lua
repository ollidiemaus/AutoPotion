---@diagnostic disable: undefined-global
local addonName, ham = ...

function ham.getDrinkForClassic()
  return {
    -- Conjured water first: free and doesn't consume bag space or gold
    ham.conjuredCrystalWater,
    ham.conjuredSparklingWater,
    ham.conjuredMineralWater,
    ham.conjuredSpringWater,
    ham.conjuredPurifiedWater,
    ham.conjuredFreshWater,
    ham.conjuredWater,
    -- Dual restore (health AND mana, no stats) - shared with Core/Food/Classic.lua's list
    ham.essenceMango,
    ham.enrichedMannaBiscuit,
    ham.alteracMannaBiscuit,
    ham.graccusMinceMeatFruitcake,
    ham.bobbingApple,
    ham.refreshingRedApple,
    ham.greenTeaLeaf,
    ham.cookedCrabClaw,
    ham.sengginRoot,
    -- Plain vendor water, highest tier first, then cosmetic reskins (order doesn't matter)
    ham.morningGloryDew,
    ham.moonberryJuice,
    ham.sweetNectar,
    ham.melonJuice,
    ham.iceColdMilk,
    ham.refreshingSpringWater,
    ham.bottledWinterspringWater,
    ham.hyjalNectar,
    ham.enchantedWater,
    ham.bubblingWater,
    ham.fizzyFaireDrink,
    ham.goldthornTea,
    ham.blendedBeanBrew,
  }
end
