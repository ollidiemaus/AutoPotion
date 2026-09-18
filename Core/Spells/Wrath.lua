local addonName, ham = ...
if not ham.isWrath then return end

-- Wrath-only spells go here (this is also where Death Knight abilities would first
-- become available, e.g. ham.vampiricBlood / ham.deathPact / ham.giftOfTheNaaruDK,
-- once their availability on Wrath Classic specifically is confirmed). Either add a
-- spell already created in Core/Spells.lua to the settings list for this flavor:
-- table.insert(ham.supportedSpells, ham.someSpellFromTheBaseFile)
-- ...or create and add one that's exclusive to this flavor:
-- ham.someWrathOnlySpell = ham.Spell.new(123456, "WARRIOR") -- class token, or omit for non-class spells
-- table.insert(ham.supportedSpells, ham.someWrathOnlySpell)
