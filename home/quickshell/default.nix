{ pkgs, ... }:

{
  # ==========================================================================
  # Quickshell
  # ==========================================================================
  #
  # Quickshell owns org.freedesktop.Notifications for this session, so it is
  # the notification daemon for every application on the machine. That makes
  # its unit ordering load-bearing rather than cosmetic.
  #
  # ==========================================================================

  home.packages = with pkgs; [
    quickshell

    # notify-send. Needed by scripts, keybinds and anything that wants to
    # talk to the daemon from a shell.
    libnotify
  ];

  xdg.configFile."quickshell".source = ./config;

  # ==========================================================================
  # D-Bus Activation
  # ==========================================================================
  #
  # Without this file nothing owns org.freedesktop.Notifications until the
  # shell happens to be running. An application that sends a notification
  # before then gets ServiceUnknown back and, in almost every toolkit, throws
  # the notification away without telling you.
  #
  # With it, the first notification of the session starts the shell instead.
  #
  # ==========================================================================

  xdg.dataFile."dbus-1/services/org.freedesktop.Notifications.service".text = ''
    [D-BUS Service]
    Name=org.freedesktop.Notifications
    Exec=${pkgs.quickshell}/bin/qs
    SystemdService=quickshell.service
  '';

  # ==========================================================================
  # Service
  # ==========================================================================

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell desktop shell and notification daemon";

      # Tie the shell to the graphical session. Previously this unit had no
      # Install section at all, so it was only ever started by hand and never
      # stopped or restarted with the session.
      PartOf = [ "graphical-session.target" ];

      After = [
        "graphical-session.target"
        "dbus.socket"
      ];

      Requires = [ "dbus.socket" ];

      # Refuse to start before the compositor has exported WAYLAND_DISPLAY.
      # Starting early is what turned Restart=on-failure into a crash loop.
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      Type = "exec";

      ExecStart = "${pkgs.quickshell}/bin/qs";

      Restart = "on-failure";

      RestartSec = 2;

      # Do not give up permanently after a few early failures.
      StartLimitBurst = 8;

      Slice = "session.slice";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
