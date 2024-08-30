local addonName, ham = ...
local isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
local isWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
local isCata = (WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC)

---@class Frame
ham.settingsFrame = CreateFrame("Frame")
local ICON_SIZE = 50
local PADDING_CATERGORY = 60
local PADDING = 30
local PADDING_HORIZONTAL = 200
local PADDING_PRIO_CATEGORY = 130
local classButtons = {}
local prioFrames = {}
local prioTextures = {}
local prioFramesCounter = 0
local firstIcon = nil
local positionx = 0
local currentPrioTitle = nil
local lastStaticElement = nil


function ham.settingsFrame:OnEvent(event, addOnName)
	if addOnName == "AutoPotion" then
		if event == "ADDON_LOADED" then
			HAMDB = HAMDB or CopyTable(ham.defaults)
			if HAMDB.activatedSpells == nil then
				print("The Settings of AutoPotion were reset due to breaking changes.")
				HAMDB = CopyTable(ham.defaults)
			end
			self:InitializeOptions()
		end
	end
	if event == "PLAYER_LOGIN" then
		self:InitializeClassSpells(lastStaticElement)
		ham.updateHeals()
		ham.updateMacro()
		self:updatePrio()
	end
end

ham.settingsFrame:RegisterEvent("PLAYER_LOGIN")
ham.settingsFrame:RegisterEvent("ADDON_LOADED")

ham.settingsFrame:SetScript("OnEvent", ham.settingsFrame.OnEvent)

