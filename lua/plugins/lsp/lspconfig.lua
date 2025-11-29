return {
  {
    "neovim/nvim-lspconfig",
    event = "User FilePost",
    cmd = { "LspInfo", "LspLog", "LspStart" },
    dependencies = {
      "williamboman/mason.nvim",
    },
    opts = function()
      -- Get LSP servers from language manager
      local languages = require("core.languages").get_manager()
      local servers = languages.get_lsp_servers()

      return {
        -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
        -- Be aware that you also will need to properly configure your LSP server to
        -- provide the inlay hints.
        inlay_hints = {
          enabled = true,
          exclude = { "rust" }, -- filetypes for which you don't want to enable inlay hints
        },
        -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
        -- Be aware that you also will need to properly configure your LSP server to
        -- provide the code lenses.
        codelens = {
          enabled = true,
        },
        -- add any global capabilities here
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
        -- LSP Server Settings from language manager
        ---@type table<string, vim.lsp.Config>
        servers = servers,
      }
    end,
    config = function(_, opts)
      require("core.lsp").setup(opts)
    end,
  },
}
