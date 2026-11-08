-- Weakest potion first: the "Weakest Potion First" box on the main page turns the health potion
-- priority around, "Weakest Mana Potion First" on the AutoManaPotion page the mana potion one.
-- Within one strength the usual order stays, and zone-locked items still go first.
local Client = require("fake.client")
local Api = require("fake.api")

local HEALTH_BOX = "Weakest Potion First"
local MANA_BOX = "Weakest Mana Potion First"

-- Classic Era and Forever
local MAJOR_HEALING_POTION, SUPERIOR_HEALING_POTION, MINOR_HEALING_POTION = 13446, 3928, 118
local LESSER_HEALING_POTION = 858
local MAJOR_HEALTHSTONE, MINOR_HEALTHSTONE = 9421, 5512
local MAJOR_HEALING_DRAUGHT = 17348
local MAJOR_MANA_POTION, MINOR_MANA_POTION, LESSER_MANA_POTION = 13444, 2455, 3385
local COMBAT_MANA_POTION, SUPERIOR_MANA_POTION = 18841, 13443
local MANA_RUBY, MANA_AGATE = 8008, 5514
-- Forever
local PERISHABLE_MINOR_HEALING_POTION, MINOR_HEALING_POTION_FOREVER = 268881, 287966
local WINDSTONE = 255663
local ZONE_MAJOR = 223913
local ZEPHRAS_ISLE, DUSKWOOD = 2991, 1431
-- Retail
local SILVERMOON_POTION_R2, FLEETING_SILVERMOON_POTION_R1, SILVERMOON_POTION_R1 = 241304, 245919, 241305
local ALGARI_HEALING_POTION_R3, ALGARI_HEALING_POTION_R1 = 211880, 211878
local HEALTHSTONE = 5512
local CAVEDWELLERS_DELIGHT_R3, CAVEDWELLERS_DELIGHT_R1 = 212244, 212242
local REFRESHING_SERUM_R2 = 241306
local MASTER_MANA_POTION, ALCHEMISTS_REJUVENATION = 76098, 76094
local LIGHTFUSED_MANA_POTION = 241300

local function drinksPotion(...)
  local items = {}
  for i, id in ipairs({ ... }) do items[i] = "item:" .. id end
  return "#showtooltip \n/castsequence [@player] reset=combat " .. table.concat(items, ", ")
end

local function drinksManaPotion(itemId)
  return "#showtooltip\n/use item:" .. itemId
end

local function previewOf(client)
  local icons = {}
  for i, shown in ipairs(client:previewIcons()) do icons[i] = shown.icon end
  return icons
end

local function icons(...)
  local list = {}
  for i, id in ipairs({ ... }) do list[i] = Api.itemIcon(id) end
  return list
end

-- A character with these bags who ticked the box with this label on its settings page.
local function ticked(label, flavor, bags, options)
  options = options or {}
  options.flavor = flavor
  options.bags = bags
  options.class = options.class or "MAGE"
  local client = Client.new(options)
  client:login()
  client:openSettings("AutoPotion", label == MANA_BOX and "AutoManaPotion" or "AutoPotion")
  client:clickCheckbox(label)
  client:nextFrame()
  return client
end

for _, flavor in ipairs({ "classic", "forever", "retail" }) do
  test(flavor .. ": both boxes are off by default and the macros use the strongest potions", function()
    local client = Client.new({ flavor = flavor, class = "MAGE",
      bags = { [MAJOR_HEALING_POTION] = 5, [MINOR_HEALING_POTION] = 5, [MAJOR_MANA_POTION] = 5, [MINOR_MANA_POTION] = 5 } })
    client:login()
    client:openSettings("AutoPotion", "AutoPotion")
    assertEqual(client:isChecked(HEALTH_BOX), false)
    client:openSettings("AutoPotion", "AutoManaPotion")
    assertEqual(client:isChecked(MANA_BOX), false)
    if flavor ~= "retail" then
      assertEqual(client:macroText("AutoPotion"), drinksPotion(MAJOR_HEALING_POTION))
      assertEqual(client:macroText("AutoManaPotion"), drinksManaPotion(MAJOR_MANA_POTION))
    end
  end)
end

