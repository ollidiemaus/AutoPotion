---@diagnostic disable: undefined-global
local L = LibStub("AceLocale-3.0"):GetLocale("AutoPotion")
local addonName, ham = ...

---@class Frame
ham.foodSettingsFrame = CreateFrame("Frame")
local PADDING = 25
local SUB_OPTION_INDENT = 20

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

-- The boxes' labels per buff kind (ham.BUFF_KINDS)
local BUFF_KIND_LABELS = {
	ap = L["Attack Power"], sp = L["Spell Power"], healing = L["Healing"], sta = L["Stamina"],
	str = L["Strength"], agi = L["Agility"], int = L["Intellect"], spi = L["Spirit"],
	primary = L["Primary Stat"], hpRegen = L["Health Regen"], mpRegen = L["Mana Regen"], hit = L["Hit"],
	crit = L["Critical Strike"], haste = L["Haste"], mastery = L["Mastery"], vers = L["Versatility"],
	expertise = L["Expertise"], armorPen = L["Armor Penetration"], dodge = L["Dodge"], parry = L["Parry"],
	armor = L["Armor"], resist = L["Resistance"], fishing = L["Fishing"], other = L["Other"],
}
local BUFF_KIND_COLUMNS = 3
local BUFF_KIND_COLUMN_WIDTH = 170

-- A box per buff kind of the flavor's buff food and drinks, in columns below `relativeTo`,
-- indented like the other refinements of "Include Buff Food" and greyed out while it's unticked.
-- Buff food with no ticked kind isn't eaten. Returns the first box of the last row (`relativeTo`
-- without kinds).
function ham.foodSettingsFrame:createBuffKindBoxes(relativeTo)
	local rowStart = relativeTo
	for i, kind in ipairs(ham.buffKindsOfFlavor()) do
		local button = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
		local column = (i - 1) % BUFF_KIND_COLUMNS
		if column == 0 then
			button:SetPoint("TOPLEFT", rowStart, "BOTTOMLEFT", 0, 0)
			rowStart = button
		else
			button:SetPoint("TOPLEFT", rowStart, "TOPLEFT", column * BUFF_KIND_COLUMN_WIDTH, 0)
		end
		button.Text:SetText(BUFF_KIND_LABELS[kind])
		button:HookScript("OnClick", function(_, btn, down)
			ham.setBuffKindWanted(kind, button:GetChecked())
			ham.refreshPreviews()
			ham.requestMacroUpdate()
		end)
		button:HookScript("OnEnter", function(_, btn, down)
			GameTooltip:SetOwner(button, "ANCHOR_TOPRIGHT")
			GameTooltip:SetText(kind == "other"
				and L["Eat buff food whose buff raises no single stat: feasts, random buffs and the like. Untick it to keep that buff food in your bags."]
				or L["Eat buff food raising this stat. Untick it to keep that buff food in your bags; food raising another ticked stat too is still eaten."],
				nil, nil, nil, nil, true)
			GameTooltip:Show()
		end)
		button:HookScript("OnLeave", function(_, btn, down)
			GameTooltip:Hide()
		end)
		ham.settingsFrame:trackCheckbox(button, function() return ham.isBuffKindWanted(kind) end)
		ham.settingsFrame:trackEnabled(button, function() return ham.options.includeBuffFood end)
	end
	return rowStart
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

	-- "only when the buff is missing", a refinement of "Include Buff Food": indented below it and
	-- greyed out while it's unticked
	local onlyWhenMissingButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
	onlyWhenMissingButton:SetPoint("TOPLEFT", includeBuffFoodButton, "BOTTOMLEFT", SUB_OPTION_INDENT, 0)
	onlyWhenMissingButton.Text:SetText(L["Only when the buff is missing"])
	onlyWhenMissingButton:HookScript("OnClick", function(_, btn, down)
		ham.settingsFrame:updateConfig("buffFoodOnlyWhenMissing", onlyWhenMissingButton:GetChecked())
	end)
	onlyWhenMissingButton:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(onlyWhenMissingButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetText(L["Eat buff food first while you don't have its buff (\"Well Fed\" for food, \"Relaxed\" for drinks), even before conjured food. While you have it, buff food comes last and is only eaten when nothing else is left."])
		GameTooltip:Show()
	end)
	onlyWhenMissingButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	ham.settingsFrame:trackOptionCheckbox(onlyWhenMissingButton, "buffFoodOnlyWhenMissing")
	ham.settingsFrame:trackEnabled(onlyWhenMissingButton, function() return ham.options.includeBuffFood end)

	local lastBuffRow = self:createBuffKindBoxes(onlyWhenMissingButton)

	-- weakest food first toggle (the food restoring the least health first, for leveling)
	local weakestFoodButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
	weakestFoodButton:SetPoint("TOPLEFT", lastBuffRow, "BOTTOMLEFT", -SUB_OPTION_INDENT, -8)
	weakestFoodButton.Text:SetText(L["Weakest Food First"])
	weakestFoodButton:HookScript("OnClick", function(_, btn, down)
		ham.settingsFrame:updateConfig("weakestFoodFirst", weakestFoodButton:GetChecked())
	end)
	weakestFoodButton:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(weakestFoodButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetText(L["Eat the food that restores the least health first and keep the better food for later. Meant for leveling. Any food in your bags counts, whatever its level. Conjured food still goes first, its weakest one first."], nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)
	weakestFoodButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	ham.settingsFrame:trackOptionCheckbox(weakestFoodButton, "weakestFoodFirst")

	-- food priority header
	local foodPrioTitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	foodPrioTitle:SetPoint("TOPLEFT", weakestFoodButton, "BOTTOMLEFT", 0, -PADDING)
	foodPrioTitle:SetText(L["Food Priority"])

	self.priorityTitle = foodPrioTitle
	self.priorityRow = ham.newPreviewRow(self.content, foodPrioTitle, 0, -PADDING)
end
