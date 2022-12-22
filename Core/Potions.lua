local addonName, addon = ...

--leywine = addon.Item.new(194684,"Azure Leywine")
healthstone = addon.Item.new(5512,"Healthstone")
refreshingR3 = addon.Item.new(191380,"Refreshing Healing Potion")
refreshingR2 = addon.Item.new(191379,"Refreshing Healing Potion")
refreshingR1 = addon.Item.new(191378,"Refreshing Healing Potion")
cosmic = addon.Item.new(187802,"Cosmic Healing Potion")
spiritual = addon.Item.new(171267,"Spiritual Healing Potion")
soulful = addon.Item.new(180317,"Soulful Healing Potion")
ashran = addon.Item.new(115498,"Ashran Healing Tonic")
abyssal = addon.Item.new(169451,"Abyssal Healing Potion")
astral = addon.Item.new(152615,"Astral Healing Potion")
coastal = addon.Item.new(152494,"Coastal Healing Potion")
ancient = addon.Item.new(127834,"Ancient Healing Potion")
aged = addon.Item.new(136569,"Aged Health Potion")
tonic = addon.Item.new(109223,"Healing Tonic")
master = addon.Item.new(76097,"Master Healing Potion")
mythical = addon.Item.new(57191,"Mythical Healing Potion")
runic = addon.Item.new(33447,"Runic Healing Potion")
resurgent = addon.Item.new(39671,"Resurgent Healing Potion")
super = addon.Item.new(22829,"Super Healing Potion")
major = addon.Item.new(13446,"Major Healing Potion")
lesser = addon.Item.new(858,"Lesser Healing Potion")
--superior has probably wrong scaling
superior = addon.Item.new(3928,"Superior Healing Potion")
minor = addon.Item.new(118,"Minor Healing Potion")
greater = addon.Item.new(1710,"Greater Healing Potion")
healingPotion = addon.Item.new(929,"Healing Potion")

function getPots()
  return {
    refreshingR3,
    refreshingR2,
    refreshingR1,
    cosmic,
    spiritual,
    soulful,
    ashran,
    abyssal,
    astral,
    coastal,
    ancient,
    aged,
    tonic,
    master,
    mythical,
    runic,
    resurgent,
    super,
    major,
    lesser,
    superior,
    minor,
    greater,
    healingPotion
  }
end