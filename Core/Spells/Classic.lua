---@diagnostic disable: undefined-global
local addonName, ham = ...
local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
if not isClassic then return end

-- Classic Era-only spells go here, e.g.:
-- ham.someClassicOnlySpell = ham.Spell.new(123456)
-- table.insert(ham.supportedSpells, ham.someClassicOnlySpell)
