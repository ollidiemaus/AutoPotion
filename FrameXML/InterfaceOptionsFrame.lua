local addonName, ham = ...
local defaults = {
	renewal = true,
	exhilaration = true,
	fortitudeOfTheBear = true,
	bitterImmunity = true,
	crimsonVial = false,
	desperatePrayer = true,
	healingElixir = true,
}

local panel = CreateFrame("Frame")

function panel:OnEvent(event, addOnName)
	if addOnName == "HealthstoneAutoMacro" then
		HAMDB = HAMDB or CopyTable(defaults)
		self.db = HAMDB
		self:InitializeOptions()
	end
end

panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", panel.OnEvent)

function panel:InitializeOptions()
	self.panel = CreateFrame("Frame")
	self.panel.name = "Healthstone Auto Macro"

	local title = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
	title:SetPoint("TOP")
	title:SetText("Healthstone Auto Marco Settings")
	
	local subtitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
	subtitle:SetPoint("TOPLEFT", 20, -30)
	subtitle:SetText("Here you can configure the behaviour of the Addon eg. if you want to include class spells")


	local renewalButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	renewalButton:SetPoint("TOPLEFT", subtitle, 20, -30)
	renewalButton.Text:SetText("Use Renewal")
	renewalButton:HookScript("OnClick", function(_, btn, down)
		self.db.renewal = renewalButton:GetChecked()
	end)
	renewalButton:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(renewalButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetSpellByID(ham.renewal);
		GameTooltip:Show()
	end)
	renewalButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	renewalButton:SetChecked(self.db.renewal)

	local exhilarationButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	exhilarationButton:SetPoint("TOPLEFT", renewalButton, 0, -30)
	exhilarationButton.Text:SetText("Use Exhilaration")
	exhilarationButton:HookScript("OnClick", function(_, btn, down)
		self.db.exhilaration = exhilarationButton:GetChecked()
	end)
	exhilarationButton:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(exhilarationButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetSpellByID(ham.exhilaration);
		GameTooltip:Show()
	end)
	exhilarationButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	exhilarationButton:SetChecked(self.db.exhilaration)


	local fortitudeOfTheBearButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	fortitudeOfTheBearButton:SetPoint("TOPLEFT", exhilarationButton, 0, -30)
	fortitudeOfTheBearButton.Text:SetText("Use Fortitude of the Bear")
	fortitudeOfTheBearButton:HookScript("OnClick", function(_, btn, down)
		self.db.fortitudeOfTheBear = fortitudeOfTheBearButton:GetChecked()
	end)
	fortitudeOfTheBearButton:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(fortitudeOfTheBearButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetSpellByID(ham.fortitudeOfTheBear);
		GameTooltip:Show()
	end)
	fortitudeOfTheBearButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	fortitudeOfTheBearButton:SetChecked(self.db.fortitudeOfTheBear)

	local bitterImmunityButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	bitterImmunityButton:SetPoint("TOPLEFT", fortitudeOfTheBearButton, 0, -30)
	bitterImmunityButton.Text:SetText("Use Bitter Immunity")
	bitterImmunityButton:HookScript("OnClick", function(_, btn, down)
		self.db.bitterImmunity = bitterImmunityButton:GetChecked()
	end)
	bitterImmunityButton:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(bitterImmunityButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetSpellByID(ham.bitterImmunity);
		GameTooltip:Show()
	end)
	bitterImmunityButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	bitterImmunityButton:SetChecked(self.db.bitterImmunity)

	local crimsonVialButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	crimsonVialButton:SetPoint("TOPLEFT", bitterImmunityButton, 0, -30)
	crimsonVialButton.Text:SetText("Use Crimson Vial")
	crimsonVialButton:HookScript("OnClick", function(_, btn, down)
		self.db.crimsonVial = crimsonVialButton:GetChecked()
	end)
	crimsonVialButton:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(crimsonVialButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetSpellByID(ham.crimsonVialSpell);
		GameTooltip:Show()
	end)
	crimsonVialButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	crimsonVialButton:SetChecked(self.db.crimsonVial)

	local desperatePrayerButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	desperatePrayerButton:SetPoint("TOPLEFT", crimsonVialButton, 0, -30)
	desperatePrayerButton.Text:SetText("Use Desperate Prayer")
	desperatePrayerButton:HookScript("OnClick", function(_, btn, down)
		self.db.desperatePrayer = desperatePrayerButton:GetChecked()
	end)
	desperatePrayerButton:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(desperatePrayerButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetSpellByID(ham.desperatePrayer);
		GameTooltip:Show()
	end)
	desperatePrayerButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	desperatePrayerButton:SetChecked(self.db.desperatePrayer)

	local healingElixirButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	healingElixirButton:SetPoint("TOPLEFT", desperatePrayerButton, 0, -30)
	healingElixirButton.Text:SetText("Use Healing Elixir")
	healingElixirButton:HookScript("OnClick", function(_, btn, down)
		self.db.healingElixir = healingElixirButton:GetChecked()
	end)
	healingElixirButton:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(healingElixirButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetSpellByID(ham.healingElixir);
		GameTooltip:Show()
	end)
	healingElixirButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	healingElixirButton:SetChecked(self.db.healingElixir)

	local btn = CreateFrame("Button", nil, self.panel, "UIPanelButtonTemplate")
	btn:SetPoint("TOPLEFT", healingElixirButton, 0, -40)
	btn:SetText("Reset to Default")
	btn:SetWidth(120)
	btn:SetScript("OnClick", function()
		HAMDB = CopyTable(defaults)
		self.db = HAMDB
		renewalButton:SetChecked(self.db.renewal)
		exhilarationButton:SetChecked(self.db.exhilaration)
		fortitudeOfTheBearButton:SetChecked(self.db.fortitudeOfTheBear)
		bitterImmunityButton:SetChecked(self.db.bitterImmunity)
		crimsonVialButton:SetChecked(self.db.crimsonVial)
		desperatePrayerButton:SetChecked(self.db.desperatePrayer)
		healingElixirButton:SetChecked(self.db.healingElixir)
		print("Reset successful!")
	end)

	InterfaceOptions_AddCategory(self.panel)
end

SLASH_HAM1 = "/ham"
SLASH_HAM2 = "/healtsthoneautomacro"

SlashCmdList.HAM = function(msg, editBox)
	InterfaceOptionsFrame_OpenToCategory(panel.panel)
end