---Language configurations module
---This module automatically loads all language configurations and initializes the language manager
local M = {}

local initialized = false

---@param module_name string
---@param message string
local function notify_error(module_name, message)
  vim.notify(string.format("[languages] %s (%s)", message, module_name), vim.log.levels.ERROR)
end

---@param languages CoreLanguagesManager
---@param module_name string
---@param spec table
local function register_spec(languages, module_name, spec)
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
    languages.register(name, spec.config)
  elseif spec.extend then
    languages.extend(name, spec.extend)
  else
    notify_error(module_name, string.format("Language '%s' must define `config` or `extend`", name))
  end
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

---Load all language configurations
function M.setup()
  local manager = require("core.languages.manager")

  if initialized then
    return manager
  end

  -- Initialize the language manager
  local config_path = vim.fn.stdpath("config")
  local languages_path = vim.fs.joinpath(config_path, "lua", "languages")

  -- Scan directory for language files
  for name, type in vim.fs.dir(languages_path) do
    if type == "file" and name:match("%.lua$") and name ~= "init.lua" then
      local module_name = "languages." .. name:gsub("%.lua$", "")
      local ok, result = pcall(require, module_name)
      if not ok then
        notify_error(module_name, result)
      else
        local specs = normalize_specs(result)
        for _, spec in ipairs(specs) do
          register_spec(manager, module_name, spec)
        end
      end
    end
  end

  initialized = true
  return manager
end

---Get the language manager instance
---@return CoreLanguagesManager
function M.get_manager()
  return M.setup()
end

return M
