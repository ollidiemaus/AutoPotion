---@diagnostic disable: undefined-global
local addonName, ham = ...
local isCata = (WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC)
if not isCata then return end

-- Cata-only spells go here, e.g.:
-- ham.someCataOnlySpell = ham.Spell.new(123456)
-- table.insert(ham.supportedSpells, ham.someCataOnlySpell)
