local addonName, ham = ...
local macroName = "AutoPotion"
local isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
local isWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
local isCata = (WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC)

ham.myPlayer = ham.Player.new()

local spellsMacroString = ''
local itemsMacroString = ''
local macroStr = ''
local resetType = "combat"
local shortestCD = nil
local bagUpdates = false -- debounce watcher for BAG_UPDATE events
local debounceTime = 3 -- seconds

local function addPlayerHealingItemIfAvailable()
  for i, value in ipairs(ham.myPlayer.getHealingItems()) do
    if value.getCount() > 0 then
      table.insert(ham.itemIdList, value.getId())
      break;
    end
  end
end

local function addHealthstoneIfAvailable()
  if isClassic == true or isWrath == true then
    for i, value in ipairs(ham.getHealthstonesClassic()) do
      if value.getCount() > 0 then
        table.insert(ham.itemIdList, value.getId())
        --we break because all Healthstones share a cd so we only want the highest healing one
        break;
      end
    end
  else
    if ham.healthstone.getCount() > 0 then
      table.insert(ham.itemIdList, ham.healthstone.getId())
    end
    if ham.demonicHealthstone.getCount() > 0 then
      table.insert(ham.itemIdList, ham.demonicHealthstone.getId())
      if HAMDB.cdReset then
        if shortestCD == nil then
          shortestCD = 60
        end
        if 60 < shortestCD then
          shortestCD = 60
        end
      end
    end
  end
end

local function addPotIfAvailable()
  for i, value in ipairs(ham.getPots()) do
    if value.getCount() > 0 then
      table.insert(ham.itemIdList, value.getId())
      --we break because all Pots share a cd so we only want the highest healing one
      break;
    end
  end
end


function ham.updateHeals()
  ham.itemIdList = {}

  ham.spellIDs = ham.myPlayer.getHealingSpells()

  addPlayerHealingItemIfAvailable()
  -- lower the priority of healthstones in insatanced content if selected
  if HAMDB.raidStone and IsInInstance() then
    addPotIfAvailable()
    addHealthstoneIfAvailable()
  else
    addHealthstoneIfAvailable()
    addPotIfAvailable()
  end
end

local function createMacroIfMissing()
  local name = GetMacroInfo(macroName)
  if name == nil then
    CreateMacro(macroName, "INV_Misc_QuestionMark")
  end
end

local function setShortestSpellCD(newSpell)
  if HAMDB.cdReset then
    local cd
    cd = GetSpellBaseCooldown(newSpell) / 1000
    if shortestCD == nil then
      shortestCD = cd
    end
    if cd < shortestCD then
      shortestCD = cd
    end
  end
end

local function setResetType()
  if HAMDB.cdReset == true and shortestCD ~= nil then
    resetType = "combat/" .. shortestCD
  else
    resetType = "combat"
  end
end

local function buildSpellMacroString()
  spellsMacroString = ''

  if next(ham.spellIDs) ~= nil then
    for i, spell in ipairs(ham.spellIDs) do
      local name
      if isRetail == true then
        name = C_Spell.GetSpellName(spell)
      else
        name = GetSpellInfo(spell)
      end

      setShortestSpellCD(spell)

      --TODO HEALING Elixir Twice because it has two charges ?! kinda janky but will work for now
      if spell == ham.healingElixir then
        name = name .. ", " .. name
      end
      if i == 1 then
        spellsMacroString = name;
      else
        spellsMacroString = spellsMacroString .. ", " .. name;
      end
    end
  end
end

local function buildItemMacroString()
  if next(ham.itemIdList) ~= nil then
    for i, name in ipairs(ham.itemIdList) do
      if i == 1 then
        itemsMacroString = "item:" .. name;
      else
        itemsMacroString = itemsMacroString .. ", " .. "item:" .. name;
      end
    end
  end
end

function ham.updateMacro()
  if next(ham.itemIdList) == nil and next(ham.spellIDs) == nil then
    macroStr = "#showtooltip"
  else
    resetType = "combat"
    buildItemMacroString()
    buildSpellMacroString()
    setResetType()
    macroStr = "#showtooltip \n/castsequence reset=" .. resetType .. " "
    if spellsMacroString ~= "" then
      macroStr = macroStr .. spellsMacroString
    end
    if spellsMacroString ~= "" and itemsMacroString ~= "" then
      macroStr = macroStr .. ", "
    end
    if itemsMacroString ~= "" then
      macroStr = macroStr .. itemsMacroString
    end
  end

  createMacroIfMissing()
  EditMacro(macroName, macroName, nil, macroStr)
end

local function MakeMacro()
  ham.updateHeals()
  ham.updateMacro()
  ham.settingsFrame:updatePrio()
end

-- debounce handler for BAG_UPDATE events which can fire very rapidly
local function onBagUpdate()
  if bagUpdates then
    return
  end
  bagUpdates = true
  C_Timer.After(debounceTime, function()
    MakeMacro()
    bagUpdates = false
  end)
end

local updateFrame = CreateFrame("Frame")
updateFrame:RegisterEvent("ADDON_LOADED")
updateFrame:RegisterEvent("BAG_UPDATE")
updateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
if isClassic == false then
  updateFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
end
updateFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
updateFrame:SetScript("OnEvent", function(self, event, arg1, ...)
  -- when addon is loaded
  if event == "ADDON_LOADED" and arg1 == addonName then
    updateFrame:UnregisterEvent("ADDON_LOADED")
    MakeMacro()
    return
  end
  -- player is in combat, do nothing
  if UnitAffectingCombat("player") then
    return
  end
  -- bag update events
  if event == "BAG_UPDATE" then
    onBagUpdate()
  -- on loading/reloading, or exiting combat
  elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" then
    MakeMacro()
  -- classic: when talents change
  elseif isClassic and event == "TRAIT_CONFIG_UPDATED" then
    MakeMacro()
  end
end)
