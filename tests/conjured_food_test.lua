-- Retail's Conjure Refreshment makes a different item at each level (Mana Cookie at 10 up to
-- Mana Bun). Each restores health and mana alike, so both AutoFood and AutoDrink use it first.
local Client = require("fake.client")

local BLOOD_KNIGHT_BURGER = 264992 -- plain food
local MANA_LILY_TEA = 242297       -- plain drink

local CONJURED = {
  { 65500, "Conjured Mana Cookie" },
  { 65515, "Conjured Mana Brownie" },
  { 65516, "Conjured Mana Cupcake" },
  { 65517, "Conjured Mana Lollipop" },
  { 43518, "Conjured Mana Pie" },
  { 43523, "Conjured Mana Strudel" },
  { 65499, "Conjured Mana Cake" },
  { 80610, "Conjured Mana Pudding" },
  { 80618, "Conjured Mana Fritter" },
}

local function macros(bags)
  local client = Client.new({ flavor = "retail", class = "MAGE", bags = bags })
  client:login()
  return client:macroText("AutoFood"), client:macroText("AutoDrink")
end

for _, item in ipairs(CONJURED) do
  local id, name = item[1], item[2]
  test("retail: " .. name .. " is eaten and drunk before plain food and drink", function()
    local food, drink = macros({ [id] = 5, [BLOOD_KNIGHT_BURGER] = 5, [MANA_LILY_TEA] = 5 })
    assertEqual(food, "#showtooltip\n/use [@player] item:" .. id)
    assertEqual(drink, "#showtooltip\n/use [@player] item:" .. id)
  end)
end
