---@diagnostic disable: undefined-global
local addonName, ham = ...

-- WoW flavor detection (single source of truth, used across every module)
ham.isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
ham.isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
ham.isTBC = (WOW_PROJECT_ID == 5) -- TBC Anniversary / BCC
ham.isWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
ham.isCata = (WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC)
ham.isMop = (WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC)

-- WOW_PROJECT_ID has no documented constant for WoW Forever yet, so detect via interface number instead.
-- Interface numbers are 5 digits (e.g. 16001 for client 1.60.1); the 16000-19999 range is reserved for
-- Forever ahead of BCC's 20000+, matching the detection used by DBM and Details-Framework/Plater.
local _, _, _, tocVersion = GetBuildInfo()
ham.isForever = (tocVersion and tocVersion >= 16000 and tocVersion < 20000) or false

-- Classic battleground UI Map IDs
-- Exposed on `ham` for use across modules (bandages, potions, etc.)
ham.MAP_ID_ALTERAC_VALLEY = 1459
ham.MAP_ID_WARSONG_GULCH = 1460
ham.MAP_ID_ARATHI_BASIN = 1461