for _, flavor in ipairs({ "classic", "forever" }) do
  test(flavor .. ": with Weakest Potion First AutoPotion uses the weakest health potion", function()
    local client = ticked(HEALTH_BOX, flavor,
      { [MAJOR_HEALING_POTION] = 5, [SUPERIOR_HEALING_POTION] = 5, [LESSER_HEALING_POTION] = 5 })
    assertEqual(client:macroText("AutoPotion"), drinksPotion(LESSER_HEALING_POTION))
    assertEqual(client:macroText("AutoManaPotion"), "#showtooltip")
    assertEqual(client.errors, {})
  end)

  test(flavor .. ": a stronger potion looted later doesn't replace the weakest, running out moves to the next-weakest", function()
    local client = ticked(HEALTH_BOX, flavor, { [SUPERIOR_HEALING_POTION] = 5, [LESSER_HEALING_POTION] = 1 })
    client:addToBags(MAJOR_HEALING_POTION, 5)
    client:nextFrame()
    assertEqual(client:macroText("AutoPotion"), drinksPotion(LESSER_HEALING_POTION))

    client:addToBags(LESSER_HEALING_POTION, -1)
    client:nextFrame()
    assertEqual(client:macroText("AutoPotion"), drinksPotion(SUPERIOR_HEALING_POTION))
  end)

  test(flavor .. ": the healthstone stays the best one with Weakest Potion First", function()
    local client = ticked(HEALTH_BOX, flavor, { [MAJOR_HEALTHSTONE] = 1, [MINOR_HEALTHSTONE] = 1,
      [MAJOR_HEALING_POTION] = 5, [MINOR_HEALING_POTION] = 5 })
    assertEqual(client:macroText("AutoPotion"), drinksPotion(MAJOR_HEALTHSTONE, MINOR_HEALING_POTION))
  end)

  test(flavor .. ": with Low Priority Healthstones too the weakest potion goes before the healthstone", function()
    local client = ticked(HEALTH_BOX, flavor, { [MAJOR_HEALTHSTONE] = 1,
      [MAJOR_HEALING_POTION] = 5, [MINOR_HEALING_POTION] = 5 })
    client:clickCheckbox("Low Priority Healthstones")
    client:nextFrame()
    assertEqual(client:macroText("AutoPotion"), drinksPotion(MINOR_HEALING_POTION, MAJOR_HEALTHSTONE))
  end)

  test(flavor .. ": battleground draughts still go first with Weakest Potion First", function()
    local client = ticked(HEALTH_BOX, flavor, { [MAJOR_HEALING_DRAUGHT] = 5,
      [MAJOR_HEALING_POTION] = 5, [MINOR_HEALING_POTION] = 5 }, { instanceType = "pvp" })
    assertEqual(client:macroText("AutoPotion"), drinksPotion(MAJOR_HEALING_DRAUGHT))
  end)

  test(flavor .. ": with Weakest Mana Potion First AutoManaPotion uses the weakest mana potion", function()
    local client = ticked(MANA_BOX, flavor,
      { [MAJOR_MANA_POTION] = 5, [LESSER_MANA_POTION] = 5, [MINOR_MANA_POTION] = 5 })
    assertEqual(client:macroText("AutoManaPotion"), drinksManaPotion(MINOR_MANA_POTION))
    assertEqual(client.errors, {})
  end)

  test(flavor .. ": the boxes are separate: Weakest Mana Potion First leaves the health potion alone", function()
    local client = ticked(MANA_BOX, flavor, { [MAJOR_HEALING_POTION] = 5, [MINOR_HEALING_POTION] = 5,
      [MAJOR_MANA_POTION] = 5, [MINOR_MANA_POTION] = 5 })
    assertEqual(client:macroText("AutoPotion"), drinksPotion(MAJOR_HEALING_POTION))
    assertEqual(client:macroText("AutoManaPotion"), drinksManaPotion(MINOR_MANA_POTION))
  end)

  test(flavor .. ": mana potions of the same strength keep their order with Weakest Mana Potion First", function()
    -- Combat and Superior Mana Potion restore the same; Combat goes first either way
    local client = ticked(MANA_BOX, flavor,
      { [MAJOR_MANA_POTION] = 5, [SUPERIOR_MANA_POTION] = 5, [COMBAT_MANA_POTION] = 5 })
    assertEqual(client:macroText("AutoManaPotion"), drinksManaPotion(COMBAT_MANA_POTION))
  end)

  test(flavor .. ": the mana gem stays the best one with Weakest Mana Potion First", function()
    local client = ticked(MANA_BOX, flavor, { [MANA_RUBY] = 1, [MANA_AGATE] = 1,
      [MAJOR_MANA_POTION] = 5, [MINOR_MANA_POTION] = 5 })
    assertEqual(client:macroText("AutoManaPotion"),
      "#showtooltip\n/castsequence reset=combat item:" .. MANA_RUBY .. ", item:" .. MINOR_MANA_POTION)
  end)

  test(flavor .. ": the previews show the weakest potion first", function()
    local client = ticked(HEALTH_BOX, flavor,
      { [MAJOR_HEALING_POTION] = 5, [SUPERIOR_HEALING_POTION] = 5, [MINOR_HEALING_POTION] = 5 })
    assertEqual(previewOf(client), icons(MINOR_HEALING_POTION))

    client:openSettings("AutoPotion", "AutoManaPotion")
    client:clickCheckbox(MANA_BOX)
    client:nextFrame()
    client:addToBags(MAJOR_MANA_POTION, 5)
    client:addToBags(MINOR_MANA_POTION, 5)
    client:nextFrame()
    assertEqual(previewOf(client), icons(MINOR_MANA_POTION, MAJOR_MANA_POTION))
  end)

  test(flavor .. ": unticking brings back the strongest potion; the setting survives a reload", function()
    local client = ticked(HEALTH_BOX, flavor, { [MAJOR_HEALING_POTION] = 5, [MINOR_HEALING_POTION] = 5 })
    client = client:reload()
    client:openSettings("AutoPotion", "AutoPotion")
    assertEqual(client:isChecked(HEALTH_BOX), true)
    assertEqual(client:macroText("AutoPotion"), drinksPotion(MINOR_HEALING_POTION))

    client:clickCheckbox(HEALTH_BOX)
    client:nextFrame()
    assertEqual(client:macroText("AutoPotion"), drinksPotion(MAJOR_HEALING_POTION))
  end)

  test(flavor .. ": ticking the box in combat changes the macro when combat ends", function()
    local client = Client.new({ flavor = flavor, bags = { [MAJOR_HEALING_POTION] = 5, [MINOR_HEALING_POTION] = 5 } })
    client:login()
    client:openSettings("AutoPotion", "AutoPotion")
    client:enterCombat()
    client:clickCheckbox(HEALTH_BOX)
    client:advance(1)
    assertEqual(client.blockedActions, {})
    assertEqual(client:macroText("AutoPotion"), drinksPotion(MAJOR_HEALING_POTION))

    client:leaveCombat()
    assertEqual(client:macroText("AutoPotion"), drinksPotion(MINOR_HEALING_POTION))
  end)

  test(flavor .. ": the boxes explain themselves", function()
    local client = Client.new({ flavor = flavor })
    client:login()
    client:openSettings("AutoPotion", "AutoPotion")
    local health = table.concat(client:hoverCheckbox(HEALTH_BOX), " ")
    client:openSettings("AutoPotion", "AutoManaPotion")
    local mana = table.concat(client:hoverCheckbox(MANA_BOX), " ")
    for _, text in ipairs({ health, mana }) do
      assertEqual(text:find("weakest", 1, true) ~= nil, true, text)
      assertEqual(text:find("leveling", 1, true) ~= nil, true, text)
      assertEqual(text:find("whatever its level", 1, true) ~= nil, true, text)
    end
  end)
