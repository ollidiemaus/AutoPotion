-- Demonic runes in the AutoManaPotion macro: off by default; with the "Include Demonic Runes"
-- box on the mana potion page ticked, one demonic rune goes last, after the mana gem and the mana
-- potion. Not offered on Retail.
local Client = require("fake.client")
local Api = require("fake.api")

-- Classic Era and Forever (wow-data: wow.py item, SpellCooldowns)
local DEMONIC_RUNE, DARK_RUNE = 12662, 20520
local MANA_RUBY = 8008
local MAJOR_MANA_POTION, SUPERIOR_MANA_POTION = 13444, 13443

local ITEMS = {
  [MANA_RUBY] = { spell = { name = "Replenish Mana", id = 10058 } },
}
local SPELLS = {
  [10058] = { name = "Replenish Mana", baseCooldown = 60000 },
}

local LABEL = "Include Demonic Runes"

local function mage(flavor, bags, options)
  options = options or {}
  options.flavor = flavor
  options.class = "MAGE"
  options.bags = bags
  options.items = ITEMS
  options.spells = SPELLS
  local client = Client.new(options)
  client:login()
  return client
end

-- Opens the AutoManaPotion page and ticks the given boxes.
local function tick(client, ...)
  client:openSettings("AutoPotion", "AutoManaPotion")
  for _, label in ipairs({ ... }) do client:clickCheckbox(label) end
  client:nextFrame()
end

local function sequence(reset, ...)
  local entries = {}
  for i, id in ipairs({ ... }) do entries[i] = "item:" .. id end
  return "#showtooltip\n/castsequence reset=" .. reset .. " " .. table.concat(entries, ", ")
end

local function uses(itemId)
  return "#showtooltip\n/use item:" .. itemId
end

local function previewOf(client)
  local icons = {}
  for i, shown in ipairs(client:previewIcons()) do icons[i] = shown.icon end
  return icons
end

