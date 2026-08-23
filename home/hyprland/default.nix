{ pkgs, ... }:

{
  # Aurora Hyprland

  # Polkit Qt Environment Override

  xdg.configFile."systemd/user/plasma-polkit-agent.service.d/environment.conf".text = ''
    [Service]
    Environment=QT_STYLE_OVERRIDE=
  '';

  # Hyprland Lua Configuration

  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;

  # Hyprland Configuration Modules

  xdg.configFile."hypr/config".source = ./config;

  # Wallpaper Scripts

  # Wallpaper selection itself now lives in Quickshell, in home/quickshell/config/modules/WallpaperPicker.qml.

  xdg.configFile."hypr/scripts/restore-wallpaper.sh".source = ./scripts/restore-wallpaper.sh;

  # Aurora Desktop Services

  # This repo configures Hyprland by writing config files directly rather than through the home-manager Hyprland module, so nothing was
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

    # Previously missing, so the target was only reachable through the explicit `systemctl --user start` in startup.lua and raced the shell.
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Awww Wallpaper Daemon

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
