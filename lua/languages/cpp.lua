---C/C++ language configuration

local is_win32 = require("core.platform").is_windows()
local clangd = require("core.platform").platform_value {
  windows = "clangd.exe",
  macos = "/usr/local/opt/llvm/bin/clangd",
  linux = "/usr/bin/clangd",
  default = "clangd",
}
local ignore_files = { ".clangdignore", ".tmpignore" }

return {
  name = "cpp",
  config = {
    -- LSP configuration
    lsp = {
      clangd = {
        cmd = {
          clangd,
          "--background-index",
        },
        capabilities = {
          offsetEncoding = "utf-8",
        },
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            for _, ignore_file in ipairs(ignore_files) do
              if vim.fn.filereadable(path .. "/" .. ignore_file) == 1 then
                client.stop(not is_win32)
                break
              end
            end
          end
        end,
      },
      neocmake = {},
    },

    -- Treesitter parsers
    treesitter = { "c", "cpp", "cmake" },

    -- Mason tools
    tools = { "clangd", "codelldb", "neocmakelsp" },

    -- DAP configuration
    dap = {
      configurations = {
        {
          type = "codelldb",
          request = "launch",
          name = "Launch file",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
        },
        {
          type = "codelldb",
          request = "attach",
          name = "Attach to process",
          pid = function()
            -- Lazy load dap.utils to avoid early require issues
            return require("dap.utils").pick_process()
          end,
          cwd = "${workspaceFolder}",
        },
      },
    },

    -- Additional options
    opts = {
      filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    },
  },
}
