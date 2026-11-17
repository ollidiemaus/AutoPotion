local addonName, ham = ...
if not ham.isForever then return end

-- Troll racial (new in Forever): channeled self-heal restoring ~50% of max health over ~6s,
-- canceled by taking damage, moving or acting. 3 minute cooldown. Only the AutoBandage macro
-- casts it (ham.getBandageSpell), so it's not one of the healing spells.
ham.rapidRegeneration = ham.Spell.new(1260270)

-- Mana spells, best restore first. The Season of Discovery rune spells in Forever's client data
-- (Shadowfiend, Dispersion) stay out until someone confirms in-game that they can be learned.
table.insert(ham.supportedManaSpells, ham.evocation)
table.insert(ham.supportedManaSpells, ham.innervate)
table.insert(ham.supportedManaSpells, ham.manaTideTotem)
table.insert(ham.supportedManaSpells, ham.darkSacrifice)
table.insert(ham.supportedManaSpells, ham.readLeyline)

ham.spellRanks[ham.manaTideTotem.getId()] = {
    16190,   -- Rank 1
    17354,   -- Rank 2
    17359,   -- Rank 3
    1325256, -- Rank 4, new in Forever
}
ham.spellRanks[ham.darkSacrifice.getId()] = {
    1277324, -- Rank 1
    1277325, -- Rank 2
    1277326, -- Rank 3
    1277327, -- Rank 4
    1277328, -- Rank 5
}

-- Desperate Prayer (Dwarf/Human priest racial in Vanilla) has one spell id per rank, while
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
