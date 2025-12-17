local addonName, ham = ...
ham.defaults = {
    cdReset = false,
    stopCast = false,
    raidStone = false,
    witheringPotion = false,
    witheringDreamsPotion = false,
    cavedwellerDelight = true,
    heartseekingInjector = false,
    activatedSpells = { ham.recuperate.getId(), ham.crimsonVialSpell.getId(), ham.renewal.getId(),
        ham.exhilaration.getId(), ham.fortitudeOfTheBear.getId(), ham.lastStand.getId(), ham.bitterImmunity.getId(),
        ham.desperatePrayer.getId(), ham.healingElixir.getId(), ham.darkPact.getId(), ham.giftOfTheNaaruDK.getId(),
        ham.giftOfTheNaaruHunter.getId(), ham.giftOfTheNaaruMage.getId(), ham.giftOfTheNaaruMageWarlock.getId(),
        ham.giftOfTheNaaruMonk.getId(), ham.giftOfTheNaaruPaladin.getId(), ham.giftOfTheNaaruPriest.getId(),
        ham.giftOfTheNaaruRogue.getId(), ham.giftOfTheNaaruShaman.getId(), ham.giftOfTheNaaruWarrior.getId(),
        ham.bagOfTricks.getId() }
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
