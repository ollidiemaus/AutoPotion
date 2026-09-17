---@diagnostic disable: undefined-global
local addonName, ham = ...

function ham.getPotsForCata()
  return {
    ham.roguesDraught,
    ham.mythical,
    ham.crazy_alch,
    ham.runic_inject,
    ham.runic,
    ham.superreju,
    ham.endless,
    ham.injector,
    ham.resurgent,
    ham.super,
    ham.argent,
    ham.auchenai,
    ham.major,
    ham.superior,
    ham.greater,
    ham.healingPotion,
    ham.lesser,
    ham.minor
  }
end

function ham.getHealthstonesForCata()
  return {
    ham.fel2,
    ham.fel1,
    ham.fel0,
    ham.demonicWotLK2,
    ham.demonicWotLK1,
    ham.demonicWotLK0,
    ham.master2,
    ham.master1,
    ham.master0,
    ham.major2,
    ham.major1,
    ham.major0,
    ham.greater2,
    ham.greater1,
    ham.greater0,
    ham.healtsthone2,
    ham.healtsthone1,
    ham.healtsthone0,
    ham.lesser2,
    ham.lesser1,
    ham.lesser0,
    ham.minor2,
    ham.minor1,
    ham.minor0
  }
end
