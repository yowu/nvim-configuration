local M = {}

local uv = vim.uv or vim.loop

-- Mapping of ctags kind abbreviations to full names
local KIND_ABBR_TO_NAME = {
  c = "class",
  d = "macro",
  e = "enumerator",
  f = "function",
  g = "enum",
  l = "local",
  m = "member",
  n = "namespace",
  p = "prototype",
  s = "struct",
  t = "typedef",
  u = "union",
  v = "variable",
  x = "external",
  C = "constant",
  E = "event",
  F = "field",
  M = "method",
  P = "property",
  i = "interface",
}

-- Mapping of full ctags kind names to LSP kinds
local KIND_NAME_TO_LSP = {
  class = "Class",
  macro = "Constant",
  enumerator = "EnumMember",
  ["function"] = "Function",
  enum = "Enum",
  ["local"] = "Variable",
  member = "Field",
  namespace = "Namespace",
  prototype = "Function",
  struct = "Struct",
  typedef = "TypeParameter",
  union = "Struct",
  variable = "Variable",
  external = "Variable",
  constant = "Constant",
  event = "Event",
  field = "Field",
  method = "Method",
  property = "Property",
  interface = "Interface",
}

-- Convert ctags kind (abbreviation or full name) to LSP kind
-- Two-step conversion: abbr -> full name -> LSP kind
local function kind_to_lsp(kind)
  if not kind or kind == "" then
    return "Text"
  end

  local name = KIND_ABBR_TO_NAME[kind] or kind:lower()

  local lsp_kind = KIND_NAME_TO_LSP[name]

  return lsp_kind or "Text"
end

local function right_pad(str, width)
  local padding = math.max(0, width - #str)
  return str .. string.rep(" ", padding)
end

---@class snacks.picker.readtags.Config: snacks.picker.Config
---@field tag? string The tag to search for
---@field tagfile? string The path to the ctags file (default: "tags")
---@field cwd? string The directory to run the command in
---@field args? string[] Additional arguments to pass to readtag

---@param opts snacks.picker.readtags.Config
---@param filter snacks.picker.Filter
local function get_cmd(opts, filter)
  local cmd = "readtags"
  local args = {
    "-e",
    "-t",
    opts.tagfile or "tags",
  }
  -- Add any extra arguments
  vim.list_extend(args, opts.args or {})

  -- Add the tag to search for
  -- If tag is provided in opts, use that, otherwise use the search filter
  local tag = opts.tag or filter.search
  if tag and tag ~= "" then
    table.insert(args, tag)
  end

  return cmd, args
end

---@param opts snacks.picker.readtags.Config
---@type snacks.picker.finder
local function readtags(opts, ctx)
  if not opts.tag and ctx.filter.search == "" then
    return function() end
  end

  local tagfiles = vim.fn.tagfiles()
  if not tagfiles or #tagfiles == 0 then
    Snacks.notify.error "No tag file found. Please run :!ctags -R ."
    return function() end
  end

  opts.tagfile = tagfiles[1]

  local cwd = opts.cwd and vim.fs.normalize(opts.cwd) or uv.cwd() or "."
  local cmd, args = get_cmd(opts, ctx.filter)

  local config = vim.tbl_extend("force", {}, {
    notify = true,
    cmd = cmd,
    args = args,
    cwd = cwd,
    transform = function(item)
      -- Parse the readtag output
      -- Format: name<TAB>file<TAB>ex_cmd<TAB>extension_fields
      local parts = vim.split(item.text, "\t")
      if #parts < 3 then
        Snacks.notify.error("invalid readtag output:\n" .. item.text)
        return false
      end

      local name, file, ex_cmd = parts[1], parts[2], parts[3]

      -- Validate essential parts
      if not name or name == "" or not file or file == "" then
        return false
      end

      item.file = file

      --we need to transpile the "*" to a "\*"
      item.search = ex_cmd:gsub("%*", "\\*")

      -- Add extension fields as metadata
      item.meta = {}
      for i = 4, #parts do
        local key, value = parts[i]:match "^([^:]+):(.+)$"
        if key and value then
          item.meta[key] = value
        end
      end

      item.kind = item.meta.kind or ""
      item.lsp_kind = kind_to_lsp(item.kind)
      local padding_width = #item.kind == 1 and 3 or 12
      item.name = right_pad(item.kind, padding_width) .. name
      item.text = item.kind .. ":" .. file -- make kind:file searchable
      return true
    end,
  })

  return require("snacks.picker.source.proc").proc(config, ctx)
end

function M.picker(opts)
  opts = opts or {}
  local picker_opts = vim.tbl_extend("force", opts, {
    finder = readtags,
    format = "lsp_symbol",
    workspace = true, -- to show file path in lsp_symbol mode
    title = "Find tag",
    auto_confirm = true,
  })

  Snacks.picker.pick(picker_opts)
end

return M
