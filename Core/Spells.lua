local addonName, ham = ...

ham.crimsonVialSpell = ham.Spell.new(185311, "ROGUE")
ham.renewal = ham.Spell.new(108238, "DRUID")
ham.exhilaration = ham.Spell.new(109304, "HUNTER")
---Fortitude of the Bear became a passive in 12.0 (Hunter exotic-pet ability, not Druid)
ham.fortitudeOfTheBear = ham.Spell.new(388035, "HUNTER")
ham.lastStand = ham.Spell.new(12975, "WARRIOR")
ham.bitterImmunity = ham.Spell.new(383762, "WARRIOR")
ham.desperatePrayer = ham.Spell.new(19236, "PRIEST")
ham.expelHarm = ham.Spell.new(322101, "MONK")
ham.healingElixir = ham.Spell.new(122281, "MONK")
ham.darkPact = ham.Spell.new(108416, "WARLOCK")
ham.vampiricBlood = ham.Spell.new(55233, "DEATHKNIGHT")
ham.deathPact = ham.Spell.new(48743, "DEATHKNIGHT")

-- Recuperate is only usable out of combat; not tied to a class (Undermine'd consumable/environment effect)
ham.recuperate = ham.Spell.new(1231411)

-- Racials WTF These are all seperate Spells. Each keeps its real class tag (needed so
-- ham.SpellGroup can pick the variant matching the player's own class for its tooltip/
-- name) but none of them are inserted into ham.supportedSpells individually - per-flavor
-- files bundle the ones valid for that flavor into a single ham.SpellGroup instead, so
-- the settings UI shows one "Gift of the Naaru" row in Other/Racial rather than one per
-- class variant.
ham.giftOfTheNaaruDK = ham.Spell.new(59545, "DEATHKNIGHT")
ham.giftOfTheNaaruHunter = ham.Spell.new(59543, "HUNTER")
ham.giftOfTheNaaruMage = ham.Spell.new(59548, "MAGE")
-- Shared Mage/Warlock id: no single class fits, left classless.
ham.giftOfTheNaaruMageWarlock = ham.Spell.new(416250)
ham.giftOfTheNaaruMonk = ham.Spell.new(121093, "MONK")
ham.giftOfTheNaaruPaladin = ham.Spell.new(59542, "PALADIN")
ham.giftOfTheNaaruPriest = ham.Spell.new(59544, "PRIEST")
ham.giftOfTheNaaruRogue = ham.Spell.new(370626, "ROGUE")
ham.giftOfTheNaaruShaman = ham.Spell.new(59547, "SHAMAN")
ham.giftOfTheNaaruWarrior = ham.Spell.new(28880, "WARRIOR")

-- Vulpera racial, not tied to a class
ham.bagOfTricks = ham.Spell.new(312411)

-- NOTE: every ham.xxx spell object above is always created, regardless of flavor -
-- Core/DB.lua and code.lua reference some of these globals unconditionally (e.g.
-- ham.recuperate.getId()), so removing the object itself on non-retail flavors would
-- crash the addon there. What varies per flavor is only which spells are *offered* in
-- the settings UI, via membership in ham.supportedSpells below.
--
-- Only spells confirmed available since Classic Era go in the shared list here; every
-- other spell here today (Legion/Cata/MoP/Dragonflight+ abilities, classes that don't
-- exist pre-Wrath/pre-Mists, retail-only racials) is added to ham.supportedSpells from
-- Core/Spells/Retail.lua instead, so Classic/TBC/Wrath/Cata/Mists don't list spells
-- their client can't actually cast. Add spells to the matching Core/Spells/<Flavor>.lua
-- file as their real per-flavor availability gets verified.
ham.supportedSpells = {}
table.insert(ham.supportedSpells, ham.lastStand)
table.insert(ham.supportedSpells, ham.desperatePrayer)
