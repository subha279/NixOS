{ pkgs, ... }:

{
  programs.mpv = {
    enable = true;

    # Add any extra scripts you want here (e.g., pkgs.mpvScripts.mpris),
    scripts = [ ];
  };

  # so mpv can call it automatically at runtime
  home.packages = [
    pkgs.yt-dlp
  ];

  xdg.configFile."mpv".source = ./config;
}
