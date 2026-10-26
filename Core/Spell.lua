local addonName, ham = ...

ham.Spell = {}

-- Maps a spell id to every rank id of that spell, for flavors with spell ranks.
-- Filled in by the per-flavor Core/Spells/<Flavor>.lua files.
ham.spellRanks = {}

-- Cooldown talents: a talent's spell id -> { spell = the addon's spell, seconds = what the talent
-- takes off that spell's base cooldown }. A talent counts while the player knows its spell id.
-- Filled in by the per-flavor Core/Spells/<Flavor>.lua files.
ham.cooldownTalents = {}

-- The global IsSpellKnown is a deprecated wrapper around C_SpellBook.IsSpellInSpellBook on
-- every flavor that has the C_SpellBook version (Retail, Classic Era, TBC, Mists, Forever),
-- and only exists there while the loadDeprecationFallbacks CVar is on. Cata and Wrath have
-- no C_SpellBook version, so they keep the native global. Same arguments as the wrapper.
local function isSpellKnown(spellId, isPet)
    if C_SpellBook and C_SpellBook.IsSpellInSpellBook then
        local spellBank = isPet and Enum.SpellBookSpellBank.Pet or Enum.SpellBookSpellBank.Player
        return C_SpellBook.IsSpellInSpellBook(spellId, spellBank, false)
    end
    return IsSpellKnown(spellId, isPet)
end

-- The spell's icon (FileDataID). Feature-detect C_Spell rather than branching on ham.isRetail:
-- Forever runs the Mainline client engine (C_Spell.*, no GetSpellTexture global) despite
-- ham.isRetail being false for it.
function ham.getSpellIcon(spellId)
    if C_Spell and C_Spell.GetSpellTexture then
        return C_Spell.GetSpellTexture(spellId)
    end
    return GetSpellTexture(spellId)
end

ham.Spell.new = function(id, class)
    local self = {}

    self.id = id
    self.class = class -- Blizzard class token (e.g. "ROGUE"), or nil if not tied to one class
    -- Feature-detect the modern C_Spell API rather than branching on ham.isRetail: Forever runs
    -- the Mainline client engine, so GetSpellInfo is nil there (confirmed via an in-game error)
    -- even though its content is Classic-based and ham.isRetail is false for it.
    if C_Spell and C_Spell.GetSpellName then
        self.name = C_Spell.GetSpellName(id)
    else
        self.name = GetSpellInfo(id)
    end

    function self.getId()
        return self.id
    end

    function self.getName()
        return self.name
    end

    function self.getClass()
        return self.class
    end

    function self.isKnown()
        -- Ranked (Classic-era) spells: the stored id is one specific rank, so also accept
        -- any other rank registered in ham.spellRanks. The macro casts by name, which
        -- resolves to the highest rank the player knows.
        for _, rankId in ipairs(ham.spellRanks[self.id] or { self.id }) do
            if isSpellKnown(rankId) or isSpellKnown(rankId, true) then
                return true
            end
        end
        return false
    end

    return self
end
