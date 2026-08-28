{ pkgs, lib, ... }:

let


  themeData = import ../../lib/themes.nix;

  activeTheme = themeData.themes.${themeData.global.activeTheme};

  colors = activeTheme.colors;

  global = themeData.global;


  hex = lib.removePrefix "#";

  pkgFromPath = path: lib.getAttrFromPath (lib.splitString "." path) pkgs;


  hexToInt = s: (builtins.fromTOML "v = 0x${s}").v;

  bgHex = hex colors.background;

  bgBrightness =
    (
      hexToInt (builtins.substring 0 2 bgHex) * 299
      + hexToInt (builtins.substring 2 2 bgHex) * 587
      + hexToInt (builtins.substring 4 2 bgHex) * 114
    )
    / 1000;

  isLight = bgBrightness > 127;


  interfaceFont = pkgFromPath global.fonts.interface.package;

  terminalFont = pkgFromPath global.fonts.terminal.package;

  emojiFont = pkgFromPath global.fonts.emoji.package;


  cursorPackage = pkgFromPath global.cursor.package;


  iconPackage = pkgFromPath global.icons.package;

  iconNameLight = lib.replaceStrings [ "-Dark" ] [ "-Light" ] global.icons.name;

  iconNameDark = global.icons.name;

in
{
  stylix = {


    enable = true;

    autoEnable = false;

    polarity = if isLight then "light" else "dark";


    base16Scheme = {

      scheme = activeTheme.name;
      author = "Aurora (lib/themes.nix)";


      base00 = hex colors.background;
      base01 = hex colors.surface;
      base02 = hex colors.surfaceHover;
      base03 = hex colors.textMuted; # was border -> comments were invisible

      base04 = hex colors.textSecondary; # was textMuted -> ramp was shifted
      base05 = hex colors.text;
      base06 = hex colors.terminalWhite;
      base07 = hex colors.terminalBrightWhite;


      base08 = hex colors.error;
      base09 = hex colors.warning;
      base0A = hex colors.terminalYellow; # was a duplicate of warning
      base0B = hex colors.success;
      base0C = hex colors.terminalCyan;
      base0D = hex colors.info;
      base0E = hex colors.accent;
      base0F = hex colors.terminalMagenta; # was accentMuted -> near-background
    };


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


    cursor = {
      package = cursorPackage;
      name = global.cursor.name;
      size = global.cursor.size;
    };


    icons = {
      enable = true;

      package = iconPackage;

      dark = iconNameDark;
      light = iconNameLight;
    };


    targets.gtk.enable = true;

    targets.qt.enable = true;

    targets.fontconfig.enable = true;
  };
}
