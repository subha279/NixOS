{
  lib,
  themeData,
  themeNames,
  ...
}:

let
  themeToTmux =
    themeId:
    let
      theme = themeData.themes.${themeId};
      colors = theme.colors;
      fonts = themeData.global.fonts;
      ui = themeData.global.ui;
    in
    ''
      # ---- Theme palette (Sunflower: ${theme.name}) ----
      set -g @THM_BG "${colors.background}"
      set -g @THM_FG "${colors.text}"
      set -g @THM_ACCENT "${colors.accent}"
      set -g @THM_ACCENT_HOVER "${colors.accentHover}"
      set -g @THM_ACCENT_ACTIVE "${colors.accentActive}"
      set -g @THM_ACCENT_MUTED "${colors.accentMuted}"
      set -g @THM_ACCENT_FG "${colors.accentForeground}"
      set -g @THM_BORDER "${colors.border}"
      set -g @THM_BORDER_FOCUS "${colors.borderFocus}"
      set -g @THM_SURFACE "${colors.surface}"
      set -g @THM_SURFACE_HOVER "${colors.surfaceHover}"
      set -g @THM_TEXT_MUTED "${colors.textMuted}"
      set -g @THM_TEXT_SECONDARY "${colors.textSecondary}"

      # ANSI colors
      set -g @THM_BLACK "${colors.terminalBlack}"
      set -g @THM_RED "${colors.terminalRed}"
      set -g @THM_GREEN "${colors.terminalGreen}"
      set -g @THM_YELLOW "${colors.terminalYellow}"
      set -g @THM_BLUE "${colors.terminalBlue}"
      set -g @THM_MAGENTA "${colors.terminalMagenta}"
      set -g @THM_CYAN "${colors.terminalCyan}"
      set -g @THM_WHITE "${colors.terminalWhite}"
      set -g @THM_BRIGHT_BLACK "${colors.terminalBrightBlack}"
      set -g @THM_BRIGHT_RED "${colors.terminalBrightRed}"
      set -g @THM_BRIGHT_GREEN "${colors.terminalBrightGreen}"
      set -g @THM_BRIGHT_YELLOW "${colors.terminalBrightYellow}"
      set -g @THM_BRIGHT_BLUE "${colors.terminalBrightBlue}"
      set -g @THM_BRIGHT_MAGENTA "${colors.terminalBrightMagenta}"
      set -g @THM_BRIGHT_CYAN "${colors.terminalBrightCyan}"
      set -g @THM_BRIGHT_WHITE "${colors.terminalBrightWhite}"

      # Options that require LITERAL colors (no #{@VAR} expansion)
      set -g clock-mode-colour "${colors.terminalBlue}"
      set -g display-panes-active-colour "${colors.accent}"
      set -g display-panes-colour "${colors.border}"
    '';

  tmuxThemeFiles = lib.genAttrs themeNames (themeId: {
    text = themeToTmux themeId;
  });

  generatedTmuxFiles = lib.mapAttrs' (
    themeId: file: lib.nameValuePair "sunflower/themes/${themeId}.tmux.conf" file
  ) tmuxThemeFiles;

in
{
  inherit
    themeToTmux
    tmuxThemeFiles
    generatedTmuxFiles
    ;
}
