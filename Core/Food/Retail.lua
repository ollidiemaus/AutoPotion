---@diagnostic disable: undefined-global
local addonName, ham = ...

function ham.getFoodForRetail()
  return {
    -- Conjured first: free and doesn't consume bag space or gold
    ham.conjuredManaBun,
    -- Communal feast (dual resource, shareable), highest crafting quality first
    ham.heartyFeastOfKnowledge,
    ham.feastOfKnowledge,
    -- Personal Well Fed food (health only), highest crafting quality first
    ham.heartyRoyalRoast,
    ham.royalRoast,
    -- Plain vendor food (health only, no stats)
    ham.bloodKnightBurger,
  }
end