for _, flavor in ipairs({ "classic", "forever" }) do
  test(flavor .. ": with the box ticked the demonic rune follows the mana potion", function()
    local client = mage(flavor, { [MAJOR_MANA_POTION] = 5, [DEMONIC_RUNE] = 2 })
    tick(client, LABEL)
    assertEqual(client:macroText("AutoManaPotion"), sequence("combat", MAJOR_MANA_POTION, DEMONIC_RUNE))
    assertEqual(client.errors, {})
  end)

  test(flavor .. ": the box is off by default and runes in the bags stay out of the macro", function()
    local client = mage(flavor, { [MAJOR_MANA_POTION] = 5, [DEMONIC_RUNE] = 2, [DARK_RUNE] = 2 })
    client:openSettings("AutoPotion", "AutoManaPotion")
    assertEqual(client:isChecked(LABEL), false)
    assertEqual(client:macroText("AutoManaPotion"), uses(MAJOR_MANA_POTION))
    assertEqual(previewOf(client), { Api.itemIcon(MAJOR_MANA_POTION) })
  end)

  test(flavor .. ": mana gem, then mana potion, then the rune, reset after the gem's cooldown", function()
    local client = mage(flavor, { [MANA_RUBY] = 1, [MAJOR_MANA_POTION] = 5, [DEMONIC_RUNE] = 2 })
    tick(client, LABEL)
    assertEqual(client:macroText("AutoManaPotion"),
      sequence("combat/60", MANA_RUBY, MAJOR_MANA_POTION, DEMONIC_RUNE))
  end)

  test(flavor .. ": with no mana potion the rune follows the gem, or stands alone", function()
    local client = mage(flavor, { [MANA_RUBY] = 1, [DEMONIC_RUNE] = 2 })
    tick(client, LABEL)
    assertEqual(client:macroText("AutoManaPotion"), sequence("combat/60", MANA_RUBY, DEMONIC_RUNE))

    client:addToBags(MANA_RUBY, -1)
    client:nextFrame()
    assertEqual(client:macroText("AutoManaPotion"), uses(DEMONIC_RUNE))
  end)

  test(flavor .. ": with both runes only Demonic Rune is used, and Dark Rune once it's gone", function()
    local client = mage(flavor, { [MAJOR_MANA_POTION] = 5, [DEMONIC_RUNE] = 1, [DARK_RUNE] = 3 })
    tick(client, LABEL)
    assertEqual(client:macroText("AutoManaPotion"), sequence("combat", MAJOR_MANA_POTION, DEMONIC_RUNE))

    client:addToBags(DEMONIC_RUNE, -1)
    client:nextFrame()
    assertEqual(client:macroText("AutoManaPotion"), sequence("combat", MAJOR_MANA_POTION, DARK_RUNE))
  end)

  test(flavor .. ": a rune that lands in the bags joins the macro, and leaves with the last one", function()
    local client = mage(flavor, { [MAJOR_MANA_POTION] = 5 })
    tick(client, LABEL)
    assertEqual(client:macroText("AutoManaPotion"), uses(MAJOR_MANA_POTION))

    client:addToBags(DARK_RUNE, 1)
    client:nextFrame()
    assertEqual(client:macroText("AutoManaPotion"), sequence("combat", MAJOR_MANA_POTION, DARK_RUNE))

    client:addToBags(DARK_RUNE, -1)
    client:nextFrame()
    assertEqual(client:macroText("AutoManaPotion"), uses(MAJOR_MANA_POTION))
  end)

  test(flavor .. ": with \"Weakest Mana Potion First\" the rune stays last", function()
    local client = mage(flavor, { [MAJOR_MANA_POTION] = 5, [SUPERIOR_MANA_POTION] = 5, [DEMONIC_RUNE] = 2 })
    tick(client, LABEL, "Weakest Mana Potion First")
    assertEqual(client:macroText("AutoManaPotion"), sequence("combat", SUPERIOR_MANA_POTION, DEMONIC_RUNE))
  end)

  test(flavor .. ": with \"Use mana gems\" off the rune still follows the potion", function()
    local client = mage(flavor, { [MANA_RUBY] = 1, [MAJOR_MANA_POTION] = 5, [DEMONIC_RUNE] = 2 })
    tick(client, LABEL, "Use mana gems")
    assertEqual(client:macroText("AutoManaPotion"), sequence("combat", MAJOR_MANA_POTION, DEMONIC_RUNE))
  end)

  test(flavor .. ": the preview shows the rune last, and drops it with the box off", function()
    local client = mage(flavor, { [MANA_RUBY] = 1, [MAJOR_MANA_POTION] = 5, [DEMONIC_RUNE] = 2 })
    tick(client, LABEL)
    assertEqual(previewOf(client),
      { Api.itemIcon(MANA_RUBY), Api.itemIcon(MAJOR_MANA_POTION), Api.itemIcon(DEMONIC_RUNE) })

    client:clickCheckbox(LABEL)
    client:nextFrame()
    assertEqual(previewOf(client), { Api.itemIcon(MANA_RUBY), Api.itemIcon(MAJOR_MANA_POTION) })
    assertEqual(client:macroText("AutoManaPotion"), sequence("combat/60", MANA_RUBY, MAJOR_MANA_POTION))
  end)

  test(flavor .. ": ticking the box in combat reaches the macro when combat ends", function()
    local client = mage(flavor, { [MAJOR_MANA_POTION] = 5, [DEMONIC_RUNE] = 2 })
    client:openSettings("AutoPotion", "AutoManaPotion")
    client:enterCombat()
    client:clickCheckbox(LABEL)
    client:advance(1)
    assertEqual(client.blockedActions, {})
    assertEqual(client:macroText("AutoManaPotion"), uses(MAJOR_MANA_POTION))

    client:leaveCombat()
    assertEqual(client:macroText("AutoManaPotion"), sequence("combat", MAJOR_MANA_POTION, DEMONIC_RUNE))
  end)

  test(flavor .. ": the box stays ticked after a reload", function()
    local client = mage(flavor, { [MAJOR_MANA_POTION] = 5, [DEMONIC_RUNE] = 2 })
    tick(client, LABEL)
    client = client:reload()
    client:openSettings("AutoPotion", "AutoManaPotion")
    assertEqual(client:isChecked(LABEL), true)
    assertEqual(client:macroText("AutoManaPotion"), sequence("combat", MAJOR_MANA_POTION, DEMONIC_RUNE))
    assertEqual(client.errors, {})
  end)
end

test("retail: no demonic rune box, and runes in the bags never reach the macro", function()
  local LIGHTFUSED_MANA_POTION = 241300
  local client = mage("retail", { [LIGHTFUSED_MANA_POTION] = 5, [DEMONIC_RUNE] = 2, [DARK_RUNE] = 2 },
    { savedVariables = { HAMDB = { includeDemonicRunes = true } } })
  client:openSettings("AutoPotion", "AutoManaPotion")
  for _, label in ipairs(client:checkboxLabels()) do
    assert(label ~= LABEL, "Retail shows the \"" .. LABEL .. "\" box")
  end
  assertEqual(client:macroText("AutoManaPotion"), uses(LIGHTFUSED_MANA_POTION))
  assertEqual(previewOf(client), { Api.itemIcon(LIGHTFUSED_MANA_POTION) })
  assertEqual(client.errors, {})
end)
