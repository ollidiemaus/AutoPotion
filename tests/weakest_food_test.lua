-- Weakest food first: the "Weakest Food First" box on the AutoFood page makes AutoFood eat the food
-- restoring the least health first, "Weakest Drink First" on the AutoDrink page makes AutoDrink
-- drink what restores the least mana first. Conjured items still go first, their weakest first;
-- buff food keeps its place; what can't be compared with the rest goes last.
local Client = require("fake.client")
local Api = require("fake.api")

local FOOD_BOX = "Weakest Food First"
local DRINK_BOX = "Weakest Drink First"

-- Classic Era and Forever, with what they restore there, in their order in the lists
local CONJURED_SWEET_ROLL = 8076  -- conjured, 2148 health
local CONJURED_BREAD = 1113       -- conjured, 243.6 health
local CONJURED_MUFFIN = 5349      -- conjured, 61.2 health
local GRILLED_SQUID = 13928       -- buff food
local SENGGIN_ROOT = 3448         -- dual restore, 294 health and 294 mana
local ROASTED_QUAIL = 8952        -- 2148 health
local FINE_AGED_CHEDDAR = 3927    -- 1392 health
local HAUNCH_OF_MEAT = 2287       -- 243.6 health
local FRESHLY_BAKED_BREAD = 4541  -- 243.6 health, listed after Haunch of Meat
local TOUGH_JERKY = 117           -- 61.2 health
local CONJURED_CRYSTAL_WATER = 8079 -- conjured, 4200 mana
local CONJURED_WATER = 5350       -- conjured, 151.2 mana
local MORNING_GLORY_DEW = 8766    -- 2934 mana
local ICE_COLD_MILK = 1179        -- 436.8 mana
local REFRESHING_SPRING_WATER = 159 -- 151.2 mana
-- Forever
local RESTORATIVE_BREAD = 282018  -- a share of health and mana, listed right after conjured food
-- Retail, with the share of maximum health or mana they restore
local AKILSTEW = 260276           -- 120% health
local TASTY_MEAT = 265674         -- 100% health
local BLOOD_KNIGHT_BURGER = 264992 -- 80% health
local CONJURED_TEA = 265099       -- conjured, 120% mana
local CONJURED_MANA_BUN = 113509  -- conjured, 100% health and mana, listed after Conjured Tea
local MANA_LILY_TEA = 242297      -- 160% mana
local PURIFIED_CORDIAL = 260258   -- 80% mana

local WELL_FED = 19705 -- the spell the addon reads the food buff's translated name from
local SPELLS = { [WELL_FED] = { name = "Well Fed" } }

local function uses(itemId)
  return "#showtooltip\n/use [@player] item:" .. itemId
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

local function page(label)
  return label == DRINK_BOX and "AutoDrink" or "AutoFood"
end

-- A character with these bags who ticked the box with this label on its settings page.
local function ticked(label, flavor, bags, options)
  options = options or {}
  options.flavor = flavor
  options.bags = bags
  options.class = options.class or "MAGE"
  options.spells = options.spells or SPELLS
  local client = Client.new(options)
  client:login()
  client:openSettings("AutoPotion", page(label))
  client:clickCheckbox(label)
  client:nextFrame()
  return client
end

-- Runs out of an item: the macro moves on.
local function eatUp(client, itemId)
  client:addToBags(itemId, -5)
  client:nextFrame()
end

test("retail, classic, forever: both boxes are off by default and the macros use the best food and drink", function()
  local bags = {
    classic = { [ROASTED_QUAIL] = 5, [HAUNCH_OF_MEAT] = 5, [MORNING_GLORY_DEW] = 5, [ICE_COLD_MILK] = 5 },
    retail = { [AKILSTEW] = 5, [BLOOD_KNIGHT_BURGER] = 5, [MANA_LILY_TEA] = 5, [PURIFIED_CORDIAL] = 5 },
  }
  bags.forever = bags.classic
  local best = { classic = { ROASTED_QUAIL, MORNING_GLORY_DEW }, retail = { AKILSTEW, MANA_LILY_TEA } }
  best.forever = best.classic
  for _, flavor in ipairs({ "retail", "classic", "forever" }) do
    local client = Client.new({ flavor = flavor, class = "MAGE", bags = bags[flavor] })
    client:login()
    client:openSettings("AutoPotion", "AutoFood")
    assertEqual(client:isChecked(FOOD_BOX), false)
    client:openSettings("AutoPotion", "AutoDrink")
    assertEqual(client:isChecked(DRINK_BOX), false)
    assertEqual(client:macroText("AutoFood"), uses(best[flavor][1]))
    assertEqual(client:macroText("AutoDrink"), uses(best[flavor][2]))
  end
end)

