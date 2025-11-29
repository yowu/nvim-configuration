return {
  "nvim-neo-tree/neo-tree.nvim",
  cmd = "Neotree",
  opts = {
    auto_clean_after_session_restore = true,
    close_if_last_window = true,
    enable_diagnostics = false,
    popup_border_style = "single",
    -- enable_git_status = false,
    sources = { "filesystem" },
    default_component_configs = {
      git_status = {
        symbols = {
          ignored = "◌",
          untracked = "󰹢",
          unstaged = "󱇨",
          staged = "󰈖",
        },
      },
    },
    window = {
      width = 30,
    },
    filesystem = {
      follow_current_file = {
        enabled = true,
      },
    },
  },

  keys = {
    -- { "<Leader>e", "<Cmd>Neotree toggle<CR>", desc = "Toggle Explorer" },
    {
      "<Leader>o",
      function()
        if vim.bo.filetype == "neo-tree" then
          vim.cmd.wincmd "p"
        else
          vim.cmd.Neotree "focus"
        end
      end,
      desc = "Toggle Explorer Focus",
    },
  },

  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "MunifTanjim/nui.nvim" },
  },
}
