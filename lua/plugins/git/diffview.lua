return {
  "sindrets/diffview.nvim",
  lazy = true,
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  opts = {
    default_args = {
      DiffviewFileHistory = { "%" },
    },
    hooks = {
      diff_buf_read = function()
        vim.wo.wrap = false
        vim.wo.list = false
        vim.wo.colorcolumn = ""
      end,
    },
    enhanced_diff_hl = true,
    keymaps = {
      view = { q = "<Cmd>DiffviewClose<CR>" },
      file_panel = { q = "<Cmd>DiffviewClose<CR>" },
      file_history_panel = { q = "<Cmd>DiffviewClose<CR>" },
    },
  },
  keys = {
    { "<Leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git Diff" },
  },
}
