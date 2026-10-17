-- Frames, textures and font strings with the methods AutoPotion's code calls (plus the getters a
-- test reads what the player sees with), and the Blizzard templates its settings pages inherit. A method the fake doesn't have fails the way an unknown
-- method fails in game, so a gap shows up as an error instead of passing silently.
--
-- A widget keeps its fake-client state under [0], where the game keeps its userdata, so addon
-- code can set any string key on it (frame.texture, panel.name, ...).
local Widgets = {}

local Region, Frame, Button, CheckButton, ScrollFrame, EditBox, Slider, Tooltip, Texture, FontString, Font =
  {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}

local function defineClass(class, parent, objectType)
  class.objectType = objectType
  class.parentClass = parent
  class.meta = { __index = class }
  if parent then setmetatable(class, { __index = parent }) end
end
defineClass(Region, nil, "Region")
defineClass(Frame, Region, "Frame")
defineClass(Button, Frame, "Button")
defineClass(CheckButton, Button, "CheckButton")
defineClass(ScrollFrame, Frame, "ScrollFrame")
defineClass(EditBox, Frame, "EditBox")
defineClass(Slider, Frame, "Slider")
defineClass(Tooltip, Frame, "GameTooltip")
defineClass(Texture, Region, "Texture")
defineClass(FontString, Region, "FontString")
defineClass(Font, nil, "Font")

local frameClasses = {
  frame = Frame, button = Button, checkbutton = CheckButton, scrollframe = ScrollFrame,
  editbox = EditBox, slider = Slider, gametooltip = Tooltip,
}

local FRAME_SCRIPTS = {
  "OnEvent", "OnShow", "OnHide", "OnUpdate", "OnEnter", "OnLeave", "OnMouseDown", "OnMouseUp",
  "OnMouseWheel", "OnSizeChanged", "OnLoad", "OnDragStart", "OnDragStop", "OnReceiveDrag",
  "OnKeyDown", "OnKeyUp", "OnAttributeChanged",
}
local scriptsByClass = {
  [Frame] = FRAME_SCRIPTS,
  [Button] = { "OnClick", "PreClick", "PostClick", "OnDoubleClick" },
  [ScrollFrame] = { "OnScrollRangeChanged", "OnVerticalScroll", "OnHorizontalScroll" },
  [EditBox] = {
    "OnEditFocusGained", "OnEditFocusLost", "OnTextChanged", "OnEscapePressed", "OnEnterPressed",
    "OnTabPressed", "OnChar", "OnCursorChanged",
  },
  [Slider] = { "OnValueChanged", "OnMinMaxChanged" },
  [Tooltip] = { "OnTooltipSetItem", "OnTooltipSetSpell", "OnTooltipCleared" },
}

local function hasScript(class, script)
  while class do
    for _, name in ipairs(scriptsByClass[class] or {}) do
      if name == script then return true end
    end
    class = class.parentClass
  end
  return false
end

local POINTS = {
  TOPLEFT = true, TOP = true, TOPRIGHT = true, LEFT = true, CENTER = true, RIGHT = true,
  BOTTOMLEFT = true, BOTTOM = true, BOTTOMRIGHT = true,
}

-- "$parent" in a template child's name stands for its parent's name; under an unnamed parent the
-- child is unnamed too.
local function resolveName(name, parent)
  if type(name) ~= "string" or not name:find("$parent", 1, true) then return name end
  local parentName = parent and parent[0].name
  if not parentName then return nil end
  return (name:gsub("%$parent", parentName))
end

local function newWidget(client, class, name, parent)
  local widget = setmetatable({}, class.meta)
  widget[0] = {
    client = client, class = class, name = name, parent = parent, shown = true,
    points = {}, width = 0, height = 0, children = {}, textures = {}, scripts = {}, hooks = {}, events = {},
  }
  if name then client.env[name] = widget end
  return widget
end

-- Runs a widget's script handler and then its hooks, each through the client's error handler.
function Widgets.runScript(frame, script, ...)
  local state = frame[0]
  if state.scripts[script] then state.client:call(state.scripts[script], frame, ...) end
  for _, hook in ipairs(state.hooks[script] or {}) do
    state.client:call(hook, frame, ...)
  end
end
local runScript = Widgets.runScript

-- The order the frame registered for the event in, or nil when it isn't registered.
function Widgets.registrationOrder(frame, event) return frame[0].events[event] end

function Widgets.hasHandler(frame, script)
  return frame[0].scripts[script] ~= nil or frame[0].hooks[script] ~= nil
end

