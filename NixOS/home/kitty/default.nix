{ config, ... }:

{
  programs.kitty = {
    enable = true;

    extraConfig = ''
      include ${config.xdg.configHome}/kitty/dank-tabs.conf
      include ${config.xdg.configHome}/kitty/dank-theme.conf
    '';
  };

  xdg.configFile."kitty/kitty.conf".source =
    ./config/kitty.conf;

  xdg.configFile."kitty/dank-tabs.conf".source =
    ./config/dank-tabs.conf;

  xdg.configFile."kitty/dank-theme.conf".source =
    ./config/dank-theme.conf;
}
