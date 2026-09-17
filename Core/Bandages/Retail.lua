---@diagnostic disable: undefined-global
local addonName, ham = ...

-- Include modern bandages first, then legacy in case they exist
function ham.getBandagesForRetail()
  return {
    ham.brightlinenBandageR2,
    ham.brightlinenBandageR1,
    ham.weaverclothBandageR3,
    ham.weaverclothBandageR2,
    ham.weaverclothBandageR1,
    ham.wilderclothBandageR3,
    ham.wilderclothBandageR2,
    ham.wilderclothBandageR1,
    ham.heavyShroudedClothBandage,
    ham.shroudedClothBandage,
    ham.deepSeaBandage,
    ham.tidesprayLinenBandage,
    ham.silkweaveSplint,
    ham.silkweaveBandage,
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
