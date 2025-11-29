return {
  "saghen/blink.cmp",
  version = "1.*",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "rafamadriz/friendly-snippets",
  },

  opts_extend = { "sources.default" },
  ---@module 'blink.cmp'
  opts = {

    enabled = function()
      -- disable blink in certain filetypes
      local disabled_filetypes = {
        "rgflow",
      }

      return not vim.tbl_contains(disabled_filetypes, vim.bo.filetype)
    end,

    appearance = {
      nerd_font_variant = "mono",
    },
    sources = {
      default = { "lsp", "buffer", "snippets", "path" },
      min_keyword_length = function(ctx)
        -- trigger completion on space in cmdline mode
        if ctx.mode == "cmdline" and string.find(ctx.line, " ") ~= nil then
          return 0
        end
        -- by default it is 2
        return 2
      end,
    },

    keymap = {
      preset = "default",
      ["<Up>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<Down>"] = { "select_next", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<PageUp>"] = { "scroll_documentation_up", "fallback" },
      ["<PageDown>"] = { "scroll_documentation_down", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<Esc>"] = { "cancel", "fallback" },
      ["<Tab>"] = {
        function()
          local copilot = require "copilot.suggestion"
          if copilot.is_visible() then
            copilot.accept()
            return true
          end
        end,
        "select_next",
        "snippet_forward",
        "fallback",
      },
    },
    completion = {
      list = {
        selection = {
          auto_insert = function(ctx)
            return ctx.mode == "cmdline"
          end,
          preselect = false,
        },
      },
      menu = {
        scrollbar = false,
        border = "none",
        draw = {
          columns = { { "label" }, { "kind_icon" }, { "kind" } },
          components = {
            kind_icon = {
              text = function(ctx)
                local icons = require "nvchad.icons.lspkind"
                local icon = icons[ctx.kind] or ctx.kind_icon
                return icon .. ctx.icon_gap
              end,
            },
          },
        },
      },
      accept = {
        auto_brackets = { enabled = true },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = { border = "single" },
      },
    },
    cmdline = {
      keymap = {
        ["<Tab>"] = { "accept", "show" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
      },
      completion = { menu = { auto_show = true } },
    },
  },
  config = function(_, opts)
    dofile(vim.g.base46_cache .. "blink")
    require("blink.cmp").setup(opts)
  end,
}
