---@diagnostic disable: undefined-global
local addonName, ham = ...

-- A "Current Priority" row of the settings pages: one icon per entry, left to right in priority
-- order, each showing its entry's tooltip on hover. A refresh fills it again with reset, add for
-- each entry, then finish; the icon frames are kept and reused, so it makes no garbage.
--
-- An entry is a kind and an id: "spell" (spell id), "item" (item id) or "slot" (inventory slot of
-- an equipped item, the tinker).
local ICON_SIZE = 50
local ICON_STEP = ICON_SIZE * 1.5 -- an icon and half an icon of gap
-- how tall the row is, for the pages that make room for it
ham.PREVIEW_ROW_HEIGHT = ICON_SIZE

-- each kind's icon and tooltip
local KINDS = {
	spell = {
		icon = ham.getSpellIcon,
		tooltip = function(spellId) GameTooltip:SetSpellByID(spellId) end,
	},
	item = {
		-- by item ID, which doesn't wait for the item cache the way GetItemInfo does
		icon = function(itemId) return C_Item.GetItemIconByID(itemId) end,
		tooltip = function(itemId) GameTooltip:SetItemByID(itemId) end,
	},
	slot = {
		icon = function(slot) return GetInventoryItemTexture("player", slot) end,
		tooltip = function(slot) GameTooltip:SetInventoryItem("player", slot) end,
	},
}

local function showTooltip(icon)
	GameTooltip:SetOwner(icon, "ANCHOR_TOPRIGHT")
	KINDS[icon.kind].tooltip(icon.id)
	GameTooltip:Show()
end

local function hideTooltip()
	GameTooltip:Hide()
end

---@class PreviewRow
local PreviewRow = {}
PreviewRow.__index = PreviewRow

-- A row on `parent` whose first icon's top left sits at offsetX, offsetY from anchor's top left.
function ham.newPreviewRow(parent, anchor, offsetX, offsetY)
	return setmetatable({
		parent = parent, anchor = anchor, offsetX = offsetX, offsetY = offsetY, icons = {}, count = 0,
	}, PreviewRow)
end

function PreviewRow:reset()
	self.count = 0
end

function PreviewRow:add(kind, id)
	local index = self.count + 1
	self.count = index
	local icon = self.icons[index]
	if icon == nil then
		icon = CreateFrame("Frame", nil, self.parent)
		icon:SetFrameStrata("MEDIUM")
		icon:SetSize(ICON_SIZE, ICON_SIZE)
		icon:SetPoint("TOPLEFT", self.anchor, "TOPLEFT", self.offsetX + (index - 1) * ICON_STEP, self.offsetY)
		icon:SetScript("OnEnter", showTooltip)
		icon:SetScript("OnLeave", hideTooltip)
		icon.texture = icon:CreateTexture(nil, "BACKGROUND")
		icon.texture:SetAllPoints(icon)
		self.icons[index] = icon
	end
	icon.kind, icon.id = kind, id
	icon.texture:SetTexture(KINDS[kind].icon(id))
	icon:Show()
end

-- Hides the icons left over from a longer list.
function PreviewRow:finish()
	for i = self.count + 1, #self.icons do
		self.icons[i]:Hide()
	end
end

-- Fills the row with the items of `items` (ham.Item, best first) that are in the bags.
function PreviewRow:showItemsInBags(items)
	self:reset()
	for _, item in ipairs(items) do
		if item.getCount() > 0 then
			self:add("item", item.getId())
		end
	end
	self:finish()
end
