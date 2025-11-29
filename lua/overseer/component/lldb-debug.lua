---@module "overseer.nvim"
---@type overseer.ComponentFileDefinition
local comp = {
  desc = "Launch codelldb to debug the program",
  params = {
    program = {
      type = "string",
      name = "program to debug",
      optional = false,
    },
  },
  constructor = function(params)
    return {
      on_exit = function(_, _, code)
        if code == 0 then
          -- Start the DAP debugger if the build succeeds
          vim.notify("Debug start", vim.log.levels.INFO)
          require("dap").run {
            type = "codelldb",
            request = "launch",
            program = params.program,
            cwd = vim.fn.getcwd(),
            stopOnEntry = false,
            args = {},
            runInTerminal = false,
          }
        else
          vim.notify("Build failed", vim.log.levels.ERROR)
        end
      end,
    }
  end,
}
return comp
