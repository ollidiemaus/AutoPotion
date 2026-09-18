---@diagnostic disable: undefined-global
local addonName, ham = ...

function ham.getFoodForClassic()
  return {
    -- Conjured food first: free and doesn't consume bag space or gold
    ham.conjuredCinnamonRoll,
    ham.conjuredSweetRoll,
    ham.conjuredSourdough,
    ham.conjuredPumpernickel,
    ham.conjuredRye,
    ham.conjuredBread,
    ham.conjuredMuffin,
    -- Stat ("Well Fed") food - only used when HAMDB.includeBuffFood is enabled
    ham.dirgesKickinChimaerokChops,
    ham.smokedDesertDumplings,
    ham.runnTumTuberSurprise,
    ham.grilledSquid,
    ham.nightfinSoup,
    -- Plain vendor/cooked food, highest tier first
    ham.roastedQuail,
    ham.curedHamSteak,
    ham.wildHogShank,
    ham.muttonChop,
    ham.haunchOfMeat,
    ham.toughJerky,
  }
end
