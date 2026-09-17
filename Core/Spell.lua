local addonName, ham = ...

ham.Spell = {}

ham.Spell.new = function(id)
    local self = {}

    self.id = id
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

    function self.isKnown()
        return IsSpellKnown(self.id) or IsSpellKnown(self.id, true)
    end

    return self
end
