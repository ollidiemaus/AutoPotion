-- Zone-locked items on Forever: a macro uses one only on the map the game allows it on, and there
-- it goes first.
local Client = require("fake.client")

local ZEPHRAS_ISLE = 2991
local DARKSPEAR_ISLANDS = 2997
local KALIMDOR = 1

local WINDSTONE = 255663
local MINOR_HEALING_POTION = 118
local MINOR_MANA_POTION = 2455
local DARKSPEAR_SILK = 272056
local DARKSPEAR_MAGEWEAVE = 272057
local DARKSPEAR_RUNECLOTH = 272058
local HEAVY_RUNECLOTH = 14530

local function bandages(itemId)
  return "#showtooltip\n/use [@player] item:" .. itemId
end

local function drinksPotion(itemId)
  return "#showtooltip \n/castsequence [@player] reset=combat item:" .. itemId
end

local function drinksManaPotion(itemId)
  return "#showtooltip\n/use item:" .. itemId
end

local function character(bags, instanceMapId, options)
  options = options or {}
  local client = Client.new({
    flavor = options.flavor or "forever", class = "MAGE", bags = bags, instanceMapId = instanceMapId,
  })
  client:login()
  return client
end

test("forever: on Zephras Isle AutoPotion uses a Windstone first", function()
  local client = character({ [WINDSTONE] = 5, [MINOR_HEALING_POTION] = 5 }, ZEPHRAS_ISLE)
  assertEqual(client:macroText("AutoPotion"), drinksPotion(WINDSTONE))
end)

test("forever: away from Zephras Isle Windstone stays out of AutoPotion and AutoManaPotion", function()
  local client = character({ [WINDSTONE] = 5 }, KALIMDOR)
  assertEqual(client:macroText("AutoPotion"), "#showtooltip")
  assertEqual(client:macroText("AutoManaPotion"), "#showtooltip")
end)

test("forever: on Zephras Isle AutoManaPotion uses a Windstone first", function()
  local client = character({ [WINDSTONE] = 5, [MINOR_MANA_POTION] = 5 }, ZEPHRAS_ISLE)
  assertEqual(client:macroText("AutoManaPotion"), drinksManaPotion(WINDSTONE))
end)

test("forever: without \"Include Rejuvenation Potions\" Windstone stays off AutoManaPotion", function()
  local client = character({ [WINDSTONE] = 5, [MINOR_MANA_POTION] = 5 }, ZEPHRAS_ISLE)
  client:openSettings("AutoPotion", "AutoManaPotion")
  client:clickCheckbox("Include Rejuvenation Potions")
  client:nextFrame()
  assertEqual(client:macroText("AutoManaPotion"), drinksManaPotion(MINOR_MANA_POTION))
end)

test("forever: arriving on Zephras Isle and leaving it updates the macros", function()
  local client = character({ [WINDSTONE] = 5, [MINOR_HEALING_POTION] = 5 }, KALIMDOR)
  assertEqual(client:macroText("AutoPotion"), drinksPotion(MINOR_HEALING_POTION), "before arriving")
  client:travelTo(ZEPHRAS_ISLE)
  assertEqual(client:macroText("AutoPotion"), drinksPotion(WINDSTONE), "on the isle")
  client:travelTo(KALIMDOR)
  assertEqual(client:macroText("AutoPotion"), drinksPotion(MINOR_HEALING_POTION), "after leaving")
end)

test("forever: on Darkspear Islands AutoBandage uses the strongest Darkspear bandage first", function()
  local client = character({
    [DARKSPEAR_SILK] = 5, [DARKSPEAR_RUNECLOTH] = 5, [DARKSPEAR_MAGEWEAVE] = 5, [HEAVY_RUNECLOTH] = 5,
  }, DARKSPEAR_ISLANDS)
  assertEqual(client:macroText("AutoBandage"), bandages(DARKSPEAR_RUNECLOTH))
end)

test("forever: a weaker Darkspear bandage still goes ahead of a normal one there", function()
  local client = character({ [DARKSPEAR_SILK] = 5, [HEAVY_RUNECLOTH] = 5 }, DARKSPEAR_ISLANDS)
  assertEqual(client:macroText("AutoBandage"), bandages(DARKSPEAR_SILK))
end)

test("forever: away from Darkspear Islands its bandages stay out of AutoBandage", function()
  local client = character({ [DARKSPEAR_RUNECLOTH] = 5, [HEAVY_RUNECLOTH] = 5 }, KALIMDOR)
  assertEqual(client:macroText("AutoBandage"), bandages(HEAVY_RUNECLOTH), "with a normal bandage")
  assertEqual(character({ [DARKSPEAR_RUNECLOTH] = 5 }, KALIMDOR):macroText("AutoBandage"), "#showtooltip",
    "with only Darkspear bandages")
end)

test("classic: the zones' map IDs change nothing", function()
  local client = character({ [WINDSTONE] = 5, [DARKSPEAR_RUNECLOTH] = 5 }, ZEPHRAS_ISLE, { flavor = "classic" })
  assertEqual(client:macroText("AutoPotion"), "#showtooltip")
  assertEqual(client:macroText("AutoBandage"), "#showtooltip")
end)
