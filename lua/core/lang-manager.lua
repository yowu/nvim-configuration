---@class LanguageConfig
---@field lsp? table<string, LspServerConfig|boolean> LSP server configurations for this language
---@field treesitter? string[] Treesitter parsers to install
---@field formatters? string[] Formatter tools (e.g., prettier, stylua)
---@field linters? string[] Linter tools
---@field dap? table DAP (debugger) configuration
---@field tools? string[] Mason tools to install (LSP servers, formatters, linters, etc.)
---@field opts? table Additional language-specific options

---Language Manager Module
---Handles registration, storage, and retrieval of language configurations.
---Also provides auto-discovery of language definition files from lua/languages/
---@class CoreLangManager
local M = {}

-- ============================================================================
-- State
-- ============================================================================

local _initialized = false

-- Storage for registered languages
local _languages = {}

-- ============================================================================
-- Internal Helpers
-- ============================================================================

---Normalize language configuration
---@param config LanguageConfig
---@return LanguageConfig
local function normalize_config(config)
  return vim.tbl_deep_extend("force", {
    lsp = {},
    treesitter = {},
    formatters = {},
    linters = {},
    dap = nil,
    tools = {},
    opts = {},
  }, config or {})
end

---@param module_name string
---@param message string
local function notify_error(module_name, message)
  vim.notify(string.format("[lang-manager] %s (%s)", message, module_name), vim.log.levels.ERROR)
end

---@param result any
---@return table
local function normalize_specs(result)
  if result == nil then
    return {}
  end

  if type(result) == "table" and result.languages and vim.islist(result.languages) then
    return result.languages
  end

  if type(result) == "table" and result.name then
    return { result }
  end

  if vim.islist(result) then
    return result
  end

  return {}
end

---@param module_name string
---@param spec table
local function register_spec(module_name, spec)
  if type(spec) ~= "table" then
    notify_error(module_name, "Language spec must be a table")
    return
  end

  local name = spec.name
  if type(name) ~= "string" or name == "" then
    notify_error(module_name, "Language spec missing `name`")
    return
  end

  if spec.config then
    M.register(name, spec.config)
  elseif spec.extend then
    M.extend(name, spec.extend)
  else
    notify_error(module_name, string.format("Language '%s' must define `config` or `extend`", name))
  end
end

-- ============================================================================
-- Registration API
-- ============================================================================

---Register a new language configuration
---@param name string Language name (e.g., "lua", "rust", "typescript")
---@param config LanguageConfig Language configuration
function M.register(name, config)
  if not name or type(name) ~= "string" then
    vim.notify("[lang-manager] Language name must be a string", vim.log.levels.ERROR)
    return
  end

  if _languages[name] then
    vim.notify(
      string.format("[lang-manager] Language '%s' is already registered. Use extend() to modify.", name),
      vim.log.levels.WARN
    )
    return
  end

  _languages[name] = normalize_config(config)
end

---Extend an existing language configuration
---@param name string Language name
---@param config LanguageConfig Additional configuration to merge
function M.extend(name, config)
  if not _languages[name] then
    vim.notify(
      string.format("[lang-manager] Language '%s' not found. Use register() first.", name),
      vim.log.levels.WARN
    )
    return
  end

  _languages[name] = vim.tbl_deep_extend("force", _languages[name], normalize_config(config))
end

---Helper: Register a simple language with common patterns
---@param name string Language name
---@param opts { lsp?: string|string[], treesitter?: string|string[], formatters?: string|string[], tools?: string[], filetypes?: string[] }
function M.register_simple(name, opts)
  opts = opts or {}

  local config = {
    treesitter = {},
    formatters = {},
    tools = {},
    lsp = {},
    opts = {
      filetypes = opts.filetypes or { name },
    },
  }

  -- Handle LSP servers
  if opts.lsp then
    local lsp_servers = type(opts.lsp) == "string" and { opts.lsp } or opts.lsp --[[@as string[] ]]
    for _, server in ipairs(lsp_servers) do
      config.lsp[server] = true
    end
  end

  -- Handle treesitter parsers
  if opts.treesitter then
    local parsers = type(opts.treesitter) == "string" and { opts.treesitter } or opts.treesitter --[[@as string[] ]]
    config.treesitter = parsers
  end

  -- Handle formatters
  if opts.formatters then
    local formatters = type(opts.formatters) == "string" and { opts.formatters } or opts.formatters --[[@as string[] ]]
    config.formatters = formatters
  end

  -- Handle tools
  if opts.tools then
    config.tools = opts.tools
  end

  M.register(name, config)
end

-- ============================================================================
-- Getters
-- ============================================================================

---Get all registered languages
---@return table<string, LanguageConfig>
function M.get_languages()
  return vim.deepcopy(_languages)
end

---Get configuration for a specific language
---@param lang string Language name
---@return LanguageConfig?
function M.get_config(lang)
  if not _languages[lang] then
    return nil
  end
  return vim.deepcopy(_languages[lang])
