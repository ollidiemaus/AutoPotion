local addonName, ham = ...

-- A SpellGroup bundles several ham.Spell objects that represent the *same* ability
-- (e.g. each class's own spell id for the "Gift of the Naaru" racial) behind a single
-- settings-UI row: one checkbox that activates/deactivates every member together,
-- instead of listing near-identical rows once per class. It duck-types enough of
-- ham.Spell's interface (getId/getName/getClass) to drop into the same
-- ham.supportedSpells list and settings UI code as a plain spell, tagged via
-- self.isGroup so the UI knows to toggle all members instead of a single db entry.
ham.SpellGroup = {}

ham.SpellGroup.new = function(members)
    local self = {}

    self.members = members
    self.isGroup = true

    -- The member matching the player's own class, so the row's name/tooltip show the
    -- spell that's actually relevant to them; falls back to the first member (e.g. for
    -- a class/race combo where nothing in the group applies, like the shared
    -- Mage/Warlock racial with no single class of its own).
    local function representative()
        local _, englishClass = UnitClass("player")
        for _, member in ipairs(members) do
            if member.getClass() == englishClass then
                return member
            end
        end
        return members[1]
    end

    function self.getId()
        return representative().getId()
    end

    function self.getName()
        return representative().getName()
    end

    function self.getClass()
        return nil -- always goes in the Other/Racial group, never a class header
    end

    -- `list` is the saved list of ticked spells, heal spells by default (see Core/DB.lua)
    function self.isActive(list)
        for _, member in ipairs(members) do
            if ham.dbContains(member.getId(), list) then
                return true
            end
        end
        return false
    end

    function self.activate(list)
        for _, member in ipairs(members) do
            if not ham.dbContains(member.getId(), list) then
                ham.insertIntoDB(member.getId(), list)
            end
        end
    end

    function self.deactivate(list)
        for _, member in ipairs(members) do
            if ham.dbContains(member.getId(), list) then
                ham.removeFromDB(member.getId(), list)
            end
        end
    end

    return self
end
