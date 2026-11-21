-- Unusable items (GLOSSARY.md): an item the character is below the required level for, or a
-- bandage it lacks the First Aid skill for, counts as if it weren't in the bags, in every macro
-- and the preview. A level-up or a skill-up brings it back.
local Client = require("fake.client")
local Api = require("fake.api")

-- Classic Era and Forever
local MAJOR_HEALING_POTION, SUPERIOR_HEALING_POTION = 13446, 3928
local ALTERAC_SWISS, DWARVEN_MILD = 8932, 422
local MOONBERRY_JUICE, SWEET_NECTAR = 1645, 1708
local MAJOR_MANA_POTION, SUPERIOR_MANA_POTION = 13444, 13443
local HEAVY_RUNECLOTH_BANDAGE, RUNECLOTH_BANDAGE, LINEN_BANDAGE = 14530, 14529, 1251
-- Retail
local ALGARI_HEALING_POTION_R1, SPIRITUAL_HEALING_POTION = 211878, 171267

local function drinksPotion(...)
  local items = {}
  for i, id in ipairs({ ... }) do items[i] = "item:" .. id end
  return "#showtooltip \n/castsequence [@player] reset=combat " .. table.concat(items, ", ")
end

local function character(options)
  local client = Client.new(options)
  client:login()
  return client
end

test("classic: a potion above the player's level is skipped for the next one", function()
  local client = character({
    flavor = "classic", level = 40,
    bags = { [MAJOR_HEALING_POTION] = 5, [SUPERIOR_HEALING_POTION] = 5 },
    items = { [MAJOR_HEALING_POTION] = { requiredLevel = 45 }, [SUPERIOR_HEALING_POTION] = { requiredLevel = 35 } },
  })
  assertEqual(client:macroText("AutoPotion"), drinksPotion(SUPERIOR_HEALING_POTION))
end)

test("forever: a potion above the player's level is skipped for the next one", function()
  local client = character({
    flavor = "forever", level = 40,
    bags = { [MAJOR_HEALING_POTION] = 5, [SUPERIOR_HEALING_POTION] = 5 },
    items = { [MAJOR_HEALING_POTION] = { requiredLevel = 45 }, [SUPERIOR_HEALING_POTION] = { requiredLevel = 35 } },
  })
  assertEqual(client:macroText("AutoPotion"), drinksPotion(SUPERIOR_HEALING_POTION))
end)

test("retail: a potion above the player's level is skipped for the next one", function()
  local client = character({
    flavor = "retail", level = 60,
    bags = { [ALGARI_HEALING_POTION_R1] = 5, [SPIRITUAL_HEALING_POTION] = 5 },
    items = { [ALGARI_HEALING_POTION_R1] = { requiredLevel = 71 }, [SPIRITUAL_HEALING_POTION] = { requiredLevel = 51 } },
  })
  assertEqual(client:macroText("AutoPotion"), drinksPotion(SPIRITUAL_HEALING_POTION))
end)

test("classic: food and drink above the player's level are skipped", function()
  local client = character({
    flavor = "classic", level = 30,
    bags = { [ALTERAC_SWISS] = 5, [DWARVEN_MILD] = 5, [MOONBERRY_JUICE] = 5, [SWEET_NECTAR] = 5 },
    items = {
      [ALTERAC_SWISS] = { requiredLevel = 45 }, [DWARVEN_MILD] = { requiredLevel = 15 },
      [MOONBERRY_JUICE] = { requiredLevel = 35 }, [SWEET_NECTAR] = { requiredLevel = 25 },
    },
  })
  assertEqual(client:macroText("AutoFood"), "#showtooltip\n/use [@player] item:" .. DWARVEN_MILD)
  assertEqual(client:macroText("AutoDrink"), "#showtooltip\n/use [@player] item:" .. SWEET_NECTAR)
end)

test("classic: the preview leaves out a potion above the player's level", function()
  local client = character({
    flavor = "classic", level = 40,
    bags = { [MAJOR_HEALING_POTION] = 1, [SUPERIOR_HEALING_POTION] = 1 },
    items = { [MAJOR_HEALING_POTION] = { requiredLevel = 45 }, [SUPERIOR_HEALING_POTION] = { requiredLevel = 35 } },
  })
  client:openSettings("AutoPotion", "AutoPotion")
  local icons = {}
  for i, shown in ipairs(client:previewIcons()) do icons[i] = shown.icon end
  assertEqual(icons, { Api.itemIcon(SUPERIOR_HEALING_POTION) })
end)

test("classic: an item the cache hasn't loaded yet counts as usable", function()
  local client = character({
    flavor = "classic", level = 40, emptyItemCache = true,
    bags = { [MAJOR_HEALING_POTION] = 5 },
    items = { [MAJOR_HEALING_POTION] = { requiredLevel = 45 } },
  })
  assertEqual(client:macroText("AutoPotion"), drinksPotion(MAJOR_HEALING_POTION))
end)

