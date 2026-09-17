---@diagnostic disable: undefined-global
local addonName, ham = ...
local isWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
if not isWrath then return end

-- Wrath-only spells go here, e.g.:
-- ham.someWrathOnlySpell = ham.Spell.new(123456)
-- table.insert(ham.supportedSpells, ham.someWrathOnlySpell)
