---@class PlatformModule
local M = {}

---Check if running on Windows
---@return boolean
function M.is_windows()
  return vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
end

---Check if running on macOS
---@return boolean
function M.is_macos()
  return vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1
end

---Check if running on Linux
---@return boolean
function M.is_linux()
  return vim.fn.has("unix") == 1 and not M.is_macos()
end

---Check if running on Unix-like system (Linux or macOS)
---@return boolean
function M.is_unix()
  return M.is_linux() or M.is_macos()
end

---Get the platform path separator
---@return string
function M.get_path_separator()
  return M.is_windows() and "\\" or "/"
end

---Get the PATH environment variable delimiter
---@return string
function M.get_path_delimiter()
  return M.is_windows() and ";" or ":"
end

---Get the platform line separator
---@return string
function M.get_line_separator()
  return M.is_windows() and "\r\n" or "\n"
end

---Join path segments with the appropriate separator
---@param ... string Path segments to join
---@return string
function M.path_join(...)
  local segments = { ... }
  local sep = M.get_path_separator()
  return table.concat(segments, sep)
end

---Normalize path separators for the current platform
---@param path string Path to normalize
---@return string
function M.normalize_path(path)
  local platform_sep = M.get_path_separator()
  local to_replace = M.is_windows() and "/" or "\\"
  return (path:gsub(to_replace, platform_sep))
end

---Get the platform name as a string
---@return "windows"|"macos"|"linux"|"unknown"
function M.get_platform()
  if M.is_windows() then
    return "windows"
  elseif M.is_macos() then
    return "macos"
  elseif M.is_linux() then
    return "linux"
  else
    return "unknown"
  end
end

---Check if running in WSL (Windows Subsystem for Linux)
---@return boolean
function M.is_wsl()
  if not M.is_linux() then
    return false
  end

  local handle = io.open("/proc/version", "r")
  if handle then
    local version = handle:read("*a")
    handle:close()
    return version:lower():find("microsoft") ~= nil
  end

  return false
end

---Get the home directory path
---@return string
function M.get_home_dir()
  if M.is_windows() then
    return os.getenv("USERPROFILE") or os.getenv("HOME") or ""
  else
    return os.getenv("HOME") or ""
  end
end

---Execute a command based on the platform
---@param opts { windows?: string|fun(), macos?: string|fun(), linux?: string|fun(), unix?: string|fun(), default?: string|fun() }
---@return any|nil
function M.platform_exec(opts)
  local platform = M.get_platform()
  local action = opts[platform] or (M.is_unix() and opts.unix) or opts.default

  if action then
    if type(action) == "function" then
      return action()
    elseif type(action) == "string" then
      return vim.fn.system(action)
    end
  end
end

---Get platform-specific value
---@param opts { windows?: any, macos?: any, linux?: any, unix?: any, default?: any }
---@return any|nil
function M.platform_value(opts)
  local platform = M.get_platform()
  local value = opts[platform]

  if value == nil and M.is_unix() and opts.unix ~= nil then
    value = opts.unix
  end

  return value ~= nil and value or opts.default
end

---Check if a command exists in PATH
---@param cmd string Command to check
---@return boolean
function M.command_exists(cmd)
  return vim.fn.executable(cmd) == 1
end

---Open a path with the default system application
---@param path string Path to open
function M.open_with_system(path)
  local cmd
  if M.is_windows() then
    cmd = string.format('start "" "%s"', path)
  elseif M.is_macos() then
    cmd = string.format("open '%s'", path)
  else
    cmd = string.format("xdg-open '%s'", path)
  end
  vim.fn.system(cmd)
end

return M
