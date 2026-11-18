local addonName, ham = ...
if not ham.isCata then return end

-- Directly confirmed against Cataclysm Classic on Wowhead: these ids still resolve to
-- the class ham.<name> already implies.
table.insert(ham.supportedSpells, ham.vampiricBlood)
table.insert(ham.supportedSpells, ham.deathPact)

-- One row for "Gift of the Naaru" instead of one per class - Monk/Rogue aren't
-- playable yet on this flavor, so they're left out of the group here.
table.insert(ham.supportedSpells, ham.SpellGroup.new({
	ham.giftOfTheNaaruDK, ham.giftOfTheNaaruHunter, ham.giftOfTheNaaruMage,
	ham.giftOfTheNaaruPaladin, ham.giftOfTheNaaruPriest, ham.giftOfTheNaaruShaman,
	ham.giftOfTheNaaruWarrior,
}))

-- Mana spells, best restore first within each class (what the caster gets back): Dispersion
-- 36%, Shadowfiend 3% per hit (about 30%), Hymn of Hope 8%. Mana Tide Totem restores none of
-- the shaman's own mana from here on, so it isn't one.
table.insert(ham.supportedManaSpells, ham.evocation)
table.insert(ham.supportedManaSpells, ham.innervate)
table.insert(ham.supportedManaSpells, ham.divinePlea)
table.insert(ham.supportedManaSpells, ham.dispersion)
table.insert(ham.supportedManaSpells, ham.shadowfiend)
table.insert(ham.supportedManaSpells, ham.hymnOfHope)
table.insert(ham.supportedManaSpells, ham.thunderstorm)
table.insert(ham.supportedManaSpells, ham.SpellGroup.new({
	ham.arcaneTorrentMana, ham.arcaneTorrentRogue, ham.arcaneTorrentDK, ham.arcaneTorrentWarrior,
	ham.arcaneTorrentHunter,
}))

-- Cooldown talents, one entry per rank: `rankOf` names the talent's first rank, so only the
-- highest rank the player knows counts
ham.cooldownTalents[44378] = { spell = ham.evocation, seconds = 60, rankOf = 44378 }    -- Arcane Flows 1
ham.cooldownTalents[44379] = { spell = ham.evocation, seconds = 120, rankOf = 44378 }   -- Arcane Flows 2
ham.cooldownTalents[15274] = { spell = ham.shadowfiend, seconds = 30, rankOf = 15274 }  -- Veiled Shadows 1
ham.cooldownTalents[15311] = { spell = ham.shadowfiend, seconds = 60, rankOf = 15274 }  -- Veiled Shadows 2

-- More Cata-only spells go here. Either add a spell already created in
-- Core/Spells.lua to the settings list for this flavor:
-- table.insert(ham.supportedSpells, ham.someSpellFromTheBaseFile)
-- ...or create and add one that's exclusive to this flavor:
-- ham.someCataOnlySpell = ham.Spell.new(123456, "WARRIOR") -- class token, or omit for non-class spells
-- table.insert(ham.supportedSpells, ham.someCataOnlySpell)
