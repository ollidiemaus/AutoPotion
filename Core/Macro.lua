local addonName, ham = ...
local env = ham.env

ham.macro = ham.macro or {}

local state = {
  name = "MegaMacro",
  retries = 0,
  checked = false,
  installed = false,
  loaded = false,
}

ham.macro.state = state
ham.macro.retryDelay = 3

function ham.macro.checkAddonReady()
  -- MegaMacro only exists on retail; consider non-retail as "checked"
  if not (env and env.isRetail) then
    state.checked = true
    return true
  end

  local addonNameInfo = C_AddOns.GetAddOnInfo(state.name)
  if not addonNameInfo then
    state.installed = false
    state.checked = true
    return true
  end

  state.installed = true

  if C_AddOns.IsAddOnLoaded(state.name) then
    state.loaded = true
    state.checked = true
    return true
  end

  if state.retries < 3 then
    state.retries = state.retries + 1
    ham.defer(ham.macro.retryDelay, ham.macro.checkAddonReady)
  else
    state.checked = true
  end
  return state.checked
end

local function ensureMacroExists(name)
  -- Don't try to create if MegaMacro is available; handled there
  local existing = GetMacroInfo(name)
  if not existing then
    pcall(function()
      CreateMacro(name, "INV_Misc_QuestionMark")
    end)
  end
end

local function applyViaMegaMacro(name, code)
  if not _G.MegaMacroGlobalData or not _G.MegaMacro then return false end
  for _, macro in pairs(MegaMacroGlobalData.Macros) do
    if macro.DisplayName == name then
      MegaMacro.UpdateCode(macro, code)
      return true
    end
  end
  print("|cffff0000AutoPotion Error:|r Missing global '" .. tostring(name) .. "' macro in MegaMacro. Please create it then reload your game.")
  return false
end

function ham.macro.apply(name, code)
  ham.macro.checkAddonReady()

  -- If MegaMacro is loaded and available, prefer it
  if state.installed and state.loaded then
    local ok = applyViaMegaMacro(name, code)
    if ok then return true end
    -- fall through to default macro if MegaMacro missing a global macro
  end

  -- Default in-game macro path
  ensureMacroExists(name)
  local success = pcall(function()
    EditMacro(name, name, nil, code)
  end)
  return success and true or false
end


