-- The game API the fake client offers, bound to one client's state. A function exists on a
-- flavor only where the client's generated API docs (Blizzard_APIDocumentationGenerated, see the
-- wow-data skill) list it, so code that relies on an API a flavor lacks fails here as in game.
local Widgets = require("fake.widgets")

local Api = {}

local CLASSES = {
  WARRIOR = { id = 1, name = "Warrior" }, PALADIN = { id = 2, name = "Paladin" },
  HUNTER = { id = 3, name = "Hunter" }, ROGUE = { id = 4, name = "Rogue" },
  PRIEST = { id = 5, name = "Priest" }, DEATHKNIGHT = { id = 6, name = "Death Knight" },
  SHAMAN = { id = 7, name = "Shaman" }, MAGE = { id = 8, name = "Mage" },
  WARLOCK = { id = 9, name = "Warlock" }, MONK = { id = 10, name = "Monk" },
  DRUID = { id = 11, name = "Druid" }, DEMONHUNTER = { id = 12, name = "Demon Hunter" },
  EVOKER = { id = 13, name = "Evoker" },
}

local MAX_CHARACTER_MACROS = 30
local MAX_MACRO_LENGTH = 255

-- Icons are FileDataIDs in game; the fake makes one up from the item or spell ID.
function Api.itemIcon(itemId) return 100000000 + itemId end
function Api.spellIcon(spellId) return 200000000 + spellId end

-- Blizzard's CopyTable: a deep copy, or a shallow one when `shallow` is set.
function Api.copyTable(source, shallow)
  local copy = {}
  for key, value in pairs(source) do
    if type(value) == "table" and not shallow then value = Api.copyTable(value) end
    copy[key] = value
  end
  return copy
end

local function installLuaExtensions(env)
  -- the string table is the host's, shared by every client: method calls (msg:trim()) look it up
  -- through the string metatable, which only has the one
  string.trim = string.trim or function(text, chars)
    chars = chars and ("[" .. chars:gsub("[%]%^%-]", "%%%0") .. "]") or "%s"
    return (text:gsub("^" .. chars .. "+", ""):gsub(chars .. "+$", ""))
  end
  env.format = string.format
  env.CopyTable = Api.copyTable
  env.time, env.date = os.time, os.date
end

local function installUnitAndWorld(client, env)
  env.UnitClass = function(unit)
    if unit ~= "player" then return nil end
    local class = CLASSES[client.class]
    return class.name, client.class, class.id
  end
  env.LOCALIZED_CLASS_NAMES_MALE = {}
  for token, class in pairs(CLASSES) do env.LOCALIZED_CLASS_NAMES_MALE[token] = class.name end
  env.UnitFactionGroup = function(unit)
    if unit == "player" then return client.faction, client.faction end
  end
  env.IsInInstance = function()
    return client.instanceType ~= "none", client.instanceType
  end
  env.C_Map = {
    GetBestMapForUnit = function(unit)
      if unit == "player" then return client.mapId end
    end,
  }
  if client.flavor.hasPvpInfo then
    env.C_PvP = {
      IsBattleground = function() return client.instanceType == "pvp" end,
      IsRatedBattleground = function() return false end,
    }
  end
  env.C_EventUtils = {
    IsEventValid = function(event) return client.events[event] == true end,
  }
  env.InCombatLockdown = function() return client.lockdown end
  env.GetLocale = function() return "enUS" end
  env.IsMacClient = function() return false end
  env.GetBuildInfo = function()
    local flavor = client.flavor
    return flavor.version, flavor.build, "Oct 1 2026", flavor.interface
  end
end

