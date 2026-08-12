{ pkgs, ... }:

{
  home.packages = with pkgs; [
    quickshell
  ];

  xdg.configFile."quickshell".source = ./config;

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell desktop shell";
    };

    Service = {
      ExecStart = "${pkgs.quickshell}/bin/qs";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}
