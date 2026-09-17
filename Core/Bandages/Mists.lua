---@diagnostic disable: undefined-global
local addonName, ham = ...

function ham.getBandagesForMists()
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
