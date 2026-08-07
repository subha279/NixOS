{ ... }:

{
  imports = [
    ./git
    ./zsh
    ./kitty
    ./fastfetch
    ./ssh
    ./xdg
    ./neovim
  ];

  home.username = "subha";
  home.homeDirectory = "/home/subha";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
