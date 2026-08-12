{ pkgs, ... }:

{
  stylix = {
    enable = true;
    autoEnable = true;

    polarity = "dark";

    image = ./wallpaper/wallpaper.png;

    # ==========================================
    # Fonts
    # ==========================================

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrains Mono Nerd Font";
      };

      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };

      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };

    # ==========================================
    # Cursor
    # ==========================================

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    # ==========================================
    # Icons
    # ==========================================

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;

      dark = "Papirus-Dark";
      light = "Papirus";
    };

    # ==========================================
    # GTK
    # ==========================================

    targets.gtk.enable = true;

    # ==========================================
    # Qt
    # ==========================================

    targets.qt.enable = true;
  };
}
