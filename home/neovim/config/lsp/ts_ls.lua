return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  root_markers = {
    "package.json",
    "tsconfig.json",
    "jsconfig.json",
    "pnpm-workspace.yaml",
    "pnpm-lock.yaml",
    "package-lock.json",
    "yarn.lock",
    ".git",
  },
  single_file_support = true,
}
