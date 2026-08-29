{ lib, ... }:

let
  themeData = import ../../lib/themes.nix;
  themeNames = builtins.attrNames themeData.themes;

  themeToLua =
    themeId:
    let
      theme = themeData.themes.${themeId};
      colors = theme.colors;
      fonts = themeData.global.fonts;
      ui = themeData.global.ui;
    in
    ''
      return {
        id = "${themeId}",
        name = "${theme.name}",
        description = "${theme.description}",

        fonts = {
          interface = "${fonts.interface.name}",
          terminal = "${fonts.terminal.name}",
          emoji = "${fonts.emoji.name}",
        },

        colors = {
          background = "${colors.background}",
          backgroundDark = "${colors.backgroundDark}",

          surface = "${colors.surface}",
          surfaceHover = "${colors.surfaceHover}",
          surfaceActive = "${colors.surfaceActive}",

          border = "${colors.border}",
          borderFocus = "${colors.borderFocus}",
          separator = "${colors.separator}",

          text = "${colors.text}",
          textSecondary = "${colors.textSecondary}",
          textMuted = "${colors.textMuted}",

          accent = "${colors.accent}",
          accentHover = "${colors.accentHover}",
          accentActive = "${colors.accentActive}",
          accentMuted = "${colors.accentMuted}",
          accentForeground = "${colors.accentForeground}",

          success = "${colors.success}",
          warning = "${colors.warning}",
          error = "${colors.error}",
          info = "${colors.info}",

          terminalBlack = "${colors.terminalBlack}",
          terminalRed = "${colors.terminalRed}",
          terminalGreen = "${colors.terminalGreen}",
          terminalYellow = "${colors.terminalYellow}",
          terminalBlue = "${colors.terminalBlue}",
          terminalMagenta = "${colors.terminalMagenta}",
          terminalCyan = "${colors.terminalCyan}",
          terminalWhite = "${colors.terminalWhite}",

          terminalBrightBlack = "${colors.terminalBrightBlack}",
          terminalBrightRed = "${colors.terminalBrightRed}",
          terminalBrightGreen = "${colors.terminalBrightGreen}",
          terminalBrightYellow = "${colors.terminalBrightYellow}",
          terminalBrightBlue = "${colors.terminalBrightBlue}",
          terminalBrightMagenta = "${colors.terminalBrightMagenta}",
          terminalBrightCyan = "${colors.terminalBrightCyan}",
          terminalBrightWhite = "${colors.terminalBrightWhite}",
        },

        ui = {
          borderWidth = ${toString ui.borderWidth},

          radius = ${toString ui.radius},
          radiusSmall = ${toString ui.radiusSmall},
          radiusLarge = ${toString ui.radiusLarge},

          iconSize = ${toString ui.iconSize},

          fontSize = ${toString ui.fontSize},
          fontSizeSmall = ${toString ui.fontSizeSmall},
          fontSizeLarge = ${toString ui.fontSizeLarge},

          shadowOpacity = ${toString ui.shadowOpacity},
          surfaceOpacity = ${toString ui.surfaceOpacity},
          windowOpacity = ${toString ui.windowOpacity},

          glassOpacity = ${toString ui.glassOpacity},
          glassLuminosity = ${toString ui.glassLuminosity},
          glassGradientOpacity = ${toString ui.glassGradientOpacity},
          glassGrainOpacity = ${toString ui.glassGrainOpacity},
          glassRimOpacity = ${toString ui.glassRimOpacity},

          glassSpecularOpacity = ${toString ui.glassSpecularOpacity},
          glassLensOpacity = ${toString ui.glassLensOpacity},
          glassDepthOpacity = ${toString ui.glassDepthOpacity},
          glassClarity = ${toString ui.glassClarity},

          terminalOpacity = ${toString ui.terminalOpacity},
          editorFloatBlend = ${toString ui.editorFloatBlend},

          clock = {
            hour = "${ui.clock.hour}",
            separator = "${ui.clock.separator}",
            minute = "${ui.clock.minute}",
            second = "${ui.clock.second}",
          },
        },
      }
    '';

  themeToJson =
    themeId:
    builtins.toJSON {
      id = themeId;
      name = themeData.themes.${themeId}.name;
      description = themeData.themes.${themeId}.description;

      fonts = {
        interface = themeData.global.fonts.interface.name;
        terminal = themeData.global.fonts.terminal.name;
        emoji = themeData.global.fonts.emoji.name;
      };

      colors = themeData.themes.${themeId}.colors;
      ui = themeData.global.ui;
    };

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

  themeToTmux =
    themeId:
    let
      theme = themeData.themes.${themeId};
      colors = theme.colors;
      ui = themeData.global.ui;

      clockColors = {
        foreground = colors.text;
        foregroundMuted = colors.textSecondary;
        foregroundFaint = colors.textMuted;

        text = colors.text;
        textSecondary = colors.textSecondary;
        textMuted = colors.textMuted;

        accent = colors.accent;
        accentHover = colors.accentHover;

        success = colors.success;
        warning = colors.warning;
        error = colors.error;
        info = colors.info;
      };

      clockColor = name: clockColors.${name} or colors.text;
    in
    ''
      set -g status on
      set -g status-position bottom
      set -g status-justify left
      set -g status-interval 5

      set -g status-style "bg=${colors.background},fg=${colors.textSecondary}"

      set -g status-left-length 60
      set -g status-right-length 90

      set -g status-left "#[fg=${colors.accent},bg=${colors.background}]#[fg=${colors.accentForeground},bg=${colors.accent},bold] #S #[fg=${colors.accent},bg=${colors.background}] "

      set -g window-status-separator " "

      set -g window-status-format "#[fg=${colors.surface},bg=${colors.background}]#[fg=${colors.textMuted},bg=${colors.surface}] #I #W#{?window_zoomed_flag,  ,}#[fg=${colors.surface},bg=${colors.background}]"

      set -g window-status-current-format "#[fg=${colors.accentMuted},bg=${colors.background}]#[fg=${colors.text},bg=${colors.accentMuted},bold] #I #W#{?window_zoomed_flag,  ,}#[fg=${colors.accentMuted},bg=${colors.background}]"

      set -g window-status-activity-style "fg=${colors.warning},bg=${colors.surface}"
      set -g window-status-bell-style "fg=${colors.error},bg=${colors.surface},bold"

      set -g status-right "#[fg=${colors.warning},bg=${colors.background}]#{?client_prefix,󰌆 ,}#[fg=${clockColor ui.clock.hour},bg=${colors.background},bold]%H#[fg=${clockColor ui.clock.separator},nobold]:#[fg=${clockColor ui.clock.minute},bold]%M#[fg=${colors.textMuted},nobold]  %a %d %b  "

      set -g pane-border-style "fg=${colors.border}"
      set -g pane-active-border-style "fg=${colors.accent}"

      set -g pane-border-lines single
      set -g pane-border-status off

      set -g display-panes-colour "${colors.textMuted}"
      set -g display-panes-active-colour "${colors.accent}"

      set -g message-style "bg=${colors.surface},fg=${colors.text}"
      set -g message-command-style "bg=${colors.surface},fg=${colors.accent}"

      set -g mode-style "bg=${colors.accentMuted},fg=${colors.text}"
      set -g copy-mode-match-style "bg=${colors.accentMuted},fg=${colors.text}"
      set -g copy-mode-current-match-style "bg=${colors.accent},fg=${colors.accentForeground}"

      set -g popup-style "bg=${colors.background},fg=${colors.text}"
      set -g popup-border-style "fg=${colors.accent}"
      set -g popup-border-lines rounded

      set -g clock-mode-colour "${colors.accent}"
      set -g clock-mode-style 24
    '';

  themeToStarship =
    themeId:
    let
      theme = themeData.themes.${themeId};
      colors = theme.colors;
    in
    ''
      add_newline = false
      command_timeout = 1000
      scan_timeout = 30
      follow_symlinks = false
      palette = "aurora"

      # PROMPT

      format = """\
      $directory\
      ''${custom.giturl}\
      $git_branch\
      ''${custom.git_worktree}\
      $git_status\
      $python\
      $cmd_duration\
      $character"""

      # COLORS

      [palettes.aurora]

      background = "${colors.background}"
      surface = "${colors.surface}"
      text = "${colors.text}"
      textMuted = "${colors.textMuted}"

      accent = "${colors.accent}"
      success = "${colors.success}"
      warning = "${colors.warning}"
      error = "${colors.error}"
      info = "${colors.info}"

      # OS

      [os]

      disabled = false
      style = "bold text"
      format = "[$symbol ]($style)"

      [os.symbols]

      NixOS = ""
      Linux = "󰌽"
      Arch = "󰣇"
      Ubuntu = "󰕈"
      Fedora = "󰣛"
      Debian = "󰣚"
      Windows = "󰍲"
      Macos = ""

      # DIRECTORY

      [directory]

      style = "bold text"
      format = "[$path]($style) "
      home_symbol = "~"

      truncation_length = 3
      truncate_to_repo = false
      truncation_symbol = "…/"

      # GIT REMOTE

      [custom.giturl]

      description = "Display Git remote icon"

      command = """
      GIT_REMOTE=$(git remote get-url origin 2>/dev/null)

      case "$GIT_REMOTE" in
        *github*)
          echo ""
          ;;
        *gitlab*)
          echo ""
          ;;
        *bitbucket*)
          echo ""
          ;;
        *)
          echo ""
          ;;
      esac
      """

      when = "git rev-parse --is-inside-work-tree 2>/dev/null"

      format = "[$output](bold accent) "

      require_repo = true
      ignore_timeout = true

      # GIT BRANCH

      [git_branch]

      symbol = " "
      style = "bold accent"
      format = "[$symbol$branch]($style) "

      # GIT WORKTREE

      [custom.git_worktree]

      description = "Show Git worktree indicator"

      command = """
      if git rev-parse --git-dir >/dev/null 2>&1; then
        common_dir=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
        git_dir=$(git rev-parse --path-format=absolute --git-dir 2>/dev/null)

        if [ "$common_dir" != "$git_dir" ]; then
          echo "⛓"
        fi
      fi
      """

      when = "git rev-parse --is-inside-work-tree >/dev/null 2>&1"

      format = "[$output](bold accent) "

      require_repo = true
      ignore_timeout = true

      # GIT STATUS

      [git_status]

      style = "bold text"
      format = "[$all_status$ahead_behind]($style) "

      untracked = "[?](bold error)"
      staged = "[+](bold success)"
      modified = "[!](bold warning)"
      renamed = "[»](bold info)"
      deleted = "[-](bold error)"
      conflicted = "[✖](bold error)"
      stashed = "[≡](bold accent)"
      typechanged = "[󰜄](bold info)"

      ahead = "[⇡''${count}](bold info)"
      behind = "[⇣''${count}](bold warning)"
      diverged = "[⇕⇡''${ahead_count}⇣''${behind_count}](bold error)"

      up_to_date = ""

      # PYTHON

      [python]

      symbol = " "
      style = "bold warning"
      format = "[$symbol$version]($style) "

      # COMMAND DURATION

      [cmd_duration]

      min_time = 1000
      style = "bold textMuted"
      format = "󰔟 [$duration]($style) "

      # PROMPT CHARACTER

      [character]

      success_symbol = "[➜](bold accent)"
      error_symbol = "[➜](bold error)"
      vimcmd_symbol = "[➜](bold info)"

    '';

  luaThemeFiles = lib.genAttrs themeNames (themeId: {
    text = themeToLua themeId;
  });

  jsonThemeFiles = lib.genAttrs themeNames (themeId: {
    text = themeToJson themeId;
  });

  kittyThemeFiles = lib.genAttrs themeNames (themeId: {
    text = themeToKitty themeId;
  });

  tmuxThemeFiles = lib.genAttrs themeNames (themeId: {
    text = themeToTmux themeId;
  });

  starshipThemeFiles = lib.genAttrs themeNames (themeId: {
    text = themeToStarship themeId;
  });

  themeList = builtins.concatStringsSep "\n" (
    map (
      themeId:
      let
        theme = themeData.themes.${themeId};
      in
      "${themeId}\t${theme.name}"
    ) themeNames
  );

  generatedLuaFiles = lib.mapAttrs' (
    themeId: file: lib.nameValuePair "aurora/themes/${themeId}.lua" file
  ) luaThemeFiles;

  generatedJsonFiles = lib.mapAttrs' (
    themeId: file: lib.nameValuePair "aurora/themes/${themeId}.json" file
  ) jsonThemeFiles;

  generatedKittyFiles = lib.mapAttrs' (
    themeId: file: lib.nameValuePair "aurora/themes/${themeId}.kitty.conf" file
  ) kittyThemeFiles;

  generatedTmuxFiles = lib.mapAttrs' (
    themeId: file: lib.nameValuePair "aurora/themes/${themeId}.tmux.conf" file
  ) tmuxThemeFiles;

  generatedStarshipFiles = lib.mapAttrs' (
    themeId: file: lib.nameValuePair "aurora/themes/${themeId}.starship.toml" file
  ) starshipThemeFiles;

