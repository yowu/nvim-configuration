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
opt.number = true -- Show line numbers
opt.numberwidth = 2 -- Number column width
opt.signcolumn = "yes" -- Always show sign column
opt.cursorline = true -- Highlight current line
opt.cursorlineopt = "number" -- Only highlight line number
opt.showmode = false -- Don't show mode (in statusline instead)
opt.ruler = false -- Don't show ruler
opt.laststatus = 3 -- Global statusline
opt.cmdheight = 0 -- Hide command line when not used

-- Clipboard
opt.clipboard = "unnamedplus" -- Use system clipboard

-- Indentation
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 2 -- Indent width
opt.tabstop = 2 -- Tab width
opt.softtabstop = 2 -- Soft tab width
opt.smartindent = true -- Smart autoindenting

-- Search
opt.ignorecase = true -- Ignore case in search
opt.smartcase = true -- Unless uppercase is used

-- Mouse
opt.mouse = "a" -- Enable mouse support

-- Splits
opt.splitbelow = true -- Horizontal splits go below
opt.splitright = true -- Vertical splits go right

-- Files
opt.undofile = true -- Persistent undo
opt.updatetime = 250 -- Faster completion

-- Appearance
opt.fillchars = { eob = " " } -- Remove ~ from empty lines
opt.timeoutlen = 400 -- Faster key sequence completion

-- Tags (for ctags support)
opt.tags = "./tags;,./tags;./.tags;,./.tmp_tags;"

-- Which wrap keys can move to prev/next line
opt.whichwrap:append "<>[]hl"

-- ============================================================================
-- Diagnostics Configuration
-- ============================================================================

vim.diagnostic.config {
  update_in_insert = false, -- Don't update diagnostics in insert mode
  virtual_lines = {
    current_line = true, -- Show virtual lines on current line
  },
  severity_sort = true, -- Sort by severity
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚",
      [vim.diagnostic.severity.WARN] = "󰀪",
      [vim.diagnostic.severity.HINT] = "󰌶",
      [vim.diagnostic.severity.INFO] = "󰋽",
    },
  },
}

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
g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
