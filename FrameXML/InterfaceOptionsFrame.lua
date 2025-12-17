---@diagnostic disable: undefined-global
local L = LibStub("AceLocale-3.0"):GetLocale("AutoPotion")
local addonName, ham = ...
local env = ham.env

---@class Frame
ham.settingsFrame = CreateFrame("Frame")
local ICON_SIZE = 50
local PADDING_CATERGORY = 45
local PADDING = 25
local PADDING_HORIZONTAL = 220
local classButtons = {}
local prioFrames = {}
local prioTextures = {}
local prioFramesCounter = 0
local firstIcon = nil
local positionx = 0
local currentPrioTitle = nil
local myClassTitle = nil
local lastStaticElement = nil

-- Bandage priority UI state
local bandageFrames = {}
local bandageTextures = {}
local bandageFirstIcon = nil
local bandagePositionX = 0
local bandagePrioTitle = nil

-- Keep references to generated option checkboxes
local optionButtons = {}

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
	self:updateBandagePrio()
end

function ham.settingsFrame:OnEvent(event, addOnName)
    if addOnName == "AutoPotion" then
        if event == ham.EVT_ADDON_LOADED then
			HAMDB = HAMDB or CopyTable(ham.defaults)
            ham.refreshOptions()
			if HAMDB.activatedSpells == nil then
				print(L["The Settings of AutoPotion were reset due to breaking changes."])
				HAMDB = CopyTable(ham.defaults)
                ham.refreshOptions()
			end
			self:InitializeOptions()
		end
	end
    if event == ham.EVT_PLAYER_LOGIN then
		self:InitializeClassSpells(myClassTitle)
		ham.updateHeals()
		ham.updateMacro()
		self:updatePrio()
		self:updateBandagePrio()
	end
end

ham.settingsFrame:RegisterEvent(ham.EVT_PLAYER_LOGIN)
ham.settingsFrame:RegisterEvent(ham.EVT_ADDON_LOADED)
ham.settingsFrame:SetScript("OnEvent", ham.settingsFrame.OnEvent)

function ham.settingsFrame:createPrioFrame(id, iconTexture, positionx, isSpell, isTinker)
    if not self or not self.content or not currentPrioTitle then return nil end
    local icon = CreateFrame("Frame", nil, self.content)
	icon:SetFrameStrata("MEDIUM")
	icon:SetWidth(ICON_SIZE)
	icon:SetHeight(ICON_SIZE)
    if isSpell == true then
        ham.ui.attachSpellTooltip(icon, id)
    elseif isTinker then
        ham.ui.attachInventoryTooltip(icon, id)
    else
        ham.ui.attachItemTooltip(icon, id)
    end
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

-- Create a bandage priority icon frame
function ham.settingsFrame:createBandagePrioFrame(id, iconTexture, positionx)
    if not self or not self.content or not bandagePrioTitle then return nil end
    local icon = CreateFrame("Frame", nil, self.content)
	icon:SetFrameStrata("MEDIUM")
	icon:SetWidth(ICON_SIZE)
	icon:SetHeight(ICON_SIZE)
    ham.ui.attachItemTooltip(icon, id)
	local texture = icon:CreateTexture(nil, "BACKGROUND")
	texture:SetTexture(iconTexture)
	texture:SetAllPoints(icon)
	---@diagnostic disable-next-line: inject-field
	icon.texture = texture

	if bandageFirstIcon == nil then
		icon:SetPoint("TOPLEFT", bandagePrioTitle, 0, -PADDING)
		bandageFirstIcon = icon
	else
		icon:SetPoint("TOPLEFT", bandageFirstIcon, positionx, 0)
	end
    icon:Show()
	table.insert(bandageFrames, icon)
	table.insert(bandageTextures, texture)
	return icon
end

