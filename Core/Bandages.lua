local addonName, ham = ...
local isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
local isWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
local isCata = (WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC)
local isMop = (WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC)

-- Classic bandages
ham.linenBandage = ham.Item.new(1251, "Linen Bandage")
ham.heavyLinenBandage = ham.Item.new(2581, "Heavy Linen Bandage")
ham.woolBandage = ham.Item.new(3530, "Wool Bandage")
ham.heavyWoolBandage = ham.Item.new(3531, "Heavy Wool Bandage")
ham.silkBandage = ham.Item.new(6450, "Silk Bandage")
ham.heavySilkBandage = ham.Item.new(6451, "Heavy Silk Bandage")
ham.mageweaveBandage = ham.Item.new(8544, "Mageweave Bandage")
ham.heavyMageweaveBandage = ham.Item.new(8545, "Heavy Mageweave Bandage")
ham.runeclothBandage = ham.Item.new(14529, "Runecloth Bandage")
ham.heavyRuneclothBandage = ham.Item.new(14530, "Heavy Runecloth Bandage")
  
  -- Alterac Valley (Classic-only)
  ham.alteracHeavyRuneclothBandage = ham.Item.new(19307, "Alterac Heavy Runecloth Bandage")

-- TBC
ham.netherweaveBandage = ham.Item.new(21990, "Netherweave Bandage")
ham.heavyNetherweaveBandage = ham.Item.new(21991, "Heavy Netherweave Bandage")

-- WotLK
ham.frostweaveBandage = ham.Item.new(34721, "Frostweave Bandage")
ham.heavyFrostweaveBandage = ham.Item.new(34722, "Heavy Frostweave Bandage")

-- Cataclysm
ham.embersilkBandage = ham.Item.new(53049, "Embersilk Bandage")
ham.heavyEmbersilkBandage = ham.Item.new(53050, "Heavy Embersilk Bandage")
ham.denseEmbersilkBandage = ham.Item.new(53051, "Dense Embersilk Bandage")

-- Mists of Pandaria
ham.windwoolBandage = ham.Item.new(72985, "Windwool Bandage")
ham.heavyWindwoolBandage = ham.Item.new(72986, "Heavy Windwool Bandage")

-- Retail (Dragonflight)
ham.wilderclothBandage = ham.Item.new(194041, "Wildercloth Bandage")
ham.denseWilderclothBandage = ham.Item.new(194207, "Dense Wildercloth Bandage")

-- Return a prioritized list of bandage items for the current client
function ham.getBandages()
  -- Classic Era only has classic bandages
  if isClassic then
    -- Base priority list for Classic
    local list = {
      ham.heavyRuneclothBandage,
      ham.runeclothBandage,
      ham.heavyMageweaveBandage,
      ham.mageweaveBandage,
      ham.heavySilkBandage,
      ham.silkBandage,
      ham.heavyWoolBandage,
      ham.woolBandage,
      ham.heavyLinenBandage,
      ham.linenBandage,
    }

    -- When inside a PvP instance (e.g., Alterac Valley), prioritize the Alterac-only bandage
    local inInstance, instanceType = IsInInstance()
    if inInstance and instanceType == "pvp" then
        if C_Map.GetBestMapForUnit("player") == 1459 then
          if ham.alteracHeavyRuneclothBandage.getCount() > 0 then
            table.insert(list, 1, ham.alteracHeavyRuneclothBandage)
          end
        end
    end

    return list
  end

  -- Wrath Classic
  if isWrath then
    return {
      ham.heavyFrostweaveBandage,
      ham.frostweaveBandage,
      ham.heavyNetherweaveBandage,
      ham.netherweaveBandage,
      ham.heavyRuneclothBandage,
      ham.runeclothBandage,
      ham.heavyMageweaveBandage,
      ham.mageweaveBandage,
      ham.heavySilkBandage,
      ham.silkBandage,
      ham.heavyWoolBandage,
      ham.woolBandage,
      ham.heavyLinenBandage,
      ham.linenBandage,
    }
  end

  -- Cataclysm Classic
  if isCata then
    return {
      ham.denseEmbersilkBandage,
      ham.heavyEmbersilkBandage,
      ham.embersilkBandage,
      ham.heavyFrostweaveBandage,
      ham.frostweaveBandage,
      ham.heavyNetherweaveBandage,
      ham.netherweaveBandage,
      ham.heavyRuneclothBandage,
      ham.runeclothBandage,
      ham.heavyMageweaveBandage,
      ham.mageweaveBandage,
      ham.heavySilkBandage,
      ham.silkBandage,
      ham.heavyWoolBandage,
      ham.woolBandage,
      ham.heavyLinenBandage,
      ham.linenBandage,
    }
  end

  -- Mists Classic
  if isMop then
    return {
      ham.heavyWindwoolBandage,
      ham.windwoolBandage,
      ham.denseEmbersilkBandage,
      ham.heavyEmbersilkBandage,
      ham.embersilkBandage,
      ham.heavyFrostweaveBandage,
      ham.frostweaveBandage,
      ham.heavyNetherweaveBandage,
      ham.netherweaveBandage,
      ham.heavyRuneclothBandage,
      ham.runeclothBandage,
      ham.heavyMageweaveBandage,
      ham.mageweaveBandage,
      ham.heavySilkBandage,
      ham.silkBandage,
      ham.heavyWoolBandage,
      ham.woolBandage,
      ham.heavyLinenBandage,
      ham.linenBandage,
    }
  end

  -- Retail (include modern first, then legacy in case they exist)
  return {
    ham.denseWilderclothBandage,
    ham.wilderclothBandage,
    ham.heavyWindwoolBandage,
    ham.windwoolBandage,
    ham.denseEmbersilkBandage,
    ham.heavyEmbersilkBandage,
    ham.embersilkBandage,
    ham.heavyFrostweaveBandage,
    ham.frostweaveBandage,
    ham.heavyNetherweaveBandage,
    ham.netherweaveBandage,
    ham.heavyRuneclothBandage,
    ham.runeclothBandage,
    ham.heavyMageweaveBandage,
    ham.mageweaveBandage,
    ham.heavySilkBandage,
    ham.silkBandage,
    ham.heavyWoolBandage,
    ham.woolBandage,
    ham.heavyLinenBandage,
    ham.linenBandage,
  }
end


