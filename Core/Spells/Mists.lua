local addonName, ham = ...
if not ham.isMop then return end

-- Mists-only spells go here (this is also where Monk abilities would first become
-- available, e.g. ham.expelHarm / ham.healingElixir / ham.giftOfTheNaaruMonk, once
-- their availability on Mists Classic specifically is confirmed - note Wowhead showed
-- giftOfTheNaaruMonk's id shared with Priest on the MoP Classic build, worth double
-- checking in-game before enabling it there). Either add a spell already created in
-- Core/Spells.lua to the settings list for this flavor:
-- table.insert(ham.supportedSpells, ham.someSpellFromTheBaseFile)
-- ...or create and add one that's exclusive to this flavor:
-- ham.someMistsOnlySpell = ham.Spell.new(123456, "WARRIOR") -- class token, or omit for non-class spells
-- table.insert(ham.supportedSpells, ham.someMistsOnlySpell)
