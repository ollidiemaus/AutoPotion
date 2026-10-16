-- Reads an addon's TOC the way the client does: metadata from the "## Key: Value" lines and
-- the files to load from the other lines, in order, with XML files replaced by the Lua files
-- their <Script file=...> and <Include file=...> elements name.
local Toc = {}

local function directoryOf(path)
  return path:match("^(.*)/[^/]*$") or "."
end

local function normalize(path)
  return (path:gsub("\\", "/"))
end

local function readFile(path)
  local file, err = io.open(path, "rb")
  if not file then error("can't read " .. path .. ": " .. tostring(err), 0) end
  local text = file:read("*a")
  file:close()
  return text
end

local function addXml(files, path)
  local xml = readFile(path):gsub("<!%-%-.-%-%->", "")
  local dir = directoryOf(path)
  for tag, file in xml:gmatch("<(%a+)%s+file%s*=%s*\"([^\"]+)\"") do
    local child = dir .. "/" .. normalize(file)
    if tag == "Script" then
      table.insert(files, child)
    elseif tag == "Include" then
      addXml(files, child)
    end
  end
end

-- Returns the files the client loads for the TOC at tocPath, and its metadata.
function Toc.read(tocPath)
  local dir = directoryOf(tocPath)
  local files, metadata = {}, {}
  for line in readFile(tocPath):gmatch("[^\r\n]+") do
    local key, value = line:match("^##%s*([^:]+):%s*(.-)%s*$")
    if key then
      metadata[key] = value
    elseif not line:match("^%s*#") and line:match("%S") then
      local path = dir .. "/" .. normalize(line:match("^%s*(.-)%s*$"))
      if path:lower():match("%.xml$") then
        addXml(files, path)
      else
        table.insert(files, path)
      end
    end
  end
  return files, metadata
end

return Toc
