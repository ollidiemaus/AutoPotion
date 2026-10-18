-- The "Current Priority" previews on the main AutoPotion page and the Food, Drink, Bandage and
-- Mana Potion pages: the right icon for every entry, left to right in priority order, no two on
-- the same spot, and the tooltip of the entry it shows.
local Client = require("fake.client")
local Api = require("fake.api")

-- A healthstone and a healing potion on each flavor.
local CLASSIC_ERA_ITEMS = { healthstone = 9421, potion = 13446 } -- Major Healthstone, Major Healing Potion
local ITEMS = {
  retail = { healthstone = 5512, potion = 244838 }, -- Healthstone, Invigorating Healing Potion (R2)
  classic = CLASSIC_ERA_ITEMS,
  forever = CLASSIC_ERA_ITEMS,
}

local function bagsWith(...)
  local bags = {}
  for _, itemId in ipairs({ ... }) do bags[itemId] = 1 end
  return bags
end

local function previewOf(client)
  local icons = {}
  for i, shown in ipairs(client:previewIcons()) do icons[i] = shown.icon end
  return icons
end

-- Bag changes reach the addon after its 3 second debounce.
local function waitForBagUpdate(client)
  client:advance(3)
end

-- Fails unless no two preview icons share a position.
local function assertNoOverlaps(client)
  local seen = {}
  for _, shown in ipairs(client:previewIcons()) do
    local spot = shown.x .. "," .. shown.y
    assertEqual(seen[spot], nil, "two preview icons at " .. spot)
    seen[spot] = true
  end
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": with an empty item cache the preview shows every item's icon", function()
    local items = ITEMS[flavor]
    local client = Client.new({
      flavor = flavor, emptyItemCache = true, bags = bagsWith(items.healthstone, items.potion),
    })
    client:login()
    client:openSettings("AutoPotion", "AutoPotion")
    assertEqual(previewOf(client), { Api.itemIcon(items.healthstone), Api.itemIcon(items.potion) })
  end)
end

local DESPERATE_PRAYER = 19236 -- rank 2 on Classic Era and Forever
local CRIMSON_VIAL = 185311

-- A character who knows one healing spell and carries a healthstone and a potion.
local function withSpell(flavor, class, spellId, options)
  local items = ITEMS[flavor]
  options = options or {}
  options.flavor, options.class, options.knownSpells = flavor, class, { spellId }
  options.bags = options.bags or bagsWith(items.healthstone, items.potion)
  local client = Client.new(options)
  client:login()
  client:openSettings("AutoPotion", "AutoPotion")
  return client
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": a healing spell and items each get their own spot, left to right in priority order", function()
    local items = ITEMS[flavor]
    local client = withSpell(flavor, "PRIEST", DESPERATE_PRAYER)
    assertEqual(previewOf(client),
      { Api.spellIcon(DESPERATE_PRAYER), Api.itemIcon(items.healthstone), Api.itemIcon(items.potion) })
    assertNoOverlaps(client)
  end)
end

test("retail: Crimson Vial doesn't sit under the healthstone", function()
  local items = ITEMS.retail
  local client = withSpell("retail", "ROGUE", CRIMSON_VIAL)
  assertEqual(previewOf(client),
    { Api.spellIcon(CRIMSON_VIAL), Api.itemIcon(items.healthstone), Api.itemIcon(items.potion) })
  assertNoOverlaps(client)
end)

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": entries that turn up while the page is open line up after the others", function()
    local items = ITEMS[flavor]
    local client = withSpell(flavor, "PRIEST", DESPERATE_PRAYER, { bags = bagsWith(items.potion) })
    assertEqual(previewOf(client), { Api.spellIcon(DESPERATE_PRAYER), Api.itemIcon(items.potion) })
    local first = client:previewIcons()[1]

    client:addToBags(items.healthstone, 1)
    waitForBagUpdate(client)
    assertEqual(previewOf(client),
      { Api.spellIcon(DESPERATE_PRAYER), Api.itemIcon(items.healthstone), Api.itemIcon(items.potion) })
    assertNoOverlaps(client)
    assertEqual(client:previewIcons()[1], first, "the first icon moved")
  end)
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": entries that run out while the page is open leave the preview", function()
    local items = ITEMS[flavor]
    local client = withSpell(flavor, "PRIEST", DESPERATE_PRAYER)
    client:addToBags(items.potion, -1)
    waitForBagUpdate(client)
    assertEqual(previewOf(client), { Api.spellIcon(DESPERATE_PRAYER), Api.itemIcon(items.healthstone) })
  end)
end

local HELM_WITH_TINKER = 1 -- any helm, the tinker is its use effect

