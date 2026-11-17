-- Mana spells in the AutoManaPotion macro: every mana spell of the flavor gets a box on the mana
-- potion page, under a header per class, all off. A ticked spell the character knows goes first,
-- cast on the player, in the flavor's order, ahead of the mana gem and the mana potion; the first
-- entry's cooldown (with cooldown talents) is the reset timer.
local Client = require("fake.client")
local Api = require("fake.api")

-- Spell IDs and base cooldowns from the clients (wow-data: wow.py spell, SpellCooldowns)
local EVOCATION, INNERVATE = 12051, 29166
local MANA_TIDE_TOTEM, MANA_TIDE_TOTEM_R2, MANA_TIDE_TOTEM_R3, MANA_TIDE_TOTEM_R4 = 16190, 17354, 17359, 1325256
local SOD_SHADOWFIEND, SOD_DISPERSION, SOD_SHAMANISTIC_RAGE = 401977, 425294, 425336
local MINDBENDER, SYMBOL_OF_HOPE = 123040, 64901
local DARK_SACRIFICE, DARK_SACRIFICE_R5 = 1277324, 1277328
local READ_LEYLINE = 1259705
local DESPERATE_PRAYER = 19236

-- Classic Era and Forever
local MANA_RUBY, MAJOR_MANA_POTION = 8008, 13444
-- Retail
local MANA_GEM, LIGHTFUSED_MANA_POTION = 36799, 241300

local ITEMS = {
  [MANA_RUBY] = { spell = { name = "Replenish Mana", id = 10058 } },
  [MANA_GEM] = { spell = { name = "Replenish Mana", id = 5405 } },
}

local CLASSIC_ERA_SPELLS = {
  [10058] = { name = "Replenish Mana", baseCooldown = 60000 },
  [EVOCATION] = { name = "Evocation", baseCooldown = 480000 },
  [INNERVATE] = { name = "Innervate", baseCooldown = 360000 },
  [MANA_TIDE_TOTEM] = { name = "Mana Tide Totem", baseCooldown = 300000 },
  [MANA_TIDE_TOTEM_R2] = { name = "Mana Tide Totem", baseCooldown = 300000 },
  [MANA_TIDE_TOTEM_R3] = { name = "Mana Tide Totem", baseCooldown = 300000 },
  [MANA_TIDE_TOTEM_R4] = { name = "Mana Tide Totem", baseCooldown = 300000 },
  [SOD_SHADOWFIEND] = { name = "Shadowfiend", baseCooldown = 300000 },
  [SOD_DISPERSION] = { name = "Dispersion", baseCooldown = 120000 },
  [SOD_SHAMANISTIC_RAGE] = { name = "Shamanistic Rage", baseCooldown = 60000 },
  [DARK_SACRIFICE] = { name = "Dark Sacrifice", baseCooldown = 600000 },
  [DARK_SACRIFICE_R5] = { name = "Dark Sacrifice", baseCooldown = 600000 },
  [READ_LEYLINE] = { name = "Read Leyline", baseCooldown = 120000 },
  [DESPERATE_PRAYER] = { name = "Desperate Prayer", baseCooldown = 600000 },
}
local SPELLS = {
  classic = CLASSIC_ERA_SPELLS,
  forever = CLASSIC_ERA_SPELLS,
  retail = {
    [5405] = { name = "Replenish Mana", baseCooldown = 90000 },
    [EVOCATION] = { name = "Evocation" }, -- one charge, no base cooldown
    [INNERVATE] = { name = "Innervate", baseCooldown = 180000 },
    [MINDBENDER] = { name = "Mindbender", baseCooldown = 60000 },
    [SYMBOL_OF_HOPE] = { name = "Symbol of Hope", baseCooldown = 180000 },
    [DESPERATE_PRAYER] = { name = "Desperate Prayer", baseCooldown = 90000 },
  },
}
local GEM = { retail = MANA_GEM, classic = MANA_RUBY, forever = MANA_RUBY }
local POTION = { retail = LIGHTFUSED_MANA_POTION, classic = MAJOR_MANA_POTION, forever = MAJOR_MANA_POTION }
local EVOCATION_RESET = { retail = "combat", classic = "combat/480", forever = "combat/480" }

local function character(flavor, class, options)
  options = options or {}
  options.flavor = flavor
  options.class = class
  options.items = ITEMS
  options.spells = SPELLS[flavor]
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

local function previewOf(client)
  local icons = {}
  for i, shown in ipairs(client:previewIcons()) do icons[i] = shown.icon end
  return icons
end

local function contains(list, value)
  for _, v in ipairs(list) do
    if v == value then return true end
  end
  return false
end

