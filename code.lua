local L = LibStub("AceLocale-3.0"):GetLocale("AutoPotion")
local addonName, ham = ...
local macroName = L["AutoPotion"]
local bandageMacroName = L["AutoBandage"] or "AutoBandage"
local foodMacroName = L["AutoFood"] or "AutoFood"
local drinkMacroName = L["AutoDrink"] or "AutoDrink"
local manaPotionMacroName = L["AutoManaPotion"] or "AutoManaPotion"

local function isInInstancedPvP()
  if not ham.isRetail then return false end
  local inInstance, instanceType = IsInInstance()
  return inInstance and (instanceType == "pvp" or instanceType == "arena")
end
ham.isInInstancedPvP = isInInstancedPvP

ham.debug = false
ham.tinkerSlot = nil
ham.myPlayer = ham.Player.new()

local spellsMacroString = ''
local itemsMacroString = ''
local macroStr = ''
local resetType = "combat"
local shortestCD = nil
local megaMacroRetryTime = 3 -- seconds between MegaMacro checks

-- MegaMacro addon compatibility
local megaMacro = {
  name = "MegaMacro", -- the addon name
  retries = 0,        -- number of loaded checks to prevent infinite loop
  checked = false,    -- did we check for the addon?
  installed = false,  -- is the addon installed?
  loaded = false,     -- is the addon loaded?
}

-- Slots to check for tinkers
-- As of 2024-10-27, only Head, Wrist and Guns can have tinkers.
local TINKER_SLOTS = {
  1,  -- Head
  9,  -- Wrist
  18, -- Gun
}
-- in debug mode Trinket 2 counts too, so a trinket with a use effect can stand in for a tinker
local DEBUG_TINKER_SLOTS = { 1, 9, 18, 14 }

local function tinkerSlots()
  return ham.debug and DEBUG_TINKER_SLOTS or TINKER_SLOTS
end

local function isTinkerSlot(slot)
  for _, tinkerSlot in ipairs(tinkerSlots()) do
    if slot == tinkerSlot then return true end
  end
  return false
end

-- Takes a finished message; a caller that builds one from parts checks ham.debug first, so
-- logging builds no string while debug mode is off.
local function log(message)
  if ham.debug then
    print("|cffb48ef9AutoPotion:|r " .. message)
  end
end

local function addPlayerHealingItemIfAvailable()
  if ham.isRetail and ham.options.heartseekingInjector and ham.tinkerSlot then
    table.insert(ham.itemIdList, "slot:" .. ham.tinkerSlot)
  end
  for i, value in ipairs(ham.myPlayer.getHealingItems()) do
    if value.getCount() > 0 then
      table.insert(ham.itemIdList, value.getId())
      break;
    end
  end
end

local function addHealthstoneIfAvailable()
  if ham.isClassic == true or ham.isTBC == true or ham.isWrath == true or ham.isCata == true or ham.isMop == true or ham.isForever == true then
    for i, value in ipairs(ham.getHealthstonesClassic()) do
      if value.getCount() > 0 then
        table.insert(ham.itemIdList, value.getId())
        --we break because all Healthstones share a cd so we only want the highest healing one
        break;
      end
    end
  else
    if ham.healthstone.getCount() > 0 then
      table.insert(ham.itemIdList, ham.healthstone.getId())
    end
    if ham.demonicHealthstone.getCount() > 0 then
      table.insert(ham.itemIdList, ham.demonicHealthstone.getId())
      if ham.options.cdReset then
        if shortestCD == nil then
          shortestCD = 60
        end
        if 60 < shortestCD then
          shortestCD = 60
        end
      end
    end
  end
end

local function addPotIfAvailable(useDelightPots)
  log("Updating pot counts...")
  useDelightPots = useDelightPots or false
  local pots = useDelightPots and ham.getDelightPots() or ham.getPots()
  for i, value in ipairs(pots) do
    if ham.debug then log("Item: " .. tostring(value.getId()) .. " Count: " .. tostring(value.getCount())) end
    if value.getCount() > 0 then
      table.insert(ham.itemIdList, value.getId())
      --we break because all Pots share a cd so we only want the highest healing one
      break;
    end
  end
end

