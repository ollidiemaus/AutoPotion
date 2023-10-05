local addonName, ham = ...

ham.crimsonVialSpell = 185311
ham.renewal = 108238
ham.exhilaration = 109304
ham.fortitudeOfTheBear = 272679
ham.bitterImmunity = 383762
ham.desperatePrayer = 19236
ham.expelHarm = 322101
ham.healingElixir = 122281

ham.Spell = {}

ham.Spell.new = function(id, name, cd)
    local self = {}

    self.id = id
    self.name = name
    self.cd = cd

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