-- The entries of `list` that are in `wanted`, in the order of `list`.
local function only(list, wanted)
  local result = {}
  for _, v in ipairs(list) do
    if contains(wanted, v) then table.insert(result, v) end
  end
  return result
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  local gem, potion = GEM[flavor], POTION[flavor]

  test(flavor .. ": with no mana spell ticked the macro is the same as before", function()
    local client = character(flavor, "MAGE", { knownSpells = { EVOCATION }, bags = { [potion] = 5 } })
    client:openSettings("AutoPotion", "AutoManaPotion")
    assertEqual(client:isChecked("Evocation"), false)
    assertEqual(client:macroText("AutoManaPotion"), "#showtooltip\n/use item:" .. potion)
    assertEqual(client.errors, {})
  end)

  test(flavor .. ": a ticked Evocation goes before the mana gem and the potion, cast on the player", function()
    local client = character(flavor, "MAGE", { knownSpells = { EVOCATION }, bags = { [gem] = 1, [potion] = 5 } })
    tick(client, "Evocation")
    assertEqual(client:macroText("AutoManaPotion"), "#showtooltip\n/castsequence [@player] reset="
      .. EVOCATION_RESET[flavor] .. " Evocation, item:" .. gem .. ", item:" .. potion)
    assertEqual(client.errors, {})
  end)

  test(flavor .. ": a ticked mana spell alone is cast on the player", function()
    local client = character(flavor, "DRUID", { knownSpells = { INNERVATE } })
    tick(client, "Innervate")
    assertEqual(client:macroText("AutoManaPotion"), "#showtooltip\n/cast [@player] Innervate")
  end)

  test(flavor .. ": a ticked spell the character doesn't know stays out until it is learned", function()
    local client = character(flavor, "MAGE", { bags = { [potion] = 5 } })
    tick(client, "Evocation")
    assertEqual(client:macroText("AutoManaPotion"), "#showtooltip\n/use item:" .. potion)

    client:learnSpell(EVOCATION)
    client:nextFrame()
    assertEqual(client:macroText("AutoManaPotion"),
      "#showtooltip\n/castsequence [@player] reset=" .. EVOCATION_RESET[flavor] .. " Evocation, item:" .. potion)
  end)

  test(flavor .. ": the preview shows the known, ticked mana spells before the items", function()
    local client = character(flavor, "MAGE", { knownSpells = { EVOCATION }, bags = { [gem] = 1, [potion] = 5 } })
    tick(client, "Evocation")
    assertEqual(previewOf(client), { Api.spellIcon(EVOCATION), Api.itemIcon(gem), Api.itemIcon(potion) })
  end)

  test(flavor .. ": ticking in combat shows in the preview at once and reaches the macro after combat", function()
    local client = character(flavor, "MAGE", { knownSpells = { EVOCATION }, bags = { [potion] = 5 } })
    client:openSettings("AutoPotion", "AutoManaPotion")
    client:enterCombat()
    client:clickCheckbox("Evocation")
    client:nextFrame()
    assertEqual(previewOf(client), { Api.spellIcon(EVOCATION), Api.itemIcon(potion) })
    assertEqual(client:macroText("AutoManaPotion"), "#showtooltip\n/use item:" .. potion)

    client:leaveCombat()
    client:nextFrame()
    assertEqual(client:macroText("AutoManaPotion"),
      "#showtooltip\n/castsequence [@player] reset=" .. EVOCATION_RESET[flavor] .. " Evocation, item:" .. potion)
    assertEqual(client.blockedActions, {})
  end)

  test(flavor .. ": the ticked mana spells stay ticked after a reload", function()
    local client = character(flavor, "MAGE", { knownSpells = { EVOCATION } })
    tick(client, "Evocation")
    client = client:reload()
    client:openSettings("AutoPotion", "AutoManaPotion")
    assertEqual(client:isChecked("Evocation"), true)
    assertEqual(client:macroText("AutoManaPotion"), "#showtooltip\n/cast [@player] Evocation")
  end)

  test(flavor .. ": settings saved before mana spells existed load with none ticked", function()
    local client = character(flavor, "MAGE", {
      knownSpells = { EVOCATION },
      savedVariables = { HAMDB = { version = 1, activatedSpells = { DESPERATE_PRAYER }, useManaGems = false } },
    })
    client:openSettings("AutoPotion", "AutoManaPotion")
    assertEqual(client:isChecked("Evocation"), false)
    assertEqual(client:isChecked("Use mana gems"), false)
    assertEqual(client:macroText("AutoManaPotion"), "#showtooltip")
    assertEqual(client.errors, {})
  end)

  test(flavor .. ": mana spells leave the heal spells and the AutoPotion macro alone", function()
    local client = character(flavor, "PRIEST", { knownSpells = { DESPERATE_PRAYER } })
    client:openSettings("AutoPotion", "AutoPotion")
    local healBoxes, healMacro = client:checkboxLabels(), client:macroText("AutoPotion")
    assertEqual(contains(healBoxes, "Evocation"), false)

    client:openSettings("AutoPotion", "AutoManaPotion")
    assertEqual(contains(client:checkboxLabels(), "Desperate Prayer"), false)
    client:clickCheckbox("Innervate")
    client:nextFrame()
    client:openSettings("AutoPotion", "AutoPotion")
    assertEqual(client:checkboxLabels(), healBoxes)
    assertEqual(client:isChecked("Desperate Prayer"), true)
    assertEqual(client:macroText("AutoPotion"), healMacro)
  end)

  test(flavor .. ": hovering a mana spell's box shows the spell's tooltip", function()
    local client = character(flavor, "MAGE")
    client:openSettings("AutoPotion", "AutoManaPotion")
    assertEqual(client:hoverCheckbox("Evocation"), { "spell:" .. EVOCATION })
  end)
