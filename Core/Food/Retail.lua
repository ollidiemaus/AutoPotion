---@diagnostic disable: undefined-global
local addonName, ham = ...

function ham.getFoodForRetail()
  return {
    ham.conjuredManaBun,
    ham.feastOfKnowledge,
  }
end
