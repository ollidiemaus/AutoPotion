-- Mana gems in the AutoManaPotion macro: a mage's mana gem goes first, the best mana potion
-- follows in a cast sequence that starts over after the gem's cooldown, and the "Use mana gems"
-- box on the mana potion page turns it off.
local Client = require("fake.client")
local Api = require("fake.api")

-- Classic Era and Forever (wow-data: wow.py item, SpellCooldowns)
local MANA_RUBY, MANA_CITRINE, MANA_AGATE = 8008, 8007, 5514
local MAJOR_MANA_POTION, SUPERIOR_MANA_POTION = 13444, 13443
-- Retail
local MANA_GEM = 36799
local LIGHTFUSED_MANA_POTION, LIGHTFUSED_MANA_POTION_R1 = 241300, 241301

local ITEMS = {
  [MANA_RUBY] = { spell = { name = "Replenish Mana", id = 10058 } },
  [MANA_CITRINE] = { spell = { name = "Replenish Mana", id = 10057 } },
  [MANA_AGATE] = { spell = { name = "Replenish Mana", id = 5405 } },
  [MANA_GEM] = { spell = { name = "Replenish Mana", id = 5405 } },
}
local CLASSIC_ERA_SPELLS = {
  [10058] = { name = "Replenish Mana", baseCooldown = 60000 },
  [10057] = { name = "Replenish Mana", baseCooldown = 60000 },
  [5405] = { name = "Replenish Mana", baseCooldown = 60000 },
}
local SPELLS = {
  classic = CLASSIC_ERA_SPELLS,
  forever = CLASSIC_ERA_SPELLS,
  retail = { [5405] = { name = "Replenish Mana", baseCooldown = 90000 } },
}

local LABEL = "Use mana gems"
local SKIP_CD_LABEL = "Show mana potion when mana gem is on cooldown"
local SEPARATE_GEM_LABEL = "Separate Mana Gem macro (AutoManaGem)"

local function mage(flavor, bags, options)
  options = options or {}
  options.flavor = flavor
  options.class = "MAGE"
  options.bags = bags
  options.items = ITEMS
  options.spells = options.spells or SPELLS[flavor]
  local client = Client.new(options)
  client:login()
  return client
end

local function sequence(reset, gem, potion)
  return "#showtooltip\n/castsequence reset=" .. reset .. " item:" .. gem .. ", item:" .. potion
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
  test(flavor .. ": a mana gem goes before the mana potion and the sequence resets after the gem's cooldown", function()
    local client = mage(flavor, { [MANA_RUBY] = 1, [MAJOR_MANA_POTION] = 5 })
    assertEqual(client:macroText("AutoManaPotion"), sequence("combat/60", MANA_RUBY, MAJOR_MANA_POTION))
    assertEqual(client.errors, {})
  end)

  test(flavor .. ": with several mana gems only the best one is used", function()
    local client = mage(flavor, { [MANA_AGATE] = 1, [MANA_RUBY] = 1, [MANA_CITRINE] = 1, [MAJOR_MANA_POTION] = 5 })
    assertEqual(client:macroText("AutoManaPotion"), sequence("combat/60", MANA_RUBY, MAJOR_MANA_POTION))
  end)

  test(flavor .. ": a mana gem and no mana potion is a plain use of the gem", function()
    local client = mage(flavor, { [MANA_CITRINE] = 1 })
    assertEqual(client:macroText("AutoManaPotion"), uses(MANA_CITRINE))
  end)

  test(flavor .. ": no mana gem leaves the potion macro as it was", function()
    local client = mage(flavor, { [MAJOR_MANA_POTION] = 5 })
    assertEqual(client:macroText("AutoManaPotion"), uses(MAJOR_MANA_POTION))
  end)
end

test("retail: the Mana Gem goes before the mana potion with its own cooldown as the reset timer", function()
  local client = mage("retail", { [MANA_GEM] = 1, [LIGHTFUSED_MANA_POTION] = 5 })
  assertEqual(client:macroText("AutoManaPotion"), sequence("combat/90", MANA_GEM, LIGHTFUSED_MANA_POTION))
  assertEqual(client.errors, {})
end)