local function stateOf(value)
  return type(value) == "table" and type(rawget(value, 0)) == "table" and value[0] or nil
end

function Widgets.isWidget(value)
  local state = stateOf(value)
  return state ~= nil and state.class ~= Font
end

function Widgets.isFont(value)
  local state = stateOf(value)
  return state ~= nil and state.class == Font
end

-- Region: everything with a parent, a position and a size ---------------------------------

function Region:GetObjectType() return self[0].class.objectType end

function Region:IsObjectType(objectType)
  local class = self[0].class
  while class do
    if class.objectType == objectType then return true end
    class = class.parentClass
  end
  return false
end

function Region:GetName() return self[0].name end
function Region:GetParent() return self[0].parent end

function Region:IsShown() return self[0].shown end

function Region:IsVisible()
  local state = self[0]
  return state.shown and (state.parent == nil or state.parent:IsVisible())
end

function Region:Show() self[0].shown = true end
function Region:Hide() self[0].shown = false end

function Region:SetShown(shown)
  if shown then self:Show() else self:Hide() end
end

function Region:SetPoint(point, ...)
  if not POINTS[point] then error("SetPoint: invalid anchor point " .. tostring(point), 2) end
  local relativeTo, relativePoint, x, y
  local a1, a2, a3, a4 = ...
  if type(a1) == "number" then
    x, y = a1, a2
  elseif select("#", ...) > 0 then
    relativeTo = a1
    if type(a2) == "number" then
      x, y = a2, a3
    else
      relativePoint, x, y = a2, a3, a4
    end
  end
  if type(relativeTo) == "string" then relativeTo = self[0].client.env[relativeTo] end
  if relativeTo == nil then relativeTo = self[0].parent end
  if relativeTo == self then error("SetPoint: a region can't be anchored to itself", 2) end
  local anchor = { point = point, relativeTo = relativeTo, relativePoint = relativePoint or point, x = x or 0, y = y or 0 }
  local points = self[0].points
  for i, existing in ipairs(points) do
    if existing.point == point then
      points[i] = anchor
      return
    end
  end
  table.insert(points, anchor)
end

function Region:SetAllPoints(relativeTo)
  self:ClearAllPoints()
  self:SetPoint("TOPLEFT", relativeTo or self[0].parent, "TOPLEFT", 0, 0)
  self:SetPoint("BOTTOMRIGHT", relativeTo or self[0].parent, "BOTTOMRIGHT", 0, 0)
end

function Region:ClearAllPoints() self[0].points = {} end

function Region:SetSize(width, height)
  self[0].width, self[0].height = width, height or width
end
function Region:SetWidth(width) self[0].width = width end
function Region:SetHeight(height) self[0].height = height end

-- The fake client doesn't lay frames out on a screen: edges are unknown, as in game for a
-- region that hasn't been drawn yet.
function Region:GetTop() return nil end
function Region:GetBottom() return nil end

function Region:SetParent(parent)
  if type(parent) == "string" then parent = self[0].client.env[parent] end
  self[0].parent = parent
end

-- Frame --------------------------------------------------------------------------------------

-- Applies a change to shown flags or parents, then fires OnShow/OnHide on every frame below
-- `frame` whose visibility it changed, the way the game does when a parent is shown or hidden.
local function changeVisibility(frame, change)
  local frames = {}
  local function collect(f)
    table.insert(frames, f)
    for _, child in ipairs(f[0].children) do collect(child) end
  end
  collect(frame)
  local before = {}
  for i, f in ipairs(frames) do before[i] = f:IsVisible() end
  change()
  for i, f in ipairs(frames) do
    local now = f:IsVisible()
    if now ~= before[i] then runScript(f, now and "OnShow" or "OnHide") end
  end
end

function Frame:Show() changeVisibility(self, function() Region.Show(self) end) end
function Frame:Hide() changeVisibility(self, function() Region.Hide(self) end) end

function Frame:SetParent(parent)
  local oldParent = self[0].parent
  changeVisibility(self, function()
    if oldParent then
      local siblings = oldParent[0].children
      for i, child in ipairs(siblings) do
        if child == self then table.remove(siblings, i) break end
      end
    end
    Region.SetParent(self, parent)
    if self[0].parent then table.insert(self[0].parent[0].children, self) end
  end)
end

local function checkScript(frame, method, script)
  if not hasScript(frame[0].class, script) then
    error(frame:GetObjectType() .. ":" .. method .. '(): doesn\'t have a "' .. tostring(script) .. '" script', 3)
  end
end

