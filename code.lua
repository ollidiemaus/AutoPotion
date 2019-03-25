-- This file is loaded from "HealthstoneAutoMacro.toc"

do

local HealPotMacroIcon = CreateFrame("Frame")
HealPotMacroIcon:RegisterEvent("BAG_UPDATE")
HealPotMacroIcon:RegisterEvent("PLAYER_LOGIN")
HealPotMacroIcon:SetScript("OnEvent",function(self,event,...)
 pot = GetItemCount("Healthstone")==0 and "Coastal Healing Potion" or "Healthstone"
 item = GetItemCount("Silas' Vial of Continuous Curing")==0 and pot or "Silas' Vial of Continuous Curing"
 EditMacro("HAMHealthPot", "HAMHealthPot", nil, "#showtooltip \n/use " .. item, 1, nil)
end)

end
