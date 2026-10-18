---@diagnostic disable: undefined-global
local L = LibStub("AceLocale-3.0"):GetLocale("AutoPotion")
local addonName, ham = ...

---@class Frame
ham.manaPotionSettingsFrame = CreateFrame("Frame")
local PADDING = 25

-- Resize the scrollable content to fit down to the mana potion preview row.
function ham.manaPotionSettingsFrame:recalculateContentHeight()
	if self.content == nil then return end
	local contentTop, titleTop = self.content:GetTop(), self.priorityTitle:GetTop()
	if contentTop == nil or titleTop == nil then return end
	self.content:SetHeight(contentTop - titleTop + PADDING + ham.PREVIEW_ROW_HEIGHT + PADDING)
end

-- Update the Mana Potion Priority section with the mana potion items in the bags, best first
function ham.manaPotionSettingsFrame:updateManaPotionPrio()
	local row = self.priorityRow
	if row == nil then return end
	row:showItemsInBags(ham.getManaPotions())
	self:recalculateContentHeight()
end

function ham.manaPotionSettingsFrame:InitializeOptions()
	-- Create the sub-panel inside the Interface Options container
	self.panel = CreateFrame("Frame", addonName .. "ManaPotion", InterfaceOptionsFramePanelContainer)
	self.panel.name = L["AutoManaPotion"]

	-- Register as a page below the AutoPotion root (the Information page)
	ham.infoSettingsFrame:addSubcategory(self.panel)

	-- Refresh the priority preview when the panel is shown; the macros follow once combat allows
	self.panel:SetScript("OnShow", function()
		ham.refreshPreviews()
		ham.requestMacroUpdate()
	end)

	-- scrollable area, matching the main panel's layout
	self.scrollFrame = CreateFrame("ScrollFrame", addonName .. "ManaPotionScrollFrame", self.panel,
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
	title:SetText(L["AutoManaPotion"])

	-- subtitle
	local subtitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	subtitle:SetPoint("TOPLEFT", 0, -40)
	subtitle:SetText(L["Shows the mana potion that will currently be used, based on what is in your bags."])

	-- include rejuvenation potions toggle (potions that restore health and mana)
	local includeRejuvenationButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
	includeRejuvenationButton:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -PADDING)
	includeRejuvenationButton.Text:SetText(L["Include Rejuvenation Potions"])
	includeRejuvenationButton:HookScript("OnClick", function(_, btn, down)
		ham.settingsFrame:updateConfig("includeRejuvenation", includeRejuvenationButton:GetChecked())
	end)
	includeRejuvenationButton:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(includeRejuvenationButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetText(L["Also use potions that restore health and mana (Rejuvenation potions, Cavedweller's Delight, Refreshing Serum, ...). They are sorted by the amount of mana they restore."], nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)
	includeRejuvenationButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	ham.settingsFrame:trackOptionCheckbox(includeRejuvenationButton, "includeRejuvenation")

	-- mana potion priority header
	local manaPotionPrioTitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	manaPotionPrioTitle:SetPoint("TOPLEFT", includeRejuvenationButton, "BOTTOMLEFT", 0, -PADDING)
	manaPotionPrioTitle:SetText(L["Mana Potion Priority"])

	self.priorityTitle = manaPotionPrioTitle
	self.priorityRow = ham.newPreviewRow(self.content, manaPotionPrioTitle, 0, -PADDING)
end
