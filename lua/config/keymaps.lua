-- ============================================================================
-- Core Keymaps Configuration
-- ============================================================================
--
-- This file contains ONLY core Neovim keymaps that don't depend on plugins.
-- Plugin-dependent keymaps belong in their respective plugin specs (keys = {}).
--
-- KEYMAP LOCATIONS:
-- 1. Core vim keymaps        → here (vim.keymap.set)
-- 2. Plugin keymaps          → plugin spec (keys = {})
-- 3. LSP keymaps             → core/lsp.lua (buffer-local on attach)
-- 4. Buffer-local keymaps    → autocmd or on_attach callbacks
--
-- ============================================================================

local map = vim.keymap.set

-- ============================================================================
-- General
-- ============================================================================

-- Better save
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })

-- Quit
map("n", "<Leader>q", "<cmd>confirm q<CR>", { desc = "Quit" })

-- Clear search highlights
-- map("n", "<Esc><Esc>", "<cmd>noh<CR>", { desc = "Clear highlights" })

-- ============================================================================
-- Window Navigation
-- ============================================================================

map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to down window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to up window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Terminal mode navigation
map("t", "<C-h>", "<C-\\><C-N><C-w>h", { desc = "Move to left window" })
map("t", "<C-j>", "<C-\\><C-N><C-w>j", { desc = "Move to down window" })
map("t", "<C-k>", "<C-\\><C-N><C-w>k", { desc = "Move to up window" })
map("t", "<C-l>", "<C-\\><C-N><C-w>l", { desc = "Move to right window" })

-- ============================================================================
-- Window Resizing
-- ============================================================================

map("n", "<A-Up>", "<cmd>resize -2<CR>", { desc = "Decrease height" })
map("n", "<A-Down>", "<cmd>resize +2<CR>", { desc = "Increase height" })
map("n", "<A-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease width" })
map("n", "<A-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase width" })

-- ============================================================================
-- Buffer Navigation
-- ============================================================================

map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

-- ============================================================================
-- Line Movement
-- ============================================================================

-- Move lines up/down in normal mode
map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })

-- Move lines up/down in insert mode
map("i", "<A-j>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move line up" })

-- Move lines up/down in visual mode
map("x", "<A-j>", ":m '>+1<CR>gv-gv", { desc = "Move selection down" })
map("x", "<A-k>", ":m '<-2<CR>gv-gv", { desc = "Move selection up" })

-- ============================================================================
-- Indentation
-- ============================================================================

-- Keep selection after indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- ============================================================================
-- Quickfix Navigation
-- ============================================================================

map("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<CR>", { desc = "Previous quickfix" })

-- ============================================================================
-- Terminal
-- ============================================================================

-- Exit terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-N>", { desc = "Exit terminal mode" })
map("t", "<C-q>", "<cmd>close<CR>", { desc = "Close terminal" })

-- ============================================================================
-- LSP Keymaps (set when LSP attaches)
-- ============================================================================

map("n", "<F2>", vim.lsp.buf.rename, { desc = "LSP Rename" })
map("n", "<F12>", vim.lsp.buf.definition, { desc = "LSP Go to definition" })

-- ============================================================================
-- View Tidy (extends <Esc><Esc>)
-- ============================================================================

-- Note: This extends <Esc><Esc> to also call view-tidy.clean
-- The base <Esc><Esc> for noh is defined above, this adds extra functionality
map("n", "<Esc><Esc>", function()
    vim.cmd "noh"
    require("extras.view-tidy").clean()
end, { desc = "Clear highlights and tidy view" })
