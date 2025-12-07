---@class LspServerConfig: vim.lsp.Config
---@field enabled? boolean Whether this LSP server is enabled (default: true)

---@class LspConfig
---@field servers table<string, LspServerConfig|boolean> LSP server configurations (true for default config)
---@field inlay_hints? { enabled: boolean, exclude: string[] } Inlay hint settings
---@field codelens? { enabled: boolean } Code lens settings
---@field capabilities? table Additional LSP capabilities

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

---Setup LSP keymappings for a buffer
---@param bufnr integer Buffer number
local function setup_keymappings(bufnr)
  local function opts(desc)
    return { buffer = bufnr, desc = "LSP " .. desc }
  end

  local map = vim.keymap.set

  -- Navigation
  map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
  map("n", "gy", vim.lsp.buf.type_definition, opts "Goto T[y]pe Definition")
  map("n", "gD", vim.lsp.buf.declaration, opts "Goto Declaration")

  -- Information
  map("n", "K", vim.lsp.buf.hover, opts "Hover")

  -- Actions
  map("n", "grl", vim.lsp.codelens.run, opts "CodeLens Action")
end

---Default on_init handler that disables semantic tokens
---@param client vim.lsp.Client
local function default_on_init(client)
  -- Disable semantic tokens provider (often causes performance issues)
  if client:supports_method("textDocument/semanticTokens") then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

---Create on_init handler that calls default and user-provided handlers
---@param server_opts LspServerConfig
---@return fun(client: vim.lsp.Client, init_result: lsp.InitializeResult)
local function create_on_init(server_opts)
  return function(client, init_result)
    default_on_init(client)

    if server_opts.on_init and type(server_opts.on_init) == "function" then
      server_opts.on_init(client, init_result)
    end
  end
end

local code_lens_group = vim.api.nvim_create_augroup("LspCodeLens", { clear = true })

---Setup LSP features for a buffer
---@param opts LspConfig Global LSP configuration
---@param bufnr integer Buffer number
local function setup_features(opts, bufnr)
  -- Inlay hints
  if opts.inlay_hints and opts.inlay_hints.enabled then
    local exclude = opts.inlay_hints.exclude or {}

    if
        vim.api.nvim_buf_is_valid(bufnr)
        and vim.bo[bufnr].buftype == ""
        and not vim.tbl_contains(exclude, vim.bo[bufnr].filetype)
    then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end

  -- Code lens
  if opts.codelens and opts.codelens.enabled and vim.lsp.codelens then
    vim.lsp.codelens.refresh { bufnr = bufnr }

    vim.api.nvim_clear_autocmds({ group = code_lens_group, buffer = bufnr })
    vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
      group = code_lens_group,
      buffer = bufnr,
      callback = function()
        vim.lsp.codelens.refresh { bufnr = bufnr }
      end,
      desc = "Refresh code lens",
    })
  end
end

---Create on_attach handler
---@param global_opts LspConfig Global LSP configuration
---@param server_opts LspServerConfig Server-specific configuration
---@return fun(client: vim.lsp.Client, bufnr: integer)
function M.create_on_attach(global_opts, server_opts)
  return function(client, bufnr)
    -- Setup keymappings
    setup_keymappings(bufnr)

    -- Setup features (inlay hints, code lens, etc.)
    setup_features(global_opts, bufnr)

    -- Call user-provided on_attach if present
    if server_opts.on_attach and type(server_opts.on_attach) == "function" then
      server_opts.on_attach(client, bufnr)
    end
  end
end

---Setup default LSP capabilities
---@return table
local function setup_default_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Integrate with nvim-cmp if available
  local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if has_cmp then
    capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())
  end

  -- Integrate with blink.cmp if available
  local has_blink, blink = pcall(require, "blink.cmp")
  if has_blink then
    capabilities = vim.tbl_deep_extend("force", capabilities, blink.get_lsp_capabilities())
  end

  return capabilities
end


---Main LSP setup function
---@param opts LspConfig
function M.setup(opts)
  opts = opts or {}

  -- Setup default options
  local config = vim.tbl_deep_extend("force", {
    inlay_hints = { enabled = false, exclude = {} },
    codelens = { enabled = false },
    capabilities = {},
    servers = {},
  }, opts)

  -- Merge global capabilities with defaults
  local global_capabilities = setup_default_capabilities()

  -- Setup each LSP server
  for server_name, server_opts in pairs(config.servers) do
    if server_opts then
      -- Convert `true` to empty config table
      server_opts = server_opts == true and {} or server_opts

      -- Check if server is explicitly disabled
      if server_opts.enabled == false then
        goto continue
      end

      -- Build server configuration
      local server_config = vim.deepcopy(server_opts)

      -- Merge capabilities
      server_config.capabilities = vim.tbl_deep_extend("force", {}, global_capabilities, server_opts.capabilities or {})

      -- Setup handlers
      server_config.on_init = create_on_init(server_opts)
      server_config.on_attach = M.create_on_attach(config, server_opts)

      -- Register and enable the LSP server
      vim.lsp.config(server_name, server_config)
      vim.lsp.enable(server_name)
    end

    ::continue::
  end
end

---Helper to get LSP clients attached to current buffer
---@return vim.lsp.Client[]
function M.get_active_clients()
  return vim.lsp.get_clients { bufnr = 0 }
end

---Helper to check if any LSP client is attached to current buffer
---@return boolean
function M.has_clients()
  return #M.get_active_clients() > 0
end

---Helper to restart LSP clients for current buffer
function M.restart()
  local clients = M.get_active_clients()
  for _, client in ipairs(clients) do
    vim.lsp.stop_client(client.id, true)
    vim.cmd "edit" -- Trigger LSP to reattach
  end
  vim.notify("LSP clients restarted", vim.log.levels.INFO)
end

return M
