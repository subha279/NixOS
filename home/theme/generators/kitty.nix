{
  lib,
  themeData,
  themeNames,
}:

let
  themeToKitty =
    themeId:
    let
      theme = themeData.themes.${themeId};
      colors = theme.colors;
      fonts = themeData.global.fonts;
      ui = themeData.global.ui;
    in
    ''
      font_family ${fonts.terminal.name}
      font_size ${toString ui.fontSize}

      foreground ${colors.text}
      background ${colors.background}

      cursor ${colors.accent}
      cursor_text_color ${colors.accentForeground}

      selection_foreground ${colors.text}
      selection_background ${colors.accentMuted}

      url_color ${colors.info}

      color0  ${colors.terminalBlack}
      color1  ${colors.terminalRed}
      color2  ${colors.terminalGreen}
      color3  ${colors.terminalYellow}
      color4  ${colors.terminalBlue}
      color5  ${colors.terminalMagenta}
      color6  ${colors.terminalCyan}
      color7  ${colors.terminalWhite}

      color8  ${colors.terminalBrightBlack}
      color9  ${colors.terminalBrightRed}
      color10 ${colors.terminalBrightGreen}
      color11 ${colors.terminalBrightYellow}
      color12 ${colors.terminalBrightBlue}
      color13 ${colors.terminalBrightMagenta}
      color14 ${colors.terminalBrightCyan}
      color15 ${colors.terminalBrightWhite}

      tab_bar_background ${colors.background}

      active_tab_foreground ${colors.accentForeground}
      active_tab_background ${colors.accent}

      inactive_tab_foreground ${colors.textSecondary}
      inactive_tab_background ${colors.surface}

      background_opacity ${toString ui.terminalOpacity}
    '';

  kittyThemeFiles = lib.genAttrs themeNames (themeId: {
    text = themeToKitty themeId;
  });

in
{
  inherit themeToKitty kittyThemeFiles;

  generatedKittyFiles = lib.mapAttrs' (
    themeId: file: lib.nameValuePair "aurora/themes/${themeId}.kitty.conf" file
  ) kittyThemeFiles;
}
