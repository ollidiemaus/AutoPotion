-- This file is loaded from "HealthstoneAutoMacro.toc"

---------------------------------
--------Custom Item Class--------
---------------------------------
local Item = {}

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

  function self.getName()
    --it's probably not necessary to do this every time we get the name but thats how it worked in previous version this would need further testing
    setName()
    return self.name
  end

  function self.getCount ()
    return GetItemCount(self.id, false, false)
  end

  return self
end
---------------------------------

do
  --local leywine = Item.new(194684,"Azure Leywine")
  local healthstone = Item.new(5512,"Healthstone")
  local refreshingR3 = Item.new(191380,"Refreshing Healing Potion")
  local refreshingR2 = Item.new(191379,"Refreshing Healing Potion")
  local refreshingR1 = Item.new(191378,"Refreshing Healing Potion")
  local spiritual = Item.new(171267,"Spiritual Healing Potion")
  
  function getPots()
    return {
      refreshingR3,
      refreshingR2,
      refreshingR1,
      spiritual
    }
  end
      
  local onCombat = true
  local HealPotMacroIcon = CreateFrame("Frame")
  HealPotMacroIcon:RegisterEvent("BAG_UPDATE")
  HealPotMacroIcon:RegisterEvent("PLAYER_LOGIN")
  HealPotMacroIcon:RegisterEvent("PLAYER_REGEN_ENABLED")
  HealPotMacroIcon:RegisterEvent("PLAYER_REGEN_DISABLED")
  HealPotMacroIcon:SetScript("OnEvent",function(self,event,...)
    if event=="PLAYER_LOGIN" then
      onCombat = false
    end
    if event=="PLAYER_REGEN_DISABLED" then
      onCombat = true
      return
    end
    if event=="PLAYER_REGEN_ENABLED" then
      onCombat = false
    end
  
    if onCombat==false then
      local Pot = getPots()
      local playerClass, englishClass, classIndex = UnitClass("player")
      local resetType = "combat"
      local macroStr, potName, foundPots, foundHealthstone, potList, potListCounter, potsString
  
      foundPots = false
      foundHealthstone = false
      potList = {}
      potListCounter = 0
      potsString = ""

      for iterator,value in ipairs(Pot) do
        if value.getCount() > 0 then
          foundPots = true;
          potName = value.getName()
          break;
        end
      end

      if healthstone.getCount() > 0 then
        foundHealthstone = true
      end

      ---uncomment this block if you really want cirmson vial to be in this roation.
      --[[if englishClass=="ROGUE" then
        resetType = "30"
        table.insert(potList, "Crimson Vial")
        potListCounter=potListCounter+1
      end--]]

      if foundHealthstone==true then
        table.insert(potList,healthstone.getName())
        potListCounter=potListCounter+1
      end
      if foundPots==true then
        table.insert(potList,potName)
        potListCounter=potListCounter+1
      end
  
      if potListCounter==0 then
        macroStr = "#showtooltip"
      else
        for i, v in ipairs(potList) do
          if i==1 then
            potsString = potsString .. v;
          else
            potsString = potsString .. ", " .. v;
          end
        end
        macroStr = "#showtooltip \n/castsequence reset=" .. resetType .. " " .. potsString
      end
      EditMacro("HAMHealthPot", "HAMHealthPot", nil, macroStr, 1, nil)
    end
  end)
end