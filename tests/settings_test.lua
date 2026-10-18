-- Settings across /reload, login and upgrades: what the player set stays set, the boxes show
-- what the macros use, and saved settings from other versions load without losing anything.
local Client = require("fake.client")
local copy = require("fake.api").copyTable

local WELL_FED = 19705 -- the food buff


-- The fresh install's settings with every box the other way round and two of the default
-- healing spells left, in reverse order.
local function changedSettings(defaults)
  local settings = {}
  for key, value in pairs(defaults) do
    if type(value) == "boolean" then value = not value end
    settings[key] = value
  end
  settings.activatedSpells = { defaults.activatedSpells[3], defaults.activatedSpells[1] }
  return settings
end

local MACRO_NAMES = { "AutoPotion", "AutoFood", "AutoDrink", "AutoBandage", "AutoManaPotion" }

local function macros(client)
  local texts = {}
  for _, name in ipairs(MACRO_NAMES) do texts[name] = client:macroText(name) end
  return texts
end

local function sameMacros(a, b)
  for _, name in ipairs(MACRO_NAMES) do
    if a[name] ~= b[name] then return false end
  end
  return true
end

-- A character for whom every option on the settings pages changes a macro: no item that a
-- better one would hide (no regular health potion on Retail, so the Withering potions get in),
-- buff food ahead of normal food and the food buff, so that "only when the buff is missing" puts
-- buff food last, a mana potion that only counts as a Rejuvenation potion, and a
-- spell with a cooldown for "reset on the shortest cooldown". The Retail one is a Warlock, the
-- only class with the Soulburn box, and wears the Heartseeking Health Injector tinker.
local CLASSIC_ERA_CHARACTER = {
  class = "WARRIOR",
  bags = {
    [9421] = 1,  -- Major Healthstone
    [13446] = 5, -- Major Healing Potion
    [13928] = 5, -- Grilled Squid (buff food)
    [8952] = 5,  -- Roasted Quail
    [18253] = 5, -- Major Rejuvenation Potion
  },
  spells = { [12975] = { baseCooldown = 180000 }, [WELL_FED] = { name = "Well Fed" } }, -- Last Stand
  knownSpells = { 12975 },
  auras = { WELL_FED },
}
local HELM_WITH_TINKER = 1 -- any helm, the tinker is its use effect
local CHARACTERS = {
  retail = {
    class = "WARLOCK",
    bags = {
      [5512] = 1,   -- Healthstone
      [241306] = 5, -- Refreshing Serum (R2), a Cavedweller's Delight and a Rejuvenation potion
      [191371] = 5, -- Potion of Withering Vitality (R3)
      [207041] = 5, -- Potion of Withering Dreams (R3)
      [242747] = 5, -- Hearty Royal Roast (buff food)
      [264992] = 5, -- Blood Knight Burger
    },
    items = { [HELM_WITH_TINKER] = { spell = { name = "Heartseeking Health Injector", id = 452767 } } },
    equipped = { [1] = HELM_WITH_TINKER },
    spells = { [108416] = { baseCooldown = 60000 }, [WELL_FED] = { name = "Well Fed" } }, -- Dark Pact
    knownSpells = { 108416, 385899 },                 -- Dark Pact, Soulburn
    auras = { WELL_FED },
  },
  classic = CLASSIC_ERA_CHARACTER,
  forever = CLASSIC_ERA_CHARACTER,
}

-- The boxes for a spell that aren't named after it, and their spell.
local SPELL_BOXES = { ["Use Rapid Regeneration (Troll racial) before bandages"] = 1260270 }

-- The character for the check box with this label: a spell's box (a healing spell's is named
-- "Spell <id>", the name the fake client gives spells) only changes the macro for a character
-- who knows it.
local function characterFor(flavor, label)
  local options = copy(CHARACTERS[flavor])
  options.flavor = flavor
  options.knownSpells = options.knownSpells or {}
  local spellId = SPELL_BOXES[label] or label:match("^Spell (%d+)$")
  if spellId then table.insert(options.knownSpells, tonumber(spellId)) end
  return options
end

-- The box each box that refines another needs ticked before it can be clicked.
local REFINES = { ["Only when the buff is missing"] = "Include Buff Food" }

-- The saved settings a session that starts with `stored` leaves behind.
local function settingsAfterSession(flavor, stored)
  local client = Client.new({ flavor = flavor, savedVariables = { HAMDB = stored } })
  client:login()
  return client:logout().HAMDB
