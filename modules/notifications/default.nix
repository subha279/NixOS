{ ... }:

{
  # ==========================================================================
  # Notification Delivery
  # ==========================================================================
  #
  # The daemon itself is Quickshell, configured in home/quickshell. This
  # module is the system half: making sure every class of application on this
  # machine can actually reach it.
  #
  # There are three separate paths an app can take to raise a notification,
  # and they were not all wired up:
  #
  #   1. direct D-Bus to org.freedesktop.Notifications
  #        GTK apps, Qt apps, libnotify, nm-applet, blueman-applet.
  #        Fixed by the D-Bus activation file in home/quickshell.
  #
  #   2. the XDG desktop portal
  #        Anything sandboxed or portal-first: Flatpaks, Electron apps such as
  #        Obsidian and Zed, and Firefox when it uses the portal backend.
  #        xdg-desktop-portal-hyprland does NOT implement the Notification
  #        interface, and no backend was declared for it, so the portal had
  #        nothing to hand these requests to. Declared below.
  #
  #   3. GApplication / GNotification
  #        Thunar and other GLib apps. Needs dconf on the system bus to
  #        resolve app IDs; without it withdrawn/replaced notifications and
  #        action callbacks silently fail.
  #
  # ==========================================================================

  # --------------------------------------------------------------------------
  # Portal notification backend
  # --------------------------------------------------------------------------
  #
  # Route portal notifications to the GTK backend, which forwards them to
  # org.freedesktop.Notifications, i.e. to Quickshell.

  xdg.portal.config.common = {
    "org.freedesktop.impl.portal.Notification" = [ "gtk" ];

    # Keep the rest of the portal behaviour explicit while we are here, so a
    # future backend does not silently take over the file picker.
    default = [
      "hyprland"
      "gtk"
    ];

    "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];

    "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
  };

  # --------------------------------------------------------------------------
  # GLib / GApplication support
  # --------------------------------------------------------------------------

  programs.dconf.enable = true;

  # --------------------------------------------------------------------------
  # Battery notifications
  # --------------------------------------------------------------------------
  #
  # upower is enabled in modules/power but had no thresholds, so it never
  # emitted the low/critical signals the shell's BatteryService listens for.

  services.upower = {
    percentageLow = 20;

    percentageCritical = 10;

    percentageAction = 5;

    criticalPowerAction = "Hibernate";
  };
}
