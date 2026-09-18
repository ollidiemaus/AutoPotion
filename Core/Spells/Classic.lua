local addonName, ham = ...
if not ham.isClassic then return end

-- Classic Era-only spells go here. Either add a spell already created in Core/Spells.lua
-- to the settings list for this flavor:
-- table.insert(ham.supportedSpells, ham.someSpellFromTheBaseFile)
-- ...or create and add one that's exclusive to this flavor:
-- ham.someClassicOnlySpell = ham.Spell.new(123456, "WARRIOR") -- class token, or omit for non-class spells
-- table.insert(ham.supportedSpells, ham.someClassicOnlySpell)
