-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(
--
local tree_fts = { "neo-tree" }
local function get_tree_width()
  for _, win in pairs(vim.api.nvim_tabpage_list_wins(0)) do
    local ft = vim.bo[vim.api.nvim_win_get_buf(win)].ft
    if vim.tbl_contains(tree_fts, ft) then
      return vim.api.nvim_win_get_width(win) + 1
    end
  end
  return 0
end

local function center_str(str, width)
  if width > #str then
    local pad = math.floor((width - #str) / 2)
    return string.rep(" ", pad) .. str .. string.rep(" ", pad)
  end

  return str
end

---@class ChadrcConfig
local M = {}

M.base46 = {
  theme = "onedark",
  hl_override = {
    FloatBorder = { fg = "black" },
    FloatTitle = { fg = "black2", bg = "red" },
  },
  hl_add = {
    SnacksPicker = { fg = "white", bg = "black" },
    SnacksPickerPrompt = { fg = "red" },
    SnacksPickerBorder = { fg = "black" },
    SnacksPickerTitle = { fg = "black", bg = "red" },
    SnacksPickerPreviewTitle = { fg = "black", bg = "blue" },
    SnacksPickerListCursorLine = { bg = "black2" },

    WhichKeyNormal = { bg = "one_bg" },
    SnacksInputBorder = { link = "SnacksPickerBorder" },
    SnacksInputTitle = { link = "SnacksPickerTitle" },

    SnacksScratchKey = { fg = "green", bg = "black2" },
    SnacksScratchTitle = { link = "SnacksPickerTitle" },
    SnacksScratchDesc = { bg = "black2" },
    SnacksScratchFooter = { bg = "black2" },

    SnacksDashboardDesc = { fg = "grey_fg2" },
    SnacksDashboardIcon = { fg = "grey_fg2" },
    SnacksDashboardSpecial = { fg = "white" },

    SnacksIndent1 = { fg = "darker_black" },
    SnacksIndent = { fg = "one_bg2" },

    RgFlowHead = { fg = "grey_fg2", bg = "black" },
    RgFlowHeadLine = { fg = "black", bg = "black" },

    NeoTreeRootName = { bold = true },
    NeoTreeGitUntracked = { link = "NeoTreeDotfile" },
    NeoTreeGitConflict = { bold = true, fg = "red" },
    NeoTreeTitleBar = { link = "@comment.danger" },
    NeoTreeFloatTitle = { link = "@comment.danger" },
  },
}

M.ui = {
  cmp = { style = "flat_light" },

  statusline = {
    theme = "default",
    separator_style = "block",
    order = { "mode", "file", "git", "%=", "diagnostics", "lsp", "cursor", "cwd" },
  },

  tabufline = {
    order = { "tree", "buffers", "tabs", "btns" },
    modules = {
      tree = function()
        local title = " Explorer"
        local tree_width = get_tree_width()
        if tree_width > #title then
          return "%#TbFill#" .. center_str(title, tree_width)
        end
        return ""
      end,
    },
  },
}

M.nvdash = {
  load_on_startup = false,
}

M.term = {
  sizes = { sp = 0.3, vsp = 0.4, ["bo sp"] = 0.3, ["bo vsp"] = 0.4 },
  float = {
    relative = "editor",
    row = 0.2,
    col = 0.1,
    width = 0.8,
    height = 0.6,
    border = "single",
  },
}

return M
