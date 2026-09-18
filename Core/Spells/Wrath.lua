local addonName, ham = ...
if not ham.isWrath then return end

-- Death Knight exists from Wrath onward, and Draenei could be every one of these
-- classes by Wrath. Each id below was checked directly against Wrath Classic on
-- Wowhead and confirmed to resolve to the class ham.<name> already implies.
table.insert(ham.supportedSpells, ham.vampiricBlood)
table.insert(ham.supportedSpells, ham.deathPact)

-- One row for "Gift of the Naaru" instead of one per class - Monk/Rogue aren't
-- playable yet on this flavor, so they're left out of the group here.
table.insert(ham.supportedSpells, ham.SpellGroup.new({
	ham.giftOfTheNaaruDK, ham.giftOfTheNaaruHunter, ham.giftOfTheNaaruMage,
	ham.giftOfTheNaaruPaladin, ham.giftOfTheNaaruPriest, ham.giftOfTheNaaruShaman,
	ham.giftOfTheNaaruWarrior,
}))

-- More Wrath-only spells go here. Either add a spell already created in
-- Core/Spells.lua to the settings list for this flavor:
-- table.insert(ham.supportedSpells, ham.someSpellFromTheBaseFile)
-- ...or create and add one that's exclusive to this flavor:
-- ham.someWrathOnlySpell = ham.Spell.new(123456, "WARRIOR") -- class token, or omit for non-class spells
-- table.insert(ham.supportedSpells, ham.someWrathOnlySpell)
