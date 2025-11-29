local M = {}

-- Base alternate map (only define forward mappings)
local base_alternate_map = {
  h = { "c", "cpp", "gen.cpp" },
  hpp = { "cpp" },
  ridl = { "h", "cpp", "gen.cpp" },
  js = { "spec.js", "test.js" },
  jsx = { "spec.jsx", "test.jsx" },
  ts = { "spec.ts", "test.ts" },
  tsx = { "spec.tsx", "test.tsx" },
}

-- Function to preprocess the map and make it symmetrical
local function make_symmetrical(map)
  local symmetrical_map = {}
  for key, values in pairs(map) do
    symmetrical_map[key] = values
    for _, value in ipairs(values) do
      symmetrical_map[value] = symmetrical_map[value] or {}

      if not vim.tbl_contains(symmetrical_map[value], key) then
        table.insert(symmetrical_map[value], key)
      end
    end
  end
  return symmetrical_map
end

-- Preprocessed symmetrical alternate map
local alternate_map = make_symmetrical(base_alternate_map)

-- Helper function to format alternates as a string
local function format_alternates(alternates)
  return "{" .. table.concat(alternates, ",") .. "}"
end

function M.get_alternate_pattern(file)
  local root = file:match "[^.]+"
  local ext = file:gsub(root .. ".", "", 1)
  local alternates = alternate_map[ext]
  if not alternates then
    return ""
  end
  return root .. "." .. format_alternates(alternates)
end

function M.find_alternate()
  local alternates = M.get_alternate_pattern(vim.fn.expand "%:t")
  if alternates == "" then
    vim.notify("No alternates found for the current file", vim.log.levels.WARN)
    return
  end

  Snacks.picker.files { cmd = "fd", args = { "-g", alternates }, auto_confirm = true }
end

-- debugging section

local debug = false

local function debug_alternate_map()
  if not debug then
    return
  end
  local map_as_string = vim.inspect(alternate_map)
  vim.notify(map_as_string, vim.log.levels.INFO)
end

debug_alternate_map()
-- end of debugging

return M