function ham.updateHeals()
  ham.itemIdList = {}
  --ham.spellIDs = ham.myPlayer.getHealingSpells()
  ham.mySpells = ham.myPlayer.getHealingSpells()

  -- Priority 1: Add player items, including tinkers
  addPlayerHealingItemIfAvailable()

  -- Priority 2: Add Healthstone if NOT set to lower priority
  if not ham.options.raidStone then
    addHealthstoneIfAvailable()
  end

  -- Priority 3: Add Health Pots (skip in instanced PvP - not allowed)
  if not isInInstancedPvP() then
    if not ham.options.heartseekingInjector or not ham.tinkerSlot then
      addPotIfAvailable()
    end

    -- Priority 4: Add Cavedweller's Delight if enabled
    if ham.options.cavedwellerDelight then
      addPotIfAvailable(true)
    end
  end

  -- Priority 5: Add Healthstone if set to lower priority
  if ham.options.raidStone then
    addHealthstoneIfAvailable()
  end
end

local function setShortestSpellCD(newSpell)
  if ham.options.cdReset then
    -- GetSpellBaseCooldown exists on every flavor (confirmed in-game on Forever), but can
    -- return nil for a spell id absent from the client's spell data
    local baseCd = GetSpellBaseCooldown(newSpell)
    if not baseCd then return end
    local cd = baseCd / 1000
    if shortestCD == nil then
      shortestCD = cd
    end
    if cd < shortestCD then
      shortestCD = cd
    end
  end
end

local function setResetType()
  if ham.options.cdReset == true and shortestCD ~= nil then
    resetType = "combat/" .. shortestCD
  else
    resetType = "combat"
  end
end

-- Spells that are only usable out of combat (Recuperate, the Earthen racial Quiet
-- Contemplation). They can't go in the castsequence, so they get their own [nocombat] line.
local function isOutOfCombatSpell(id)
  return id == ham.recuperate.getId() or id == ham.quietContemplation.getId()
end

-- The out-of-combat spell to put on the [nocombat] line, if any. Quiet Contemplation is
-- preferred since it also restores mana. Recuperate isn't allowed in instanced PvP.
local function getOutOfCombatSpell()
  if not ham.isRetail then return nil end
  if ham.dbContains(ham.quietContemplation.getId()) and ham.quietContemplation.isKnown() then
    return ham.quietContemplation
  end
  if not isInInstancedPvP() and ham.dbContains(ham.recuperate.getId()) and ham.recuperate.isKnown() then
    return ham.recuperate
  end
  return nil
end

local function buildSpellMacroString()
  spellsMacroString = ''

  if next(ham.mySpells) ~= nil then
    local spellCounter = 1
    for i, spell in ipairs(ham.mySpells) do
      local name = ''
      if isOutOfCombatSpell(spell.getId()) then
        --we don't want to add these because even though they are spells they are only usable out of combat
      else
        name = spell.getName();
        setShortestSpellCD(spell.getId())

        --TODO HEALING Elixir Twice because it has two charges ?! kinda janky but will work for now
        if spell.getId() == ham.healingElixir.getId() then
          name = spell.getName() .. ", " .. spell.getName()
        end
        if spellCounter == 1 then
          spellsMacroString = name;
        else
          spellsMacroString = spellsMacroString .. ", " .. name;
        end
        spellCounter = spellCounter + 1
      end
    end
  end
end

local function buildItemMacroString()
  if next(ham.itemIdList) ~= nil then
    for i, name in ipairs(ham.itemIdList) do
      local entry
      -- Check if the entry starts with "slot:" and extract the slot number
      if type(name) == "string" and name:match("^slot:") then
        entry = name:sub(6)               -- Extract everything after "slot:"
      else
        entry = "item:" .. tostring(name) -- Default to item ID formatting
      end
      -- Add the entry to the macro string
      if i == 1 then
        itemsMacroString = entry
      else
        itemsMacroString = itemsMacroString .. ", " .. entry
      end
    end
  end
end

-- Hands the text to the MegaMacro macro with this display name. Returns false when the player
-- hasn't created it.
local function updateMegaMacro(name, text)
  for _, macro in pairs(MegaMacroGlobalData.Macros) do
    if macro.DisplayName == name then
      MegaMacro.UpdateCode(macro, text)
      if ham.debug then log("MegaMacro updated (" .. name .. ") with: " .. text) end
      return true
    end
  end
  print("|cffff0000AutoPotion Error:|r Missing global '" ..
    tostring(name) .. "' macro in MegaMacro. Please create it then reload your game.")
  return false
end

local writtenText = {}   -- [macro name] = the text last written to it this session
local reportedFull = {}  -- [macro name] = true once the player was told it didn't fit

