local addonName, ham = ...

ham.Spell = {}

-- Maps a spell id to every rank id of that spell, for flavors with spell ranks.
-- Filled in by the per-flavor Core/Spells/<Flavor>.lua files.
ham.spellRanks = {}

ham.Spell.new = function(id, class)
    local self = {}

    self.id = id
    self.class = class -- Blizzard class token (e.g. "ROGUE"), or nil if not tied to one class
    -- Feature-detect the modern C_Spell API rather than branching on ham.isRetail: Forever runs
    -- the Mainline client engine, so GetSpellInfo is nil there (confirmed via an in-game error)
    -- even though its content is Classic-based and ham.isRetail is false for it.
    if C_Spell and C_Spell.GetSpellCooldown and C_Spell.GetSpellName then
        -- GetSpellCooldown returns nil (not a zeroed table) for a spell ID absent from the
        -- client's spell database entirely, e.g. a Retail-only spell on Forever's Classic-era
        -- spell data. The legacy GetSpellBaseCooldown degraded gracefully instead, so match that.
        local cooldownInfo = C_Spell.GetSpellCooldown(id)
        self.cd = cooldownInfo and cooldownInfo.duration
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
        -- Ranked (Classic-era) spells: the stored id is one specific rank, so also accept
        -- any other rank registered in ham.spellRanks. The macro casts by name, which
        -- resolves to the highest rank the player knows.
        for _, rankId in ipairs(ham.spellRanks[self.id] or { self.id }) do
            if IsSpellKnown(rankId) or IsSpellKnown(rankId, true) then
                return true
            end
        end
        return false
    end

    return self
end
