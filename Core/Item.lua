local addonName, ham = ...

ham.Item = {}

ham.Item.new = function(id, name, tags)
  local self = {}

  self.id = id
  self.name = name
  self.tags = tags or {}

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
