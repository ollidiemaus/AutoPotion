-- "Reset to Default" on the AutoPotion page: the settings, every check box on every settings page
-- and the macros go back to what a fresh install has, at once, in combat too.
local Client = require("fake.client")
local copy = require("fake.api").copyTable

local MACRO_NAMES = { "AutoPotion", "AutoFood", "AutoDrink", "AutoBandage", "AutoManaPotion" }

local function macros(client)
  local texts = {}
  for _, name in ipairs(MACRO_NAMES) do texts[name] = client:macroText(name) end
  return texts
end

-- The check boxes on every settings page, { ["page > path"] = { [label] = checked } }.
local function checkboxes(client)
  local boxes = {}
  for _, page in ipairs(client:settingsPages()) do
    client:openSettings(unpack(page))
    local shown = {}
    for _, label in ipairs(client:checkboxLabels()) do shown[label] = client:isChecked(label) end
    boxes[table.concat(page, " > ")] = shown
  end
  return boxes
end

-- A character for whom every option on the settings pages changes a macro (see settings_test).
local CLASSIC_ERA_CHARACTER = {
  class = "WARRIOR",
  bags = {
    [9421] = 1,  -- Major Healthstone
    [13446] = 5, -- Major Healing Potion
    [13928] = 5, -- Grilled Squid (buff food)
    [18253] = 5, -- Major Rejuvenation Potion
  },
  spells = { [12975] = { baseCooldown = 180000 } }, -- Last Stand
  knownSpells = { 12975 },
}
local HELM_WITH_TINKER = 1
local CHARACTERS = {
  retail = {
    class = "WARLOCK",
    bags = {
      [5512] = 1,   -- Healthstone
      [241306] = 5, -- Refreshing Serum (R2), a Cavedweller's Delight and a Rejuvenation potion
      [191371] = 5, -- Potion of Withering Vitality (R3)
      [207041] = 5, -- Potion of Withering Dreams (R3)
      [242747] = 5, -- Hearty Royal Roast (buff food)
    },
    items = { [HELM_WITH_TINKER] = { spell = { name = "Heartseeking Health Injector", id = 452767 } } },
    equipped = { [1] = HELM_WITH_TINKER },
    spells = { [108416] = { baseCooldown = 60000 } }, -- Dark Pact
    knownSpells = { 108416, 385899 },                 -- Dark Pact, Soulburn
  },
  classic = CLASSIC_ERA_CHARACTER,
  forever = CLASSIC_ERA_CHARACTER,
}

local function character(flavor, savedVariables)
  local options = copy(CHARACTERS[flavor])
  options.flavor = flavor
  options.savedVariables = savedVariables
  return options
end

-- A fresh install for this character, logged in.
local function freshInstall(flavor)
  local client = Client.new(character(flavor))
  client:login()
  return client
end

-- The character logged in with every box the other way round from a fresh install and two of
-- the default healing spells left, then the AutoPotion page opened.
local function changedEverything(flavor)
  local defaults = freshInstall(flavor):logout().HAMDB
  local settings = {}
  for key, value in pairs(defaults) do
    if type(value) == "boolean" then value = not value end
    settings[key] = value
  end
  settings.activatedSpells = { defaults.activatedSpells[3], defaults.activatedSpells[1] }
  local client = Client.new(character(flavor, { HAMDB = settings }))
  client:login()
  client:openSettings("AutoPotion", "AutoPotion")
  client:nextFrame()
  return client
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": Reset out of combat puts the macros, every check box and the saved settings back to a fresh install's", function()
    local fresh = freshInstall(flavor)
    local expectedMacros = macros(fresh)
    local client = changedEverything(flavor)
    -- the macros the settings change for this character
    for _, name in ipairs({ "AutoPotion", "AutoFood", "AutoManaPotion" }) do
      assertEqual(client:macroText(name) ~= expectedMacros[name], true, name .. " is the fresh install's before Reset")
    end

    client:clickButton("Reset to Default")
    client:nextFrame()
    -- before opening any other page, which would rebuild the macros on its own
    assertEqual(macros(client), expectedMacros, "macros")
    assertEqual(checkboxes(client), checkboxes(fresh), "check boxes")
    assertEqual(client:logout().HAMDB, fresh:logout().HAMDB, "saved settings")
    assertEqual(#client.errors, 0, table.concat(client.errors, "\n\n"))
  end)
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": Reset in combat is not blocked, shows at once and reaches the macros when combat ends", function()
    local fresh = freshInstall(flavor)
    fresh:openSettings("AutoPotion", "AutoPotion")
    local client = changedEverything(flavor)

    client:enterCombat()
    client:clickButton("Reset to Default")
    assertEqual(client:shownIcons(), fresh:shownIcons(), "preview")
    client:advance(1)
    assertEqual(client.blockedActions, {})

    client:leaveCombat()
    assertEqual(macros(client), macros(fresh))
    assertEqual(#client.errors, 0, table.concat(client.errors, "\n\n"))
  end)
end
