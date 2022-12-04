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

  --this is never called and can be removed as we use ids in the macros now
  function self.getName()
    --it's probably not necessary to do this every time we get the name but thats how it worked in previous version this would need further testing
    setName()
    return self.name
  end

  function self.getId()
    return self.id
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
  local cosmic = Item.new(187802,"Cosmic Healing Potion")
  local spiritual = Item.new(171267,"Spiritual Healing Potion")
  local soulful = Item.new(180317,"Soulful Healing Potion")
  local ashran = Item.new(115498,"Ashran Healing Tonic")
  local abyssal = Item.new(169451,"Abyssal Healing Potion")
  local astral = Item.new(152615,"Astral Healing Potion")
  local coastal = Item.new(152494,"Coastal Healing Potion")
  local ancient = Item.new(127834,"Ancient Healing Potion")
  local aged = Item.new(136569,"Aged Health Potion")
  local tonic = Item.new(109223,"Healing Tonic")
  local master = Item.new(76097,"Master Healing Potion")
  local mythical = Item.new(57191,"Mythical Healing Potion")
  local runic = Item.new(33447,"Runic Healing Potion")
  local resurgent = Item.new(39671,"Resurgent Healing Potion")
  local super = Item.new(22829,"Super Healing Potion")
  local major = Item.new(13446,"Major Healing Potion")
  local lesser = Item.new(858,"Lesser Healing Potion")
  ---superior has probably wrong scaling
  local superior = Item.new(3928,"Superior Healing Potion")
  local minor = Item.new(118,"Minor Healing Potion")
  local greater = Item.new(1710,"Greater Healing Potion")
  local healingPotion = Item.new(929,"Healing Potion")
  
  function getPots()
    return {
      refreshingR3,
      refreshingR2,
      refreshingR1,
      cosmic,
      spiritual,
      soulful,
      ashran,
      abyssal,
      astral,
      coastal,
      ancient,
      aged,
      tonic,
      master,
      mythical,
      runic,
      resurgent,
      super,
      major,
      lesser,
      superior,
      minor,
      greater,
      healingPotion
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
      local macroStr, foundPots, foundHealthstone, potListCounter, potsString, potId, potIdList
  
      foundPots = false
      foundHealthstone = false
      potIdList = {}
      potListCounter = 0
      potsString = ""

      for iterator,value in ipairs(Pot) do
        --this is because the getCount onCombat works differently
        if value.getCount() > 0 then
          foundPots = true;
          potId = value.getId()
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
        table.insert(potIdList,healthstone.getId())
        potListCounter=potListCounter+1
      end
      if foundPots==true then
        table.insert(potIdList,potId)
        potListCounter=potListCounter+1
      end
  
      if potListCounter==0 then
        macroStr = "#showtooltip"
      else
        for i, v in ipairs(potIdList) do
          if i==1 then
            potsString = "item:" .. v;
          else
            potsString = potsString .. ", " .. "item:" .. v;
          end
        end
        macroStr = "#showtooltip \n/castsequence reset=" .. resetType .. " " .. potsString
      end
      EditMacro("HAMHealthPot", "HAMHealthPot", nil, macroStr, 1, nil)
    end
  end)
end