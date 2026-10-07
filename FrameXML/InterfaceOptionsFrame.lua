---@diagnostic disable: undefined-global
local L = LibStub("AceLocale-3.0"):GetLocale("AutoPotion")
local addonName, ham = ...

---@class Frame
ham.settingsFrame = CreateFrame("Frame")
local ICON_SIZE = 50
local PADDING_CATERGORY = 45
local PADDING = 25
local PADDING_HORIZONTAL = 300 -- column width; two columns leave room for an icon next to each name
local COLUMNS = 2
-- spell/item checkboxes show the icon between the box and the name, like the spellbook
local ROW_ICON_SIZE = 28
local ROW_ICON_GAP = 6
local ROW_HEIGHT = 34
local FIRST_ROW_OFFSET = 30 -- from a section title down to its first row of icon checkboxes
local QUESTION_MARK_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
-- the Heartseeking Health Injector's use effect, the same id ham.checkTinker matches
local HEARTSEEKING_SPELL_ID = 452767
local classButtons = {}
local prioFrames = {}
local prioTextures = {}
local prioFramesCounter = 0
local firstIcon = nil
local positionx = 0
local currentPrioTitle = nil
local lastStaticElement = nil

-- The "Current Priority" title + icon row and the Reset button live in a fixed-height
-- footer anchored to the panel itself (not the scrollable content), so they stay visible
-- no matter how far the settings above have been scrolled.
local FOOTER_TOP_PADDING = 12
local FOOTER_TITLE_HEIGHT = 24
local FOOTER_ICON_GAP = PADDING -- gap between the title and the icon row below it
local FOOTER_BUTTON_GAP = 16
local FOOTER_BUTTON_HEIGHT = 22
local FOOTER_BOTTOM_PADDING = 16
local FOOTER_HEIGHT = FOOTER_TOP_PADDING + FOOTER_TITLE_HEIGHT + FOOTER_ICON_GAP + ICON_SIZE +
	FOOTER_BUTTON_GAP + FOOTER_BUTTON_HEIGHT + FOOTER_BOTTOM_PADDING

local CLASS_ORDER = {
	"WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "DEATHKNIGHT",
	"SHAMAN", "MAGE", "WARLOCK", "MONK", "DRUID", "EVOKER",
}

local function getSpellIcon(spellId)
	-- Feature-detect C_Spell rather than branching on ham.isRetail: Forever runs the
	-- Mainline client engine (C_Spell.*, no GetSpellTexture global) despite ham.isRetail
	-- being false for it. See Core/Spell.lua for the same pattern.
	if C_Spell and C_Spell.GetSpellTexture then
		return C_Spell.GetSpellTexture(spellId)
	end
	return GetSpellTexture(spellId)
end

-- Spellbook-style checkbox: the box, then the spell/item icon, then its name. Clicking the
-- icon or the name toggles the box too, just like the template's own label.
local function createIconCheckButton(parent, iconTexture, label)
	local button = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")

	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetSize(ROW_ICON_SIZE, ROW_ICON_SIZE)
	icon:SetPoint("LEFT", button, "RIGHT", ROW_ICON_GAP, 0)
	icon:SetTexture(iconTexture or QUESTION_MARK_ICON)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- crop the border baked into every icon

	local border = button:CreateTexture(nil, "BACKGROUND")
	border:SetColorTexture(0, 0, 0, 0.8)
	border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
	border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)

	---@diagnostic disable-next-line: undefined-field
	local text = button.Text
	text:ClearAllPoints()
	text:SetPoint("LEFT", icon, "RIGHT", ROW_ICON_GAP, 0)
	text:SetText(label)
	button:SetHitRectInsets(0, -(ROW_ICON_GAP * 2 + ROW_ICON_SIZE + text:GetStringWidth()), 0, 0)

	return button
end

