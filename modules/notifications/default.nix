{ ... }:

{
  xdg.portal.config.common = {
    "org.freedesktop.impl.portal.Notification" = [ "gtk" ];

    # Keep the rest of the portal behaviour explicit while we are here, so a future backend does not silently take over the file picker.
    default = [
      "hyprland"
      "gtk"
    ];

    "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];

    "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
  };

  # GLib / GApplication support

  programs.dconf.enable = true;

  # Battery notifications

  services.upower = {
    percentageLow = 20;

    percentageCritical = 10;

    percentageAction = 5;

    criticalPowerAction = "PowerOff";
  };
}
