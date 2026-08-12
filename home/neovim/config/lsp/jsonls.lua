return {
  cmd = {
    "vscode-json-language-server",
    "--stdio",
  },
  filetypes = {
    "json",
    "jsonc",
  },
  root_markers = {
    "package.json",
    "tsconfig.json",
    ".git",
  },
}
