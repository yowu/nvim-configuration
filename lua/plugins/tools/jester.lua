local M = {}

local jest = vim.fn.executable "jest" == 1 and "jest" or "node ./node_modules/jest/bin/jest.js"
local newline = require("core.platform").is_windows() and "\r" or "\n"

local function run(opts)
  local status_ok, jester = pcall(require, "jester")
  if not status_ok then
    return
  end
  jester.run(opts)
end

function M.run_test_around_cursor()
  run { cmd = jest .. " -t '$result' -- $file " .. newline }
end

function M.run_current_file()
  run { cmd = jest .. " -- $file " .. newline }
end

function M.run_all_files()
  run { cmd = jest .. " " .. newline }
end

function M.run_all_match_files(pattern)
  if pattern == nil or #pattern == 0 then
    return M.run_all_files()
  end
  run { cmd = jest .. " -t '" .. pattern .. "' " .. newline }
end

return {
  "david-kunz/jester",
  opts = {
    path_to_jest_run = jest,   -- used for run tests
    path_to_jest_debug = jest, -- used for debugging
    escapeRegex = false,
  },
  event = "User FileOpened",
  keys = {
    { "<LocalLeader>j",  group = true,             desc = "Jest" },
    { "<localleader>ja", M.run_all_files,          desc = "Run all test files" },
    { "<localleader>jf", M.run_current_file,       desc = "Run current file" },
    { "<localleader>jt", M.run_test_around_cursor, desc = "Run current test" },
  },
}
