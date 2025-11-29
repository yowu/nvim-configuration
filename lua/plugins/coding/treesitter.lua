return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    opts_extend = { "ensure_installed" },
    opts = function()
      -- Get parsers from language manager
      local languages = require("core.languages").get_manager()
      local parsers = languages.get_treesitter_parsers()

      -- Add base parsers that are always needed
      local base_parsers = { "lua", "vim", "regex" }
      for _, parser in ipairs(base_parsers) do
        if not vim.tbl_contains(parsers, parser) then
          table.insert(parsers, parser)
        end
      end

      return {
        ensure_installed = parsers,
      }
    end,
    config = function(_, opts)
      pcall(function()
        dofile(vim.g.base46_cache .. "syntax")
        dofile(vim.g.base46_cache .. "treesitter")
      end)
      local treesitter = require('nvim-treesitter')
      treesitter.setup({
        install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site"),
      })

      vim.defer_fn(function()
        -- Calls `install()` only if there are missing parsers.
        local installed = treesitter.get_installed()
        local not_installed = vim.tbl_filter(
          function(parser) return not vim.tbl_contains(installed, parser) end,
          opts.ensure_installed
        )
        if #not_installed > 0 then
          treesitter.install(not_installed,
            {
              force = false,   -- force installation of already installed parsers
              generate = true, -- generate `parser.c` from `grammar.json` or `grammar.js` before compiling.
              max_jobs = 4,    -- limit parallel tasks (useful in combination with {generate} on memory-limited systems).
              summary = true,  -- print summary of successful and total operations for multiple languages.
            })
        end
      end, 0)

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          if vim.list_contains(
                treesitter.get_installed(),
                vim.treesitter.language.get_lang(args.match)
              )
          then
            vim.treesitter.start(args.buf)
          end
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    opts = {
      select = {
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        -- You can choose the select mode (default is charwise 'v')
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * method: eg 'v' or 'o'
        -- and should return the mode ('v', 'V', or '<c-v>') or a table
        -- mapping query_strings to modes.
        selection_modes = {
          ['@parameter.outer'] = 'v', -- charwise
          ['@function.outer'] = 'V',  -- linewise
          ['@class.outer'] = '<c-v>', -- blockwise
        },
        -- If you set this to `true` (default is `false`) then any textobject is
        -- extended to include preceding or succeeding whitespace. Succeeding
        -- whitespace has priority in order to act similarly to eg the built-in
        -- `ap`.
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * selection_mode: eg 'v'
        -- and should return true of false
        include_surrounding_whitespace = false,
      },
      move = {
        set_jumps = true,
      },
    },
    config = function()
      local map = vim.keymap.set
      local select = require('nvim-treesitter-textobjects.select')
      local move = require('nvim-treesitter-textobjects.move')

      local function set_select(lhs, capture, group, desc)
        map({ 'n', 'x', 'o' }, lhs, function()
          select.select_textobject(capture, group)
        end, { desc = desc })
      end

      local function set_move(lhs, method, capture, group, desc)
        map({ 'n', 'x', 'o' }, lhs, function()
          move[method](capture, group)
        end, { desc = desc })
      end

      local selects = {
        { 'af', '@function.outer', 'textobjects', 'Select around function' },
        { 'if', '@function.inner', 'textobjects', 'Select inside function' },
        { 'ac', '@class.outer',    'textobjects', 'Select around class' },
        { 'ic', '@class.inner',    'textobjects', 'Select inside class' },
        { 'as', '@local.scope',    'locals',      'Select around scope' },
      }

      for _, spec in ipairs(selects) do
        set_select(spec[1], spec[2], spec[3], spec[4])
      end

      local moves = {
        { ']m', 'goto_next_start',     '@function.outer',                'textobjects', 'Next function start' },
        { ']]', 'goto_next_start',     '@class.outer',                   'textobjects', 'Next class start' },
        { ']o', 'goto_next_start',     { '@loop.inner', '@loop.outer' }, 'textobjects', 'Next loop start' },
        { ']s', 'goto_next_start',     '@local.scope',                   'locals',      'Next scope start' },
        { ']z', 'goto_next_start',     '@fold',                          'folds',       'Next fold start' },
        { ']M', 'goto_next_end',       '@function.outer',                'textobjects', 'Next function end' },
        { '][', 'goto_next_end',       '@class.outer',                   'textobjects', 'Next class end' },
        { '[m', 'goto_previous_start', '@function.outer',                'textobjects', 'Previous function start' },
        { '[[', 'goto_previous_start', '@class.outer',                   'textobjects', 'Previous class start' },
        { '[M', 'goto_previous_end',   '@function.outer',                'textobjects', 'Previous function end' },
        { '[]', 'goto_previous_end',   '@class.outer',                   'textobjects', 'Previous class end' },
        { ']d', 'goto_next',           '@conditional.outer',             'textobjects', 'Next conditional' },
        { '[d', 'goto_previous',       '@conditional.outer',             'textobjects', 'Previous conditional' },
      }

      for _, spec in ipairs(moves) do
        set_move(spec[1], spec[2], spec[3], spec[4], spec[5])
      end
    end,
  },
}
