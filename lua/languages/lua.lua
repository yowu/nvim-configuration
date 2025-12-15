---Lua language configuration

return {
  name = "lua",
  config = {
    -- LSP configuration
    lsp = {
      lua_ls = {
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.fn.expand "$VIMRUNTIME/lua",
                vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
                vim.fn.stdpath "data" .. "/lazy/lazy.nvim",
                vim.fn.stdpath "data" .. "/lazy/plenary.nvim",
                vim.fn.stdpath "data" .. "/lazy/snacks.nvim",
                "${3rd}/luv/library",
              },
            },
          },
        },
        root_markers = { ".luarc.json", "lazy-lock.json", ".stylua.toml" },
      },
    },

    -- Treesitter parsers
    treesitter = { "lua" },

    -- Formatters
    formatters = { "stylua" },

    -- Mason tools (LSP servers, formatters, etc.)
    tools = { "lua-language-server", "stylua" },

    -- Additional options
    opts = {
      filetypes = { "lua" },
    },
  },
}
