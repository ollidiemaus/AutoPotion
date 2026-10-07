---@diagnostic disable: undefined-global
local L = LibStub("AceLocale-3.0"):GetLocale("AutoPotion")
local addonName, ham = ...

---@class Frame
ham.manaPotionSettingsFrame = CreateFrame("Frame")
local ICON_SIZE = 50
local PADDING = 25

local manaPotionFrames = {}
local manaPotionTextures = {}
local manaPotionFirstIcon = nil
local manaPotionPositionX = 0
local manaPotionAnchor = nil

-- Resize the scrollable content to fit the mana potion icon row.
function ham.manaPotionSettingsFrame:recalculateContentHeight()
	if self.content == nil then return end
	local contentTop = self.content:GetTop()
	if contentTop == nil then return end

	local lowest = nil
	local function considerBottom(frame)
		if frame and frame:IsShown() then
			local bottom = frame:GetBottom()
			if bottom and (lowest == nil or bottom < lowest) then
				lowest = bottom
			end
		end
	end

	considerBottom(manaPotionAnchor)
	for _, frame in pairs(manaPotionFrames) do considerBottom(frame) end

	if lowest ~= nil then
		self.content:SetHeight((contentTop - lowest) + PADDING)
	end
end

-- Create a mana potion priority icon frame
function ham.manaPotionSettingsFrame:createManaPotionPrioFrame(id, iconTexture, positionx)
	local icon = CreateFrame("Frame", nil, self.content, UIParent)
	icon:SetFrameStrata("MEDIUM")
	icon:SetWidth(ICON_SIZE)
	icon:SetHeight(ICON_SIZE)
	icon:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(icon, "ANCHOR_TOPRIGHT")
		GameTooltip:SetItemByID(id)
		GameTooltip:Show()
	end)
	icon:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	local texture = icon:CreateTexture(nil, "BACKGROUND")
	texture:SetTexture(iconTexture)
	texture:SetAllPoints(icon)
	---@diagnostic disable-next-line: inject-field
	icon.texture = texture

	if manaPotionFirstIcon == nil then
		icon:SetPoint("TOPLEFT", manaPotionAnchor, 0, -PADDING)
		manaPotionFirstIcon = icon
	else
		icon:SetPoint("TOPLEFT", manaPotionFirstIcon, positionx, 0)
	end
	icon:Show()
	table.insert(manaPotionFrames, icon)
	table.insert(manaPotionTextures, texture)
	return icon
end

-- Update the Mana Potion Priority section.
function ham.manaPotionSettingsFrame:updateManaPotionPrio()
	-- hide existing
	for _, frame in pairs(manaPotionFrames) do
		frame:Hide()
	end

	manaPotionPositionX = 0

	-- Build the prioritized mana potion list for the current context
	if ham.getManaPotions then
		local potions = ham.getManaPotions()
		local shown = 0
		for _, item in ipairs(potions) do
			if item.getCount and item.getCount() > 0 then
				local id = item.getId()
				local _, _, _, _, _, _, _, _, _, iconTexture = C_Item.GetItemInfo(id)
				local idx = shown + 1
				local currentFrame = manaPotionFrames[idx]
				local currentTexture = manaPotionTextures[idx]
				if currentFrame ~= nil then
					currentFrame:SetScript("OnEnter", nil)
					currentFrame:SetScript("OnLeave", nil)
					currentFrame:HookScript("OnEnter", function(_, btn, down)
						GameTooltip:SetOwner(currentFrame, "ANCHOR_TOPRIGHT")
						GameTooltip:SetItemByID(id)
						GameTooltip:Show()
					end)
					currentFrame:HookScript("OnLeave", function(_, btn, down)
						GameTooltip:Hide()
					end)
					currentTexture:SetTexture(iconTexture)
					currentTexture:SetAllPoints(currentFrame)
					currentFrame.texture = currentTexture
					currentFrame:Show()
				else
					self:createManaPotionPrioFrame(id, iconTexture, manaPotionPositionX)
					manaPotionPositionX = manaPotionPositionX + (ICON_SIZE + (ICON_SIZE / 2))
				end
				shown = shown + 1
			end
		end
	end
	self:recalculateContentHeight()
end

function ham.manaPotionSettingsFrame:InitializeOptions()
	-- Create the sub-panel inside the Interface Options container
	self.panel = CreateFrame("Frame", addonName .. "ManaPotion", InterfaceOptionsFramePanelContainer)
	self.panel.name = L["AutoManaPotion"]

	-- Register as a page below the AutoPotion root (the Information page)
	ham.infoSettingsFrame:addSubcategory(self.panel)

	-- Refresh priority preview when the panel is shown
	self.panel:SetScript("OnShow", function()
		-- "Reset to Default" on the main panel rewrites HAMDB, so re-read the saved value
		if ham.manaPotionSettingsFrame.includeRejuvenationButton then
			ham.manaPotionSettingsFrame.includeRejuvenationButton:SetChecked(HAMDB.includeRejuvenation ~= false)
		end
		ham.manaPotionSettingsFrame:updateManaPotionPrio()
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
	includeRejuvenationButton:SetChecked(HAMDB.includeRejuvenation ~= false)
	self.includeRejuvenationButton = includeRejuvenationButton

	-- mana potion priority header
	local manaPotionPrioTitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	manaPotionPrioTitle:SetPoint("TOPLEFT", includeRejuvenationButton, "BOTTOMLEFT", 0, -PADDING)
	manaPotionPrioTitle:SetText(L["Mana Potion Priority"])

	manaPotionAnchor = manaPotionPrioTitle
	self:recalculateContentHeight()
end
