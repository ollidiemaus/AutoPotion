-- What an update costs: a macro rebuild touches the "Current Priority" preview only on a settings
-- page the player has open, and debug logging prints nothing until /ap debug turns it on.
local Client = require("fake.client")
local Api = require("fake.api")

local PAGES = {
  { "AutoPotion", "AutoPotion" }, { "AutoPotion", "AutoFood" }, { "AutoPotion", "AutoDrink" },
  { "AutoPotion", "AutoBandage" }, { "AutoPotion", "AutoManaPotion" },
}

-- A healthstone and a healing potion on each flavor, and a healing spell a priest knows there.
local CLASSIC_ERA_ITEMS = { healthstone = 9421, potion = 13446 } -- Major Healthstone, Major Healing Potion
local ITEMS = {
  retail = { healthstone = 5512, potion = 244838 }, -- Healthstone, Invigorating Healing Potion (R2)
  classic = CLASSIC_ERA_ITEMS,
  forever = CLASSIC_ERA_ITEMS,
}
local DESPERATE_PRAYER = 19236 -- rank 2 on Classic Era and Forever

local function priest(flavor)
  local client = Client.new({
    flavor = flavor, class = "PRIEST", knownSpells = { DESPERATE_PRAYER },
    bags = { [ITEMS[flavor].potion] = 1 },
  })
  client:login()
  return client
end

local function iconLookups(client)
  return client:apiCallCount("C_Item.GetItemIconByID") + client:apiCallCount("C_Spell.GetSpellTexture")
end

local function previewOf(client)
  local icons = {}
  for i, shown in ipairs(client:previewIcons()) do icons[i] = shown.icon end
  return icons
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": with every settings page hidden, a bag change rebuilds the macros without touching a preview", function()
    local client = priest(flavor)
    -- every page has drawn its preview once, then the panel is closed
    for _, page in ipairs(PAGES) do client:openSettings(unpack(page)) end
    client:closeSettings()
    client:nextFrame()
    local before = iconLookups(client)

    client:addToBags(ITEMS[flavor].healthstone, 1)
    client:nextFrame()
    assertEqual(client:macroText("AutoPotion"):match("item:(%d+)"), tostring(ITEMS[flavor].healthstone))
    assertEqual(iconLookups(client) - before, 0, "icon lookups for hidden previews")
  end)
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": a page opened after bag changes shows the current priorities", function()
    local items = ITEMS[flavor]
    local client = priest(flavor)
    client:openSettings("AutoPotion", "AutoPotion")
    client:closeSettings()
    client:addToBags(items.healthstone, 1)
    client:nextFrame()

    client:openSettings("AutoPotion", "AutoPotion")
    assertEqual(previewOf(client),
      { Api.spellIcon(DESPERATE_PRAYER), Api.itemIcon(items.healthstone), Api.itemIcon(items.potion) })
  end)
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": the open page's preview follows bag changes", function()
    local items = ITEMS[flavor]
    local client = priest(flavor)
    client:openSettings("AutoPotion", "AutoPotion")
    client:addToBags(items.healthstone, 1)
    client:nextFrame()
    assertEqual(previewOf(client),
      { Api.spellIcon(DESPERATE_PRAYER), Api.itemIcon(items.healthstone), Api.itemIcon(items.potion) })
  end)
end

-- Zoning and a looted healthstone, as the player sees them in the chat.
local function zoneAndLoot(client)
  client:fireEvent("PLAYER_ENTERING_WORLD", false, false)
  client:nextFrame()
  client:addToBags(ITEMS[client.flavorName].healthstone, 1)
  client:nextFrame()
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": with debugging off, a login and a bag change print nothing", function()
    local client = priest(flavor)
    zoneAndLoot(client)
    assertEqual(client.printed, {})
  end)
end

local function chat(lines)
  local printed = {}
  for i, line in ipairs(lines) do printed[i] = "|cffb48ef9AutoPotion:|r " .. line end
  return printed
end

-- On Classic Era and Forever the priest's potion is the only one the potion lists find.
local CLASSIC_ERA_DEBUG_LINES = chat({
  "event: PLAYER_ENTERING_WORLD",
  "Updating pot counts...", "Item: 13446 Count: 1", "Updating pot counts...",
  "event: BAG_UPDATE_DELAYED",
  "Updating pot counts...", "Item: 13446 Count: 1", "Updating pot counts...",
  "AutoPotion macro updated.",
})

for _, flavor in ipairs({ "classic", "forever" }) do
  test(flavor .. ": with debugging on, a login and a bag change print what they always did", function()
    local client = priest(flavor)
    client:typeCommand("/ap debug")
    assertEqual(client.printed, { "|cffb48ef9AutoPotion:|r Debug mode is now enabled" })
    client.printed = {}
    zoneAndLoot(client)
    assertEqual(client.printed, CLASSIC_ERA_DEBUG_LINES)
  end)
end

-- Retail's potion lists are long and change every patch, so this checks the lines around them
-- and the one for the potion the priest carries.
test("retail: with debugging on, a login and a bag change print what they always did", function()
  local client = priest("retail")
  client:typeCommand("/ap debug")
  client.printed = {}
  zoneAndLoot(client)
  local others, potionLines = {}, 0
  for _, line in ipairs(client.printed) do
    if line:find("Item: %d+ Count: %d+$") then
      if line == "|cffb48ef9AutoPotion:|r Item: " .. ITEMS.retail.potion .. " Count: 1" then
        potionLines = potionLines + 1
      end
    else
      table.insert(others, line)
    end
  end
  assertEqual(others, chat({
    "event: PLAYER_ENTERING_WORLD", "Updating pot counts...", "Updating pot counts...",
    "event: BAG_UPDATE_DELAYED", "Updating pot counts...", "Updating pot counts...",
    "AutoPotion macro updated.",
  }))
  assertEqual(potionLines, 2)
end)
