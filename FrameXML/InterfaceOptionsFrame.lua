local defaults = {
	renewal = true,
	exhilaration = true,
	bitterImmunity = true,
	cirmsonVial = false,
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

	local renewalButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	renewalButton:SetPoint("TOPLEFT", 20, -20)
	renewalButton.Text:SetText("Enable Renewal")
	renewalButton:HookScript("OnClick", function(_, btn, down)
		self.db.renewal = renewalButton:GetChecked()
	end)
	renewalButton:SetChecked(self.db.renewal)

	local exhilarationButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	exhilarationButton:SetPoint("TOPLEFT", renewalButton, 0, -30)
	exhilarationButton.Text:SetText("Enable Exhilaration")
	exhilarationButton:HookScript("OnClick", function(_, btn, down)
		self.db.exhilaration = exhilarationButton:GetChecked()
	end)
	exhilarationButton:SetChecked(self.db.exhilaration)

	local bitterImmunityButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	bitterImmunityButton:SetPoint("TOPLEFT", exhilarationButton, 0, -30)
	bitterImmunityButton.Text:SetText("Enable Bitter Immunity")
	bitterImmunityButton:HookScript("OnClick", function(_, btn, down)
		self.db.bitterImmunity = bitterImmunityButton:GetChecked()
	end)
	bitterImmunityButton:SetChecked(self.db.bitterImmunity)

	local cirmsonVialButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	cirmsonVialButton:SetPoint("TOPLEFT", bitterImmunityButton, 0, -30)
	cirmsonVialButton.Text:SetText("Enable Bitter Immunity")
	cirmsonVialButton:HookScript("OnClick", function(_, btn, down)
		self.db.cirmsonVial = cirmsonVialButton:GetChecked()
	end)
	cirmsonVialButton:SetChecked(self.db.cirmsonVial)

	local btn = CreateFrame("Button", nil, self.panel, "UIPanelButtonTemplate")
	btn:SetPoint("TOPLEFT", cirmsonVialButton, 0, -40)
	btn:SetText("Reset to Default")
	btn:SetWidth(120)
	btn:SetScript("OnClick", function()
		HAMDB = CopyTable(defaults)
		self.db = HAMDB
		renewalButton:SetChecked(self.db.renewal)
		exhilarationButton:SetChecked(self.db.exhilaration)
		bitterImmunityButton:SetChecked(self.db.bitterImmunity)
		cirmsonVialButton:SetChecked(self.db.cirmsonVial)
		print("Reset successful!")
	end)

	InterfaceOptions_AddCategory(self.panel)
end

SLASH_HAM1 = "/ham"
SLASH_HAM2 = "/healtsthoneautomacro"

SlashCmdList.HAM = function(msg, editBox)
	InterfaceOptionsFrame_OpenToCategory(panel.panel)
end