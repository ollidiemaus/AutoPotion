-- This file is loaded from "HealthstoneAutoMacro.toc"
-- #showtooltip
-- /castsequence reset=combat Healthstone, Coastal Healing Potion
do

local HSId = 5512;
local SilasPotId = 156634;
local NormalPotId = 152494;
local AbyssalPotId = 169451;
local EmeraldId = 166799; -- Emerald of Vigor

function getPotNames()
  SilasPotName = GetItemInfo(SilasPotId);
  NormalPotName = GetItemInfo(NormalPotId);
  AbyssalPotName = GetItemInfo(AbyssalPotId);
  EmeraldName = GetItemInfo(EmeraldId);

  -- fall back on connect sometimes GetItem fail
  if SilasPotName==nil then
    SilasPotName = "Silas' Vial of Continuous Curing"
  end
  if AbyssalPotName==nil then
    AbyssalPotName = "Abyssal Healing Potion"
  end
  if NormalPotName==nil then
    NormalPotName = "Coastal Healing Potion"
  end
  if EmeraldName==nil then
    EmeraldName = "Emerald of Vigor"
  end
  return SilasPotName, AbyssalPotName, NormalPotName, EmeraldName
end

function getPots()
  SilasPotName, AbyssalPotName, NormalPotName, EmeraldName = getPotNames()
  SilasNbr = GetItemCount(SilasPotId, false, false);
  return {
    {SilasPotName, SilasNbr},
    {EmeraldName, GetItemCount(EmeraldId, false, false)},
	{AbyssalPotName, GetItemCount(AbyssalPotId, false, false)},
    {NormalPotName, GetItemCount(NormalPotId, false, false)}

  }
end
function getHs()
  HSName = GetItemInfo(HSId);
  if HSName==nil then
    HSName = "Healthstone"
  end
  return HSName, GetItemCount(HSId, false, false);
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
    local HsName, HsNbr = getHs()
    local macroStr, potName, found;

    found = false;
    for i,v in ipairs(Pot) do
      if v[2] > 0 then
        found = true;
        potName = v[1]
        break;
      end
    end

    if HsNbr > 0 then
      if found==true then
        macroStr = "#showtooltip \n/castsequence reset=combat " .. HSName .. ", " .. potName;
      else
        macroStr = "#showtooltip \n/use " .. HSName;
      end
    elseif found==true then
      macroStr = "#showtooltip \n/use " .. potName;
    else
      macroStr = "#showtooltip"
    end
    EditMacro("HAMHealthPot", "HAMHealthPot", nil, macroStr, 1, nil)
  end
end)

end
