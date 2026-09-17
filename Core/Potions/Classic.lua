---@diagnostic disable: undefined-global
local addonName, ham = ...

function ham.getPotsForClassic()
  -- Base Classic potions list
  local pots = {
    ham.major,
    ham.combat,
    ham.superior,
    ham.greater,
    ham.healingPotion,
    ham.lesser,
    ham.minor
  }

  -- If in a PvP battleground, prioritize battleground draughts
  local inInstance, instanceType = IsInInstance()
  local isInBattleground = inInstance and instanceType == "pvp"
  if isInBattleground then
    -- Insert in reverse order so final priority is Major then Superior
    table.insert(pots, 1, ham.superiorHealingDraught)
    table.insert(pots, 1, ham.majorHealingDraught)
  end

  return pots
end

function ham.getHealthstonesForClassic()
  return {
    ham.major2,
    ham.major1,
    ham.major0,
    ham.greater2,
    ham.greater1,
    ham.greater0,
    ham.wipperRootTuber,
    ham.healtsthone2,
    ham.healtsthone1,
    ham.lilyRoot,
    ham.healtsthone0,
    ham.crystalFlakeThroatLozenge,
    ham.lesser2,
    ham.lesser1,
    ham.lesser0,
    ham.minor2,
    ham.minor1,
    ham.minor0
  }
end
