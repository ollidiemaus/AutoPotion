-- "Only when the buff is missing" on clients that aren't English: the addon reads the food buff's
-- and Relaxed's names at load from spell IDs, so it finds them by their translated names.
local Client = require("fake.client")

local WELL_FED = 19705         -- the spell the addon reads Well Fed's translated name from
local FOOD_BUFF = 1232585      -- any other Well Fed, as a food leaves it
local HEARTY_NAME = 454188     -- Retail: the spell the addon reads Hearty Well Fed's name from
local HEARTY_WELL_FED = 462180 -- Retail: a Hearty Well Fed from hearty food
local RELAXED_NAME = 1269152   -- Retail: the spell the addon reads Relaxed's name from
local RELAXED = 1269167        -- Retail: any other Relaxed, as a tea leaves it
local WELL_FED_NAMES = { enUS = "Well Fed", deDE = "Satt", frFR = "Bien nourri" }
local HEARTY_NAMES = { enUS = "Hearty Well Fed", deDE = "Zünftig satt" }
local RELAXED_NAMES = { enUS = "Relaxed", deDE = "Entspannt", frFR = "Décontraction" }
local SPELLS = {
  [WELL_FED] = { names = WELL_FED_NAMES }, [FOOD_BUFF] = { names = WELL_FED_NAMES },
  [HEARTY_NAME] = { names = HEARTY_NAMES }, [HEARTY_WELL_FED] = { names = HEARTY_NAMES },
  [RELAXED_NAME] = { names = RELAXED_NAMES }, [RELAXED] = { names = RELAXED_NAMES },
}

-- Buff and normal food and drink, in their order in the lists.
local CLASSIC_ERA_FOOD = { buff = 13928, normal = 8952 } -- Grilled Squid, Roasted Quail
local FOOD = {
  retail = { buff = 242747, normal = 264992 }, -- Hearty Royal Roast, Blood Knight Burger
  classic = CLASSIC_ERA_FOOD,
  forever = CLASSIC_ERA_FOOD,
}
local DRINK = { buff = 242298, normal = 242297 } -- Retail: Argentleaf Tea, Mana Lily Tea

local function uses(itemId)
  return "#showtooltip\n/use [@player] item:" .. itemId
end

-- A logged-in character on a client in this locale, with these items, preferring buff food and
-- drinks while their buff is missing.
local function character(flavor, locale, items)
  local bags = {}
  for _, itemId in ipairs(items) do bags[itemId] = 5 end
  local client = Client.new({ flavor = flavor, locale = locale, bags = bags, spells = SPELLS })
  client:login()
  client:openSettings("AutoPotion", "AutoFood")
  client:clickCheckbox("Include Buff Food")
  client:clickCheckbox("Only when the buff is missing")
  client:nextFrame()
  return client
end

for _, locale in ipairs({ "deDE", "frFR" }) do
  for _, flavor in ipairs(Client.FLAVOR_NAMES) do
    local food = FOOD[flavor]
    test(flavor .. " " .. locale .. ": " .. WELL_FED_NAMES[locale] .. " puts buff food after normal food", function()
      local client = character(flavor, locale, { food.buff, food.normal })
      assertEqual(client:macroText("AutoFood"), uses(food.buff), "without the food buff")
      client:gainAura(FOOD_BUFF)
      client:nextFrame()
      assertEqual(client:macroText("AutoFood"), uses(food.normal), "with the food buff")
      client:loseAura(FOOD_BUFF)
      client:nextFrame()
      assertEqual(client:macroText("AutoFood"), uses(food.buff), "after it fell off")
    end)
  end
end

test("retail deDE: gaining Zünftig satt puts buff food after normal food", function()
  local client = character("retail", "deDE", { FOOD.retail.buff, FOOD.retail.normal })
  assertEqual(client:macroText("AutoFood"), uses(FOOD.retail.buff), "without the food buff")
  client:gainAura(HEARTY_WELL_FED)
  client:nextFrame()
  assertEqual(client:macroText("AutoFood"), uses(FOOD.retail.normal), "with the food buff")
end)

for _, locale in ipairs({ "deDE", "frFR" }) do
  test("retail " .. locale .. ": gaining " .. RELAXED_NAMES[locale] .. " puts buff drinks after normal drink", function()
    local client = character("retail", locale, { DRINK.buff, DRINK.normal })
    assertEqual(client:macroText("AutoDrink"), uses(DRINK.buff), "without Relaxed")
    client:gainAura(RELAXED)
    client:nextFrame()
    assertEqual(client:macroText("AutoDrink"), uses(DRINK.normal), "with Relaxed")
  end)
end