test("classic: once an uncached item loads, it is skipped if it is above the player's level", function()
  local client = character({
    flavor = "classic", level = 40, emptyItemCache = true,
    bags = { [MAJOR_HEALING_POTION] = 5, [SUPERIOR_HEALING_POTION] = 5 },
    items = { [MAJOR_HEALING_POTION] = { requiredLevel = 45 }, [SUPERIOR_HEALING_POTION] = { requiredLevel = 35 } },
  })
  client:nextFrame()
  client:nextFrame()
  assertEqual(client:macroText("AutoPotion"), drinksPotion(SUPERIOR_HEALING_POTION))
end)

test("classic: a mana potion above the player's level is skipped for the next one", function()
  local client = character({
    flavor = "classic", level = 45,
    bags = { [MAJOR_MANA_POTION] = 5, [SUPERIOR_MANA_POTION] = 5 },
    items = { [MAJOR_MANA_POTION] = { requiredLevel = 49 }, [SUPERIOR_MANA_POTION] = { requiredLevel = 41 } },
  })
  assertEqual(client:macroText("AutoManaPotion"), "#showtooltip\n/use item:" .. SUPERIOR_MANA_POTION)
end)

test("retail: dropping to a lower effective level (Party Sync) skips the potions above it", function()
  local client = character({
    flavor = "retail", level = 80,
    bags = { [ALGARI_HEALING_POTION_R1] = 5, [SPIRITUAL_HEALING_POTION] = 5 },
    items = { [ALGARI_HEALING_POTION_R1] = { requiredLevel = 71 }, [SPIRITUAL_HEALING_POTION] = { requiredLevel = 51 } },
  })
  assertEqual(client:macroText("AutoPotion"), drinksPotion(ALGARI_HEALING_POTION_R1), "at 80")
  client:changeEffectiveLevel(60)
  client:nextFrame()
  assertEqual(client:macroText("AutoPotion"), drinksPotion(SPIRITUAL_HEALING_POTION), "synced to 60")
end)

local function bandages(itemId)
  return "#showtooltip\n/use [@player] item:" .. itemId
end

for _, flavor in ipairs({ "classic", "forever" }) do
  test(flavor .. ": a bandage above the First Aid skill is skipped until a skill-up", function()
    local client = character({
      flavor = flavor, skills = { ["First Aid"] = 220 },
      bags = { [HEAVY_RUNECLOTH_BANDAGE] = 5, [RUNECLOTH_BANDAGE] = 5 },
    })
    assertEqual(client:macroText("AutoBandage"), bandages(RUNECLOTH_BANDAGE), "at 220")
    client:raiseSkill("First Aid", 225)
    client:nextFrame()
    assertEqual(client:macroText("AutoBandage"), bandages(HEAVY_RUNECLOTH_BANDAGE), "at 225")
  end)

  test(flavor .. ": without First Aid no bandage is used", function()
    local client = character({ flavor = flavor, skills = {}, bags = { [LINEN_BANDAGE] = 5 } })
    assertEqual(client:macroText("AutoBandage"), "#showtooltip")
  end)
end

test("classic: a German client finds First Aid by its German name", function()
  local client = character({
    flavor = "classic", locale = "deDE", skills = { ["First Aid"] = 220 },
    bags = { [HEAVY_RUNECLOTH_BANDAGE] = 5, [RUNECLOTH_BANDAGE] = 5 },
  })
  assertEqual(client:macroText("AutoBandage"), bandages(RUNECLOTH_BANDAGE))
end)

test("retail: bandages need no First Aid", function()
  local client = character({ flavor = "retail", skills = {}, bags = { [LINEN_BANDAGE] = 5 } })
  assertEqual(client:macroText("AutoBandage"), bandages(LINEN_BANDAGE))
end)

local function classicLevel44()
  return character({
    flavor = "classic", level = 44,
    bags = { [MAJOR_HEALING_POTION] = 5, [SUPERIOR_HEALING_POTION] = 5 },
    items = { [MAJOR_HEALING_POTION] = { requiredLevel = 45 }, [SUPERIOR_HEALING_POTION] = { requiredLevel = 35 } },
  })
end

test("classic: reaching the required level brings the potion back", function()
  local client = classicLevel44()
  client:levelUp()
  client:nextFrame()
  assertEqual(client:macroText("AutoPotion"), drinksPotion(MAJOR_HEALING_POTION))
end)

test("classic: a level-up in combat changes the macro once combat ends", function()
  local client = classicLevel44()
  client:enterCombat()
  client:levelUp()
  client:nextFrame()
  assertEqual(client:macroText("AutoPotion"), drinksPotion(SUPERIOR_HEALING_POTION), "in combat")
  assertEqual(client.blockedActions, {})
  client:leaveCombat()
  client:nextFrame()
  assertEqual(client:macroText("AutoPotion"), drinksPotion(MAJOR_HEALING_POTION), "after combat")
end)