end

-- The flavor's mana spells, each under its class's header, best restore first.
local PAGE = {
  retail = {
    headings = { "Mana Spells", "Priest", "Mage", "Druid" },
    boxes = { "Mindbender", "Symbol of Hope", "Evocation", "Innervate" },
  },
  classic = {
    headings = { "Mana Spells", "Priest", "Shaman", "Mage", "Druid" },
    boxes = { "Shadowfiend", "Dispersion", "Shamanistic Rage", "Mana Tide Totem", "Evocation", "Innervate" },
  },
  forever = {
    headings = { "Mana Spells", "Priest", "Shaman", "Mage", "Druid", "Other / Racial" },
    boxes = { "Dark Sacrifice", "Mana Tide Totem", "Evocation", "Innervate", "Read Leyline" },
  },
}
local ALL_HEADINGS = { "Mana Spells", "Warrior", "Paladin", "Hunter", "Rogue", "Priest", "Death Knight",
  "Shaman", "Mage", "Warlock", "Monk", "Druid", "Evoker", "Other / Racial" }
local ALL_SPELLS = { "Evocation", "Innervate", "Mana Tide Totem", "Shadowfiend", "Dispersion",
  "Shamanistic Rage", "Mindbender", "Symbol of Hope", "Dark Sacrifice", "Read Leyline" }

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": the mana potion page lists the flavor's mana spells under class headers, all off", function()
    local client = character(flavor, "WARRIOR")
    client:openSettings("AutoPotion", "AutoManaPotion")
    assertEqual(only(client:headings(), ALL_HEADINGS), PAGE[flavor].headings)
    local boxes = only(client:checkboxLabels(), ALL_SPELLS)
    table.sort(boxes)
    local expected = { unpack(PAGE[flavor].boxes) }
    table.sort(expected)
    assertEqual(boxes, expected)
    for _, label in ipairs(boxes) do assertEqual(client:isChecked(label), false, label) end
  end)
end

-- No talent on Retail, Classic Era or Forever shortens a mana spell's cooldown for good (Wrath and
-- Cata's Arcane Flows and Veiled Shadows are checked by scripts/wago_check.py)
test("retail: mana spells follow the flavor's order, not the order they were ticked", function()
  local client = character("retail", "PRIEST", { knownSpells = { MINDBENDER, SYMBOL_OF_HOPE } })
  tick(client, "Symbol of Hope", "Mindbender")
  assertEqual(client:macroText("AutoManaPotion"),
    "#showtooltip\n/castsequence [@player] reset=combat/60 Mindbender, Symbol of Hope")
end)

test("classic: Season of Discovery's Shadowfiend goes before its Dispersion", function()
  local client = character("classic", "PRIEST", { knownSpells = { SOD_SHADOWFIEND, SOD_DISPERSION } })
  tick(client, "Dispersion", "Shadowfiend")
  assertEqual(client:macroText("AutoManaPotion"),
    "#showtooltip\n/castsequence [@player] reset=combat/300 Shadowfiend, Dispersion")
end)

test("classic: a shaman who knows a higher rank of Mana Tide Totem gets it by name", function()
  local client = character("classic", "SHAMAN", { knownSpells = { MANA_TIDE_TOTEM_R3 } })
  tick(client, "Mana Tide Totem")
  assertEqual(client:macroText("AutoManaPotion"), "#showtooltip\n/cast [@player] Mana Tide Totem")
end)

test("forever: Mana Tide Totem's new fourth rank counts", function()
  local client = character("forever", "SHAMAN", { knownSpells = { MANA_TIDE_TOTEM_R4 } })
  tick(client, "Mana Tide Totem")
  assertEqual(client:macroText("AutoManaPotion"), "#showtooltip\n/cast [@player] Mana Tide Totem")
end)

test("forever: an Undead Skyborne priest gets Dark Sacrifice before Read Leyline", function()
  local client = character("forever", "PRIEST", { knownSpells = { DARK_SACRIFICE_R5, READ_LEYLINE } })
  tick(client, "Read Leyline", "Dark Sacrifice")
  assertEqual(client:macroText("AutoManaPotion"),
    "#showtooltip\n/castsequence [@player] reset=combat/600 Dark Sacrifice, Read Leyline")
end)

test("forever: Season of Discovery runes in Forever's client aren't offered", function()
  local client = character("forever", "PRIEST")
  client:openSettings("AutoPotion", "AutoManaPotion")
  assertEqual(contains(client:checkboxLabels(), "Shadowfiend"), false)
  assertEqual(contains(client:checkboxLabels(), "Dispersion"), false)
end)
