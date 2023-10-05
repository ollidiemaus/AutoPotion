local addonName, ham = ...
local isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
local isWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)

--ham.leywine = ham.Item.new(194684,"Azure Leywine")
--ham.healthstone = ham.Item.new(117, "Healthstone")
ham.healthstone = ham.Item.new(5512, "Healthstone")
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
ham.master = ham.Item.new(76097, "Master Healing Potion")
ham.mythical = ham.Item.new(57191, "Mythical Healing Potion")
ham.runic = ham.Item.new(33447, "Runic Healing Potion")
ham.superreju = ham.Item.new(22850, "Super Rejuvenation Potion")
ham.endless = ham.Item.new(43569, "Endless Healing Potion")
ham.injector = ham.Item.new(33092, "Healing Potion Injector")
ham.resurgent = ham.Item.new(39671, "Resurgent Healing Potion")
ham.argent = ham.Item.new(43531, "Argent Healing Potion")
ham.auchenai = ham.Item.new(32947, "Auchenai Healing Potion")
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
------Healthstones for WotLK------
ham.master0 = ham.Item.new(22103, "Master Healthstone")
ham.master1 = ham.Item.new(22104, "Master Healthstone")
ham.master2 = ham.Item.new(22105, "Master Healthstone")
ham.demonic0 = ham.Item.new(36889, "Demonic Healthstone")
ham.demonic1 = ham.Item.new(36890, "Demonic Healthstone")
ham.demonic2 = ham.Item.new(36891, "Demonic Healthstone")
ham.fel0 = ham.Item.new(36892, "Fel Healthstone")
ham.fel1 = ham.Item.new(36893, "Fel Healthstone")
ham.fel2 = ham.Item.new(36894, "Fel Healthstone")

function ham.getPots()
  if isRetail then
    local pots = {
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

    if HAMDB.witheringPotion then
      table.insert(pots, 1, ham.witheringR1)
      table.insert(pots, 1, ham.witheringR2)
      table.insert(pots, 1, ham.witheringR3)
    end

    return pots
  end
  if isClassic then
    return {
      ham.major,
      ham.superior,
      ham.greater,
      ham.healingPotion,
      ham.lesser,
      ham.minor
    }
  end

  if isWrath then
    return {
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
end

function ham.getHealthstonesClassic()
  if isClassic then
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

  if isWrath then
    return {
      ham.fel2,
      ham.fel1,
      ham.fel0,
      ham.demonic2,
      ham.demonic1,
      ham.demonic0,
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
end
