---@diagnostic disable: undefined-global
local addonName, ham = ...

function ham.getDrinkForWrath()
  return {
    -- Conjured water first: free and doesn't consume bag space or gold
    ham.conjuredManaStrudel,
    ham.conjuredManaPie,
    -- Dual restore (health AND mana, no stats) - shared with Core/Food/Wrath.lua's list
    ham.blackJelly,
    ham.giganticFeast,
    ham.grilledBonescale,
    ham.sauteedGoby,
    ham.smallFeast,
    ham.smokedRockfin,
    -- Plain water (no stats), highest tier first
    ham.crusadersWaterskin,
    ham.honeymintTea,
    ham.kungaloosh,
    ham.starsSorrow,
    ham.yetiMilk,
    ham.bitterPlasma,
    ham.freshAppleJuice,
    ham.freshSqueezedLimeade,
    ham.pungentSealWhey,
    ham.frostberryJuice,
    ham.grizzleberryJuice,
    ham.mountainWater,
    ham.sweetenedGoatsMilk,
    -- TBC and Classic Era items, as a fallback for lower-level characters
    -- TBC: conjured water
    ham.conjuredGlacierWater,
    ham.conjuredMountainSpringWater,
    -- TBC: dual restore (health AND mana, no stats)
    ham.conjuredMannaBiscuit,
    ham.hotButteredTrout,
    ham.naaruRation,
    ham.enrichedTeroconeJuice,
    ham.undersporePod,
    -- TBC: plain water (no stats), highest tier first
    ham.blackCoffee,
    ham.blackrockFortifiedWater,
    ham.dosOgris,
    ham.ethermead,
    ham.gilneasSparklingWater,
    ham.purifiedDraenicWater,
    ham.sparklingSouthshoreCider,
    ham.starsTears,
    ham.blackrockMineralWater,
    ham.filteredDraenicWater,
    ham.silverwine,
    ham.starsLament,
    ham.blackrockSpringWater,
    -- Classic Era: conjured water
    ham.conjuredCrystalWater,
    ham.conjuredSparklingWater,
    ham.conjuredMineralWater,
    ham.conjuredSpringWater,
    ham.conjuredPurifiedWater,
    ham.conjuredFreshWater,
    ham.conjuredWater,
    -- Classic Era: dual restore (health AND mana, no stats)
    ham.essenceMango,
    ham.enrichedMannaBiscuit,
    ham.alteracMannaBiscuit,
    ham.graccusMinceMeatFruitcake,
    ham.bobbingApple,
    ham.refreshingRedApple,
    ham.cookedCrabClaw,
    ham.sengginRoot,
    ham.greenTeaLeaf,
    -- Classic Era: plain water (no stats), highest tier first
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
