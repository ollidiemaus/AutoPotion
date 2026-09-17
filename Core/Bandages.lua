local addonName, ham = ...

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

-- Dragonflight
ham.wilderclothBandageR3 = ham.Item.new(194050, "Wildercloth Bandage")
ham.wilderclothBandageR2 = ham.Item.new(194049, "Wildercloth Bandage")
ham.wilderclothBandageR1 = ham.Item.new(194048, "Wildercloth Bandage")

-- The War Within
ham.weaverclothBandageR3 = ham.Item.new(224442, "Weavercloth Bandage")
ham.weaverclothBandageR2 = ham.Item.new(224441, "Weavercloth Bandage")
ham.weaverclothBandageR1 = ham.Item.new(224440, "Weavercloth Bandage")

-- Midnight
ham.brightlinenBandageR2 = ham.Item.new(239713, "Bright Linen Bandage")
ham.brightlinenBandageR1 = ham.Item.new(239711, "Bright Linen Bandage")

-- Return a prioritized list of bandage items for the current client
function ham.getBandages()
  if ham.isClassic and ham.getBandagesForClassic then return ham.getBandagesForClassic() end
  if ham.isWrath and ham.getBandagesForWrath then return ham.getBandagesForWrath() end
  if ham.isCata and ham.getBandagesForCata then return ham.getBandagesForCata() end
  if ham.isMop and ham.getBandagesForMists then return ham.getBandagesForMists() end

  -- Everything else (Retail, and any other flavor without a dedicated list) falls back to Retail's list
  if ham.getBandagesForRetail then return ham.getBandagesForRetail() end
  return {}
end