local function installItems(client, env)
  local function item(itemId)
    itemId = tonumber(itemId)
    local data = client.items[itemId] or {}
    return itemId, data
  end
  env.C_Item = {
    GetItemCount = function(itemId)
      client.apiCalls["C_Item.GetItemCount"] = client:apiCallCount("C_Item.GetItemCount") + 1
      return client.bags[tonumber(itemId)] or 0
    end,
    -- an item the cache lacks reports nothing; the request loads it by the next frame
    GetItemInfo = function(itemId)
      local id, data = item(itemId)
      if not id then return nil end
      if not client:isItemCached(id) then
        client:requestItem(id)
        return nil
      end
      local name = data.name or ("Item " .. id)
      local link = "|cffffffff|Hitem:" .. id .. "::::::::::::::|h[" .. name .. "]|h|r"
      return name, link, 1, 1, 1, "Consumable", "Consumable", 20, "", data.icon or Api.itemIcon(id), 0, 0, 0, 0, 0, nil, false
    end,
    -- reads the client's item data, not the cache
    GetItemIconByID = function(itemId)
      client.apiCalls["C_Item.GetItemIconByID"] = client:apiCallCount("C_Item.GetItemIconByID") + 1
      local id, data = item(itemId)
      return id and (data.icon or Api.itemIcon(id))
    end,
    GetItemSpell = function(itemId)
      local _, data = item(itemId)
      if data.spell then return data.spell.name, data.spell.id end
    end,
  }
  env.GetInventoryItemID = function(unit, slot)
    if unit == "player" then return client.equipped[slot] end
  end
  env.GetInventoryItemTexture = function(unit, slot)
    local itemId = env.GetInventoryItemID(unit, slot)
    return itemId and env.C_Item.GetItemIconByID(itemId)
  end
end

local function installSpells(client, env)
  env.Enum = env.Enum or {}
  env.Enum.SpellBookSpellBank = { Player = 0, Pet = 1 }
  local function known(spellId, spellBank)
    local spells = spellBank == env.Enum.SpellBookSpellBank.Pet and client.petSpells or client.knownSpells
    return spells[spellId] == true
  end
  local function spell(spellId)
    return client.spells[spellId] or {}
  end
  env.C_Spell = {
    GetSpellName = function(spellId) return spell(spellId).name or ("Spell " .. spellId) end,
    GetSpellTexture = function(spellId)
      client.apiCalls["C_Spell.GetSpellTexture"] = client:apiCallCount("C_Spell.GetSpellTexture") + 1
      return spell(spellId).icon or Api.spellIcon(spellId)
    end,
    GetSpellCooldown = function()
      return { startTime = 0, duration = 0, isEnabled = true, modRate = 1 }
    end,
  }
  env.C_SpellBook = {
    IsSpellInSpellBook = function(spellId, spellBank) return known(spellId, spellBank) end,
    IsSpellKnown = function(spellId, spellBank) return known(spellId, spellBank) end,
  }
  env.GetSpellBaseCooldown = function(spellId)
    return spell(spellId).baseCooldown or 0, 0
  end
end

-- The unit's auras. Every aura the fake knows is a buff (HELPFUL). All three flavors list
-- C_UnitAuras.GetPlayerAuraBySpellID and GetAuraDataBySpellName; AuraUtil.FindAuraByName is
-- FrameXML (Blizzard_FrameXMLUtil) on all three.
local function installAuras(client, env)
  local function find(unit, matches, filter)
    if filter and filter:find("HARMFUL") then return nil end
    for _, aura in ipairs(client.auras[unit] or {}) do
      if matches(aura) then return Api.copyTable(aura) end
    end
  end
  env.C_UnitAuras = {
    GetPlayerAuraBySpellID = function(spellId)
      return find("player", function(aura) return aura.spellId == spellId end)
    end,
    GetAuraDataBySpellName = function(unit, spellName, filter)
      client.apiCalls["C_UnitAuras.GetAuraDataBySpellName"] = client:apiCallCount("C_UnitAuras.GetAuraDataBySpellName") + 1
      return find(unit, function(aura) return aura.name == spellName end, filter)
    end,
  }
  env.AuraUtil = {
    -- AuraUtil.UnpackAuraData's returns
    FindAuraByName = function(auraName, unit, filter)
      local aura = env.C_UnitAuras.GetAuraDataBySpellName(unit, auraName, filter)
      if not aura then return nil end
      return aura.name, aura.icon, aura.applications, nil, aura.duration, aura.expirationTime,
        aura.sourceUnit, false, false, aura.spellId
    end,
  }
end

