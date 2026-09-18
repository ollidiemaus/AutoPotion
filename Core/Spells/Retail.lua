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
table.insert(ham.supportedSpells, ham.giftOfTheNaaruDK)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruHunter)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruMage)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruMageWarlock)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruMonk)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruPaladin)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruPriest)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruRogue)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruShaman)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruWarrior)
table.insert(ham.supportedSpells, ham.bagOfTricks)

-- More retail-only spells go here, e.g.:
-- ham.someRetailOnlySpell = ham.Spell.new(123456, "WARRIOR") -- class token, or omit for non-class spells
-- table.insert(ham.supportedSpells, ham.someRetailOnlySpell)