test("retail: a MegaMacro AutoManaPotion gets the mana gem too", function()
  local client = mage("retail", { [MANA_GEM] = 1, [LIGHTFUSED_MANA_POTION] = 5 }, { megaMacro = { "AutoManaPotion" } })
  client:advance(10) -- the MegaMacro check
  assertEqual(client:megaMacroText("AutoManaPotion"), sequence("combat/90", MANA_GEM, LIGHTFUSED_MANA_POTION))
end)

test("classic: when the client reports no cooldown for the gem the sequence resets on combat only", function()
  local client = mage("classic", { [MANA_RUBY] = 1, [MAJOR_MANA_POTION] = 5 }, { spells = {} })
  assertEqual(client:macroText("AutoManaPotion"), sequence("combat", MANA_RUBY, MAJOR_MANA_POTION))
end)

-- Per flavor: the best mana gem, its reset timer, and the two best mana potions.
local FLAVOR_ITEMS = {
  classic = { gem = MANA_RUBY, reset = "combat/60", potion = MAJOR_MANA_POTION, second = SUPERIOR_MANA_POTION },
  forever = { gem = MANA_RUBY, reset = "combat/60", potion = MAJOR_MANA_POTION, second = SUPERIOR_MANA_POTION },
  retail = { gem = MANA_GEM, reset = "combat/90", potion = LIGHTFUSED_MANA_POTION, second = LIGHTFUSED_MANA_POTION_R1 },
}

