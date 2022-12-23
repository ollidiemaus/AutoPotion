local addonName, ham = ...

local function addPlayerHealingSpellsIfAvailable()
  local myPlayer=ham.Player.new()
  local playerResetType, playerSpellName = myPlayer.getHealingSpells()
  ham.spellNameList = {}
  ham.spellsMacroString = ""

  if playerSpellName ~= nil then
    table.insert(ham.spellNameList, playerSpellName)
  end

  if next(ham.spellNameList) ~= nil then
    for i, v in ipairs(ham.spellNameList) do
      if i==1 then
        ham.spellsMacroString = v;
      else
        ham.spellsMacroString = ham.spellsMacroString .. ", "  .. v;
      end
    end
  end
end

local function addPlayerHealingItemIfAvailable()
  local myPlayer=ham.Player.new()
  local playerResetType, item = myPlayer.getHealingItems()

  if item ~= nil then
    if item.getCount() > 0 then
      table.insert(ham.itemIdList, item.getId())
    end
  end
end

local function addHealthstoneIfAvailable()
  if ham.healthstone.getCount() > 0 then
    table.insert(ham.itemIdList,ham.healthstone.getId())
  end
end

local function addPotIfAvailable()
  for iterator,value in ipairs(ham.getPots()) do
    if value.getCount() > 0 then
      table.insert(ham.itemIdList,value.getId())
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

local function updateMacro()
  local resetType = "combat"
  local itemsString = ""
  if next(ham.itemIdList) == nil and next(ham.spellNameList) ==nil then
    ham.macroStr = "#showtooltip"
  else
    if next(ham.itemIdList) ~= nil then
      for i, v in ipairs(ham.itemIdList) do
        if i==1 then
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
  EditMacro("HAMHealthPot", "HAMHealthPot", nil, ham.macroStr)
end
    
local onCombat = true
local HealPotMacroIcon = CreateFrame("Frame")
HealPotMacroIcon:RegisterEvent("BAG_UPDATE")
HealPotMacroIcon:RegisterEvent("PLAYER_LOGIN")
HealPotMacroIcon:RegisterEvent("TRAIT_CONFIG_UPDATED")
HealPotMacroIcon:RegisterEvent("PLAYER_REGEN_ENABLED")
HealPotMacroIcon:RegisterEvent("PLAYER_REGEN_DISABLED")
HealPotMacroIcon:SetScript("OnEvent",function(self,event,...)
  if event=="PLAYER_LOGIN" then
    onCombat = false
  end
  if event=="PLAYER_REGEN_DISABLED" then
    onCombat = true
    return
  end
  if event=="PLAYER_REGEN_ENABLED" then
    onCombat = false
  end
  
  if onCombat==false then
    updateAvailableHeals()
    updateMacro()
  end
end)