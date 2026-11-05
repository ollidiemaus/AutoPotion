---@diagnostic disable: undefined-global
local addonName, ham = ...

-- WoW flavor detection (single source of truth, used across every module)

-- WOW_PROJECT_ID has no documented constant for WoW Forever yet (confirmed in-game via
-- /dump WOW_PROJECT_ID, which currently reports 1/WOW_PROJECT_MAINLINE on the Forever beta client,
-- since Forever runs on the Mainline client codebase). Detect it via interface number instead.
-- Interface numbers are 5 digits (e.g. 16001 for client 1.60.1); the 16000-19999 range is reserved for
-- Forever ahead of BCC's 20000+, matching the detection used by DBM and Details-Framework/Plater.
local _, _, _, tocVersion = GetBuildInfo()
ham.isForever = (tocVersion and tocVersion >= 16000 and tocVersion < 20000) or false

-- Forever shares WOW_PROJECT_MAINLINE with Retail, but its content is Vanilla-based, so it must be
-- excluded here to keep every existing "if ham.isRetail" check in the addon Forever-safe by default.
ham.isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) and not ham.isForever
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

-- UI maps of the zones where Forever's own Major and Greater Healing Potion work
ham.MAP_ID_THE_HINTERLANDS = 1425
ham.MAP_ID_DUSKWOOD = 1431
ham.MAP_ID_ASHENVALE = 1440
ham.MAP_ID_FERALAS = 1444

-- Instance maps of Forever's islands. A zone-locked item's area requirement covers the whole
-- island, so these are instance map IDs (GetInstanceInfo), not UI maps: every subzone shares one.
ham.INSTANCE_MAP_ID_ZEPHRAS_ISLE = 2991
ham.INSTANCE_MAP_ID_DARKSPEAR_ISLANDS = 2997

-- Whether the player is on this instance map. Leaving one is a loading screen, so the macros
-- follow through PLAYER_ENTERING_WORLD.
function ham.isOnInstanceMap(mapId)
  return select(8, GetInstanceInfo()) == mapId
end