-- Retail and Forever list the limit in Constants.MacroConsts, the older clients in a global.
local function maxGeneralMacros()
  local consts = Constants and Constants.MacroConsts
  return consts and consts.MAX_ACCOUNT_MACROS or MAX_ACCOUNT_MACROS
end

-- Creates the macro unless the general macro slots are full; then it tells the player, once per
-- session for each macro, and returns false.
local function createMacro(name, text)
  if GetNumMacros() >= maxGeneralMacros() then
    if not reportedFull[name] then
      reportedFull[name] = true
      local message =
        L["Couldn't create the %s macro: your general macros are full. Delete one of them and it will be created."]
      print("|cffb48ef9AutoPotion:|r " .. format(message, name))
    end
    return false
  end
  CreateMacro(name, "INV_Misc_QuestionMark", text)
  return true
end

-- The one writer for all five macros, standard or MegaMacro-managed. Writing a macro makes the
-- action bars refresh, so it only writes text that differs from what it wrote last.
local function writeMacro(name, text)
  if megaMacro.installed and megaMacro.loaded then
    if writtenText[name] ~= text and updateMegaMacro(name, text) then writtenText[name] = text end
    return
  end
  if GetMacroInfo(name) == nil then
    if not createMacro(name, text) then return end
  elseif writtenText[name] ~= text then
    EditMacro(name, name, nil, text)
  else
    return
  end
  writtenText[name] = text
  if ham.debug then log(name .. " macro updated.") end
end

local function checkMegaMacroAddon()
  -- MegaMacro is only available for retail
  if not ham.isRetail then
    megaMacro.checked = true
    return
  end

  -- is MegaMacro installed?
  local name = C_AddOns.GetAddOnInfo(megaMacro.name)
  if not name then
    megaMacro.installed = false
    megaMacro.checked = true
    return
  end

  megaMacro.installed = true

  -- is the addon loaded?
  if C_AddOns.IsAddOnLoaded(megaMacro.name) then
    megaMacro.loaded = true
    megaMacro.checked = true
    return
  end

  -- Retry loading if not yet loaded
  if megaMacro.retries < 3 then
    megaMacro.retries = megaMacro.retries + 1
    C_Timer.After(megaMacroRetryTime, function()
      checkMegaMacroAddon()
      -- the macros wait for this check
      if megaMacro.checked then ham.requestMacroUpdate() end
    end)
  else
    megaMacro.checked = true
  end
end

-- Build bandage macro string (highest available bandage first)
local function buildBandageMacroString()
  local sequence = {}
  local bandages = ham.getBandages()
  for _, item in ipairs(bandages) do
    if item.getCount() > 0 then
      table.insert(sequence, "item:" .. tostring(item.getId()))
      break
    end
  end

  if #sequence == 0 then
    return "#showtooltip"
  end
  return "#showtooltip\n/use [@player] " .. sequence[1]
end

-- Build food macro string (highest available food first)
local function buildFoodMacroString()
  local sequence = {}
  local food = ham.getFood()
  for _, item in ipairs(food) do
    if item.getCount() > 0 then
      table.insert(sequence, "item:" .. tostring(item.getId()))
      break
    end
  end

  if #sequence == 0 then
    return "#showtooltip"
  end
  return "#showtooltip\n/use [@player] " .. sequence[1]
end

-- Build drink macro string (highest available drink first)
local function buildDrinkMacroString()
  local sequence = {}
  local drink = ham.getDrink()
  for _, item in ipairs(drink) do
    if item.getCount() > 0 then
      table.insert(sequence, "item:" .. tostring(item.getId()))
      break
    end
  end

  if #sequence == 0 then
    return "#showtooltip"
  end
  return "#showtooltip\n/use [@player] " .. sequence[1]
end

-- Build mana potion macro string (highest mana restore available first)
local function buildManaPotionMacroString()
  local sequence = {}
  local potions = ham.getManaPotions()
  for _, item in ipairs(potions) do
    if item.getCount() > 0 then
      table.insert(sequence, "item:" .. tostring(item.getId()))
      break
    end
  end

  if #sequence == 0 then
    return "#showtooltip"
  end
  return "#showtooltip\n/use " .. sequence[1]
end

