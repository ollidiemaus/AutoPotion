local addonName, ham = ...
local macroName = "AutoPotion"
local macroNameOld = "HAMHealthPot"
local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)

local function addPlayerHealingSpellsIfAvailable()
  local myPlayer = ham.Player.new()
  ham.spellNameList = myPlayer.getHealingSpells()
  ham.spellsMacroString = ""

  if next(ham.spellNameList) ~= nil then
    for i, v in ipairs(ham.spellNameList) do
      if i == 1 then
        ham.spellsMacroString = v;
      else
        ham.spellsMacroString = ham.spellsMacroString .. ", " .. v;
      end
    end
  end
end

local function addPlayerHealingItemIfAvailable()
  local myPlayer = ham.Player.new()
  local playerResetType, item = myPlayer.getHealingItems()

  if item ~= nil then
    if item.getCount() > 0 then
      table.insert(ham.itemIdList, item.getId())
    end
  end
end

local function addHealthstoneIfAvailable()
  if isClassic == false then
    if ham.healthstone.getCount() > 0 then
      table.insert(ham.itemIdList, ham.healthstone.getId())
    end
  else
    for iterator, value in ipairs(ham.getHealthstonesClassic()) do
      if value.getCount() > 0 then
        table.insert(ham.itemIdList, value.getId())
        --we break because all Healthstones share a cd so we only want the highest healing one
        break;
      end
    end
  end
end

local function addPotIfAvailable()
  for iterator, value in ipairs(ham.getPots()) do
    if value.getCount() > 0 then
      table.insert(ham.itemIdList, value.getId())
      --we break because all Pots share a cd so we only want the highest healing one
      break;
    end
  end
end


local function updateAvailableHeals()
  ham.itemIdList = {}

  addPlayerHealingSpellsIfAvailable()
  addPlayerHealingItemIfAvailable()
  addHealthstoneIfAvailable()
  addPotIfAvailable()
end

local function createMacroIfMissing()
  local name = GetMacroInfo(macroName)
  if name == nil then
    CreateMacro(macroName, "INV_Misc_QuestionMark")
  end

  local nameOld = GetMacroInfo(macroNameOld)
  if nameOld == nil then
    CreateMacro(macroNameOld, "INV_Misc_QuestionMark")
  end
end

local function updateMacro()
  local resetType = "combat"
  local itemsString = ""
  if next(ham.itemIdList) == nil and next(ham.spellNameList) == nil then
    ham.macroStr = "#showtooltip"
  else
    if next(ham.itemIdList) ~= nil then
      for i, v in ipairs(ham.itemIdList) do
        if i == 1 then
          itemsString = "item:" .. v;
        else
          itemsString = itemsString .. ", " .. "item:" .. v;
        end
      end
    end
    ham.macroStr = "#showtooltip \n/castsequence reset=" .. resetType .. " "
    if ham.spellsMacroString ~= "" then
      ham.macroStr = ham.macroStr .. ham.spellsMacroString
    end
    if ham.spellsMacroString ~= "" and itemsString ~= "" then
      ham.macroStr = ham.macroStr .. ", "
    end
    if itemsString ~= "" then
      ham.macroStr = ham.macroStr .. itemsString
    end
  end
  createMacroIfMissing()
  EditMacro(macroName, macroName, nil, ham.macroStr)
  EditMacro(macroNameOld, macroNameOld, nil, ham.macroStr)
end

local onCombat = true
local HealPotMacroIcon = CreateFrame("Frame")
HealPotMacroIcon:RegisterEvent("BAG_UPDATE")
HealPotMacroIcon:RegisterEvent("PLAYER_LOGIN")
if isClassic == false then
  HealPotMacroIcon:RegisterEvent("TRAIT_CONFIG_UPDATED")
end
HealPotMacroIcon:RegisterEvent("PLAYER_REGEN_ENABLED")
HealPotMacroIcon:RegisterEvent("PLAYER_REGEN_DISABLED")
HealPotMacroIcon:SetScript("OnEvent", function(self, event, ...)
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
    updateAvailableHeals()
    updateMacro()
  end
end)
