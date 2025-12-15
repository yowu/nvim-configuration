---C/C++ language configuration

local clangd = require("core.platform").platform_value {
  windows = "clangd.exe",
  macos = "/usr/local/opt/llvm/bin/clangd",
  linux = "/usr/bin/clangd",
  default = "clangd",
}

local function ignore_clangd()
  local root = vim.fn.getcwd()
  local ok, project = pcall(require, "project_nvim.project")
  if ok then
    root = project.get_project_root()
  end
  return vim.fn.filereadable(root .. "/.ignoreclangd") == 1
end

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
        -- Only start clangd if .ignoreclangd file is not present in the cwd
        root_dir = function(_, on_dir)
          if not ignore_clangd() then
            on_dir(vim.fn.getcwd())
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
