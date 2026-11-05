-- Which food the AutoFood macro eats, with "Include Buff Food" at its default (off).
local Client = require("fake.client")

local BOILED_CLAMS = 5525

local function autoFood(flavor, bags)
  local client = Client.new({ flavor = flavor, bags = bags })
  client:login()
  return client:macroText("AutoFood")
end

-- Forever's Boiled Clams cast plain Food (spell 433, like Tough Jerky) and give no food buff.
test("forever: Boiled Clams are eaten like plain food with buff food left out", function()
  assertEqual(autoFood("forever", { [BOILED_CLAMS] = 5 }), "#showtooltip\n/use [@player] item:5525")
end)

test("classic: Boiled Clams are buff food and left out", function()
  assertEqual(autoFood("classic", { [BOILED_CLAMS] = 5 }), "#showtooltip")
end)

-- Forever's Longjaw Mud Snapper casts Nutritious Food; other flavors' is plain food.
local LONGJAW_MUD_SNAPPER = 4592

test("forever: Longjaw Mud Snapper is Nutritious food and left out", function()
  assertEqual(autoFood("forever", { [LONGJAW_MUD_SNAPPER] = 5 }), "#showtooltip")
end)

test("classic: Longjaw Mud Snapper is eaten like plain food", function()
  assertEqual(autoFood("classic", { [LONGJAW_MUD_SNAPPER] = 5 }), "#showtooltip\n/use [@player] item:4592")
end)
