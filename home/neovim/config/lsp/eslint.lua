return {
  cmd = {
    "vscode-eslint-language-server",
    "--stdio",
  },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
    "svelte",
  },
  root_markers = {
    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
    ".eslintrc",
    ".eslintrc.json",
    ".eslintrc.js",
    "package.json",
    ".git",
  },
}
