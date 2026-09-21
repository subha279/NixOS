{ lib, pkgs, ... }:

let
  themeData = import ../../lib/themes.nix;
  themeNames = builtins.attrNames themeData.themes;

  iconPackage = pkgs.colloid-icon-theme;
  iconThemeName = themeData.global.icons.name;

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
        offset: digit (builtins.substring offset 1 h) * 16 + digit (builtins.substring (offset + 1) 1 h);
    in
    {
      r = byte 0;
      g = byte 2;
      b = byte 4;
    };

  stylixBase16 =
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

  renderStylixTemplate =
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
    lib.foldl' (result: replacement: lib.replaceStrings [ replacement.from ] [ replacement.to ] result)
      (builtins.readFile template)
      (
        lib.mapAttrsToList (from: to: {
          inherit from to;
        }) replacements
      );

  gtk3Template = ./templates/gtk-3.0.css.mustache;
  gtk4Template = ./templates/gtk-4.0.css.mustache;

  kvconfigTemplate = ./templates/kvconfig.mustache;
  kvantumSvgTemplate = ./templates/kvantum.svg.mustache;

  themeToGtk3 = themeId: renderStylixTemplate gtk3Template (stylixBase16 themeId);

  themeToGtk4 = themeId: renderStylixTemplate gtk4Template (stylixBase16 themeId);

  themeToKvantumConfig = themeId: renderStylixTemplate kvconfigTemplate (stylixBase16 themeId);

  themeToKvantumSvg = themeId: renderStylixTemplate kvantumSvgTemplate (stylixBase16 themeId);

  gtk3ThemeFiles = lib.genAttrs themeNames (themeId: {
    text = themeToGtk3 themeId;
  });

  gtk4ThemeFiles = lib.genAttrs themeNames (themeId: {
    text = themeToGtk4 themeId;
  });

  kvantumConfigFiles = lib.genAttrs themeNames (themeId: {
    text = themeToKvantumConfig themeId;
  });

  kvantumSvgFiles = lib.genAttrs themeNames (themeId: {
    text = themeToKvantumSvg themeId;
  });

  generatedGtk3Files = lib.mapAttrs' (
    themeId: file: lib.nameValuePair "aurora/themes/${themeId}/gtk-3.0/gtk.css" file
  ) gtk3ThemeFiles;

  generatedGtk4Files = lib.mapAttrs' (
    themeId: file: lib.nameValuePair "aurora/themes/${themeId}/gtk-4.0/gtk.css" file
  ) gtk4ThemeFiles;

  generatedKvantumConfigFiles = lib.mapAttrs' (
    themeId: file: lib.nameValuePair "aurora/themes/${themeId}/kvantum/Base16Kvantum.kvconfig" file
  ) kvantumConfigFiles;

  generatedKvantumSvgFiles = lib.mapAttrs' (
    themeId: file: lib.nameValuePair "aurora/themes/${themeId}/kvantum/Base16Kvantum.svg" file
  ) kvantumSvgFiles;

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

          syntax = {
            comment = "${colors.syntax.comment}";
            variable = "${colors.syntax.variable}";
            parameter = "${colors.syntax.parameter}";
            property = "${colors.syntax.property}";
            func = "${colors.syntax.func}";
            method = "${colors.syntax.method}";
            keyword = "${colors.syntax.keyword}";
            keywordControl = "${colors.syntax.keywordControl}";
            type = "${colors.syntax.type}";
            constant = "${colors.syntax.constant}";
            string = "${colors.syntax.string}";
            number = "${colors.syntax.number}";
            boolean = "${colors.syntax.boolean}";
            operator = "${colors.syntax.operator}";
            punctuation = "${colors.syntax.punctuation}";
            tag = "${colors.syntax.tag}";
            attribute = "${colors.syntax.attribute}";
            namespace = "${colors.syntax.namespace}";
            builtin = "${colors.syntax.builtin}";
            regex = "${colors.syntax.regex}";
            special = "${colors.syntax.special}";
            macro = "${colors.syntax.macro}";
          },

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

        format = """\

        $directory\

        ''${custom.giturl}\

        $git_branch\

        ''${custom.git_worktree}\

        $git_status\

        $package\

        $nodejs\

        $bun\

        $c\

        $rust\

        $golang\

        $php\

        $java\

        $kotlin\

        $haskell\

        $python\

        $docker_context\

        $cmd_duration\

        $character"""

        [palettes.aurora]

        bg = "${colors.background}"

        surface = "${colors.surface}"

        surface2 = "${colors.surfaceHover}"

        surface3 = "${colors.surfaceActive}"

        text = "${colors.text}"

        text_soft = "${colors.textSecondary}"

        muted = "${colors.textMuted}"

        dim = "${colors.textMuted}"

        purple = "${colors.accent}"

        purple_bright = "${colors.accentHover}"

        purple_soft = "${colors.accentMuted}"

        purple_dark = "${colors.border}"

        blue = "${colors.terminalBlue}"

        cyan = "${colors.terminalCyan}"

        green = "${colors.success}"

        yellow = "${colors.warning}"

        orange = "${colors.warning}"

        red = "${colors.error}"

        pink = "${colors.terminalMagenta}"

        [os]

        disabled = false

        style = "bold text"

        format = "[$symbol ]($style)"

        [os.symbols]

        NixOS = ""

        Macos = ""

        Windows = "󰍲"

        [directory]

        style = "bold text"

        format = "[$path]($style)[$read_only]($read_only_style) "

        home_symbol = "~"

        truncation_length = 3

        truncate_to_repo = false

        truncation_symbol = "…/"

        read_only = " 󰌾"

        read_only_style = "bold red"

        [custom.giturl]

        description = "Display symbol for remote Git server"

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

        *git*)

        echo ""

        ;;

        *)

        echo ""

        ;;

        esac

        """

        when = "git rev-parse --is-inside-work-tree 2>/dev/null"

        format = "[$output](bold purple) "

        require_repo = true

        ignore_timeout = true

        [git_branch]

        symbol = " "

        format = "[](purple)[ $symbol$branch ](bold bg bg:purple)[](purple) "

        [custom.git_worktree]

        description = "Show indicator when inside a Git worktree"

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

        format = "[$output](bold purple) "

        style = "bold purple"

        require_repo = true

        ignore_timeout = true

        [git_status]

        style = "bold text"

        format = "[$untracked$staged$modified$renamed$deleted$conflicted$stashed$typechanged$ahead_behind]($style) "

        untracked = "[?](bold red)"

        staged = "[+](bold green)"

        modified = "[!](bold yellow)"

        renamed = "[»](bold blue)"

        deleted = "[-](bold red)"

        conflicted = "[✖](bold red)"

        stashed = "[≡](bold purple)"

        typechanged = "[󰜄](bold cyan)"

        ahead = "[⇡''${count}](bold cyan)"

        behind = "[⇣''${count}](bold orange)"

        diverged = "[⇕⇡''${ahead_count}⇣''${behind_count}](bold pink)"

        up_to_date = ""

        [package]

        disabled = false

        symbol = "󰏗 "

        style = "bold purple"

        format = "[$symbol$version]($style) "

        [nodejs]

        symbol = ""

        style = "bold green"

        format = "[$symbol( $version)]($style) "

        [bun]

        symbol = "🥟"

        style = "bold orange"

        format = "[$symbol( $version)]($style) "

        detect_files = [

        "bun.lock",

        "bun.lockb",

        ]

        [c]

        symbol = " "

        style = "bold blue"

        format = "[$symbol( $version)]($style) "

        [rust]

        symbol = ""

        style = "bold orange"

        format = "[$symbol( $version)]($style) "

        [golang]

        symbol = ""

        style = "bold cyan"

        format = "[$symbol( $version)]($style) "

        detect_files = [

        "go.mod",

        ]

        [php]

        symbol = ""

        style = "bold purple"

        format = "[$symbol( $version)]($style) "

        [java]

        symbol = " "

        style = "bold red"

        format = "[$symbol( $version)]($style) "

        [kotlin]

        symbol = ""

        style = "bold pink"

        format = "[$symbol( $version)]($style) "

        [haskell]

        symbol = ""

        style = "bold purple"

        format = "[$symbol( $version)]($style) "

        [python]

        symbol = ""

        style = "bold yellow"

        format = "[$symbol( $version)]($style) "

        [docker_context]

        symbol = ""

        style = "bold cyan"

        format = "[$symbol( $context)]($style) "

        [time]

        disabled = true

        time_format = "%R"

        style = "bold muted"

        format = "[󰥔 $time]($style) "

        [cmd_duration]

        min_time = 1000

        style = "bold muted"

        format = "󰔟 [$duration]($style) "

        [character]

        success_symbol = "[➜](bold purple)"

        error_symbol = "[➜](bold red)"

        vimcmd_symbol = "[➜](bold cyan)"

        vimcmd_replace_one_symbol = "[➜](bold pink)"

        vimcmd_replace_symbol = "[➜](bold pink)"

        vimcmd_visual_symbol = "[➜](bold purple)"
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

  generatedStarshipFiles = lib.mapAttrs' (
    themeId: file: lib.nameValuePair "aurora/themes/${themeId}.starship.toml" file
  ) starshipThemeFiles;

in

{
  home.packages = [
    iconPackage
  ];

  gtk = {
    enable = true;

    iconTheme = {
      package = iconPackage;
      name = iconThemeName;
    };
  };

  stylix.targets.gtk.enable = false;
  stylix.targets.qt.enable = false;
  stylix.targets.fontconfig.enable = true;

  xdg.configFile = {
    "aurora/themes.json".text = builtins.toJSON themeData;
    "aurora/themes.list".text = themeList + "\n";
  }

  // generatedLuaFiles
  // generatedJsonFiles
  // generatedKittyFiles
  // generatedStarshipFiles
  // generatedGtk3Files
  // generatedGtk4Files
  // generatedKvantumConfigFiles
  // generatedKvantumSvgFiles;

  home.activation.initializeAuroraTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    theme_dir="$HOME/.config/aurora"
    theme_file="$theme_dir/active-theme"
    active_lua="$theme_dir/active-theme.lua"
    active_kitty="$theme_dir/active-kitty.conf"
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

    if [[ -f "$theme_dir/themes/$selected.starship.toml" ]]; then
      ln -sfn \
        "$theme_dir/themes/$selected.starship.toml" \
        "$active_starship"
    else
      ln -sfn \
        "$theme_dir/themes/catppuccin-mocha.starship.toml" \
        "$active_starship"
    fi

    gtk3_dir="$HOME/.config/gtk-3.0"
    gtk4_dir="$HOME/.config/gtk-4.0"
    kvantum_dir="$HOME/.config/Kvantum"
    kvantum_theme="$kvantum_dir/Base16Kvantum"

    mkdir -p "$gtk3_dir" "$gtk4_dir" "$kvantum_dir"

    ln -sfn "$theme_dir/themes/$selected/gtk-3.0/gtk.css" "$gtk3_dir/gtk.css"
    ln -sfn "$theme_dir/themes/$selected/gtk-4.0/gtk.css" "$gtk4_dir/gtk.css"

    if [[ -L "$kvantum_theme" || -e "$kvantum_theme" ]]; then
    rm -rf "$kvantum_theme"
    fi

    ln -s \
    "$theme_dir/themes/$selected/kvantum" \
    "$kvantum_theme"
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
      ACTIVE_STARSHIP="$CONFIG_DIR/active-starship.toml"
      THEME_DIR="$CONFIG_DIR/themes"
      GTK3_DIR="$HOME/.config/gtk-3.0"
      GTK4_DIR="$HOME/.config/gtk-4.0"
      KVANTUM_DIR="$HOME/.config/Kvantum"
      KVANTUM_THEME="$KVANTUM_DIR/Base16Kvantum"

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
        ln -sfn "$theme_starship" "$ACTIVE_STARSHIP"

        # GTK
        mkdir -p "$GTK3_DIR" "$GTK4_DIR"

        ln -sfn "$THEME_DIR/$selected/gtk-3.0/gtk.css" \
        "$GTK3_DIR/gtk.css"

        ln -sfn "$THEME_DIR/$selected/gtk-4.0/gtk.css" \
        "$GTK4_DIR/gtk.css"


        # Kvantum
        mkdir -p "$KVANTUM_DIR"

        if [[ -L "$KVANTUM_THEME" || -e "$KVANTUM_THEME" ]]; then
        rm -rf "$KVANTUM_THEME"
        fi

        ln -s \
        "$THEME_DIR/$selected/kvantum" \
        "$KVANTUM_THEME"

        mkdir -p "$KVANTUM_DIR"

        if [[ -L "$KVANTUM_THEME" || -e "$KVANTUM_THEME" ]]; then
        rm -rf "$KVANTUM_THEME"
        fi

        ln -s "$THEME_DIR/$selected/kvantum" "$KVANTUM_THEME"

        # Kvantum
        kvantum_config="$KVANTUM_DIR/kvantum.kvconfig"
        printf '%s\n' \
        '[General]' \
        'theme=Base16Kvantum' \
        > "$kvantum_config"

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
