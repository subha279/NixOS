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

  xdg.configFile."hypr/scripts/restore-wallpaper.sh".source = ./scripts/restore-wallpaper.sh;

  # Aurora Desktop Services

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
        "nm-applet.service"
        "blueman-applet.service"
      ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Network Applet
  #
  # A systemd user service rather than a Hyprland exec, because systemd will
  # only ever run one of it.
  #
  # Launching it from the hyprland.start hook meant that `hyprctl reload`, which
  # is the last thing `aurora-theme` does, could stack a second copy. Two secret
  # agents registered against NetworkManager for one session make a perfectly
  # healthy connection look like it is renegotiating every time the theme
  # changes. A pgrep guard papered over that; this removes the possibility.
  #
  # Quickshell owns the network UI. This is here for the secret agent, which is
  # what answers a request for credentials that nmcli cannot supply inline, and
  # for the tray icon. Its own notifications are suppressed by dconf in
  # home/quickshell/default.nix so they do not double up with NetworkService.

  systemd.user.services.nm-applet = {
    Unit = {
      Description = "NetworkManager applet";

      PartOf = [ "graphical-session.target" ];

      After = [ "graphical-session.target" ];

      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      Type = "exec";

      # --indicator exposes it over StatusNotifier, which is the protocol the
      # Quickshell tray actually consumes.
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator";

      Restart = "on-failure";

      RestartSec = 2;

      Slice = "session.slice";
    };

    Install = {
      WantedBy = [ "desktop-services.target" ];
    };
  };

  # Bluetooth Applet
  #
  # Same reasoning as nm-applet above: one owner, no duplicates on reload.

  systemd.user.services.blueman-applet = {
    Unit = {
      Description = "Blueman bluetooth applet";

      PartOf = [ "graphical-session.target" ];

      After = [ "graphical-session.target" ];

      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      Type = "exec";

      ExecStart = "${pkgs.blueman}/bin/blueman-applet";

      Restart = "on-failure";

      RestartSec = 2;

      Slice = "session.slice";
    };

    Install = {
      WantedBy = [ "desktop-services.target" ];
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
