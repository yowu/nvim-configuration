return {
  name = "C++: run active file",
  builder = function()
    -- Full path to current file (see :help expand())
    local ext = vim.fn.has "win32" ~= 0 and ".exe" or ""
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
