local addonName, ham = ...
ham.defaults = {
    cdReset = false,
    stopCast = false,
    raidStone = false,
    witheringPotion = false,
    witheringDreamsPotion = false,
    cavedwellerDelight = true,
    heartseekingInjector = false,
    activatedSpells = { ham.crimsonVialSpell, ham.renewal, ham.exhilaration, ham.fortitudeOfTheBear, ham.lastStand, ham
        .bitterImmunity,
        ham.desperatePrayer, ham.healingElixir, ham.darkPact, ham.giftOfTheNaaruDK, ham.giftOfTheNaaruHunter, ham
        .giftOfTheNaaruMage,
        ham.giftOfTheNaaruMageWarlock, ham.giftOfTheNaaruMonk, ham.giftOfTheNaaruPaladin, ham.giftOfTheNaaruPriest, ham
        .giftOfTheNaaruRogue, ham.giftOfTheNaaruShaman, ham.giftOfTheNaaruWarrior, ham.bagOfTricks }
}


function ham.dbContains(id)
    if not HAMDB or not HAMDB.activatedSpells then return false end
    for _, v in ipairs(HAMDB.activatedSpells) do
        if v == id then
            return true
        end
    end
    return false
end

function ham.removeFromDB(id)
    if not HAMDB or not HAMDB.activatedSpells then return end
    for i = #HAMDB.activatedSpells, 1, -1 do
        if HAMDB.activatedSpells[i] == id then
            table.remove(HAMDB.activatedSpells, i)
        end
    end
end

function ham.insertIntoDB(id)
    if not HAMDB then return end
    HAMDB.activatedSpells = HAMDB.activatedSpells or {}
    if not ham.dbContains(id) then
        table.insert(HAMDB.activatedSpells, id)
    end
end
