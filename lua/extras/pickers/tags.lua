local M = {}

local uv = vim.uv or vim.loop

local function left_pad(str, numSpaces)
  local spaces = string.rep(" ", numSpaces)
  return spaces .. str
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

  args = vim.deepcopy(args)

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
    ---@param item snacks.picker.finder.Item
    transform = function(item)
      -- Parse the readtag output
      -- Format is typically: name<TAB>file<TAB>ex_cmd<TAB>extension_fields
      local parts = vim.split(item.text, "\t")
      if #parts < 3 then
        Snacks.notify.error("invalid readtag output:\n" .. item.text)
        return false
      end

      local name, file, ex_cmd = parts[1], parts[2], parts[3]

      -- Extract line number from ex_cmd if it's a line number
      local line_num = ex_cmd:match "^(%d+)$"
      if not line_num then
        -- Try to extract line number from pattern like /^function foo(/;/
        line_num = ex_cmd:match "/^.+/;/(%d+)"
      end

      item.name = name
      item.file = file

      local padding_num = (40 - #file) > 0 and (40 - #file) or 0
      item.line = left_pad(" " .. name .. " " .. (parts[4] or ""), padding_num)

      if line_num then
        item.pos = { tonumber(line_num), 0 }
      else
        -- If we can't extract a line number, we'll use the search for vim to jump
        -- but we need to transpile the "*" to a "\*"
        ex_cmd = ex_cmd:gsub("%*", "\\*")
        item.search = ex_cmd
      end

      -- Add any extension fields as metadata
      item.meta = {}
      for i = 4, #parts do
        local key, value = parts[i]:match "([^:]+):(.+)"
        if key and value then
          item.meta[key] = value
        end
      end
    end,
  })
  return require("snacks.picker.source.proc").proc(config, ctx)
end

function M.picker(opts)
  opts = opts or {}
  local picker_opts = vim.tbl_extend("force", opts, {
    finder = readtags,
    format = "file",
    title = "Find tag",
    source = "ctags",
    auto_confirm = true,
    cmd = "readtags",
  })

  Snacks.picker.pick(picker_opts)
end

return M
