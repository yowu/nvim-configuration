-- ============================================================================
-- Autocommands & Events
-- ============================================================================

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- ============================================================================
-- FilePost Event (for lazy loading plugins)
-- ============================================================================

autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
  group = augroup("UserFilePost", { clear = true }),
  callback = function(args)
    local file = vim.api.nvim_buf_get_name(args.buf)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })

    if not vim.g.ui_entered and args.event == "UIEnter" then
      vim.g.ui_entered = true
    end

    if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
      vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
      vim.api.nvim_del_augroup_by_name "UserFilePost"

      vim.schedule(function()
        vim.api.nvim_exec_autocmds("FileType", {})
      end)
    end
  end,
})

-- ============================================================================
-- Close Windows with 'q'
-- ============================================================================

do
  local group = augroup("QCloseWindows", { clear = true })
  local cache = {}

  autocmd("BufWinEnter", {
    group = group,
    desc = "Make q close help, man, quickfix, etc",
    callback = function(args)
      if cache[args.buf] then
        return
      end
      cache[args.buf] = true

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
    group = group,
    desc = "Clean up cache",
    callback = function(args)
      cache[args.buf] = nil
    end,
  })
end

-- ============================================================================
-- Highlight on Yank
-- ============================================================================

autocmd("TextYankPost", {
  group = augroup("HighlightYank", { clear = true }),
  desc = "Highlight yanked text",
  callback = function()
    vim.hl.on_yank { timeout = 200 }
  end,
})

-- ============================================================================
-- Terminal Settings
-- ============================================================================

autocmd({ "TermOpen", "WinEnter" }, {
  group = augroup("TerminalSettings", { clear = true }),
  pattern = "term://*",
  command = "startinsert",
  desc = "Auto enter insert mode in terminal",
})

-- ============================================================================
-- Dim Inactive Windows (optional)
-- ============================================================================

autocmd("BufWinEnter", {
  group = augroup("DimInactive", { clear = true }),
  desc = "Dim inactive window",
  callback = function(args)
    -- Skip for certain filetypes
    if not vim.tbl_contains({ "DiffviewFiles" }, vim.bo[args.buf].filetype) then
      vim.cmd [[setlocal winhighlight=NormalNC:PmenuSbar]]
    end
  end,
})

-- ============================================================================
-- Neo-tree Auto Open
-- ============================================================================

autocmd("BufEnter", {
  group = augroup("NeoTreeStart", { clear = true }),
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
