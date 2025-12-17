---@diagnostic disable: undefined-global
local addonName, ham = ...
local env = ham.env

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

-- Warsong Gulch (Classic-only)
ham.wsgRuneclothBandage = ham.Item.new(19066, "Warsong Gulch Runecloth Bandage")
ham.wsgMageweaveBandage = ham.Item.new(19067, "Warsong Gulch Mageweave Bandage")
ham.wsgSilkBandage = ham.Item.new(19068, "Warsong Gulch Silk Bandage")

-- Arathi Basin (Classic-only) - neutral bandages
ham.abMageweaveBandage = ham.Item.new(20065, "Arathi Basin Mageweave Bandage")
ham.abRuneclothBandage = ham.Item.new(20066, "Arathi Basin Runecloth Bandage")
ham.abSilkBandage = ham.Item.new(20067, "Arathi Basin Silk Bandage")

-- Arathi Basin (Classic-only) - faction bandages
-- Horde (Defiler's)
ham.defilersSilkBandage = ham.Item.new(20235, "Defiler's Silk Bandage")
ham.defilersMageweaveBandage = ham.Item.new(20232, "Defiler's Mageweave Bandage")
ham.defilersRuneclothBandage = ham.Item.new(20234, "Defiler's Runecloth Bandage")
-- Alliance (Highlander's)
ham.highlandersSilkBandage = ham.Item.new(20244, "Highlander's Silk Bandage")
ham.highlandersMageweaveBandage = ham.Item.new(20237, "Highlander's Mageweave Bandage")
ham.highlandersRuneclothBandage = ham.Item.new(20243, "Highlander's Runecloth Bandage")

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

-- Determine environment key
local getEnvKey = ham.getEnvKey
local copyList = ham.copyList

-- Consolidated base bandage lists per environment
local BANDAGES_BY_ENV = {
  classic = {
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
  },
  wrath = {
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
  },
  cata = {
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
  },
  mop = {
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
  },
  retail = {
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
  },
}

-- Return a prioritized list of bandage items for the current client
function ham.getBandages()
  local key = getEnvKey()
  local list = copyList(BANDAGES_BY_ENV[key] or {})

  if key == "classic" then
    local inInstance, instanceType = IsInInstance()
    if inInstance and instanceType == "pvp" then
      local mapId = C_Map.GetBestMapForUnit("player")
      -- Alterac Valley
      if mapId == ham.MAP_ID_ALTERAC_VALLEY then
        if ham.alteracHeavyRuneclothBandage.getCount() > 0 then
          table.insert(list, 1, ham.alteracHeavyRuneclothBandage)
        end
      end
      -- Warsong Gulch (prefer runecloth > mageweave > silk)
      if mapId == ham.MAP_ID_WARSONG_GULCH then
        if ham.wsgRuneclothBandage.getCount() > 0 then
          table.insert(list, 1, ham.wsgRuneclothBandage)
        elseif ham.wsgMageweaveBandage.getCount() > 0 then
          table.insert(list, 1, ham.wsgMageweaveBandage)
        elseif ham.wsgSilkBandage.getCount() > 0 then
          table.insert(list, 1, ham.wsgSilkBandage)
        end
      end
      -- Arathi Basin (faction + neutral, runecloth > mageweave > silk)
      if mapId == ham.MAP_ID_ARATHI_BASIN then
        local faction = UnitFactionGroup("player")
        local abPriority = {}
        if faction == "Alliance" then
          table.insert(abPriority, ham.highlandersRuneclothBandage)
          table.insert(abPriority, ham.abRuneclothBandage)
          table.insert(abPriority, ham.highlandersMageweaveBandage)
          table.insert(abPriority, ham.abMageweaveBandage)
          table.insert(abPriority, ham.highlandersSilkBandage)
          table.insert(abPriority, ham.abSilkBandage)
        else
          table.insert(abPriority, ham.defilersRuneclothBandage)
          table.insert(abPriority, ham.abRuneclothBandage)
          table.insert(abPriority, ham.defilersMageweaveBandage)
          table.insert(abPriority, ham.abMageweaveBandage)
          table.insert(abPriority, ham.defilersSilkBandage)
          table.insert(abPriority, ham.abSilkBandage)
        end
        for _, bandage in ipairs(abPriority) do
          if bandage.getCount() > 0 then
            table.insert(list, 1, bandage)
            break
          end
        end
      end
    end
  end

  return list
end