local function tooltips(client)
  local shown = {}
  for i = 1, #client:previewIcons() do shown[i] = client:hoverPreviewIcon(i) end
  return shown
end

test("retail: after refreshes each preview icon shows the tooltip of its current entry", function()
  local items = ITEMS.retail
  local client = withSpell("retail", "PRIEST", DESPERATE_PRAYER, {
    bags = bagsWith(items.potion),
    items = { [HELM_WITH_TINKER] = { spell = { name = "Heartseeking Health Injector", id = 452767 } } },
    equipped = { [1] = HELM_WITH_TINKER },
  })
  assertEqual(tooltips(client), { { "spell:" .. DESPERATE_PRAYER }, { "item:" .. items.potion } })

  -- the tinker takes the potion's place
  client:clickCheckbox("Heartseeking Health Injector (tinker)")
  client:addToBags(items.healthstone, 1)
  waitForBagUpdate(client)
  assertEqual(previewOf(client),
    { Api.spellIcon(DESPERATE_PRAYER), Api.itemIcon(HELM_WITH_TINKER), Api.itemIcon(items.healthstone) })
  assertEqual(tooltips(client),
    { { "spell:" .. DESPERATE_PRAYER }, { "player:slot:1" }, { "item:" .. items.healthstone } })

  client:addToBags(items.healthstone, -1)
  waitForBagUpdate(client)
  assertEqual(tooltips(client), { { "spell:" .. DESPERATE_PRAYER }, { "player:slot:1" } })
  assertEqual(#client.errors, 0, table.concat(client.errors, "\n\n"))
end)

-- The other pages, with each flavor's best two items of the page, best first (wow-data: wow.py item).
local CLASSIC_ERA_PAGE_ITEMS = {
  AutoFood = { 22895, 8076 },       -- Conjured Cinnamon Roll, Conjured Sweet Roll
  AutoDrink = { 8079, 8078 },       -- Conjured Crystal Water, Conjured Sparkling Water
  AutoBandage = { 14530, 14529 },   -- Heavy Runecloth Bandage, Runecloth Bandage
  AutoManaPotion = { 13444, 13443 }, -- Major Mana Potion, Superior Mana Potion
}
local PAGE_ITEMS = {
  retail = {
    AutoFood = { 113509, 265096 },      -- Conjured Mana Bun, Conjured Souffle
    AutoDrink = { 265099, 113509 },     -- Conjured Tea, Conjured Mana Bun
    AutoBandage = { 239713, 239711 },   -- Bright Linen Bandage (R2, R1)
    AutoManaPotion = { 241300, 241301 }, -- Lightfused Mana Potion (R2, R1)
  },
  classic = CLASSIC_ERA_PAGE_ITEMS,
  forever = CLASSIC_ERA_PAGE_ITEMS,
}
local PAGES = { "AutoFood", "AutoDrink", "AutoBandage", "AutoManaPotion" }

local function onPage(flavor, page, bags)
  local client = Client.new({ flavor = flavor, emptyItemCache = true, bags = bags })
  client:login()
  client:openSettings("AutoPotion", page)
  return client
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  for _, page in ipairs(PAGES) do
    local best, second = PAGE_ITEMS[flavor][page][1], PAGE_ITEMS[flavor][page][2]

    test(flavor .. ": with an empty item cache the " .. page .. " preview shows every item's icon", function()
      local client = onPage(flavor, page, bagsWith(best, second))
      assertEqual(previewOf(client), { Api.itemIcon(best), Api.itemIcon(second) })
      assertNoOverlaps(client)
      assertEqual(#client.errors, 0, table.concat(client.errors, "\n\n"))
    end)

    test(flavor .. ": the " .. page .. " preview follows the bags while the page is open", function()
      local client = onPage(flavor, page, bagsWith(second))
      assertEqual(previewOf(client), { Api.itemIcon(second) })
      local first = client:previewIcons()[1]

      client:addToBags(best, 1)
      waitForBagUpdate(client)
      assertEqual(previewOf(client), { Api.itemIcon(best), Api.itemIcon(second) })
      assertNoOverlaps(client)
      local shown = client:previewIcons()[1]
      assertEqual({ shown.x, shown.y }, { first.x, first.y }, "the first icon moved")
      assertEqual(tooltips(client), { { "item:" .. best }, { "item:" .. second } })

      client:addToBags(best, -1)
      waitForBagUpdate(client)
      assertEqual(previewOf(client), { Api.itemIcon(second) })
      assertEqual(tooltips(client), { { "item:" .. second } })
      assertEqual(#client.errors, 0, table.concat(client.errors, "\n\n"))
    end)
  end
end
