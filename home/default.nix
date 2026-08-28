{ ... }:

let
  vars = import ../lib/variables.nix;
in

{
  imports = [
    ./git
    ./zsh
    ./kitty
    ./tmux
    ./fastfetch
    ./ssh
    ./xdg
    ./neovim
    ./hyprland
    ./quickshell
    ./obsidian
    ./theme
  ];

  home.username = vars.username;
  home.homeDirectory = "/home/${vars.username}";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
