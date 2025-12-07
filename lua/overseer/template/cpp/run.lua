return {
  name = "C++: run active file",
  builder = function()
    -- Full path to current file (see :help expand())
    local ext = require("core.platform").get_executable_extension()
    local out = vim.fn.expand "%:t:r" .. ext
    return {
      cmd = { vim.loop.cwd() .. "/bin/" .. out },
      components = {
        { "dependencies", task_names = { "C++: build active file" } },
        "default",
      },
      strategy = "toggleterm",
    }
  end,
  condition = {
    filetype = { "cpp" },
  },
}
