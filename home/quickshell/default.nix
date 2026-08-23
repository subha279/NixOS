{ pkgs, ... }:

{
  # Quickshell

  home.packages = with pkgs; [
    quickshell

    # notify-send.
    libnotify
  ];

  xdg.configFile."quickshell".source = ./config;

  # D-Bus Activation

  xdg.dataFile."dbus-1/services/org.freedesktop.Notifications.service".text = ''
    [D-BUS Service]
    Name=org.freedesktop.Notifications
    Exec=${pkgs.quickshell}/bin/qs
    SystemdService=quickshell.service
  '';

  # Applet notifications
  #
  # nm-applet and blueman-applet run only as the NetworkManager secret agent
  # and the Bluetooth pairing agent. Tray.qml hides their icons and the bar
  # draws its own indicators, but they still raised their own popups -- which
  # is why "Wi-Fi off" and "Connection Established" appeared together.

  dconf.settings = {
    "org/gnome/nm-applet" = {
      disable-connected-notifications = true;
      disable-disconnected-notifications = true;
      disable-vpn-notifications = true;
      suppress-wireless-networks-available = true;
    };

    "org/blueman/general" = {
      plugin-list = [ "!ConnectionNotifier" ];
    };
  };

  # Service

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell desktop shell and notification daemon";

      # Tie the shell to the graphical session.
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
