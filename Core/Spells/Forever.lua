local addonName, ham = ...
if not ham.isForever then return end

-- Troll racial (new in Forever): channeled self-heal restoring ~50% of max health over ~6s,
-- canceled by taking damage, moving or acting. 3 minute cooldown.
ham.rapidRegeneration = ham.Spell.new(1260270)
table.insert(ham.supportedSpells, ham.rapidRegeneration)

-- Desperate Prayer (Dwarf/Human priest racial in Vanilla) has one spell id per rank, while
-- ham.desperatePrayer uses rank 2's id. Register every rank so a priest at any rank is detected.
ham.spellRanks[ham.desperatePrayer.getId()] = {
    13908, -- Rank 1
    19236, -- Rank 2
    19238, -- Rank 3
    19240, -- Rank 4
    19241, -- Rank 5
    19242, -- Rank 6
}
