local L = LibStub("AceLocale-3.0"):GetLocale("AutoPotion")
local addonName, ham = ...
local macroName = L["AutoPotion"]
local bandageMacroName = L["AutoBandage"] or "AutoBandage"
local env = ham.env

-- Configuration options
-- Use in-memory options as HAMDB updates are not persisted instantly.
-- We'll also use lazy initialization to prevent early access issues.
function ham.refreshOptions()
  local src = HAMDB or ham.defaults or {}
  ham.options = {
    cdReset = not not src.cdReset,
    stopCast = not not src.stopCast,
    raidStone = not not src.raidStone,
    witheringPotion = not not src.witheringPotion,
    witheringDreamsPotion = not not src.witheringDreamsPotion,
    -- default true only when nil, but respect explicit false in DB
    cavedwellerDelight = (src.cavedwellerDelight == nil) and true or not not src.cavedwellerDelight,
    heartseekingInjector = not not src.heartseekingInjector,
  }
end

setmetatable(ham, {
  __index = function(t, k)
    if k == "options" then
      ham.refreshOptions()
      return ham.options
    end
  end
})

ham.debug = false
ham.tinkerSlot = nil
ham.myPlayer = ham.Player.new()

local spellsMacroString = ''
local itemsMacroString = ''
local macroStr = ''
local resetType = "combat"
local shortestCD = nil
local bagUpdates = false -- debounce watcher for BAG_UPDATE events
local debounceTime = 3   -- seconds
local combatRetry = 0    -- number of combat retries

-- Macro application handled in Core/Macro.lua via ham.macro

-- Slots to check for tinkers
-- As of 2024-10-27, only Head, Wrist and Guns can have tinkers.
local function getTinkerSlots()
  if ham.debug then
    return { ham.SLOT_HEAD, ham.SLOT_WRIST, ham.SLOT_RANGED, ham.SLOT_TRINKET2 }
  end
  return { ham.SLOT_HEAD, ham.SLOT_WRIST, ham.SLOT_RANGED }
end

local function log(message)
  if ham.debug then
    print("|cffb48ef9AutoPotion:|r " .. message)
  end
end

local function addPlayerHealingItemIfAvailable()
  if env and env.isRetail and ham.options.heartseekingInjector and ham.tinkerSlot then
    table.insert(ham.itemIdList, ham.SLOT_PREFIX .. ham.tinkerSlot)
  end
end

local function addHealthstoneIfAvailable()
  if env and (env.isClassic or env.isWrath or env.isCata or env.isMop) then
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
    log("Item: " .. tostring(value.getId()) .. " Count: " .. tostring(value.getCount()))
    if value.getCount() > 0 then
      table.insert(ham.itemIdList, value.getId())
      --we break because all Pots share a cd so we only want the highest healing one
      break;
    end
  end
end

function ham.updateHeals()
  shortestCD = nil
  ham.itemIdList = {}
  ham.spellIDs = ham.myPlayer.getHealingSpells()

  -- Priority 1: Add player items, including tinkers
  addPlayerHealingItemIfAvailable()

  -- Priority 2: Add Healthstone if NOT set to lower priority
  if not ham.options.raidStone then
    addHealthstoneIfAvailable()
  end

  -- Priority 3: Add Health Pots if available, and Heartseeking is NOT available or enabled
  if not ham.options.heartseekingInjector or not ham.tinkerSlot then
    addPotIfAvailable()
  end

  -- Priority 4: Add Cavedweller's Delight if enabled
  if ham.options.cavedwellerDelight then
    addPotIfAvailable(true)
  end

  -- Priority 5: Add Healthstone if set to lower priority
  if ham.options.raidStone then
    addHealthstoneIfAvailable()
  end
end

-- creation handled by ham.macro when applying default macro path

local function setShortestSpellCD(newSpell)
  if ham.options.cdReset then
    local cd = ham.getSpellBaseCooldownSeconds(newSpell)
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

local function buildSpellMacroString()
  spellsMacroString = ''
  if next(ham.spellIDs) ~= nil then
    local parts = {}
    for _, spell in ipairs(ham.spellIDs) do
      local name = ham.getSpellName(spell)
      setShortestSpellCD(spell)
      if spell == ham.healingElixir then
        table.insert(parts, name)
        table.insert(parts, name)
      else
        table.insert(parts, name)
      end
    end
    spellsMacroString = table.concat(parts, ", ")
  end
end

local function buildItemMacroString()
  itemsMacroString = ''
  if next(ham.itemIdList) ~= nil then
    local entries = {}
    for _, name in ipairs(ham.itemIdList) do
      table.insert(entries, ham.formatItemEntry(name))
    end
    itemsMacroString = table.concat(entries, ", ")
  end
end

-- removed legacy MegaMacro helpers in favor of Core/Macro.lua

