-- Buff kinds under "Include Buff Food" on the AutoFood page: one box per stat the flavor's buff
-- food raises (Attack Power, Fishing, ...). Buff food or drink with no ticked kind is never eaten.
local Client = require("fake.client")
local Api = require("fake.api")

local MUD_SNAPPER = 4592    -- Forever: Longjaw Mud Snapper, Nutritious food raising Attack Power
local CATFISH = 4593        -- Forever: Bristle Whisker Catfish, Nutritious food raising Fishing
local ROASTED_QUAIL = 8952  -- plain food, after the buff food on Classic Era and Forever
local BLOOD_SAUSAGE = 3220  -- Classic Era: buff food raising Stamina and Spirit
local ARGENTLEAF_TEA = 242298 -- Retail: a Relaxed drink, Other (Finesse and Speed)
local MANA_LILY_TEA = 242297  -- Retail: a plain drink after it

local WELL_FED = 19705       -- the spell the addon reads the food buff's translated name from
local FOOD_BUFF = 1249521    -- Forever: the Catfish's food buff
local SPELLS = { [WELL_FED] = { name = "Well Fed" }, [FOOD_BUFF] = { name = "Well Fed" } }

-- every buff kind's box label (GLOSSARY.md)
local KIND_LABELS = {
  "Attack Power", "Spell Power", "Healing", "Stamina", "Strength", "Agility", "Intellect", "Spirit",
  "Primary Stat", "Health Regen", "Mana Regen", "Hit", "Critical Strike", "Haste", "Mastery",
  "Versatility", "Expertise", "Armor Penetration", "Dodge", "Parry", "Armor", "Resistance", "Fishing",
  "Other",
}

local function uses(itemId)
  return "#showtooltip\n/use [@player] item:" .. itemId
end

-- A logged-in character with these items on the AutoFood page, Include Buff Food ticked.
local function character(flavor, items)
  local bags = {}
  for _, itemId in ipairs(items) do bags[itemId] = 5 end
  local client = Client.new({ flavor = flavor, bags = bags, spells = SPELLS })
  client:login()
  client:openSettings("AutoPotion", "AutoFood")
  client:clickCheckbox("Include Buff Food")
  client:nextFrame()
  return client
end

local function untick(client, ...)
  for _, label in ipairs({ ... }) do client:clickCheckbox(label) end
  client:nextFrame()
end

local function has(list, value)
  for _, v in ipairs(list) do
    if v == value then return true end
  end
  return false
end

test("forever: unticking Fishing eats the Mud Snapper and keeps the Catfish", function()
  local client = character("forever", { MUD_SNAPPER, CATFISH })
  assertEqual(client:macroText("AutoFood"), uses(CATFISH), "every kind ticked")
  untick(client, "Fishing")
  assertEqual(client:macroText("AutoFood"), uses(MUD_SNAPPER), "Fishing unticked")
end)

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  test(flavor .. ": every buff kind starts ticked", function()
    local client = character(flavor, {})
    local shown = 0
    for _, label in ipairs(client:checkboxLabels()) do
      if has(KIND_LABELS, label) then
        shown = shown + 1
        assertEqual(client:isChecked(label), true, label .. " ticked")
      end
    end
    assertEqual(shown > 3, true, "buff kind boxes shown")
  end)

  test(flavor .. ": the buff kinds are greyed out while Include Buff Food is unticked", function()
    local client = character(flavor, {})
    assertEqual(client:isEnabled("Other"), true, "with buff food")
    client:clickCheckbox("Include Buff Food")
    assertEqual(client:isEnabled("Other"), false, "without buff food")
  end)
end

test("each flavor shows only the kinds its buff food has", function()
  local forever = character("forever", {}):checkboxLabels()
  assertEqual(has(forever, "Fishing"), true, "Forever: Fishing")
  assertEqual(has(forever, "Versatility"), false, "Forever: no Versatility")
  local retail = character("retail", {}):checkboxLabels()
  assertEqual(has(retail, "Versatility"), true, "Retail: Versatility")
  assertEqual(has(retail, "Fishing"), false, "Retail: no Fishing")
  local classic = character("classic", {}):checkboxLabels()
  assertEqual(has(classic, "Spirit"), true, "Classic Era: Spirit")
  assertEqual(has(classic, "Haste"), false, "Classic Era: no Haste")
end)

test("classic: food raising two stats is eaten while one of them is ticked", function()
  local client = character("classic", { BLOOD_SAUSAGE, ROASTED_QUAIL })
  untick(client, "Stamina")
  assertEqual(client:macroText("AutoFood"), uses(BLOOD_SAUSAGE), "Spirit still ticked")
  untick(client, "Spirit")
  assertEqual(client:macroText("AutoFood"), uses(ROASTED_QUAIL), "both unticked")
end)

test("forever: an unticked kind stays unticked after a reload", function()
  local client = character("forever", { MUD_SNAPPER, CATFISH })
  untick(client, "Fishing")
  client = client:reload()
  client:openSettings("AutoPotion", "AutoFood")
  assertEqual(client:isChecked("Fishing"), false, "Fishing")
  assertEqual(client:isChecked("Attack Power"), true, "Attack Power")
  assertEqual(client:macroText("AutoFood"), uses(MUD_SNAPPER))
end)

test("retail: the same boxes decide which Relaxed drinks AutoDrink drinks", function()
  local client = character("retail", { ARGENTLEAF_TEA, MANA_LILY_TEA })
  assertEqual(client:macroText("AutoDrink"), uses(ARGENTLEAF_TEA), "Other ticked")
  untick(client, "Other")
  assertEqual(client:macroText("AutoDrink"), uses(MANA_LILY_TEA), "Other unticked")
end)

test("forever: only when the buff is missing places the buff food still wanted", function()
  local client = character("forever", { CATFISH, MUD_SNAPPER, ROASTED_QUAIL })
  client:clickCheckbox("Only when the buff is missing")
  untick(client, "Fishing")
  assertEqual(client:macroText("AutoFood"), uses(MUD_SNAPPER), "without the food buff")
  client:gainAura(FOOD_BUFF)
  client:nextFrame()
  assertEqual(client:macroText("AutoFood"), uses(ROASTED_QUAIL), "with the food buff")
end)

test("forever: the Current Priority preview leaves out unwanted buff food", function()
  local client = character("forever", { CATFISH, MUD_SNAPPER, ROASTED_QUAIL })
  untick(client, "Fishing")
  local icons = {}
  for i, shown in ipairs(client:previewIcons()) do icons[i] = shown.icon end
  assertEqual(icons, { Api.itemIcon(MUD_SNAPPER), Api.itemIcon(ROASTED_QUAIL) })
end)
