-- Jest helpers
local M = {}
local newline = require("core.platform").get_line_separator()

M.jest = vim.fn.executable("jest") == 1 and "jest" or "node ./node_modules/jest/bin/jest.js"

local function run_jester(opts)
  local status_ok, jester = pcall(require, "jester")
  if not status_ok then
    return
  end
  jester.run(opts)
end

function M.run_test_around_cursor()
  run_jester({ cmd = M.jest .. " -t '$result' -- $file " .. newline })
end

function M.run_current_file()
  run_jester({ cmd = M.jest .. " -- $file " .. newline })
end

function M.run_all_files()
  run_jester({ cmd = M.jest .. " " .. newline })
end

return M