for _, flavor in ipairs({ "classic", "forever" }) do
  test(flavor .. ": with Weakest Food First AutoFood eats the weakest food", function()
    local client = ticked(FOOD_BOX, flavor,
      { [ROASTED_QUAIL] = 5, [FINE_AGED_CHEDDAR] = 5, [HAUNCH_OF_MEAT] = 5 })
    assertEqual(client:macroText("AutoFood"), uses(HAUNCH_OF_MEAT))
    assertEqual(client.errors, {})
  end)

  test(flavor .. ": with Weakest Drink First AutoDrink drinks the weakest drink", function()
    local client = ticked(DRINK_BOX, flavor,
      { [MORNING_GLORY_DEW] = 5, [ICE_COLD_MILK] = 5, [REFRESHING_SPRING_WATER] = 5 })
    assertEqual(client:macroText("AutoDrink"), uses(REFRESHING_SPRING_WATER))
    assertEqual(client.errors, {})
  end)

  test(flavor .. ": the boxes are separate", function()
    local bags = { [ROASTED_QUAIL] = 5, [HAUNCH_OF_MEAT] = 5, [MORNING_GLORY_DEW] = 5, [ICE_COLD_MILK] = 5 }
    local client = ticked(FOOD_BOX, flavor, bags)
    assertEqual(client:macroText("AutoFood"), uses(HAUNCH_OF_MEAT))
    assertEqual(client:macroText("AutoDrink"), uses(MORNING_GLORY_DEW))

    client = ticked(DRINK_BOX, flavor, bags)
    assertEqual(client:macroText("AutoFood"), uses(ROASTED_QUAIL))
    assertEqual(client:macroText("AutoDrink"), uses(ICE_COLD_MILK))
  end)

  test(flavor .. ": conjured food still goes first, its weakest first", function()
    local client = ticked(FOOD_BOX, flavor, { [CONJURED_SWEET_ROLL] = 5, [CONJURED_BREAD] = 5,
      [CONJURED_MUFFIN] = 5, [TOUGH_JERKY] = 5 })
    assertEqual(client:macroText("AutoFood"), uses(CONJURED_MUFFIN))
    eatUp(client, CONJURED_MUFFIN)
    assertEqual(client:macroText("AutoFood"), uses(CONJURED_BREAD))
    eatUp(client, CONJURED_BREAD)
    eatUp(client, CONJURED_SWEET_ROLL)
    assertEqual(client:macroText("AutoFood"), uses(TOUGH_JERKY))
  end)

  test(flavor .. ": conjured water still goes first, its weakest first", function()
    local client = ticked(DRINK_BOX, flavor, { [CONJURED_CRYSTAL_WATER] = 5, [CONJURED_WATER] = 5,
      [REFRESHING_SPRING_WATER] = 5 })
    assertEqual(client:macroText("AutoDrink"), uses(CONJURED_WATER))
    eatUp(client, CONJURED_WATER)
    assertEqual(client:macroText("AutoDrink"), uses(CONJURED_CRYSTAL_WATER))
  end)

  test(flavor .. ": dual-restore food ranks by health on AutoFood and by mana on AutoDrink", function()
    -- Senggin Root restores 294 health and 294 mana: more health than Haunch of Meat, less mana
    -- than Ice Cold Milk. It goes ahead of both normally.
    local client = ticked(FOOD_BOX, flavor, { [SENGGIN_ROOT] = 5, [HAUNCH_OF_MEAT] = 5,
      [FINE_AGED_CHEDDAR] = 5, [ICE_COLD_MILK] = 5, [REFRESHING_SPRING_WATER] = 5 })
    client:openSettings("AutoPotion", "AutoDrink")
    client:clickCheckbox(DRINK_BOX)
    client:nextFrame()
    assertEqual(client:macroText("AutoFood"), uses(HAUNCH_OF_MEAT))
    assertEqual(client:macroText("AutoDrink"), uses(REFRESHING_SPRING_WATER))

    eatUp(client, HAUNCH_OF_MEAT)
    eatUp(client, REFRESHING_SPRING_WATER)
    assertEqual(client:macroText("AutoFood"), uses(SENGGIN_ROOT))
    assertEqual(client:macroText("AutoDrink"), uses(SENGGIN_ROOT))
  end)

  test(flavor .. ": food restoring the same keeps its usual order", function()
    local client = ticked(FOOD_BOX, flavor,
      { [FRESHLY_BAKED_BREAD] = 5, [HAUNCH_OF_MEAT] = 5, [ROASTED_QUAIL] = 5 })
    assertEqual(client:macroText("AutoFood"), uses(HAUNCH_OF_MEAT))
  end)

  test(flavor .. ": a stronger food looted later doesn't replace the weakest, running out moves to the next-weakest", function()
    local client = ticked(FOOD_BOX, flavor, { [FINE_AGED_CHEDDAR] = 5, [TOUGH_JERKY] = 5 })
    client:addToBags(ROASTED_QUAIL, 5)
    client:nextFrame()
    assertEqual(client:macroText("AutoFood"), uses(TOUGH_JERKY))

    eatUp(client, TOUGH_JERKY)
    assertEqual(client:macroText("AutoFood"), uses(FINE_AGED_CHEDDAR))
  end)

  test(flavor .. ": buff food stays left out without Include Buff Food", function()
    local client = ticked(FOOD_BOX, flavor, { [GRILLED_SQUID] = 5, [ROASTED_QUAIL] = 5, [TOUGH_JERKY] = 5 })
    assertEqual(client:macroText("AutoFood"), uses(TOUGH_JERKY))
    eatUp(client, TOUGH_JERKY)
    eatUp(client, ROASTED_QUAIL)
    assertEqual(client:macroText("AutoFood"), "#showtooltip")
  end)

  test(flavor .. ": with Include Buff Food buff food keeps its place ahead of the other food", function()
    local client = ticked(FOOD_BOX, flavor, { [GRILLED_SQUID] = 5, [ROASTED_QUAIL] = 5, [TOUGH_JERKY] = 5 })
    client:clickCheckbox("Include Buff Food")
    client:nextFrame()
    assertEqual(client:macroText("AutoFood"), uses(GRILLED_SQUID))
    eatUp(client, GRILLED_SQUID)
    assertEqual(client:macroText("AutoFood"), uses(TOUGH_JERKY))
  end)

  test(flavor .. ": with \"Only when the buff is missing\" buff food goes first without the buff, last with it", function()
    local client = ticked(FOOD_BOX, flavor, { [GRILLED_SQUID] = 5, [ROASTED_QUAIL] = 5, [TOUGH_JERKY] = 5 })
    client:clickCheckbox("Include Buff Food")
    client:clickCheckbox("Only when the buff is missing")
    client:nextFrame()
    assertEqual(client:macroText("AutoFood"), uses(GRILLED_SQUID))

    client:gainAura(WELL_FED)
    client:nextFrame()
    assertEqual(client:macroText("AutoFood"), uses(TOUGH_JERKY))
    eatUp(client, TOUGH_JERKY)
    assertEqual(client:macroText("AutoFood"), uses(ROASTED_QUAIL))
    eatUp(client, ROASTED_QUAIL)
    assertEqual(client:macroText("AutoFood"), uses(GRILLED_SQUID))
  end)

  test(flavor .. ": the previews show the weakest first", function()
    local client = ticked(FOOD_BOX, flavor,
      { [ROASTED_QUAIL] = 5, [FINE_AGED_CHEDDAR] = 5, [TOUGH_JERKY] = 5 })
    assertEqual(previewOf(client), icons(TOUGH_JERKY, FINE_AGED_CHEDDAR, ROASTED_QUAIL))

    client:openSettings("AutoPotion", "AutoDrink")
    client:clickCheckbox(DRINK_BOX)
    client:nextFrame()
    client:addToBags(MORNING_GLORY_DEW, 5)
    client:addToBags(ICE_COLD_MILK, 5)
    client:nextFrame()
    assertEqual(previewOf(client), icons(ICE_COLD_MILK, MORNING_GLORY_DEW))
  end)

  test(flavor .. ": unticking brings back the best food; the setting survives a reload", function()
    local client = ticked(FOOD_BOX, flavor, { [ROASTED_QUAIL] = 5, [TOUGH_JERKY] = 5 })
    client = client:reload()
    client:openSettings("AutoPotion", "AutoFood")
    assertEqual(client:isChecked(FOOD_BOX), true)
    assertEqual(client:macroText("AutoFood"), uses(TOUGH_JERKY))

    client:clickCheckbox(FOOD_BOX)
    client:nextFrame()
    assertEqual(client:macroText("AutoFood"), uses(ROASTED_QUAIL))
  end)

  test(flavor .. ": ticking the box in combat changes the macro when combat ends", function()
    local client = Client.new({ flavor = flavor, class = "MAGE",
      bags = { [MORNING_GLORY_DEW] = 5, [REFRESHING_SPRING_WATER] = 5 } })
    client:login()
    client:openSettings("AutoPotion", "AutoDrink")
    client:enterCombat()
    client:clickCheckbox(DRINK_BOX)
    client:advance(1)
    assertEqual(client.blockedActions, {})
    assertEqual(client:macroText("AutoDrink"), uses(MORNING_GLORY_DEW))

    client:leaveCombat()
    assertEqual(client:macroText("AutoDrink"), uses(REFRESHING_SPRING_WATER))
  end)

  test(flavor .. ": the boxes explain themselves", function()
    local client = Client.new({ flavor = flavor })
    client:login()
    local texts = {}
    for _, label in ipairs({ FOOD_BOX, DRINK_BOX }) do
      client:openSettings("AutoPotion", page(label))
      table.insert(texts, table.concat(client:hoverCheckbox(label), " "))
    end
    for _, text in ipairs(texts) do
      assertEqual(text:find("least", 1, true) ~= nil, true, text)
      assertEqual(text:find("leveling", 1, true) ~= nil, true, text)
      assertEqual(text:find("Conjured", 1, true) ~= nil, true, text)
    end
  end)
