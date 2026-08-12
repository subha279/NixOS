{ pkgs, ... }:

{
  home.packages = with pkgs; [

    # Modern CLI
    bat
    eza
    fd
    fzf
    jq
    ripgrep
    zoxide

    # Shell Prompt
    starship
  ];
}
