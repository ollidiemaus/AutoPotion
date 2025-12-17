local addonName, ham = ...

-- Classic battleground UI Map IDs
-- Exposed on `ham` for use across modules (bandages, potions, etc.)
ham.MAP_ID_ALTERAC_VALLEY = 1459
ham.MAP_ID_WARSONG_GULCH = 1460
ham.MAP_ID_ARATHI_BASIN = 1461


-- Environment flags centralized for reuse across modules
ham.env = {
  isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE),
  isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC),
  isWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC),
  isCata = (WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC),
  isMop = (WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC),
}

-- Shared string constants
ham.SLOT_PREFIX = "slot:"
-- Slot IDs
ham.SLOT_HEAD = 1
ham.SLOT_WRIST = 9
ham.SLOT_RANGED = 18
ham.SLOT_TRINKET2 = 14

-- Common helpers
function ham.getEnvKey()
  local env = ham.env
  if env and env.isRetail then return "retail" end
  if env and env.isClassic then return "classic" end
  if env and env.isWrath then return "wrath" end
  if env and env.isCata then return "cata" end
  if env and env.isMop then return "mop" end
  return "unknown"
end

function ham.copyList(list)
  local out = {}
  for i, v in ipairs(list or {}) do out[i] = v end
  return out
end

-- Simple deferral helper
function ham.defer(seconds, fn)
  C_Timer.After(seconds, fn)
end

-- Event names
ham.EVT_ADDON_LOADED = "ADDON_LOADED"
ham.EVT_BAG_UPDATE = "BAG_UPDATE"
ham.EVT_PLAYER_ENTERING_WORLD = "PLAYER_ENTERING_WORLD"
ham.EVT_PLAYER_EQUIPMENT_CHANGED = "PLAYER_EQUIPMENT_CHANGED"
ham.EVT_TRAIT_CONFIG_UPDATED = "TRAIT_CONFIG_UPDATED"
ham.EVT_PLAYER_REGEN_ENABLED = "PLAYER_REGEN_ENABLED"
ham.EVT_UNIT_PET = "UNIT_PET"
ham.EVT_PLAYER_LOGIN = "PLAYER_LOGIN"

-- UI helpers namespace
ham.ui = ham.ui or {}

function ham.ui.attachSpellTooltip(frame, spellId)
  frame:HookScript("OnEnter", function()
    GameTooltip:SetOwner(frame, "ANCHOR_TOPRIGHT")
    GameTooltip:SetSpellByID(spellId)
    GameTooltip:Show()
  end)
  frame:HookScript("OnLeave", function()
    GameTooltip:Hide()
  end)
end

function ham.ui.attachItemTooltip(frame, itemId)
  frame:HookScript("OnEnter", function()
    GameTooltip:SetOwner(frame, "ANCHOR_TOPRIGHT")
    GameTooltip:SetItemByID(itemId)
    GameTooltip:Show()
  end)
  frame:HookScript("OnLeave", function()
    GameTooltip:Hide()
  end)
end

function ham.ui.attachInventoryTooltip(frame, slotId)
  frame:HookScript("OnEnter", function()
    GameTooltip:SetOwner(frame, "ANCHOR_TOPRIGHT")
    GameTooltip:SetInventoryItem("player", slotId)
    GameTooltip:Show()
  end)
  frame:HookScript("OnLeave", function()
    GameTooltip:Hide()
  end)
end

-- Item/macro entry formatter for slot or item id
function ham.formatItemEntry(idOrSlot)
  if type(idOrSlot) == "string" and idOrSlot:match("^" .. ham.SLOT_PREFIX) then
    return idOrSlot:sub(#ham.SLOT_PREFIX + 1)
  end
  return "item:" .. tostring(idOrSlot)
end

-- Item icon helper (works across clients, with fallbacks)
function ham.getItemIcon(itemId)
  if C_Item and C_Item.GetItemIconByID then
    return C_Item.GetItemIconByID(itemId)
  end
  if GetItemIcon then
    return GetItemIcon(itemId)
  end
  return nil
end


