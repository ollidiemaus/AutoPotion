local addonName, ham = ...

ham.Player = {}

ham.Player.new = function()
  local self = {}

  self.localizedClass, self.englishClass, self.classIndex = UnitClass("player");

  function self.getHealingItems()
      if self.englishClass=="ROGUE" then
        if HAMDB.crimsonVial then
          if IsSpellKnown(ham.crimsonVialSpell) then
            return "30", ham.Item.new(137222,"Crimson Vial")
          end
        end
      end
    return
  end

  --returns resetType, spellId
  function self.getHealingSpells()
      if self.englishClass=="DRUID" then
        if HAMDB.renewal then
          if IsSpellKnown(ham.crimsonVialSpell) then
            local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(ham.crimsonVialSpell)
            return "30", name
          end
        end
      end
      if self.englishClass=="DRUID" then
        if HAMDB.renewal then
          if IsSpellKnown(ham.renewal) then
            local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(ham.renewal)
            return "90", name
          end
        end
      end
    
      if self.englishClass=="HUNTER" then
        --NOTE: on GCD
        if HAMDB.exhilaration then
          if IsSpellKnown(ham.exhilaration) then
            local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(ham.exhilaration)
            return "120", name
          end
        end
      end
      if self.englishClass=="WARRIOR" then
        if HAMDB.bitterImmunity then
          if IsSpellKnown(ham.bitterImmunity) then
            local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(ham.bitterImmunity)
            return "180", name
          end
        end
      end
      if self.englishClass=="PRIEST" then
        if HAMDB.desperatePrayer then
          if IsSpellKnown(ham.desperatePrayer) then
            local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(ham.desperatePrayer)
            return "90", name
          end
        end
      end

    return
  end

  return self
end