function ham.settingsFrame:updatePrio()
    if not self or not self.content or not currentPrioTitle then return end
	local spellCounter = 0
	local itemCounter = 0

	for i, frame in pairs(prioFrames) do
		frame:Hide()
	end

	-- Add spells to priority frames
	if next(ham.spellIDs) ~= nil then
		for i, id in ipairs(ham.spellIDs) do
            local iconTexture = ham.getSpellTexture and ham.getSpellTexture(id) or GetSpellTexture(id)
			local currentFrame = prioFrames[i]
			local currentTexture = prioTextures[i]
			if currentFrame ~= nil then
                currentFrame:SetScript("OnEnter", nil)
                currentFrame:SetScript("OnLeave", nil)
                ham.ui.attachSpellTooltip(currentFrame, id)
				currentTexture:SetTexture(iconTexture)
				currentTexture:SetAllPoints(currentFrame)
				currentFrame.texture = currentTexture
				currentFrame:Show()
			else
				self:createPrioFrame(id, iconTexture, positionx, true, false)
				positionx = positionx + (ICON_SIZE + (ICON_SIZE / 2))
			end
			spellCounter = spellCounter + 1
		end
	end

	-- Add items to priority frames
	if next(ham.itemIdList) ~= nil then
		for i, id in ipairs(ham.itemIdList) do
			local entry
			local iconTexture
			local isTinker = false

			-- if the entry is a gear slot (ie: tinker)
            if type(id) == "string" and id:match("^" .. ham.SLOT_PREFIX) then
                local slot = assert(tonumber(id:sub(#ham.SLOT_PREFIX + 1)), "Invalid slot number")
				entry = GetInventoryItemID("player", slot)
				iconTexture = GetInventoryItemTexture("player", slot)
				isTinker = true
				-- otherwise its a normal item id
            else
                entry = id
                iconTexture = ham.getItemIcon and ham.getItemIcon(id)
			end

			local currentFrame = prioFrames[i + spellCounter]
			local currentTexture = prioTextures[i + spellCounter]

			if currentFrame ~= nil then
                currentFrame:SetScript("OnEnter", nil)
                currentFrame:SetScript("OnLeave", nil)
                if isTinker then
                    ham.ui.attachInventoryTooltip(currentFrame, ham.tinkerSlot)
                else
                    ham.ui.attachItemTooltip(currentFrame, id)
                end
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

-- Update the Bandage Priority section
function ham.settingsFrame:updateBandagePrio()
    if not self or not self.content or not bandagePrioTitle then return end
	-- hide existing
	for _, frame in pairs(bandageFrames) do
		frame:Hide()
	end

	bandagePositionX = 0

	-- Build the prioritized bandage list for the current context
	if ham.getBandages then
		local bandages = ham.getBandages()
		local shown = 0
		for _, item in ipairs(bandages) do
			if item.getCount and item.getCount() > 0 then
                local id = item.getId()
                local iconTexture = ham.getItemIcon and ham.getItemIcon(id)
				local idx = shown + 1
				local currentFrame = bandageFrames[idx]
				local currentTexture = bandageTextures[idx]
				if currentFrame ~= nil then
                currentFrame:SetScript("OnEnter", nil)
                currentFrame:SetScript("OnLeave", nil)
                ham.ui.attachItemTooltip(currentFrame, id)
					currentTexture:SetTexture(iconTexture)
					currentTexture:SetAllPoints(currentFrame)
					currentFrame.texture = currentTexture
					currentFrame:Show()
				else
					self:createBandagePrioFrame(id, iconTexture, bandagePositionX)
					bandagePositionX = bandagePositionX + (ICON_SIZE + (ICON_SIZE / 2))
				end
				shown = shown + 1
			end
		end
	end
end

function ham.settingsFrame:InitializeOptions()
	-- Create the main panel inside the Interface Options container
	self.panel = CreateFrame("Frame", addonName, InterfaceOptionsFramePanelContainer)
	self.panel.name = addonName

	-- Register with Interface Options
	if InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(self.panel)
	else
		local category = Settings.RegisterCanvasLayoutCategory(self.panel, addonName)
		Settings.RegisterAddOnCategory(category)
		self.panel.categoryID = category:GetID() -- for OpenToCategory use
	end

	-- inset frame to provide some padding
	self.content = CreateFrame("Frame", nil, self.panel)
	self.content:SetPoint("TOPLEFT", self.panel, "TOPLEFT", 16, -16)
	self.content:SetPoint("BOTTOMRIGHT", self.panel, "BOTTOMRIGHT", -16, 16)

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

    -- Helper to create a checkbox based on a schema spec
    local function createOption(spec, anchorTo)
        local btn = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
        -- Position: either relative to given anchor or using grid (row/col) under the provided anchor
        if spec.anchor == "grid" and anchorTo then
            local x = (spec.col or 0) * PADDING_HORIZONTAL
            local y = - (spec.row or 1) * PADDING
            btn:SetPoint("TOPLEFT", anchorTo, x, y)
        else
            btn:SetPoint("TOPLEFT", anchorTo or behaviourTitle, spec.offsetX or 0, - (spec.offsetY or PADDING))
        end
        ---@diagnostic disable-next-line: undefined-field
        btn.Text:SetText(spec.label)
        btn:HookScript("OnClick", function()
            ham.settingsFrame:updateConfig(spec.key, btn:GetChecked())
        end)
        if spec.onEnter then
            btn:HookScript("OnEnter", function() spec.onEnter(btn) end)
            btn:HookScript("OnLeave", function() GameTooltip:Hide() end)
        elseif spec.tooltip then
            btn:HookScript("OnEnter", function()
                GameTooltip:SetOwner(btn, "ANCHOR_TOPRIGHT")
                GameTooltip:SetText(spec.tooltip)
                GameTooltip:Show()
            end)
            btn:HookScript("OnLeave", function() GameTooltip:Hide() end)
        end
        btn:SetChecked(ham.options[spec.key])
        optionButtons[spec.key] = btn
        return btn
    end

    -- Behavior options
    local behaviorSchema = {
        { key = "stopCast", label = L["Include /stopcasting in the macro"], tooltip = L["Useful for casters."], offsetX = 0, offsetY = PADDING },
        { key = "cdReset", label = L["Includes the shortest Cooldown in the reset Condition of Castsequence. !!USE CAREFULLY!!"], offsetX = 0, offsetY = PADDING },
        { key = "raidStone", label = L["Low Priority Healthstones"], onEnter = function(btn)
            GameTooltip:SetOwner(btn, "ANCHOR_TOPRIGHT"); GameTooltip:SetText(L["Prioritize health potions over a healthstone."]); GameTooltip:Show()
        end, offsetX = 0, offsetY = PADDING },
    }

    local last = behaviourTitle
    for _, spec in ipairs(behaviorSchema) do
        last = createOption(spec, last)
    end
    lastStaticElement = last


	-------------  ITEMS  -------------
	local witheringPotionButton = nil
	local witheringDreamsPotionButton = nil
	local cavedwellerDelightButton = nil
	local heartseekingButton = nil
            if env and env.isRetail then
        local itemsTitle = self.content:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
        itemsTitle:SetPoint("TOPLEFT", lastStaticElement, 0, -PADDING_CATERGORY)
        itemsTitle:SetText(L["Items"])

        local itemSchema = {
            { key = "witheringPotion", label = L["Potion of Withering Vitality"], anchor = "grid", row = 1, col = 0, onEnter = function(btn)
                GameTooltip:SetOwner(btn, "ANCHOR_TOPRIGHT"); GameTooltip:SetItemByID(ham.witheringR3.getId()); GameTooltip:Show()
            end },
            { key = "witheringDreamsPotion", label = L["Potion of Withering Dreams"], anchor = "grid", row = 1, col = 1, onEnter = function(btn)
                GameTooltip:SetOwner(btn, "ANCHOR_TOPRIGHT"); GameTooltip:SetItemByID(ham.witheringDreamsR3.getId()); GameTooltip:Show()
            end },
            { key = "cavedwellerDelight", label = L["Cavedweller's Delight"], anchor = "grid", row = 1, col = 2, onEnter = function(btn)
                GameTooltip:SetOwner(btn, "ANCHOR_TOPRIGHT"); GameTooltip:SetItemByID(ham.cavedwellersDelightR3.getId()); GameTooltip:Show()
            end },
            { key = "heartseekingInjector", label = L["Heartseeking Health Injector (tinker)"], anchor = "grid", row = 2, col = 0, onEnter = function(btn)
                if ham.tinkerSlot then GameTooltip:SetOwner(btn, "ANCHOR_TOPRIGHT"); GameTooltip:SetInventoryItem("player", ham.tinkerSlot); GameTooltip:Show() end
            end },
        }

        local lastItem
        for _, spec in ipairs(itemSchema) do
            lastItem = createOption(spec, itemsTitle)
        end
        lastStaticElement = lastItem or itemsTitle
    end

	-------------  CLASS / RACIALS  -------------
	myClassTitle = self.content:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
	myClassTitle:SetPoint("TOPLEFT", lastStaticElement, 0, -PADDING_CATERGORY)
	myClassTitle:SetText(L["Class/Racial Spells"])

	-------------  CURRENT PRIORITY  -------------
	currentPrioTitle = self.content:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
	currentPrioTitle:SetPoint("TOPLEFT", myClassTitle, 0, -PADDING_CATERGORY - PADDING)
	currentPrioTitle:SetText(L["Current Priority"])

	-------------  BANDAGE PRIORITY  -------------
	bandagePrioTitle = self.content:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
	bandagePrioTitle:SetPoint("TOPLEFT", currentPrioTitle, 0, -PADDING_CATERGORY - ICON_SIZE)
	bandagePrioTitle:SetText(L["Bandage Priority"])


	-------------  RESET BUTTON  -------------
	local btn = CreateFrame("Button", nil, self.content, "UIPanelButtonTemplate")
	btn:SetPoint("BOTTOMLEFT", 1, 0)
	btn:SetText(L["Reset to Default"])
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
        for key, btn in pairs(optionButtons) do
            if btn and btn.SetChecked then btn:SetChecked(ham.options[key]) end
        end
		ham.updateHeals()
		ham.updateMacro()
		self:updatePrio()
		self:updateBandagePrio()
		print(L["Reset successful!"])
	end)
end

function ham.settingsFrame:InitializeClassSpells(relativeTo)
	local lastbutton = nil
	local posy = -PADDING
	if next(ham.supportedSpells) ~= nil then
		local count = 0
		for i, spell in ipairs(ham.supportedSpells) do
			if IsSpellKnown(spell) or IsSpellKnown(spell, true) then
				local name = ham.getSpellName(spell)
				local button = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")

				if count == 3 then
					lastbutton = nil
					count = 0
					posy = posy - PADDING
				end
				if lastbutton ~= nil then
					button:SetPoint("TOPLEFT", lastbutton, PADDING_HORIZONTAL, 0)
				else
					button:SetPoint("TOPLEFT", relativeTo, 0, posy)
				end
				---@diagnostic disable-next-line: undefined-field
				button.Text:SetText(spell.getName())
				button:HookScript("OnClick", function(_, btn, down)
					if button:GetChecked() then
						ham.insertIntoDB(spell.getId())
					else
						ham.removeFromDB(spell.getId())
					end
					ham.updateHeals()
					ham.updateMacro()
					self:updatePrio()
				end)
				button:HookScript("OnEnter", function(_, btn, down)
					---@diagnostic disable-next-line: param-type-mismatch
					GameTooltip:SetOwner(button, "ANCHOR_TOPRIGHT")
					GameTooltip:SetSpellByID(spell.getId());
					GameTooltip:Show()
				end)
				button:HookScript("OnLeave", function(_, btn, down)
					GameTooltip:Hide()
				end)
				button:SetChecked(ham.dbContains(spell.getId()))
				table.insert(classButtons, spell.getId(), button)
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
	-- Check if the message contains "debug"
	if msg and msg:trim():lower() == "debug" then
		ham.debug = not ham.debug
		ham.checkTinker()
		print("|cffb48ef9AutoPotion:|r Debug mode is now " .. (ham.debug and "enabled" or "disabled"))
		return
	end

	-- Open settings if no "debug" keyword was passed
	if InterfaceOptions_AddCategory then
		InterfaceOptionsFrame_OpenToCategory(addonName)
	else
		local settingsCategoryID = _G[addonName].categoryID
		Settings.OpenToCategory(settingsCategoryID)
	end
end
