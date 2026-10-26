-- A headless stand-in for the WoW client. It loads the addon the way the game does (the TOC's
-- files in order, XML includes resolved, the addon name and namespace as the file vararg, saved
-- variables restored before ADDON_LOADED) and records what the client and the player would see:
-- macros, blocked actions, Lua errors, printed text and the globals the addon added.
--
-- Tests act only as the client would (log in, fire events, step frames and timers, enter
-- combat) and read only those records, never the addon's internals.
local Api = require("fake.api")
local Toc = require("fake.toc")
local Widgets = require("fake.widgets")

local Client = {}
Client.__index = Client

local FRAME_TIME = 1 / 60

local PROJECT_IDS = {
  WOW_PROJECT_MAINLINE = 1, WOW_PROJECT_CLASSIC = 2, WOW_PROJECT_WOWLABS = 3,
  WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5, WOW_PROJECT_WRATH_CLASSIC = 11,
  WOW_PROJECT_CATACLYSM_CLASSIC = 14, WOW_PROJECT_MISTS_CLASSIC = 19,
}
local FOREVER_PROJECT_IDS = { WOW_PROJECT_CAMELOT = 18 }
for name, id in pairs(PROJECT_IDS) do FOREVER_PROJECT_IDS[name] = id end

-- What each client reports about itself, from its UI source (wow-data: wow.py builds). Forever's
-- UI source sets WOW_PROJECT_ID to WOW_PROJECT_CAMELOT (Blizzard_ProjectConstants/Camelot); the
-- beta reported 1 (see Core/Constants.lua), and the addon tells Forever by its interface version.
Client.FLAVORS = {
  retail = {
    projectId = 1, projectIds = PROJECT_IDS, version = "12.1.5", build = "70391", interface = 120105,
    hasPvpInfo = true,
  },
  classic = {
    projectId = 2, projectIds = PROJECT_IDS, version = "1.15.9", build = "70003", interface = 11509,
    hasPvpInfo = false,
  },
  forever = {
    projectId = 18, projectIds = FOREVER_PROJECT_IDS, version = "1.60.1", build = "70425", interface = 16001,
    hasPvpInfo = true,
  },
}
Client.FLAVOR_NAMES = { "retail", "classic", "forever" }

-- The Lua 5.1 globals the game offers addons (no io, os, require, dofile or loadfile).
local LUA_GLOBALS = {
  "assert", "error", "getmetatable", "setmetatable", "ipairs", "pairs", "next", "pcall", "xpcall",
  "rawequal", "rawget", "rawset", "select", "tonumber", "tostring", "type", "unpack",
  "getfenv", "setfenv", "string",
}
local LUA_LIBRARIES = { "math", "table", "coroutine", "bit" }

local copy = Api.copyTable

local function toSet(list)
  local result = {}
  for _, value in ipairs(list or {}) do result[value] = true end
  return result
end

