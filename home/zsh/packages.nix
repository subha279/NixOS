{ pkgs, ... }:

{
  home.packages = with pkgs; [

    bat
    eza
    fd
    fzf
    jq
    ripgrep
    zoxide

    starship
  ];
}
