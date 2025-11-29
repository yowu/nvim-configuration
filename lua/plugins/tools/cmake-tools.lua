return {
  "Civitasv/cmake-tools.nvim",
  ft = { "c", "cpp", "objc", "objcpp", "cuda" },
  cmd = { "CMakeQuickStart", "CMakeRun", "CMakeBuild", "CMakeClean" },
  init = function()
    local loaded = false
    local function check()
      local cwd = vim.uv.cwd()
      if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
        require("lazy").load({ plugins = { "cmake-tools.nvim" } })
        loaded = true
      end
    end
    check()
    vim.api.nvim_create_autocmd("DirChanged", {
      callback = function()
        if not loaded then
          check()
        end
      end,
    })
  end,
  opts = {
    cmake_build_directory = function()
      local ps = require("core.platform").get_path_separator()
      return "build" .. ps .. "${variant:buildType}"
    end,
    cmake_executor = {
      name = "toggleterm",
      opts = { direction = "horizontal" },
    },
    cmake_runner = {
      name = "toggleterm",
      opts = { direction = "horizontal" },
    },
  },
}
