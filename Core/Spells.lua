local addonName, ham = ...

ham.crimsonVialSpell = 185311
ham.renewal = 108238
ham.exhilaration = 109304
ham.fortitudeOfTheBear = 272679
ham.bitterImmunity = 383762
ham.desperatePrayer = 19236
ham.expelHarm = 322101
ham.healingElixir = 122281

ham.supportedSpells = {}
table.insert(ham.supportedSpells, ham.crimsonVialSpell)
table.insert(ham.supportedSpells, ham.renewal)
table.insert(ham.supportedSpells, ham.exhilaration)
table.insert(ham.supportedSpells, ham.fortitudeOfTheBear)
table.insert(ham.supportedSpells, ham.bitterImmunity)
table.insert(ham.supportedSpells, ham.desperatePrayer)
table.insert(ham.supportedSpells, ham.expelHarm)
table.insert(ham.supportedSpells, ham.healingElixir)

ham.Spell = {}

ham.Spell.new = function(id, name)
    local self = {}

    self.id = id
    self.name = name
    self.cd = GetSpellBaseCooldown(id)

    function self.getId()
        return self.id
    end

    function self.getName()
        return self.name
    end

    function self.getCd()
        return self.cd
    end

    return self
end
