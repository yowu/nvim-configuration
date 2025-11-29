---@class LanguageConfig
---@field lsp? table<string, LspServerConfig|boolean> LSP server configurations for this language
---@field treesitter? string[] Treesitter parsers to install
---@field formatters? string[] Formatter tools (e.g., prettier, stylua)
---@field linters? string[] Linter tools
---@field dap? table DAP (debugger) configuration
---@field tools? string[] Mason tools to install (LSP servers, formatters, linters, etc.)
---@field opts? table Additional language-specific options



---@class CoreLanguagesManager
local M = {}

-- Storage for registered languages
local languages = {}

-- Cached derived data
local cache = {
  lsp_servers = nil,
  treesitter = nil,
  mason_tools = nil,
  formatters = nil,
  dap = nil,
}

local function invalidate_cache()
  cache.lsp_servers = nil
  cache.treesitter = nil
  cache.mason_tools = nil
  cache.formatters = nil
  cache.dap = nil
end

---@generic T
---@param key "lsp_servers"|"treesitter"|"mason_tools"|"formatters"|"dap"
---@param builder fun(): T
---@return T
local function get_cached(key, builder)
  if not cache[key] then
    cache[key] = builder()
  end
  return vim.deepcopy(cache[key])
end

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

---Register a new language configuration
---@param name string Language name (e.g., "lua", "rust", "typescript")
---@param config LanguageConfig Language configuration
function M.register(name, config)
  if not name or type(name) ~= "string" then
    vim.notify("Language name must be a string", vim.log.levels.ERROR)
    return
  end

  if languages[name] then
    vim.notify(string.format("Language '%s' is already registered. Use extend() to modify.", name), vim.log.levels.WARN)
    return
  end

  languages[name] = normalize_config(config)
  invalidate_cache()
end

---Extend an existing language configuration
---@param name string Language name
---@param config LanguageConfig Additional configuration to merge
function M.extend(name, config)
  if not languages[name] then
    vim.notify(string.format("Language '%s' not found. Use register() first.", name), vim.log.levels.WARN)
    return
  end

  languages[name] = vim.tbl_deep_extend("force", languages[name], normalize_config(config))
  invalidate_cache()
end

---Get all registered languages
---@return table<string, LanguageConfig>
function M.get_languages()
  return vim.deepcopy(languages)
end

---Get configuration for a specific language
---@param lang string Language name
---@return LanguageConfig?
function M.get_config(lang)
  if not languages[lang] then
    return nil
  end
  return vim.deepcopy(languages[lang])
end

---Get all LSP server configurations
---@return table<string, LspServerConfig>
function M.get_lsp_servers()
  return get_cached("lsp_servers", function()
    local servers = {}

    for _, lang_config in pairs(languages) do
      if lang_config.lsp then
        for server_name, server_config in pairs(lang_config.lsp) do
          if server_config ~= false then
            servers[server_name] = server_config == true and {} or server_config
          end
        end
      end
    end

    return servers
  end)
end

---Get all treesitter parsers to install
---@return string[]
function M.get_treesitter_parsers()
  return get_cached("treesitter", function()
    local parsers = {}
    local seen = {}

    for _, lang_config in pairs(languages) do
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
  end)
end

---Get all Mason tools to install
---@return string[]
function M.get_mason_tools()
  return get_cached("mason_tools", function()
    local tools = {}
    local seen = {}

    for _, lang_config in pairs(languages) do
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
  end)
end

---Get formatters organized by filetype
---@return table<string, string[]>
function M.get_formatters()
  return get_cached("formatters", function()
    local formatters_by_ft = {}

    for _, lang_config in pairs(languages) do
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
  end)
end

---Get all DAP configurations
---@return table<string, table[]>
function M.get_dap_configurations()
  return get_cached("dap", function()
    local configurations = {}

    for _, lang_config in pairs(languages) do
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
  end)
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
    local lsp_servers = type(opts.lsp) == "string" and { opts.lsp } or opts.lsp
    for _, server in ipairs(lsp_servers) do
      config.lsp[server] = true
    end
  end

  -- Handle treesitter parsers
  if opts.treesitter then
    local parsers = type(opts.treesitter) == "string" and { opts.treesitter } or opts.treesitter
    config.treesitter = parsers
  end

  -- Handle formatters
  if opts.formatters then
    local formatters = type(opts.formatters) == "string" and { opts.formatters } or opts.formatters
    config.formatters = formatters
  end

  -- Handle tools
  if opts.tools then
    config.tools = opts.tools
  end

  M.register(name, config)
end

---Get statistics about registered languages
---@return { total: integer, with_lsp: integer, with_treesitter: integer, with_formatters: integer }
function M.get_stats()
  local stats = {
    total = 0,
    with_lsp = 0,
    with_treesitter = 0,
    with_formatters = 0,
  }

  for _, config in pairs(languages) do
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

---Clear all registered languages (useful for testing)
function M.clear()
  languages = {}
  invalidate_cache()
end

---List all registered language names
---@return string[]
function M.list()
  local names = vim.tbl_keys(languages)
  table.sort(names)
  return names
end

return M
