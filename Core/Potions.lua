local addonName, ham = ...
local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)

--ham.leywine = ham.Item.new(194684,"Azure Leywine")
--ham.healthstone = ham.Item.new(117, "Healthstone")
ham.healthstone = ham.Item.new(5512, "Healthstone")
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
ham.master = ham.Item.new(76097, "Master Healing Potion")
ham.mythical = ham.Item.new(57191, "Mythical Healing Potion")
ham.runic = ham.Item.new(33447, "Runic Healing Potion")
ham.resurgent = ham.Item.new(39671, "Resurgent Healing Potion")
ham.super = ham.Item.new(22829, "Super Healing Potion")
ham.major = ham.Item.new(13446, "Major Healing Potion")
ham.lesser = ham.Item.new(858, "Lesser Healing Potion")
--superior has probably wrong scaling
ham.superior = ham.Item.new(3928, "Superior Healing Potion")
ham.minor = ham.Item.new(118, "Minor Healing Potion")
ham.greater = ham.Item.new(1710, "Greater Healing Potion")
ham.healingPotion = ham.Item.new(929, "Healing Potion")

------Healthstones for Classic------
ham.minor0 = ham.Item.new(5512, "Minor Healthstone")
ham.minor1 = ham.Item.new(19004, "Minor Healthstone")
ham.minor2 = ham.Item.new(19005, "Minor Healthstone")
ham.lesser0 = ham.Item.new(5511, "Lesser Healthstone")
ham.lesser1 = ham.Item.new(19006, "Lesser Healthstone")
ham.lesser2 = ham.Item.new(19007, "Lesser Healthstone")
ham.healtsthone0 = ham.Item.new(5509, "Healthstone")
ham.healtsthone1 = ham.Item.new(19008, "Healthstone")
ham.healtsthone2 = ham.Item.new(19009, "Healthstone")
ham.greater0 = ham.Item.new(5510, "Greater Healthstone")
ham.greater1 = ham.Item.new(19010, "Greater Healthstone")
ham.greater2 = ham.Item.new(19011, "Greater Healthstone")
ham.major0 = ham.Item.new(9421, "Major Healthstone")
ham.major1 = ham.Item.new(19012, "Major Healthstone")
ham.major2 = ham.Item.new(19013, "Major Healthstone")

function ham.getPots()
  if isClassic == false then
    return {
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
  else
    return {
      ham.major,
      ham.superior,
      ham.greater,
      ham.healingPotion,
      ham.lesser,
      ham.minor
    }
  end
end

function ham.getHealthstonesClassic()
  return {
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
