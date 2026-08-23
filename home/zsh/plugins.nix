{ pkgs, ... }:

{
  # fzf

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--cycle"
      "--info=inline"
      "--smart-case"
    ];
  };

  # zoxide

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;

    options = [
      "--cmd"
      "cd"
    ];
  };

  # fzf-tab

  programs.zsh.plugins = [
    {
      name = "fzf-tab";
      src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      file = "fzf-tab.plugin.zsh";
    }
  ];
}
