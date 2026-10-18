-- What the macros do when the bags or pets change: a bag change reaches the macros as soon as
-- the client reports the bags settled (BAG_UPDATE_DELAYED), and only the player's own pet
-- makes the addon look at its macros again.
local Client = require("fake.client")

local MACRO_NAMES = { "AutoPotion", "AutoFood", "AutoDrink", "AutoBandage", "AutoManaPotion" }

-- The best and the second-best healing potion of each flavor (wow-data: wow.py item).
local CLASSIC_ERA_POTIONS = { best = 13446, next = 3928 } -- Major, Superior Healing Potion
local POTIONS = {
  retail = { best = 244838, next = 244835 }, -- Invigorating Healing Potion R2, R1
  classic = CLASSIC_ERA_POTIONS,
  forever = CLASSIC_ERA_POTIONS,
}

local function potionInMacro(client) return client:macroText("AutoPotion"):match("item:(%d+)") end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": a looted potion is in the macro the frame after the bags settle", function()
    local client = Client.new({ flavor = flavor })
    client:login()
    client:addToBags(POTIONS[flavor].best, 1)
    client:nextFrame()
    assertEqual(potionInMacro(client), tostring(POTIONS[flavor].best))
  end)
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": using up the last potion puts the next-best one in the macro the frame after", function()
    local potions = POTIONS[flavor]
    local client = Client.new({ flavor = flavor, bags = { [potions.best] = 1, [potions.next] = 3 } })
    client:login()
    assertEqual(potionInMacro(client), tostring(potions.best))
    client:addToBags(potions.best, -1)
    client:nextFrame()
    assertEqual(potionInMacro(client), tostring(potions.next))
  end)
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": bag changes over several frames rewrite the macro once, after the last", function()
    local potions = POTIONS[flavor]
    local client = Client.new({ flavor = flavor })
    client:login()
    local before = client:macroWrites(MACRO_NAMES)
    -- the macro would change twice if each change were acted on
    client:changeBagsOverFrames({ { item = potions.next, count = 1 }, { item = potions.best, count = 1 } })
    client:nextFrame()
    assertEqual(client:macroWrites(MACRO_NAMES).AutoPotion - before.AutoPotion, 1)
    assertEqual(potionInMacro(client), tostring(potions.best))
  end)
end

local DESPERATE_PRAYER = 19236 -- rank 2 on Classic Era and Forever

-- A Priest who has just learned Desperate Prayer. The addon doesn't watch for learned spells, so
-- the macros show whether a later event made it rebuild them.
local function priestWhoLearnedASpell(flavor)
  local client = Client.new({ flavor = flavor, class = "PRIEST", bags = { [POTIONS[flavor].best] = 1 } })
  client:login()
  client:learnSpell(DESPERATE_PRAYER)
  client:nextFrame()
  return client
end

local function macros(client)
  local texts = {}
  for _, name in ipairs(MACRO_NAMES) do texts[name] = client:macroText(name) end
  return texts
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": group members summoning or dismissing pets don't touch the macros", function()
    local client = priestWhoLearnedASpell(flavor)
    local before, writesBefore = macros(client), client:macroWrites(MACRO_NAMES)
    for _, unit in ipairs({ "party1", "party2", "raid7", "pet", "partypet1" }) do
      client:fireEvent("UNIT_PET", unit)
      client:nextFrame()
    end
    assertEqual(macros(client), before)
    assertEqual(client:macroWrites(MACRO_NAMES), writesBefore)
  end)

  test(flavor .. ": the player's own pet changing updates the macros", function()
    local client = priestWhoLearnedASpell(flavor)
    client:fireEvent("UNIT_PET", "player")
    client:nextFrame()
    -- the fake client names a spell "Spell <id>"
    assertEqual(client:macroText("AutoPotion"):match("reset=combat (.*)$"),
      "Spell " .. DESPERATE_PRAYER .. ", item:" .. POTIONS[flavor].best)
  end)
end
