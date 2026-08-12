return {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "pyrightconfig.json",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    ".git",
  },
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "standard",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
}
