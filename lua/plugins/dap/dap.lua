return {
  "mfussenegger/nvim-dap",
  lazy = true,
  opts = function()
    local languages = require("core.languages").get_manager()
    local configurations = languages.get_dap_configurations()

    return {
      breakpoint = {
        text = "",
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      },
      breakpoint_rejected = {
        text = "",
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      },
      stopped = {
        text = "󰁕",
        texthl = "DiagnosticSignWarn",
        linehl = "Visual",
        numhl = "DiagnosticSignWarn",
      },
      log = {
        level = "info",
      },

      adapters = {
        codelldb = {
          type = "server",
          host = "127.0.0.1",
          port = 13000,
          executable = {
            command = vim.fn.stdpath "data" .. "/mason/packages/codelldb/extension/adapter/codelldb",
            args = { "--port", "13000" },
          },
        },
      },

      configurations = configurations,
    }
  end,

  config = function(_, opts)
    local status_ok, dap = pcall(require, "dap")
    if not status_ok then
      return
    end
    vim.fn.sign_define("DapBreakpoint", opts.breakpoint)
    vim.fn.sign_define("DapBreakpointRejected", opts.breakpoint_rejected)
    vim.fn.sign_define("DapStopped", opts.stopped)
    dap.set_log_level(opts.log.level)

    dap.adapters = opts.adapters
    dap.configurations = opts.configurations
  end,

  keys = {
    -- Function keys
    { "<F5>",  function() require("dap").continue() end,  desc = "Debugger: Start" },
    { "<F17>", function() require("dap").terminate() end, desc = "Debugger: Stop" }, -- Shift+F5
    {
      "<F21>",
      function() -- Shift+F9
        vim.ui.input({ prompt = "Condition: " }, function(condition)
          if condition then require("dap").set_breakpoint(condition) end
        end)
      end,
      desc = "Debugger: Conditional Breakpoint"
    },
    { "<F29>",      function() require("dap").restart_frame() end,            desc = "Debugger: Restart" }, -- Ctrl+F5
    { "<F6>",       function() require("dap").pause() end,                    desc = "Debugger: Pause" },
    { "<F9>",       function() require("dap").toggle_breakpoint() end,        desc = "Debugger: Toggle Breakpoint" },
    { "<F10>",      function() require("dap").step_over() end,                desc = "Debugger: Step Over" },
    { "<F11>",      function() require("dap").step_into() end,                desc = "Debugger: Step Into" },
    { "<F23>",      function() require("dap").step_out() end,                 desc = "Debugger: Step Out" }, -- Shift+F11

    -- Leader+G prefix keymaps
    { "<Leader>GC", function() require("dap").run_to_cursor() end,            desc = "Run To Cursor" },
    { "<Leader>Gb", function() require("dap").step_back() end,                desc = "Step Back" },
    { "<Leader>Gc", function() require("dap").continue() end,                 desc = "Continue" },
    { "<Leader>Gd", function() require("dap").disconnect() end,               desc = "Disconnect" },
    { "<Leader>Gg", function() require("dap").session() end,                  desc = "Get Session" },
    { "<Leader>Gi", function() require("dap").step_into() end,                desc = "Step Into" },
    { "<Leader>Go", function() require("dap").step_over() end,                desc = "Step Over" },
    { "<Leader>Gp", function() require("dap").pause() end,                    desc = "Pause" },
    { "<Leader>Gq", function() require("dap").close() end,                    desc = "Quit" },
    { "<Leader>Gr", function() require("dap").repl.toggle() end,              desc = "Toggle Repl" },
    { "<Leader>Gs", function() require("dap").continue() end,                 desc = "Start" },
    { "<Leader>Gt", function() require("dap").toggle_breakpoint() end,        desc = "Toggle Breakpoint" },
    { "<Leader>Gu", function() require("dap").step_out() end,                 desc = "Step Out" },
    { "<Leader>GU", function() require("dapui").toggle({ reset = true }) end, desc = "Toggle UI" },
  },
}
