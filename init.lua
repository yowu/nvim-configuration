-- Phase 1: Core Settings (before plugins)
-- These must load first as plugins may depend on them
require "config.options" -- Vim options, diagnostics, leader keys
require "config.keymaps" -- Core keybindings (non-plugin)

-- Phase 2: Language Definitions
-- Register language configs before plugins consume them
require("core.lang-manager").setup()

-- Phase 3: Plugin Manager
-- Loads lazy.nvim and all plugin specs
require "config.lazy"

-- Phase 4: Post-Plugin Setup
-- These run after plugins are loaded
require "config.autocmds" -- Autocommands & events
require "config.polish"   -- Other things
