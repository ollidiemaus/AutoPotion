---@diagnostic disable: undefined-global
local addonName, ham = ...
local isTBC = (WOW_PROJECT_ID == 5) -- TBC Anniversary / BCC
if not isTBC then return end

-- TBC-only spells go here, e.g.:
-- ham.someTBCOnlySpell = ham.Spell.new(123456)
-- table.insert(ham.supportedSpells, ham.someTBCOnlySpell)
