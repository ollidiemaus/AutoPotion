---@diagnostic disable: undefined-global
local L = LibStub("AceLocale-3.0"):GetLocale("AutoPotion")
local addonName, ham = ...

-- The "AutoPotion" root category of the settings: a short page explaining how the addon
-- works, which /ap opens to. Every macro's settings page is registered below it via
-- addSubcategory.
---@class Frame
ham.infoSettingsFrame = CreateFrame("Frame")
local PADDING = 25
local LINE_GAP = 6
local ENTRY_GAP = 12
local MACRO_ICON_SIZE = 26
local ADDON_ICON_SIZE = 36
local ICON_GAP = 10
local STEP_NUMBER_WIDTH = 22
local COMMAND_WIDTH = 90
local LINK_WIDTH = 300
local LINK_HEIGHT = 20
local LINK_BORDER = 5 -- InputBoxTemplate draws its border this far outside the box

local MACROS = {
	{
		name = L["AutoPotion"],
		icon = "Interface\\Icons\\INV_Potion_54",
		description = L["Healthstones, healing potions and class/racial self-heals."],
	},
	{
		name = L["AutoManaPotion"],
		icon = "Interface\\Icons\\INV_Potion_76",
		description = L["The mana potion that restores the most mana."],
	},
	{
		name = L["AutoFood"],
		icon = "Interface\\Icons\\INV_Misc_Fork&Knife",
		description = L["The best food in your bags."],
	},
	{
		name = L["AutoDrink"],
		icon = "Interface\\Icons\\INV_Drink_07",
		description = L["The best drink in your bags."],
	},
	{
		name = L["AutoBandage"],
		icon = "Interface\\Icons\\INV_Misc_Bandage_12",
		description = L["Your strongest bandage, including battleground bandages."],
	},
}

local COMMANDS = {
	{ command = "/ap",       description = L["Opens these settings."] },
	{ command = "/ap debug", description = L["Toggles debug messages in the chat."] },
}

-- Other addons by the same author. `flavors` are product names and stay untranslated. The
-- icons are copies of each addon's own icon in Media, so they show without the addon installed.
local MEDIA = "Interface\\AddOns\\" .. addonName .. "\\Media\\"
local OTHER_ADDONS = {
	{
		name = "AutoSetup",
		icon = MEDIA .. "AutoSetup",
		flavors = "Retail · WoW Forever",
		url = "https://www.curseforge.com/wow/addons/autosetup",
		description = L["Applies the right Edit Mode layout, UI scale and AddOn set for your screen resolution. Made for switching between PC, laptop and Steam Deck."],
	},
	{
		name = "Wayscribe",
		icon = MEDIA .. "Wayscribe",
		flavors = "WoW Forever",
		url = "https://www.curseforge.com/wow/addons/wayscribe",
		description = L["An automatic journal of your adventures: level ups, dungeon runs, first boss kills, professions and your routes on the world map."],
	},
}

local function isAddOnLoaded(name)
	if C_AddOns and C_AddOns.IsAddOnLoaded then
		return C_AddOns.IsAddOnLoaded(name)
	end
	return IsAddOnLoaded and IsAddOnLoaded(name)
end

-- nil for an unpackaged checkout, where the TOC still holds the packager's placeholder
local function getVersion()
	local getMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
	local version = getMetadata and getMetadata(addonName, "Version")
	if version and not version:find("^@") then
		return version
	end
	return nil
end

-- Registers a settings page below the AutoPotion root. Pages are listed in the order they
-- are registered (see ham.settingsFrame:OnEvent).
function ham.infoSettingsFrame:addSubcategory(panel)
	if self.category then
		Settings.RegisterCanvasLayoutSubcategory(self.category, panel, panel.name)
	else
		panel.parent = self.panel.name
		InterfaceOptions_AddCategory(panel)
	end
end

function ham.infoSettingsFrame:open()
	if self.category then
		Settings.OpenToCategory(self.category:GetID())
	else
		InterfaceOptionsFrame_OpenToCategory(self.panel)
	end
end

-- Show "Installed" next to the other addons that are loaded. Checked whenever the page is
-- shown: when this page is created, addons that load after AutoPotion (e.g. AutoSetup) aren't
-- loaded yet.
function ham.infoSettingsFrame:updateInstalledLabels()
	for name, label in pairs(self.installedLabels) do
		label:SetShown(isAddOnLoaded(name) and true or false)
	end
end

