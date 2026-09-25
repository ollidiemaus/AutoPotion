local addonName, ham = ...
if not ham.isTBC then return end

-- Checked every spell currently in Core/Spells/Retail.lua against TBC Classic on
-- Wowhead: none of them apply here as-is. Notably, ham.giftOfTheNaaruWarrior's id
-- (28880) resolves on TBC Classic's own page to the *Priest* variant of Gift of the
-- Naaru, not Warrior - Blizzard reused that id for a different class's version of the
-- racial later on (it's the Warrior variant from Wrath Classic onward). The ids for
-- Hunter/Shaman's TBC-era Gift of the Naaru don't exist at all under the ids this addon
-- uses (those only start at Wrath). TBC's own Gift of the Naaru ids aren't in this addon
-- yet - add them here once found, using the pattern below.
--
-- TBC-only spells go here. Either add a spell already created in Core/Spells.lua
-- to the settings list for this flavor:
-- table.insert(ham.supportedSpells, ham.someSpellFromTheBaseFile)
-- ...or create and add one that's exclusive to this flavor:
-- ham.someTBCOnlySpell = ham.Spell.new(123456, "WARRIOR") -- class token, or omit for non-class spells
-- table.insert(ham.supportedSpells, ham.someTBCOnlySpell)

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
}
