local default_opts = { inlay_hints = { enabled = true, exclude = {} }, codelens = { enabled = true } }

local get_lsp_opts = function()
  local plugin = require("lazy.core.config").spec.plugins["nvim-lspconfig"]
  local opts = require("lazy.core.plugin").values(plugin, "opts", false)
  if opts then
    return {
      inlay_hints = vim.tbl_deep_extend("force", {}, opts.inlay_hints),
      codelens = vim.tbl_deep_extend("force", {}, opts.codelens),
    }
  end
  return default_opts
end

return {
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    ft = { "rust" },
    init = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(client, bufnr)
            local opts = get_lsp_opts()
            local func = require("core.lsp").create_on_attach(opts, {})
            func(client, bufnr)
          end,
        },
      }
    end
  }
}
