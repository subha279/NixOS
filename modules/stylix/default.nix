{ pkgs, lib, ... }:

let

  # ==========================================================================
  # Aurora Theme Source
  # ==========================================================================

  themeData = import ../../lib/themes.nix;

  activeTheme = themeData.themes.${themeData.global.activeTheme};

  colors = activeTheme.colors;

  global = themeData.global;

  # ==========================================================================
  # Central Fonts
  # ==========================================================================

  interfaceFont = builtins.getAttr global.fonts.interface.package pkgs;

  terminalFont = builtins.getAttr global.fonts.terminal.package pkgs;

  emojiFont = builtins.getAttr global.fonts.emoji.package pkgs;

  # ==========================================================================
  # Helpers
  # ==========================================================================

  hex = color: lib.removePrefix "#" color;

in
{
  stylix = {

    # ==========================================================================
    # Core
    # ==========================================================================

    enable = true;

    # We explicitly enable the targets we want.
    #
    # This prevents Stylix from silently taking ownership of applications
    # that Aurora configures itself.
    autoEnable = false;

    polarity = "dark";

    # ==========================================================================
    # COLOR SOURCE
    # ==========================================================================
    #
    # IMPORTANT:
    #
    # Aurora is now the color authority.
    #
    # No wallpaper-generated palette.
    # No Wallust palette.
    #
    # lib/themes.nix
    #       ↓
    #   activeTheme
    #       ↓
    #   Aurora colors
    #       ↓
    #      Stylix
    #
    # Stylix accepts a Base16 attribute set directly.
    #
    # ==========================================================================

    base16Scheme = {

      scheme = activeTheme.name;

      # ------------------------------------------------------------------------
      # Base
      # ------------------------------------------------------------------------

      base00 = hex colors.background;
      base01 = hex colors.surface;
      base02 = hex colors.surfaceHover;
      base03 = hex colors.border;

      base04 = hex colors.textMuted;
      base05 = hex colors.text;
      base06 = hex colors.text;
      base07 = hex colors.text;

      # ------------------------------------------------------------------------
      # Semantic
      # ------------------------------------------------------------------------

      base08 = hex colors.error;
      base09 = hex colors.warning;
      base0A = hex colors.warning;
      base0B = hex colors.success;
      base0C = hex colors.terminalCyan;
      base0D = hex colors.info;
      base0E = hex colors.accent;
      base0F = hex colors.accentMuted;
    };

    # ==========================================================================
    # FONTS
    # ==========================================================================
    #
    # The interface font comes from:
    #
    #     lib/themes.nix
    #
    # The terminal font remains independently configurable because a terminal
    # and desktop UI have different font requirements.
    #
    # If you want ONE font everywhere, set interface and terminal to the same
    # font in lib/themes.nix.
    #
    # ==========================================================================

    fonts = {

      # ------------------------------------------------------------------------
      # Interface
      # ------------------------------------------------------------------------

      sansSerif = {
        package = interfaceFont;
        name = global.fonts.interface.name;
      };

      # ------------------------------------------------------------------------
      # Serif
      # ------------------------------------------------------------------------
      #
      # Use the interface font as the default serif fallback as well.
      # This keeps the system visually consistent.
      #
      serif = {
        package = interfaceFont;
        name = global.fonts.interface.name;
      };

      # ------------------------------------------------------------------------
      # Terminal / Editor
      # ------------------------------------------------------------------------

      monospace = {
        package = terminalFont;
        name = global.fonts.terminal.name;
      };

      # ------------------------------------------------------------------------
      # Emoji
      # ------------------------------------------------------------------------

      emoji = {
        package = emojiFont;
        name = global.fonts.emoji.name;
      };

      # ------------------------------------------------------------------------
      # Global Font Sizes
      # ------------------------------------------------------------------------

      sizes = {

        applications = global.ui.fontSize;

        desktop = global.ui.fontSize;

        popups = global.ui.fontSize;

        terminal = global.ui.fontSize;
      };
    };

    # ==========================================================================
    # CURSOR
    # ==========================================================================

    cursor = {
      package = builtins.getAttr global.cursor.package pkgs;

      name = global.cursor.name;

      size = global.cursor.size;
    };

    # ==========================================================================
    # ICONS
    # ==========================================================================

    icons = {
      enable = true;

      package = builtins.getAttr global.icons.package pkgs;

      dark = global.icons.name;

      light = global.icons.name;
    };

    # ==========================================================================
    # GTK
    # ==========================================================================

    targets.gtk.enable = true;

    # ==========================================================================
    # QT
    # ==========================================================================

    targets.qt.enable = true;

    # ==========================================================================
    # FONTCONFIG
    # ==========================================================================
    #
    # Makes the Aurora fonts the system default fonts through Fontconfig.
    #
    # This is particularly important for applications which don't have a
    # dedicated Stylix target.
    #
    # ==========================================================================

    targets.fontconfig.enable = true;

  };
}