end

---Get all LSP server configurations
---@return table<string, LspServerConfig>
function M.get_lsp_servers()
  local servers = {}

  for _, lang_config in pairs(_languages) do
    if lang_config.lsp then
      for server_name, server_config in pairs(lang_config.lsp) do
        if server_config ~= false then
          servers[server_name] = server_config == true and {} or server_config
        end
      end
    end
  end

  return servers
end

---Get all treesitter parsers to install
---@return string[]
function M.get_treesitter_parsers()
  local parsers = {}
  local seen = {}

  for _, lang_config in pairs(_languages) do
    if lang_config.treesitter then
      for _, parser in ipairs(lang_config.treesitter) do
        if not seen[parser] then
          table.insert(parsers, parser)
          seen[parser] = true
        end
      end
    end
  end

  table.sort(parsers)
  return parsers
end

---Get all Mason tools to install
---@return string[]
function M.get_mason_tools()
  local tools = {}
  local seen = {}

  for _, lang_config in pairs(_languages) do
    -- Add explicit tools
    if lang_config.tools then
      for _, tool in ipairs(lang_config.tools) do
        if not seen[tool] then
          table.insert(tools, tool)
          seen[tool] = true
        end
      end
    end

    -- Add formatters
    if lang_config.formatters then
      for _, formatter in ipairs(lang_config.formatters) do
        if not seen[formatter] then
          table.insert(tools, formatter)
          seen[formatter] = true
        end
      end
    end

    -- Add linters
    if lang_config.linters then
      for _, linter in ipairs(lang_config.linters) do
        if not seen[linter] then
          table.insert(tools, linter)
          seen[linter] = true
        end
      end
    end
  end

  table.sort(tools)
  return tools
end

---Get formatters organized by filetype
---@return table<string, string[]>
function M.get_formatters()
  local formatters_by_ft = {}

  for _, lang_config in pairs(_languages) do
    if lang_config.formatters and lang_config.opts and lang_config.opts.filetypes then
      for _, ft in ipairs(lang_config.opts.filetypes) do
        formatters_by_ft[ft] = formatters_by_ft[ft] or {}
        for _, formatter in ipairs(lang_config.formatters) do
          table.insert(formatters_by_ft[ft], formatter)
        end
      end
    end
  end

  return formatters_by_ft
end

---Get all DAP configurations
---@return table<string, table[]>
function M.get_dap_configurations()
  local configurations = {}

  for _, lang_config in pairs(_languages) do
    if lang_config.dap and lang_config.opts and lang_config.opts.filetypes then
      for _, ft in ipairs(lang_config.opts.filetypes) do
        if lang_config.dap.configurations then
          configurations[ft] = configurations[ft] or {}
          vim.list_extend(configurations[ft], lang_config.dap.configurations)
        end
      end
    end
  end

  return configurations
end

-- ============================================================================
-- Utilities
-- ============================================================================

---Get statistics about registered languages
---@return { total: integer, with_lsp: integer, with_treesitter: integer, with_formatters: integer }
function M.get_stats()
  local stats = {
    total = 0,
    with_lsp = 0,
    with_treesitter = 0,
    with_formatters = 0,
  }

  for _, config in pairs(_languages) do
    stats.total = stats.total + 1
    if config.lsp and vim.tbl_count(config.lsp) > 0 then
      stats.with_lsp = stats.with_lsp + 1
    end
    if config.treesitter and #config.treesitter > 0 then
      stats.with_treesitter = stats.with_treesitter + 1
    end
    if config.formatters and #config.formatters > 0 then
      stats.with_formatters = stats.with_formatters + 1
    end
  end

  return stats
end

---List all registered language names
---@return string[]
function M.list()
  local names = vim.tbl_keys(_languages)
  table.sort(names)
  return names
end

---Clear all registered languages (useful for testing)
function M.clear()
  _languages = {}
  _initialized = false
end

-- ============================================================================
-- Setup & Auto-Discovery
-- ============================================================================

---Load all language configurations from lua/languages/
---This scans the languages directory and registers each language definition
function M.setup()
  if _initialized then
    return
  end

  -- Initialize the language manager
  local config_path = vim.fn.stdpath "config"
  local languages_path = vim.fs.joinpath(config_path, "lua", "languages")

  if vim.fn.isdirectory(languages_path) == 0 then
    return
  end

  -- Scan directory for language files
  for name, type in vim.fs.dir(languages_path) do
    if type == "file" and name:match "%.lua$" and name ~= "init.lua" then
      local module_name = "languages." .. name:gsub("%.lua$", "")
      local ok, result = pcall(require, module_name)
      if not ok then
        notify_error(module_name, result)
      else
        local specs = normalize_specs(result)
        for _, spec in ipairs(specs) do
          register_spec(module_name, spec)
        end
      end
    end
  end

  _initialized = true
end

return M
