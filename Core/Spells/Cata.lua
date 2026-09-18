local addonName, ham = ...
if not ham.isCata then return end

-- Directly confirmed against Cataclysm Classic on Wowhead: these ids still resolve to
-- the class ham.<name> already implies.
table.insert(ham.supportedSpells, ham.vampiricBlood)
table.insert(ham.supportedSpells, ham.deathPact)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruDK)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruShaman)

-- NOT added here (unconfirmed on Cata Classic specifically, don't assume - the Gift of
-- the Naaru ids have already been seen to shift class/existence between flavors, e.g.
-- ham.giftOfTheNaaruWarrior's id means Priest on TBC Classic and Warrior on Wrath+):
-- ham.giftOfTheNaaruHunter, ham.giftOfTheNaaruMage, ham.giftOfTheNaaruPaladin,
-- ham.giftOfTheNaaruPriest, ham.giftOfTheNaaruWarrior

-- More Cata-only spells go here. Either add a spell already created in
-- Core/Spells.lua to the settings list for this flavor:
-- table.insert(ham.supportedSpells, ham.someSpellFromTheBaseFile)
-- ...or create and add one that's exclusive to this flavor:
-- ham.someCataOnlySpell = ham.Spell.new(123456, "WARRIOR") -- class token, or omit for non-class spells
-- table.insert(ham.supportedSpells, ham.someCataOnlySpell)
