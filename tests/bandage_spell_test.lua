-- Rapid Regeneration, the Troll racial on Forever, as a bandage spell: the AutoBandage macro casts
-- it first and uses the best bandage in the bags while it's on cooldown.
local Client = require("fake.client")
local Api = require("fake.api")

local RAPID_REGENERATION = 1260270
local SPELLS = { [RAPID_REGENERATION] = { name = "Rapid Regeneration" } }
local HEAVY_RUNECLOTH = 14530 -- the best bandage below
local RUNECLOTH = 14529

-- A logged-in Forever character with these bags, knowing Rapid Regeneration unless told otherwise.
local function troll(bags, options)
  options = options or {}
  local client = Client.new({
    flavor = options.flavor or "forever", bags = bags, spells = SPELLS,
    knownSpells = options.unknown and {} or { RAPID_REGENERATION },
  })
  client:login()
  return client
end

test("forever: the macro casts Rapid Regeneration, then the best bandage", function()
  local client = troll({ [RUNECLOTH] = 5, [HEAVY_RUNECLOTH] = 5 })
  assertEqual(client:macroText("AutoBandage"),
    "#showtooltip\n/castsequence [@player] reset=combat/180 Rapid Regeneration, item:" .. HEAVY_RUNECLOTH)
end)

test("forever: with no bandage the macro casts Rapid Regeneration", function()
  local client = troll({})
  assertEqual(client:macroText("AutoBandage"), "#showtooltip\n/cast Rapid Regeneration")
end)

test("forever: a character that doesn't know the spell uses the bandage", function()
  local client = troll({ [HEAVY_RUNECLOTH] = 5 }, { unknown = true })
  assertEqual(client:macroText("AutoBandage"), "#showtooltip\n/use [@player] item:" .. HEAVY_RUNECLOTH)
end)

local LABEL = "Use Rapid Regeneration (Troll racial) before bandages"

test("forever: the AutoBandage page offers the option first, ticked", function()
  local client = troll({}, { unknown = true })
  client:openSettings("AutoPotion", "AutoBandage")
  assertEqual(client:checkboxLabels()[1], LABEL)
  assertEqual(client:isChecked(LABEL), true)
end)

test("forever: unticking the option puts the bandage back at once", function()
  local client = troll({ [HEAVY_RUNECLOTH] = 5 })
  client:openSettings("AutoPotion", "AutoBandage")
  client:clickCheckbox(LABEL)
  client:nextFrame()
  assertEqual(client:isChecked(LABEL), false)
  assertEqual(client:macroText("AutoBandage"), "#showtooltip\n/use [@player] item:" .. HEAVY_RUNECLOTH)
end)

test("forever: unticking the option in combat changes the macro when combat ends", function()
  local client = troll({ [HEAVY_RUNECLOTH] = 5 })
  local spellMacro = client:macroText("AutoBandage")
  client:openSettings("AutoPotion", "AutoBandage")
  client:enterCombat()
  client:clickCheckbox(LABEL)
  client:nextFrame()
  assertEqual(client:macroText("AutoBandage"), spellMacro, "in combat")
  client:leaveCombat()
  client:nextFrame()
  assertEqual(client:macroText("AutoBandage"), "#showtooltip\n/use [@player] item:" .. HEAVY_RUNECLOTH)
end)

-- Retail and Classic Era bandages, best first
local OTHER_FLAVORS = {
  retail = 239713,   -- Bright Linen Bandage (R2)
  classic = HEAVY_RUNECLOTH,
}
for flavor, bandage in pairs(OTHER_FLAVORS) do
  test(flavor .. ": the AutoBandage macro and page stay as they are", function()
    local client = troll({ [bandage] = 5 }, { flavor = flavor })
    assertEqual(client:macroText("AutoBandage"), "#showtooltip\n/use [@player] item:" .. bandage)
    client:openSettings("AutoPotion", "AutoBandage")
    assertEqual(client:checkboxLabels(), {})
  end)
end

local function previewOf(client)
  local icons = {}
  for i, shown in ipairs(client:previewIcons()) do icons[i] = shown.icon end
  return icons
end

test("forever: the Bandage Priority preview shows the spell ahead of the bandages", function()
  local client = troll({ [RUNECLOTH] = 5, [HEAVY_RUNECLOTH] = 5 })
  client:openSettings("AutoPotion", "AutoBandage")
  assertEqual(previewOf(client),
    { Api.spellIcon(RAPID_REGENERATION), Api.itemIcon(HEAVY_RUNECLOTH), Api.itemIcon(RUNECLOTH) })
end)

test("forever: the preview shows the spell with no bandage in the bags", function()
  local client = troll({})
  client:openSettings("AutoPotion", "AutoBandage")
  assertEqual(previewOf(client), { Api.spellIcon(RAPID_REGENERATION) })
end)

test("forever: the preview leaves the spell out when the option is off", function()
  local client = troll({ [HEAVY_RUNECLOTH] = 5 })
  client:openSettings("AutoPotion", "AutoBandage")
  client:clickCheckbox(LABEL)
  assertEqual(previewOf(client), { Api.itemIcon(HEAVY_RUNECLOTH) })
end)

test("forever: the preview leaves the spell out for a character that doesn't know it", function()
  local client = troll({ [HEAVY_RUNECLOTH] = 5 }, { unknown = true })
  client:openSettings("AutoPotion", "AutoBandage")
  assertEqual(previewOf(client), { Api.itemIcon(HEAVY_RUNECLOTH) })
end)