-- A stand-in for the MegaMacro addon, installed and loaded before AutoPotion: its global macros
-- (one per name in client.megaMacroNames) and the UpdateCode call AutoPotion writes them with,
-- recorded in client.macroCalls.
local MEGA_MACRO = "MegaMacro"
local function installMegaMacro(client, env)
  local macros = {}
  for i, name in ipairs(client.megaMacroNames) do
    macros[i] = { Id = i, Scope = "gg", DisplayName = name, Code = "" }
  end
  env.MegaMacroGlobalData = { Macros = macros }
  env.MegaMacro = {
    UpdateCode = function(macro, code)
      table.insert(client.macroCalls, { func = "MegaMacro.UpdateCode", name = macro.DisplayName, body = code })
      macro.Code = code
    end,
  }
end

local function installAddOns(client, env)
  local function isOwn(name) return name == client.addonName or name == 1 end
  local hasMegaMacro = client.megaMacroNames ~= nil
  if hasMegaMacro then installMegaMacro(client, env) end
  env.C_AddOns = {
    GetAddOnInfo = function(name)
      if isOwn(name) then
        local metadata = client.addonMetadata
        return client.addonName, metadata.Title, metadata.Notes, true, nil, "INSECURE", false
      end
      if hasMegaMacro and name == MEGA_MACRO then
        return MEGA_MACRO, MEGA_MACRO, nil, true, nil, "INSECURE", false
      end
      return nil, nil, nil, false, "MISSING", "INSECURE", false
    end,
    IsAddOnLoaded = function(name)
      if isOwn(name) then return client.addonLoaded, client.addonLoaded end
      if hasMegaMacro and name == MEGA_MACRO then return true, true end
      return false, false
    end,
    GetAddOnMetadata = function(name, field)
      if isOwn(name) then return client.addonMetadata[field] end
    end,
  }
end

