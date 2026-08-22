{ pkgs, ... }:

{
  # ==========================================================================
  # Desktop Services
  # ==========================================================================

  services.gvfs.enable = true;

  services.udisks2.enable = true;

  # --------------------------------------------------------------------------
  # Thunar
  # --------------------------------------------------------------------------
  #
  # Using the module rather than the bare package. The package on its own has
  # no plugin path, cannot persist its settings, and its file-operation and
  # device notifications never reach the daemon.

  programs.thunar = {
    enable = true;

    plugins = with pkgs.xfce; [
      thunar-volman
      thunar-archive-plugin
      thunar-media-tags-plugin
    ];
  };

  # Settings persistence for Thunar.
  programs.xfconf.enable = true;

  # Thumbnails. The tumbler package was installed but the service that
  # actually registers the thumbnailers was not enabled, so Thunar never
  # generated previews.
  services.tumbler.enable = true;
}
