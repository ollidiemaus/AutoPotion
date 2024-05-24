local addonName, ham = ...
local macroName = "AutoPotion"
local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
local isWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
local isCata = (WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC)


ham.myPlayer = ham.Player.new()

local spellsMacroString = ''
local itemsMacroString = ''
local macroStr = ''
local resetType = "combat"

local function addPlayerHealingItemIfAvailable()
  local playerResetType, item = ham.myPlayer.getHealingItems()

  if item ~= nil then
    if item.getCount() > 0 then
      table.insert(ham.itemIdList, item.getId())
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
  addHealthstoneIfAvailable()
  addPotIfAvailable()
end

local function createMacroIfMissing()
  local name = GetMacroInfo(macroName)
  if name == nil then
    CreateMacro(macroName, "INV_Misc_QuestionMark")
  end
end

local function buildSpellMacroString()
  spellsMacroString = ''

  if next(ham.spellIDs) ~= nil then
    local shortestCD = nil
    for i, spell in ipairs(ham.spellIDs) do
      local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(spell)

      if HAMDB.cdReset then
        local cooldownMS, gcdMS = GetSpellBaseCooldown(spell)
        local cd = cooldownMS / 1000
        if shortestCD == nil then
          shortestCD = cd
        end
        if cd < shortestCD then
          shortestCD = cd
        end
      end
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
    --add if ham.cdReset == true then combat/spelltime
    if HAMDB.cdReset then
      resetType = "combat/" .. shortestCD
    end
  end
end

local function buildItemMacroString()
  if next(ham.itemIdList) ~= nil then
    for i, v in ipairs(ham.itemIdList) do
      if i == 1 then
        itemsMacroString = "item:" .. v;
      else
        itemsMacroString = itemsMacroString .. ", " .. "item:" .. v;
      end
    end
  end
end

local function updateMacro()
  if next(ham.itemIdList) == nil and next(ham.spellIDs) == nil then
    macroStr = "#showtooltip"
  else
    resetType = "combat"
    buildItemMacroString()
    buildSpellMacroString()
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

local onCombat = true
local updateFrame = CreateFrame("Frame")
updateFrame:RegisterEvent("BAG_UPDATE")
updateFrame:RegisterEvent("PLAYER_LOGIN")
updateFrame:RegisterEvent("PLAYER_ENTERING_WORLD") -- Initial login and UI reload
if isClassic == false then
  updateFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
end
updateFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
updateFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
updateFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_LOGIN" then
    onCombat = false
  end
  if event == "PLAYER_REGEN_DISABLED" then
    onCombat = true
    return
  end
  if event == "PLAYER_REGEN_ENABLED" then
    onCombat = false
  end

  if onCombat == false then
    ham.updateHeals()
    updateMacro()
  end
end)
