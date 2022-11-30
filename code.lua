-- This file is loaded from "HealthstoneAutoMacro.toc"
do

  local healthstoneId = 5512;
  local refreshing1Id = 191378; -- Refreshing Healing Potion - Rank 1
  local refreshing2Id = 191379; -- Refreshing Healing Potion - Rank 2
  local refreshing3Id = 191380; -- Refreshing Healing Potion - Rank 3
  
  
  function getPotNames()
    refreshing1Name = GetItemInfo(refreshing1Id);
    refreshing2Name = GetItemInfo(refreshing2Id);
	  refreshing3Name = GetItemInfo(refreshing3Id);
  
    -- fall back on connect sometimes GetItem fail
    if refreshing1Name==nil then
      refreshing1Name = "Refreshing Healing Potion"
    end
    if refreshing2Name==nil then
      refreshing2Name = "Refreshing Healing Potion"
    end
    if refreshing3Name==nil then
      refreshing3Name = "Refreshing Healing Potion"
    end
    return refreshing3Name, refreshing2Name, refreshing1Name
  end
  
  function getPots()
    refreshing3Name, refreshing2Name, refreshing1Name  = getPotNames()
    return {
      {refreshing3Name, GetItemCount(refreshing3Id, false, false)},
      {refreshing2Name, GetItemCount(refreshing2Id, false, false)},
	    {refreshing1Name, GetItemCount(refreshing1Id, false, false)}
  
    }
  end
  
  function getHealthstone()
    healthstoneName = GetItemInfo(healthstoneId);
    if healthstoneName==nil then
      healthstoneName = "Healthstone"
    end
    return healthstoneName, GetItemCount(healthstoneId, false, false);
  end
    
  local onCombat = true;
  local HealPotMacroIcon = CreateFrame("Frame");
  HealPotMacroIcon:RegisterEvent("BAG_UPDATE");
  HealPotMacroIcon:RegisterEvent("PLAYER_LOGIN");
  HealPotMacroIcon:RegisterEvent("PLAYER_REGEN_ENABLED");
  HealPotMacroIcon:RegisterEvent("PLAYER_REGEN_DISABLED");
  HealPotMacroIcon:SetScript("OnEvent",function(self,event,...)
    if event=="PLAYER_LOGIN" then
      onCombat = false;
    end
    if event=="PLAYER_REGEN_DISABLED" then
      onCombat = true;
      return ;
    end
    if event=="PLAYER_REGEN_ENABLED" then
      onCombat = false;
    end
  
    if onCombat==false then
      local Pot = getPots()
      local healthstoneName, healthstoneCounter = getHealthstone()
      local playerClass, englishClass, classIndex = UnitClass("player");
      local resetType = "combat"
      local macroStr, potName, foundPots, foundHealthstone, potList, potListCounter, potsString;
  
      foundPots = false;
      foundHealthstone = false;
      potList = {}
      potListCounter = 0;
      potsString = ""
  
      for i,v in ipairs(Pot) do
        if v[2] > 0 then
          foundPots = true;
          potName = v[1]
          break;
        end
      end

      if healthstoneCounter > 0 then
        foundHealthstone = true;
      end
  
      -- Currently the Priority is: vial -> healthstone -> pot -> phial
      -- after 50k+ health it needs to be: healtstone -> phial -> pot
      
      ---uncomment this block if you really want cirmson vial to be in this roation.
      --[[if englishClass=="ROGUE" then
        resetType = "30"
        table.insert(potList, "Crimson Vial")
        potListCounter=potListCounter+1;
      end--]]
      if foundHealthstone==true then
        table.insert(potList,healthstoneName)
        potListCounter=potListCounter+1;
      end
      if foundPots==true then
        table.insert(potList,potName)
        potListCounter=potListCounter+1;
      end
  
      if potListCounter==0 then
        macroStr = "#showtooltip"
      else
        for i, v in ipairs(potList) do
          if i==1 then
            potsString = potsString .. v;
          else
            potsString = potsString .. ", " .. v;
          end
        end
        macroStr = "#showtooltip \n/castsequence reset=" .. resetType .. " " .. potsString;
      end
      EditMacro("HAMHealthPot", "HAMHealthPot", nil, macroStr, 1, nil)
    end
  end)
  
  end
