return {
  name = "C++: build active file",
  builder = function()
    -- Full path to current file (see :help expand())
    local file = vim.fn.expand "%:p"
    local ext = require("core.platform").get_executable_extension()
    local out = vim.fn.expand "%:t:r" .. ext
    return {
      cmd = { "clang++" },
      args = {
        "-std=c++20",
        "-Wall",
        "-fcolor-diagnostics",
        "-fansi-escape-codes",
        "-g",
        file,
        "-o",
        vim.loop.cwd() .. "/bin/" .. out,
      },
      components = { "default" },
    }
  end,
  condition = {
    filetype = { "cpp" },
  },
}
