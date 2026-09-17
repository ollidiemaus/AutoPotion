---@diagnostic disable: undefined-global
local addonName, ham = ...

-- WoW flavor detection (single source of truth, used across every module)
ham.isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
ham.isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
ham.isTBC = (WOW_PROJECT_ID == 5) -- TBC Anniversary / BCC
ham.isWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
ham.isCata = (WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC)
ham.isMop = (WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC)

-- Classic battleground UI Map IDs
-- Exposed on `ham` for use across modules (bandages, potions, etc.)
ham.MAP_ID_ALTERAC_VALLEY = 1459
ham.MAP_ID_WARSONG_GULCH = 1460
ham.MAP_ID_ARATHI_BASIN = 1461


