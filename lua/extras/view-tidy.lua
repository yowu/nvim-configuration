local M = {}

-- Utility function to map filetypes to custom buftypes
local function map_filetype_to_buftype(filetype, bufname)
  local filetype_map = {
    Telescope = "telescope",
    dashboard = "dashboard",
    alpha = "dashboard",
    nvdash = "dashboard",
    ["neo-tree"] = "tree",
    NvimTree = "tree",
    codecompanion = "codecompanion",
    OverseerForm = "overseer",
  }

  -- Check for specific filetypes
  for pattern, buftype in pairs(filetype_map) do
    if filetype and filetype:match(pattern) then
      return buftype
    end
  end

  -- Handle special cases based on buffer name
  if filetype == "lua" and bufname:find "luapad.lua" then
    return "luapad"
  end

  if filetype == "lua" and bufname:find "scratch" then
    return "luapad"
  end

  if bufname:find "diffview://" then
    return "diffview"
  end

  -- Default to the original buftype
  return nil
end

-- Function to determine the buffer type of a window
local function get_win_buftype(winnr)
  local bufnr = vim.fn.winbufnr(winnr)
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  local bufname = vim.api.nvim_buf_get_name(bufnr):lower()

  -- Map filetype to custom buftype if applicable
  local custom_buftype = map_filetype_to_buftype(filetype, bufname)
  if custom_buftype then
    return custom_buftype
  end

  -- Fallback to the actual buftype
  return vim.api.nvim_get_option_value("buftype", { buf = bufnr })
end

-- Define buffer type categories
local disabled_buftypes = { "codecompanion", "telescope", "terminal", "luapad", "diffview", "dashboard", "overseer" }
local prioritized_buftypes = { "help", "quickfix", "nofile" }
local secondary_priority_buftypes = { "tree" }

-- Function to clean up the view by closing windows
local function clean_view()
  local winnr = vim.fn.winnr "$"

  if winnr == 1 then
    return
  end

  local secondary_priority_candidates = {}
  local disabled_candidates = {}

  -- Close prioritized buftypes if possible
  for index = 1, winnr do
    local buftype = get_win_buftype(index)
    if vim.tbl_contains(prioritized_buftypes, buftype) then
      vim.cmd(index .. "wincmd c")
      return
    end

    if vim.tbl_contains(secondary_priority_buftypes, buftype) then
      table.insert(secondary_priority_candidates, index)
    elseif vim.tbl_contains(disabled_buftypes, buftype) then
      table.insert(disabled_candidates, index)
    end
  end

  -- Close secondary priority candidates if available
  if #secondary_priority_candidates > 0 then
    vim.cmd(secondary_priority_candidates[1] .. "wincmd c")
    return
  end

  -- Do nothing if only disabled candidates are present
  if #disabled_candidates > 0 then
    return
  end

  -- Close the active window as a last resort
  vim.api.nvim_win_close(0, false)
end

-- Function to clean the view and clear search highlights
function M.clean()
  -- Try to clear search highlights first
  if vim.fn.getreg "/" ~= "" then
    vim.fn.setreg("/", "")
    return
  end

  clean_view()
end

function M.setup()
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("ViewTidy", { clear = true }),
    desc = "Clear last search",
    callback = function()
      vim.cmd "let @/ = ''"
    end,
  })

  vim.keymap.set("n", "<Esc><Esc>", M.clean, { desc = "which_key_ignore" })
end

return M
