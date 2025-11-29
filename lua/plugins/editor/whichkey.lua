return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function(_, opts)
    dofile(vim.g.base46_cache .. "whichkey")
    require("which-key").setup(opts)
  end,
  opts = {
    ---@type false | "classic" | "modern" | "helix"
    -- preset = "modern",
    notify = false,
    sort = { "group", "alphanum", "order", "local", "mod" },
    icons = { mappings = false },
    -- But you can disable this and setup the triggers yourself.
    -- Be aware, that triggers are not needed for visual and operator pending mode.
    disable = {
      -- disable WhichKey for certain buf types and file types.
      ft = {},
      bt = { "TelescopePrompt", "terminal" },
    },
    spec = {
      -- For the lazy loaded plugin, we need add their groups even they are not loaded
      { "<Leader>G",      group = true, desc = "Debug" },
      { "<Leader>g",      group = true, desc = "Git" },
      { "<Leader>c",      group = true, desc = "CodeCompanion" },
      { "<LocalLeader>j", group = true, desc = "Jester" },
      { "<LocalLeader>g", group = true, desc = "Goto" },
    },
  },
}
