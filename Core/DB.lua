local addonName, ham = ...

-- The layout of the saved settings. Raise it when a change needs more than new keys at their
-- defaults, and upgrade older settings in ham.loadSettings.
local SETTINGS_VERSION = 1

ham.defaults = {
    version = SETTINGS_VERSION,
    cdReset = false,
    stopCast = false,
    raidStone = false,
    witheringPotion = false,
    witheringDreamsPotion = false,
    cavedwellerDelight = true,
    heartseekingInjector = false,
    includeBuffFood = false,
    -- with includeBuffFood: buff food first while the food buff is missing, last while it's there
    buffFoodOnlyWhenMissing = false,
    includeRejuvenation = true,
    soulburn = false,
    -- ham.bitterImmunity is deliberately left out - it was removed outright in patch
    -- 12.0.0 with no replacement, and was never offered on any Classic flavor either, so
    -- there's no longer a checkbox anywhere for this default to correspond to.
    activatedSpells = { ham.recuperate.getId(), ham.crimsonVialSpell.getId(), ham.renewal.getId(),
        ham.exhilaration.getId(), ham.lastStand.getId(),
        ham.desperatePrayer.getId(), ham.healingElixir.getId(), ham.darkPact.getId(), ham.giftOfTheNaaruDK.getId(),
        ham.giftOfTheNaaruHunter.getId(), ham.giftOfTheNaaruMage.getId(), ham.giftOfTheNaaruMageWarlock.getId(),
        ham.giftOfTheNaaruMonk.getId(), ham.giftOfTheNaaruPaladin.getId(), ham.giftOfTheNaaruPriest.getId(),
        ham.giftOfTheNaaruRogue.getId(), ham.giftOfTheNaaruShaman.getId(), ham.giftOfTheNaaruWarrior.getId(),
        ham.bagOfTricks.getId(), ham.quietContemplation.getId() }
}

-- Loads the saved settings on ADDON_LOADED and upgrades them to SETTINGS_VERSION: every key
-- missing from them is added at its default, one key at a time, and stored values stay as they
-- are. Settings from before version 1 have no version; the ones without the healing-spell list
-- used to be wiped, now they just get the default list. Settings from a newer version are left
-- untouched, ham.options fills in what they lack.
function ham.loadSettings()
    HAMDB = HAMDB or {}
    if (HAMDB.version or 0) <= SETTINGS_VERSION then
        for key, default in pairs(ham.defaults) do
            if HAMDB[key] == nil then
                HAMDB[key] = type(default) == "table" and CopyTable(default) or default
            end
        end
        HAMDB.version = SETTINGS_VERSION
    end
    ham.refreshOptions()
end

-- Rebuilds ham.options, the settings the macros and the settings pages use, from the saved
-- settings. Call it after every change to HAMDB. ham.options shares its tables with HAMDB and
-- the defaults, so a change goes into a new table in HAMDB, never into ham.options.
function ham.refreshOptions()
    local options = {}
    for key, default in pairs(ham.defaults) do
        local value = HAMDB[key]
        if value == nil then value = default end
        options[key] = value
    end
    ham.options = options
end

-- Whether the healing spell with this id is ticked.
function ham.dbContains(id)
    for _, v in ipairs(ham.options.activatedSpells) do
        if v == id then
            return true
        end
    end
    return false
end

-- Unticks and ticks a healing spell: the saved settings get a new list, then ham.options.
function ham.removeFromDB(id)
    local spells = {}
    for _, v in ipairs(ham.options.activatedSpells) do
        if v ~= id then
            table.insert(spells, v)
        end
    end
    HAMDB.activatedSpells = spells
    ham.refreshOptions()
end

function ham.insertIntoDB(id)
    local spells = CopyTable(ham.options.activatedSpells)
    table.insert(spells, id)
    HAMDB.activatedSpells = spells
    ham.refreshOptions()
end
