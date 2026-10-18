---@diagnostic disable: undefined-global
local L = LibStub("AceLocale-3.0"):GetLocale("AutoPotion")
local addonName, ham = ...

---@class Frame
ham.bandageSettingsFrame = CreateFrame("Frame")
local PADDING = 25

-- Resize the scrollable content to fit down to the bandage preview row.
function ham.bandageSettingsFrame:recalculateContentHeight()
	if self.content == nil then return end
	local contentTop, titleTop = self.content:GetTop(), self.priorityTitle:GetTop()
	if contentTop == nil or titleTop == nil then return end
	self.content:SetHeight(contentTop - titleTop + PADDING + ham.PREVIEW_ROW_HEIGHT + PADDING)
end

-- Update the Bandage Priority section with the bandage spell the macro casts first, if any, then
-- the bandage items in the bags, best first
function ham.bandageSettingsFrame:updateBandagePrio()
	local row = self.priorityRow
	if row == nil then return end
	row:reset()
	local spell = ham.getBandageSpell()
	if spell then row:add("spell", spell.getId()) end
	row:addItemsInBags(ham.getBandages())
	row:finish()
	self:recalculateContentHeight()
end

function ham.bandageSettingsFrame:InitializeOptions()
	-- Create the sub-panel inside the Interface Options container
	self.panel = CreateFrame("Frame", addonName .. "Bandage", InterfaceOptionsFramePanelContainer)
	self.panel.name = L["AutoBandage"]

	-- Register as a page below the AutoPotion root (the Information page)
	ham.infoSettingsFrame:addSubcategory(self.panel)

	-- Refresh the priority preview when the panel is shown; the macros follow once combat allows
	self.panel:SetScript("OnShow", function()
		ham.refreshPreviews()
		ham.requestMacroUpdate()
	end)

	-- scrollable area, matching the main panel's layout
	self.scrollFrame = CreateFrame("ScrollFrame", addonName .. "BandageScrollFrame", self.panel,
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
	title:SetText(L["AutoBandage"])

	-- subtitle
	local subtitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	subtitle:SetPoint("TOPLEFT", 0, -40)
	subtitle:SetText(L["Shows the bandage that will currently be used, based on what is in your bags."])

	-- Forever: Rapid Regeneration (Troll racial) before the bandage; offered to every character,
	-- like the healing spells on the AutoPotion page
	local lastElement = subtitle
	if ham.isForever then
		local rapidRegenerationButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
		rapidRegenerationButton:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -PADDING)
		rapidRegenerationButton.Text:SetText(L["Use Rapid Regeneration (Troll racial) before bandages"])
		rapidRegenerationButton:HookScript("OnClick", function(_, btn, down)
			ham.settingsFrame:updateConfig("rapidRegenerationBandage", rapidRegenerationButton:GetChecked())
		end)
		ham.settingsFrame:trackOptionCheckbox(rapidRegenerationButton, "rapidRegenerationBandage")
		lastElement = rapidRegenerationButton
	end

	-- bandage priority header
	local bandagePrioTitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	bandagePrioTitle:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, -PADDING)
	bandagePrioTitle:SetText(L["Bandage Priority"])

	self.priorityTitle = bandagePrioTitle
	self.priorityRow = ham.newPreviewRow(self.content, bandagePrioTitle, 0, -PADDING)
end
