-- ============================================================================
-- Autocommands & Events
-- ============================================================================

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- ============================================================================
-- FilePost Event (for lazy loading plugins)
-- ============================================================================

augroup("UserFilePost", { clear = true })
autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
  group = "UserFilePost",
  callback = function(args)
    local file = vim.api.nvim_buf_get_name(args.buf)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })

    if not vim.g.ui_entered and args.event == "UIEnter" then
      vim.g.ui_entered = true
    end

    if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
      vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
      vim.api.nvim_del_augroup_by_name("UserFilePost")

      vim.schedule(function()
        vim.api.nvim_exec_autocmds("FileType", {})
      end)
    end
  end,
})

-- ============================================================================
-- Close Windows with 'q'
-- ============================================================================

augroup("QCloseWindows", { clear = true })

local q_close_cache = {}

autocmd("BufWinEnter", {
  group = "QCloseWindows",
  desc = "Make q close help, man, quickfix, etc",
  callback = function(args)
    if q_close_cache[args.buf] then
      return
    end
    q_close_cache[args.buf] = true

    -- Check if q is already mapped
    for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(args.buf, "n")) do
      if mapping.lhs == "q" then
        return
      end
    end

    -- Map q to close for special buffer types
    if vim.tbl_contains({ "help", "nofile", "quickfix" }, vim.bo[args.buf].buftype) then
      vim.keymap.set("n", "q", "<Cmd>close<CR>", {
        desc = "Close window",
        buffer = args.buf,
        silent = true,
        nowait = true,
      })
    end
  end,
})

autocmd("BufDelete", {
  group = "QCloseWindows",
  desc = "Clean up q_close_windows cache",
  callback = function(args)
    q_close_cache[args.buf] = nil
  end,
})

-- ============================================================================
-- Highlight on Yank
-- ============================================================================

augroup("HighlightYank", { clear = true })
autocmd("TextYankPost", {
  group = "HighlightYank",
  desc = "Highlight yanked text",
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- ============================================================================
-- Terminal Settings
-- ============================================================================

augroup("TerminalSettings", { clear = true })
autocmd({ "TermOpen", "WinEnter" }, {
  group = "TerminalSettings",
  pattern = "term://*",
  command = "startinsert",
  desc = "Auto enter insert mode in terminal",
})

-- ============================================================================
-- Dim Inactive Windows (optional)
-- ============================================================================

augroup("DimInactive", { clear = true })
autocmd("BufWinEnter", {
  group = "DimInactive",
  desc = "Dim inactive window",
  callback = function(args)
    -- Skip for certain filetypes
    if not vim.tbl_contains({ "DiffviewFiles" }, vim.bo[args.buf].filetype) then
      vim.cmd([[setlocal winhighlight=NormalNC:PmenuSbar]])
    end
  end,
})


autocmd("VimEnter", {
  group = augroup("ViewTidy", { clear = true }),
  desc = "Clear last search",
  callback = function()
    vim.cmd "let @/ = ''"
  end,
})

-- ============================================================================
-- Neo-tree Auto Open
-- ============================================================================

augroup("NeoTreeStart", { clear = true })
autocmd("BufEnter", {
  group = "NeoTreeStart",
  desc = "Open Neo-Tree on startup with directory",
  callback = function()
    if package.loaded["neo-tree"] then
      return true
    end
    local stats = vim.uv.fs_stat(vim.api.nvim_buf_get_name(0))
    if stats and stats.type == "directory" then
      require("lazy").load { plugins = { "neo-tree.nvim" } }
      return true
    end
  end,
})

-- ============================================================================
-- Custom Filetypes
-- ============================================================================
vim.filetype.add({
  extension = {
    ridl = "ruby",
  },

  pattern = {
    ["journal.*.txt"] = "vb",
  },
})
