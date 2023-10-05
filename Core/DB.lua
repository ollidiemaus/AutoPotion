local addonName, ham = ...
ham.defaults = {
    cdReset = false,
    witheringPotion = false,
    activatedSpells = { ham.renewal, ham.exhilaration, ham.fortitudeOfTheBear, ham.bitterImmunity, ham.desperatePrayer,
        ham.healingElixir }
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
