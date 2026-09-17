---@diagnostic disable: undefined-global
local addonName, ham = ...
local isMop = (WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC)
if not isMop then return end

-- Mists-only spells go here, e.g.:
-- ham.someMistsOnlySpell = ham.Spell.new(123456)
-- table.insert(ham.supportedSpells, ham.someMistsOnlySpell)