function ham.settingsFrame:updateConfig(option, value)
	if ham.options[option] ~= nil then
		ham.options[option] = value -- Update in-memory
		HAMDB[option] = value -- Persist to DB
	else
		print(L["Invalid option: "] .. tostring(option))
	end
	-- Rebuild the macro and update priority frame
	ham.checkTinker()
	ham.updateHeals()
	ham.updateMacro()
	self:updatePrio()
	ham.bandageSettingsFrame:updateBandagePrio()
	ham.updateFoodMacro()
	ham.foodSettingsFrame:updateFoodPrio()
	ham.updateDrinkMacro()
	ham.drinkSettingsFrame:updateDrinkPrio()
	ham.updateManaPotionMacro()
	ham.manaPotionSettingsFrame:updateManaPotionPrio()
end

function ham.settingsFrame:OnEvent(event, addOnName)
	if addOnName == "AutoPotion" then
		if event == "ADDON_LOADED" then
			HAMDB = HAMDB or CopyTable(ham.defaults)
			if HAMDB.activatedSpells == nil then
				print(L["The Settings of AutoPotion were reset due to breaking changes."])
				HAMDB = CopyTable(ham.defaults)
			end
			-- the settings list shows the pages in this order
			ham.infoSettingsFrame:InitializeOptions()
			self:InitializeOptions()
			ham.manaPotionSettingsFrame:InitializeOptions()
			ham.foodSettingsFrame:InitializeOptions()
			ham.drinkSettingsFrame:InitializeOptions()
			ham.bandageSettingsFrame:InitializeOptions()
		end
	end
	if event == "PLAYER_LOGIN" then
		self:InitializeClassSpells(lastStaticElement)
		ham.updateHeals()
		ham.updateMacro()
		self:updatePrio()
		ham.bandageSettingsFrame:updateBandagePrio()
		ham.updateFoodMacro()
		ham.foodSettingsFrame:updateFoodPrio()
		ham.updateDrinkMacro()
		ham.drinkSettingsFrame:updateDrinkPrio()
		ham.updateManaPotionMacro()
		ham.manaPotionSettingsFrame:updateManaPotionPrio()
	end
end

ham.settingsFrame:RegisterEvent("PLAYER_LOGIN")
ham.settingsFrame:RegisterEvent("ADDON_LOADED")
ham.settingsFrame:SetScript("OnEvent", ham.settingsFrame.OnEvent)

