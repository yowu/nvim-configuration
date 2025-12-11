return {
  -- ============================================================================
  -- Mason - Package manager for LSP servers, DAP, linters, formatters
  -- ============================================================================
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = function()
      return {
        PATH = "skip",
        ui = {
          icons = {
            package_pending = " ",
            package_installed = " ",
            package_uninstalled = " ",
          },
        },
        max_concurrent_installers = 10,
        ensure_installed = require("core.lang-manager").get_mason_tools(),
      }
    end,

    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require "mason-registry"
      mr:on("package:install:success", function()
        -- trigger FileType event to possibly load this newly installed LSP server
        vim.schedule(function()
          vim.api.nvim_exec_autocmds("FileType", {})
        end)
      end)

      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            vim.notify(string.format("Mason installing %s", p.name), vim.log.levels.INFO)
            p:install()
          end
        end
      end)

      -- add mason to path
      local sep = require("core.platform").get_path_separator()
      local delim = require("core.platform").get_path_delimiter()
      vim.env.PATH = table.concat({ vim.fn.stdpath "data", "mason", "bin" }, sep) .. delim .. vim.env.PATH
    end,
  },

  -- ============================================================================
  -- nvim-lspconfig - LSP configuration
  -- ============================================================================
  {
    "neovim/nvim-lspconfig",
    event = "User FilePost",
    cmd = { "LspInfo", "LspLog", "LspStart" },
    dependencies = {
      "williamboman/mason.nvim",
    },
    opts = function()
      return {
        disabled_server_capabilities = {
          "semanticTokensProvider",
        },
        inlay_hints = {
          enabled = true,
          exclude = { "rust", "lua" }, -- filetypes for which you don't want to enable inlay hints
        },
        codelens = {
          enabled = true,
        },
        folding = {
          enabled = false,
        },
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
        ---@type table<string, vim.lsp.Config>
        servers = require("core.lang-manager").get_lsp_servers(),
      }
    end,
    config = function(_, opts)
      require("core.lsp").setup(opts)
    end,
  },

  -- ============================================================================
  -- Conform - Formatter
  -- ============================================================================
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require("conform").setup {
        formatters_by_ft = require("core.lang-manager").get_formatters(),
        format_on_save = {
          timeout_ms = 1500,
          lsp_format = "fallback",
        },
      }

      vim.api.nvim_create_user_command("Format", function()
        require("conform").format { lsp_format = "fallback" }
      end, { desc = "Format file" })
    end,
  },

  -- ============================================================================
  -- Rustaceanvim - Rust LSP enhancements
  -- ============================================================================
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    ft = { "rust" },
  },
}
