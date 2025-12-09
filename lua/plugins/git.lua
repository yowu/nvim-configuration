return {
  -- ============================================================================
  -- Gitsigns - Git signs in the gutter
  -- ============================================================================
  {
    "lewis6991/gitsigns.nvim",
    event = "User FilePost",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
    },
    keys = {
      { "<Leader>gL", function() require("gitsigns").blame_line({ full = true }) end, desc = "Blame Line (full)" },
      { "<Leader>gR", function() require("gitsigns").reset_buffer() end, desc = "Reset Buffer" },
      { "<Leader>gj", function() require("gitsigns").nav_hunk("next", { navigation_message = false }) end, desc = "Next Hunk" },
      { "<Leader>gk", function() require("gitsigns").nav_hunk("prev", { navigation_message = false }) end, desc = "Prev Hunk" },
      { "<Leader>gl", function() require("gitsigns").blame_line() end, desc = "Blame" },
      { "<Leader>gp", function() require("gitsigns").preview_hunk() end, desc = "Preview Hunk" },
      { "<Leader>gr", function() require("gitsigns").reset_hunk() end, desc = "Reset Hunk" },
      { "<Leader>gs", function() require("gitsigns").stage_hunk() end, desc = "Stage Hunk" },
      { "<Leader>gu", function() require("gitsigns").undo_stage_hunk() end, desc = "Undo Stage Hunk" },
    },
  },

  -- ============================================================================
  -- Diffview - Git diff viewer
  -- ============================================================================
  {
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
  },
}
