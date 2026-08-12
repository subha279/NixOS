{ ... }:

{
  programs.fzf = {
    enable = true;

    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;

    enableZshIntegration = true;
  };

  programs.eza.enable = true;
}
