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
