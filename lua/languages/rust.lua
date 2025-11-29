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

    -- Custom setup for rustaceanvim integration
    -- Note: rustaceanvim handles LSP setup directly via vim.g.rustaceanvim
    -- So we don't register rust_analyzer in the lsp table here
    custom_setup = function()
      -- The actual rustaceanvim configuration is handled in the plugin spec
      -- This is just a placeholder for any additional Rust-specific setup
    end,
  },
}
