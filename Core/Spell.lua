local addonName, ham = ...

ham.Spell = {}

ham.Spell.new = function(id, class)
    local self = {}

    self.id = id
    self.class = class -- Blizzard class token (e.g. "ROGUE"), or nil if not tied to one class
    if ham.isRetail == true then
        self.cd = C_Spell.GetSpellCooldown(id).duration
        self.name = C_Spell.GetSpellName(id)
    else
        self.cd = GetSpellBaseCooldown(id)
        self.name = GetSpellInfo(id)
    end

    function self.getId()
        return self.id
    end

    function self.getName()
        return self.name
    end

    function self.getCd()
        return self.cd
    end

    function self.getClass()
        return self.class
    end

    function self.isKnown()
        return IsSpellKnown(self.id) or IsSpellKnown(self.id, true)
    end

    return self
end
