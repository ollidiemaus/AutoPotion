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

  function self.getId()
    return self.id
  end

  function self.getCount ()
    return GetItemCount(self.id, false, false)
  end

  return self
end
---------------------------------

---------------------------------
-------Custom Player Class-------
---------------------------------
local Player = {}

Player.new = function()
  local self = {}

  self.localizedClass, self.englishClass, self.classIndex = UnitClass("player");
  
  function self.getSpellPotions()
      ---uncomment this block if you really want cirmson vial to be in this roation.
      if self.englishClass=="ROGUE" then
        if HAMDB.crimsonVial then
          local crimsonVialSpellId = 185311
          if IsSpellKnown(crimsonVialSpellId) then
            return "30", 137222
          end
        end
      end
    return
  end
  
  --returns resetType, spellId
  function self.getHealingSpells()
      if self.englishClass=="DRUID" then
        if HAMDB.renewal then
          local renewal = 108238
          if IsSpellKnown(renewal) then
            name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(renewal)
            return "90", name
          end
        end
      end
      if self.englishClass=="HUNTER" then
        --NOTE: on GCD
        if HAMDB.exhilaration then
          local exhilaration = 109304
          if IsSpellKnown(exhilaration) then
            name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(exhilaration)
            return "120", name
          end
        end
      end
      if self.englishClass=="WARRIOR" then
        if HAMDB.bitterImmunity then
          local bitterImmunity = 383762
          if IsSpellKnown(bitterImmunity) then
            name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(bitterImmunity)
            return "180", name
          end
        end
      end

    return
  end

  return self
end
---------------------------------

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
HealPotMacroIcon:RegisterEvent("TRAIT_CONFIG_UPDATED")
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
    Pot = getPots()
    resetType = "combat"

    foundPots = false
    potIdList = {}
    potListCounter = 0
    potsString = ""

    spellNameList = {}
    spellListCounter = 0
    spellsString = ""

    myPlayer=Player.new()
    playerResetType, playerSpellName = myPlayer.getHealingSpells()

    if playerSpellName ~= nil then
      table.insert(spellNameList, playerSpellName)
      spellListCounter=spellListCounter+1
    end

    for iterator,value in ipairs(Pot) do
      --this is because the getCount onCombat works differently
      if value.getCount() > 0 then
        foundPots = true;
        potId = value.getId()
        break;
      end
    end

    if healthstone.getCount() > 0 then
      table.insert(potIdList,healthstone.getId())
      potListCounter=potListCounter+1
    end
    if foundPots==true then
      table.insert(potIdList,potId)
      potListCounter=potListCounter+1
    end
------------------Macro Building------------------
    if potListCounter==0 and spellListCounter==0 then
      macroStr = "#showtooltip \n/"
    else
      if next(spellNameList) ~= nil then
        for i, v in ipairs(spellNameList) do
          if i==1 then
            spellsString = v;
          else
            spellsString = spellsString .. ", "  .. v;
          end
        end
      end
      if next(potIdList) ~= nil then
        for i, v in ipairs(potIdList) do
          if i==1 then
            potsString = "item:" .. v;
          else
            potsString = potsString .. ", " .. "item:" .. v;
          end
        end
      end
      macroStr = "#showtooltip \n/castsequence reset=" .. resetType .. " "
      if spellsString ~= "" then
        macroStr = macroStr .. spellsString
      end
      if spellsString ~= "" and potsString ~= "" then
        macroStr = macroStr .. ", " 
      end
      if potsString ~= "" then
        macroStr = macroStr .. potsString
      end
    end
    EditMacro("HAMHealthPot", "HAMHealthPot", nil, macroStr, 1, nil)
  end
end)