local addonName, ham = ...
if not ham.isCata then return end

-- Directly confirmed against Cataclysm Classic on Wowhead: these ids still resolve to
-- the class ham.<name> already implies.
table.insert(ham.supportedSpells, ham.vampiricBlood)
table.insert(ham.supportedSpells, ham.deathPact)

-- One row for "Gift of the Naaru" instead of one per class - Monk/Rogue aren't
-- playable yet on this flavor, so they're left out of the group here.
table.insert(ham.supportedSpells, ham.SpellGroup.new({
	ham.giftOfTheNaaruDK, ham.giftOfTheNaaruHunter, ham.giftOfTheNaaruMage,
	ham.giftOfTheNaaruPaladin, ham.giftOfTheNaaruPriest, ham.giftOfTheNaaruShaman,
	ham.giftOfTheNaaruWarrior,
}))

-- More Cata-only spells go here. Either add a spell already created in
-- Core/Spells.lua to the settings list for this flavor:
-- table.insert(ham.supportedSpells, ham.someSpellFromTheBaseFile)
-- ...or create and add one that's exclusive to this flavor:
-- ham.someCataOnlySpell = ham.Spell.new(123456, "WARRIOR") -- class token, or omit for non-class spells
-- table.insert(ham.supportedSpells, ham.someCataOnlySpell)
