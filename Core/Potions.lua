--leywine = Item.new(194684,"Azure Leywine")
healthstone = Item.new(5512,"Healthstone")
refreshingR3 = Item.new(191380,"Refreshing Healing Potion")
refreshingR2 = Item.new(191379,"Refreshing Healing Potion")
refreshingR1 = Item.new(191378,"Refreshing Healing Potion")
cosmic = Item.new(187802,"Cosmic Healing Potion")
spiritual = Item.new(171267,"Spiritual Healing Potion")
soulful = Item.new(180317,"Soulful Healing Potion")
ashran = Item.new(115498,"Ashran Healing Tonic")
abyssal = Item.new(169451,"Abyssal Healing Potion")
astral = Item.new(152615,"Astral Healing Potion")
coastal = Item.new(152494,"Coastal Healing Potion")
ancient = Item.new(127834,"Ancient Healing Potion")
aged = Item.new(136569,"Aged Health Potion")
tonic = Item.new(109223,"Healing Tonic")
master = Item.new(76097,"Master Healing Potion")
mythical = Item.new(57191,"Mythical Healing Potion")
runic = Item.new(33447,"Runic Healing Potion")
resurgent = Item.new(39671,"Resurgent Healing Potion")
super = Item.new(22829,"Super Healing Potion")
major = Item.new(13446,"Major Healing Potion")
lesser = Item.new(858,"Lesser Healing Potion")
--superior has probably wrong scaling
superior = Item.new(3928,"Superior Healing Potion")
minor = Item.new(118,"Minor Healing Potion")
greater = Item.new(1710,"Greater Healing Potion")
healingPotion = Item.new(929,"Healing Potion")

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