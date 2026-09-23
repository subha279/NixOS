{ ... }:

{
  programs.kitty = {
    enable = true;
    shellIntegration = {
      enableZshIntegration = false;
      mode = "disabled";
    };
  };

  xdg.configFile."kitty/kitty.conf".source = ./config/kitty.conf;
}
