local addonName, ham = ...
if not ham.isMop then return end

-- Directly confirmed against Mists of Pandaria Classic on Wowhead: these ids still
-- resolve to the class ham.<name> already implies (the earlier "shared with Priest"
-- reading on giftOfTheNaaruMonk turned out to be a search-result artifact - checked
-- again directly and it cleanly requires Monk on MoP Classic).
table.insert(ham.supportedSpells, ham.renewal)
table.insert(ham.supportedSpells, ham.exhilaration)
table.insert(ham.supportedSpells, ham.vampiricBlood)
table.insert(ham.supportedSpells, ham.deathPact)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruDK)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruHunter)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruMage)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruMonk)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruPaladin)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruPriest)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruShaman)
table.insert(ham.supportedSpells, ham.giftOfTheNaaruWarrior)

-- NOT added here even though Monk/Warlock exist by MoP - confirmed these specific ids
-- do NOT carry over to MoP Classic, so adding them would show the wrong spell:
-- ham.expelHarm (322101) - MoP Classic's Expel Harm is a different id (115072)
-- ham.healingElixir (122281) - MoP Classic's version is a different id (122280) with a
--   different effect (proc-based "Healing Elixirs", not a drink-a-flask activated spell)
-- ham.darkPact (108416) - this id is "Sacrificial Pact" on MoP Classic, an unrelated
--   spell entirely; Dark Pact's own MoP-era id hasn't been found/added yet

-- More Mists-only spells go here. Either add a spell already created in
-- Core/Spells.lua to the settings list for this flavor:
-- table.insert(ham.supportedSpells, ham.someSpellFromTheBaseFile)
-- ...or create and add one that's exclusive to this flavor:
-- ham.someMistsOnlySpell = ham.Spell.new(123456, "WARRIOR") -- class token, or omit for non-class spells
-- table.insert(ham.supportedSpells, ham.someMistsOnlySpell)