-- Macros: account (general) macros take indexes 1..maxAccountMacros, character macros the ones
-- after. Creating and editing are protected in combat: there the call is recorded as a blocked
-- action and does nothing, as the game does with an addon's call. client.macroApiError, when set,
-- makes them fail with that message the way the C API raises errors.
local function installMacros(client, env)
  local macros = client.macros
  local MAX_ACCOUNT_MACROS = client.maxAccountMacros

  -- Retail and Forever list the limits in Constants.MacroConsts; Classic Era's MacroUI reads globals.
  if client.flavorName == "classic" then
    env.MAX_ACCOUNT_MACROS, env.MAX_CHARACTER_MACROS = MAX_ACCOUNT_MACROS, MAX_CHARACTER_MACROS
  else
    env.Constants = env.Constants or {}
    env.Constants.MacroConsts = {
      MAX_ACCOUNT_MACROS = MAX_ACCOUNT_MACROS, MAX_CHARACTER_MACROS = MAX_CHARACTER_MACROS,
    }
  end

  env.GetNumMacros = function() return #macros.account, #macros.character end

  local function find(nameOrIndex)
    if type(nameOrIndex) == "number" then
      if nameOrIndex > MAX_ACCOUNT_MACROS then
        return macros.character, nameOrIndex - MAX_ACCOUNT_MACROS
      end
      return macros.account, nameOrIndex
    end
    for _, list in ipairs({ macros.account, macros.character }) do
      for position, macro in ipairs(list) do
        if macro.name == nameOrIndex then return list, position end
      end
    end
  end

  local function indexOf(list, position)
    if not list or not list[position] then return 0 end
    return list == macros.character and MAX_ACCOUNT_MACROS + position or position
  end

  env.GetMacroInfo = function(nameOrIndex)
    local list, position = find(nameOrIndex)
    local macro = list and list[position]
    if macro then return macro.name, macro.icon, macro.body end
  end

  env.CreateMacro = function(name, icon, body, perCharacter)
    table.insert(client.macroCalls, { func = "CreateMacro", name = name, body = body })
    if client:blockProtected("CreateMacro") then return end
    if client.macroApiError then error(client.macroApiError, 2) end
    local list = perCharacter and macros.character or macros.account
    local limit = perCharacter and MAX_CHARACTER_MACROS or MAX_ACCOUNT_MACROS
    if #list >= limit then error("CreateMacro(): Too many macros", 2) end
    table.insert(list, { name = name, icon = icon, body = (body or ""):sub(1, MAX_MACRO_LENGTH) })
    return indexOf(list, #list)
  end

  env.EditMacro = function(nameOrIndex, name, icon, body)
    table.insert(client.macroCalls, { func = "EditMacro", macro = nameOrIndex, name = name, body = body })
    if client:blockProtected("EditMacro") then return end
    if client.macroApiError then error(client.macroApiError, 2) end
    local list, position = find(nameOrIndex)
    local macro = list and list[position]
    if not macro then error("EditMacro(): Invalid macro " .. tostring(nameOrIndex), 2) end
    macro.name = name or macro.name
    macro.icon = icon or macro.icon
    if body then macro.body = body:sub(1, MAX_MACRO_LENGTH) end
    return indexOf(list, position)
  end
end

-- The settings registration API. Opening a category shows the settings panel, then swaps the
-- canvas frame the way SettingsPanelMixin:OpenToCategory does: the old frame is unparented and
-- hidden, the new one parented to the canvas and shown, and then the canvas is shown. The canvas
-- starts hidden, as when the panel is on one of the game's own list categories.
local function installSettings(client, env)
  local categories = client.settingsCategories
  local panel = Widgets.CreateFrame(client, "Frame", "SettingsPanel", env.UIParent)
  panel:Hide()
  local canvas = Widgets.CreateFrame(client, "Frame", nil, panel)
  canvas:Hide()
  local current

  local Category = {}
  Category.__index = Category
  function Category:GetID() return self.ID end
  function Category:GetName() return self.name end

  local function register(frame, name, parentCategory)
    local category = setmetatable({ ID = #categories + 1, name = name, frame = frame, parent = parentCategory }, Category)
    table.insert(categories, category)
    return category, { GetFrame = function() return frame end }
  end

  local function display(category)
    panel:Show()
    if current == category then return end
    if current then
      current.frame:SetParent(nil)
      current.frame:ClearAllPoints()
      current.frame:Hide()
    end
    current = category
    category.frame:SetParent(canvas)
    category.frame:ClearAllPoints()
    category.frame:SetAllPoints(canvas)
    category.frame:Show()
    canvas:Show()
  end
  client.displaySettingsCategory = display
  client.settingsPanel = panel
  client.displayedSettingsCategory = function() return current end

  env.Settings = {
    RegisterCanvasLayoutCategory = function(frame, name) return register(frame, name) end,
    RegisterCanvasLayoutSubcategory = function(parentCategory, frame, name)
      return register(frame, name, parentCategory)
    end,
    RegisterAddOnCategory = function(category) category.addOn = true end,
    OpenToCategory = function(categoryId)
      for _, category in ipairs(categories) do
        if category.ID == categoryId then display(category) end
      end
    end,
  }
end

function Api.install(client, env)
  installLuaExtensions(env)
  installUnitAndWorld(client, env)
  installItems(client, env)
  installSpells(client, env)
  installAuras(client, env)
  installAddOns(client, env)
  installMacros(client, env)
  installSettings(client, env)

  for name, id in pairs(client.flavor.projectIds) do env[name] = id end
  env.WOW_PROJECT_ID = client.flavor.projectId
  env.GREEN_FONT_COLOR_CODE = "|cff20ff20"
  -- ColorMixin objects from SharedColorConstants
  local function color(r, g, b)
    return { r = r, g = g, b = b, a = 1, GetRGB = function(self) return self.r, self.g, self.b end }
  end
  env.HIGHLIGHT_FONT_COLOR = color(1, 1, 1)
  env.GRAY_FONT_COLOR = color(0.5, 0.5, 0.5)
  env.FONT_COLOR_CODE_CLOSE = "|r"
  env.SlashCmdList = {}
  env.C_Timer = {
    After = function(seconds, callback)
      if type(callback) ~= "function" then error("C_Timer.After: callback must be a function", 2) end
      client:after(seconds, callback)
    end,
  }
  env.geterrorhandler = function() return client.errorHandler end
  -- the fake hands out no secret values
  env.issecretvalue = function() return false end
end

return Api
