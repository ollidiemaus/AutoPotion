local addonName, ham = ...
if not ham.isRetail then return end

-- The objects themselves are always created in Core/Spells.lua (see the note there);
-- this just adds the ones that are only actually available on retail to the list the
-- settings UI offers, so Classic/TBC/Wrath/Cata/Mists don't show spells they can't cast.
table.insert(ham.supportedSpells, ham.crimsonVialSpell)
table.insert(ham.supportedSpells, ham.renewal)
table.insert(ham.supportedSpells, ham.exhilaration)
table.insert(ham.supportedSpells, ham.fortitudeOfTheBear)
table.insert(ham.supportedSpells, ham.bitterImmunity)
table.insert(ham.supportedSpells, ham.expelHarm)
table.insert(ham.supportedSpells, ham.healingElixir)
table.insert(ham.supportedSpells, ham.darkPact)
table.insert(ham.supportedSpells, ham.vampiricBlood)
table.insert(ham.supportedSpells, ham.deathPact)
table.insert(ham.supportedSpells, ham.recuperate)
table.insert(ham.supportedSpells, ham.bagOfTricks)

-- One row for every class's "Gift of the Naaru" id, instead of listing the same racial
-- ten times over - all confirmed valid on retail.
table.insert(ham.supportedSpells, ham.SpellGroup.new({
	ham.giftOfTheNaaruDK, ham.giftOfTheNaaruHunter, ham.giftOfTheNaaruMage,
	ham.giftOfTheNaaruMageWarlock, ham.giftOfTheNaaruMonk, ham.giftOfTheNaaruPaladin,
	ham.giftOfTheNaaruPriest, ham.giftOfTheNaaruRogue, ham.giftOfTheNaaruShaman,
	ham.giftOfTheNaaruWarrior,
}))

-- More retail-only spells go here, e.g.:
-- ham.someRetailOnlySpell = ham.Spell.new(123456, "WARRIOR") -- class token, or omit for non-class spells
-- table.insert(ham.supportedSpells, ham.someRetailOnlySpell)
