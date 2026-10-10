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
    ham.cookedCrabClaw,
    ham.sengginRoot,
    ham.greenTeaLeaf,
    -- Plain vendor water (no stats), highest tier first
    ham.hyjalNectar,
    ham.morningGloryDew,
    ham.moonberryJuice,
    ham.bottledWinterspringWater,
    ham.sweetNectar,
    ham.enchantedWater,
    ham.goldthornTea,
    ham.melonJuice,
    ham.bubblingWater,
    ham.fizzyFaireDrink,
    ham.iceColdMilk,
    ham.blendedBeanBrew,
    ham.refreshingSpringWater,
  }
end
