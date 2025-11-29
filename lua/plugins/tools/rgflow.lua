return {
  "mangelozzi/nvim-rgflow.lua",
  opts = {
    -- set the default rip grep flags and options for when running a search via
    -- rgflow. once changed via the ui, the previous search flags are used for
    -- each subsequent search (until neovim restarts).
    cmd_flags = "--smart-case --fixed-strings --max-columns=200",

    -- mappings to trigger rgflow functions
    default_trigger_mappings = false,
    -- these mappings are only active when the rgflow ui (panel) is open
    default_ui_mappings = true,
    -- quickfix window only mapping
    default_quickfix_mappings = true,
  },
  event = "VeryLazy",
  keys = {
    { "<Leader>/", function() require("extras.grep").grep_string() end,                                    desc = "Search" },
    { "<M-/>",     function() require("extras.grep").grep_string { search = vim.fn.expand "<cword>" } end, desc = "Search word under cursor" },
  },
}
