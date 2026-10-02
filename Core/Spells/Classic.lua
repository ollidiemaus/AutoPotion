local addonName, ham = ...
if not ham.isClassic then return end

-- Classic Era-only spells go here. Either add a spell already created in Core/Spells.lua
-- to the settings list for this flavor:
-- table.insert(ham.supportedSpells, ham.someSpellFromTheBaseFile)
-- ...or create and add one that's exclusive to this flavor:
-- ham.someClassicOnlySpell = ham.Spell.new(123456, "WARRIOR") -- class token, or omit for non-class spells
-- table.insert(ham.supportedSpells, ham.someClassicOnlySpell)

-- Desperate Prayer (Dwarf/Human priest racial) has one spell id per rank, while
-- ham.desperatePrayer uses rank 2's id. Register every rank so a priest at any rank is detected.
ham.spellRanks[ham.desperatePrayer.getId()] = {
    13908, -- Rank 1
    19236, -- Rank 2
    19238, -- Rank 3
    19240, -- Rank 4
    19241, -- Rank 5
    19242, -- Rank 6
    19243, -- Rank 7
}