-- Build bandage macro string (highest available bandage first)
function ham.buildBandageMacro()
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

-- check if player has the engineering tinker: Heartseeking Health Injector
function ham.checkTinker()
  if not (env and env.isRetail) then return end
  ham.tinkerSlot = nil -- always reset
  for _, slot in ipairs(getTinkerSlots()) do
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

function ham.buildMacro()
  -- returns the macro string only
  if next(ham.itemIdList) == nil and next(ham.spellIDs) == nil then
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
    macroStr = macroStr .. "/castsequence [@player] reset=" .. resetType .. " "
    if spellsMacroString ~= "" then
      macroStr = macroStr .. spellsMacroString
    end
    if spellsMacroString ~= "" and itemsMacroString ~= "" then
      macroStr = macroStr .. ", "
    end
    if itemsMacroString ~= "" then
      macroStr = macroStr .. itemsMacroString
    end
  end
  return macroStr
end

function ham.applyMacro(name, code)
  local ok = ham.macro and ham.macro.apply and ham.macro.apply(name, code)
  if ok then log('Macro updated.') end
end

-- Backward-compatible wrappers used by UI
function ham.updateMacro()
  local code = ham.buildMacro()
  ham.applyMacro(macroName, code)
end

function ham.updateBandageMacro()
  local bandageCode = ham.buildBandageMacro()
  ham.applyMacro(bandageMacroName, bandageCode)
end

local function MakeMacro()
  -- ensure MegaMacro readiness check runs (non-blocking on non-retail)
  if ham.macro and ham.macro.checkAddonReady then ham.macro.checkAddonReady() end

  -- retry if player is still in combat
  if InCombatLockdown() then
    if combatRetry < 4 then
      combatRetry = combatRetry + 1
      log("Player in combat. Retry attempt: " .. combatRetry)
      ham.defer(0.5, MakeMacro)
    else
      log("Failed to update macro after 4 attempts.")
    end
    return
  end

  -- safe to update macro
  combatRetry = 0
  ham.checkTinker()
  ham.updateHeals()
  ham.updateMacro()
  ham.updateBandageMacro()

  ham.settingsFrame:updatePrio()
  ham.settingsFrame:updateBandagePrio()
end

-- debounce handler for BAG_UPDATE events which can fire very rapidly
local function onBagUpdate()
  if bagUpdates then
    return
  end
  log("event: BAG_UPDATE")
  bagUpdates = true
  ham.defer(debounceTime, function()
    MakeMacro()
    bagUpdates = false
  end)
end

local updateFrame = CreateFrame("Frame")
updateFrame:RegisterEvent(ham.EVT_ADDON_LOADED)
updateFrame:RegisterEvent(ham.EVT_BAG_UPDATE)
updateFrame:RegisterEvent(ham.EVT_PLAYER_ENTERING_WORLD)
updateFrame:RegisterEvent(ham.EVT_PLAYER_EQUIPMENT_CHANGED)
if env and not env.isClassic then
  updateFrame:RegisterEvent(ham.EVT_TRAIT_CONFIG_UPDATED)
end
updateFrame:RegisterEvent(ham.EVT_PLAYER_REGEN_ENABLED)
updateFrame:RegisterEvent(ham.EVT_UNIT_PET)
updateFrame:SetScript("OnEvent", function(self, event, arg1, ...)
  -- when addon is loaded
  if event == ham.EVT_ADDON_LOADED and arg1 == addonName then
    updateFrame:UnregisterEvent(ham.EVT_ADDON_LOADED)
    log("event: ADDON_LOADED")
    MakeMacro()
    return
  end
  -- player is in combat, do nothing
  if InCombatLockdown() then
    return
  end
  -- bag update events
  if event == ham.EVT_BAG_UPDATE then
    onBagUpdate()
    -- on loading/reloading
  elseif event == ham.EVT_UNIT_PET then
    log("event: UNIT_PET")
    MakeMacro()
    -- when pet is called
  elseif event == ham.EVT_PLAYER_ENTERING_WORLD then
    log("event: PLAYER_ENTERING_WORLD")
    MakeMacro()
    -- on exiting combat
  elseif event == ham.EVT_PLAYER_REGEN_ENABLED then
    log("event: PLAYER_REGEN_ENABLED")
    -- Wait a second after combat ends to update the macro
    -- as the UI may still be cleaning up a protected state.
    ham.defer(0.5, MakeMacro)
    -- when talents change and classic is false
  elseif env and not env.isClassic and event == ham.EVT_TRAIT_CONFIG_UPDATED then
    log("event: TRAIT_CONFIG_UPDATED")
    MakeMacro()
    -- when player changes equipment
  elseif event == ham.EVT_PLAYER_EQUIPMENT_CHANGED then
    log("event: PLAYER_EQUIPMENT_CHANGED")
    MakeMacro()
  end
end)
