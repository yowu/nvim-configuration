local M = {}
local notification = require "fidget.notification"

local finder = function()
  local results = notification.get_history()
  -- Reverse results
  for i = 1, math.floor(#results / 2) do
    results[i], results[#results - i + 1] = results[#results - i + 1], results[i]
  end
  local notifications = {}
  for _, item in ipairs(results) do
    table.insert(notifications, {
      time = vim.fn.strftime("%c", item.last_updated),
      annotation = item.annote or " ",
      text = item.message or "<unknown>",
    })
  end
  return notifications
end

function M.picker()
  return Snacks.picker.pick {
    finder = finder,
    format = function(item, _)
      local ret = {}
      local a = Snacks.picker.util.align
      ret[#ret + 1] = { a(item.time, 24), "SnacksPickerGitDate" }
      ret[#ret + 1] = { " " }
      ret[#ret + 1] = { a(item.annotation, 8), "SnacksPickerIconName" }
      ret[#ret + 1] = { " " }
      ret[#ret + 1] = { item.text, "SnacksPickerComment" }
      return ret
    end,
    confirm = "close",
    title = "Notifications",
    need_search = true,
    layout = { preset = "select", layout = { backdrop = true } },
  }
end

return M
