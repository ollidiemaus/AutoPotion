Item = {}

Item.new = function(id,name)
  local self = {}

  self.id = id
  self.name = name

  local function setName()
    itemInfoName = GetItemInfo(self.id)
      if itemInfoName~=nil then
        self.name = itemInfoName
      end
  end

  function self.getId()
    return self.id
  end

  function self.getCount ()
    return GetItemCount(self.id, false, false)
  end

  return self
end