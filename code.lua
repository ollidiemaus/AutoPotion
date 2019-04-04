-- This file is loaded from "HealthstoneAutoMacro.toc"
-- #showtooltip
-- /castsequence reset=combat Healthstone, Coastal Healing Potion
do

local HSId = 5512;
local SilasPotId = 156634;
local NormalPotId = 152494;
local EmeraldId = 166799; -- Emerald of Vigor

function getPotNames()
  HSName = GetItemInfo(HSId);
  SilasPotName = GetItemInfo(SilasPotId);
  NormalPotName = GetItemInfo(NormalPotId);
  EmeraldName = GetItemInfo(EmeraldId);

  -- fall back on connect sometimes GetItem fail
  if HSName==nil then
    HSName = "Healthstone"
  end
  if SilasPotName==nil then
    SilasPotName = "Silas' Vial of Continuous Curing"
  end
  if NormalPotName==nil then
    NormalPotName = "Coastal Healing Potion"
  end
  if EmeraldName==nil then
    EmeraldName = "Emerald of Vigor"
  end
  return HSName, SilasPotName, NormalPotName, EmeraldName
end
function getPotCount()
  HealthstoneNbr = GetItemCount(HSId);
  SilasNbr = GetItemCount(SilasPotId);
  NormalPotNbr = GetItemCount(NormalPotId);
  EmeraldPotNbr = GetItemCount(EmeraldId);
  return HealthstoneNbr, SilasNbr, NormalPotNbr, EmeraldPotNbr
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
    local HSName, SilasPotName, NormalPotName, EmeraldName = getPotNames(); 
    local HealthstoneNbr, SilasNbr, NormalPotNbr, EmeraldPotNbr = getPotCount()
    local macroStr = ""

    if HealthstoneNbr > 0 then
      macroStr = "#showtooltip \n/castsequence reset=combat " .. HSName .. ", ";
      if SilasNbr > 0 then
        macroStr = macroStr .. SilasPotName;
      elseif EmeraldPotNbr > 0 then
        macroStr = macroStr .. EmeraldName;
      elseif NormalPotNbr > 0 then
        macroStr = macroStr .. NormalPotName;
      else
        macroStr = "#showtooltip \n/use " .. HSName;
      end
    elseif SilasNbr > 0 then
      macroStr = "#showtooltip \n/use " .. SilasPotName;
    elseif EmeraldPotNbr > 0 then
      macroStr = "#showtooltip \n/use " .. EmeraldName;
    elseif NormalPotNbr > 0 then
      macroStr = "#showtooltip \n/use " .. NormalPotName;
    else
      macroStr = "#showtooltip"
    end

    EditMacro("HAMHealthPot", "HAMHealthPot", nil, macroStr, 1, nil)
  end
end)

end
