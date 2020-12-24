-- This file is loaded from "HealthstoneAutoMacro.toc"
do

local healthstoneId = 5512;
local phialId = 177278; -- Phial of Serenity
local normalPotId = 171267; -- Spiritual Healing Potion
local siphId = 176409; -- Rejuvenating Siphoned Essence


function getPotNames()
  normalPotName = GetItemInfo(normalPotId);
  siphName = GetItemInfo(siphId);

  -- fall back because on connect sometimes GetItem fail
  if normalPotName==nil then
    normalPotName = "Spiritual Healing Potion"
  end
  if siphName==nil then
    siphName = "Rejuvenating Siphoned Essence"
  end
  return siphName, normalPotName
end

function getPots()
  siphName, normalPotName, phialName = getPotNames()
  return {
    {siphName, GetItemCount(siphId, false, false)},
    {normalPotName, GetItemCount(normalPotId, false, false)}

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
local healPotMacroIcon = CreateFrame("Frame");
healPotMacroIcon:RegisterEvent("BAG_UPDATE");
healPotMacroIcon:RegisterEvent("PLAYER_LOGIN");
healPotMacroIcon:RegisterEvent("PLAYER_REGEN_ENABLED");
healPotMacroIcon:RegisterEvent("PLAYER_REGEN_DISABLED");
healPotMacroIcon:SetScript("OnEvent",function(self,event,...)
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
    local macroStr, potName, foundPots;

    foundPots = false;
    foundPhial = false;
    foundHealthstone = false;

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

    -- Currently the Priority is: healthstone -> pot -> phial
    -- after 50k+ health it needs to be: healtstone -> phial -> pot
    potsString = ""
    if foundHealthstone==true then
      potsString = potsString .. healthstoneName;
    end
    if foundPhial==true then
      potsString = potsString .. ", " .. phialName;
    end
    if foundPots==true then
      potsString = potsString .. ", " .. potName;
    end
    if foundHealthstone==false and foundPhial==false and foundPots==false then
      macroStr = "#showtooltip"
    else
      macroStr = "#showtooltip \n/castsequence reset=combat " .. potsString;
    end

    EditMacro("HAMHealthPot", "HAMHealthPot", nil, macroStr, 1, nil)
  end
end)

end