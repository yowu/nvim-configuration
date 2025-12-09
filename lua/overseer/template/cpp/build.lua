return {
  name = "C++: build active file",
  builder = function()
    -- Full path to current file (see :help expand())
    local file = vim.fn.expand "%:p"
    local ext = vim.fn.has "win32" ~= 0 and ".exe" or ""
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
