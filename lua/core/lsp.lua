---@class LspServerConfig: vim.lsp.Config
---@field enabled? boolean Whether this LSP server is enabled (default: true)

---@alias LspCapability
---| "semanticTokensProvider"
---| "documentHighlightProvider"
---| "documentFormattingProvider"
---| "documentRangeFormattingProvider"
---| "hoverProvider"
---| "completionProvider"
---| "signatureHelpProvider"
---| "definitionProvider"
---| "typeDefinitionProvider"
---| "implementationProvider"
---| "referencesProvider"
---| "documentSymbolProvider"
---| "workspaceSymbolProvider"
---| "codeActionProvider"
---| "codeLensProvider"
---| "declarationProvider"
---| "renameProvider"
---| "foldingRangeProvider"
---| "inlayHintProvider"

---@class GlobalLspConfig
---@field inlay_hints? { enabled: boolean, exclude: string[] } Inlay hint settings
---@field codelens? { enabled: boolean } Code lens settings
---@field folding? { enabled: boolean } Fold settings
---@field capabilities? table Additional LSP capabilities
---@field disabled_server_capabilities? LspCapability[] List of server capabilities to disable

---@class LspConfig: GlobalLspConfig
---@field servers table<string, LspServerConfig|boolean> LSP server configurations (true for default config)

---@class CoreLspModule
local M = {}

-- Default LSP keymappings
-- Note: Some keymaps are created unconditionally when Nvim starts:
-- "grn" - vim.lsp.buf.rename()
-- "gra" - vim.lsp.buf.code_action() (Normal and Visual)
-- "grr" - vim.lsp.buf.references()
-- "gri" - vim.lsp.buf.implementation()
-- "gO"  - vim.lsp.buf.document_symbol()
-- CTRL-S - vim.lsp.buf.signature_help() (Insert mode)
-- "K"   - vim.lsp.buf.hover() (Neovim 0.10+)

---Setup LSP keymappings for a buffer
---@param bufnr integer Buffer number
local function setup_keymaps(bufnr)
  local function opts(desc)
    return { buffer = bufnr, desc = "LSP " .. desc }
  end

  local map = vim.keymap.set

  -- Navigation
  map("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
  map("n", "<F12>", vim.lsp.buf.definition, opts("Go to definition"))
  map("n", "gy", vim.lsp.buf.type_definition, opts("Goto T[y]pe Definition"))
  map("n", "gD", vim.lsp.buf.declaration, opts("Goto Declaration"))

  -- Actions
  map("n", "<F2>", vim.lsp.buf.rename, opts("Rename"))
  map("n", "grl", vim.lsp.codelens.run, opts("CodeLens Action"))
end

---Disable specific server capabilities
---@param client vim.lsp.Client
---@param disabled_capabilities? LspCapability[]
local function disable_server_capabilities(client, disabled_capabilities)
  local to_disable = disabled_capabilities or {}
  for _, capability in ipairs(to_disable) do
    if client.server_capabilities[capability] ~= nil then
      client.server_capabilities[capability] = nil
    end
  end
end

---Check if buffer is valid for LSP features
---@param bufnr integer
---@return boolean
local function is_lsp_eligible_buffer(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == ""
end

---Setup inlay hints for a buffer
---@param client vim.lsp.Client
---@param bufnr integer
---@param config { enabled: boolean, exclude?: string[] }
local function setup_inlay_hints(client, bufnr, config)
  if not config.enabled then
    return
  end

  if not client:supports_method("textDocument/inlayHint") then
    return
  end

  if not is_lsp_eligible_buffer(bufnr) then
    return
  end

  local exclude = config.exclude or {}
  local filetype = vim.bo[bufnr].filetype

  if vim.tbl_contains(exclude, filetype) then
    return
  end

  vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
end

---Setup code lens for a buffer
---@param client vim.lsp.Client
---@param bufnr integer
---@param config { enabled: boolean }
local function setup_codelens(client, bufnr, config)
  if not config.enabled then
    return
  end

  if not vim.lsp.codelens then
    return
  end

  if not client:supports_method("textDocument/codeLens") then
    return
  end

  -- Initial refresh
  vim.lsp.codelens.refresh({ bufnr = bufnr })

  -- Use buffer-specific augroup name to avoid clearing other buffers' autocmds
  local group_name = string.format("CoreLspCodeLens_%d", bufnr)
  local group = vim.api.nvim_create_augroup(group_name, { clear = true })

  vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
    group = group,
    buffer = bufnr,
    callback = function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.lsp.codelens.refresh({ bufnr = bufnr })
      end
    end,
    desc = "Refresh code lens",
  })

  -- Clean up augroup when buffer is deleted
  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    buffer = bufnr,
    callback = function()
      pcall(vim.api.nvim_del_augroup_by_name, group_name)
    end,
    desc = "Clean up code lens augroup",
  })
