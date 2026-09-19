---@diagnostic disable: undefined-global
local L = LibStub("AceLocale-3.0"):GetLocale("AutoPotion")
local addonName, ham = ...

---@class Frame
ham.foodSettingsFrame = CreateFrame("Frame")
local ICON_SIZE = 50
local PADDING = 25

local foodFrames = {}
local foodTextures = {}
local foodFirstIcon = nil
local foodPositionX = 0
local foodAnchor = nil

-- Resize the scrollable content to fit the food icon row.
function ham.foodSettingsFrame:recalculateContentHeight()
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

	considerBottom(foodAnchor)
	for _, frame in pairs(foodFrames) do considerBottom(frame) end

	if lowest ~= nil then
		self.content:SetHeight((contentTop - lowest) + PADDING)
	end
end

-- Create a food priority icon frame
function ham.foodSettingsFrame:createFoodPrioFrame(id, iconTexture, positionx)
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

	if foodFirstIcon == nil then
		icon:SetPoint("TOPLEFT", foodAnchor, 0, -PADDING)
		foodFirstIcon = icon
	else
		icon:SetPoint("TOPLEFT", foodFirstIcon, positionx, 0)
	end
	icon:Show()
	table.insert(foodFrames, icon)
	table.insert(foodTextures, texture)
	return icon
end

-- Update the Food Priority section
function ham.foodSettingsFrame:updateFoodPrio()
	-- hide existing
	for _, frame in pairs(foodFrames) do
		frame:Hide()
	end

	foodPositionX = 0

	-- Build the prioritized food list for the current context
	if ham.getFood then
		local food = ham.getFood()
		local shown = 0
		for _, item in ipairs(food) do
			if item.getCount and item.getCount() > 0 then
				local id = item.getId()
				local _, _, _, _, _, _, _, _, _, iconTexture = C_Item.GetItemInfo(id)
				local idx = shown + 1
				local currentFrame = foodFrames[idx]
				local currentTexture = foodTextures[idx]
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
					self:createFoodPrioFrame(id, iconTexture, foodPositionX)
					foodPositionX = foodPositionX + (ICON_SIZE + (ICON_SIZE / 2))
				end
				shown = shown + 1
			end
		end
	end
	self:recalculateContentHeight()
end

function ham.foodSettingsFrame:InitializeOptions()
	-- Create the sub-panel inside the Interface Options container
	self.panel = CreateFrame("Frame", addonName .. "Food", InterfaceOptionsFramePanelContainer)
	self.panel.name = L["AutoFood"]

	-- Register as a subcategory of the main AutoPotion panel
	if InterfaceOptions_AddCategory then
		self.panel.parent = addonName
		InterfaceOptions_AddCategory(self.panel)
	else
		local category = Settings.RegisterCanvasLayoutSubcategory(ham.settingsFrame.category, self.panel, self.panel.name)
		self.panel.categoryID = category:GetID()
	end

	-- Refresh priority preview when the panel is shown
	self.panel:SetScript("OnShow", function()
		ham.checkTinker()
		ham.updateHeals()
		ham.updateMacro()
		ham.foodSettingsFrame:updateFoodPrio()
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
	includeBuffFoodButton:SetChecked(HAMDB.includeBuffFood)

	-- food priority header
	local foodPrioTitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	foodPrioTitle:SetPoint("TOPLEFT", includeBuffFoodButton, "BOTTOMLEFT", 0, -PADDING)
	foodPrioTitle:SetText(L["Food Priority"])

	foodAnchor = foodPrioTitle
	self:recalculateContentHeight()
end
