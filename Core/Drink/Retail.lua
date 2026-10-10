---@diagnostic disable: undefined-global
local addonName, ham = ...

function ham.getDrinkForRetail()
  return {
    -- Conjured first: free and doesn't consume bag space or gold. Conjured Mana Bun is
    -- dual restore, shared with Core/Food/Retail.lua's list; Conjured Tea is mana-only.
    ham.conjuredTea,
    ham.conjuredManaBun,
    -- "Relaxed" drink (mana restore plus a secondary stat), opt-in via includeBuffFood
    ham.argentleafTea,
    ham.sanguithornTea,
    ham.azerootTea,
    -- Plain drink (mana only, no stats), highest tier first
    ham.manaLilyTea,
    ham.tranquilityBloomTea,
    ham.springrunnerSparkling,
    ham.bloomNectar,
    ham.teaOfMistsAndRain,
    ham.denshroomDeepRoast,
    ham.lashroomQuencher,
    ham.extractOfLightbloom,
    ham.purifiedStormWater,
    ham.shadeleafTea,
    ham.purifiedCordial,
    ham.everspringWater,
    ham.rootJuice,
    ham.crispBluffBock,
    ham.refreshingAhluaWater,
    ham.grottoGulp,
    ham.voidPort,
    ham.voidwyrmAbsinthe,
    ham.goldengroveJuice,
    ham.wineNot,
    ham.sunwellShot,
    ham.darkwellDraft,
    ham.dawnmosa,
    ham.magistersMead,
    ham.dragonhawkFlight,
    ham.fairbreezeFranciacorta,
    ham.buddingLight,
    ham.chanterelleShandy,
    ham.worldRootBeer,
    ham.brightClaw,
  }
end