for _, flavor in ipairs({ "classic", "forever", "retail" }) do
  local items = FLAVOR_ITEMS[flavor]

  test(flavor .. ": the \"Use mana gems\" box is on by default, turns the gem off and stays off after a reload", function()
    local client = mage(flavor, { [items.gem] = 1, [items.potion] = 5 })
    client:openSettings("AutoPotion", "AutoManaPotion")
    assertEqual(client:isChecked(LABEL), true)

    client:clickCheckbox(LABEL)
    client:nextFrame()
    assertEqual(client:isChecked(LABEL), false)
    assertEqual(client:macroText("AutoManaPotion"), uses(items.potion))

    client = client:reload()
    client:openSettings("AutoPotion", "AutoManaPotion")
    assertEqual(client:isChecked(LABEL), false)
    assertEqual(client:macroText("AutoManaPotion"), uses(items.potion))
    assertEqual(client.errors, {})
  end)

  test(flavor .. ": the preview shows the mana gem in front of the potions, and drops it with the box off", function()
    local client = mage(flavor, { [items.gem] = 1, [items.potion] = 5, [items.second] = 5 })
    client:openSettings("AutoPotion", "AutoManaPotion")
    assertEqual(previewOf(client),
      { Api.itemIcon(items.gem), Api.itemIcon(items.potion), Api.itemIcon(items.second) })

    client:clickCheckbox(LABEL)
    client:nextFrame()
    assertEqual(previewOf(client), { Api.itemIcon(items.potion), Api.itemIcon(items.second) })
    assertEqual(client.errors, {})
  end)

  test(flavor .. ": a mana gem conjured in combat gets into the macro when combat ends", function()
    local client = mage(flavor, { [items.potion] = 5 })
    client:enterCombat()
    client:addToBags(items.gem, 1)
    client:advance(1)
    assertEqual(client.blockedActions, {})
    assertEqual(client:macroText("AutoManaPotion"), uses(items.potion))

    client:leaveCombat()
    assertEqual(client:macroText("AutoManaPotion"), sequence(items.reset, items.gem, items.potion))
  end)

  test(flavor .. ": skips a mana gem on cooldown when enabled and returns to it on expiry", function()
    local client = mage(flavor, { [items.gem] = 1, [items.potion] = 5 }, {
      itemCooldowns = { [items.gem] = { start = 1, duration = 60 } },
    })
    assertEqual(client:macroText("AutoManaPotion"), sequence(items.reset, items.gem, items.potion))

    client:openSettings("AutoPotion", "AutoManaPotion")
    assertEqual(client:isChecked(SKIP_CD_LABEL), false)
    assertEqual(previewOf(client), { Api.itemIcon(items.gem), Api.itemIcon(items.potion) })

    client:clickCheckbox(SKIP_CD_LABEL)
    client:nextFrame()
    assertEqual(client:macroText("AutoManaPotion"), uses(items.potion))
    assertEqual(previewOf(client), { Api.itemIcon(items.potion) })

    client:clickCheckbox(SKIP_CD_LABEL)
    client:nextFrame()
    assertEqual(client:macroText("AutoManaPotion"), sequence(items.reset, items.gem, items.potion))

    client:clickCheckbox(SKIP_CD_LABEL)
    client:nextFrame()
    assertEqual(client:macroText("AutoManaPotion"), uses(items.potion))

    client:advance(65)
    assertEqual(client:macroText("AutoManaPotion"), sequence(items.reset, items.gem, items.potion))
    assertEqual(client.errors, {})
  end)

  test(flavor .. ": restores mana gem at once when its cooldown resets early", function()
    local client = mage(flavor, { [items.gem] = 1, [items.potion] = 5 }, {
      itemCooldowns = { [items.gem] = { start = 1, duration = 60 } },
    })
    client:openSettings("AutoPotion", "AutoManaPotion")
    client:clickCheckbox(SKIP_CD_LABEL)
    client:nextFrame()
    assertEqual(client:macroText("AutoManaPotion"), uses(items.potion))

    client:setItemCooldown(items.gem, 0)
    client:nextFrame()
    assertEqual(client:macroText("AutoManaPotion"), sequence(items.reset, items.gem, items.potion))
    assertEqual(client.errors, {})
  end)

  test(flavor .. ": existing AutoManaGem macro survives login when separate macro is off", function()
    local client = Client.new({
      flavor = flavor,
      class = "WARRIOR",
      accountMacros = { "AutoManaGem" },
    })
    client.env.EditMacro("AutoManaGem", "AutoManaGem", nil, "#showtooltip\n/say my macro")
    client:login()
    assertEqual(client:macroText("AutoManaGem"), "#showtooltip\n/say my macro")
    assertEqual(client.errors, {})
  end)

  test(flavor .. ": Separate Mana Gem macro creates AutoManaGem and keeps AutoManaPotion for potions", function()
    local client = mage(flavor, { [items.gem] = 1, [items.potion] = 5, [items.second] = 5 })
    client:openSettings("AutoPotion", "AutoManaPotion")
    assertEqual(client:isChecked(SEPARATE_GEM_LABEL), false)
    assertEqual(client:macroText("AutoManaGem"), nil)

    client:clickCheckbox(SEPARATE_GEM_LABEL)
    client:nextFrame()
    assertEqual(client:macroText("AutoManaGem"), uses(items.gem))
    assertEqual(client:macroText("AutoManaPotion"), uses(items.potion))
    assertEqual(previewOf(client), { Api.itemIcon(items.potion), Api.itemIcon(items.second) })
    assertEqual(client:isEnabled(LABEL), false)
    assertEqual(client:isEnabled(SKIP_CD_LABEL), false)

    client:clickCheckbox(SEPARATE_GEM_LABEL)
    client:nextFrame()
    assertEqual(client:macroText("AutoManaGem"), nil)
    assertEqual(client:macroText("AutoManaPotion"), sequence(items.reset, items.gem, items.potion))
    assertEqual(client.errors, {})
  end)
end

for _, flavor in ipairs({ "classic", "forever" }) do
  test(flavor .. ": skips a mana gem on cooldown for a demonic rune even without a mana potion", function()
    local DEMONIC_RUNE = 12662
    local client = mage(flavor, { [MANA_RUBY] = 1, [DEMONIC_RUNE] = 2 }, {
      itemCooldowns = { [MANA_RUBY] = { start = 1, duration = 60 } },
    })
    client:openSettings("AutoPotion", "AutoManaPotion")
    client:clickCheckbox(SKIP_CD_LABEL)
    client:clickCheckbox("Include Demonic Runes")
    client:nextFrame()
    assertEqual(client:macroText("AutoManaPotion"), uses(DEMONIC_RUNE))
    assertEqual(previewOf(client), { Api.itemIcon(DEMONIC_RUNE) })
    assertEqual(client.errors, {})
  end)
end
