local addonName, ham = ...

ham.Item = {}

-- What a food or drink item restores over the whole eat, from its tags: hp / mp flat totals,
-- hpPct / mpPct shares of maximum health / mana, scaled = true when the amount follows the player's
-- level. A flavor whose client differs has a table of its own under its name ({ hp = 552,
-- forever = { hp = 243.6 } }), which replaces the item's amounts there. scripts/wago_check.py
-- checks them against client data.
local RESTORE_KEYS = { "hp", "mp", "hpPct", "mpPct", "scaled" }

local function restoresOf(tags)
  local own = tags
  if ham.flavor and type(tags[ham.flavor]) == "table" then own = tags[ham.flavor] end
  local restores = {}
  for _, key in ipairs(RESTORE_KEYS) do restores[key] = own[key] end
  return restores
end

ham.Item.new = function(id, name, tags)
  local self = {}

  self.id = id
  self.name = name
  self.tags = tags or {}
  self.restores = restoresOf(self.tags)

  local function setName()
    local itemInfoName = C_Item.GetItemInfo(self.id)
    if itemInfoName ~= nil then
      self.name = itemInfoName
    end
  end

  function self.getId()
    return self.id
  end

  function self.getCount()
    return C_Item.GetItemCount(self.id, false, false)
  end

  function self.getTags()
    return self.tags
  end

  function self.hasTag(tagName)
    return self.tags[tagName] == true
  end

  return self
end
