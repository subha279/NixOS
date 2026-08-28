{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    withNodeJs = false;
    withPython3 = false;

    plugins = with pkgs.vimPlugins; [

      blink-cmp


      nvim-lspconfig


      nvim-treesitter.withAllGrammars
      nvim-colorizer-lua


      telescope-nvim

      telescope-fzf-native-nvim

      plenary-nvim
      nvim-web-devicons


      gitsigns-nvim


      conform-nvim
      nvim-lint


      which-key-nvim
      lualine-nvim
      snacks-nvim

      nvim-tree-lua

      alpha-nvim
    ];

    extraPackages = with pkgs; [


      qt6.qtdeclarative

      lua-language-server
      rust-analyzer
      typescript-language-server
      pyright
      clang-tools
      nixd
      bash-language-server
      vscode-langservers-extracted
      yaml-language-server
      marksman
      tailwindcss-language-server
      dockerfile-language-server
      taplo


      stylua
      prettier
      ruff
      nixfmt
      shfmt
      eslint_d
      shellcheck
      rustfmt


      gcc
      gdb
      cmake
      pkg-config


      lazygit
    ];
  };

  xdg.configFile."nvim".source = ./config;
}
