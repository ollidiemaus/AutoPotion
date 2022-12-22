function addPlayerHealingSpellsIfAvailable()
  local myPlayer=Player.new()
  local playerResetType, playerSpellName = myPlayer.getHealingSpells()
  spellNameList = {}
  spellsMacroString = ""

  if playerSpellName ~= nil then
    table.insert(spellNameList, playerSpellName)
  end

  if next(spellNameList) ~= nil then
    for i, v in ipairs(spellNameList) do
      if i==1 then
        spellsMacroString = v;
      else
        spellsMacroString = spellsMacroString .. ", "  .. v;
      end
    end
  end

end

function addPotIfAvailable()
  for iterator,value in ipairs(getPots()) do
    if value.getCount() > 0 then
      table.insert(itemIdList,value.getId())
      --we break because all Pots share a cd so we only want the highest healing one
      break;
    end
  end
end

function addHealthstoneIfAvailable()
  if healthstone.getCount() > 0 then
    table.insert(itemIdList,healthstone.getId())
  end
end

function updateAvailableHeals()
  itemIdList = {}

  addPlayerHealingSpellsIfAvailable()
  addHealthstoneIfAvailable()
  addPotIfAvailable()
end

function updateMacro()
  local resetType = "combat"
  local itemsString = ""
  if next(itemIdList) == nil and next(spellNameList) ==nil then
    macroStr = "#showtooltip"
  else
    if next(itemIdList) ~= nil then
      for i, v in ipairs(itemIdList) do
        if i==1 then
          itemsString = "item:" .. v;
        else
          itemsString = itemsString .. ", " .. "item:" .. v;
        end
      end
    end
    macroStr = "#showtooltip \n/castsequence reset=" .. resetType .. " "
    if spellsMacroString ~= "" then
      macroStr = macroStr .. spellsMacroString
    end
    if spellsMacroString ~= "" and itemsString ~= "" then
      macroStr = macroStr .. ", " 
    end
    if itemsString ~= "" then
      macroStr = macroStr .. itemsString
    end
  end
  EditMacro("HAMHealthPot", "HAMHealthPot", nil, macroStr, 1, nil)
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