end

---Setup LSP folding for a buffer
---@param client vim.lsp.Client
---@param bufnr integer
---@param config { enabled: boolean }
local function setup_folding(client, bufnr, config)
  if not config.enabled then
    return
  end

  if type(vim.lsp.foldexpr) ~= "function" then
    return
  end

  if not client:supports_method("textDocument/foldingRange") then
    return
  end

  local winid = vim.fn.bufwinid(bufnr)
  vim.api.nvim_set_option_value("foldmethod", "expr", { win = winid })
  vim.api.nvim_set_option_value("foldexpr", "v:lua.vim.lsp.foldexpr()", { win = winid })
end

---Setup LSP features for a buffer
---@param client vim.lsp.Client
---@param opts GlobalLspConfig Global LSP configuration
---@param bufnr integer Buffer number
local function setup_lsp_features(client, opts, bufnr)
  if opts.inlay_hints then
    setup_inlay_hints(client, bufnr, opts.inlay_hints)
  end

  if opts.codelens then
    setup_codelens(client, bufnr, opts.codelens)
  end

  if opts.folding then
    setup_folding(client, bufnr, opts.folding)
  end
end

---@param opts GlobalLspConfig
local function register_lsp_attach_autocmd(opts)
  local group = vim.api.nvim_create_augroup("CoreLspAttach", { clear = true })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local bufnr = args.buf

      if not client then
        return
      end

      -- Disable capabilities first, before setting up features that may depend on them
      disable_server_capabilities(client, opts.disabled_server_capabilities)
      setup_keymaps(bufnr)
      setup_lsp_features(client, opts, bufnr)
    end,
  })
end

---Get default LSP capabilities
--- @param opts GlobalLspConfig
---@return table
local function build_global_capabilities(opts)
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Integrate with blink.cmp if available
  local has_blink, blink = pcall(require, "blink.cmp")
  if has_blink and blink.get_lsp_capabilities then
    capabilities = vim.tbl_deep_extend("force", capabilities, blink.get_lsp_capabilities())
  end

  if opts.capabilities then
    capabilities = vim.tbl_deep_extend("force", capabilities, opts.capabilities)
  end

  return capabilities
end

---Configure and enable a single LSP server
---@param server_name string
---@param server_opts LspServerConfig|boolean
---@param global_capabilities table
local function setup_lsp_server(server_name, server_opts, global_capabilities)
  -- Skip if server is falsy (false or nil)
  if not server_opts then
    return
  end

  -- Convert `true` to empty config table
  local config = server_opts == true and {} or vim.deepcopy(server_opts)

  -- Check if server is explicitly disabled
  if config.enabled == false then
    return
  end

  -- Remove our custom field before passing to vim.lsp.config
  config.enabled = nil

  -- Merge capabilities
  config.capabilities = vim.tbl_deep_extend(
    "force",
    {},
    global_capabilities,
    config.capabilities or {}
  )

  -- Register and enable the LSP server
  vim.lsp.config(server_name, config)
  vim.lsp.enable(server_name)
end

---Main LSP setup function
---@param opts LspConfig
function M.setup(opts)
  opts = opts or {}
  opts.servers = opts.servers or {}

  register_lsp_attach_autocmd(opts)

  local global_capabilities = build_global_capabilities(opts)
  -- Setup each LSP server
  for server_name, server_opts in pairs(opts.servers) do
    setup_lsp_server(server_name, server_opts, global_capabilities)
  end
end

return M
