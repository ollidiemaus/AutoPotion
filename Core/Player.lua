Player = {}

Player.new = function()
  local self = {}

  self.localizedClass, self.englishClass, self.classIndex = UnitClass("player");
  
  function self.getHealingItems()
      if self.englishClass=="ROGUE" then
        if HAMDB.crimsonVial then
          local crimsonVialSpellId = 185311
          if IsSpellKnown(crimsonVialSpellId) then
            return "30", Item.new(137222,"Crimson Vial")
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