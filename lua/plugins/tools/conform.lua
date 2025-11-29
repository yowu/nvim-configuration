return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    config = function()
      local languages = require("core.languages").get_manager()
      local formatters_by_ft = languages.get_formatters()

      require("conform").setup {
        formatters_by_ft = formatters_by_ft,
        format_on_save = {
          -- These options will be passed to conform.format()
          timeout_ms = 1500,
          lsp_format = "fallback",
        },
      }

      vim.api.nvim_create_user_command("Format", function()
        require("conform").format { lsp_format = "fallback" }
      end, { desc = "Format file" })
    end,
  },
}
