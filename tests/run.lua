-- Runs AutoPotion's tests: every tests/*_test.lua, or the test files given as arguments. Prints
-- each failing test with its reason and a summary, and exits non-zero when one failed.
-- Start it with tests/run.sh, which checks for LuaJIT and runs it from the repo root.
package.path = "tests/?.lua;" .. package.path

local tests = {}
local currentFile

-- Test files call test(name, fn); fn fails by raising an error (assertEqual does that).
function test(name, fn)
  table.insert(tests, { name = name, fn = fn, file = currentFile })
end

local function show(value, indent)
  indent = indent or ""
  if type(value) == "string" then return string.format("%q", value) end
  if type(value) ~= "table" then return tostring(value) end
  local keys = {}
  for key in pairs(value) do table.insert(keys, key) end
  if #keys == 0 then return "{}" end
  table.sort(keys, function(a, b)
    if type(a) == type(b) and (type(a) == "number" or type(a) == "string") then return a < b end
    return type(a) < type(b)
  end)
  local lines = {}
  for _, key in ipairs(keys) do
    local label = type(key) == "string" and key or "[" .. tostring(key) .. "]"
    table.insert(lines, indent .. "  " .. label .. " = " .. show(value[key], indent .. "  "))
  end
  return "{\n" .. table.concat(lines, ",\n") .. "\n" .. indent .. "}"
end

-- Fails the test unless actual and expected are equal, tables compared by content.
function assertEqual(actual, expected, message)
  local shownActual, shownExpected = show(actual), show(expected)
  if shownActual ~= shownExpected then
    error((message and message .. "\n" or "") .. "expected: " .. shownExpected .. "\n  actual: " .. shownActual, 2)
  end
end

local files = { ... }
if #files == 0 then
  local list = io.popen("ls tests/*_test.lua")
  for path in list:lines() do table.insert(files, path) end
  list:close()
end

for _, path in ipairs(files) do
  currentFile = path
  local chunk, err = loadfile(path)
  if not chunk then
    table.insert(tests, { name = "load " .. path, file = path, fn = function() error(err, 0) end })
  else
    chunk()
  end
end

local failed = 0
for _, t in ipairs(tests) do
  local ok, err = xpcall(t.fn, debug.traceback)
  if not ok then
    failed = failed + 1
    print("FAIL " .. t.file .. ": " .. t.name .. "\n  " .. tostring(err):gsub("\n", "\n  ") .. "\n")
  end
end

print(string.format("%d passed, %d failed", #tests - failed, failed))
os.exit(failed == 0 and 0 or 1)
