return {
  "nvchad/ui",
  lazy = false,
  config = function()
    -- Create NvThemes command
    vim.api.nvim_create_user_command("NvThemes", function() require("nvchad.themes").open() end,
      { desc = "Toggle themes" })
    require("base46").load_all_highlights()
    require "nvchad"
  end,

  keys = {
    -- Buffer navigation
    { "]b",     function() require("nvchad.tabufline").next() end,                                desc = "Buffer goto next" },
    { "[b",     function() require("nvchad.tabufline").prev() end,                                desc = "Buffer goto prev" },
    { "<C-q>",  function() require("nvchad.tabufline").close_buffer() end,                        desc = "Buffer close" },
    -- Terminal toggles (both normal and terminal mode)
    { "<A-|>",  function() require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" } end, mode = { "n", "t" },      desc = "Toggle vertical term" },
    { "<A-\\>", function() require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" } end,  mode = { "n", "t" },      desc = "Toggle horizontal term" },
    { "<A-`>",  function() require("nvchad.term").toggle { pos = "float", id = "floatTerm" } end, mode = { "n", "t" },      desc = "Toggle floating term" },
    { "<C-`>",  function() require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" } end,  mode = { "n", "t" },      desc = "Toggle term" },
  },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-lua/plenary.nvim",
    "nvchad/base46",
    "nvzone/volt",
  },
  specs = {
    {
      "nvchad/base46",
      branch = "v3.0",
    }
  }
}
