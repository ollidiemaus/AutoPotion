local addonName, ham = ...
ham.defaults = {
    cdReset = false,
    stopCast = false,
    raidStone = false,
    witheringPotion = false,
    witheringDreamsPotion = false,
    cavedwellerDelight = true,
    heartseekingInjector = false,
    -- ham.bitterImmunity is deliberately left out - it was removed outright in patch
    -- 12.0.0 with no replacement, and was never offered on any Classic flavor either, so
    -- there's no longer a checkbox anywhere for this default to correspond to.
    activatedSpells = { ham.recuperate.getId(), ham.crimsonVialSpell.getId(), ham.renewal.getId(),
        ham.exhilaration.getId(), ham.lastStand.getId(),
        ham.desperatePrayer.getId(), ham.healingElixir.getId(), ham.darkPact.getId(), ham.giftOfTheNaaruDK.getId(),
        ham.giftOfTheNaaruHunter.getId(), ham.giftOfTheNaaruMage.getId(), ham.giftOfTheNaaruMageWarlock.getId(),
        ham.giftOfTheNaaruMonk.getId(), ham.giftOfTheNaaruPaladin.getId(), ham.giftOfTheNaaruPriest.getId(),
        ham.giftOfTheNaaruRogue.getId(), ham.giftOfTheNaaruShaman.getId(), ham.giftOfTheNaaruWarrior.getId(),
        ham.bagOfTricks.getId() }
}

function ham.dbContains(id)
    local found = false
    for _, v in pairs(HAMDB.activatedSpells) do
        if v == id then
            found = true
        end
    end
    return found
end

function ham.removeFromDB(id)
    local backup = {}
    if ham.dbContains(id) then
        for _, v in pairs(HAMDB.activatedSpells) do
            if v ~= id then
                table.insert(backup, v)
            end
        end
    end

    HAMDB.activatedSpells = CopyTable(backup)
end

function ham.insertIntoDB(id)
    table.insert(HAMDB.activatedSpells, id)
end
