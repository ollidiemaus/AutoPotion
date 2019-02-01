-- This file is loaded from "HealthstoneAutoMacro.toc"

do

local HealPotMacroIcon = CreateFrame("Frame")
HealPotMacroIcon:RegisterEvent("BAG_UPDATE")
HealPotMacroIcon:RegisterEvent("PLAYER_LOGIN")
HealPotMacroIcon:SetScript("OnEvent",function(self,event,...)
 item = GetItemCount("Healthstone")==0 and "Coastal Healing Potion" or "Healthstone"
 EditMacro("HAMHealthPot", "HAMHealthPot", nil, "#showtooltip \n/use " .. item, 1, nil)
end)

end