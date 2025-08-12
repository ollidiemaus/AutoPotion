local addonName, ham = ...
local env = ham.env


ham.crimsonVialSpell = 185311
ham.renewal = 108238
ham.exhilaration = 109304
ham.fortitudeOfTheBear = 388035
ham.lastStand = 12975
ham.bitterImmunity = 383762
ham.desperatePrayer = 19236
ham.expelHarm = 322101
ham.healingElixir = 122281
ham.darkPact = 108416
ham.vampiricBlood = 55233

--Racials WTF These are all seperate Spells
ham.giftOfTheNaaruDK = 59545
ham.giftOfTheNaaruHunter = 59543
ham.giftOfTheNaaruMage = 59548
ham.giftOfTheNaaruMageWarlock = 416250
ham.giftOfTheNaaruMonk = 121093
ham.giftOfTheNaaruPaladin = 59542
ham.giftOfTheNaaruPriest = 59544
ham.giftOfTheNaaruRogue = 370626
ham.giftOfTheNaaruShaman = 59547
ham.giftOfTheNaaruWarrior = 28880

ham.bagOfTricks = 312411

ham.supportedSpells = {
  ham.crimsonVialSpell,
  ham.renewal,
  ham.exhilaration,
  ham.fortitudeOfTheBear,
  ham.lastStand,
  ham.bitterImmunity,
  ham.desperatePrayer,
  ham.expelHarm,
  ham.healingElixir,
  ham.darkPact,
  ham.vampiricBlood,
  ham.giftOfTheNaaruDK,
  ham.giftOfTheNaaruHunter,
  ham.giftOfTheNaaruMage,
  ham.giftOfTheNaaruMageWarlock,
  ham.giftOfTheNaaruMonk,
  ham.giftOfTheNaaruPaladin,
  ham.giftOfTheNaaruPriest,
  ham.giftOfTheNaaruRogue,
  ham.giftOfTheNaaruShaman,
  ham.giftOfTheNaaruWarrior,
  ham.bagOfTricks,
}


ham.Spell = {}

ham.Spell.new = function(id, name)
    local self = {}

    self.id = id
    self.name = name
    if env and env.isRetail == true then
        self.cd = C_Spell.GetSpellCooldown(id).duration
    else
        self.cd = GetSpellBaseCooldown(id)
    end


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

-- Return localized spell name for both retail and classic clients
function ham.getSpellName(spellId)
  if env and env.isRetail == true then
    return C_Spell.GetSpellName(spellId)
  else
    local name = GetSpellInfo(spellId)
    return name
  end
end

-- Return base cooldown in seconds (0 if none)
function ham.getSpellBaseCooldownSeconds(spellId)
  local ms = GetSpellBaseCooldown(spellId)
  if not ms or ms <= 0 then return 0 end
  return ms / 1000
end

-- Return spell icon texture id/path unified across clients
function ham.getSpellTexture(spellId)
  if env and env.isRetail == true then
    local iconTexture = C_Spell.GetSpellTexture(spellId)
    return iconTexture
  else
    return GetSpellTexture(spellId)
  end
end