end

test("forever: a Perishable potion still goes before the plain one of the same strength", function()
  local client = ticked(HEALTH_BOX, "forever", { [MAJOR_HEALING_POTION] = 5, [MINOR_HEALING_POTION] = 5,
    [MINOR_HEALING_POTION_FOREVER] = 5, [PERISHABLE_MINOR_HEALING_POTION] = 5 })
  assertEqual(client:macroText("AutoPotion"), drinksPotion(PERISHABLE_MINOR_HEALING_POTION))
end)

test("forever: Windstone still goes first on Zephras Isle", function()
  local client = ticked(HEALTH_BOX, "forever", { [WINDSTONE] = 5, [MAJOR_HEALING_POTION] = 5,
    [MINOR_HEALING_POTION] = 5 }, { instanceMapId = ZEPHRAS_ISLE })
  assertEqual(client:macroText("AutoPotion"), drinksPotion(WINDSTONE))
end)

test("forever: a zone-locked potion still goes first in its zone", function()
  local client = ticked(HEALTH_BOX, "forever", { [ZONE_MAJOR] = 5, [MAJOR_HEALING_POTION] = 5,
    [MINOR_HEALING_POTION] = 5 }, { mapId = DUSKWOOD })
  assertEqual(client:macroText("AutoPotion"), drinksPotion(ZONE_MAJOR))
end)

test("retail: the weakest rank goes first and Fleeting before the plain potion of the same rank", function()
  local client = ticked(HEALTH_BOX, "retail", { [SILVERMOON_POTION_R2] = 5, [SILVERMOON_POTION_R1] = 5,
    [FLEETING_SILVERMOON_POTION_R1] = 5, [ALGARI_HEALING_POTION_R3] = 5, [ALGARI_HEALING_POTION_R1] = 5 })
  assertEqual(client:macroText("AutoPotion"), drinksPotion(ALGARI_HEALING_POTION_R1))

  client:addToBags(ALGARI_HEALING_POTION_R1, -5)
  client:addToBags(ALGARI_HEALING_POTION_R3, -5)
  client:nextFrame()
  assertEqual(client:macroText("AutoPotion"), drinksPotion(FLEETING_SILVERMOON_POTION_R1))
end)

test("retail: Cavedweller's Delight is turned around too and stays after the normal potions", function()
  local client = ticked(HEALTH_BOX, "retail", { [HEALTHSTONE] = 1, [SILVERMOON_POTION_R2] = 5,
    [ALGARI_HEALING_POTION_R1] = 5, [REFRESHING_SERUM_R2] = 5, [CAVEDWELLERS_DELIGHT_R3] = 5,
    [CAVEDWELLERS_DELIGHT_R1] = 5 })
  assertEqual(client:macroText("AutoPotion"),
    drinksPotion(HEALTHSTONE, ALGARI_HEALING_POTION_R1, CAVEDWELLERS_DELIGHT_R1))
end)

test("retail: a plain mana potion still goes before the rejuvenation potion of the same strength", function()
  local client = ticked(MANA_BOX, "retail", { [LIGHTFUSED_MANA_POTION] = 5, [MASTER_MANA_POTION] = 5,
    [ALCHEMISTS_REJUVENATION] = 5 })
  assertEqual(client:macroText("AutoManaPotion"), drinksManaPotion(MASTER_MANA_POTION))
end)