in
{
  stylix.targets.gtk.enable = true;
  stylix.targets.qt.enable = true;
  stylix.targets.fontconfig.enable = true;

  xdg.configFile = {
    "aurora/themes.json".text = builtins.toJSON themeData;
    "aurora/themes.list".text = themeList + "\n";
  }

  // generatedLuaFiles
  // generatedJsonFiles
  // generatedKittyFiles
  // generatedTmuxFiles
  // generatedStarshipFiles;

  home.activation.initializeAuroraTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    theme_dir="$HOME/.config/aurora"
    theme_file="$theme_dir/active-theme"
    active_lua="$theme_dir/active-theme.lua"
    active_kitty="$theme_dir/active-kitty.conf"
    active_tmux="$theme_dir/active-tmux.conf"
    active_starship="$theme_dir/active-starship.toml"

    mkdir -p "$theme_dir"
    mkdir -p "$HOME/.cache/aurora"

    if [ ! -f "$theme_file" ]; then
      printf '%s\n' "catppuccin-mocha" > "$theme_file"
    fi

    selected="$(cat "$theme_file")"

    if [[ ! -f "$theme_dir/themes/$selected.lua" ]]; then
      printf '%s\n' "catppuccin-mocha" > "$theme_file"
      selected="catppuccin-mocha"
    fi

    ln -sfn \
      "$theme_dir/themes/$selected.lua" \
      "$active_lua"

    if [[ -f "$theme_dir/themes/$selected.kitty.conf" ]]; then
      ln -sfn \
        "$theme_dir/themes/$selected.kitty.conf" \
        "$active_kitty"
    else
      ln -sfn \
        "$theme_dir/themes/catppuccin-mocha.kitty.conf" \
        "$active_kitty"
    fi

    if [[ -f "$theme_dir/themes/$selected.tmux.conf" ]]; then
      ln -sfn \
        "$theme_dir/themes/$selected.tmux.conf" \
        "$active_tmux"
    else
      ln -sfn \
        "$theme_dir/themes/catppuccin-mocha.tmux.conf" \
        "$active_tmux"
    fi

    if [[ -f "$theme_dir/themes/$selected.starship.toml" ]]; then
      ln -sfn \
        "$theme_dir/themes/$selected.starship.toml" \
        "$active_starship"
    else
      ln -sfn \
        "$theme_dir/themes/catppuccin-mocha.starship.toml" \
        "$active_starship"
    fi
  '';

  home.file.".local/bin/aurora-theme" = {
    executable = true;

    text = ''
      #!/usr/bin/env bash

      set -euo pipefail

      CONFIG_DIR="$HOME/.config/aurora"
      THEMES_FILE="$CONFIG_DIR/themes.list"
      ACTIVE_THEME="$CONFIG_DIR/active-theme"
      ACTIVE_LUA="$CONFIG_DIR/active-theme.lua"
      ACTIVE_KITTY="$CONFIG_DIR/active-kitty.conf"
      ACTIVE_TMUX="$CONFIG_DIR/active-tmux.conf"
      ACTIVE_STARSHIP="$CONFIG_DIR/active-starship.toml"
      THEME_DIR="$CONFIG_DIR/themes"

      if [[ ! -f "$THEMES_FILE" ]]; then
        echo "Aurora: theme list not found." >&2
        exit 1
      fi

      if [[ $# -gt 0 ]]; then
        selected="$1"
      else
        echo "Aurora: usage: aurora-theme <theme-id|display-name>" >&2
        echo "Aurora: for a picker, run: qs ipc call theme toggle" >&2
        exit 1
      fi

      [[ -z "$selected" ]] && exit 0

      theme_id="$(
        awk -F '\t' -v sel="$selected" '
          $1 == sel || $2 == sel {
            print $1
            exit
          }
        ' "$THEMES_FILE"
      )"

      if [[ -z "$theme_id" ]]; then
        echo "Aurora: unknown theme: $selected" >&2
        exit 1
      fi

      theme_lua="$THEME_DIR/$theme_id.lua"
      theme_json="$THEME_DIR/$theme_id.json"
      theme_kitty="$THEME_DIR/$theme_id.kitty.conf"
      theme_tmux="$THEME_DIR/$theme_id.tmux.conf"
      theme_starship="$THEME_DIR/$theme_id.starship.toml"

      if [[ ! -f "$theme_lua" ]]; then
        echo "Aurora: generated Lua theme not found: $theme_id" >&2
        exit 1
      fi

      if [[ ! -f "$theme_json" ]]; then
        echo "Aurora: generated JSON theme not found: $theme_id" >&2
        exit 1
      fi

      if [[ ! -f "$theme_kitty" ]]; then
        echo "Aurora: generated Kitty theme not found: $theme_id" >&2
        exit 1
      fi

      if [[ ! -f "$theme_tmux" ]]; then
        echo "Aurora: generated Tmux theme not found: $theme_id" >&2
        exit 1
      fi

      if [[ ! -f "$theme_starship" ]]; then
        echo "Aurora: generated Starship theme not found: $theme_id" >&2
        exit 1
      fi

      KREO_CONFIG="/etc/aurora/kreo-rgb.conf"

      if [[ -r "$KREO_CONFIG" ]] &&
         grep -q '^enabled=1$' "$KREO_CONFIG" &&
         grep -q '^follow-theme=1$' "$KREO_CONFIG"; then

        if command -v kreo-rgb >/dev/null 2>&1 &&
           command -v jq >/dev/null 2>&1; then

          kreo_accent="$(
            jq -r '.colors.accent // empty' "$theme_json"
          )"

          if [[ "$kreo_accent" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
            kreo-rgb "$kreo_accent" >/dev/null 2>&1 || true
          fi
        fi
      fi

      ln -sfn "$theme_lua" "$ACTIVE_LUA"
      ln -sfn "$theme_kitty" "$ACTIVE_KITTY"
      ln -sfn "$theme_tmux" "$ACTIVE_TMUX"
      ln -sfn "$theme_starship" "$ACTIVE_STARSHIP"

      printf '%s\n' "$theme_id" > "$ACTIVE_THEME"

      if command -v hyprctl >/dev/null 2>&1; then
        hyprctl reload >/dev/null 2>&1 || true
      fi

      if command -v kitten >/dev/null 2>&1; then
        shopt -s nullglob

        kitty_sockets=(
          "$XDG_RUNTIME_DIR"/kitty-*
        )

        for socket in "''${kitty_sockets[@]}"; do
          [[ -S "$socket" ]] || continue

          kitten @ \
            --to "unix:$socket" \
            set-colors \
            --all \
            --configured \
            "$theme_kitty" \
            >/dev/null 2>&1 || true
        done
      fi

      if command -v tmux >/dev/null 2>&1; then
        if tmux has-session 2>/dev/null; then
          tmux source-file "$ACTIVE_TMUX" >/dev/null 2>&1 || true
          tmux refresh-client -S >/dev/null 2>&1 || true
        fi
      fi

      AURORA_ZSH_REFRESH_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/aurora-zsh"

      if [[ -d "$AURORA_ZSH_REFRESH_DIR" ]]; then
        for fifo in "$AURORA_ZSH_REFRESH_DIR"/*; do
          [[ -p "$fifo" ]] || continue

          (
            printf '%s\n' "refresh" > "$fifo"
          ) >/dev/null 2>&1 &
        done
      fi

      echo "Aurora theme: $selected"
    '';
  };
}
