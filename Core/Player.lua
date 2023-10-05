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

    for i, spell in ipairs(HAMDB.activatedSpells) do
      if IsSpellKnown(spell) then
        table.insert(spells, spell)
        --TODO HEALING Elixir Twice because it has two charges ?! kinda janky but will work for now
        if spell == ham.healingElixir then
          table.insert(spells, spell)
        end
      end
    end

    return spells
  end

  return self
end
