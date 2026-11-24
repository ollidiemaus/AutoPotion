---@diagnostic disable: undefined-global
local L = LibStub("AceLocale-3.0"):GetLocale("AutoPotion")
local addonName, ham = ...

---@class Frame
ham.manaPotionSettingsFrame = CreateFrame("Frame")
local PADDING = 25
local SUB_OPTION_INDENT = 20

-- Resize the scrollable content to fit down to the mana potion preview row.
function ham.manaPotionSettingsFrame:recalculateContentHeight()
	if self.content == nil then return end
	local contentTop, titleTop = self.content:GetTop(), self.priorityTitle:GetTop()
	if contentTop == nil or titleTop == nil then return end
	self.content:SetHeight(contentTop - titleTop + PADDING + ham.PREVIEW_ROW_HEIGHT + PADDING)
end

-- Update the Mana Potion Priority section: the ticked mana spells the character knows, then the
-- mana potion items in the bags, best first
function ham.manaPotionSettingsFrame:updateManaPotionPrio()
	local row = self.priorityRow
	if row == nil then return end
	row:reset()
	for _, spell in ipairs(ham.myPlayer.getManaSpells()) do
		row:add("spell", spell.getId())
	end
	local items = ham.getManaPotions()
	local gem = ham.getManaGem()
	local demonicRune = ham.getDemonicRune()
	if gem then
		local firstPot = nil
		for _, item in ipairs(items) do
			if item.getCount() > 0 then
				firstPot = item
				break
			end
		end
		if not ham.shouldPutManaPotionBeforeGem(gem, firstPot or demonicRune) then
			items = { gem, unpack(items) }
		end
	end
	if demonicRune then
		items = { unpack(items) }
		table.insert(items, demonicRune)
	end
	row:addItemsInBags(items)
	row:finish()
	self:recalculateContentHeight()
end

