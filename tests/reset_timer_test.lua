-- The AutoPotion macro's reset timer with the cooldown option on: the castsequence starts over
-- after the first entry's cooldown, and only when the client reports one for it.
local Client = require("fake.client")

local LABEL = "Go back to your first heal once its cooldown is over"
local TOOLTIP = "If you don't press the macro for as long as your first heal's cooldown (talents included), the macro starts over with it. Works when the first heal is a spell or a Healthstone. A later heal with a longer cooldown can still make the macro wait."

local DESPERATE_PRAYER = 19236
local GIFT_OF_THE_NAARU_ROGUE = 370626
local GIFT_OF_THE_NAARU_MONK = 121093
local CRIMSON_VIAL = 185311
local HEALING_ELIXIR = 122281
local HEALTHSTONE = 5512
local DEMONIC_HEALTHSTONE = 224464
local POTION = 244838
local LAST_STAND = 12975
local MAJOR_HEALTHSTONE = 9421
local GIFT_OF_THE_NAARU_PRIEST = 59544
local EXHILARATION = 109304
local DARK_PACT = 108416
local DEATH_PACT = 48743
local VAMPIRIC_BLOOD = 55233
-- cooldown talents
local ANGELS_MERCY = 238100
local NATURAL_MENDING = 270581
local FREQUENT_DONOR = 386686
local DEATH_DEFIANCE = 1266818

local SPELLS = {
  [DESPERATE_PRAYER] = { name = "Desperate Prayer", baseCooldown = 90000 },
  [GIFT_OF_THE_NAARU_ROGUE] = { name = "Gift of the Naaru", baseCooldown = 120000 },
  [GIFT_OF_THE_NAARU_MONK] = { name = "Gift of the Naaru", baseCooldown = 120000 },
  [CRIMSON_VIAL] = { name = "Crimson Vial", baseCooldown = 30000 },
  [HEALING_ELIXIR] = { name = "Healing Elixir", baseCooldown = 0 }, -- charges, no base cooldown
  [6262] = { name = "Healthstone", baseCooldown = 60000 },
  [452930] = { name = "Demonic Healthstone", baseCooldown = 60000 },
  [LAST_STAND] = { name = "Last Stand", baseCooldown = 180000 },
  [11732] = { name = "Major Healthstone", baseCooldown = 120000 },
  [GIFT_OF_THE_NAARU_PRIEST] = { name = "Gift of the Naaru", baseCooldown = 120000 },
  [EXHILARATION] = { name = "Exhilaration", baseCooldown = 120000 },
  [DARK_PACT] = { name = "Dark Pact", baseCooldown = 60000 },
  [DEATH_PACT] = { name = "Death Pact", baseCooldown = 120000 },
  [VAMPIRIC_BLOOD] = { name = "Vampiric Blood", baseCooldown = 90000 },
  [ANGELS_MERCY] = { name = "Angel's Mercy" },
  [NATURAL_MENDING] = { name = "Natural Mending" },
  [FREQUENT_DONOR] = { name = "Frequent Donor" },
  [DEATH_DEFIANCE] = { name = "Death Defiance" },
}
local ITEMS = {
  [HEALTHSTONE] = { spell = { name = "Healthstone", id = 6262 } },
  [DEMONIC_HEALTHSTONE] = { spell = { name = "Demonic Healthstone", id = 452930 } },
  [MAJOR_HEALTHSTONE] = { spell = { name = "Major Healthstone", id = 11732 } },
}

-- A character logged in with the cooldown option on (unless HAMDB says otherwise).
local function character(options)
  options.spells = SPELLS
  options.items = ITEMS
  local settings = options.settings or {}
  if settings.cdReset == nil then settings.cdReset = true end
  options.savedVariables = { HAMDB = settings }
  options.settings = nil
  local client = Client.new(options)
  client:login()
  return client
end

-- What follows reset= in a macro.
local function sequenceResetArgument(text)
  return text:match("reset=(%S+)")
end

test("retail: Desperate Prayer alone resets after its cooldown", function()
  local client = character({ class = "PRIEST", knownSpells = { DESPERATE_PRAYER } })
  assertEqual(sequenceResetArgument(client:macroText("AutoPotion")), "combat/90")
  assertEqual(client.errors, {})
end)

