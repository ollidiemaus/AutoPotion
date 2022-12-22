--leywine = ItemClass.new(194684,"Azure Leywine")
healthstone = ItemClass.new(5512,"Healthstone")
refreshingR3 = ItemClass.new(191380,"Refreshing Healing Potion")
refreshingR2 = ItemClass.new(191379,"Refreshing Healing Potion")
refreshingR1 = ItemClass.new(191378,"Refreshing Healing Potion")
cosmic = ItemClass.new(187802,"Cosmic Healing Potion")
spiritual = ItemClass.new(171267,"Spiritual Healing Potion")
soulful = ItemClass.new(180317,"Soulful Healing Potion")
ashran = ItemClass.new(115498,"Ashran Healing Tonic")
abyssal = ItemClass.new(169451,"Abyssal Healing Potion")
astral = ItemClass.new(152615,"Astral Healing Potion")
coastal = ItemClass.new(152494,"Coastal Healing Potion")
ancient = ItemClass.new(127834,"Ancient Healing Potion")
aged = ItemClass.new(136569,"Aged Health Potion")
tonic = ItemClass.new(109223,"Healing Tonic")
master = ItemClass.new(76097,"Master Healing Potion")
mythical = ItemClass.new(57191,"Mythical Healing Potion")
runic = ItemClass.new(33447,"Runic Healing Potion")
resurgent = ItemClass.new(39671,"Resurgent Healing Potion")
super = ItemClass.new(22829,"Super Healing Potion")
major = ItemClass.new(13446,"Major Healing Potion")
lesser = ItemClass.new(858,"Lesser Healing Potion")
--superior has probably wrong scaling
superior = ItemClass.new(3928,"Superior Healing Potion")
minor = ItemClass.new(118,"Minor Healing Potion")
greater = ItemClass.new(1710,"Greater Healing Potion")
healingPotion = ItemClass.new(929,"Healing Potion")

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