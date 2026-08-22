{ pkgs, ... }:

{
  # ==========================================================================
  # Aurora Hyprland
  # ==========================================================================
  #
  # Hyprland itself consumes the Aurora theme through:
  #
  #   ~/.config/aurora/active-theme.lua
  #
  # Stylix remains responsible for system-wide GTK/Qt/font/cursor/icon
  # integration.
  #
  # Wallust is NOT part of the theme pipeline.
  #
  # ==========================================================================

  # ==========================================================================
  # Polkit Qt Environment Override
  # ==========================================================================

  xdg.configFile."systemd/user/plasma-polkit-agent.service.d/environment.conf".text = ''
    [Service]
    Environment=QT_STYLE_OVERRIDE=
  '';

  # ==========================================================================
  # Hyprland Lua Configuration
  # ==========================================================================

  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;

  # ==========================================================================
  # Hyprland Configuration Modules
  # ==========================================================================

  xdg.configFile."hypr/config".source = ./config;

  # ==========================================================================
  # Wallpaper Scripts
  # ==========================================================================
  #
  # Wallpaper selection is completely independent from theming.
  #
  # Selecting a wallpaper:
  #
  #   changes the wallpaper
  #
  # It does NOT:
  #
  #   generate colors
  #   change Aurora theme
  #   modify Kitty colors
  #   modify Neovim colors
  #   modify QuickShell colors
  #
  # ==========================================================================

  # Wallpaper selection itself now lives in Quickshell, in
  # home/quickshell/config/modules/WallpaperPicker.qml. Only the
  # boot-time restore hook is still a script, because it has to run
  # before the shell is up.

  xdg.configFile."hypr/scripts/restore-wallpaper.sh".source = ./scripts/restore-wallpaper.sh;

  # ==========================================================================
  # Aurora Desktop Services
  # ==========================================================================

  systemd.user.targets.desktop-services = {
    Unit = {
      Description = "Aurora desktop services";

      Wants = [
        "quickshell.service"
        "awww-daemon.service"
        "plasma-polkit-agent.service"
      ];
    };
  };

  # ==========================================================================
  # Awww Wallpaper Daemon
  # ==========================================================================

  systemd.user.services.awww-daemon = {
    Unit = {
      Description = "Awww Wayland wallpaper daemon";

      PartOf = [
        "desktop-services.target"
      ];
    };

    Service = {
      ExecStart = "${pkgs.awww}/bin/awww-daemon";

      Restart = "on-failure";

      RestartSec = 2;
    };
  };
}
