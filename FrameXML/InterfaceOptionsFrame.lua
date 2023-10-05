local addonName, ham = ...
local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
local isWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
local panel = CreateFrame("Frame", "Auto Potion", InterfaceOptionsFramePanelContainer)
local classButtons = {}

function panel:OnEvent(event, addOnName)
	if addOnName == "AutoPotion" then
		HAMDB = HAMDB or CopyTable(ham.defaults)
		self:InitializeOptions()
	end
end

panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", panel.OnEvent)

function panel:InitializeOptions()
	local localizedClass, englishClass, classIndex = UnitClass("player");

	self.panel = CreateFrame("Frame", "Auto Potion", InterfaceOptionsFramePanelContainer)
	self.panel.name = "Auto Potion"

	-------------  HEADER  -------------
	local title = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
	title:SetPoint("TOP", 0, -2)
	title:SetText("Auto Potion Settings")

	local subtitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
	subtitle:SetPoint("TOPLEFT", 0, -30)
	subtitle:SetText("Here you can configure the behaviour of the Addon eg. if you want to include class spells")



	-------------  General  -------------
	local behaviourTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
	behaviourTitle:SetPoint("TOPLEFT", subtitle, 0, -30)
	behaviourTitle:SetText("Addon Behaviour")

	local cdResetButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	cdResetButton:SetPoint("TOPLEFT", behaviourTitle, 0, -30)
	cdResetButton.Text:SetText("Include Spell Cooldown in Macro")
	cdResetButton:HookScript("OnClick", function(_, btn, down)
		HAMDB.cdReset = cdResetButton:GetChecked()
	end)
	cdResetButton:SetChecked(HAMDB.cdReset)



	-------------  CLASSES  -------------
	if isClassic == false then
		local myClassTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
		myClassTitle:SetPoint("TOPLEFT", subtitle, 0, -105)
		myClassTitle:SetText(localizedClass)

		if next(ham.supportedSpells) ~= nil then
			local count = 0
			local lastbutton = nil
			local posy = -30
			for i, spell in ipairs(ham.supportedSpells) do
				--if IsSpellKnown(v) then
				local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(spell)
				local button = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")

				if count == 3 then
					lastbutton = nil
					count = 0
					posy = posy - 30
				end
				if lastbutton ~= nil then
					button:SetPoint("TOPLEFT", lastbutton, 200, 0)
				else
					button:SetPoint("TOPLEFT", myClassTitle, 0, posy)
				end
				button.Text:SetText("Use " .. name)
				button:HookScript("OnClick", function(_, btn, down)
					if button:GetChecked() then
						ham.insertIntoDB(spell)
					else
						ham.removeFromDB(spell)
					end
				end)
				button:HookScript("OnEnter", function(_, btn, down)
					GameTooltip:SetOwner(button, "ANCHOR_TOPRIGHT")
					GameTooltip:SetSpellByID(spell);
					GameTooltip:Show()
				end)
				button:HookScript("OnLeave", function(_, btn, down)
					GameTooltip:Hide()
				end)
				button:SetChecked(ham.dbContains(spell))
				table.insert(classButtons, spell, button)
				lastbutton = button
				count = count + 1
				--end
			end
		end


		-------------  ITEMS  -------------
		local itemsTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
		itemsTitle:SetPoint("TOPLEFT", subtitle, 0, -285)
		itemsTitle:SetText("Items")

		local witheringPotionButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
		witheringPotionButton:SetPoint("TOPLEFT", itemsTitle, 0, -30)
		witheringPotionButton.Text:SetText("Use Potion of Withering Vitality")
		witheringPotionButton:HookScript("OnClick", function(_, btn, down)
			HAMDB.witheringPotion = witheringPotionButton:GetChecked()
		end)
		witheringPotionButton:HookScript("OnEnter", function(_, btn, down)
			GameTooltip:SetOwner(witheringPotionButton, "ANCHOR_TOPRIGHT")
			GameTooltip:SetItemByID(ham.witheringR3.getId())
			GameTooltip:Show()
		end)
		witheringPotionButton:HookScript("OnLeave", function(_, btn, down)
			GameTooltip:Hide()
		end)
		witheringPotionButton:SetChecked(HAMDB.witheringPotion)



		-------------  RESET BUTTON  -------------
		local btn = CreateFrame("Button", nil, self.panel, "UIPanelButtonTemplate")
		btn:SetPoint("BOTTOMLEFT", 2, 3)
		btn:SetText("Reset to Default")
		btn:SetWidth(120)
		btn:SetScript("OnClick", function()
			HAMDB = CopyTable(ham.defaults)

			for spellID, button in pairs(classButtons) do
				if ham.dbContains(spellID) then
					button:SetChecked(true)
				else
					button:SetChecked(false)
				end
			end
			cdResetButton:SetChecked(HAMDB.cdReset)
			witheringPotionButton:SetChecked(HAMDB.witheringPotion)
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