function ham.settingsFrame:createPrioFrame(id, iconTexture, positionx, isSpell)
	local icon = CreateFrame("Frame", nil, self.panel, UIParent)
	icon:SetFrameStrata("MEDIUM")
	icon:SetWidth(ICON_SIZE)
	icon:SetHeight(ICON_SIZE)
	icon:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(icon, "ANCHOR_TOPRIGHT")
		if isSpell == true then
			GameTooltip:SetSpellByID(id)
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
		icon:SetPoint("BOTTOMLEFT", 0, PADDING_PRIO_CATEGORY - PADDING * 2)
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

	if next(ham.spellIDs) ~= nil then
		for i, id in ipairs(ham.spellIDs) do
			local iconTexture, originalIconTexture
			if isRetail == true then
				iconTexture, originalIconTexture = C_Spell.GetSpellTexture(id)
			else
				iconTexture = GetSpellTexture(id)
			end
			local currentFrame = prioFrames[i]
			local currentTexture = prioTextures[i]
			if currentFrame ~= nil then
				currentFrame:SetScript("OnEnter", nil)
				currentFrame:SetScript("OnLeave", nil)
				currentFrame:HookScript("OnEnter", function(_, btn, down)
					GameTooltip:SetOwner(currentFrame, "ANCHOR_TOPRIGHT")
					GameTooltip:SetSpellByID(id)
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
				self:createPrioFrame(id, iconTexture, positionx, true)
				positionx = positionx + (ICON_SIZE + (ICON_SIZE / 2))
			end
			spellCounter = spellCounter + 1
		end
	end
	if next(ham.itemIdList) ~= nil then
		for i, id in ipairs(ham.itemIdList) do
			local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, iconTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent =
				C_Item.GetItemInfo(id)
			local currentFrame = prioFrames[i + spellCounter]
			local currentTexture = prioTextures[i + spellCounter]

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
				self:createPrioFrame(id, iconTexture, positionx, false)
				positionx = positionx + (ICON_SIZE + (ICON_SIZE / 2))
			end
			itemCounter = itemCounter + 1
		end
	end
end

function ham.settingsFrame:InitializeOptions()
	print("init frame")
	self.panel = CreateFrame("Frame", addonName, InterfaceOptionsFramePanelContainer)
	---@diagnostic disable-next-line: inject-field
	self.panel.name = addonName
	if InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(self.panel)
	else
		local category = Settings.RegisterCanvasLayoutCategory(self.panel, addonName);
		Settings.RegisterAddOnCategory(category);
		self.panel.categoryID = category:GetID() -- for OpenToCategory use
	end


	-------------  HEADER  -------------
	local title = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
	title:SetPoint("TOP", 0, -2)
	title:SetText("Auto Potion Settings")

	local subtitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
	subtitle:SetPoint("TOPLEFT", 0, -PADDING)
	subtitle:SetText("Here you can configure the behaviour of the Addon eg. if you want to include class spells")


	-------------  General  -------------
	local behaviourTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
	behaviourTitle:SetPoint("TOPLEFT", subtitle, 0, -PADDING_CATERGORY)
	behaviourTitle:SetText("Addon Behaviour")

	local cdResetButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	cdResetButton:SetPoint("TOPLEFT", behaviourTitle, 0, -PADDING)
	---@diagnostic disable-next-line: undefined-field
	cdResetButton.Text:SetText(
		"Includes the shortest Cooldown in the reset Condition of Castsequence. !!USE CAREFULLY!!")
	cdResetButton:HookScript("OnClick", function(_, btn, down)
		HAMDB.cdReset = cdResetButton:GetChecked()
	end)
	cdResetButton:SetChecked(HAMDB.cdReset)

	lastStaticElement = cdResetButton


	-------------  Healthstone button  -------------	
	local raidStoneButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	raidStoneButton:SetPoint("TOPLEFT", lastStaticElement, 0, -PADDING)
	---@diagnostic disable-next-line: undefined-field
	raidStoneButton.Text:SetText("Low Priority Healthstones(Instance only)")
	raidStoneButton:HookScript("OnClick", function(_, btn, down)
		HAMDB.raidStone = raidStoneButton:GetChecked()
		ham.updateHeals()
		ham.updateMacro()
		self:updatePrio()
	end)
	raidStoneButton:HookScript("OnEnter", function(_, btn, down)
		---@diagnostic disable-next-line: param-type-mismatch
		GameTooltip:SetOwner(raidStoneButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetText(
			"This option will prioritize health potions over a healthstone while in a Instance")
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
	if isRetail then
		local itemsTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
		itemsTitle:SetPoint("TOPLEFT", lastStaticElement, 0, -PADDING_CATERGORY)
		itemsTitle:SetText("Items")

		witheringPotionButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
		witheringPotionButton:SetPoint("TOPLEFT", itemsTitle, 0, -PADDING)
		---@diagnostic disable-next-line: undefined-field
		witheringPotionButton.Text:SetText("Use Potion of Withering Vitality")
		witheringPotionButton:HookScript("OnClick", function(_, btn, down)
			HAMDB.witheringPotion = witheringPotionButton:GetChecked()
			ham.updateHeals()
			ham.updateMacro()
			self:updatePrio()
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


		witheringDreamsPotionButton = CreateFrame("CheckButton", nil, self.panel,
			"InterfaceOptionsCheckButtonTemplate")
		witheringDreamsPotionButton:SetPoint("TOPLEFT", itemsTitle, 300, -PADDING)
		---@diagnostic disable-next-line: undefined-field
		witheringDreamsPotionButton.Text:SetText("Use Potion of Withering Dreams")
		witheringDreamsPotionButton:HookScript("OnClick", function(_, btn, down)
			HAMDB.witheringDreamsPotion = witheringDreamsPotionButton:GetChecked()
			ham.updateHeals()
			ham.updateMacro()
			self:updatePrio()
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

		lastStaticElement = witheringPotionButton ---MAYBE witheringDreamsPotionButton
	end

	local useHealthstonesButton = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
	useHealthstonesButton:SetPoint("TOPLEFT", lastStaticElement, 0, -PADDING)
	---@diagnostic disable-next-line: undefined-field
	useHealthstonesButton.Text:SetText("Include Healthstones")
	useHealthstonesButton:HookScript("OnClick", function(_, btn, down)
		HAMDB.useHealthstones = useHealthstonesButton:GetChecked()
		ham.updateHeals()
		ham.updateMacro()
		self:updatePrio()
	end)
	useHealthstonesButton:SetChecked(HAMDB.useHealthstones)
	lastStaticElement = useHealthstonesButton


	-------------  CURRENT PRIORITY  -------------
	currentPrioTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
	currentPrioTitle:SetPoint("BOTTOMLEFT", 0, PADDING_PRIO_CATEGORY)
	currentPrioTitle:SetText("Current Priority")


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
		raidStoneButton:SetChecked(HAMDB.raidStone)
		if isRetail then
			witheringPotionButton:SetChecked(HAMDB.witheringPotion)
			witheringDreamsPotionButton:SetChecked(HAMDB.witheringDreamsPotion)
		end
		useHealthstonesButton:SetChecked(HAMDB.useHealthstones)
		ham.updateHeals()
		ham.updateMacro()
		self:updatePrio()
		print("Reset successful!")
	end)
end

function ham.settingsFrame:InitializeClassSpells(relativeTo)
	-------------  CLASS / RACIALS  -------------
	local myClassTitle = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
	myClassTitle:SetPoint("TOPLEFT", relativeTo, 0, -PADDING_CATERGORY)
	myClassTitle:SetText("Class/Racial Spells")

	local lastbutton = nil
	local posy = -PADDING
	if next(ham.supportedSpells) ~= nil then
		local count = 0
		for i, spell in ipairs(ham.supportedSpells) do
			if IsSpellKnown(spell) then
				local name = C_Spell.GetSpellName(spell)
				local button = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")

				if count == 3 then
					lastbutton = nil
					count = 0
					posy = posy - PADDING
				end
				if lastbutton ~= nil then
					button:SetPoint("TOPLEFT", lastbutton, PADDING_HORIZONTAL, 0)
				else
					button:SetPoint("TOPLEFT", myClassTitle, 0, posy)
				end
				---@diagnostic disable-next-line: undefined-field
				button.Text:SetText("Use " .. name)
				button:HookScript("OnClick", function(_, btn, down)
					if button:GetChecked() then
						ham.insertIntoDB(spell)
					else
						ham.removeFromDB(spell)
					end
					ham.updateHeals()
					ham.updateMacro()
					self:updatePrio()
				end)
				button:HookScript("OnEnter", function(_, btn, down)
					---@diagnostic disable-next-line: param-type-mismatch
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
			end
		end
	end
end

SLASH_HAM1 = "/ham"
SLASH_HAM2 = "/healtsthoneautomacro"
SLASH_HAM3 = "/ap"
SLASH_HAM4 = "/autopotion"

SlashCmdList.HAM = function(msg, editBox)
	if InterfaceOptions_AddCategory then
		InterfaceOptionsFrame_OpenToCategory(addonName)
	else
		local settingsCategoryID = _G[addonName].categoryID
		Settings.OpenToCategory(settingsCategoryID)
	end
end
