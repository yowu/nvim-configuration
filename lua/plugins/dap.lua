return {
  -- ============================================================================
  -- nvim-dap - Debug Adapter Protocol client
  -- ============================================================================
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    opts = function()
      local lang_manager = require("core.lang-manager")
      local configurations = lang_manager.get_dap_configurations()

      return {
        breakpoint = {
          text = "",
          texthl = "DiagnosticSignError",
          linehl = "",
          numhl = "",
        },
        breakpoint_rejected = {
          text = "",
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
              command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
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
      { "<F5>", function() require("dap").continue() end, desc = "Debugger: Start" },
      { "<F17>", function() require("dap").terminate() end, desc = "Debugger: Stop" }, -- Shift+F5
      {
        "<F21>", -- Shift+F9
        function()
          vim.ui.input({ prompt = "Condition: " }, function(condition)
            if condition then
              require("dap").set_breakpoint(condition)
            end
          end)
        end,
        desc = "Debugger: Conditional Breakpoint",
      },
      { "<F29>", function() require("dap").restart_frame() end, desc = "Debugger: Restart" }, -- Ctrl+F5
      { "<F6>", function() require("dap").pause() end, desc = "Debugger: Pause" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debugger: Toggle Breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debugger: Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debugger: Step Into" },
      { "<F23>", function() require("dap").step_out() end, desc = "Debugger: Step Out" }, -- Shift+F11

      -- Leader+G prefix keymaps
      { "<Leader>GC", function() require("dap").run_to_cursor() end, desc = "Run To Cursor" },
      { "<Leader>Gb", function() require("dap").step_back() end, desc = "Step Back" },
      { "<Leader>Gc", function() require("dap").continue() end, desc = "Continue" },
      { "<Leader>Gd", function() require("dap").disconnect() end, desc = "Disconnect" },
      { "<Leader>Gg", function() require("dap").session() end, desc = "Get Session" },
      { "<Leader>Gi", function() require("dap").step_into() end, desc = "Step Into" },
      { "<Leader>Go", function() require("dap").step_over() end, desc = "Step Over" },
      { "<Leader>Gp", function() require("dap").pause() end, desc = "Pause" },
      { "<Leader>Gq", function() require("dap").close() end, desc = "Quit" },
      { "<Leader>Gr", function() require("dap").repl.toggle() end, desc = "Toggle Repl" },
      { "<Leader>Gs", function() require("dap").continue() end, desc = "Start" },
      { "<Leader>Gt", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<Leader>Gu", function() require("dap").step_out() end, desc = "Step Out" },
      { "<Leader>GU", function() require("dapui").toggle({ reset = true }) end, desc = "Toggle UI" },
    },
  },

  -- ============================================================================
  -- nvim-dap-ui - UI for nvim-dap
  -- ============================================================================
  {
    "rcarriga/nvim-dap-ui",
    lazy = true,
    dependencies = {
      "mfussenegger/nvim-dap",
      { "nvim-neotest/nvim-nio", lazy = true },
    },
    opts = {
      icons = { expanded = "", collapsed = "", circular = "" },
      mappings = {
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
      element_mappings = {},
      expand_lines = true,
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.33 },
            { id = "breakpoints", size = 0.17 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 0.33,
          position = "right",
        },
        {
          elements = {
            { id = "repl", size = 0.45 },
            { id = "console", size = 0.55 },
          },
          size = 0.27,
          position = "bottom",
        },
      },
      controls = {
        enabled = true,
        element = "repl",
        icons = {
          pause = "",
          play = "",
          step_into = "",
          step_over = "",
          step_out = "",
          step_back = "",
          run_last = "",
          terminate = "",
        },
      },
      floating = {
        max_height = 0.9,
        max_width = 0.5,
        border = "rounded",
        mappings = {
          close = { "q", "<Esc>" },
        },
      },
      windows = { indent = 1 },
      render = {
        max_type_length = nil,
        max_value_lines = 100,
      },
    },
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)

      dap.listeners.after.event_initialized.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
}