test("retail: Gift of the Naaru before Crimson Vial resets after Gift of the Naaru's cooldown", function()
  local client = character({
    class = "ROGUE",
    knownSpells = { GIFT_OF_THE_NAARU_ROGUE, CRIMSON_VIAL },
    settings = { activatedSpells = { GIFT_OF_THE_NAARU_ROGUE, CRIMSON_VIAL } },
  })
  assertEqual(client:macroText("AutoPotion"),
    "#showtooltip \n/castsequence [@player] reset=combat/120 Gift of the Naaru, Crimson Vial")
end)

test("retail: unticking and ticking spells in the settings gives the new first entry's reset timer at once", function()
  local client = character({
    class = "ROGUE",
    knownSpells = { GIFT_OF_THE_NAARU_ROGUE, CRIMSON_VIAL },
    settings = { activatedSpells = { GIFT_OF_THE_NAARU_ROGUE, CRIMSON_VIAL } },
  })
  client:openSettings("AutoPotion", "AutoPotion")

  client:clickCheckbox("Gift of the Naaru")
  client:nextFrame()
  assertEqual(sequenceResetArgument(client:macroText("AutoPotion")), "combat/30", "Gift of the Naaru unticked")

  client:clickCheckbox("Gift of the Naaru") -- ticked again, now after Crimson Vial
  client:nextFrame()
  assertEqual(client:macroText("AutoPotion"),
    "#showtooltip \n/castsequence [@player] reset=combat/30 Crimson Vial, Gift of the Naaru")

  client:clickCheckbox("Crimson Vial")
  client:clickCheckbox("Crimson Vial") -- Gift of the Naaru first again
  client:nextFrame()
  assertEqual(client:macroText("AutoPotion"),
    "#showtooltip \n/castsequence [@player] reset=combat/120 Gift of the Naaru, Crimson Vial")
  assertEqual(client.errors, {})
end)

test("retail: a Healthstone first, with no spell, resets after the Healthstone's cooldown", function()
  local client = character({ bags = { [HEALTHSTONE] = 1, [POTION] = 5 } })
  assertEqual(client:macroText("AutoPotion"),
    "#showtooltip \n/castsequence [@player] reset=combat/60 item:" .. HEALTHSTONE .. ", item:" .. POTION)
end)

test("retail: a Demonic Healthstone behind a spell leaves the spell's timer", function()
  local client = character({
    class = "PRIEST", knownSpells = { DESPERATE_PRAYER }, bags = { [DEMONIC_HEALTHSTONE] = 1 },
  })
  assertEqual(sequenceResetArgument(client:macroText("AutoPotion")), "combat/90")
end)

test("retail: a potion first has no reset timer, even with a Healthstone behind it", function()
  local client = character({ bags = { [HEALTHSTONE] = 1, [POTION] = 5 }, settings = { raidStone = true } })
  assertEqual(client:macroText("AutoPotion"),
    "#showtooltip \n/castsequence [@player] reset=combat item:" .. POTION .. ", item:" .. HEALTHSTONE)
end)

test("retail: Healing Elixir first has no reset timer, even with a cooldown spell behind it", function()
  local client = character({
    class = "MONK",
    knownSpells = { HEALING_ELIXIR, GIFT_OF_THE_NAARU_MONK },
    settings = { activatedSpells = { HEALING_ELIXIR, GIFT_OF_THE_NAARU_MONK } },
  })
  assertEqual(sequenceResetArgument(client:macroText("AutoPotion")), "combat")
end)

test("retail: with the option off there is no reset timer", function()
  local client = character({
    class = "PRIEST", knownSpells = { DESPERATE_PRAYER }, bags = { [HEALTHSTONE] = 1 },
    settings = { cdReset = false },
  })
  assertEqual(sequenceResetArgument(client:macroText("AutoPotion")), "combat")
end)

for _, flavor in ipairs({ "classic", "forever" }) do
  test(flavor .. ": a spell first resets after its base cooldown", function()
    local client = character({ flavor = flavor, knownSpells = { LAST_STAND }, bags = { [MAJOR_HEALTHSTONE] = 1 } })
    assertEqual(sequenceResetArgument(client:macroText("AutoPotion")), "combat/180")
  end)

  test(flavor .. ": a Healthstone first resets after its on-use spell's cooldown", function()
    local client = character({ flavor = flavor, bags = { [MAJOR_HEALTHSTONE] = 1 } })
    assertEqual(sequenceResetArgument(client:macroText("AutoPotion")), "combat/120")
  end)
