-- What changing gear does to the macros. Only Retail has tinkers, and only a tinker slot (head,
-- wrist, gun) can hold the Heartseeking Health Injector, so only a change there is worth a rebuild.
-- A rebuild that changes no macro text writes nothing, so the tests also count the
-- C_Item.GetItemCount calls the client served: a rebuild asks it for every candidate item.
local Client = require("fake.client")

local MACRO_NAMES = { "AutoPotion", "AutoFood", "AutoDrink", "AutoBandage", "AutoManaPotion" }

local function everyMacro(count)
  local counts = {}
  for _, name in ipairs(MACRO_NAMES) do counts[name] = count end
  return counts
end

-- What the client did between two snapshots: macro writes per macro and C_Item.GetItemCount
-- calls, which a rebuild makes for every candidate item.
local function snapshot(client)
  return { writes = client:macroWrites(MACRO_NAMES), itemCounts = client:apiCallCount("C_Item.GetItemCount") }
end

local function since(client, before)
  local now = snapshot(client)
  for name, count in pairs(now.writes) do now.writes[name] = count - before.writes[name] end
  now.itemCounts = now.itemCounts - before.itemCounts
  return now
end

-- The C_Item.GetItemCount calls of one rebuild with nothing changed.
local function oneRebuild(client)
  local before = snapshot(client)
  client:fireEvent("PLAYER_ENTERING_WORLD", false, false)
  client:advance(1)
  return since(client, before).itemCounts
end

local HELM, BRACERS, CHEST, LEGS, MAIN_HAND = 101, 102, 103, 104, 105
local INJECTOR_HELM = 106 -- a helm with the tinker as its use effect
local ITEMS = { [INJECTOR_HELM] = { spell = { name = "Heartseeking Health Injector", id = 452767 } } }

local function wearing(flavor, options)
  options = options or {}
  local client = Client.new({
    flavor = flavor,
    bags = { [5512] = 1 }, -- Healthstone
    items = ITEMS,
    equipped = { [1] = HELM, [9] = BRACERS, [5] = CHEST, [7] = LEGS, [16] = MAIN_HAND },
    savedVariables = options.savedVariables,
  })
  client:login()
  client:advance(1)
  return client
end

test("retail: a gear-set swap that changes only non-tinker slots doesn't rebuild the macros", function()
  local client = wearing("retail")
  local before = snapshot(client)
  client:equip({ [5] = 203, [7] = 204, [16] = 205, [17] = 206 })
  client:advance(1)
  assertEqual(since(client, before), { writes = everyMacro(0), itemCounts = 0 })
  assertEqual(client.errors, {})
end)

local function withInjectorBox(client)
  client:openSettings("AutoPotion", "AutoPotion")
  client:clickCheckbox("Heartseeking Health Injector (tinker)")
  client:advance(1)
  return client
end

test("retail: putting on or taking off the Heartseeking Health Injector updates the macro", function()
  local client = withInjectorBox(wearing("retail"))
  local without = client:macroText("AutoPotion")

  client:equip({ [1] = INJECTOR_HELM })
  client:nextFrame()
  assertEqual(client:macroText("AutoPotion"), "#showtooltip \n/castsequence [@player] reset=combat 1, item:5512")

  client:equip({ [1] = HELM })
  client:nextFrame()
  assertEqual(client:macroText("AutoPotion"), without)
  assertEqual(client.errors, {})
end)

test("retail: a gear-set swap that changes tinker slots rebuilds the macros once", function()
  local client = withInjectorBox(wearing("retail"))
  local before = snapshot(client)
  client:equip({ [1] = INJECTOR_HELM, [9] = 202, [5] = 203, [16] = 205 })
  client:advance(1)
  local changes = since(client, before)
  -- a rebuild's calls depend on the gear, so compare with one in the new gear
  assertEqual(changes.itemCounts, oneRebuild(client))
  assertEqual(changes.writes.AutoPotion, 1)
  assertEqual(client.errors, {})
end)

for _, flavor in ipairs({ "classic", "forever" }) do
  test(flavor .. ": changing gear, tinker slots included, doesn't rebuild the macros", function()
    local client = wearing(flavor)
    local before = snapshot(client)
    client:equip({ [1] = INJECTOR_HELM, [9] = 202, [5] = 203, [18] = 207 })
    client:advance(1)
    client:equip({ [1] = HELM })
    client:advance(1)
    assertEqual(since(client, before), { writes = everyMacro(0), itemCounts = 0 })
    assertEqual(client.errors, {})
  end)
end
