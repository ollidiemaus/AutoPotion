---@diagnostic disable: undefined-global
local L = LibStub("AceLocale-3.0"):GetLocale("AutoPotion")
local addonName, ham = ...

---@class Frame
ham.drinkSettingsFrame = CreateFrame("Frame")
local PADDING = 25

-- Resize the scrollable content to fit down to the drink preview row.
function ham.drinkSettingsFrame:recalculateContentHeight()
	if self.content == nil then return end
	local contentTop, titleTop = self.content:GetTop(), self.priorityTitle:GetTop()
	if contentTop == nil or titleTop == nil then return end
	self.content:SetHeight(contentTop - titleTop + PADDING + ham.PREVIEW_ROW_HEIGHT + PADDING)
end

-- Update the Drink Priority section with the drink items in the bags, best first
function ham.drinkSettingsFrame:updateDrinkPrio()
	local row = self.priorityRow
	if row == nil then return end
	row:showItemsInBags(ham.getDrink())
	self:recalculateContentHeight()
end

function ham.drinkSettingsFrame:InitializeOptions()
	-- Create the sub-panel inside the Interface Options container
	self.panel = CreateFrame("Frame", addonName .. "Drink", InterfaceOptionsFramePanelContainer)
	self.panel.name = L["AutoDrink"]

	-- Register as a page below the AutoPotion root (the Information page)
	ham.infoSettingsFrame:addSubcategory(self.panel)

	-- Refresh the priority preview when the panel is shown; the macros follow once combat allows
	self.panel:SetScript("OnShow", function()
		ham.refreshPreviews()
		ham.requestMacroUpdate()
	end)

	-- scrollable area, matching the main panel's layout
	self.scrollFrame = CreateFrame("ScrollFrame", addonName .. "DrinkScrollFrame", self.panel,
		"UIPanelScrollFrameTemplate")
	self.scrollFrame:SetPoint("TOPLEFT", self.panel, "TOPLEFT", 16, -16)
	self.scrollFrame:SetPoint("BOTTOMRIGHT", self.panel, "BOTTOMRIGHT", -28, 16)
	self.scrollFrame:EnableMouseWheel(true)
	self.scrollFrame:SetScript("OnMouseWheel", function(sf, delta)
		local newScroll = sf:GetVerticalScroll() - delta * 40
		local maxScroll = sf:GetVerticalScrollRange()
		newScroll = math.max(0, math.min(newScroll, maxScroll))
		sf:SetVerticalScroll(newScroll)
	end)

	self.content = CreateFrame("Frame", nil, self.scrollFrame)
	self.content:SetSize(1, 1)
	self.scrollFrame:SetScrollChild(self.content)
	self.scrollFrame:HookScript("OnSizeChanged", function(_, width)
		self.content:SetWidth(width)
	end)

	-- title
	local title = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	title:SetPoint("TOP", 0, 0)
	title:SetText(L["AutoDrink"])

	-- subtitle
	local subtitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	subtitle:SetPoint("TOPLEFT", 0, -40)
	subtitle:SetText(L["Shows the drink that will currently be used, based on what is in your bags."])

	-- weakest drink first toggle (the drink restoring the least mana first, for leveling)
	local weakestDrinkButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
	weakestDrinkButton:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -PADDING)
	weakestDrinkButton.Text:SetText(L["Weakest Drink First"])
	weakestDrinkButton:HookScript("OnClick", function(_, btn, down)
		ham.settingsFrame:updateConfig("weakestDrinkFirst", weakestDrinkButton:GetChecked())
	end)
	weakestDrinkButton:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(weakestDrinkButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetText(L["Drink what restores the least mana first and keep the better drinks for later. Meant for leveling. Any drink in your bags counts, whatever its level. Conjured drinks still go first, the weakest one first."], nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)
	weakestDrinkButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	ham.settingsFrame:trackOptionCheckbox(weakestDrinkButton, "weakestDrinkFirst")

	-- drink priority header
	local drinkPrioTitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	drinkPrioTitle:SetPoint("TOPLEFT", weakestDrinkButton, "BOTTOMLEFT", 0, -PADDING)
	drinkPrioTitle:SetText(L["Drink Priority"])

	self.priorityTitle = drinkPrioTitle
	self.priorityRow = ham.newPreviewRow(self.content, drinkPrioTitle, 0, -PADDING)
end
