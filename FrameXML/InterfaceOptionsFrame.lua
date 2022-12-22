local addonName, addon = ...
local defaults = {
	renewal = true,
	exhilaration = true,
	bitterImmunity = true,
	crimsonVial = false,
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
	renewalButton:SetChecked(self.db.renewal)

	local exhilarationButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	exhilarationButton:SetPoint("TOPLEFT", renewalButton, 0, -30)
	exhilarationButton.Text:SetText("Use Exhilaration")
	exhilarationButton:HookScript("OnClick", function(_, btn, down)
		self.db.exhilaration = exhilarationButton:GetChecked()
	end)
	exhilarationButton:SetChecked(self.db.exhilaration)

	local bitterImmunityButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	bitterImmunityButton:SetPoint("TOPLEFT", exhilarationButton, 0, -30)
	bitterImmunityButton.Text:SetText("Use Bitter Immunity")
	bitterImmunityButton:HookScript("OnClick", function(_, btn, down)
		self.db.bitterImmunity = bitterImmunityButton:GetChecked()
	end)
	bitterImmunityButton:SetChecked(self.db.bitterImmunity)

	local crimsonVialButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	crimsonVialButton:SetPoint("TOPLEFT", bitterImmunityButton, 0, -30)
	crimsonVialButton.Text:SetText("Use Crimson Vial")
	crimsonVialButton:HookScript("OnClick", function(_, btn, down)
		self.db.crimsonVial = crimsonVialButton:GetChecked()
	end)
	crimsonVialButton:SetChecked(self.db.crimsonVial)

	local btn = CreateFrame("Button", nil, self.panel, "UIPanelButtonTemplate")
	btn:SetPoint("TOPLEFT", crimsonVialButton, 0, -40)
	btn:SetText("Reset to Default")
	btn:SetWidth(120)
	btn:SetScript("OnClick", function()
		HAMDB = CopyTable(defaults)
		self.db = HAMDB
		renewalButton:SetChecked(self.db.renewal)
		exhilarationButton:SetChecked(self.db.exhilaration)
		bitterImmunityButton:SetChecked(self.db.bitterImmunity)
		crimsonVialButton:SetChecked(self.db.crimsonVial)
		print("Reset successful!")
	end)

	InterfaceOptions_AddCategory(self.panel)
end

SLASH_HAM1 = "/ham"
SLASH_HAM2 = "/healtsthoneautomacro"

SlashCmdList.HAM = function(msg, editBox)
	InterfaceOptionsFrame_OpenToCategory(panel.panel)
end