end

test("retail: Desperate Prayer with Angel's Mercy resets after its shortened cooldown", function()
  local client = character({ class = "PRIEST", knownSpells = { DESPERATE_PRAYER, ANGELS_MERCY } })
  assertEqual(sequenceResetArgument(client:macroText("AutoPotion")), "combat/70")
  assertEqual(client.errors, {})
end)

test("retail: picking Angel's Mercy shortens the timer at once, dropping it restores it", function()
  local client = character({ class = "PRIEST", knownSpells = { DESPERATE_PRAYER } })

  client:pickTalent(ANGELS_MERCY)
  client:nextFrame()
  assertEqual(sequenceResetArgument(client:macroText("AutoPotion")), "combat/70", "picked")

  client:dropTalent(ANGELS_MERCY)
  client:nextFrame()
  assertEqual(sequenceResetArgument(client:macroText("AutoPotion")), "combat/90", "dropped")
  assertEqual(client.errors, {})
end)

for _, case in ipairs({
  { class = "HUNTER", spell = EXHILARATION, talent = NATURAL_MENDING, reset = "combat/90" },
  { class = "WARLOCK", spell = DARK_PACT, talent = FREQUENT_DONOR, reset = "combat/45" },
  { class = "DEATHKNIGHT", spell = DEATH_PACT, talent = DEATH_DEFIANCE, reset = "combat/90" },
}) do
  local name = SPELLS[case.spell].name .. " with " .. SPELLS[case.talent].name
  test("retail: " .. name .. " resets after its shortened cooldown", function()
    local client = character({
      class = case.class, knownSpells = { case.spell, case.talent },
      settings = { activatedSpells = { case.spell } },
    })
    assertEqual(sequenceResetArgument(client:macroText("AutoPotion")), case.reset)
    assertEqual(client.errors, {})
  end)
end

test("retail: Angel's Mercy leaves the timer of Gift of the Naaru before Desperate Prayer", function()
  local client = character({
    class = "PRIEST",
    knownSpells = { GIFT_OF_THE_NAARU_PRIEST, DESPERATE_PRAYER, ANGELS_MERCY },
    settings = { activatedSpells = { GIFT_OF_THE_NAARU_PRIEST, DESPERATE_PRAYER } },
  })
  assertEqual(client:macroText("AutoPotion"),
    "#showtooltip \n/castsequence [@player] reset=combat/120 Gift of the Naaru, Desperate Prayer")
end)

test("retail: dropping the talent that taught Death Pact gives Vampiric Blood's timer", function()
  local client = character({
    class = "DEATHKNIGHT",
    knownSpells = { DEATH_PACT, VAMPIRIC_BLOOD },
    settings = { activatedSpells = { DEATH_PACT, VAMPIRIC_BLOOD } },
  })
  client:dropTalent(DEATH_PACT)
  client:nextFrame()
  assertEqual(client:macroText("AutoPotion"),
    "#showtooltip \n/castsequence [@player] reset=combat/90 Vampiric Blood")

  client:pickTalent(DEATH_PACT)
  client:nextFrame()
  assertEqual(client:macroText("AutoPotion"),
    "#showtooltip \n/castsequence [@player] reset=combat/120 Death Pact, Vampiric Blood")
  assertEqual(client.errors, {})
end)

test("retail: the MegaMacro macro gets the same reset timer", function()
  local client = character({ class = "PRIEST", knownSpells = { DESPERATE_PRAYER }, megaMacro = { "AutoPotion" } })
  assertEqual(sequenceResetArgument(client:megaMacroText("AutoPotion")), "combat/90")
end)

for _, flavor in ipairs(Client.FLAVOR_NAMES) do
  for _, locale in ipairs({ "enUS", "deDE" }) do
    test(flavor .. " " .. locale .. ": the option's check box and its tooltip say what it does", function()
      local client = character({ flavor = flavor, locale = locale })
      client:openSettings("AutoPotion", "AutoPotion")
      assertEqual(client:isChecked(LABEL), true)
      assertEqual(client:hoverCheckbox(LABEL), { TOOLTIP })
    end)
  end
end
