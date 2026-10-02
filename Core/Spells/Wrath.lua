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

-- Desperate Prayer (Holy talent) has one spell id per rank, while ham.desperatePrayer uses
-- rank 2's id. Register every rank so a priest at any rank is detected.
ham.spellRanks[ham.desperatePrayer.getId()] = {
	13908, -- Rank 1
	19236, -- Rank 2
	19238, -- Rank 3
	19240, -- Rank 4
	19241, -- Rank 5
	19242, -- Rank 6
	19243, -- Rank 7
	25437, -- Rank 8
	48172, -- Rank 9
	48173, -- Rank 10
}
