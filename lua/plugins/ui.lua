-- Snacks picker layout configuration
local layout_map = {
  select = { "files", "git_files", "buffers", "recent", "projects", "smart", "pickers", "commands" },
  right = { "lsp_symbols", "lsp_workspace_symbols" },
}

local layout_lookup = {}
for layout_type, sources in pairs(layout_map) do
  for _, source in ipairs(sources) do
    layout_lookup[source] = layout_type
  end
end

return {
  -- ============================================================================
  -- NvChad UI - Theme, statusline, tabufline, terminal
  -- ============================================================================
  {
    "nvchad/ui",
    lazy = false,
    config = function()
      vim.api.nvim_create_user_command("NvThemes", function()
        require("nvchad.themes").open()
      end, { desc = "Toggle themes" })
      require("base46").load_all_highlights()
      require "nvchad"
    end,

    keys = {
      {
        "]b",
        function()
          require("nvchad.tabufline").next()
        end,
        desc = "Buffer goto next",
      },
      {
        "[b",
        function()
          require("nvchad.tabufline").prev()
        end,
        desc = "Buffer goto prev",
      },
      {
        "<C-q>",
        function()
          require("nvchad.tabufline").close_buffer()
        end,
        desc = "Buffer close",
      },
      {
        "<A-|>",
        function()
          require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }
        end,
        mode = { "n", "t" },
        desc = "Toggle vertical term",
      },
      {
        "<A-\\>",
        function()
          require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
        end,
        mode = { "n", "t" },
        desc = "Toggle horizontal term",
      },
      {
        "<A-`>",
        function()
          require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
        end,
        mode = { "n", "t" },
        desc = "Toggle floating term",
      },
      {
        "<C-`>",
        function()
          require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
        end,
        mode = { "n", "t" },
        desc = "Toggle term",
      },
    },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/plenary.nvim",
      "nvchad/base46",
      "nvzone/volt",
    },
    specs = {
      {
        "nvchad/base46",
        branch = "v3.0",
      },
    },
  },

  -- ============================================================================
  -- Snacks.nvim - Picker, input, rename, scratch
  -- ============================================================================
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      input = { enable = true },
      rename = { enable = true },
      scope = { enable = true },
      scratch = {
        icon = "󱇨 ",
        win = {
          style = {
            wo = {
              winhighlight = "NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder",
            },
          },
        },
      },
      picker = {
        ui_select = true,
        layout = function(source)
          local layout_type = layout_lookup[source] or "ivy_split"
          return { preset = layout_type, layout = { backdrop = true } }
        end,
        sources = {
          explorer = {
            layout = {
              layout = {
                position = "left",
                width = 30,
                min_width = 30,
                height = 0,
                border = "none",
                box = "vertical",
                { win = "list", border = "none" },
                {
                  win = "input",
                  height = 1,
                  title = "{title} {live} {flags}",
                  title_pos = "center",
                },
              },
              auto_hide = { "input" },
            },
          },
        },
      },
    },

    config = function(_, opts)
      require("snacks").setup(opts)
      vim.api.nvim_create_user_command("SnacksScratch", function()
        Snacks.scratch()
      end, { desc = "Snacks scratchpad" })
    end,

    keys = {
      -- Leader prefix
      {
        "<Leader>b",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<Leader>d",
        function()
          Snacks.picker.diagnostics()
        end,
        desc = "Diagnostics",
      },
      {
        "<Leader>D",
        function()
          Snacks.picker.diagnostics { workspace = true }
        end,
        desc = "Diagnostics for workspace",
      },
      {
        "<Leader>f",
        function()
          Snacks.picker.files()
        end,
        desc = "Files",
      },
      {
        "<Leader>F",
        function()
          Snacks.picker.files { cwd = vim.fn.expand "%:p:h" }
        end,
        desc = "Files under current directory",
      },
      {
        "<Leader>j",
        function()
          Snacks.picker.jumps()
        end,
        desc = "Jumplist",
      },
      {
        "<Leader>p",
        function()
          require("extras.pickers.project").picker()
        end,
        desc = "Projects",
      },
      {
        "<Leader>r",
        function()
          Snacks.picker.recent()
        end,
        desc = "Recent files",
      },
      {
        "<Leader>s",
        function()
          Snacks.picker.lsp_symbols()
        end,
        desc = "Document symbols",
      },
      {
        "<Leader>S",
        function()
          Snacks.picker.lsp_workspace_symbols()
        end,
        desc = "Workspace symbols",
      },
      {
        "<Leader>'",
        function()
          Snacks.picker.resume()
        end,
        desc = "Resume last picker",
      },
      {
        "<Leader>,",
        function()
          Snacks.picker.files { cwd = vim.fn.stdpath "config" }
        end,
        desc = "Edit config",
      },
      {
        "<Leader>?",
        function()
          Snacks.picker.commands()
        end,
        desc = "Commands",
      },
      {
        "<Leader><space>",
        function()
          Snacks.picker()
        end,
        desc = "Pickers",
      },
      -- Ctrl keys
      {
        "<C-p>",
        function()
          Snacks.picker.smart()
        end,
        desc = "Smart find file",
      },
      {
        "<C-\\>",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Find buffer",
      },
      {
        "<C-/>",
        function()
          Snacks.picker.resume()
        end,
        desc = "Resume last search",
      },
      -- Goto keymaps
      {
        "<LocalLeader>ga",
        function()
          require("extras.alternate").find_alternate()
        end,
        desc = "Goto alternate files",
      },
      {
        "<LocalLeader>gf",
        function()
          Snacks.picker.files { cmd = "fd", args = { "-g", vim.fn.expand "<cfile>" }, auto_confirm = true }
        end,
        desc = "Goto file",
      },
      -- Tags navigation (ctags)
      {
        "g]",
        function()
          require("extras.pickers.tags").picker { tag = vim.fn.expand "<cword>" }
        end,
        desc = "Goto tag",
      },
      {
        "g.",
        function()
          local word = vim.fn.expand "<cword>"
          local buf = vim.fn.expand "%:t"
          local root = buf:match "[^.]+"
          require("extras.pickers.tags").picker { tag = word, args = { "-Q", [[(substr? $input "/]] .. root .. [[.")]] } }
        end,
        desc = "Goto tag locally",
      },
      {
        "g,",
        function()
          local word = vim.fn.expand "<cword>"
          local buf = vim.fn.expand "%:t"
          local root = buf:match "[^.]+"
          require("extras.pickers.tags").picker {
            tag = word,
            args = { "-Q", [[(substr? $input "/]] .. root .. [[.")]], "-p" },
          }
        end,
        desc = "Goto related tags locally",
      },
      {
        "g/",
        function()
          vim.ui.input({ prompt = "Search for tag: " }, function(input)
            if input and #input > 0 then
              require("extras.pickers.tags").picker { tag = input, args = { "-p", "-i" } }
            end
          end)
        end,
        desc = "Search for tag",
      },
    },
    specs = {
      {
        "nvim-neo-tree/neo-tree.nvim",
        optional = true,
        opts = function(_, opts)
          local function on_move(data)
            Snacks.rename.on_rename_file(data.source, data.destination)
          end
          local events = require "neo-tree.events"
          opts.event_handlers = opts.event_handlers or {}
          vim.list_extend(opts.event_handlers, {
            { event = events.FILE_MOVED, handler = on_move },
            { event = events.FILE_RENAMED, handler = on_move },
          })
        end,
      },
    },
  },

  -- ============================================================================
  -- Neo-tree - File explorer
  -- ============================================================================
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    opts = {
      auto_clean_after_session_restore = true,
      close_if_last_window = true,
      enable_diagnostics = false,
      popup_border_style = "single",
      sources = { "filesystem" },
      default_component_configs = {
        git_status = {
          symbols = {
            ignored = "◌",
            untracked = "󰹢",
            unstaged = "󱇨",
            staged = "󰈖",
          },
        },
      },
      window = {
        width = 30,
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
      },
    },
    keys = {
      {
        "<Leader>o",
        function()
          if vim.bo.filetype == "neo-tree" then
            vim.cmd.wincmd "p"
          else
            vim.cmd.Neotree "focus"
          end
        end,
        desc = "Toggle Explorer Focus",
      },
    },
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "MunifTanjim/nui.nvim" },
    },
  },

  -- ============================================================================
  -- Indent Blankline - Indentation guides
  -- ============================================================================
  {
    "lukas-reineke/indent-blankline.nvim",
    cmd = { "IBLEnable", "IBLDisable", "IBLToggle", "IBLEnableScope", "IBLDisableScope", "IBLToggleScope" },
    event = "User FilePost",
    opts = {
      indent = { char = "┊" },
      scope = { char = "│" },
      exclude = {
        buftypes = {
          "nofile",
          "prompt",
          "quickfix",
          "terminal",
        },
        filetypes = {
          "aerial",
          "alpha",
          "dashboard",
          "help",
          "lazy",
          "mason",
          "neo-tree",
          "nvdash",
          "NvimTree",
          "neogitstatus",
          "notify",
          "startify",
          "toggleterm",
          "Trouble",
        },
      },
    },
    config = function(_, opts)
      local hooks = require "ibl.hooks"
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
      require("ibl").setup(opts)
    end,
  },

  -- ============================================================================
  -- Fidget - LSP progress and notifications
  -- ============================================================================
  {
    "j-hui/fidget.nvim",
    opts = {
      notification = {
        override_vim_notify = true,
      },
    },
    event = "VeryLazy",
  },
}
