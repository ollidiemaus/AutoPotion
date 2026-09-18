local addonName, ham = ...
if not ham.isTBC then return end

-- TBC-only spells go here, e.g.:
-- ham.someTBCOnlySpell = ham.Spell.new(123456, "WARRIOR") -- class token, or omit for non-class spells
-- table.insert(ham.supportedSpells, ham.someTBCOnlySpell)
