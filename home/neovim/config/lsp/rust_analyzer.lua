return {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = {
    "Cargo.toml",
    "rust-project.json",
    ".git",
  },
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
      check = {
        command = "clippy",
      },
      procMacro = {
        enable = true,
      },
      diagnostics = {
        enable = true,
      },
      inlayHints = {
        bindingModeHints = {
          enable = true,
        },
        chainingHints = {
          enable = true,
        },
        closingBraceHints = {
          enable = true,
        },
        closureReturnTypeHints = {
          enable = "with_block",
        },
        lifetimeElisionHints = {
          enable = "skip_trivial",
        },
        parameterHints = {
          enable = true,
        },
        typeHints = {
          enable = true,
        },
      },
    },
  },
}
