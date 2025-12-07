return {
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = function()
      local languages = require("core.languages").get_manager()
      local tools = languages.get_mason_tools()

      return {
        PATH = "skip",
        ui = {
          icons = {
            package_pending = " ",
            package_installed = " ",
            package_uninstalled = " ",
          },
        },
        max_concurrent_installers = 10,
        ensure_installed = tools,
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
            print(string.format("Installing %s", p.name))
            p:install()
          end
        end
      end)

      -- add mason to path
      local sep = require("core.platform").get_path_separator()
      local delim = require("core.platform").get_path_delimiter()
      vim.env.PATH = table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, sep) ..
          delim .. vim.env.PATH
    end,
  },
}
