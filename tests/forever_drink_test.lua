-- Forever's Nutritious drinks are buff food, and they leave the food buff: Forever has no Relaxed.
-- So "only when the buff is missing" orders AutoDrink by the food buff there.
local Client = require("fake.client")

local WELL_FED = 19705      -- the spell the addon reads the food buff's translated name from
local NUTRITIOUS_DRINK_AURA = 1249927  -- the Well Fed that Nutritious drinks leave
local NUTRITIOUS_FOOD_AURA = 1249523   -- the Well Fed that Nutritious Food leaves
local SPELLS = {
  [WELL_FED] = { name = "Well Fed" }, [NUTRITIOUS_DRINK_AURA] = { name = "Well Fed" }, [NUTRITIOUS_FOOD_AURA] = { name = "Well Fed" },
}

local PEACE_TEA = 249865          -- Nutritious, buff food
local CONJURED_WATER = 5350
local CRISP_SPRING_WATER = 252031 -- plain

local function drinks(itemId)
  return "#showtooltip\n/use [@player] item:" .. itemId
end

local function character(bags)
  local client = Client.new({ flavor = "forever", class = "MAGE", bags = bags, spells = SPELLS })
  client:login()
  client:openSettings("AutoPotion", "AutoFood")
  return client
end

local function includeBuffFood(client)
  client:clickCheckbox("Include Buff Food")
  client:nextFrame()
end

local function preferBuffFood(client)
  includeBuffFood(client)
  client:clickCheckbox("Only when the buff is missing")
  client:nextFrame()
end

test("forever: without \"Include Buff Food\" Nutritious drinks are left out", function()
  local client = character({ [PEACE_TEA] = 5 })
  assertEqual(client:macroText("AutoDrink"), "#showtooltip")
end)

test("forever: with \"Include Buff Food\" Nutritious drinks are drunk by their place in the list", function()
  local client = character({ [PEACE_TEA] = 5, [CRISP_SPRING_WATER] = 5 })
  includeBuffFood(client)
  assertEqual(client:macroText("AutoDrink"), drinks(PEACE_TEA))
end)

test("forever: lacking the food buff, Nutritious drinks go ahead of conjured water", function()
  local client = character({ [CONJURED_WATER] = 5, [PEACE_TEA] = 5 })
  preferBuffFood(client)
  assertEqual(client:macroText("AutoDrink"), drinks(PEACE_TEA))
end)

test("forever: having the food buff, Nutritious drinks go last, and go first again once it's gone", function()
  local client = character({ [PEACE_TEA] = 5, [CRISP_SPRING_WATER] = 5 })
  preferBuffFood(client)
  client:gainAura(NUTRITIOUS_DRINK_AURA)
  client:nextFrame()
  assertEqual(client:macroText("AutoDrink"), drinks(CRISP_SPRING_WATER), "with the food buff")
  client:loseAura(NUTRITIOUS_DRINK_AURA)
  client:nextFrame()
  assertEqual(client:macroText("AutoDrink"), drinks(PEACE_TEA), "after it fell off")
end)

test("forever: a food buff that eating left counts for AutoDrink too", function()
  local client = character({ [PEACE_TEA] = 5, [CRISP_SPRING_WATER] = 5 })
  preferBuffFood(client)
  client:gainAura(NUTRITIOUS_FOOD_AURA)
  client:nextFrame()
  assertEqual(client:macroText("AutoDrink"), drinks(CRISP_SPRING_WATER))
end)
