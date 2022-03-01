-- This file is loaded from "HealthstoneAutoMacro.toc"
do

  local healthstoneId = 5512;
  local siphId = 176409; -- Rejuvenating Siphoned Essence - Torghast Potion
  local cosmicHealingId = 187802; -- Cosmic Healing Potion
  local spiritualHealingId = 171267; -- Spiritual Healing Potion
  local phialId = 177278; -- Phial of Serenity
  
  
  function getPotNames()
    siphName = GetItemInfo(siphId);
    cosmicHealingName = GetItemInfo(cosmicHealingId);
	  spiritualHealingName = GetItemInfo(spiritualHealingId);
  
    -- fall back on connect sometimes GetItem fail
    if siphName==nil then
      siphName = "Rejuvenating Siphoned Essence"
    end
    if cosmicHealingName==nil then
      cosmicHealingName = "Cosmic Healing Potion"
    end
	if spiritualHealingName==nil then
      spiritualHealingName = "Spiritual Healing Potion"
    end
    return siphName, cosmicHealingName, spiritualHealingName
  end
  
  function getPots()
    siphName, cosmicHealingName, spiritualHealingName  = getPotNames()
    return {
      {siphName, GetItemCount(siphId, false, false)},
      {cosmicHealingName, GetItemCount(cosmicHealingId, false, false)},
	    {spiritualHealingName, GetItemCount(spiritualHealingId, false, false)}
  
    }
  end
  
  function getHealthstone()
    healthstoneName = GetItemInfo(healthstoneId);
    if healthstoneName==nil then
      healthstoneName = "Healthstone"
    end
    return healthstoneName, GetItemCount(healthstoneId, false, false);
  end
  
  function getPhial()
    phialName = GetItemInfo(phialId);
    if phialName==nil then
      phialName = "Phial of Serenity"
    end
    return phialName, GetItemCount(phialId, false, false);
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
      local phialName, phialCounter = getPhial()
      local playerClass, englishClass, classIndex = UnitClass("player");
      local resetType = "combat"
      local macroStr, potName, foundPots, foundPhial, foundHealthstone, potList, potListCounter, potsString;
  
      foundPots = false;
      foundPhial = false;
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
  
      if phialCounter > 0 then
        foundPhial = true;
      end

      if healthstoneCounter > 0 then
        foundHealthstone = true;
      end
  
      -- Currently the Priority is: vial -> healthstone -> pot -> phial
      -- after 50k+ health it needs to be: healtstone -> phial -> pot
      
      if englishClass=="ROGUE" then
        resetType = "30"
        table.insert(potList, "Crimson Vial")
        potListCounter=potListCounter+1;
      end
      if foundHealthstone==true then
        table.insert(potList,healthstoneName)
        potListCounter=potListCounter+1;
      end
      if foundPots==true then
        table.insert(potList,potName)
        potListCounter=potListCounter+1;
      end
      if foundPhial==true then
        table.insert(potList,phialName)
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
      end
      macroStr = "#showtooltip \n/castsequence reset=" .. resetType .. " " .. potsString;
      EditMacro("HAMHealthPot", "HAMHealthPot", nil, macroStr, 1, nil)
    end
  end)
  
  end
