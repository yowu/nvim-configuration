---@type overseer.ComponentFileDefinition
local comp = {
  desc = "vim.notify when task is started",
  params = {},
  constructor = function(_)
    return {
      on_start = function(_, task, _)
        vim.notify(string.format("Task %s started", task.name), vim.log.levels.INFO, { title = "Overseer" })
      end,
    }
  end,
}
return comp
