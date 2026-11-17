local addonName, ham = ...

ham.crimsonVialSpell = ham.Spell.new(185311, "ROGUE")
-- Removed on retail in patch 12.0.0, replaced by the passive "Aessina's Renewal" - kept
-- here (object always created, see note below) since it's still a real, active spell on
-- Mists Classic and is listed there.
ham.renewal = ham.Spell.new(108238, "DRUID")
ham.exhilaration = ham.Spell.new(109304, "HUNTER")
---Fortitude of the Bear became a passive in 12.0 (Hunter exotic-pet ability, not Druid) - not offered anywhere any more
ham.fortitudeOfTheBear = ham.Spell.new(388035, "HUNTER")
ham.lastStand = ham.Spell.new(12975, "WARRIOR")
-- Removed outright in patch 12.0.0, no replacement - not offered anywhere any more
ham.bitterImmunity = ham.Spell.new(383762, "WARRIOR")
ham.desperatePrayer = ham.Spell.new(19236, "PRIEST")
ham.expelHarm = ham.Spell.new(322101, "MONK")
ham.healingElixir = ham.Spell.new(122281, "MONK")
ham.darkPact = ham.Spell.new(108416, "WARLOCK")
-- Not a heal itself: empowers the next Healthstone. Never part of ham.supportedSpells or the
-- castsequence - code.lua adds it as a separate leading /cast line when the option is enabled.
ham.soulburn = ham.Spell.new(385899, "WARLOCK")
ham.vampiricBlood = ham.Spell.new(55233, "DEATHKNIGHT")
ham.deathPact = ham.Spell.new(48743, "DEATHKNIGHT")

-- Recuperate is only usable out of combat; not tied to a class (Undermine'd consumable/environment effect)
ham.recuperate = ham.Spell.new(1231411)
-- Earthen racial: their out-of-combat food/drink replacement (they can't eat), also only
-- usable out of combat, so the macro treats it just like Recuperate
ham.quietContemplation = ham.Spell.new(461063)

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

-- Mana spells: spells that bring the caster's own mana back, which AutoManaPotion casts on the
-- player before the mana gem (see GLOSSARY.md). Like the heal spells, every object is always
-- created; the per-flavor files add the ones that flavor offers to ham.supportedManaSpells, in
-- the order the macro casts them: best restore first. Ranked spells register their ranks in
-- ham.spellRanks there.
ham.evocation = ham.Spell.new(12051, "MAGE")
ham.innervate = ham.Spell.new(29166, "DRUID")
ham.manaTideTotem = ham.Spell.new(16190, "SHAMAN")
ham.shadowfiend = ham.Spell.new(34433, "PRIEST")
ham.mindbender = ham.Spell.new(123040, "PRIEST")
-- Hymn of Hope from Wrath to Mists; Retail kept the id for Symbol of Hope
ham.hymnOfHope = ham.Spell.new(64901, "PRIEST")
-- TBC's Draenei priest racial, a different spell from Retail's Symbol of Hope
ham.symbolOfHopeDraenei = ham.Spell.new(32548, "PRIEST")
ham.dispersion = ham.Spell.new(47585, "PRIEST")
ham.divinePlea = ham.Spell.new(54428, "PALADIN")
ham.thunderstorm = ham.Spell.new(51490, "SHAMAN")
ham.shamanisticRage = ham.Spell.new(30823, "SHAMAN")
-- Season of Discovery rune spells (Classic Era)
ham.shadowfiendRune = ham.Spell.new(401977, "PRIEST")
ham.dispersionRune = ham.Spell.new(425294, "PRIEST")
ham.shamanisticRageRune = ham.Spell.new(425336, "SHAMAN")
-- Blood Elf racial, one id per power type; the mana one is shared by every mana class, so it has
-- no class and comes first in its ham.SpellGroup (the row's name and tooltip for those classes)
ham.arcaneTorrentMana = ham.Spell.new(28730)
ham.arcaneTorrentRogue = ham.Spell.new(25046, "ROGUE")
ham.arcaneTorrentDK = ham.Spell.new(50613, "DEATHKNIGHT")
ham.arcaneTorrentWarrior = ham.Spell.new(69179, "WARRIOR")
ham.arcaneTorrentHunter = ham.Spell.new(80483, "HUNTER")
-- Forever: Undead priest racial (health into mana) and Skyborne racial (a regen buff)
ham.darkSacrifice = ham.Spell.new(1277324, "PRIEST")
ham.readLeyline = ham.Spell.new(1259705)

ham.supportedManaSpells = {}
