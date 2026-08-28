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
        closureCaptureHints = {
          enable = true,
        },
        closureReturnTypeHints = {
          enable = "always",
        },
        discriminantHints = {
          enable = "always",
        },
        expressionAdjustmentHints = {
          enable = "always",
        },
        lifetimeElisionHints = {
          enable = "skip_trivial",
        },
        parameterHints = {
          enable = true,
        },
        reborrowHints = {
          enable = "always",
        },
        renderColons = true,
        typeHints = {
          enable = true,
        },
      },
    },
  },
}
