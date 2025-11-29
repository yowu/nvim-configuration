local overseer = require "overseer"

return {
  -- Required fields
  name = "Build Revit tag database",
  builder = function(_)
    -- This must return an overseer.TaskDefinition
    return {
      -- cmd is the only required field
      cmd = { "pwsh" },
      -- additional arguments for the cmd
      args = {
        "-NoProfile",
        "-Command",
        "rg -tcpp -tcs --files |",
        "ctags -L- --c++-kinds=+p --fields=+iaS --extras=+q --extras=-r -I C:/users/wuy/ctags.d/identifier-list.txt -f .tmp_tags",
      },

      -- the name of the task (defaults to the cmd of the task)
      name = "RTags: Build",
      -- set the working directory for the task
      cwd = vim.loop.cwd(),
      -- additional environment variables
      --
      components = {
        "default",
        "on-start-notify",
      },
    }
  end,
  -- Tags can be used in overseer.run_template()
  tags = { overseer.TAG.BUILD },
  -- Determines sort order when choosing tasks. Lower comes first.
  priority = 50,
  -- Add requirements for this template. If they are not met, the template will not be visible.
  -- All fields are optional.
  condition = {
    -- Only matches when cwd is inside one of the listed dirs
    callback = function()
      local cwd = vim.loop.cwd():lower()
      return cwd:find "revit" ~= nil
    end,
  },
}
