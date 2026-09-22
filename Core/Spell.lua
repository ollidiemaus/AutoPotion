local addonName, ham = ...

ham.Spell = {}

ham.Spell.new = function(id, class)
    local self = {}

    self.id = id
    self.class = class -- Blizzard class token (e.g. "ROGUE"), or nil if not tied to one class
    -- Feature-detect the modern C_Spell API rather than branching on ham.isRetail: Forever runs
    -- the Mainline client engine, so GetSpellInfo is nil there (confirmed via an in-game error)
    -- even though its content is Classic-based and ham.isRetail is false for it.
    if C_Spell and C_Spell.GetSpellCooldown and C_Spell.GetSpellName then
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
