---@diagnostic disable: undefined-global
local addonName, ham = ...

-- WoW Forever is based on Classic, starting from the same bandage list until beta testing shows otherwise.
function ham.getBandagesForForever()
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

  -- When inside a PvP instance, prioritize battleground-specific bandages
  local inInstance, instanceType = IsInInstance()
  if inInstance and instanceType == "pvp" then
    local mapId = C_Map.GetBestMapForUnit("player")
    -- Alterac Valley
    if mapId == ham.MAP_ID_ALTERAC_VALLEY then
      if ham.alteracHeavyRuneclothBandage.getCount() > 0 then
        table.insert(list, 1, ham.alteracHeavyRuneclothBandage)
      end
    end
    -- Warsong Gulch
    if mapId == ham.MAP_ID_WARSONG_GULCH then
      -- Highest to lowest: Runecloth > Mageweave > Silk
      if ham.wsgRuneclothBandage.getCount() > 0 then
        table.insert(list, 1, ham.wsgRuneclothBandage)
      elseif ham.wsgMageweaveBandage.getCount() > 0 then
        table.insert(list, 1, ham.wsgMageweaveBandage)
      elseif ham.wsgSilkBandage.getCount() > 0 then
        table.insert(list, 1, ham.wsgSilkBandage)
      end
    end
    -- Arathi Basin
    if mapId == ham.MAP_ID_ARATHI_BASIN then
      local faction = UnitFactionGroup("player")
      -- Build AB-specific priority (runecloth > mageweave > silk), faction first then neutral
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

  return list
end
