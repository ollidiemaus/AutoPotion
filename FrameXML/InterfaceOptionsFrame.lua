local addonName, ham = ...
local defaults = {
	renewal = true,
	exhilaration = true,
	fortitudeOfTheBear = true,
	bitterImmunity = true,
	crimsonVial = false,
	desperatePrayer = true,
	expelHarm = false,
	healingElixir = true,
	witheringPotion = false,
}

local panel = CreateFrame("Frame")
local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)

function panel:OnEvent(event, addOnName)
	if addOnName == "AutoPotion" then
		HAMDB = HAMDB or CopyTable(defaults)
		self.db = HAMDB
		self:InitializeOptions()
	end
	---LEGACY
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
	self.panel.name = "Auto Potion"

	local title = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
	title:SetPoint("TOP")
	title:SetText("Auto Potion Settings")

	local subtitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
	subtitle:SetPoint("TOPLEFT", 20, -30)
	subtitle:SetText("Here you can configure the behaviour of the Addon eg. if you want to include class spells")

	if isClassic == false then
		--[[local dkTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
	dkTitle:SetPoint("TOPLEFT", subtitle, 0, -50)
	dkTitle:SetText("Death Knight")

	local dhTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
	dhTitle:SetPoint("TOPLEFT", subtitle, 0, -50)
	dhTitle:SetText("Demon Hunter")--]]
		local druidTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
		druidTitle:SetPoint("TOPLEFT", subtitle, 0, -30)
		druidTitle:SetText("Druid")

		local renewalButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
		renewalButton:SetPoint("TOPLEFT", druidTitle, 0, -15)
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

		--[[local evokerTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
	evokerTitle:SetPoint("TOPLEFT", subtitle, 0, -50)
	evokerTitle:SetText("Evoker")--]]
		local hunterTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
		hunterTitle:SetPoint("TOPLEFT", renewalButton, 0, -50)
		hunterTitle:SetText("Hunter")

		local exhilarationButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
		exhilarationButton:SetPoint("TOPLEFT", hunterTitle, 0, -15)
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

		local fortitudeOfTheBearButton = CreateFrame("CheckButton", nil, self.panel,
			"InterfaceOptionsCheckButtonTemplate")
		fortitudeOfTheBearButton:SetPoint("TOPLEFT", exhilarationButton, 200, 0)
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

		--[[local mageTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
	mageTitle:SetPoint("TOPLEFT", subtitle, 0, -50)
	mageTitle:SetText("Mage")--]]
		local monkTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
		monkTitle:SetPoint("TOPLEFT", exhilarationButton, 0, -50)
		monkTitle:SetText("Monk")

		local expelHarmButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
		expelHarmButton:SetPoint("TOPLEFT", monkTitle, 0, -15)
		expelHarmButton.Text:SetText("Use Expel Harm")
		expelHarmButton:HookScript("OnClick", function(_, btn, down)
			self.db.expelHarm = expelHarmButton:GetChecked()
		end)
		expelHarmButton:HookScript("OnEnter", function(_, btn, down)
			GameTooltip:SetOwner(expelHarmButton, "ANCHOR_TOPRIGHT")
			GameTooltip:SetSpellByID(ham.expelHarm);
			GameTooltip:Show()
		end)
		expelHarmButton:HookScript("OnLeave", function(_, btn, down)
			GameTooltip:Hide()
		end)
		expelHarmButton:SetChecked(self.db.expelHarm)

		local healingElixirButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
		healingElixirButton:SetPoint("TOPLEFT", expelHarmButton, 200, 0)
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

		--[[local paladinTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
	paladinTitle:SetPoint("TOPLEFT", subtitle, 0, -50)
	paladinTitle:SetText("Paladin")--]]
		local priestTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
		priestTitle:SetPoint("TOPLEFT", expelHarmButton, 0, -50)
		priestTitle:SetText("Priest")

		local desperatePrayerButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
		desperatePrayerButton:SetPoint("TOPLEFT", priestTitle, 0, -15)
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

		local rogueTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
		rogueTitle:SetPoint("TOPLEFT", desperatePrayerButton, 0, -50)
		rogueTitle:SetText("Rogue")

		local crimsonVialButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
		crimsonVialButton:SetPoint("TOPLEFT", rogueTitle, 0, -15)
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

		--[[local shamanTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
	shamanTitle:SetPoint("TOPLEFT", subtitle, 0, -50)
	shamanTitle:SetText("Shaman")

	local wlTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
	wlTitle:SetPoint("TOPLEFT", subtitle, 0, -50)
	wlTitle:SetText("Warlock")--]]
		local warriorTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
		warriorTitle:SetPoint("TOPLEFT", crimsonVialButton, 0, -50)
		warriorTitle:SetText("Warrior")
		local bitterImmunityButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
		bitterImmunityButton:SetPoint("TOPLEFT", warriorTitle, 0, -15)
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

		local witheringPotTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
		witheringPotTitle:SetPoint("TOPLEFT", bitterImmunityButton, 0, -50)
		witheringPotTitle:SetText("Withering Potions")

		local witheringPotionButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
		witheringPotionButton:SetPoint("TOPLEFT", witheringPotTitle, 0, -15)
		witheringPotionButton.Text:SetText("Use Potion of Withering Vitality")
		witheringPotionButton:HookScript("OnClick", function(_, btn, down)
			self.db.witheringPotion = witheringPotionButton:GetChecked()
		end)
		witheringPotionButton:HookScript("OnEnter", function(_, btn, down)
			GameTooltip:SetOwner(witheringPotionButton, "ANCHOR_TOPRIGHT")
			GameTooltip:SetItemByID(ham.witheringR3.getId())
			GameTooltip:Show()
		end)
		witheringPotionButton:HookScript("OnLeave", function(_, btn, down)
			GameTooltip:Hide()
		end)
		witheringPotionButton:SetChecked(self.db.witheringPotion)

		local btn = CreateFrame("Button", nil, self.panel, "UIPanelButtonTemplate")
		btn:SetPoint("TOPLEFT", witheringPotionButton, 0, -50)
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
			expelHarmButton:SetChecked(self.db.expelHarm)
			healingElixirButton:SetChecked(self.db.healingElixir)
			witheringPotionButton:SetChecked(self.db.witheringPotion)
			print("Reset successful!")
		end)
	end
	InterfaceOptions_AddCategory(self.panel)
end

SLASH_HAM1 = "/ham"
SLASH_HAM2 = "/healtsthoneautomacro"
SLASH_HAM3 = "/ap"
SLASH_HAM4 = "/autopotion"

SlashCmdList.HAM = function(msg, editBox)
	InterfaceOptionsFrame_OpenToCategory(panel.panel)
end