end

test("forever: Restorative Bread, a share among flat amounts, goes last with Weakest Food First", function()
  local client = Client.new({ flavor = "forever", bags = { [RESTORATIVE_BREAD] = 5, [ROASTED_QUAIL] = 5,
    [TOUGH_JERKY] = 5 } })
  client:login()
  assertEqual(client:macroText("AutoFood"), uses(RESTORATIVE_BREAD))

  client = ticked(FOOD_BOX, "forever", { [RESTORATIVE_BREAD] = 5, [ROASTED_QUAIL] = 5, [TOUGH_JERKY] = 5,
    [CONJURED_MUFFIN] = 5 })
  assertEqual(client:macroText("AutoFood"), uses(CONJURED_MUFFIN))
  eatUp(client, CONJURED_MUFFIN)
  assertEqual(client:macroText("AutoFood"), uses(TOUGH_JERKY))
  eatUp(client, TOUGH_JERKY)
  assertEqual(client:macroText("AutoFood"), uses(ROASTED_QUAIL))
  eatUp(client, ROASTED_QUAIL)
  assertEqual(client:macroText("AutoFood"), uses(RESTORATIVE_BREAD))
end)

test("retail: food and drink rank by the share of health or mana they restore", function()
  local client = ticked(FOOD_BOX, "retail", { [AKILSTEW] = 5, [TASTY_MEAT] = 5, [BLOOD_KNIGHT_BURGER] = 5,
    [MANA_LILY_TEA] = 5, [PURIFIED_CORDIAL] = 5 })
  assertEqual(client:macroText("AutoFood"), uses(BLOOD_KNIGHT_BURGER))
  eatUp(client, BLOOD_KNIGHT_BURGER)
  assertEqual(client:macroText("AutoFood"), uses(TASTY_MEAT))
  assertEqual(client:macroText("AutoDrink"), uses(MANA_LILY_TEA))

  client:openSettings("AutoPotion", "AutoDrink")
  client:clickCheckbox(DRINK_BOX)
  client:nextFrame()
  assertEqual(client:macroText("AutoDrink"), uses(PURIFIED_CORDIAL))
  assertEqual(client.errors, {})
end)

test("retail: the weakest conjured drink goes first", function()
  local bags = { [CONJURED_TEA] = 5, [CONJURED_MANA_BUN] = 5, [PURIFIED_CORDIAL] = 5 }
  local client = Client.new({ flavor = "retail", class = "MAGE", bags = bags })
  client:login()
  assertEqual(client:macroText("AutoDrink"), uses(CONJURED_TEA))

  client = ticked(DRINK_BOX, "retail", bags)
  assertEqual(client:macroText("AutoDrink"), uses(CONJURED_MANA_BUN))
end)
