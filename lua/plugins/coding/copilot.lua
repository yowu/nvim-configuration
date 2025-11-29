return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "User FilePost",
  opts = {
    suggestion = { auto_trigger = true, debounce = 150 },
    panel = { enable = false },
  },
}
