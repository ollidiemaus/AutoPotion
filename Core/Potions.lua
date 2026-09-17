---@diagnostic disable: undefined-global
local addonName, ham = ...
local isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
local isTBC = (WOW_PROJECT_ID == 5) -- TBC Anniversary / BCC
local isWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
local isCata = (WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC)
local isMop = (WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC)

ham.healthstone = ham.Item.new(5512, "Healthstone")
ham.demonicHealthstone = ham.Item.new(224464, "Demonic Healthstone") ---1 Minute CD due to Pact of Gluttony
--Midnight
ham.concentratedSilvermoonPotion2 = ham.Item.new(271884, "Concentrated Silvermoon Health Potion")
ham.concentratedSilvermoonPotion1 = ham.Item.new(271883, "Concentrated Silvermoon Health Potion")
ham.fleetingSilvermoonPotion2 = ham.Item.new(245918, "Fleeting Silvermoon Health Potion")
ham.fleetingSilvermoonPotion1 = ham.Item.new(245919, "Fleeting Silvermoon Health Potion")
ham.silvermoonPotion2 = ham.Item.new(241304, "Silvermoon Health Potion")
ham.silvermoonPotion1 = ham.Item.new(241305, "Silvermoon Health Potion")
ham.refreshingSerumR2 = ham.Item.new(241306, "Refreshing Serum")
ham.refreshingSerumR1 = ham.Item.new(241307, "Refreshing Serum")
ham.potent = ham.Item.new(258138, "Potent Healing Potion") -- 50% -healing
--The War Within
ham.invigoratingHealingPotionR3 = ham.Item.new(244839, "Invigorating Healing Potion")
ham.invigoratingHealingPotionR2 = ham.Item.new(244838, "Invigorating Healing Potion")
ham.invigoratingHealingPotionR1 = ham.Item.new(244835, "Invigorating Healing Potion")
ham.fleetingInvigoratingHealingPotionR3 = ham.Item.new(244849, "Fleeting Invigorating Healing Potion")
ham.fleetingInvigoratingHealingPotionR2 = ham.Item.new(244848, "Fleeting Invigorating Healing Potion")
ham.fleetingInvigoratingHealingPotionR1 = ham.Item.new(244847, "Fleeting Invigorating Healing Potion")
ham.algariHealingPotionR3 = ham.Item.new(211880, "Algari Healing Potion")
ham.algariHealingPotionR2 = ham.Item.new(211879, "Algari Healing Potion")
ham.algariHealingPotionR1 = ham.Item.new(211878, "Algari Healing Potion")
ham.fleetingAlgariHealingPotionR3 = ham.Item.new(212944, "Fleeting Algari Healing Potion")
ham.fleetingAlgariHealingPotionR2 = ham.Item.new(212943, "Fleeting Algari Healing Potion")
ham.fleetingAlgariHealingPotionR1 = ham.Item.new(212942, "Fleeting Algari Healing Potion")
ham.cavedwellersDelightR3 = ham.Item.new(212244, "Cavedweller's Delight")
ham.cavedwellersDelightR2 = ham.Item.new(212243, "Cavedweller's Delight")
ham.cavedwellersDelightR1 = ham.Item.new(212242, "Cavedweller's Delight")
ham.fleetingCavedwellersDelightR3 = ham.Item.new(212950, "Fleeting Cavedweller's Delight")
ham.fleetingCavedwellersDelightR2 = ham.Item.new(212949, "Fleeting Cavedweller's Delight")
ham.fleetingCavedwellersDelightR1 = ham.Item.new(212948, "Fleeting Cavedweller's Delight")
ham.thirdWind = ham.Item.new(138486, "\"Third Wind\" Potion")
ham.survivalistsHealingPotion = ham.Item.new(224021, "Survivalist's Healing Potion")
ham.witheringDreamsR3 = ham.Item.new(207041, "Potion of Withering Dreams")
ham.witheringDreamsR2 = ham.Item.new(207040, "Potion of Withering Dreams")
ham.witheringDreamsR1 = ham.Item.new(207039, "Potion of Withering Dreams")
ham.dreamR3 = ham.Item.new(207023, "Dreamwalker's Healing Potion")
ham.dreamsR2 = ham.Item.new(207022, "Dreamwalker's Healing Potion")
ham.dreamR1 = ham.Item.new(207021, "Dreamwalker's Healing Potion")
ham.witheringR3 = ham.Item.new(191371, "Potion of Withering Vitality")
ham.witheringR2 = ham.Item.new(191370, "Potion of Withering Vitality")
ham.witheringR1 = ham.Item.new(191369, "Potion of Withering Vitality")
ham.refreshingR3 = ham.Item.new(191380, "Refreshing Healing Potion")
ham.refreshingR2 = ham.Item.new(191379, "Refreshing Healing Potion")
ham.refreshingR1 = ham.Item.new(191378, "Refreshing Healing Potion")
ham.cosmic = ham.Item.new(187802, "Cosmic Healing Potion")
ham.spiritual = ham.Item.new(171267, "Spiritual Healing Potion")
ham.soulful = ham.Item.new(180317, "Soulful Healing Potion")
ham.ashran = ham.Item.new(115498, "Ashran Healing Tonic")
ham.abyssal = ham.Item.new(169451, "Abyssal Healing Potion")
ham.astral = ham.Item.new(152615, "Astral Healing Potion")
ham.coastal = ham.Item.new(152494, "Coastal Healing Potion")
ham.ancient = ham.Item.new(127834, "Ancient Healing Potion")
ham.aged = ham.Item.new(136569, "Aged Health Potion")
ham.tonic = ham.Item.new(109223, "Healing Tonic")
--Mists
ham.master = ham.Item.new(76097, "Master Healing Potion")
--Cata
ham.roguesDraught = ham.Item.new(63300, "Rogue's Draught")
ham.mythical = ham.Item.new(57191, "Mythical Healing Potion")
ham.crazy_alch = ham.Item.new(40077, "Crazy Alchemist's Potion")
ham.runic_inject = ham.Item.new(41166, "Runic Healing Injector")
ham.runic = ham.Item.new(33447, "Runic Healing Potion")
ham.endless = ham.Item.new(43569, "Endless Healing Potion")
ham.resurgent = ham.Item.new(39671, "Resurgent Healing Potion")
ham.argent = ham.Item.new(43531, "Argent Healing Potion")
--TBC/Classic
ham.injector = ham.Item.new(33092, "Healing Potion Injector")
ham.superreju = ham.Item.new(22850, "Super Rejuvenation Potion")
ham.auchenai = ham.Item.new(32947, "Auchenai Healing Potion")
ham.super = ham.Item.new(22829, "Super Healing Potion")
ham.major = ham.Item.new(13446, "Major Healing Potion")
ham.lesser = ham.Item.new(858, "Lesser Healing Potion")
ham.combat = ham.Item.new(18839, "Combat Healing Potion")
--superior has probably wrong scaling
ham.superior = ham.Item.new(3928, "Superior Healing Potion")
ham.minor = ham.Item.new(118, "Minor Healing Potion")
ham.greater = ham.Item.new(1710, "Greater Healing Potion")
ham.healingPotion = ham.Item.new(929, "Healing Potion")
-- Classic PvP battleground-only draughts
ham.majorHealingDraught = ham.Item.new(17348, "Major Healing Draught")
ham.superiorHealingDraught = ham.Item.new(17349, "Superior Healing Draught")

