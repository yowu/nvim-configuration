return {
  -- ============================================================================
  -- ts-comments.nvim - Better comment support
  -- ============================================================================
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "User FilePost",
  },

  -- ============================================================================
  -- Mini.surround - Add/delete/replace surroundings
  -- ============================================================================
  {
    "echasnovski/mini.surround",
    opts = {
      mappings = {
        add = "gsa",            -- Add surrounding in Normal and Visual modes
        delete = "gsd",         -- Delete surrounding
        find = "gsf",           -- Find surrounding (to the right)
        find_left = "gsF",      -- Find surrounding (to the left)
        highlight = "gsh",      -- Highlight surrounding
        replace = "gsr",        -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
      },
    },
    keys = {
      { "gsa", desc = "Add surrounding",                     mode = { "n", "v" } },
      { "gsd", desc = "Delete surrounding" },
      { "gsf", desc = "Find right surrounding" },
      { "gsF", desc = "Find left surrounding" },
      { "gsh", desc = "Highlight surrounding" },
      { "gsr", desc = "Replace surrounding" },
      { "gsn", desc = "Update `MiniSurround.config.n_lines`" },
    },
  },
  -- Flash.nvim - Enhanced motion
  {
    "folke/flash.nvim",
    event = "User FilePost",
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },

  -- Project.nvim - Project detection
  {
    "ahmedkhalf/project.nvim",
    main = "project_nvim",
    event = "VimEnter",
    opts = {
      detection_methods = { "pattern" },
      patterns = {
        ".git",
        "_darcs",
        ".hg",
        ".svn",
        "Makefile",
        "package.json",
        "pom.xml",
        "*.sln",
        "lazy-lock.json",
        ".clangd",
        ".clang-format",
        ".clang-tidy",
      },
      silent_chdir = true,
      scope_chdir = "global",
    },
  },

  -- Which-key.nvim - Keybinding help
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      notify = false,
      sort = { "group", "alphanum", "order", "local", "mod" },
      icons = { mappings = false },
      disable = { ft = {}, bt = { "TelescopePrompt", "terminal" } },
      spec = {
        { "<Leader>G",      group = true, desc = "Debug" },
        { "<Leader>g",      group = true, desc = "Git" },
        { "<Leader>c",      group = true, desc = "CodeCompanion" },
        { "<LocalLeader>j", group = true, desc = "Jester" },
        { "<LocalLeader>g", group = true, desc = "Goto" },
      },
    },
  },
}
