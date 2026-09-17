---@diagnostic disable: undefined-global
local addonName, ham = ...
local isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
if not isRetail then return end

-- Retail-only spells go here, e.g.:
-- ham.someRetailOnlySpell = ham.Spell.new(123456)
-- table.insert(ham.supportedSpells, ham.someRetailOnlySpell)
