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

-- options:
--   flavor           "retail" (default), "classic" or "forever"
--   class            the player's class token, "WARRIOR" by default
--   faction          "Alliance" (default) or "Horde"
--   instanceType     what IsInInstance reports: "none" (default), "pvp", "party", ...
--   mapId            the player's map, 1429 (Elwynn Forest) by default
--   bags             { [itemId] = count }
--   items            { [itemId] = { name =, icon =, spell = { name =, id = } } }, all optional
--   equipped         { [inventorySlot] = itemId }
--   spells           { [spellId] = { name =, icon =, baseCooldown = } }, all optional
--   knownSpells      { spellId, ... } in the player's spell book; petSpells the same for the pet
--   savedVariables   { [name] = value } as stored by an earlier session
function Client.new(options)
  options = options or {}
  local flavorName = options.flavor or "retail"
  local flavor = Client.FLAVORS[flavorName]
  if not flavor then error("unknown flavor " .. tostring(flavorName), 2) end

  local self = setmetatable({
    flavorName = flavorName,
    flavor = flavor,
    addonName = "AutoPotion",
    addonLoaded = false,
    class = options.class or "WARRIOR",
    faction = options.faction or "Alliance",
    instanceType = options.instanceType or "none",
    mapId = options.mapId or 1429,
    bags = copy(options.bags or {}),
    items = copy(options.items or {}),
    equipped = copy(options.equipped or {}),
    spells = copy(options.spells or {}),
    knownSpells = toSet(options.knownSpells),
    petSpells = toSet(options.petSpells),
    savedVariables = copy(options.savedVariables or {}),
    macros = { account = {}, character = {} },
    -- records
    errors = {},
    printed = {},
    macroCalls = {},
    blockedActions = {},
    -- internals
    frames = {},
    timers = {},
    settingsCategories = {},
    time = 0,
    order = 0,
    lockdown = false,
  }, Client)

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
-- gear, spells and macros (the server keeps those), with the saved variables this session wrote.
function Client:reload()
  local saved = self:logout()
  local knownSpells, petSpells = {}, {}
  for spellId in pairs(self.knownSpells) do table.insert(knownSpells, spellId) end
  for spellId in pairs(self.petSpells) do table.insert(petSpells, spellId) end
  local client = Client.new({
    flavor = self.flavorName, class = self.class, faction = self.faction,
    instanceType = self.instanceType, mapId = self.mapId, bags = self.bags, items = self.items,
    equipped = self.equipped, spells = self.spells, knownSpells = knownSpells, petSpells = petSpells,
    savedVariables = saved,
  })
  client.macros = copy(self.macros)
  client:login(true)
  return client
end

-- Events, frames and timers ------------------------------------------------------------------

-- Delivers an event to every frame registered for it, in registration order.
function Client:fireEvent(event, ...)
  local receivers = {}
  for _, frame in ipairs(self.frames) do
    local order = Widgets.registrationOrder(frame, event)
    if order then table.insert(receivers, { frame = frame, order = order }) end
  end
  table.sort(receivers, function(a, b) return a.order < b.order end)
  for _, receiver in ipairs(receivers) do
    -- a handler that ran earlier may have unregistered it
    if Widgets.registrationOrder(receiver.frame, event) then
      Widgets.runScript(receiver.frame, "OnEvent", event, ...)
    end
  end
end

-- Draws one frame: OnUpdate on every visible frame, then the timers that are due. A timer
-- started during this frame runs on a later one, even with a delay of 0.
function Client:nextFrame(elapsed)
  elapsed = elapsed or FRAME_TIME
  self.time = self.time + elapsed
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

-- Clicks the check box with this label on the open settings page.
function Client:clickCheckbox(label)
  Widgets.click(checkbox(self, label))
end

-- What the player and the client see ---------------------------------------------------------

-- The body of the macro with this name, or nil when there's none.
function Client:macroText(name)
  local _, _, body = self.env.GetMacroInfo(name)
  return body
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
