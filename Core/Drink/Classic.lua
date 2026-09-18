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
    -- Plain vendor water, highest tier first
    ham.morningGloryDew,
    ham.moonberryJuice,
    ham.sweetNectar,
    ham.melonJuice,
    ham.iceColdMilk,
    ham.refreshingSpringWater,
  }
end
