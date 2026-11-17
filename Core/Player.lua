local addonName, ham = ...

ham.Player = {}

ham.Player.new = function()
  local self = {}

  self.localizedClass, self.englishClass, self.classIndex = UnitClass("player");

  function self.getHealingItems()
    local healingItems = {}
    return healingItems
  end

  -- Ids of every spell offered on this flavor (groups expanded to their members). Saved
  -- settings can still hold ids we've since stopped offering (e.g. Fortitude of the Bear,
  -- now a passive on retail); the user can't untick those any more, so skip them here.
  local function supportedIds()
    local ids = {}
    for _, spell in ipairs(ham.supportedSpells) do
      for _, member in ipairs(spell.isGroup and spell.members or { spell }) do
        ids[member.getId()] = true
      end
    end
    return ids
  end

  function self.getHealingSpells()
    local mySpells = {}
    local supported = supportedIds()
    for i, id in ipairs(ham.options.activatedSpells) do
      local currentSpell = ham.Spell.new(id)
      if supported[id] and currentSpell.isKnown() then
        table.insert(mySpells, currentSpell)
      end
    end
    return mySpells
  end

  -- The ticked mana spells the character knows, in the flavor's order (best restore first), not
  -- the order they were ticked. A group gives each ticked member the character knows.
  function self.getManaSpells()
    local mySpells = {}
    for _, spell in ipairs(ham.supportedManaSpells) do
      for _, member in ipairs(spell.isGroup and spell.members or { spell }) do
        if ham.dbContains(member.getId(), "activatedManaSpells") and member.isKnown() then
          table.insert(mySpells, member)
        end
      end
    end
    return mySpells
  end

  return self
end
