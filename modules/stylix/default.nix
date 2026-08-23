{ pkgs, lib, ... }:

let

  # Aurora Theme Source

  themeData = import ../../lib/themes.nix;

  activeTheme = themeData.themes.${themeData.global.activeTheme};

  colors = activeTheme.colors;

  global = themeData.global;

  # Helpers

  # themes.nix stores colors as "#RRGGBB"; base16 wants them bare.
  hex = lib.removePrefix "#";

  # Resolve DOTTED package paths such as "maple-mono.truetype".
  pkgFromPath = path: lib.getAttrFromPath (lib.splitString "." path) pkgs;

  # Polarity Detection

  hexToInt = s: (builtins.fromTOML "v = 0x${s}").v;

  bgHex = hex colors.background;

  # Perceived brightness, ITU-R BT.601.
  bgBrightness =
    (
      hexToInt (builtins.substring 0 2 bgHex) * 299
      + hexToInt (builtins.substring 2 2 bgHex) * 587
      + hexToInt (builtins.substring 4 2 bgHex) * 114
    )
    / 1000;

  isLight = bgBrightness > 127;

  # Central Fonts

  interfaceFont = pkgFromPath global.fonts.interface.package;

  terminalFont = pkgFromPath global.fonts.terminal.package;

  emojiFont = pkgFromPath global.fonts.emoji.package;

  # Central Cursor

  cursorPackage = pkgFromPath global.cursor.package;

  # Central Icons

  iconPackage = pkgFromPath global.icons.package;

  # Colloid-Dark -> Colloid-Light for light polarity.
  iconNameLight = lib.replaceStrings [ "-Dark" ] [ "-Light" ] global.icons.name;

  iconNameDark = global.icons.name;

in
{
  stylix = {

    # Core

    enable = true;

    # Aurora explicitly owns application-specific theming.
    autoEnable = false;

    # Derived, not hardcoded. See Polarity Detection above.
    polarity = if isLight then "light" else "dark";

    # STATIC AURORA COLOR SOURCE

    base16Scheme = {

      scheme = activeTheme.name;
      author = "Aurora (lib/themes.nix)";

      # Base ramp

      base00 = hex colors.background;
      base01 = hex colors.surface;
      base02 = hex colors.surfaceHover;
      base03 = hex colors.textMuted; # was border -> comments were invisible

      base04 = hex colors.textSecondary; # was textMuted -> ramp was shifted
      base05 = hex colors.text;
      # base06/base07 are the bright end of the foreground ramp.
      base06 = hex colors.terminalWhite;
      base07 = hex colors.terminalBrightWhite;

      # Semantic

      base08 = hex colors.error;
      base09 = hex colors.warning;
      base0A = hex colors.terminalYellow; # was a duplicate of warning
      base0B = hex colors.success;
      base0C = hex colors.terminalCyan;
      base0D = hex colors.info;
      base0E = hex colors.accent;
      base0F = hex colors.terminalMagenta; # was accentMuted -> near-background
    };

    # FONTS

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

    # CURSOR

    cursor = {
      package = cursorPackage;
      name = global.cursor.name;
      size = global.cursor.size;
    };

    # ICON THEME

    icons = {
      enable = true;

      package = iconPackage;

      dark = iconNameDark;
      light = iconNameLight;
    };

    # ========================================================================
    # DESKTOP TARGETS
    # ========================================================================
    #
    # autoEnable = false means targets must be explicitly enabled.
    #
    # We intentionally keep GTK, Qt and Fontconfig under Stylix.
    #
    # Neovim is deliberately NOT a Stylix target: enabling it would
    # generate a base16 colorscheme and override the real plugin
    # colorschemes. Transparency is handled in the Neovim config with a
    # ColorScheme autocmd instead. If you ever want Stylix to own nvim:
    #
    #   targets.neovim = {
    #     enable = true;
    #     transparentBackground = {
    #       main = true;
    #       signColumn = true;
    #     };
    #   };
    #
    # Both lines are required -- transparentBackground alone is a no-op
    # while the target is disabled.
    #
    # ========================================================================

    targets.gtk.enable = true;

    targets.qt.enable = true;

    targets.fontconfig.enable = true;
  };
}
