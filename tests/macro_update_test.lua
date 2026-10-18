-- When the macros get rewritten: once per batch of changes, and never during combat lockdown,
-- where rewriting them is a blocked action. What the player changes in combat reaches the
-- macros as soon as combat ends.
local Client = require("fake.client")
local Api = require("fake.api")

local MACRO_NAMES = { "AutoPotion", "AutoFood", "AutoDrink", "AutoBandage", "AutoManaPotion" }

local function macroWrites(client) return client:macroWrites(MACRO_NAMES) end

local function everyMacro(count)
  local counts = {}
  for _, name in ipairs(MACRO_NAMES) do counts[name] = count end
  return counts
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": logging in writes each macro exactly once", function()
    local client = Client.new({ flavor = flavor })
    client:login()
    assertEqual(macroWrites(client), everyMacro(1))
  end)
end

local function macros(client)
  local texts = {}
  for _, name in ipairs(MACRO_NAMES) do texts[name] = client:macroText(name) end
  return texts
end

-- A healthstone and a potion, so "Low Priority Healthstones" swaps them in the preview and the
-- macro, and on Retail a Warlock who knows Dark Pact, a healing spell with a check box.
local CLASSIC_ERA_CHARACTER = {
  bags = {
    [9421] = 1,  -- Major Healthstone
    [13446] = 5, -- Major Healing Potion
  },
  healthstone = 9421,
  potion = 13446,
}
local CHARACTERS = {
  retail = {
    class = "WARLOCK",
    bags = {
      [5512] = 1,   -- Healthstone
      [244838] = 5, -- Invigorating Healing Potion (R2)
    },
    knownSpells = { 108416 }, -- Dark Pact
    healthstone = 5512,
    potion = 244838,
  },
  classic = CLASSIC_ERA_CHARACTER,
  forever = CLASSIC_ERA_CHARACTER,
}
local DARK_PACT = 108416

local function loggedIn(flavor)
  local character = CHARACTERS[flavor]
  local client = Client.new({
    flavor = flavor, class = character.class, bags = character.bags, knownSpells = character.knownSpells,
  })
  client:login()
  return client
end

-- The healthstone and the potion in the order the open page's preview shows them.
local function previewedItems(flavor, client)
  local character = CHARACTERS[flavor]
  local names = {
    [Api.itemIcon(character.healthstone)] = "healthstone",
    [Api.itemIcon(character.potion)] = "potion",
  }
  local shown = {}
  for _, icon in ipairs(client:shownIcons()) do
    if names[icon] then table.insert(shown, names[icon]) end
  end
  return shown
end

-- The macros after clicking this box on the AutoPotion page out of combat.
local function macrosAfterClickingOutOfCombat(flavor, label)
  local client = loggedIn(flavor)
  client:openSettings("AutoPotion", "AutoPotion")
  client:clickCheckbox(label)
  client:nextFrame()
  return macros(client)
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": ticking an option in combat is not blocked, shows at once and reaches the macro when combat ends", function()
    local client = loggedIn(flavor)
    client:openSettings("AutoPotion", "AutoPotion")
    assertEqual(previewedItems(flavor, client), { "healthstone", "potion" })
    local before = macros(client)

    client:enterCombat()
    client:clickCheckbox("Low Priority Healthstones")
    assertEqual(previewedItems(flavor, client), { "potion", "healthstone" })
    client:advance(1)
    assertEqual(client.blockedActions, {})
    assertEqual(macros(client), before)

    client:leaveCombat()
    local character = CHARACTERS[flavor]
    assertEqual(client:macroText("AutoPotion"):match("item:.*$"),
      "item:" .. character.potion .. ", item:" .. character.healthstone)
  end)
end

test("retail: unticking a healing spell in combat is not blocked, shows at once and reaches the macro when combat ends", function()
  local label = "Spell " .. DARK_PACT
  local expected = macrosAfterClickingOutOfCombat("retail", label)
  local client = loggedIn("retail")
  client:openSettings("AutoPotion", "AutoPotion")
  local function darkPactIcons()
    local count = 0
    for _, icon in ipairs(client:shownIcons()) do
      if icon == Api.spellIcon(DARK_PACT) then count = count + 1 end
    end
    return count
  end
  -- its check box and its place in the preview
  assertEqual(darkPactIcons(), 2)
  local before = macros(client)

  client:enterCombat()
  client:clickCheckbox(label)
  assertEqual(darkPactIcons(), 1)
  client:advance(1)
  assertEqual(client.blockedActions, {})
  assertEqual(macros(client), before)

  client:leaveCombat()
  assertEqual(macros(client), expected)
end)

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": opening each settings page in combat is not blocked and shows the current preview", function()
    local reference = loggedIn(flavor)
    local client = loggedIn(flavor)
    client:enterCombat()
    for _, page in ipairs(client:settingsPages()) do
      reference:openSettings(unpack(page))
      client:openSettings(unpack(page))
      assertEqual(client:shownIcons(), reference:shownIcons(), table.concat(page, " > "))
    end
    client:advance(1)
    assertEqual(client.blockedActions, {})
  end)
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": a /reload in combat is not blocked and builds the macros when combat ends", function()
    local expected = macros(loggedIn(flavor))
    local client = loggedIn(flavor)
    client:enterCombat()
    client = client:reload()
    client:advance(1)
    assertEqual(client.blockedActions, {})

    client:leaveCombat()
    assertEqual(macros(client), expected)
    assertEqual(macroWrites(client), everyMacro(1))
  end)
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": several update requests in one frame rewrite a changed macro once", function()
    local client = loggedIn(flavor)
    local before = macroWrites(client)
    client:fireEvent("PLAYER_ENTERING_WORLD", false, false) -- zoning
    client:fireEvent("UNIT_PET", "player")
    client:openSettings("AutoPotion", "AutoPotion")
    client:clickCheckbox("Low Priority Healthstones")
    client:clickCheckbox("Include /stopcasting in the macro")
    client:advance(1)
    local after = macroWrites(client)
    for name, count in pairs(after) do after[name] = count - before[name] end
    -- both boxes change only the AutoPotion macro
    local expected = everyMacro(0)
    expected.AutoPotion = 1
    assertEqual(after, expected)
  end)
end
