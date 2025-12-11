return {
  -- ============================================================================
  -- Blink.cmp - Completion
  -- ============================================================================
  {
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
          -- trigger completion off space in cmdline mode
          if ctx.mode == "cmdline" and string.find(ctx.line, " ") ~= nil then
            return -1
          end
          -- by default it is 1
          return 1
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
            local ok, copilot = pcall(require, "copilot.suggestion")
            if ok and copilot.is_visible() then
              copilot.accept()
              return false
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
            preselect = true,
          },
        },
        menu = {
          scrollbar = true,
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
          auto_brackets = { enabled = false },
        },
        documentation = {
          auto_show = false,
          auto_show_delay_ms = 199,
          window = { border = "single" },
        },
      },
      cmdline = {
        keymap = {
          ["<Tab>"] = { "accept", "show" },
          ["<Up>"] = { "select_prev", "fallback" },
          ["<Down>"] = { "select_next", "fallback" },
        },
        completion = { menu = { auto_show = false } },
      },
    },
  },
}