-- Resize the scrollable content to fit the page. The text wraps, so its height depends on
-- the width of the settings window.
function ham.infoSettingsFrame:recalculateContentHeight()
	if self.content == nil or self.lastElement == nil then return end
	local contentTop = self.content:GetTop()
	local bottom = self.lastElement:GetBottom()
	if contentTop == nil or bottom == nil then return end
	self.content:SetHeight((contentTop - bottom) + PADDING)
end

function ham.infoSettingsFrame:InitializeOptions()
	self.panel = CreateFrame("Frame", addonName, InterfaceOptionsFramePanelContainer)
	self.panel.name = addonName

	-- Prefer the modern Settings API whenever the client has it: the old
	-- InterfaceOptions_AddCategory identifies categories by name, and the healing page below
	-- this one is also called "AutoPotion".
	if Settings and Settings.RegisterCanvasLayoutCategory then
		self.category = Settings.RegisterCanvasLayoutCategory(self.panel, addonName)
		Settings.RegisterAddOnCategory(self.category)
	else
		InterfaceOptions_AddCategory(self.panel)
	end

	self.installedLabels = {}

	self.panel:SetScript("OnShow", function()
		ham.infoSettingsFrame:updateInstalledLabels()
		ham.infoSettingsFrame:recalculateContentHeight()
		-- wrapped text may only get its final height once the page has been laid out
		C_Timer.After(0, function() ham.infoSettingsFrame:recalculateContentHeight() end)
	end)

	-- scrollable area, matching the other pages' layout
	self.scrollFrame = CreateFrame("ScrollFrame", addonName .. "InfoScrollFrame", self.panel,
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

	local content = CreateFrame("Frame", nil, self.scrollFrame)
	content:SetSize(1, 1)
	self.scrollFrame:SetScrollChild(content)
	self.scrollFrame:HookScript("OnSizeChanged", function(_, width)
		content:SetWidth(width)
		ham.infoSettingsFrame:recalculateContentHeight()
	end)
	self.content = content

	-- Every element is placed below the previous one (`last`). `lastIndent` is how far `last`
	-- sits right of the content's left edge, so the next element can line up with it again.
	local last, lastIndent

	-- Font string below `anchor` reaching to the right edge of the page, wrapping as needed.
	local function createText(fontObject, text, anchor, offsetX, offsetY)
		local fontString = content:CreateFontString(nil, "ARTWORK", fontObject)
		fontString:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", offsetX, offsetY)
		fontString:SetPoint("RIGHT", content, "RIGHT", 0, 0)
		fontString:SetJustifyH("LEFT")
		fontString:SetText(text)
		return fontString
	end

	local function addSectionTitle(text)
		last = createText("GameFontNormalHuge", text, last, -lastIndent, -PADDING)
		lastIndent = 0
	end

	local function addParagraph(text)
		last = createText("GameFontHighlight", text, last, -lastIndent, -ENTRY_GAP)
		lastIndent = 0
	end

	-- "label  text" entry, with the text wrapping in its own column next to the label
	local function addListEntry(label, text, labelWidth)
		local labelString = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		labelString:SetPoint("TOPLEFT", last, "BOTTOMLEFT", -lastIndent, -LINE_GAP)
		labelString:SetWidth(labelWidth)
		labelString:SetJustifyH("LEFT")
		labelString:SetText(label)

		local textString = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		textString:SetPoint("TOPLEFT", labelString, "TOPRIGHT", 0, 0)
		textString:SetPoint("RIGHT", content, "RIGHT", 0, 0)
		textString:SetJustifyH("LEFT")
		textString:SetText(text)
		last, lastIndent = textString, labelWidth
	end

	-- Icon on the left, the name (plus an optional grey `tag`) next to it and the description
	-- below the name. Returns the name font string.
	local function addIconEntry(iconTexture, iconSize, name, nameFont, tag, description)
		local icon = content:CreateTexture(nil, "ARTWORK")
		icon:SetSize(iconSize, iconSize)
		icon:SetPoint("TOPLEFT", last, "BOTTOMLEFT", -lastIndent, -ENTRY_GAP)
		icon:SetTexture(iconTexture)
		if iconTexture:find("^Interface\\Icons\\") then
			icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- crop the border baked into the game's icons
		end

		local nameString = content:CreateFontString(nil, "ARTWORK", nameFont)
		nameString:SetPoint("TOPLEFT", icon, "TOPRIGHT", ICON_GAP, 0)
		nameString:SetText(name)

		if tag then
			local tagString = content:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
			tagString:SetPoint("BOTTOMLEFT", nameString, "BOTTOMRIGHT", 8, 1)
			tagString:SetText(tag)
		end

		last = createText("GameFontHighlight", description, nameString, 0, -3)
		lastIndent = iconSize + ICON_GAP
		return nameString
	end

	-- The game can't open web pages, so links are shown in a read-only edit box: clicking it
	-- selects the whole link, ready to be copied.
	local function addLink(url)
		local box = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
		box:SetSize(LINK_WIDTH, LINK_HEIGHT)
		box:SetPoint("TOPLEFT", last, "BOTTOMLEFT", LINK_BORDER, -LINE_GAP)
		box:SetAutoFocus(false)
		box:SetFontObject(GameFontHighlightSmall)
		box:SetText(url)
		box:SetCursorPosition(0)
		box:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
		box:SetScript("OnEditFocusLost", function(self) self:HighlightText(0, 0) end)
		-- clicking moves the cursor, which would drop the selection again
		box:SetScript("OnMouseUp", function(self) self:HighlightText() end)
		box:SetScript("OnTextChanged", function(self, userInput)
			if userInput then
				self:SetText(url)
				self:HighlightText()
			end
		end)
		box:SetScript("OnEscapePressed", box.ClearFocus)
		box:SetScript("OnEnterPressed", box.ClearFocus)

		local hint = content:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
		hint:SetPoint("LEFT", box, "RIGHT", 8, 0)
		hint:SetText(string.format(L["Click and press %s to copy"], IsMacClient and IsMacClient() and "Cmd+C" or L["Ctrl+C"]))

		last, lastIndent = box, lastIndent + LINK_BORDER
	end

	-------------  HEADER  -------------
	local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	title:SetPoint("TOP", 0, 0)
	title:SetText(L["AutoPotion"])

	local version = getVersion()
	if version then
		local versionString = content:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
		versionString:SetPoint("TOP", title, "BOTTOM", 0, -2)
		versionString:SetText(string.format(L["Version %s"], version))
	end

	-- same position as the subtitle on the other pages
	local intro = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	intro:SetPoint("TOPLEFT", 0, -40)
	intro:SetPoint("RIGHT", content, "RIGHT", 0, 0)
	intro:SetJustifyH("LEFT")
	intro:SetText(L["AutoPotion keeps your macros up to date, so one key always uses the best you have right now: healing spells, potions, food, drink and bandages."])
	last, lastIndent = intro, 0

	-------------  HOW IT WORKS  -------------
	addSectionTitle(L["How it works"])
	addListEntry("1.", L["AutoPotion creates the macros listed below. You find them under General Macros (/macro)."], STEP_NUMBER_WIDTH)
	addListEntry("2.", L["Drag the macros you want onto your action bars and bind a key."], STEP_NUMBER_WIDTH)
	addListEntry("3.", L["That's it. The macros update themselves out of combat whenever your bags, talents or gear change. You still press the key yourself - AutoPotion never casts anything for you."], STEP_NUMBER_WIDTH)
	addParagraph(L["Each macro has its own settings page in the list on the left."])

	-------------  MACROS  -------------
	addSectionTitle(L["Macros"])
	for _, macro in ipairs(MACROS) do
		addIconEntry(macro.icon, MACRO_ICON_SIZE, macro.name, "GameFontNormal", nil, macro.description)
	end

	-------------  COMMANDS  -------------
	addSectionTitle(L["Commands"])
	for _, entry in ipairs(COMMANDS) do
		addListEntry(entry.command, entry.description, COMMAND_WIDTH)
	end

	-------------  OTHER ADDONS  -------------
	addSectionTitle(string.format(L["More addons by %s"], "ollidiemaus"))
	for _, addon in ipairs(OTHER_ADDONS) do
		addIconEntry(addon.icon, ADDON_ICON_SIZE, addon.name, "GameFontNormalLarge", addon.flavors, addon.description)

		-- right-aligned on the name's line: the description spans the full width below it
		local status = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		status:SetPoint("BOTTOMRIGHT", last, "TOPRIGHT", 0, 3)
		status:SetText(GREEN_FONT_COLOR_CODE .. L["Installed"] .. FONT_COLOR_CODE_CLOSE)
		self.installedLabels[addon.name] = status

		addLink(addon.url)
	end
	self:updateInstalledLabels()

	self.lastElement = last
end
