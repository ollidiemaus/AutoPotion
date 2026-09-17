---@diagnostic disable: undefined-global
local addonName, ham = ...

function ham.getDelightPotsForRetail()
  return {
    ham.refreshingSerumR2,
    ham.refreshingSerumR1,
    ham.cavedwellersDelightR3,
    ham.cavedwellersDelightR2,
    ham.cavedwellersDelightR1,
    ham.fleetingCavedwellersDelightR3,
    ham.fleetingCavedwellersDelightR2,
    ham.fleetingCavedwellersDelightR1,
  }
end

function ham.getPotsForRetail()
  local pots = {
    ham.concentratedSilvermoonPotion2,
    ham.concentratedSilvermoonPotion1,
    ham.fleetingSilvermoonPotion2,
    ham.fleetingSilvermoonPotion1,
    ham.silvermoonPotion2,
    ham.silvermoonPotion1,
    ham.potent,
    ham.fleetingInvigoratingHealingPotionR3,
    ham.invigoratingHealingPotionR3,
    ham.fleetingInvigoratingHealingPotionR2,
    ham.invigoratingHealingPotionR2,
    ham.fleetingInvigoratingHealingPotionR1,
    ham.invigoratingHealingPotionR1,
    ham.fleetingAlgariHealingPotionR3,
    ham.algariHealingPotionR3,
    ham.fleetingAlgariHealingPotionR2,
    ham.algariHealingPotionR2,
    ham.fleetingAlgariHealingPotionR1,
    ham.algariHealingPotionR1,
    ham.thirdWind,
    ham.survivalistsHealingPotion,
    ham.witheringDreamsR3,
    ham.witheringDreamsR2,
    ham.witheringDreamsR1,
    ham.dreamR3,
    ham.dreamsR2,
    ham.dreamR1,
    ham.witheringR3,
    ham.witheringR2,
    ham.witheringR1,
    ham.refreshingR3,
    ham.refreshingR2,
    ham.refreshingR1,
    ham.cosmic,
    ham.spiritual,
    ham.soulful,
    ham.ashran,
    ham.abyssal,
    ham.astral,
    ham.coastal,
    ham.ancient,
    ham.aged,
    ham.tonic,
    ham.master,
    ham.mythical,
    ham.runic,
    ham.resurgent,
    ham.super,
    ham.major,
    ham.lesser,
    ham.superior,
    ham.minor,
    ham.greater,
    ham.healingPotion
  }

  local isUnratedBattleground = C_PvP.IsBattleground() and not C_PvP.IsRatedBattleground()
  if not isUnratedBattleground then
    RemoveFromList(pots, ham.thirdWind)
  end

  if not HAMDB.witheringPotion then
    RemoveFromList(pots, ham.witheringR1)
    RemoveFromList(pots, ham.witheringR2)
    RemoveFromList(pots, ham.witheringR3)
  end

  if not HAMDB.witheringDreamsPotion then
    RemoveFromList(pots, ham.witheringDreamsR1)
    RemoveFromList(pots, ham.witheringDreamsR2)
    RemoveFromList(pots, ham.witheringDreamsR3)
  end

  return pots
end
