local addonName, ham = ...

ham.Player = {}

ham.Player.new = function()
  local self = {}

  self.localizedClass, self.englishClass, self.classIndex = UnitClass("player");

  function self.getHealingSpells()
    local spells = {}
    local activated = (type(HAMDB) == "table" and HAMDB.activatedSpells)
        or (ham.defaults and ham.defaults.activatedSpells)
        or {}
    for i, spell in ipairs(activated) do
      if IsSpellKnown(spell) or IsSpellKnown(spell, true) then
        table.insert(spells, spell)
      end
    end
    return mySpells
  end

  return self
end
