-- Loading the addon and logging in, on every flavor the fake client models.
local Client = require("fake.client")

-- One of each consumable the macros pick from, with item IDs from the flavor's client data
-- (wow-data: wow.py item), and the macros the player should then have.
local CLASSIC_ERA_BAGS = {
  bags = {
    [9421] = 1,  -- Major Healthstone
    [13446] = 5, -- Major Healing Potion
    [8076] = 20, -- Conjured Sweet Roll
    [8079] = 20, -- Conjured Crystal Water
    [14530] = 10, -- Heavy Runecloth Bandage
    [13444] = 5, -- Major Mana Potion
  },
  macros = {
    AutoPotion = "#showtooltip \n/castsequence [@player] reset=combat item:9421, item:13446",
    AutoFood = "#showtooltip\n/use [@player] item:8076",
    AutoDrink = "#showtooltip\n/use [@player] item:8079",
    AutoBandage = "#showtooltip\n/use [@player] item:14530",
    AutoManaPotion = "#showtooltip\n/use item:13444",
  },
}

local CASES = {
  retail = {
    bags = {
      [5512] = 1,    -- Healthstone
      [244838] = 5,  -- Invigorating Healing Potion (R2)
      [265096] = 20, -- Conjured Souffle
      [265099] = 20, -- Conjured Tea
      [239713] = 10, -- Bright Linen Bandage (R2)
      [241300] = 5,  -- Lightfused Mana Potion (R2)
    },
    macros = {
      AutoPotion = "#showtooltip \n/castsequence [@player] reset=combat item:5512, item:244838",
      AutoFood = "#showtooltip\n/use [@player] item:265096",
      AutoDrink = "#showtooltip\n/use [@player] item:265099",
      AutoBandage = "#showtooltip\n/use [@player] item:239713",
      AutoManaPotion = "#showtooltip\n/use item:241300",
    },
  },
  classic = CLASSIC_ERA_BAGS,
  forever = CLASSIC_ERA_BAGS,
}

-- The globals AutoPotion may add: its saved settings, slash commands and key binding names,
-- LibStub (the one registry every addon's embedded libraries share) and its own named frames,
-- which the Classic scroll-frame template needs to find its scroll bar.
local function isOwnGlobal(client, name)
  return name == "HAMDB"
    or name:match("^SLASH_HAM%d+$") ~= nil
    or name:match("^BINDING_NAME_") ~= nil
    or name == "LibStub"
    or (name:match("^AutoPotion") ~= nil and client:isFrame(client.env[name]))
end

local function loggedIn(flavor)
  local client = Client.new({ flavor = flavor, bags = CASES[flavor].bags })
  client:login()
  return client
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": loads and logs in without Lua errors", function()
    local client = loggedIn(flavor)
    assertEqual(#client.errors, 0, table.concat(client.errors, "\n\n"))
  end)

  test(flavor .. ": after login the five macros use the best item in the bags", function()
    local client = loggedIn(flavor)
    local macros = {}
    for name in pairs(CASES[flavor].macros) do macros[name] = client:macroText(name) end
    assertEqual(macros, CASES[flavor].macros)
  end)

  test(flavor .. ": logging in out of combat causes no blocked actions", function()
    local client = loggedIn(flavor)
    assertEqual(client.blockedActions, {})
  end)

  test(flavor .. ": adds no globals but saved settings, slash commands, binding names and its frames", function()
    local client = loggedIn(flavor)
    local others = {}
    for _, name in ipairs(client:addedGlobals()) do
      if not isOwnGlobal(client, name) then table.insert(others, name) end
    end
    assertEqual(others, {})
  end)
end
