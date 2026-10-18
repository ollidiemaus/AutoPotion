-- How the macros get written: only when their text changes (every write makes the action bars
-- refresh), and a macro that can't be created because the general macro slots are full is
-- reported to the player instead of failing silently.
local Client = require("fake.client")

local MACRO_NAMES = { "AutoPotion", "AutoFood", "AutoDrink", "AutoBandage", "AutoManaPotion" }

local function macroWrites(client) return client:macroWrites(MACRO_NAMES) end

local function everyMacro(count)
  local counts = {}
  for _, name in ipairs(MACRO_NAMES) do counts[name] = count end
  return counts
end

-- Something that makes the addon rebuild its macros without changing what's in them.
local function rebuild(client)
  client:fireEvent("PLAYER_ENTERING_WORLD", false, false) -- zoning
  client:nextFrame()
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": rebuilding with unchanged bags and settings writes each macro once", function()
    local client = Client.new({ flavor = flavor })
    client:login()
    rebuild(client)
    rebuild(client)
    assertEqual(macroWrites(client), everyMacro(1))
    assertEqual(client.errors, {})
  end)
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": looting a bandage rewrites only the bandage macro", function()
    local client = Client.new({ flavor = flavor })
    client:login()
    client:addToBags(1251, 5) -- Linen Bandage
    client:nextFrame()
    local expected = everyMacro(1)
    expected.AutoBandage = 2
    assertEqual(macroWrites(client), expected)
    assertEqual(client:macroText("AutoBandage"):match("item:%d+"), "item:1251")
  end)

  test(flavor .. ": changing a setting rewrites only the macros it changes", function()
    local client = Client.new({ flavor = flavor })
    client:login()
    client:openSettings("AutoPotion", "AutoPotion")
    client:clickCheckbox("Include /stopcasting in the macro")
    client:nextFrame()
    local expected = everyMacro(1)
    expected.AutoPotion = 2
    assertEqual(macroWrites(client), expected)
  end)
end

-- General macros the player made, enough to leave `free` of the client's 120 slots.
local function playerMacros(free)
  local names = {}
  for i = 1, 120 - free do names[i] = "Mine " .. i end
  return names
end

-- The printed lines about this macro.
local function linesAbout(client, name)
  local lines = {}
  for _, line in ipairs(client.printed) do
    if line:find(" " .. name .. " macro", 1, true) then table.insert(lines, line) end
  end
  return lines
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": with the general macro slots full, each missing macro is reported once and the others still update", function()
    -- room for two: AutoPotion and AutoBandage are built first and get them
    local client = Client.new({ flavor = flavor, accountMacros = playerMacros(2) })
    client:login()
    rebuild(client)
    client:addToBags(1251, 5) -- Linen Bandage
    client:nextFrame()

    assertEqual(client.errors, {})
    for _, name in ipairs({ "AutoFood", "AutoDrink", "AutoManaPotion" }) do
      assertEqual(client:macroText(name), nil, name)
      local lines = linesAbout(client, name)
      assertEqual(#lines, 1, name .. " reported once")
      assertEqual(lines[1]:find("full") ~= nil, true, lines[1])
    end
    assertEqual(client:macroText("AutoPotion") ~= nil, true)
    assertEqual(client:macroText("AutoBandage"):match("item:%d+"), "item:1251")
    assertEqual(linesAbout(client, "AutoPotion"), {})
  end)

  test(flavor .. ": a macro that didn't fit is created once the player frees a slot", function()
    local client = Client.new({ flavor = flavor, accountMacros = playerMacros(0) })
    client:login()
    assertEqual(client:macroText("AutoPotion"), nil)
    client:deleteMacro("Mine 1")
    rebuild(client)
    assertEqual(client:macroText("AutoPotion") ~= nil, true)
    assertEqual(client.errors, {})
  end)

  test(flavor .. ": a macro API failure for another reason reaches the error handler", function()
    local client = Client.new({ flavor = flavor })
    client.macroApiError = "EditMacro(): something went wrong"
    client:login()
    assertEqual(#client.errors > 0, true)
    assertEqual(client.errors[1]:find("something went wrong", 1, true) ~= nil, true, client.errors[1])
  end)
end

-- MegaMacro is only checked on Retail.
test("retail: with MegaMacro, rebuilding with unchanged bags and settings writes each macro once", function()
  local client = Client.new({ megaMacro = MACRO_NAMES })
  client:login()
  rebuild(client)
  rebuild(client)
  assertEqual(macroWrites(client), everyMacro(1))
  assertEqual(client.macros.account, {})
  assertEqual(client.errors, {})

  client:addToBags(1251, 5) -- Linen Bandage
  client:nextFrame()
  local expected = everyMacro(1)
  expected.AutoBandage = 2
  assertEqual(macroWrites(client), expected)
  assertEqual(client:megaMacroText("AutoBandage"):match("item:%d+"), "item:1251")
end)
