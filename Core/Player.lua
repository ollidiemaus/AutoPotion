local addonName, ham = ...

ham.Player = {}

ham.Player.new = function()
  local self = {}

  self.localizedClass, self.englishClass, self.classIndex = UnitClass("player");

  function self.getHealingItems()
    return
  end

  --returns table with Spellnames {"", ""}
  function self.getHealingSpells()
    local spells = {}

    if self.englishClass == "DRUID" then
      if HAMDB.renewal then
        if IsSpellKnown(ham.renewal) then
          local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(ham.renewal)
          table.insert(spells, name)
        end
      end
    end

    if self.englishClass == "HUNTER" then
      --NOTE: on GCD
      if HAMDB.exhilaration then
        if IsSpellKnown(ham.exhilaration) then
          local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(ham.exhilaration)
          table.insert(spells, name)
        end
      end
      if HAMDB.fortitudeOfTheBear then
        if IsSpellKnown(ham.fortitudeOfTheBear) then
          local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(ham.fortitudeOfTheBear)
          table.insert(spells, name)
        end
      end
    end

    if self.englishClass == "MONK" then
      if HAMDB.expelHarm then
        if IsSpellKnown(ham.expelHarm) then
          local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(ham.expelHarm)
          table.insert(spells, name)
        end
      end
      if HAMDB.healingElixir then
        if IsSpellKnown(ham.healingElixir) then
          local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(ham.healingElixir)
          --Twice because it has two charges ?!
          table.insert(spells, name)
          table.insert(spells, name)
        end
      end
    end

    if self.englishClass == "PRIEST" then
      if HAMDB.desperatePrayer then
        if IsSpellKnown(ham.desperatePrayer) then
          local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(ham.desperatePrayer)
          table.insert(spells, name)
        end
      end
    end

    if self.englishClass == "ROGUE" then
      if HAMDB.crimsonVial then
        if IsSpellKnown(ham.crimsonVialSpell) then
          local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(ham.crimsonVialSpell)
          table.insert(spells, name)
        end
      end
    end

    if self.englishClass == "WARRIOR" then
      if HAMDB.bitterImmunity then
        if IsSpellKnown(ham.bitterImmunity) then
          local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(ham.bitterImmunity)
          table.insert(spells, name)
        end
      end
    end

    return spells
  end

  return self
end
