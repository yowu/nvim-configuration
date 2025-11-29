local M = {}

local string_to_tbl = function(str)
  local result = {}
  for i in string.gmatch(str, "%S+") do
    table.insert(result, i)
  end
  return result
end

M.grep_string = function(opts)
  opts = opts or {}
  local rg_opts = [[--vimgrep --max-columns=400]]
  require("rgflow").open(opts.search, rg_opts, opts.cwd, {
    custom_start = function(pattern, flags, path)
      -- collected args from rgflow.
      opts.cwd = path
      opts.regex = true
      opts.args = string_to_tbl(flags)
      opts.search = pattern
      Snacks.picker.grep(opts)
    end,
  })
end

return M
