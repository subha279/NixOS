{ pkgs, lib, ... }:

let

  # ==========================================================================
  # Aurora Theme Source
  # ==========================================================================

  themeData = import ../../lib/themes.nix;

  activeTheme =
    themeData.themes.${themeData.global.activeTheme};

  colors = activeTheme.colors;

  global = themeData.global;

  # ==========================================================================
  # Central Fonts
  # ==========================================================================

  interfaceFont =
    builtins.getAttr
      global.fonts.interface.package
      pkgs;

  terminalFont =
    builtins.getAttr
      global.fonts.terminal.package
      pkgs;

  emojiFont =
    builtins.getAttr
      global.fonts.emoji.package
      pkgs;

  # ==========================================================================
  # Central Cursor
  # ==========================================================================

  cursorPackage =
    builtins.getAttr
      global.cursor.package
      pkgs;

  # ==========================================================================
  # Central Icons
  # ==========================================================================

  iconPackage =
    builtins.getAttr
      global.icons.package
      pkgs;

  # ==========================================================================
  # Helpers
  # ==========================================================================

  hex =
    color:
    lib.removePrefix "#" color;

in
{
  stylix = {

    # ==========================================================================
    # Core
    # ==========================================================================

    enable = true;

    # Aurora explicitly owns application-specific theming.
    # Stylix remains responsible for system desktop integration.
    autoEnable = false;

    polarity = "dark";

    # ==========================================================================
    # STATIC AURORA COLOR SOURCE
    # ==========================================================================
    #
    # IMPORTANT:
    #
    # No wallpaper image is supplied to Stylix.
    # No Wallust integration exists.
    #
    # Colors come exclusively from lib/themes.nix.
    #
    # ==========================================================================

    base16Scheme = {

      scheme = activeTheme.name;

      # Base

      base00 = hex colors.background;
      base01 = hex colors.surface;
      base02 = hex colors.surfaceHover;
      base03 = hex colors.border;

      base04 = hex colors.textMuted;
      base05 = hex colors.text;
      base06 = hex colors.text;
      base07 = hex colors.text;

      # Semantic

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

    fonts = {

      sansSerif = {
        package = interfaceFont;
        name = global.fonts.interface.name;
      };

      serif = {
        package = interfaceFont;
        name = global.fonts.interface.name;
      };

      monospace = {
        package = terminalFont;
        name = global.fonts.terminal.name;
      };

      emoji = {
        package = emojiFont;
        name = global.fonts.emoji.name;
      };

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
      package = cursorPackage;
      name = global.cursor.name;
      size = global.cursor.size;
    };

    # ==========================================================================
    # ICON THEME
    # ==========================================================================

    icons = {
      enable = true;

      package = iconPackage;

      dark = global.icons.name;
      light = global.icons.name;
    };

    # ==========================================================================
    # DESKTOP TARGETS
    # ==========================================================================
    #
    # autoEnable = false means targets must be explicitly enabled.
    #
    # We intentionally keep GTK, Qt and Fontconfig under Stylix.
    #
    # ==========================================================================

    targets.gtk.enable = true;

    targets.qt.enable = true;

    targets.fontconfig.enable = true;
  };
}
