{ pkgs, ... }:

{


  xdg.configFile."systemd/user/plasma-polkit-agent.service.d/environment.conf".text = ''
    [Service]
    Environment=QT_STYLE_OVERRIDE=
  '';


  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;


  xdg.configFile."hypr/config".source = ./config;


  xdg.configFile."hypr/scripts/restore-wallpaper.sh".source = ./scripts/restore-wallpaper.sh;


  systemd.user.targets.hyprland-session = {
    Unit = {
      Description = "Hyprland compositor session";

      Documentation = [ "man:systemd.special(7)" ];

      BindsTo = [ "graphical-session.target" ];

      Wants = [ "graphical-session-pre.target" ];

      After = [ "graphical-session-pre.target" ];

      Before = [ "graphical-session.target" ];
    };
  };

  systemd.user.targets.desktop-services = {
    Unit = {
      Description = "Aurora desktop services";

      PartOf = [ "graphical-session.target" ];

      After = [ "graphical-session.target" ];

      Wants = [
        "quickshell.service"
        "awww-daemon.service"
        "plasma-polkit-agent.service"
      ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };


  systemd.user.services.awww-daemon = {
    Unit = {
      Description = "Awww Wayland wallpaper daemon";

      PartOf = [
        "graphical-session.target"
      ];

      After = [
        "graphical-session.target"
      ];

      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      Type = "exec";

      ExecStart = "${pkgs.awww}/bin/awww-daemon";

      Restart = "on-failure";

      RestartSec = 2;

      Slice = "session.slice";
    };

    Install = {
      WantedBy = [ "desktop-services.target" ];
    };
  };
}
