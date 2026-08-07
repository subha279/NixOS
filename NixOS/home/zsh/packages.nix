{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    eza
    fd
    fzf
    jq
    ripgrep
    starship
    zoxide
  ];
}
