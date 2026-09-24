{
  lib,
  themeData,
  ...
}:

let
  hexToDec =
    hex:
    let
      h = lib.removePrefix "#" hex;

      digit =
        c:
        {
          "0" = 0;
          "1" = 1;
          "2" = 2;
          "3" = 3;
          "4" = 4;
          "5" = 5;
          "6" = 6;
          "7" = 7;
          "8" = 8;
          "9" = 9;
          "a" = 10;
          "b" = 11;
          "c" = 12;
          "d" = 13;
          "e" = 14;
          "f" = 15;
        }
        .${lib.toLower c};

      byte =
        offset:
        digit (builtins.substring offset 1 h) * 16
        + digit (builtins.substring (offset + 1) 1 h);
    in
    {
      r = byte 0;
      g = byte 2;
      b = byte 4;
    };

  toBase16 =
    themeId:
    let
      colors = themeData.themes.${themeId}.colors;
    in
    {
      base00 = lib.removePrefix "#" colors.background;
      base01 = lib.removePrefix "#" colors.surface;
      base02 = lib.removePrefix "#" colors.surfaceHover;
      base03 = lib.removePrefix "#" colors.textMuted;
      base04 = lib.removePrefix "#" colors.textSecondary;
      base05 = lib.removePrefix "#" colors.text;
      base06 = lib.removePrefix "#" colors.terminalWhite;
      base07 = lib.removePrefix "#" colors.terminalBrightWhite;
      base08 = lib.removePrefix "#" colors.error;
      base09 = lib.removePrefix "#" colors.warning;
      base0A = lib.removePrefix "#" colors.terminalYellow;
      base0B = lib.removePrefix "#" colors.success;
      base0C = lib.removePrefix "#" colors.terminalCyan;
      base0D = lib.removePrefix "#" colors.info;
      base0E = lib.removePrefix "#" colors.accent;
      base0F = lib.removePrefix "#" colors.terminalMagenta;
    };

  renderTemplate =
    template: base16:
    let
      base01Rgb = hexToDec base16.base01;

      replacements = {
        "{{base00-hex}}" = base16.base00;
        "{{base01-hex}}" = base16.base01;
        "{{base02-hex}}" = base16.base02;
        "{{base03-hex}}" = base16.base03;
        "{{base04-hex}}" = base16.base04;
        "{{base05-hex}}" = base16.base05;
        "{{base06-hex}}" = base16.base06;
        "{{base07-hex}}" = base16.base07;
        "{{base08-hex}}" = base16.base08;
        "{{base09-hex}}" = base16.base09;
        "{{base0A-hex}}" = base16.base0A;
        "{{base0B-hex}}" = base16.base0B;
        "{{base0C-hex}}" = base16.base0C;
        "{{base0D-hex}}" = base16.base0D;
        "{{base0E-hex}}" = base16.base0E;
        "{{base0F-hex}}" = base16.base0F;

        "{{base01-dec-r}}" = toString base01Rgb.r;
        "{{base01-dec-g}}" = toString base01Rgb.g;
        "{{base01-dec-b}}" = toString base01Rgb.b;
      };
    in
    lib.foldl'
      (
        result: replacement:
        lib.replaceStrings [ replacement.from ] [ replacement.to ] result
      )
      (builtins.readFile template)
      (
        lib.mapAttrsToList
          (from: to: {
            inherit from to;
          })
          replacements
      );

in
{
  inherit
    hexToDec
    toBase16
    renderTemplate
    ;
}