-- The "Mana Spells" section: a box for every mana spell of the flavor, under a header per class,
-- above the item options. Built on PLAYER_LOGIN like the AutoPotion page's heal spells.
function ham.manaPotionSettingsFrame:InitializeManaSpells()
	if #ham.supportedManaSpells == 0 then return end
	local title = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	title:SetPoint("TOPLEFT", self.subtitle, "BOTTOMLEFT", 0, -PADDING)
	title:SetText(L["Mana Spells"])
	local lastRow = ham.settingsFrame:createSpellSection(self.content, title, ham.supportedManaSpells,
		"activatedManaSpells")
	self.firstItemOption:SetPoint("TOPLEFT", lastRow, "BOTTOMLEFT", 0, -PADDING)
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
	self.subtitle = subtitle

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
	-- moves below the mana spells once they are laid out (InitializeManaSpells)
	self.firstItemOption = includeRejuvenationButton

	-- use mana gems toggle (a mage's conjured mana gem before the mana potion)
	local useManaGemsButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
	useManaGemsButton:SetPoint("TOPLEFT", includeRejuvenationButton, "BOTTOMLEFT", 0, -8)
	useManaGemsButton.Text:SetText(L["Use mana gems"])
	useManaGemsButton:HookScript("OnClick", function(_, btn, down)
		ham.settingsFrame:updateConfig("useManaGems", useManaGemsButton:GetChecked())
	end)
	useManaGemsButton:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(useManaGemsButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetText(L["Use your best mana gem first. The next press drinks the mana potion, since they don't share a cooldown. The macro goes back to the mana gem when combat starts or ends, and when you haven't pressed it for as long as the mana gem's cooldown."], nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)
	useManaGemsButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	ham.settingsFrame:trackOptionCheckbox(useManaGemsButton, "useManaGems")
	ham.settingsFrame:trackEnabled(useManaGemsButton, function() return not ham.options.separateManaGemMacro end)

	-- skip mana gem while it is on cooldown and a mana potion is available sooner
	local skipManaGemOnCooldownButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
	skipManaGemOnCooldownButton:SetPoint("TOPLEFT", useManaGemsButton, "BOTTOMLEFT", SUB_OPTION_INDENT, 0)
	skipManaGemOnCooldownButton.Text:SetText(L["Show mana potion when mana gem is on cooldown"])
	skipManaGemOnCooldownButton:HookScript("OnClick", function(_, btn, down)
		ham.settingsFrame:updateConfig("skipManaGemOnCooldown", skipManaGemOnCooldownButton:GetChecked())
	end)
	skipManaGemOnCooldownButton:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(skipManaGemOnCooldownButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetText(L["When your mana gem is on cooldown and a mana potion is ready (or comes off cooldown sooner), show and use the mana potion first until the mana gem is ready again. Because macros cannot be edited in combat, if the mana gem comes off cooldown mid-fight, the macro stays potion-only until combat ends."], nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)
	skipManaGemOnCooldownButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	ham.settingsFrame:trackOptionCheckbox(skipManaGemOnCooldownButton, "skipManaGemOnCooldown")
	ham.settingsFrame:trackEnabled(skipManaGemOnCooldownButton, function()
		return ham.options.useManaGems and not ham.options.separateManaGemMacro
	end)

	-- separate mana gem macro toggle (creates AutoManaGem and keeps AutoManaPotion for potions only)
	local separateManaGemMacroButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
	separateManaGemMacroButton:SetPoint("TOPLEFT", skipManaGemOnCooldownButton, "BOTTOMLEFT", -SUB_OPTION_INDENT, -8)
	separateManaGemMacroButton.Text:SetText(L["Separate Mana Gem macro (AutoManaGem)"])
	separateManaGemMacroButton:HookScript("OnClick", function(_, btn, down)
		local checked = separateManaGemMacroButton:GetChecked()
		if not checked and ham.scheduleManaGemMacroDelete then
			ham.scheduleManaGemMacroDelete()
		end
		ham.settingsFrame:updateConfig("separateManaGemMacro", checked)
	end)
	separateManaGemMacroButton:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(separateManaGemMacroButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetText(L["Create a separate AutoManaGem macro for your best mana gem and keep AutoManaPotion for mana potions only."], nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)
	separateManaGemMacroButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	ham.settingsFrame:trackOptionCheckbox(separateManaGemMacroButton, "separateManaGemMacro")

	-- weakest mana potion first toggle (the mana potion priority turned around, for leveling)
	local weakestManaPotionButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
	weakestManaPotionButton:SetPoint("TOPLEFT", separateManaGemMacroButton, "BOTTOMLEFT", 0, -8)
	weakestManaPotionButton.Text:SetText(L["Weakest Mana Potion First"])
	weakestManaPotionButton:HookScript("OnClick", function(_, btn, down)
		ham.settingsFrame:updateConfig("weakestManaPotionFirst", weakestManaPotionButton:GetChecked())
	end)
	weakestManaPotionButton:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(weakestManaPotionButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetText(L["Use your weakest mana potion first and keep the stronger ones for later. Meant for leveling. Any mana potion in your bags counts, whatever its level. The mana gem is still your best one."], nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)
	weakestManaPotionButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	ham.settingsFrame:trackOptionCheckbox(weakestManaPotionButton, "weakestManaPotionFirst")
	local lastCheckbox = weakestManaPotionButton

	-- include demonic runes toggle (the last step, costs health; its flat mana is worthless on Retail)
	if not ham.isRetail then
		local demonicRuneButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
		demonicRuneButton:SetPoint("TOPLEFT", weakestManaPotionButton, "BOTTOMLEFT", 0, -8)
		demonicRuneButton.Text:SetText(L["Include Demonic Runes"])
		demonicRuneButton:HookScript("OnClick", function(_, btn, down)
			ham.settingsFrame:updateConfig("includeDemonicRunes", demonicRuneButton:GetChecked())
		end)
		demonicRuneButton:HookScript("OnEnter", function(_, btn, down)
			GameTooltip:SetOwner(demonicRuneButton, "ANCHOR_TOPRIGHT")
			GameTooltip:SetText(L["Use a Demonic Rune or Dark Rune after the mana potion. It costs you health. It has a cooldown of its own, so the next press uses it."], nil, nil, nil, nil, true)
			GameTooltip:Show()
		end)
		demonicRuneButton:HookScript("OnLeave", function(_, btn, down)
			GameTooltip:Hide()
		end)
		ham.settingsFrame:trackOptionCheckbox(demonicRuneButton, "includeDemonicRunes")
		lastCheckbox = demonicRuneButton
	end

	-- mana potion priority header
	local manaPotionPrioTitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	manaPotionPrioTitle:SetPoint("TOPLEFT", lastCheckbox, "BOTTOMLEFT", 0, -PADDING)
	manaPotionPrioTitle:SetText(L["Mana Potion Priority"])

	self.priorityTitle = manaPotionPrioTitle
	self.priorityRow = ham.newPreviewRow(self.content, manaPotionPrioTitle, 0, -PADDING)
end
