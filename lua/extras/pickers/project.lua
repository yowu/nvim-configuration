local M = {}
local history = require "project_nvim.utils.history"

local finder = function()
  local results = history.get_recent_projects()
  -- Reverse results
  for i = 1, math.floor(#results / 2) do
    results[i], results[#results - i + 1] = results[#results - i + 1], results[i]
  end
  local project_list = {}
  for _, project in ipairs(results) do
    table.insert(project_list, {
      name = vim.fn.fnamemodify(project, ":t") or "<unknown>",
      text = project,
      file = project,
      dir = true,
    })
  end
  return project_list
end

function M.picker()
  return Snacks.picker.pick {
    finder = finder,
    format = function(item, _)
      local ret = {}
      local a = Snacks.picker.util.align
      local icon, hl = Snacks.util.icon("file", "directory")
      ret[#ret + 1] = { a(icon, 2), hl }
      ret[#ret + 1] = { a(item.name, 40), "SnacksPickerDirectory" }
      ret[#ret + 1] = { " " }
      ret[#ret + 1] = { item.file, "SnacksPickerComment" }
      return ret
    end,
    confirm = "load_session",
    title = "Projects",
    need_search = true,
    layout = { preset = "select", layout = { backdrop = true } },
  }
end

return M
