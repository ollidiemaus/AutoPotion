local addonName, ham = ...

-- The layout of the saved settings. Raise it when a change needs more than new keys at their
-- defaults, and upgrade older settings in ham.loadSettings.
local SETTINGS_VERSION = 2

ham.defaults = {
    version = SETTINGS_VERSION,
    cdReset = false,
    stopCast = false,
    raidStone = false,
    -- the potion priority turned around: the weakest health / mana potion first
    weakestPotionFirst = false,
    weakestManaPotionFirst = false,
    witheringPotion = false,
    witheringDreamsPotion = false,
    cavedwellerDelight = true,
    heartseekingInjector = false,
    includeBuffFood = false,
    -- with includeBuffFood: buff food first while the food buff is missing, last while it's there
    buffFoodOnlyWhenMissing = false,
    -- with includeBuffFood: the unticked buff kinds, { [kind] = true }. Buff food none of whose
    -- kinds is ticked isn't eaten. Kept as the unticked ones so every kind, a new one too, starts
    -- ticked.
    unwantedBuffKinds = {},
    -- the food / drink restoring the least health / mana first, conjured items still first
    weakestFoodFirst = false,
    weakestDrinkFirst = false,
    includeRejuvenation = true,
    -- AutoManaPotion uses the best mana gem before the mana potion
    useManaGems = true,
    -- With useManaGems: show and use the mana potion while the mana gem is on cooldown
    skipManaGemOnCooldown = false,
    -- Create a separate AutoManaGem macro and keep AutoManaPotion for mana potions only
    separateManaGemMacro = false,
    -- AutoManaPotion uses a demonic rune after the mana potion (costs health; not on Retail)
    includeDemonicRunes = false,
    soulburn = false,
    -- Forever: the AutoBandage macro casts Rapid Regeneration (Troll racial) before the bandage
    rapidRegenerationBandage = true,
    -- ham.bitterImmunity is deliberately left out - it was removed outright in patch
    -- 12.0.0 with no replacement, and was never offered on any Classic flavor either, so
    -- there's no longer a checkbox anywhere for this default to correspond to.
    activatedSpells = { ham.recuperate.getId(), ham.crimsonVialSpell.getId(), ham.renewal.getId(),
        ham.exhilaration.getId(), ham.lastStand.getId(),
        ham.desperatePrayer.getId(), ham.healingElixir.getId(), ham.darkPact.getId(), ham.giftOfTheNaaruDK.getId(),
        ham.giftOfTheNaaruHunter.getId(), ham.giftOfTheNaaruMage.getId(), ham.giftOfTheNaaruMageWarlock.getId(),
        ham.giftOfTheNaaruMonk.getId(), ham.giftOfTheNaaruPaladin.getId(), ham.giftOfTheNaaruPriest.getId(),
        ham.giftOfTheNaaruRogue.getId(), ham.giftOfTheNaaruShaman.getId(), ham.giftOfTheNaaruWarrior.getId(),
        ham.bagOfTricks.getId(), ham.quietContemplation.getId() },
    -- the ticked mana spells (AutoManaPotion), none until the player ticks one. Version 2 added it.
    activatedManaSpells = {},
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

-- Whether buff food of this buff kind is wanted (ticked).
function ham.isBuffKindWanted(kind)
    return not ham.options.unwantedBuffKinds[kind]
end

-- Ticks or unticks a buff kind: the saved settings get a new set of unticked kinds, then ham.options.
function ham.setBuffKindWanted(kind, wanted)
    local unwanted = CopyTable(ham.options.unwantedBuffKinds)
    unwanted[kind] = (not wanted) or nil
    HAMDB.unwantedBuffKinds = unwanted
    ham.refreshOptions()
end

-- The saved lists of ticked spells: "activatedSpells" (heal spells, the default) and
-- "activatedManaSpells" (mana spells). A spell belongs to one of them.

-- Whether the spell with this id is ticked in the list (heal spells by default).
function ham.dbContains(id, list)
    for _, v in ipairs(ham.options[list or "activatedSpells"]) do
        if v == id then
            return true
        end
    end
    return false
end

-- Unticks and ticks a spell in the list (heal spells by default): the saved settings get a new
-- list, then ham.options.
function ham.removeFromDB(id, list)
    list = list or "activatedSpells"
    local spells = {}
    for _, v in ipairs(ham.options[list]) do
        if v ~= id then
            table.insert(spells, v)
        end
    end
    HAMDB[list] = spells
    ham.refreshOptions()
end

function ham.insertIntoDB(id, list)
    list = list or "activatedSpells"
    local spells = CopyTable(ham.options[list])
    table.insert(spells, id)
    HAMDB[list] = spells
    ham.refreshOptions()
end
