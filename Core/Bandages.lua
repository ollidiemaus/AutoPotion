local addonName, ham = ...

-- firstAid: the First Aid skill a bandage needs (ItemSparse.RequiredSkillRank, the same on every
-- flavor with First Aid; scripts/wago_check.py checks it). Retail has no First Aid and ignores it.

-- Classic bandages
ham.linenBandage = ham.Item.new(1251, "Linen Bandage", { firstAid = 1 })
ham.heavyLinenBandage = ham.Item.new(2581, "Heavy Linen Bandage", { firstAid = 20 })
ham.woolBandage = ham.Item.new(3530, "Wool Bandage", { firstAid = 50 })
ham.heavyWoolBandage = ham.Item.new(3531, "Heavy Wool Bandage", { firstAid = 75 })
ham.silkBandage = ham.Item.new(6450, "Silk Bandage", { firstAid = 100 })
ham.heavySilkBandage = ham.Item.new(6451, "Heavy Silk Bandage", { firstAid = 125 })
ham.mageweaveBandage = ham.Item.new(8544, "Mageweave Bandage", { firstAid = 150 })
ham.heavyMageweaveBandage = ham.Item.new(8545, "Heavy Mageweave Bandage", { firstAid = 175 })
ham.runeclothBandage = ham.Item.new(14529, "Runecloth Bandage", { firstAid = 200 })
ham.heavyRuneclothBandage = ham.Item.new(14530, "Heavy Runecloth Bandage", { firstAid = 225 })

-- Alterac Valley (Classic-only)
ham.alteracHeavyRuneclothBandage = ham.Item.new(19307, "Alterac Heavy Runecloth Bandage", { firstAid = 225 })

-- Warsong Gulch (Classic-only)
ham.wsgRuneclothBandage = ham.Item.new(19066, "Warsong Gulch Runecloth Bandage", { firstAid = 225 })
ham.wsgMageweaveBandage = ham.Item.new(19067, "Warsong Gulch Mageweave Bandage", { firstAid = 175 })
ham.wsgSilkBandage = ham.Item.new(19068, "Warsong Gulch Silk Bandage", { firstAid = 125 })

-- Arathi Basin (Classic-only) - neutral bandages
ham.abMageweaveBandage = ham.Item.new(20065, "Arathi Basin Mageweave Bandage", { firstAid = 175 })
ham.abRuneclothBandage = ham.Item.new(20066, "Arathi Basin Runecloth Bandage", { firstAid = 225 })
ham.abSilkBandage = ham.Item.new(20067, "Arathi Basin Silk Bandage", { firstAid = 125 })

-- Arathi Basin (Classic-only) - faction bandages
-- Horde (Defiler's)
ham.defilersSilkBandage = ham.Item.new(20235, "Defiler's Silk Bandage", { firstAid = 125 })
ham.defilersMageweaveBandage = ham.Item.new(20232, "Defiler's Mageweave Bandage", { firstAid = 175 })
ham.defilersRuneclothBandage = ham.Item.new(20234, "Defiler's Runecloth Bandage", { firstAid = 225 })
-- Alliance (Highlander's)
ham.highlandersSilkBandage = ham.Item.new(20244, "Highlander's Silk Bandage", { firstAid = 125 })
ham.highlandersMageweaveBandage = ham.Item.new(20237, "Highlander's Mageweave Bandage", { firstAid = 175 })
ham.highlandersRuneclothBandage = ham.Item.new(20243, "Highlander's Runecloth Bandage", { firstAid = 225 })

-- TBC
ham.netherweaveBandage = ham.Item.new(21990, "Netherweave Bandage", { firstAid = 300 })
ham.heavyNetherweaveBandage = ham.Item.new(21991, "Heavy Netherweave Bandage", { firstAid = 325 })

-- WotLK
ham.frostweaveBandage = ham.Item.new(34721, "Frostweave Bandage", { firstAid = 350 })
ham.heavyFrostweaveBandage = ham.Item.new(34722, "Heavy Frostweave Bandage", { firstAid = 400 })

-- Cataclysm
ham.embersilkBandage = ham.Item.new(53049, "Embersilk Bandage", { firstAid = 425 })
ham.heavyEmbersilkBandage = ham.Item.new(53050, "Heavy Embersilk Bandage", { firstAid = 475 })
ham.denseEmbersilkBandage = ham.Item.new(53051, "Dense Embersilk Bandage", { firstAid = 500 })

-- Mists of Pandaria
ham.windwoolBandage = ham.Item.new(72985, "Windwool Bandage", { firstAid = 500 })
ham.heavyWindwoolBandage = ham.Item.new(72986, "Heavy Windwool Bandage", { firstAid = 550 })

-- Legion
ham.silkweaveBandage = ham.Item.new(133940, "Silkweave Bandage")
ham.silkweaveSplint = ham.Item.new(133942, "Silkweave Splint")

-- Battle for Azeroth
ham.tidesprayLinenBandage = ham.Item.new(158381, "Tidespray Linen Bandage")
ham.deepSeaBandage = ham.Item.new(158382, "Deep Sea Bandage")

-- Shadowlands
ham.shroudedClothBandage = ham.Item.new(173192, "Shrouded Cloth Bandage")
ham.heavyShroudedClothBandage = ham.Item.new(173191, "Heavy Shrouded Cloth Bandage")

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

-- WoW Forever
ham.denseRuneclothBandage = ham.Item.new(232433, "Dense Runecloth Bandage", { firstAid = 300 })
-- zone-locked to Darkspear Islands
ham.darkspearIslandsRuneclothBandage = ham.Item.new(272058, "Darkspear Islands Runecloth Bandage", { firstAid = 225 })
ham.darkspearIslandsMageweaveBandage = ham.Item.new(272057, "Darkspear Islands Mageweave Bandage", { firstAid = 175 })
ham.darkspearIslandsSilkBandage = ham.Item.new(272056, "Darkspear Islands Silk Bandage", { firstAid = 125 })

-- Return a prioritized list of bandage items for the current client
function ham.getBandages()
  if ham.isClassic and ham.getBandagesForClassic then return ham.getBandagesForClassic() end
  if ham.isTBC and ham.getBandagesForTBC then return ham.getBandagesForTBC() end
  if ham.isWrath and ham.getBandagesForWrath then return ham.getBandagesForWrath() end
  if ham.isCata and ham.getBandagesForCata then return ham.getBandagesForCata() end
  if ham.isMop and ham.getBandagesForMists then return ham.getBandagesForMists() end
  if ham.isForever and ham.getBandagesForForever then return ham.getBandagesForForever() end

  -- Everything else (Retail, and any other flavor without a dedicated list) falls back to Retail's list
  if ham.getBandagesForRetail then return ham.getBandagesForRetail() end
  return {}
end

-- The spell the AutoBandage macro casts before the bandage, or nil when there's none: Rapid
-- Regeneration on Forever, while its option is ticked and the player knows it.
function ham.getBandageSpell()
  local spell = ham.rapidRegeneration
  if spell and ham.options.rapidRegenerationBandage and spell.isKnown() then return spell end
end
