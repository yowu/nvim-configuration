-- ============================================================================
-- Neovim Options & Settings
-- ============================================================================

local opt = vim.opt
local g = vim.g

-- ============================================================================
-- General Settings
-- ============================================================================

-- Leader keys
g.mapleader = " "
g.maplocalleader = ","

-- UI
opt.number = true            -- Show line numbers
opt.numberwidth = 2          -- Number column width
opt.signcolumn = "yes"       -- Always show sign column
opt.cursorline = true        -- Highlight current line
opt.cursorlineopt = "number" -- Only highlight line number
opt.showmode = false         -- Don't show mode (in statusline instead)
opt.ruler = false            -- Don't show ruler
opt.laststatus = 3           -- Global statusline
opt.cmdheight = 0            -- Hide command line when not used

-- Clipboard
opt.clipboard = "unnamedplus" -- Use system clipboard

-- Indentation
opt.expandtab = true   -- Use spaces instead of tabs
opt.shiftwidth = 2     -- Indent width
opt.tabstop = 2        -- Tab width
opt.softtabstop = 2    -- Soft tab width
opt.smartindent = true -- Smart autoindenting

-- Search
opt.ignorecase = true -- Ignore case in search
opt.smartcase = true  -- Unless uppercase is used

-- Mouse
opt.mouse = "a" -- Enable mouse support

-- Splits
opt.splitbelow = true -- Horizontal splits go below
opt.splitright = true -- Vertical splits go right

-- Files
opt.undofile = true  -- Persistent undo
opt.updatetime = 250 -- Faster completion

-- Appearance
opt.fillchars = { eob = " " } -- Remove ~ from empty lines
opt.timeoutlen = 400          -- Faster key sequence completion

-- Tags (for ctags support)
opt.tags = "./tags;,./tags;./.tags;,./.tmp_tags;"

-- Which wrap keys can move to prev/next line
opt.whichwrap:append("<>[]hl")

-- ============================================================================
-- Diagnostics Configuration
-- ============================================================================

vim.diagnostic.config({
  update_in_insert = false, -- Don't update diagnostics in insert mode
  virtual_lines = {
    current_line = true,    -- Show virtual lines on current line
  },
  severity_sort = true,     -- Sort by severity
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚",
      [vim.diagnostic.severity.WARN] = "󰀪",
      [vim.diagnostic.severity.HINT] = "󰌶",
      [vim.diagnostic.severity.INFO] = "󰋽",
    },
  },
})

-- ============================================================================
-- Global Variables
-- ============================================================================

g.icons_enabled = true -- Enable icons

-- Disable unused providers (faster startup)
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- NvChad theme cache path
g.base46_cache = vim.fn.stdpath("data") .. "/base46/"

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
  g.clipboard = {
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
if g.neovide then
  local font_size = is_windows and ":h14" or ":h19"
  vim.opt.guifont = { "LiterationMono Nerd Font Mono", "LXGW WenKai", font_size }
  g.neovide_cursor_trail_size = 0
  g.neovide_cursor_animation_length = 0
  g.neovide_floating_shadow = false
  g.neovide_light_radius = 5
  g.neovide_floating_corner_radius = 0.5
  vim.opt.linespace = 8
  g.neovide_input_macos_option_key_is_meta = "only_left"
end
