return {
  -- ============================================================================
  -- Copilot - AI code suggestions
  -- ============================================================================
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "User FilePost",
    opts = {
      suggestion = { auto_trigger = true, debounce = 150 },
      panel = { enable = false },
    },
  },

  -- ============================================================================
  -- CodeCompanion - AI chat and inline assistant
  -- ============================================================================
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "codecompanion" },
        opts = {
          render_modes = true, -- Render in ALL modes
          sign = {
            enabled = false, -- Turn off in the status column
          },
        },
      },
    },
    event = "User FilePost",
    config = function()
      require("codecompanion").setup {
        interactions = {
          chat = {
            adapter = "copilot",
          },
          inline = {
            adapter = "copilot",
          },
        },
      }
    end,

    keys = {
      { "<Leader>cc", "<cmd>CodeCompanionChat Toggle<CR>", desc = "Chat" },
      { "<Leader>ca", "<cmd>CodeCompanionActions<CR>", desc = "Actions" },
      { "<Leader>ci", "<cmd>CodeCompanion<CR>", desc = "Inline Assistant" },
    },

    specs = {
      {
        "nvim-treesitter/nvim-treesitter",
        optional = true,
        opts_extend = { "ensure_installed" },
        opts = {
          ensure_installed = { "markdown", "markdown-inline", "html" },
        },
      },
    },
  },
}
