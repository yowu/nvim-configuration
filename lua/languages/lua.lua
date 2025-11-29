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

        on_init = function(client)
          local is_windows = require("core.platform").is_windows()
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if not vim.uv.fs_stat(path .. "/lazy-lock.json") and not vim.uv.fs_stat(path .. "/.luarc.json") then
              client.stop(not is_windows)
            end
          end
        end,
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