-- Resize the scrollable content to fit whatever was last laid out inside it (class
-- spell groups and the priority icon row can all change the content's extent).
function ham.settingsFrame:recalculateContentHeight()
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

	for _, button in pairs(classButtons) do considerBottom(button) end

	if lowest ~= nil then
		self.content:SetHeight((contentTop - lowest) + PADDING)
	end
end

function ham.settingsFrame:createPrioFrame(id, iconTexture, positionx, isSpell, isTinker)
	local icon = CreateFrame("Frame", nil, self.priorityFooter, UIParent)
	icon:SetFrameStrata("MEDIUM")
	icon:SetWidth(ICON_SIZE)
	icon:SetHeight(ICON_SIZE)
	icon:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(icon, "ANCHOR_TOPRIGHT")
		if isSpell == true then
			GameTooltip:SetSpellByID(id)
		elseif isTinker then
			GameTooltip:SetInventoryItem("player", id)
		else
			GameTooltip:SetItemByID(id)
		end
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

	if firstIcon == nil then
		icon:SetPoint("TOPLEFT", currentPrioTitle, 0, -PADDING)
		firstIcon = icon
	else
		icon:SetPoint("TOPLEFT", firstIcon, positionx, 0)
	end
	icon:Show()
	table.insert(prioFrames, icon)
	table.insert(prioTextures, texture)
	prioFramesCounter = prioFramesCounter + 1
	return icon
end

function ham.settingsFrame:updatePrio()
	local spellCounter = 0
	local itemCounter = 0

	for i, frame in pairs(prioFrames) do
		frame:Hide()
	end

	-- Add spells to priority frames (skip Recuperate in instanced PvP - not allowed)
	if next(ham.mySpells) ~= nil then
		for i, spell in ipairs(ham.mySpells) do
			if spell.getId() == ham.recuperate.getId() and ham.isInInstancedPvP and ham.isInInstancedPvP() then
				-- Recuperate not shown in instanced PvP
			else
				local iconTexture = getSpellIcon(spell.getId())
				spellCounter = spellCounter + 1
				local currentFrame = prioFrames[spellCounter]
				local currentTexture = prioTextures[spellCounter]
				if currentFrame ~= nil then
					currentFrame:SetScript("OnEnter", nil)
					currentFrame:SetScript("OnLeave", nil)
					currentFrame:HookScript("OnEnter", function(_, btn, down)
						GameTooltip:SetOwner(currentFrame, "ANCHOR_TOPRIGHT")
						GameTooltip:SetSpellByID(spell.getId())
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
					local positionx = (spellCounter - 1) * (ICON_SIZE + (ICON_SIZE / 2))
					self:createPrioFrame(spell.getId(), iconTexture, positionx, true, false)
				end
			end
		end
	end

	-- Add items to priority frames
	if next(ham.itemIdList) ~= nil then
		for i, id in ipairs(ham.itemIdList) do
			local entry
			local iconTexture
			local isTinker = false

			-- if the entry is a gear slot (ie: tinker)
			if type(id) == "string" and id:match("^slot:") then
				local slot = assert(tonumber(id:sub(6)), "Invalid slot number")
				entry = GetInventoryItemID("player", slot)
				iconTexture = GetInventoryItemTexture("player", slot)
				isTinker = true
				-- otherwise its a normal item id
			else
				local _, _, _, _, _, _, _, _, _, tmpTexture = C_Item.GetItemInfo(id)
				entry = id
				iconTexture = tmpTexture
			end

			local currentFrame = prioFrames[i + spellCounter]
			local currentTexture = prioTextures[i + spellCounter]

			if currentFrame ~= nil then
				currentFrame:SetScript("OnEnter", nil)
				currentFrame:SetScript("OnLeave", nil)
				currentFrame:HookScript("OnEnter", function(_, btn, down)
					GameTooltip:SetOwner(currentFrame, "ANCHOR_TOPRIGHT")
					if isTinker then
						GameTooltip:SetInventoryItem("player", ham.tinkerSlot)
					else
						GameTooltip:SetItemByID(id)
					end
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
				self:createPrioFrame(entry, iconTexture, positionx, false, isTinker)
				positionx = positionx + (ICON_SIZE + (ICON_SIZE / 2))
			end
			itemCounter = itemCounter + 1
		end
	end
end

function ham.settingsFrame:InitializeOptions()
	-- Create the healing panel inside the Interface Options container
	self.panel = CreateFrame("Frame", addonName .. "Heal", InterfaceOptionsFramePanelContainer)
	self.panel.name = L["AutoPotion"]

	-- Register as a page below the AutoPotion root (the Information page)
	ham.infoSettingsFrame:addSubcategory(self.panel)

	-- Refresh priority preview when panel is shown (e.g. when opening settings in BG/Arena)
	self.panel:SetScript("OnShow", function()
		ham.checkTinker()
		ham.updateHeals()
		ham.updateMacro()
		ham.settingsFrame:updatePrio()
		ham.settingsFrame:recalculateContentHeight()
	end)

	-------------  FIXED FOOTER (Current Priority + Reset button)  -------------
	-- Anchored to the panel itself (not the scrollable content) so both stay visible
	-- no matter how far the settings above have been scrolled.
	self.priorityFooter = CreateFrame("Frame", nil, self.panel)
	self.priorityFooter:SetPoint("BOTTOMLEFT", self.panel, "BOTTOMLEFT", 0, 0)
	self.priorityFooter:SetPoint("BOTTOMRIGHT", self.panel, "BOTTOMRIGHT", 0, 0)
	self.priorityFooter:SetHeight(FOOTER_HEIGHT)

	currentPrioTitle = self.priorityFooter:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	currentPrioTitle:SetPoint("TOPLEFT", self.priorityFooter, "TOPLEFT", 16, -FOOTER_TOP_PADDING)
	currentPrioTitle:SetText(L["Current Priority"])

	local btn = CreateFrame("Button", nil, self.priorityFooter, "UIPanelButtonTemplate")
	btn:SetPoint("BOTTOMLEFT", self.priorityFooter, "BOTTOMLEFT", 17, FOOTER_BOTTOM_PADDING)
	btn:SetText(L["Reset to Default"])
	-- Size to the localized text instead of a fixed width, so longer translations
	-- (e.g. German "Auf Standard zurücksetzen") don't clip past the button's edges.
	local BUTTON_TEXT_PADDING = 20
	local MIN_BUTTON_WIDTH = 120
	btn:SetWidth(math.max(MIN_BUTTON_WIDTH, btn:GetFontString():GetStringWidth() + BUTTON_TEXT_PADDING))

	-- scrollable area so the panel stays usable once it has more rows than fit on screen
	self.scrollFrame = CreateFrame("ScrollFrame", addonName .. "ScrollFrame", self.panel, "UIPanelScrollFrameTemplate")
	self.scrollFrame:SetPoint("TOPLEFT", self.panel, "TOPLEFT", 16, -16)
	self.scrollFrame:SetPoint("BOTTOMRIGHT", self.panel, "BOTTOMRIGHT", -28, FOOTER_HEIGHT)
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
	title:SetText(L["Auto Potion Settings"])

	-- subtitle
	local subtitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	subtitle:SetPoint("TOPLEFT", 0, -40)
	subtitle:SetText(L["Configure the behavior of the addon. IE: if you want to include class spells"])

	-- behavior title
	local behaviourTitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	behaviourTitle:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -PADDING)
	behaviourTitle:SetText(L["Addon Behaviour"])

	-------------  Stop Casting  -------------	
	local stopCastButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
	stopCastButton:SetPoint("TOPLEFT", behaviourTitle, 0, -PADDING)
	---@diagnostic disable-next-line: undefined-field
	stopCastButton.Text:SetText(L["Include /stopcasting in the macro"])
	stopCastButton:HookScript("OnClick", function(_, btn, down)
		ham.settingsFrame:updateConfig("stopCast", stopCastButton:GetChecked())
	end)
	stopCastButton:HookScript("OnEnter", function(_, btn, down)
		---@diagnostic disable-next-line: param-type-mismatch
		GameTooltip:SetOwner(stopCastButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetText(L["Useful for casters."])
		GameTooltip:Show()
	end)
	stopCastButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	stopCastButton:SetChecked(HAMDB.stopCast)
	lastStaticElement = stopCastButton

	-------------  Shortest Cooldown  -------------	
	local cdResetButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
	cdResetButton:SetPoint("TOPLEFT", lastStaticElement, 0, -PADDING)
	---@diagnostic disable-next-line: undefined-field
	cdResetButton.Text:SetText(L
		["Includes the shortest Cooldown in the reset Condition of Castsequence. !!USE CAREFULLY!!"])
	cdResetButton:HookScript("OnClick", function(_, btn, down)
		ham.settingsFrame:updateConfig("cdReset", cdResetButton:GetChecked())
	end)
	cdResetButton:SetChecked(HAMDB.cdReset)
	lastStaticElement = cdResetButton

	-------------  Healthstone Priority  -------------	
	local raidStoneButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
	raidStoneButton:SetPoint("TOPLEFT", lastStaticElement, 0, -PADDING)
	---@diagnostic disable-next-line: undefined-field
	raidStoneButton.Text:SetText(L["Low Priority Healthstones"])
	raidStoneButton:HookScript("OnClick", function(_, btn, down)
		ham.settingsFrame:updateConfig("raidStone", raidStoneButton:GetChecked())
	end)
	raidStoneButton:HookScript("OnEnter", function(_, btn, down)
		---@diagnostic disable-next-line: param-type-mismatch
		GameTooltip:SetOwner(raidStoneButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetText(L["Prioritize health potions over a healthstone."])
		GameTooltip:Show()
	end)
	raidStoneButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	raidStoneButton:SetChecked(HAMDB.raidStone)
	lastStaticElement = raidStoneButton


	-------------  ITEMS  -------------
	local witheringPotionButton = nil
	local witheringDreamsPotionButton = nil
	local cavedwellerDelightButton = nil
	local heartseekingButton = nil
	local soulburnButton = nil
	if ham.isRetail then
		local itemsTitle = self.content:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
		itemsTitle:SetPoint("TOPLEFT", lastStaticElement, 0, -PADDING_CATERGORY)
		itemsTitle:SetText(L["Items"])

		-- offset of a cell in the two-column grid below the title
		local function itemPosition(column, row)
			return column * PADDING_HORIZONTAL, -FIRST_ROW_OFFSET - row * ROW_HEIGHT
		end

		---Withering Potion---
		witheringPotionButton = createIconCheckButton(self.content, C_Item.GetItemIconByID(ham.witheringR3.getId()),
			L["Potion of Withering Vitality"])
		witheringPotionButton:SetPoint("TOPLEFT", itemsTitle, itemPosition(0, 0))
		witheringPotionButton:HookScript("OnClick", function(_, btn, down)
			ham.settingsFrame:updateConfig("witheringPotion", witheringPotionButton:GetChecked())
		end)
		witheringPotionButton:HookScript("OnEnter", function(_, btn, down)
			---@diagnostic disable-next-line: param-type-mismatch
			GameTooltip:SetOwner(witheringPotionButton, "ANCHOR_TOPRIGHT")
			GameTooltip:SetItemByID(ham.witheringR3.getId())
			GameTooltip:Show()
		end)
		witheringPotionButton:HookScript("OnLeave", function(_, btn, down)
			GameTooltip:Hide()
		end)
		witheringPotionButton:SetChecked(HAMDB.witheringPotion)

		---Withering Dreams Potion---
		witheringDreamsPotionButton = createIconCheckButton(self.content,
			C_Item.GetItemIconByID(ham.witheringDreamsR3.getId()), L["Potion of Withering Dreams"])
		witheringDreamsPotionButton:SetPoint("TOPLEFT", itemsTitle, itemPosition(1, 0))
		witheringDreamsPotionButton:HookScript("OnClick", function(_, btn, down)
			ham.settingsFrame:updateConfig("witheringDreamsPotion", witheringDreamsPotionButton:GetChecked())
		end)
		witheringDreamsPotionButton:HookScript("OnEnter", function(_, btn, down)
			---@diagnostic disable-next-line: param-type-mismatch
			GameTooltip:SetOwner(witheringDreamsPotionButton, "ANCHOR_TOPRIGHT")
			GameTooltip:SetItemByID(ham.witheringDreamsR3.getId())
			GameTooltip:Show()
		end)
		witheringDreamsPotionButton:HookScript("OnLeave", function(_, btn, down)
			GameTooltip:Hide()
		end)
		witheringDreamsPotionButton:SetChecked(HAMDB.witheringDreamsPotion)

		---Refreshing Serum buttons could be renamed---
		cavedwellerDelightButton = createIconCheckButton(self.content,
			C_Item.GetItemIconByID(ham.refreshingSerumR2.getId()), L["Refreshing Serum"])
		cavedwellerDelightButton:SetPoint("TOPLEFT", itemsTitle, itemPosition(0, 1))
		cavedwellerDelightButton:HookScript("OnClick", function(_, btn, down)
			ham.settingsFrame:updateConfig("cavedwellerDelight", cavedwellerDelightButton:GetChecked())
		end)
		cavedwellerDelightButton:HookScript("OnEnter", function(_, btn, down)
			---@diagnostic disable-next-line: param-type-mismatch
			GameTooltip:SetOwner(cavedwellerDelightButton, "ANCHOR_TOPRIGHT")
			GameTooltip:SetItemByID(ham.refreshingSerumR2.getId())
			GameTooltip:Show()
		end)
		cavedwellerDelightButton:HookScript("OnLeave", function(_, btn, down)
			GameTooltip:Hide()
		end)
		cavedwellerDelightButton:SetChecked(HAMDB.cavedwellerDelight)

		---Heartseeking Health Injector---
		-- right column: its (German) name is too long for the left one
		heartseekingButton = createIconCheckButton(self.content, getSpellIcon(HEARTSEEKING_SPELL_ID),
			L["Heartseeking Health Injector (tinker)"])
		heartseekingButton:SetPoint("TOPLEFT", itemsTitle, itemPosition(1, 1))
		heartseekingButton:HookScript("OnClick", function(_, btn, down)
			ham.settingsFrame:updateConfig("heartseekingInjector", heartseekingButton:GetChecked())
		end)
		heartseekingButton:HookScript("OnEnter", function(_, btn, down)
			---@diagnostic disable-next-line: param-type-mismatch
			if ham.tinkerSlot then
				GameTooltip:SetOwner(heartseekingButton, "ANCHOR_TOPRIGHT")
				GameTooltip:SetInventoryItem("player", ham.tinkerSlot)
				GameTooltip:Show()
			end
		end)
		heartseekingButton:HookScript("OnLeave", function(_, btn, down)
			GameTooltip:Hide()
		end)
		heartseekingButton:SetChecked(HAMDB.heartseekingInjector)

		---Soulburn (Warlock only)---
		if ham.myPlayer.englishClass == "WARLOCK" then
			soulburnButton = createIconCheckButton(self.content, getSpellIcon(ham.soulburn.getId()),
				L["Soulburn Healthstone"])
			soulburnButton:SetPoint("TOPLEFT", itemsTitle, itemPosition(0, 2))
			soulburnButton:HookScript("OnClick", function(_, btn, down)
				ham.settingsFrame:updateConfig("soulburn", soulburnButton:GetChecked())
			end)
			soulburnButton:HookScript("OnEnter", function(_, btn, down)
				---@diagnostic disable-next-line: param-type-mismatch
				GameTooltip:SetOwner(soulburnButton, "ANCHOR_TOPRIGHT")
				GameTooltip:SetSpellByID(ham.soulburn.getId())
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(
					L["Casts Soulburn right before the macro in combat to empower your Healthstone. Costs a Soul Shard every time Soulburn is off cooldown, also on presses that use a potion or spell."],
					1, 1, 1, true)
				GameTooltip:Show()
			end)
			soulburnButton:HookScript("OnLeave", function(_, btn, down)
				GameTooltip:Hide()
			end)
			soulburnButton:SetChecked(HAMDB.soulburn)
		end

		-- first button of the last row
		lastStaticElement = soulburnButton or cavedwellerDelightButton
	end

	-- Class/racial spell groups are created dynamically in InitializeClassSpells, since
	-- class headers depend on which classes actually have spells and that section's
	-- height varies with how many show up.

	-------------  RESET BUTTON  -------------
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
		raidStoneButton:SetChecked(HAMDB.raidStone)
		if ham.isRetail then
			---@diagnostic disable-next-line: need-check-nil
			witheringPotionButton:SetChecked(HAMDB.witheringPotion)
			---@diagnostic disable-next-line: need-check-nil
			witheringDreamsPotionButton:SetChecked(HAMDB.witheringDreamsPotion)
			---@diagnostic disable-next-line: need-check-nil
			cavedwellerDelightButton:SetChecked(HAMDB.cavedwellerDelight)
		end
		-- ham.options is only read once, so clear Soulburn in memory too or the macro keeps it until /reload
		ham.options.soulburn = HAMDB.soulburn
		if soulburnButton then
			soulburnButton:SetChecked(HAMDB.soulburn)
		end
		ham.updateHeals()
		ham.updateMacro()
		self:updatePrio()
		ham.bandageSettingsFrame:updateBandagePrio()
		print(L["Reset successful!"])
	end)
end

-- Create one class/racial-spell checkbox, anchored (offsetX, offsetY) from `relativeTo`.
-- `spell` is either a plain ham.Spell (single db entry) or a ham.SpellGroup (toggles
-- every member together as one unit - see Core/SpellGroup.lua).
local function createSpellButton(parent, relativeTo, offsetX, offsetY, spell)
	local button = createIconCheckButton(parent, getSpellIcon(spell.getId()), spell.getName())
	button:SetPoint("TOPLEFT", relativeTo, offsetX, offsetY)
	button:HookScript("OnClick", function(_, btn, down)
		if spell.isGroup then
			if button:GetChecked() then
				spell.activate()
			else
				spell.deactivate()
			end
		else
			if button:GetChecked() then
				ham.insertIntoDB(spell.getId())
			else
				ham.removeFromDB(spell.getId())
			end
		end
		ham.updateHeals()
		ham.updateMacro()
		ham.settingsFrame:updatePrio()
	end)
	button:HookScript("OnEnter", function(_, btn, down)
		---@diagnostic disable-next-line: param-type-mismatch
		GameTooltip:SetOwner(button, "ANCHOR_TOPRIGHT")
		GameTooltip:SetSpellByID(spell.getId())
		GameTooltip:Show()
	end)
	button:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	if spell.isGroup then
		button:SetChecked(spell.isActive())
	else
		button:SetChecked(ham.dbContains(spell.getId()))
	end
	classButtons[spell.getId()] = button
	return button
end

-- Shows every spell available for the current flavor (not just ones the character
-- currently knows), grouped under a header per class. A class with no spells in
-- ham.supportedSpells gets no header at all; spells not tied to a class (racials
-- shared across classes, non-class effects) are grouped under "Other / Racial".
function ham.settingsFrame:InitializeClassSpells(relativeTo)
	local buckets = {}
	local otherBucket = {}
	for _, spell in ipairs(ham.supportedSpells) do
		local class = spell.getClass()
		if class then
			buckets[class] = buckets[class] or {}
			table.insert(buckets[class], spell)
		else
			table.insert(otherBucket, spell)
		end
	end

	local lastAnchor = relativeTo

	local function layoutGroup(headerText, spells)
		if #spells == 0 then return end

		local header = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
		header:SetPoint("TOPLEFT", lastAnchor, 0, -PADDING_CATERGORY)
		header:SetText(headerText)

		local rowStart = nil
		local lastButton = nil
		local posy = -FIRST_ROW_OFFSET
		local count = 0
		for _, spell in ipairs(spells) do
			if count == COLUMNS then
				lastButton = nil
				count = 0
				posy = posy - ROW_HEIGHT
			end
			local button
			if lastButton ~= nil then
				button = createSpellButton(self.content, lastButton, PADDING_HORIZONTAL, 0, spell)
			else
				button = createSpellButton(self.content, header, 0, posy, spell)
				rowStart = button
			end
			lastButton = button
			count = count + 1
		end

		lastAnchor = rowStart
	end

	for _, classToken in ipairs(CLASS_ORDER) do
		local className = LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[classToken] or classToken
		layoutGroup(className, buckets[classToken] or {})
	end
	layoutGroup(L["Other / Racial"], otherBucket)

	self:recalculateContentHeight()
end

SLASH_HAM1 = "/ham"
SLASH_HAM2 = "/healtsthoneautomacro"
SLASH_HAM3 = "/ap"
SLASH_HAM4 = "/autopotion"

SlashCmdList.HAM = function(msg, editBox)
	-- Check if the message contains "debug"
	if msg and msg:trim():lower() == "debug" then
		ham.debug = not ham.debug
		ham.checkTinker()
		print("|cffb48ef9AutoPotion:|r Debug mode is now " .. (ham.debug and "enabled" or "disabled"))
		return
	end

	-- Open settings (on the Information page) if no "debug" keyword was passed
	ham.infoSettingsFrame:open()
end
