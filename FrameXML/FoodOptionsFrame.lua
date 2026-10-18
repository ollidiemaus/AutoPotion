---@diagnostic disable: undefined-global
local L = LibStub("AceLocale-3.0"):GetLocale("AutoPotion")
local addonName, ham = ...

---@class Frame
ham.foodSettingsFrame = CreateFrame("Frame")
local PADDING = 25

-- Resize the scrollable content to fit down to the food preview row.
function ham.foodSettingsFrame:recalculateContentHeight()
	if self.content == nil then return end
	local contentTop, titleTop = self.content:GetTop(), self.priorityTitle:GetTop()
	if contentTop == nil or titleTop == nil then return end
	self.content:SetHeight(contentTop - titleTop + PADDING + ham.PREVIEW_ROW_HEIGHT + PADDING)
end

-- Update the Food Priority section with the food items in the bags, best first
function ham.foodSettingsFrame:updateFoodPrio()
	local row = self.priorityRow
	if row == nil then return end
	row:showItemsInBags(ham.getFood())
	self:recalculateContentHeight()
end

function ham.foodSettingsFrame:InitializeOptions()
	-- Create the sub-panel inside the Interface Options container
	self.panel = CreateFrame("Frame", addonName .. "Food", InterfaceOptionsFramePanelContainer)
	self.panel.name = L["AutoFood"]

	-- Register as a page below the AutoPotion root (the Information page)
	ham.infoSettingsFrame:addSubcategory(self.panel)

	-- Refresh the priority preview when the panel is shown; the macros follow once combat allows
	self.panel:SetScript("OnShow", function()
		ham.refreshPreviews()
		ham.requestMacroUpdate()
	end)

	-- scrollable area, matching the main panel's layout
	self.scrollFrame = CreateFrame("ScrollFrame", addonName .. "FoodScrollFrame", self.panel,
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
	title:SetText(L["AutoFood"])

	-- subtitle
	local subtitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	subtitle:SetPoint("TOPLEFT", 0, -40)
	subtitle:SetText(L["Shows the food that will currently be used, based on what is in your bags."])

	-- include buff food toggle
	local includeBuffFoodButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
	includeBuffFoodButton:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -PADDING)
	includeBuffFoodButton.Text:SetText(L["Include Buff Food"])
	includeBuffFoodButton:HookScript("OnClick", function(_, btn, down)
		ham.settingsFrame:updateConfig("includeBuffFood", includeBuffFoodButton:GetChecked())
	end)
	includeBuffFoodButton:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(includeBuffFoodButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetText(L["Include \"Well Fed\"/\"Relaxed\" buff food and drink items (with situational secondary-stat bonuses) in the food and drink priority lists."])
		GameTooltip:Show()
	end)
	includeBuffFoodButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	ham.settingsFrame:trackOptionCheckbox(includeBuffFoodButton, "includeBuffFood")

	-- food priority header
	local foodPrioTitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	foodPrioTitle:SetPoint("TOPLEFT", includeBuffFoodButton, "BOTTOMLEFT", 0, -PADDING)
	foodPrioTitle:SetText(L["Food Priority"])

	self.priorityTitle = foodPrioTitle
	self.priorityRow = ham.newPreviewRow(self.content, foodPrioTitle, 0, -PADDING)
end
