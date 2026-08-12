return {
  cmd = { "nixd" },
  filetypes = { "nix" },
  root_markers = {
    "flake.nix",
    ".git",
  },
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import (builtins.getFlake (toString ./.)).inputs.nixpkgs { }",
      },
      formatting = {
        command = { "nixfmt" },
      },
      options = {
        nixos = {
          expr = "(builtins.getFlake (toString ./.)).nixosConfigurations.laptop.options",
        },
      },
    },
  },
}