-- Soulburn (Warlock talent) empowers the next Healthstone. It's off the GCD, so a leading
-- "/cast [combat] Soulburn" line fires in the same keypress as the castsequence step. It
-- can't live inside the castsequence itself: with no Soul Shard the sequence would get stuck.
local function shouldSoulburn()
  if not ham.isRetail or not ham.options.soulburn then return false end
  if ham.myPlayer.englishClass ~= "WARLOCK" then return false end
  -- talents are not always in the spellbook, so also check whether the player knows it
  -- (C_SpellBook.IsSpellKnown replaces the deprecated IsPlayerSpell; Retail only, see above)
  if not (ham.soulburn.isKnown()
      or C_SpellBook.IsSpellKnown(ham.soulburn.getId(), Enum.SpellBookSpellBank.Player)) then
    return false
  end
  -- only when a Healthstone is actually in the sequence, so no shards are burned without one
  for _, id in ipairs(ham.itemIdList) do
    if id == ham.healthstone.getId() or id == ham.demonicHealthstone.getId() then
      return true
    end
  end
  return false
end

-- check if player has the engineering tinker: Heartseeking Health Injector
function ham.checkTinker()
  if not ham.isRetail then return end
  ham.tinkerSlot = nil -- always reset
  for _, slot in ipairs(tinkerSlots()) do
    local itemID = GetInventoryItemID("player", slot)
    if itemID then
      local spellName, spellID = C_Item.GetItemSpell(itemID)
      if spellName then
        -- note: i'm not an engineer, so i use a trinket with a use effect for debugging.
        -- this is why the "Phylactery" reference exists if debugging is enabled --- phuze.
        -- note: Using "spellName" to find "Heartseeking" can only support English region.
        -- So I add spellID to support other region, e.g. Taiwan (TW), China (CN) and Korea (KR) --- Nephits
        if ham.debug then
          if spellName:find("Phylactery") or spellName:find("Heartseeking") or spellID == 452767 then
            ham.tinkerSlot = slot
          end
        else
          if spellName:find("Heartseeking") or spellID == 452767 then
            ham.tinkerSlot = slot
          end
        end
      end
    end
  end
end

function ham.updateMacro()
  --if next(ham.itemIdList) == nil and next(ham.spellIDs) == nil then
  if next(ham.itemIdList) == nil and next(ham.mySpells) == nil then
    macroStr = "#showtooltip"
    if ham.options.stopCast then
      macroStr = macroStr .. "\n/stopcasting \n"
    end
  else
    resetType = "combat"
    buildItemMacroString()
    buildSpellMacroString()
    setResetType()
    macroStr = "#showtooltip \n"
    if ham.options.stopCast then
      macroStr = macroStr .. "/stopcasting \n"
    end
    -- Recuperate / Quiet Contemplation: out-of-combat only
    -- this condition is needed because if not used the castsequence will use off gcd heals direclty after them
    local combatCondition = ''
    local outOfCombatSpell = getOutOfCombatSpell()
    if outOfCombatSpell then
      combatCondition = ',combat'
      macroStr = macroStr .. "/cast [nocombat] " .. outOfCombatSpell.getName() .. "\n"
    end

    local sequenceStr = "/castsequence [@player" .. combatCondition .. "] reset=" .. resetType .. " "
    if spellsMacroString ~= "" then
      sequenceStr = sequenceStr .. spellsMacroString
    end
    if spellsMacroString ~= "" and itemsMacroString ~= "" then
      sequenceStr = sequenceStr .. ", "
    end
    if itemsMacroString ~= "" then
      sequenceStr = sequenceStr .. itemsMacroString
    end

    -- Soulburn has to come before the castsequence so it is active when the Healthstone is used
    if shouldSoulburn() then
      local soulburnLine = "/cast [combat] " .. ham.soulburn.getName() .. "\n"
      -- standard macros are limited to 255 characters (MegaMacro allows more);
      -- rather drop Soulburn than break the whole macro
      if not (megaMacro.installed and megaMacro.loaded) and #(macroStr .. soulburnLine .. sequenceStr) > 255 then
        log("Macro too long, skipping Soulburn.")
      else
        macroStr = macroStr .. soulburnLine
      end
    end

    macroStr = macroStr .. sequenceStr
  end

  if not megaMacro.checked then
    log("MegaMacro not checked. Retrying.")
    checkMegaMacroAddon()
    return
  end

  writeMacro(macroName, macroStr)
end

function ham.updateBandageMacro()
  writeMacro(bandageMacroName, buildBandageMacroString())
end

function ham.updateFoodMacro()
  writeMacro(foodMacroName, buildFoodMacroString())
end

function ham.updateDrinkMacro()
  writeMacro(drinkMacroName, buildDrinkMacroString())
end