end

-- What a fresh install stores at the end of its first session.
local function freshInstallSettings(flavor)
  return settingsAfterSession(flavor, nil)
end

test("retail: unticking Cavedweller's Delight stays in effect after a reload", function()
  local client = Client.new({
    flavor = "retail",
    bags = {
      [5512] = 1,   -- Healthstone
      [212244] = 5, -- Cavedweller's Delight (R3)
    },
  })
  client:login()
  client:openSettings("AutoPotion", "AutoPotion")
  -- the box for Cavedweller's Delight and Refreshing Serum, which replaced it
  client:clickCheckbox("Refreshing Serum")

  client = client:reload()
  client:openSettings("AutoPotion", "AutoPotion")
  assertEqual(client:isChecked("Refreshing Serum"), false)
  assertEqual(client:macroText("AutoPotion"), "#showtooltip \n/castsequence [@player] reset=combat item:5512")
end)

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": saved settings missing a key get it at its default and keep every other value", function()
    local defaults = freshInstallSettings(flavor)
    local stored = changedSettings(defaults)
    for key, default in pairs(defaults) do
      local withoutKey = copy(stored)
      withoutKey[key] = nil
      local expected = copy(stored)
      expected[key] = default
      assertEqual(settingsAfterSession(flavor, withoutKey), expected, "saved settings without " .. key)
    end
  end)
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": saved settings from a newer version are left untouched", function()
    local defaults = freshInstallSettings(flavor)
    local stored = changedSettings(defaults)
    stored.version = defaults.version + 1
    stored.stopCast = nil -- moved somewhere else in that version
    stored.newerOption = "on"
    local client = Client.new({ flavor = flavor, savedVariables = { HAMDB = copy(stored) } })
    client:login()
    assertEqual(client:logout().HAMDB, stored)
    assertEqual(#client.errors, 0, table.concat(client.errors, "\n\n"))
  end)
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": saved settings without a healing-spell list get the default list and keep everything else", function()
    local defaults = freshInstallSettings(flavor)
    -- as stored before the list and the version existed, with a key those versions had
    local stored = changedSettings(defaults)
    stored.activatedSpells = nil
    stored.version = nil
    stored.renewal = false
    local expected = copy(stored)
    expected.activatedSpells = defaults.activatedSpells
    expected.version = defaults.version
    assertEqual(settingsAfterSession(flavor, stored), expected)
  end)
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": after a reload every check box on every settings page shows what the macros use", function()
    local player = Client.new(characterFor(flavor, ""))
    player:login()
    for _, page in ipairs(player:settingsPages()) do
      player:openSettings(unpack(page))
      for _, label in ipairs(player:checkboxLabels()) do
        local box = table.concat(page, " > ") .. ": " .. label
        local client = Client.new(characterFor(flavor, label))
        client:login()
        client:openSettings(unpack(page))
        if not client:isEnabled(label) then
          client:clickCheckbox(REFINES[label])
          client:nextFrame()
        end
        local before = macros(client)
        client:clickCheckbox(label)
        client:nextFrame()
        local clicked = { checked = client:isChecked(label), macros = macros(client) }
        assertEqual(sameMacros(clicked.macros, before), false, box .. " changes no macro for this character")

        client = client:reload()
        client:openSettings(unpack(page))
        assertEqual({ checked = client:isChecked(label), macros = macros(client) }, clicked, box .. " after the reload")
      end
    end
  end)
end

-- The check boxes on every settings page, { ["page > path"] = { [label] = checked } }, and the macros.
local function whatThePlayerSees(client)
  local boxes = {}
  for _, page in ipairs(client:settingsPages()) do
    client:openSettings(unpack(page))
    local shown = {}
    for _, label in ipairs(client:checkboxLabels()) do shown[label] = client:isChecked(label) end
    boxes[table.concat(page, " > ")] = shown
  end
  return { boxes = boxes, macros = macros(client) }
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": settings a newer version's saved settings lack show and work as on a fresh install", function()
    local fresh = Client.new(characterFor(flavor, ""))
    fresh:login()
    local character = characterFor(flavor, "")
    character.savedVariables = { HAMDB = { version = freshInstallSettings(flavor).version + 1 } }
    local newer = Client.new(character)
    newer:login()
    assertEqual(whatThePlayerSees(newer), whatThePlayerSees(fresh))
    assertEqual(#newer.errors, 0, table.concat(newer.errors, "\n\n"))
  end)
end