-- { [event] = true } for the events a flavor's client knows, from tests/fake/events/<flavor>.txt
-- (written by update.sh there from the client's generated API docs).
local validEvents = {}
local function eventsOf(flavorName)
  if not validEvents[flavorName] then
    local events = {}
    for line in io.lines("tests/fake/events/" .. flavorName .. ".txt") do
      if not line:find("^#") then events[line] = true end
    end
    validEvents[flavorName] = events
  end
  return validEvents[flavorName]
end

-- options:
--   flavor           "retail" (default), "classic" or "forever"
--   class            the player's class token, "WARRIOR" by default
--   faction          "Alliance" (default) or "Horde"
--   instanceType     what IsInInstance reports: "none" (default), "pvp", "party", ...
--   mapId            the player's map, 1429 (Elwynn Forest) by default
--   bags             { [itemId] = count }
--   items            { [itemId] = { name =, icon =, spell = { name =, id = } } }, all optional
--   equipped         { [inventorySlot] = itemId }
--   emptyItemCache   true to start with no item in the item cache, as after clearing the Cache
--                    folder: C_Item.GetItemInfo reports an item only once it has loaded
--   locale           what GetLocale reports, "enUS" by default
--   spells           { [spellId] = { name =, names =, icon =, baseCooldown = } }, all optional;
--                    names = { [locale] = name } for the name in each locale, see Client:spellName
--   knownSpells      { spellId, ... } in the player's spell book; petSpells the same for the pet
--   auras            { spellId, ... } the auras (buffs) the player has, named as `spells` says
--   savedVariables   { [name] = value } as stored by an earlier session
--   accountMacros    { name, ... } general macros the player already has
--   maxAccountMacros the client's limit of general macros, 120 by default
--   megaMacro        { name, ... } global macros in a stub MegaMacro addon, installed and loaded
--                    (Retail only, as the addon checks it only there)
function Client.new(options)
  options = options or {}
  local flavorName = options.flavor or "retail"
  local flavor = Client.FLAVORS[flavorName]
  if not flavor then error("unknown flavor " .. tostring(flavorName), 2) end

  local self = setmetatable({
    flavorName = flavorName,
    flavor = flavor,
    events = eventsOf(flavorName),
    addonName = "AutoPotion",
    addonLoaded = false,
    class = options.class or "WARRIOR",
    faction = options.faction or "Alliance",
    instanceType = options.instanceType or "none",
    mapId = options.mapId or 1429,
    locale = options.locale or "enUS",
    bags = copy(options.bags or {}),
    items = copy(options.items or {}),
    equipped = copy(options.equipped or {}),
    -- { [itemId] = true } for the items loaded, nil when every item is
    itemCache = options.emptyItemCache and {} or nil,
    itemRequests = {},
    spells = copy(options.spells or {}),
    knownSpells = toSet(options.knownSpells),
    petSpells = toSet(options.petSpells),
    -- { [unit] = { aura data, ... } } in the order gained, see Client:gainAura
    auras = {},
    lastAuraInstance = 0,
    aurasHidden = false, -- see Client:hideAuras
    savedVariables = copy(options.savedVariables or {}),
    macros = { account = {}, character = {} },
    maxAccountMacros = options.maxAccountMacros or 120,
    megaMacroNames = options.megaMacro,
    -- records
    errors = {},
    printed = {},
    macroCalls = {},
    blockedActions = {},
    apiCalls = {},
    -- internals
    frames = {},
    timers = {},
    settingsCategories = {},
    time = 0,
    order = 0,
    lockdown = false,
  }, Client)

  for _, spellId in ipairs(options.auras or {}) do self:addAura("player", spellId) end
  for _, name in ipairs(options.accountMacros or {}) do
    table.insert(self.macros.account, { name = name, icon = "INV_Misc_QuestionMark", body = "" })
  end
  self.addonFiles, self.addonMetadata = Toc.read(self.addonName .. ".toc")
  self.errorHandler = function(message)
    table.insert(self.errors, debug.traceback(tostring(message), 2))
  end
  self:createEnvironment()
  self.globalsBeforeLoad = {}
  for name in pairs(self.env) do self.globalsBeforeLoad[name] = true end
  return self
end

function Client:createEnvironment()
  local env = {}
  self.env = env
  for _, name in ipairs(LUA_GLOBALS) do env[name] = _G[name] end
  for _, name in ipairs(LUA_LIBRARIES) do env[name] = copy(_G[name]) end
  env._G = env
  -- like the game's, it compiles into the addon's environment
  env.loadstring = function(source, chunkName)
    local chunk, err = loadstring(source, chunkName)
    if chunk then setfenv(chunk, env) end
    return chunk, err
  end
  env.print = function(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[i] = tostring((select(i, ...))) end
    table.insert(self.printed, table.concat(parts, " "))
  end
  Widgets.install(self, env)
  Api.install(self, env)
end

function Client:nextOrder()
  self.order = self.order + 1
  return self.order
end

-- Calls fn the way the game calls addon code: an error goes to the error handler and the
-- caller carries on.
function Client:call(fn, ...)
  local count, args = select("#", ...), { ... }
  return xpcall(function() return fn(unpack(args, 1, count)) end, function(message)
    self.errorHandler(message)
  end)
end

-- Called by every protected API. Returns true when combat lockdown blocks the call.
function Client:blockProtected(func)
  if not self.lockdown then return false end
  table.insert(self.blockedActions, { addon = self.addonName, func = func })
  self:fireEvent("ADDON_ACTION_BLOCKED", self.addonName, func .. "()")
  return true
end

function Client:isItemCached(itemId)
  return self.itemCache == nil or self.itemCache[itemId] == true
end

-- Asks the server for an item the cache lacks; it arrives on the next frame.
function Client:requestItem(itemId)
  if not self.itemRequests[itemId] then
    self.itemRequests[itemId] = true
    table.insert(self.itemRequests, itemId)
  end
end

function Client:after(seconds, callback)
  table.insert(self.timers, { due = self.time + math.max(seconds or 0, 0), order = self:nextOrder(), callback = callback })
end

-- Loading and logging in ---------------------------------------------------------------------

local function savedVariableNames(self)
  return (self.addonMetadata.SavedVariables or ""):gmatch("[^,%s]+")
end

function Client:loadAddon()
  local namespace = {}
  for _, path in ipairs(self.addonFiles) do
    local chunk, err = loadfile(path)
    if chunk then
      setfenv(chunk, self.env)
      self:call(chunk, self.addonName, namespace)
    else
      self.errorHandler(err)
    end
  end
  self.addonLoaded = true
  -- a variable with nothing stored keeps what the addon's files set
  for name in savedVariableNames(self) do
    local stored = self.savedVariables[name]
    if type(stored) == "table" then stored = copy(stored) end
    if stored ~= nil then self.env[name] = stored end
  end
  self:fireEvent("ADDON_LOADED", self.addonName)
end

-- Loads the addon and runs the login events, then one frame. `reloading` runs them the way a
-- /reload does.
function Client:login(reloading)
  self:loadAddon()
  self:fireEvent("PLAYER_LOGIN")
  self:fireEvent("PLAYER_ENTERING_WORLD", not reloading, reloading and true or false)
  self:nextFrame()
end

-- Ends the session the way logging out and /reload do: PLAYER_LOGOUT, then the client writes
-- the saved variables. Returns what it wrote, { [name] = value }.
function Client:logout()
  self:fireEvent("PLAYER_LOGOUT")
  local saved = {}
  for name in savedVariableNames(self) do
    local value = self.env[name]
    if type(value) == "table" then value = copy(value) end
    saved[name] = value
  end
  return saved
end

-- /reload: ends this session and returns a new, logged-in one for the same character, its bags,
-- gear, spells, macros and combat state (the server keeps those), with the saved variables this session wrote.
function Client:reload()
  local saved = self:logout()
  local knownSpells, petSpells = {}, {}
  for spellId in pairs(self.knownSpells) do table.insert(knownSpells, spellId) end
  for spellId in pairs(self.petSpells) do table.insert(petSpells, spellId) end
  local auras = {}
  for i, aura in ipairs(self.auras.player or {}) do auras[i] = aura.spellId end
  local client = Client.new({
    flavor = self.flavorName, locale = self.locale, class = self.class, faction = self.faction,
    instanceType = self.instanceType, mapId = self.mapId, bags = self.bags, items = self.items,
    equipped = self.equipped, spells = self.spells, knownSpells = knownSpells, petSpells = petSpells,
    auras = auras,
    savedVariables = saved, maxAccountMacros = self.maxAccountMacros, megaMacro = self.megaMacroNames,
  })
  -- the macro API holds on to the macros table, so fill it rather than replacing it
  local macros = copy(self.macros)
  client.macros.account, client.macros.character = macros.account, macros.character
  -- the server keeps the character in combat across the reload
  client.lockdown = self.lockdown
  client:login(true)
  return client
end

-- Events, frames and timers ------------------------------------------------------------------

-- Delivers an event to every frame registered for it, in registration order. A frame that
-- registered it with RegisterUnitEvent gets it only for its units (the first argument).
function Client:fireEvent(event, ...)
  if not self.events[event] then error("the " .. self.flavorName .. " client has no event " .. event, 2) end
  local unit = ...
  local receivers = {}
  for _, frame in ipairs(self.frames) do
    local order = Widgets.registrationOrder(frame, event, unit)
    if order then table.insert(receivers, { frame = frame, order = order }) end
  end
  table.sort(receivers, function(a, b) return a.order < b.order end)
  for _, receiver in ipairs(receivers) do
    -- a handler that ran earlier may have unregistered it
    if Widgets.registrationOrder(receiver.frame, event, unit) then
      Widgets.runScript(receiver.frame, "OnEvent", event, ...)
    end
  end
end

-- Draws one frame: the requested items arrive (GET_ITEM_INFO_RECEIVED), OnUpdate runs on every
-- visible frame, then the timers that are due. A timer started during this frame runs on a later
-- one, even with a delay of 0.
function Client:nextFrame(elapsed)
  elapsed = elapsed or FRAME_TIME
  self.time = self.time + elapsed
  local requested = {}
  for i, itemId in ipairs(self.itemRequests) do requested[i] = itemId end
  self.itemRequests = {}
  for _, itemId in ipairs(requested) do
    self.itemCache[itemId] = true
    self:fireEvent("GET_ITEM_INFO_RECEIVED", itemId, true)
  end
  local startedBefore = self.order
  local frames = {}
  for i, frame in ipairs(self.frames) do frames[i] = frame end
  for _, frame in ipairs(frames) do
    if Widgets.hasHandler(frame, "OnUpdate") and frame:IsVisible() then
      Widgets.runScript(frame, "OnUpdate", elapsed)
    end
  end
  local due, waiting = {}, {}
  for _, timer in ipairs(self.timers) do
    if timer.due <= self.time + 1e-9 and timer.order <= startedBefore then
      table.insert(due, timer)
    else
      table.insert(waiting, timer)
    end
  end
  self.timers = waiting
  table.sort(due, function(a, b)
    if a.due ~= b.due then return a.due < b.due end
    return a.order < b.order
  end)
  for _, timer in ipairs(due) do self:call(timer.callback) end
end

-- Lets `seconds` of game time pass, frame by frame.
function Client:advance(seconds)
  local frames = math.max(1, math.ceil(seconds / FRAME_TIME - 1e-6))
  for _ = 1, frames do self:nextFrame(seconds / frames) end
end

local function putInBags(client, itemId, count)
  client.bags[itemId] = math.max((client.bags[itemId] or 0) + count, 0)
  client:fireEvent("BAG_UPDATE", 0)
end

-- Puts items in the bags (a negative count takes them out) and fires BAG_UPDATE, then
-- BAG_UPDATE_DELAYED once the bags have settled, as the client does.
function Client:addToBags(itemId, count)
  putInBags(self, itemId, count)
  self:fireEvent("BAG_UPDATE_DELAYED")
end

-- Several bag changes the server sends over consecutive frames, as when looting a whole corpse:
-- `changes` is { { item =, count = }, ... }. Each fires BAG_UPDATE in its own frame, and
-- BAG_UPDATE_DELAYED fires once after the last.
function Client:changeBagsOverFrames(changes)
  for i, change in ipairs(changes) do
    if i > 1 then self:nextFrame() end
    putInBags(self, change.item, change.count)
  end
  self:fireEvent("BAG_UPDATE_DELAYED")
end

-- The player changes gear, `slots` is { [inventorySlot] = itemId or false for empty }: by hand
-- one slot, with an equipment set several at once. Each slot that changed fires
-- PLAYER_EQUIPMENT_CHANGED, all in the same frame.
function Client:equip(slots)
  local changed = {}
  for slot, itemId in pairs(slots) do
    itemId = itemId or nil
    if self.equipped[slot] ~= itemId then
      self.equipped[slot] = itemId
      table.insert(changed, slot)
    end
  end
  table.sort(changed)
  for _, slot in ipairs(changed) do
    self:fireEvent("PLAYER_EQUIPMENT_CHANGED", slot, self.equipped[slot] ~= nil)
  end
end

-- Auras ---------------------------------------------------------------------------------------

-- The spell's name in the client's locale, as C_Spell.GetSpellName and the auras report it: its
-- `names` entry for the locale, else its `name`, else "Spell <id>".
function Client:spellName(spellId)
  local spell = self.spells[spellId] or {}
  return spell.names and spell.names[self.locale] or spell.name or ("Spell " .. spellId)
end

-- Puts an aura on the unit without telling anyone; returns its AuraData.
function Client:addAura(unit, spellId)
  self.lastAuraInstance = self.lastAuraInstance + 1
  local spell = self.spells[spellId] or {}
  local aura = {
    auraInstanceID = self.lastAuraInstance, spellId = spellId,
    name = self:spellName(spellId), icon = spell.icon or Api.spellIcon(spellId),
    isHelpful = true, isHarmful = false, applications = 0, duration = 3600,
    expirationTime = self.time + 3600, sourceUnit = unit,
  }
  self.auras[unit] = self.auras[unit] or {}
  table.insert(self.auras[unit], aura)
  return aura
end

-- The unit ("player" by default, or "party1", "pet", ...) gains the buff of this spell, as from
-- eating, and the client fires UNIT_AURA with what was added.
function Client:gainAura(spellId, unit)
  unit = unit or "player"
  local aura = self:addAura(unit, spellId)
  self:fireEvent("UNIT_AURA", unit, { isFullUpdate = false, addedAuras = { copy(aura) } })
end

-- The unit's buff of this spell falls off (it expires, the player dies, ...), and the client
-- fires UNIT_AURA with the removed aura's instance ID.
function Client:loseAura(spellId, unit)
  unit = unit or "player"
  for position, aura in ipairs(self.auras[unit] or {}) do
    if aura.spellId == spellId then
      table.remove(self.auras[unit], position)
      self:fireEvent("UNIT_AURA", unit, { isFullUpdate = false, removedAuraInstanceIDs = { aura.auraInstanceID } })
      return
    end
  end
  error(unit .. " has no aura " .. tostring(spellId), 2)
end

-- The game hides auras from addons (an encounter, M+, PvP): the aura lookups return nothing and
-- C_Secrets.ShouldAurasBeSecret reports true until showAuras. ADDON_RESTRICTION_STATE_CHANGED
-- comes before the restriction becomes active and after it ends.
local ENCOUNTER = 1                         -- Enum.AddOnRestrictionType.Encounter
local INACTIVE, ACTIVATING = 0, 1           -- Enum.AddOnRestrictionState
function Client:hideAuras()
  self:fireEvent("ADDON_RESTRICTION_STATE_CHANGED", ENCOUNTER, ACTIVATING)
  self.aurasHidden = true
end

function Client:showAuras()
  self.aurasHidden = false
  self:fireEvent("ADDON_RESTRICTION_STATE_CHANGED", ENCOUNTER, INACTIVE)
end

-- The player learns a spell (a trainer, a talent) and the client fires SPELLS_CHANGED.
function Client:learnSpell(spellId)
  self.knownSpells[spellId] = true
  self:fireEvent("SPELLS_CHANGED")
end

-- The player picks or drops a talent in the talent window: its spell becomes known or unknown,
-- then the client fires SPELLS_CHANGED, plus TRAIT_CONFIG_UPDATED on the flavors that have it.
local function changeTalent(client, spellId, known)
  client.knownSpells[spellId] = known or nil
  client:fireEvent("SPELLS_CHANGED")
  if client.events.TRAIT_CONFIG_UPDATED then client:fireEvent("TRAIT_CONFIG_UPDATED", 1) end
end

function Client:pickTalent(spellId)
  changeTalent(self, spellId, true)
end

function Client:dropTalent(spellId)
  changeTalent(self, spellId, false)
end

-- The player deletes this macro in the macro window (/macro).
function Client:deleteMacro(name)
  for _, list in ipairs({ self.macros.account, self.macros.character }) do
    for position, macro in ipairs(list) do
      if macro.name == name then
        table.remove(list, position)
        return
      end
    end
  end
  error("no macro " .. tostring(name), 2)
end

-- Combat: PLAYER_REGEN_DISABLED fires before the lockdown starts, PLAYER_REGEN_ENABLED after
-- it ended, as in game.

function Client:enterCombat()
  self:fireEvent("PLAYER_REGEN_DISABLED")
  self.lockdown = true
end

function Client:leaveCombat()
  self.lockdown = false
  self:fireEvent("PLAYER_REGEN_ENABLED")
end

-- The settings panel ---------------------------------------------------------------------------

local function pathOf(category)
  local names = {}
  while category do
    table.insert(names, 1, category.name)
    category = category.parent
  end
  return names
end

-- The pages the settings panel's category list offers, each as its path: { "AutoPotion",
-- "AutoFood" } is AutoFood below AutoPotion.
function Client:settingsPages()
  local pages = {}
  for i, category in ipairs(self.settingsCategories) do pages[i] = pathOf(category) end
  return pages
end

-- Opens a page of the game's settings panel the way the player does, through the category list:
-- openSettings("AutoPotion", "AutoFood") opens AutoFood below AutoPotion.
function Client:openSettings(...)
  local path = table.concat({ ... }, " > ")
  for _, category in ipairs(self.settingsCategories) do
    if table.concat(pathOf(category), " > ") == path then
      self.displaySettingsCategory(category)
      return
    end
  end
  error("no settings page " .. path, 2)
end

-- Closes the game's settings panel; the page that was open stays its page for the next opening.
function Client:closeSettings()
  self.settingsPanel:Hide()
end

local function visibleCheckboxes(self)
  local category = self.displayedSettingsCategory()
  if not category then error("the settings panel isn't open", 3) end
  local boxes = {}
  for _, frame in ipairs(Widgets.descendants(category.frame)) do
    if frame:IsObjectType("CheckButton") and frame:IsVisible() then table.insert(boxes, frame) end
  end
  return boxes
end

-- The labels of the check boxes on the open settings page, top to bottom as created.
function Client:checkboxLabels()
  local labels = {}
  for _, box in ipairs(visibleCheckboxes(self)) do table.insert(labels, Widgets.checkboxLabel(box)) end
  return labels
end

local function checkbox(self, label)
  local found
  for _, box in ipairs(visibleCheckboxes(self)) do
    if Widgets.checkboxLabel(box) == label then
      if found then error('two check boxes say "' .. label .. '"', 3) end
      found = box
    end
  end
  if not found then error('no check box "' .. label .. '" on the open settings page', 3) end
  return found
end

-- Whether the check box with this label on the open settings page is ticked.
function Client:isChecked(label)
  return checkbox(self, label):GetChecked()
end

-- Whether the check box with this label on the open settings page can be clicked.
function Client:isEnabled(label)
  return checkbox(self, label):IsEnabled()
end

-- Clicks the check box with this label on the open settings page.
function Client:clickCheckbox(label)
  Widgets.click(checkbox(self, label))
end

-- Moves the mouse onto the check box with this label on the open settings page and off again.
-- Returns the lines of the tooltip it showed, nil when it showed none.
function Client:hoverCheckbox(label)
  local box = checkbox(self, label)
  local tooltip = self.env.GameTooltip
  tooltip:Hide()
  Widgets.runScript(box, "OnEnter", false)
  local lines = tooltip:IsShown() and Widgets.tooltipLines(tooltip) or nil
  Widgets.runScript(box, "OnLeave", false)
  return lines
end

-- Clicks the button (not a check box) that says `text` on the open settings page.
function Client:clickButton(text)
  local category = self.displayedSettingsCategory()
  if not category then error("the settings panel isn't open", 2) end
  for _, frame in ipairs(Widgets.descendants(category.frame)) do
    if frame:IsObjectType("Button") and not frame:IsObjectType("CheckButton") and frame:IsVisible()
        and frame:GetText() == text then
      Widgets.click(frame)
      return
    end
  end
  error('no button "' .. text .. '" on the open settings page', 2)
end

-- The icons the open settings page shows (FileDataIDs), top to bottom and left to right as
-- created: the healing-spell boxes' icons and the "Current Priority" preview.
function Client:shownIcons()
  local category = self.displayedSettingsCategory()
  if not category then error("the settings panel isn't open", 2) end
  local icons = {}
  for _, frame in ipairs(Widgets.descendants(category.frame)) do
    for _, texture in ipairs(Widgets.textures(frame)) do
      if texture:IsVisible() and type(texture:GetTexture()) == "number" then
        table.insert(icons, texture:GetTexture())
      end
    end
  end
  return icons
end

-- The "Current Priority" preview icons on the open settings page, left to right as the player
-- sees them: { icon = FileDataID, x =, y = } with the offset of each icon's top left corner.
-- A preview icon is a frame (not a button) that shows an icon and a tooltip on hover.
local function previewFrames(self)
  local category = self.displayedSettingsCategory()
  if not category then error("the settings panel isn't open", 3) end
  local found, root = {}, nil
  for _, frame in ipairs(Widgets.descendants(category.frame)) do
    if not frame:IsObjectType("Button") and frame:IsVisible() and Widgets.hasHandler(frame, "OnEnter") then
      for _, texture in ipairs(Widgets.textures(frame)) do
        if texture:IsVisible() and type(texture:GetTexture()) == "number" then
          local origin, x, y = Widgets.topLeftOffset(frame)
          if root and origin ~= root then error("the preview icons aren't laid out in one row", 3) end
          root = origin
          table.insert(found, { frame = frame, icon = texture:GetTexture(), x = x, y = y })
          break
        end
      end
    end
  end
  table.sort(found, function(a, b)
    if a.y ~= b.y then return a.y > b.y end
    return a.x < b.x
  end)
  return found
end

function Client:previewIcons()
  local icons = {}
  for i, found in ipairs(previewFrames(self)) do
    icons[i] = { icon = found.icon, x = found.x, y = found.y }
  end
  return icons
end

-- Moves the mouse onto the nth preview icon from the left and off again. Returns the lines of the
-- tooltip it showed, nil when it showed none.
function Client:hoverPreviewIcon(n)
  local found = previewFrames(self)[n]
  if not found then error("no preview icon " .. n, 2) end
  local tooltip = self.env.GameTooltip
  tooltip:Hide()
  Widgets.runScript(found.frame, "OnEnter", false)
  local lines = tooltip:IsShown() and Widgets.tooltipLines(tooltip) or nil
  Widgets.runScript(found.frame, "OnLeave", false)
  return lines
end

-- The player types a slash command in the chat box ("/ap debug"); the client runs the handler
-- an addon registered for it with SLASH_<KEY><n> and SlashCmdList[KEY].
function Client:typeCommand(line)
  local command, rest = line:match("^(%S+)%s*(.-)$")
  command = command:lower()
  for name, value in pairs(self.env) do
    local key = type(name) == "string" and name:match("^SLASH_(.-)%d+$")
    if key and type(value) == "string" and value:lower() == command and self.env.SlashCmdList[key] then
      self:call(self.env.SlashCmdList[key], rest, nil)
      return
    end
  end
  error("no slash command " .. command, 2)
end

-- What the player and the client see ---------------------------------------------------------

-- The body of the macro with this name, or nil when there's none.
function Client:macroText(name)
  local _, _, body = self.env.GetMacroInfo(name)
  return body
end

-- The code of the stub MegaMacro addon's global macro with this name, or nil when there's none.
function Client:megaMacroText(name)
  for _, macro in ipairs(self.env.MegaMacroGlobalData and self.env.MegaMacroGlobalData.Macros or {}) do
    if macro.DisplayName == name then return macro.Code end
  end
end

-- How often each of these macros was written (created or edited) since the client started,
-- { [name] = count }, blocked calls included.
function Client:macroWrites(names)
  local counts = {}
  for _, name in ipairs(names) do counts[name] = 0 end
  for _, call in ipairs(self.macroCalls) do
    local name = call.func == "EditMacro" and call.macro or call.name
    if counts[name] then counts[name] = counts[name] + 1 end
  end
  return counts
end

-- How often the addon called this API function since the client started, for the ones the fake
-- counts (C_Item.GetItemCount: every macro rebuild asks it for each candidate item;
-- C_UnitAuras.GetAuraDataBySpellName and GetPlayerAuraBySpellID: aura lookups by name and by ID;
-- C_Item.GetItemIconByID and C_Spell.GetSpellTexture: icon lookups, which only the settings
-- pages make).
function Client:apiCallCount(name)
  return self.apiCalls[name] or 0
end

-- Names of the globals that weren't there before the addon loaded, sorted.
function Client:addedGlobals()
  local added = {}
  for name in pairs(self.env) do
    if not self.globalsBeforeLoad[name] then table.insert(added, name) end
  end
  table.sort(added, function(a, b) return tostring(a) < tostring(b) end)
  return added
end

function Client:isFrame(value)
  return Widgets.isWidget(value) and value:IsObjectType("Frame")
end

return Client
