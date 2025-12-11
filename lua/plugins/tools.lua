return {
  -- ============================================================================
  -- Overseer - Task runner
  -- ============================================================================
  {
    "stevearc/overseer.nvim",
    version = "1.6.0",
    opts = {
      templates = { "builtin", "rtags", "cpp" },
    },
    cmd = {
      "OverseerOpen",
      "OverseerClose",
      "OverseerToggle",
      "OverseerSaveBundle",
      "OverseerLoadBundle",
      "OverseerDeleteBundle",
      "OverseerRunCmd",
      "OverseerRun",
      "OverseerInfo",
      "OverseerBuild",
      "OverseerQuickAction",
      "OverseerTaskAction",
      "OverseerClearCache",
    },
    keys = {
      { "<A-P>", "<Cmd>OverseerRun<cr>", desc = "OverseerRun" },
    },
    dependencies = {
      "akinsho/toggleterm.nvim",
    },
  },

  -- ============================================================================
  -- ToggleTerm - Terminal management
  -- ============================================================================
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      size = 10,
      shading_factor = 2,
    },
  },

  -- ============================================================================
  -- RgFlow - Ripgrep integration
  -- ============================================================================
  {
    "mangelozzi/nvim-rgflow.lua",
    opts = {
      cmd_flags = "--smart-case --fixed-strings --max-columns=200",
      default_trigger_mappings = false,
      default_ui_mappings = true,
      default_quickfix_mappings = true,
    },
    event = "VeryLazy",
    keys = {
      {
        "<Leader>/",
        function()
          require("extras.grep").grep_string()
        end,
        desc = "Search",
      },
      {
        "<M-/>",
        function()
          require("extras.grep").grep_string { search = vim.fn.expand "<cword>" }
        end,
        desc = "Search word under cursor",
      },
    },
  },

  -- ============================================================================
  -- Jester - Jest test runner
  -- ============================================================================
  {
    "david-kunz/jester",
    opts = {
      path_to_jest_run = require("extras.jest").jest,
      path_to_jest_debug = require("extras.jest").jest,
      escapeRegex = false,
    },
    event = "User FileOpened",
    keys = {
      { "<LocalLeader>j", group = true, desc = "Jest" },
      { "<localleader>ja", require("extras.jest").run_all_files, desc = "Run all test files" },
      { "<localleader>jf", require("extras.jest").run_current_file, desc = "Run current file" },
      { "<localleader>jt", require("extras.jest").run_test_around_cursor, desc = "Run current test" },
    },
  },

  -- ============================================================================
  -- CMake Tools - CMake integration
  -- ============================================================================
  {
    "Civitasv/cmake-tools.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    cmd = { "CMakeQuickStart", "CMakeRun", "CMakeBuild", "CMakeClean" },
    init = function()
      local loaded = false
      local function check()
        local cwd = vim.uv.cwd()
        if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
          require("lazy").load { plugins = { "cmake-tools.nvim" } }
          loaded = true
        end
      end
      check()
      vim.api.nvim_create_autocmd("DirChanged", {
        callback = function()
          if not loaded then
            check()
          end
        end,
      })
    end,
    opts = {
      cmake_build_directory = function()
        local ps = require("core.platform").get_path_separator()
        return "build" .. ps .. "${variant:buildType}"
      end,
      cmake_executor = {
        name = "toggleterm",
        opts = { direction = "horizontal" },
      },
      cmake_runner = {
        name = "toggleterm",
        opts = { direction = "horizontal" },
      },
    },
  },
}