function Frame:SetScript(script, handler)
  checkScript(self, "SetScript", script)
  -- like the game, setting a handler drops the hooks on it
  self[0].scripts[script] = handler
  self[0].hooks[script] = nil
end

function Frame:HookScript(script, hook)
  checkScript(self, "HookScript", script)
  local hooks = self[0].hooks
  hooks[script] = hooks[script] or {}
  table.insert(hooks[script], hook)
end

function Frame:RegisterEvent(event)
  self[0].events[event] = self[0].client:nextOrder()
  return true
end

function Frame:UnregisterEvent(event) self[0].events[event] = nil end

function Frame:CreateTexture(name, layer)
  local texture = newWidget(self[0].client, Texture, resolveName(name, self), self)
  texture[0].layer = layer
  table.insert(self[0].textures, texture)
  return texture
end

function Frame:CreateFontString(name, layer, fontObject)
  local client = self[0].client
  if fontObject ~= nil and not Widgets.isFont(client.env[fontObject]) then
    error('CreateFontString: Couldn\'t find inherited node "' .. tostring(fontObject) .. '"', 2)
  end
  local fontString = newWidget(client, FontString, resolveName(name, self), self)
  fontString[0].layer = layer
  fontString[0].fontObject = fontObject
  return fontString
end

function Frame:SetFrameStrata(strata) self[0].strata = strata end
function Frame:SetID(id) self[0].id = id end
function Frame:GetID() return self[0].id or 0 end
function Frame:EnableMouseWheel(enable) self[0].mouseWheel = enable end
function Frame:SetHitRectInsets(left, right, top, bottom) self[0].hitRectInsets = { left, right, top, bottom } end

-- Button -------------------------------------------------------------------------------------

function Button:SetFontString(fontString) self[0].fontString = fontString end
function Button:GetFontString() return self[0].fontString end

function Button:SetText(text)
  if not self[0].fontString then self[0].fontString = self:CreateFontString(nil, "ARTWORK") end
  self[0].fontString:SetText(text)
end

function Button:GetText()
  return self[0].fontString and self[0].fontString:GetText()
end

-- CheckButton --------------------------------------------------------------------------------

function CheckButton:SetChecked(checked) self[0].checked = checked and true or false end
function CheckButton:GetChecked() return self[0].checked or false end

-- The text next to the box, what the player reads it by: the template's label, wherever the
-- addon moved it.
function Widgets.checkboxLabel(button)
  return button[0].label and button[0].label:GetText()
end

-- A left click as the player makes it: a check button toggles before its OnClick runs.
function Widgets.click(button)
  if button:IsObjectType("CheckButton") then button:SetChecked(not button:GetChecked()) end
  runScript(button, "OnClick", "LeftButton", false)
end

-- Every frame below `frame`, in creation order.
function Widgets.descendants(frame)
  local result = {}
  local function collect(f)
    for _, child in ipairs(f[0].children) do
      table.insert(result, child)
      collect(child)
    end
  end
  collect(frame)
  return result
end

-- The textures created on `frame`, in creation order.
function Widgets.textures(frame) return frame[0].textures end

-- ScrollFrame --------------------------------------------------------------------------------

function ScrollFrame:SetScrollChild(child)
  self[0].scrollChild = child
  child:SetParent(self)
end
function ScrollFrame:SetVerticalScroll(offset) self[0].verticalScroll = offset end
function ScrollFrame:GetVerticalScroll() return self[0].verticalScroll or 0 end
function ScrollFrame:GetVerticalScrollRange() return 0 end

-- EditBox ------------------------------------------------------------------------------------

function EditBox:SetText(text) self[0].text = tostring(text or "") end
function EditBox:GetText() return self[0].text or "" end
function EditBox:SetAutoFocus(autoFocus) self[0].autoFocus = autoFocus end
function EditBox:SetFontObject(font) self[0].fontObject = font end
function EditBox:SetCursorPosition(position) self[0].cursor = position end
function EditBox:HighlightText(from, to) self[0].highlight = { from, to } end

-- GameTooltip: records what it was asked to show ---------------------------------------------

function Tooltip:SetOwner(owner, anchor)
  self[0].owner, self[0].anchor, self[0].lines = owner, anchor, {}
end

local function addTooltipLine(tooltip, line)
  tooltip[0].lines = tooltip[0].lines or {}
  table.insert(tooltip[0].lines, line)
end
function Tooltip:SetText(text) self[0].lines = { tostring(text) } end
function Tooltip:AddLine(text) addTooltipLine(self, tostring(text)) end
function Tooltip:SetSpellByID(spellId) addTooltipLine(self, "spell:" .. tostring(spellId)) end
function Tooltip:SetItemByID(itemId) addTooltipLine(self, "item:" .. tostring(itemId)) end
function Tooltip:SetInventoryItem(unit, slot) addTooltipLine(self, unit .. ":slot:" .. tostring(slot)) end

