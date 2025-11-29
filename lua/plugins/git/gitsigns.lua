return {
  "lewis6991/gitsigns.nvim",
  event = "User FilePost",
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" }
    },
  },
  keys = {
    {
      "<Leader>gL",
      "<cmd>lua require 'gitsigns'.blame_line({full=true})<cr>",
      desc = "Blame Line (full)",
    },
    {
      "<Leader>gR",
      "<cmd>lua require 'gitsigns'.reset_buffer()<cr>",
      desc = "Reset Buffer",
    },
    -- {
    --   "<Leader>gd",
    --   "<cmd>Gitsigns diffthis HEAD<cr>",
    --   desc = "Git Diff",
    -- },
    {
      "<Leader>gj",
      "<cmd>lua require 'gitsigns'.nav_hunk('next', {navigation_message = false})<cr>",
      desc = "Next Hunk",
    },
    {
      "<Leader>gk",
      "<cmd>lua require 'gitsigns'.nav_hunk('prev', {navigation_message = false})<cr>",
      desc = "Prev Hunk",
    },
    {
      "<Leader>gl",
      "<cmd>lua require 'gitsigns'.blame_line()<cr>",
      desc = "Blame",
    },
    {
      "<Leader>gp",
      "<cmd>lua require 'gitsigns'.preview_hunk()<cr>",
      desc = "Preview Hunk",
    },
    {
      "<Leader>gr",
      "<cmd>lua require 'gitsigns'.reset_hunk()<cr>",
      desc = "Reset Hunk",
    },
    {
      "<Leader>gs",
      "<cmd>lua require 'gitsigns'.stage_hunk()<cr>",
      desc = "Stage Hunk",
    },
    {
      "<Leader>gu",
      "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
      desc = "Undo Stage Hunk",
    },
  },
  -- specs = {
  --   {
  --     "folke/which-key.nvim",
  --     optional = true,
  --     keys = {
  --     }
  --   }
  -- }
}
