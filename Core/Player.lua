local addonName, ham = ...

ham.Player = {}

ham.Player.new = function()
  local self = {}

  self.localizedClass, self.englishClass, self.classIndex = UnitClass("player");

  function self.getHealingItems()
    return
  end

  function self.getHealingSpells()
    local spells = {}

    -------------  DK  -------------
    -------------  DH  -------------
    -------------  DRUID  -------------
    if HAMDB.renewal then
      if IsSpellKnown(ham.renewal) then
        table.insert(spells, ham.renewal)
      end
    end
    -------------  Evoker  -------------
    -------------  HUNTER  -------------
    --NOTE: on GCD
    if HAMDB.exhilaration then
      if IsSpellKnown(ham.exhilaration) then
        table.insert(spells, ham.exhilaration)
      end
    end
    if HAMDB.fortitudeOfTheBear then
      if IsSpellKnown(ham.fortitudeOfTheBear) then
        table.insert(spells, ham.fortitudeOfTheBear)
      end
    end
    -------------  MAGE  -------------
    -------------  MONK  -------------
    if HAMDB.expelHarm then
      if IsSpellKnown(ham.expelHarm) then
        table.insert(spells, ham.expelHarm)
      end
    end
    if HAMDB.healingElixir then
      if IsSpellKnown(ham.healingElixir) then
        --TODO Twice because it has two charges ?! kinda janky but will work for now
        table.insert(spells, ham.healingElixir)
        table.insert(spells, ham.healingElixir)
      end
    end
    -------------  PALADIN  -------------
    -------------  PRIEST  -------------
    if HAMDB.desperatePrayer then
      if IsSpellKnown(ham.desperatePrayer) then
        table.insert(spells, ham.desperatePrayer)
      end
    end
    -------------  ROGUE  -------------
    if self.englishClass == "ROGUE" then
      if HAMDB.crimsonVial then
        if IsSpellKnown(ham.crimsonVialSpell) then
          table.insert(spells, ham.crimsonVialSpell)
        end
      end
    end
    -------------  SHAMAN  -------------
    -------------  WARLOCK  -------------
    -------------  WARRIOR  -------------
    if HAMDB.bitterImmunity then
      if IsSpellKnown(ham.bitterImmunity) then
        table.insert(spells, ham.bitterImmunity)
      end
    end

    return spells
  end

  return self
end