function ham.updateManaPotionMacro()
  writeMacro(manaPotionMacroName, buildManaPotionMacroString())
end

-- A hidden page's preview is left alone: its OnShow refreshes it when the player opens it.
local function isShown(page)
  return page.panel ~= nil and page.panel:IsVisible()
end

-- Works out the current priorities from the bags and shows them on the settings pages that are
-- open. It makes no protected calls, so it also runs in combat.
function ham.refreshPreviews()
  ham.checkTinker()
  ham.updateHeals()
  if isShown(ham.settingsFrame) then ham.settingsFrame:updatePrio() end
  if isShown(ham.bandageSettingsFrame) then ham.bandageSettingsFrame:updateBandagePrio() end
  if isShown(ham.foodSettingsFrame) then ham.foodSettingsFrame:updateFoodPrio() end
  if isShown(ham.drinkSettingsFrame) then ham.drinkSettingsFrame:updateDrinkPrio() end
  if isShown(ham.manaPotionSettingsFrame) then ham.manaPotionSettingsFrame:updateManaPotionPrio() end
end

local function rebuildMacros()
  ham.refreshPreviews()
  ham.updateMacro()
  ham.updateBandageMacro()
  ham.updateFoodMacro()
  ham.updateDrinkMacro()
  ham.updateManaPotionMacro()
end

local updatePending = false -- an update was requested and hasn't run yet
local flushArmed = false    -- a next-frame flush is waiting

-- Runs a pending update unless combat lockdown blocks it; PLAYER_REGEN_ENABLED runs it then.
local function flushMacroUpdate()
  if not updatePending or InCombatLockdown() then return end
  -- dont attempt to create macro until MegaMacro addon is checked; the check requests an update
  if not megaMacro.checked then
    log("MegaMacro not checked or loaded. Retrying.")
    checkMegaMacroAddon()
    if not megaMacro.checked then return end
  end
  updatePending = false
  rebuildMacros()
end

local function onNextFrame()
  flushArmed = false
  flushMacroUpdate()
end

-- The one way to get the macros rebuilt. Requests made in the same frame lead to one rebuild on
-- the next frame; a request made in combat waits until combat ends.
function ham.requestMacroUpdate()
  updatePending = true
  if flushArmed or InCombatLockdown() then return end
  flushArmed = true
  C_Timer.After(0, onNextFrame)
end

-- `message` is a constant, so it costs nothing while debug mode is off
local function requestOn(message)
  return function()
    log(message)
    ham.requestMacroUpdate()
  end
end

local eventHandlers = {
  ADDON_LOADED = function(self, name)
    if name ~= addonName then return end
    self:UnregisterEvent("ADDON_LOADED")
    log("event: ADDON_LOADED")
    ham.requestMacroUpdate()
  end,
  -- fires once a burst of BAG_UPDATEs has settled
  BAG_UPDATE_DELAYED = requestOn("event: BAG_UPDATE_DELAYED"),
  UNIT_PET = requestOn("event: UNIT_PET"),
  -- also on zoning: the instanced-PvP rules depend on the zone
  PLAYER_ENTERING_WORLD = requestOn("event: PLAYER_ENTERING_WORLD"),
  -- only a tinker slot can change what the macros use; a gear set fires this once per slot
  PLAYER_EQUIPMENT_CHANGED = function(_, slot)
    if isTinkerSlot(slot) then
      log("event: PLAYER_EQUIPMENT_CHANGED")
      ham.requestMacroUpdate()
    end
  end,
  TRAIT_CONFIG_UPDATED = requestOn("event: TRAIT_CONFIG_UPDATED"),
  -- run what was requested during combat
  PLAYER_REGEN_ENABLED = function()
    log("event: PLAYER_REGEN_ENABLED")
    flushMacroUpdate()
  end,
}

local updateFrame = CreateFrame("Frame")
updateFrame:RegisterEvent("ADDON_LOADED")
updateFrame:RegisterEvent("BAG_UPDATE_DELAYED")
updateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- tinkers are Retail content
if ham.isRetail then
  updateFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
end
-- talents (trait configs) can teach or remove healing spells; only clients that have them know
-- the event, and registering an unknown event is a Lua error
if C_EventUtils.IsEventValid("TRAIT_CONFIG_UPDATED") then
  updateFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
end
updateFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
-- only the player's own pet, not every group member's
updateFrame:RegisterUnitEvent("UNIT_PET", "player")
updateFrame:SetScript("OnEvent", function(self, event, ...)
  eventHandlers[event](self, ...)
end)
