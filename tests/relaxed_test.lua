-- "Only when the buff is missing" for AutoDrink on Retail: Relaxed decides where the buff drinks
-- (Argentleaf, Sanguithorn and Azeroot Tea) go, the way the food buff does for AutoFood. The two
-- buffs are checked separately.
local Client = require("fake.client")
local Api = require("fake.api")

local RELAXED_NAME = 1269152 -- the spell the addon reads Relaxed's translated name from
local RELAXED = 1269167      -- any other Relaxed, as a tea leaves it
local WELL_FED = 19705
local FOOD_BUFF = 1232585    -- a Well Fed, as a food leaves it
local SPELLS = {
  [RELAXED_NAME] = { name = "Relaxed" }, [RELAXED] = { name = "Relaxed" },
  [WELL_FED] = { name = "Well Fed" }, [FOOD_BUFF] = { name = "Well Fed" },
}

local DRINK = { conjured = 265099, buff = 242298, normal = 242297 } -- Conjured Tea, Argentleaf Tea, Mana Lily Tea
local FOOD = { buff = 242747, normal = 264992 }                     -- Hearty Royal Roast, Blood Knight Burger

local function uses(itemId)
  return "#showtooltip\n/use [@player] item:" .. itemId
end

-- A logged-in Retail character with these items, on the AutoFood page.
local function character(items, options)
  options = options or {}
  local bags = {}
  for _, itemId in ipairs(items) do bags[itemId] = 5 end
  local client = Client.new({ flavor = "retail", bags = bags, spells = SPELLS, auras = options.auras })
  client:login()
  client:openSettings("AutoPotion", "AutoFood")
  return client
end

local function preferBuffFood(client)
  client:clickCheckbox("Include Buff Food")
  client:clickCheckbox("Only when the buff is missing")
  client:nextFrame()
end

local function previewOf(client)
  local icons = {}
  for i, shown in ipairs(client:previewIcons()) do icons[i] = shown.icon end
  return icons
end

test("retail: without Relaxed, buff drinks come before conjured drink", function()
  local client = character({ DRINK.conjured, DRINK.buff, DRINK.normal })
  preferBuffFood(client)
  assertEqual(client:macroText("AutoDrink"), uses(DRINK.buff))
end)

test("retail: gaining Relaxed puts buff drinks after normal drink, losing it puts them back", function()
  local client = character({ DRINK.buff, DRINK.normal })
  preferBuffFood(client)
  client:gainAura(RELAXED)
  client:nextFrame()
  assertEqual(client:macroText("AutoDrink"), uses(DRINK.normal), "with Relaxed")
  client:loseAura(RELAXED)
  client:nextFrame()
  assertEqual(client:macroText("AutoDrink"), uses(DRINK.buff), "after it fell off")
end)

test("retail: with only buff drinks in the bags, the macro drinks one while the player is Relaxed", function()
  local client = character({ DRINK.buff })
  preferBuffFood(client)
  client:gainAura(RELAXED)
  client:nextFrame()
  assertEqual(client:macroText("AutoDrink"), uses(DRINK.buff))
end)

test("retail: Relaxed doesn't move buff food, Well Fed doesn't move buff drinks", function()
  local client = character({ DRINK.buff, DRINK.normal, FOOD.buff, FOOD.normal })
  preferBuffFood(client)
  client:gainAura(RELAXED)
  client:nextFrame()
  assertEqual(client:macroText("AutoFood"), uses(FOOD.buff), "AutoFood with Relaxed")
  assertEqual(client:macroText("AutoDrink"), uses(DRINK.normal), "AutoDrink with Relaxed")
  client:loseAura(RELAXED)
  client:gainAura(FOOD_BUFF)
  client:nextFrame()
  assertEqual(client:macroText("AutoFood"), uses(FOOD.normal), "AutoFood with Well Fed")
  assertEqual(client:macroText("AutoDrink"), uses(DRINK.buff), "AutoDrink with Well Fed")
end)

test("retail: Relaxed gained in combat changes the macro once combat ends", function()
  local client = character({ DRINK.buff, DRINK.normal })
  preferBuffFood(client)
  client:enterCombat()
  client:gainAura(RELAXED)
  client:nextFrame()
  assertEqual(client:macroText("AutoDrink"), uses(DRINK.buff), "in combat")
  assertEqual(#client.blockedActions, 0, "blocked actions")
  client:leaveCombat()
  client:nextFrame()
  assertEqual(client:macroText("AutoDrink"), uses(DRINK.normal), "after combat")
end)

test("retail: the Drink page's Current Priority preview shows the macro's order", function()
  local client = character({ DRINK.conjured, DRINK.buff, DRINK.normal })
  preferBuffFood(client)
  client:openSettings("AutoPotion", "AutoDrink")
  assertEqual(previewOf(client), { Api.itemIcon(DRINK.buff), Api.itemIcon(DRINK.conjured), Api.itemIcon(DRINK.normal) })
  client:gainAura(RELAXED)
  assertEqual(previewOf(client), { Api.itemIcon(DRINK.conjured), Api.itemIcon(DRINK.normal), Api.itemIcon(DRINK.buff) },
    "with Relaxed, before the macro rebuild")
  client:nextFrame()
  assertEqual(client:macroText("AutoDrink"), uses(DRINK.conjured))
end)

test("retail: with the sub-option off, buff drinks keep their place and Relaxed changes nothing", function()
  local client = character({ DRINK.conjured, DRINK.buff, DRINK.normal })
  client:clickCheckbox("Include Buff Food")
  client:nextFrame()
  assertEqual(client:macroText("AutoDrink"), uses(DRINK.conjured))
  local writes = client:macroWrites({ "AutoDrink" })
  client:gainAura(RELAXED)
  client:nextFrame()
  assertEqual(client:macroText("AutoDrink"), uses(DRINK.conjured))
  assertEqual(client:macroWrites({ "AutoDrink" }), writes, "macro writes")
end)

test("retail: logging in Relaxed puts buff drinks last", function()
  local client = character({ DRINK.buff, DRINK.normal }, { auras = { RELAXED } })
  preferBuffFood(client)
  client = client:reload()
  assertEqual(client:macroText("AutoDrink"), uses(DRINK.normal))
end)

test("retail: while auras are hidden, the remembered Relaxed stays", function()
  local client = character({ DRINK.buff, DRINK.normal })
  preferBuffFood(client)
  client:gainAura(RELAXED)
  client:nextFrame()
  client:hideAuras()
  client:loseAura(RELAXED)
  client:nextFrame()
  assertEqual(client:macroText("AutoDrink"), uses(DRINK.normal), "with auras hidden")
  client:showAuras()
  client:nextFrame()
  assertEqual(client:macroText("AutoDrink"), uses(DRINK.buff), "with auras visible again")
end)
