-- "Only when the buff is missing" under "Include Buff Food" on the AutoFood page: while the player
-- lacks the food buff, buff food goes first, ahead of conjured food; while they have it, buff food
-- goes last but stays in the macro.
local Client = require("fake.client")
local Api = require("fake.api")

local WELL_FED = 19705       -- the spell the addon reads the food buff's translated name from
local FOOD_BUFF = 1232585    -- any other Well Fed, as a food leaves it
local SPELLS = { [WELL_FED] = { name = "Well Fed" }, [FOOD_BUFF] = { name = "Well Fed" } }

-- Conjured food, buff food and normal food on each flavor, in their order in the food list.
local CLASSIC_ERA_FOOD = { conjured = 8076, buff = 13928, normal = 8952 } -- Conjured Sweet Roll, Grilled Squid, Roasted Quail
local FOOD = {
  retail = { conjured = 113509, buff = 242747, normal = 264992 }, -- Conjured Mana Bun, Hearty Royal Roast, Blood Knight Burger
  classic = CLASSIC_ERA_FOOD,
  forever = CLASSIC_ERA_FOOD,
}

local function eats(itemId)
  return "#showtooltip\n/use [@player] item:" .. itemId
end

-- A logged-in character with the given food (`kinds` names FOOD entries) on the AutoFood page.
local function character(flavor, kinds, options)
  options = options or {}
  local bags = {}
  for _, kind in ipairs(kinds) do bags[FOOD[flavor][kind]] = 5 end
  local client = Client.new({ flavor = flavor, bags = bags, spells = SPELLS, auras = options.auras })
  client:login()
  client:openSettings("AutoPotion", "AutoFood")
  return client
end

local function previewOf(client)
  local icons = {}
  for i, shown in ipairs(client:previewIcons()) do icons[i] = shown.icon end
  return icons
end

-- What following the auras costs: aura lookups and item counts (a macro rebuild asks for each item).
local function workDone(client)
  return {
    auraLookups = client:apiCallCount("C_UnitAuras.GetAuraDataBySpellName"),
    itemCounts = client:apiCallCount("C_Item.GetItemCount"),
  }
end

local function preferBuffFood(client)
  client:clickCheckbox("Include Buff Food")
  client:clickCheckbox("Only when the buff is missing")
  client:nextFrame()
end

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  local food = FOOD[flavor]

  test(flavor .. ": without the food buff, buff food comes before conjured food", function()
    local client = character(flavor, { "conjured", "buff", "normal" })
    preferBuffFood(client)
    assertEqual(client:macroText("AutoFood"), eats(food.buff))
  end)

  test(flavor .. ": gaining the food buff puts buff food after normal food, losing it puts it back", function()
    local client = character(flavor, { "buff", "normal" })
    preferBuffFood(client)
    client:gainAura(FOOD_BUFF)
    client:nextFrame()
    assertEqual(client:macroText("AutoFood"), eats(food.normal), "with the food buff")
    client:loseAura(FOOD_BUFF)
    client:nextFrame()
    assertEqual(client:macroText("AutoFood"), eats(food.buff), "after it fell off")
  end)

  test(flavor .. ": with the sub-option off, buff food keeps its place and the food buff changes nothing", function()
    local client = character(flavor, { "conjured", "buff", "normal" })
    client:clickCheckbox("Include Buff Food")
    client:nextFrame()
    assertEqual(client:macroText("AutoFood"), eats(food.conjured))
    local before = workDone(client)
    client:gainAura(FOOD_BUFF)
    client:nextFrame()
    client:loseAura(FOOD_BUFF)
    client:nextFrame()
    assertEqual(client:macroText("AutoFood"), eats(food.conjured))
    assertEqual(workDone(client), before, "work for the food buff")
  end)

  test(flavor .. ": a full aura update finds the food buff", function()
    local client = character(flavor, { "buff", "normal" })
    preferBuffFood(client)
    client:addAura("player", FOOD_BUFF) -- as after a loading screen
    client:fireEvent("UNIT_AURA", "player", { isFullUpdate = true })
    client:nextFrame()
    assertEqual(client:macroText("AutoFood"), eats(food.normal))
  end)

  test(flavor .. ": with only buff food in the bags, the macro eats it while the player has the food buff", function()
    local client = character(flavor, { "buff" })
    preferBuffFood(client)
    client:gainAura(FOOD_BUFF)
    client:nextFrame()
    assertEqual(client:macroText("AutoFood"), eats(food.buff))
  end)

  test(flavor .. ": the food buff gained in combat changes the macro once combat ends", function()
    local client = character(flavor, { "buff", "normal" })
    preferBuffFood(client)
    client:enterCombat()
    client:gainAura(FOOD_BUFF)
    client:nextFrame()
    assertEqual(client:macroText("AutoFood"), eats(food.buff), "in combat")
    assertEqual(#client.blockedActions, 0, "blocked actions")
    client:leaveCombat()
    client:nextFrame()
    assertEqual(client:macroText("AutoFood"), eats(food.normal), "after combat")
  end)

  test(flavor .. ": the Food page's Current Priority preview shows the macro's order", function()
    local client = character(flavor, { "conjured", "buff", "normal" })
    preferBuffFood(client)
    assertEqual(previewOf(client), { Api.itemIcon(food.buff), Api.itemIcon(food.conjured), Api.itemIcon(food.normal) })
    client:gainAura(FOOD_BUFF)
    assertEqual(previewOf(client), { Api.itemIcon(food.conjured), Api.itemIcon(food.normal), Api.itemIcon(food.buff) },
      "with the food buff, before the macro rebuild")
    client:nextFrame()
    assertEqual(client:macroText("AutoFood"), eats(food.conjured))
  end)

  test(flavor .. ": a party member's or the pet's auras rewrite no macro and do no work", function()
    local client = character(flavor, { "buff", "normal" })
    preferBuffFood(client)
    local before, writes = workDone(client), client:macroWrites({ "AutoFood" })
    for _, unit in ipairs({ "party1", "pet", "target" }) do
      client:gainAura(FOOD_BUFF, unit)
      client:nextFrame()
    end
    assertEqual(client:macroText("AutoFood"), eats(food.buff))
    assertEqual(client:macroWrites({ "AutoFood" }), writes, "macro writes")
    assertEqual(workDone(client), before, "work for other units' auras")
  end)

  test(flavor .. ": logging in with the food buff puts buff food last", function()
    local client = character(flavor, { "buff", "normal" }, { auras = { FOOD_BUFF } })
    preferBuffFood(client)
    client = client:reload()
    assertEqual(client:macroText("AutoFood"), eats(food.normal))
  end)

  test(flavor .. ": the sub-option can only be ticked while Include Buff Food is", function()
    local client = character(flavor, { "buff", "normal" })
    assertEqual(client:isEnabled("Only when the buff is missing"), false, "with Include Buff Food off")
    client:clickCheckbox("Only when the buff is missing")
    assertEqual(client:isChecked("Only when the buff is missing"), false, "clicked while disabled")
    client:clickCheckbox("Include Buff Food")
    assertEqual(client:isEnabled("Only when the buff is missing"), true, "with Include Buff Food on")
  end)
end