------Healthstones for Classic------
ham.minor0 = ham.Item.new(5512, "Minor Healthstone")
ham.minor1 = ham.Item.new(19004, "Minor Healthstone")
ham.minor2 = ham.Item.new(19005, "Minor Healthstone")
ham.lesser0 = ham.Item.new(5511, "Lesser Healthstone")
ham.lesser1 = ham.Item.new(19006, "Lesser Healthstone")
ham.lesser2 = ham.Item.new(19007, "Lesser Healthstone")
ham.crystalFlakeThroatLozenge = ham.Item.new(23683, "Crystal Flake Throat Lozenge")
ham.healtsthone0 = ham.Item.new(5509, "Healthstone")
ham.lilyRoot = ham.Item.new(14894, "Lily Root")
ham.healtsthone1 = ham.Item.new(19008, "Healthstone")
ham.healtsthone2 = ham.Item.new(19009, "Healthstone")
ham.wipperRootTuber = ham.Item.new(11951, "Whipper Root Tuber")
ham.greater0 = ham.Item.new(5510, "Greater Healthstone")
ham.greater1 = ham.Item.new(19010, "Greater Healthstone")
ham.greater2 = ham.Item.new(19011, "Greater Healthstone")
ham.major0 = ham.Item.new(9421, "Major Healthstone")
ham.major1 = ham.Item.new(19012, "Major Healthstone")
ham.major2 = ham.Item.new(19013, "Major Healthstone")
------Healthstones for TBC------
ham.master0 = ham.Item.new(22103, "Master Healthstone")
ham.master1 = ham.Item.new(22104, "Master Healthstone")
ham.master2 = ham.Item.new(22105, "Master Healthstone")
------Healthstones for WotLK------
ham.demonicWotLK0 = ham.Item.new(36889, "Demonic Healthstone")
ham.demonicWotLK1 = ham.Item.new(36890, "Demonic Healthstone")
ham.demonicWotLK2 = ham.Item.new(36891, "Demonic Healthstone")
ham.fel0 = ham.Item.new(36892, "Fel Healthstone")
ham.fel1 = ham.Item.new(36893, "Fel Healthstone")
ham.fel2 = ham.Item.new(36894, "Fel Healthstone")
------Healthstones for Cata------

function RemoveFromList(list, itemToRemove)
  for i = #list, 1, -1 do
    if list[i] == itemToRemove then
      table.remove(list, i)
    end
  end
end

function ham.getDelightPots()
  if isRetail and ham.getDelightPotsForRetail then
    return ham.getDelightPotsForRetail()
  end
  return {}
end

function ham.getPots()
  if isRetail and ham.getPotsForRetail then return ham.getPotsForRetail() end
  if isClassic and ham.getPotsForClassic then return ham.getPotsForClassic() end
  if isTBC and ham.getPotsForTBC then return ham.getPotsForTBC() end
  if isWrath and ham.getPotsForWrath then return ham.getPotsForWrath() end
  if isCata and ham.getPotsForCata then return ham.getPotsForCata() end
  if isMop and ham.getPotsForMists then return ham.getPotsForMists() end

  -- Fallback: return empty table if no version matches
  return {}
end

function ham.getHealthstonesClassic()
  if isClassic and ham.getHealthstonesForClassic then return ham.getHealthstonesForClassic() end
  if isTBC and ham.getHealthstonesForTBC then return ham.getHealthstonesForTBC() end
  if isWrath and ham.getHealthstonesForWrath then return ham.getHealthstonesForWrath() end
  if isCata and ham.getHealthstonesForCata then return ham.getHealthstonesForCata() end
  if isMop and ham.getHealthstonesForMists then return ham.getHealthstonesForMists() end

  -- Fallback: return empty table if no version matches
  return {}
end
