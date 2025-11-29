return {
  "ahmedkhalf/project.nvim",
  main = "project_nvim",
  event = "VimEnter",
  opts = {
    detection_methods = { "pattern" },
    patterns = {
      ".git",
      "_darcs",
      ".hg",
      ".svn",
      "Makefile",
      "package.json",
      "pom.xml",
      "*.sln",
      "lazy-lock.json",
      ".clangd",
      ".clang-format",
      ".clang-tidy",
    },
    silent_chdir = true,
    scope_chdir = "global",
  },
}
