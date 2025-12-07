---Rust language configuration

return {
  name = "rust",
  config = {
    -- Treesitter parsers
    treesitter = { "rust", "toml" },

    -- Mason tools
    tools = { "codelldb" },

    -- Additional options
    opts = {
      filetypes = { "rust" },
    },
  },
}
