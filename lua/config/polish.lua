-- extras function
require("extras.alternate").setup {
  alternate_map = {
    -- Add your custom alternates here
    -- ["js"] = { "jsx" },
  },
}
require("extras.view-tidy").setup()

-- Load Theme
for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
  dofile(vim.g.base46_cache .. v)
end

-- Platform-specific settings (Windows)
local is_windows = require("core.platform").is_windows()

if is_windows then
  vim.opt.shell = "pwsh.exe"
  vim.opt.shellcmdflag =
  "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  vim.cmd([[
    let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    set shellquote= shellxquote=
  ]])

  -- Windows clipboard
  vim.g.clipboard = {
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
  }
end

-- Neovide settings
if vim.g.neovide then
  local font_size = is_windows and ":h14" or ":h19"
  vim.opt.guifont = { "LiterationMono Nerd Font Mono", "LXGW WenKai", font_size }
  vim.opt.linespace = 8
  vim.g.neovide_cursor_trail_size = 0
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_floating_shadow = false
  vim.g.neovide_light_radius = 5
  vim.g.neovide_floating_corner_radius = 0.5
  vim.g.neovide_input_macos_option_key_is_meta = "only_left"
end

