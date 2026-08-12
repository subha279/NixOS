return {
  cmd = {
    "docker-langserver",
    "--stdio",
  },
  filetypes = {
    "dockerfile",
  },
  root_markers = {
    "Dockerfile",
    "Containerfile",
    "docker-compose.yml",
    "docker-compose.yaml",
    ".git",
  },
}
