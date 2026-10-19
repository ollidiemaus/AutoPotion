-- Lint guards globals: a leaked global (wow-addon-standards T4) or a misspelled API name fails it.
-- Unused values, shadowing and line length are left to review.
std = "lua51"
max_line_length = false
ignore = { "21", "31", "4", "542" }
-- .lua/, .luarocks/ and .install/ are the toolchains the CI actions install into the workspace.
exclude_files = { ".git/", ".release/", "Libs/", ".lua/", ".luarocks/", ".install/" }

-- Globals the addon defines.
globals = {
    "HAMDB",
    "SLASH_HAM1", "SLASH_HAM2", "SLASH_HAM3", "SLASH_HAM4",
    "SlashCmdList",
}

-- WoW API the addon reads. Keep this list explicit: an unexpected global is usually a typo.
read_globals = {
    -- Lua extensions in the WoW client
    "format", "issecretvalue",
    -- Namespaces
    "AuraUtil", "C_AddOns", "C_EventUtils", "C_Item", "C_Map", "C_PvP", "C_Secrets", "C_Spell",
    "C_SpellBook", "C_Timer", "C_UnitAuras", "Constants", "Enum", "Settings",
    -- Frames and UI
    "CreateFrame", "GameTooltip", "GameFontHighlightSmall", "InterfaceOptionsFramePanelContainer",
    "InterfaceOptionsFrame_OpenToCategory", "InterfaceOptions_AddCategory", "CopyTable",
    "FONT_COLOR_CODE_CLOSE", "GRAY_FONT_COLOR", "GREEN_FONT_COLOR_CODE", "HIGHLIGHT_FONT_COLOR",
    -- Macros
    "CreateMacro", "EditMacro", "GetMacroInfo", "GetNumMacros", "MAX_ACCOUNT_MACROS",
    "MegaMacro", "MegaMacroGlobalData",
    -- Items, spells, units
    "GetInventoryItemID", "GetInventoryItemTexture", "GetSpellBaseCooldown", "GetSpellInfo",
    "GetSpellTexture", "IsSpellKnown", "UnitClass", "UnitFactionGroup", "LOCALIZED_CLASS_NAMES_MALE",
    "InCombatLockdown", "IsInInstance",
    -- Client and flavor
    "GetAddOnMetadata", "GetBuildInfo", "IsAddOnLoaded", "IsMacClient",
    "WOW_PROJECT_ID", "WOW_PROJECT_MAINLINE", "WOW_PROJECT_CLASSIC", "WOW_PROJECT_WRATH_CLASSIC",
    "WOW_PROJECT_CATACLYSM_CLASSIC", "WOW_PROJECT_MISTS_CLASSIC",
    -- Libraries
    "LibStub",
}

-- The test runner defines test() and assertEqual(); the fake client installs the WoW API into _G.
files["tests/"] = {
    globals = { "test", "assertEqual", "string" },
}