-- Texture ------------------------------------------------------------------------------------

function Texture:SetTexture(texture) self[0].texture = texture end
function Texture:GetTexture() return self[0].texture end
function Texture:SetColorTexture(r, g, b, a) self[0].texture, self[0].color = nil, { r, g, b, a } end
function Texture:SetTexCoord(...) self[0].texCoord = { ... } end

-- FontString ---------------------------------------------------------------------------------

function FontString:SetText(text)
  if text == nil then self[0].text = nil else self[0].text = tostring(text) end
end
function FontString:GetText() return self[0].text end
-- no fonts to measure with: about 6 pixels a character
function FontString:GetStringWidth() return #(self[0].text or "") * 6 end
function FontString:SetJustifyH(justify) self[0].justifyH = justify end
function FontString:SetFontObject(font) self[0].fontObject = font end

-- Font objects -------------------------------------------------------------------------------

function Font:GetName() return self[0].name end

local FONT_OBJECTS = {
  "GameFontNormal", "GameFontNormalSmall", "GameFontNormalLarge", "GameFontNormalHuge",
  "GameFontHighlight", "GameFontHighlightSmall", "GameFontHighlightLarge",
  "GameFontDisable", "GameFontDisableSmall", "ChatFontNormal",
}

-- Templates ----------------------------------------------------------------------------------

local function checkButtonTemplate(button)
  button.Text = button:CreateFontString("$parentText", "ARTWORK", "GameFontNormalSmall")
  button[0].label = button.Text
end

local templates = {
  UICheckButtonTemplate = checkButtonTemplate,
  OptionsBaseCheckButtonTemplate = checkButtonTemplate,
  InterfaceOptionsCheckButtonTemplate = checkButtonTemplate,
  UIPanelButtonTemplate = function(button)
    button.Text = button:CreateFontString("$parentText", "ARTWORK", "GameFontNormal")
    button:SetFontString(button.Text)
  end,
  -- named children: the classic scroll bar code finds its buttons by name
  UIPanelScrollFrameTemplate = function(scrollFrame, client)
    local scrollBar = Widgets.CreateFrame(client, "Slider", "$parentScrollBar", scrollFrame)
    scrollBar.ScrollUpButton = Widgets.CreateFrame(client, "Button", "$parentScrollUpButton", scrollBar)
    scrollBar.ScrollDownButton = Widgets.CreateFrame(client, "Button", "$parentScrollDownButton", scrollBar)
    scrollFrame.ScrollBar = scrollBar
  end,
  InputBoxTemplate = function(editBox)
    editBox.Left = editBox:CreateTexture(nil, "BACKGROUND")
    editBox.Right = editBox:CreateTexture(nil, "BACKGROUND")
    editBox.Middle = editBox:CreateTexture(nil, "BACKGROUND")
  end,
}

function Widgets.CreateFrame(client, frameType, name, parent, template, id)
  local class = frameClasses[tostring(frameType):lower()]
  if not class then error("CreateFrame: Unknown frame type '" .. tostring(frameType) .. "'", 3) end
  if type(parent) == "string" then parent = client.env[parent] end
  local frame = newWidget(client, class, resolveName(name, parent), parent)
  if parent then table.insert(parent[0].children, frame) end
  if id then frame:SetID(id) end
  table.insert(client.frames, frame)
  -- AutoPotion's preview icons pass UIParent as the template and the game accepts that, so
  -- anything but a string is ignored
  if type(template) == "string" then
    for templateName in template:gmatch("[^,%s]+") do
      local apply = templates[templateName]
      if not apply then error('CreateFrame: Couldn\'t find inherited node "' .. templateName .. '"', 3) end
      apply(frame, client)
    end
  end
  return frame
end

-- Adds the frames and font objects every client has before any addon loads.
function Widgets.install(client, env)
  env.CreateFrame = function(...) return Widgets.CreateFrame(client, ...) end
  for _, name in ipairs(FONT_OBJECTS) do
    env[name] = setmetatable({ [0] = { class = Font, name = name } }, Font.meta)
  end
  env.UIParent = Widgets.CreateFrame(client, "Frame", "UIParent")
  env.GameTooltip = Widgets.CreateFrame(client, "GameTooltip", "GameTooltip", env.UIParent)
  env.GameTooltip:Hide()
end

return Widgets
