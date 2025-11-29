return {
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
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      size = 10,
      shading_factor = 2,
    },
  },
}
