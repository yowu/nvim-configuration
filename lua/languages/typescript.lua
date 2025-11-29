---TypeScript/JavaScript language configuration

return {
  name = "typescript",
  config = {
    -- LSP configuration
    lsp = {
      vtsls = {
        settings = {
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            inlayHints = {
              parameterNames = { enabled = "all" },
              parameterTypes = { enabled = true },
              variableTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              enumMemberValues = { enabled = true },
            },
          },
          javascript = {
            updateImportsOnFileMove = { enabled = "always" },
            inlayHints = {
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              variableTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              enumMemberValues = { enabled = true },
            },
          },
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
        },
      },
      -- Need manual install: npm i -g vscode-langservers-extracted
      eslint = true,
    },

    -- Treesitter parsers
    treesitter = { "typescript", "javascript", "tsx", "jsdoc" },

    -- Formatters
    formatters = { "prettier" },

    -- Mason tools
    tools = { "vtsls", "prettier", "eslint_d" },

    -- Additional options
    opts = {
      filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "json", "jsonc", "css", "html" },
    },
  },
}
