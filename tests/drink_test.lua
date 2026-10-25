-- Which drink the AutoDrink macro uses: only items that restore mana.
local Client = require("fake.client")

local BOBBING_APPLE = 20516
local COOKED_CRAB_CLAW = 2682
local GRACCUS_FRUITCAKE = 21215

local function autoDrink(flavor, bags)
  local client = Client.new({ flavor = flavor, class = "MAGE", bags = bags })
  client:login()
  return client:macroText("AutoDrink")
end

-- Bobbing Apple casts spell 24869 there, which restores health only (24707 on Cata and Mists
-- restores mana too).
for _, flavor in ipairs({ "classic", "forever" }) do
  test(flavor .. ": Bobbing Apple is left out of the drink macro", function()
    assertEqual(autoDrink(flavor, { [BOBBING_APPLE] = 5 }), "#showtooltip")
  end)

  test(flavor .. ": Graccu's Mince Meat Fruitcake restores mana and is drunk", function()
    assertEqual(autoDrink(flavor, { [GRACCUS_FRUITCAKE] = 5, [BOBBING_APPLE] = 5 }),
      "#showtooltip\n/use [@player] item:21215")
  end)
end

-- Forever's Cooked Crab Claw casts Nutritious Food (Food 433 and an Intellect Well Fed), no mana.
test("forever: Cooked Crab Claw is left out of the drink macro", function()
  assertEqual(autoDrink("forever", { [COOKED_CRAB_CLAW] = 5 }), "#showtooltip")
end)

test("classic: Cooked Crab Claw restores mana and is drunk", function()
  assertEqual(autoDrink("classic", { [COOKED_CRAB_CLAW] = 5 }), "#showtooltip\n/use [@player] item:2682")
end)
