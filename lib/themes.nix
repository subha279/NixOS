{
  # GLOBAL AURORA SETTINGS

  global = {

    # Active Theme
    activeTheme = "aurora";

    # Fonts

    fonts = {

      # Main UI font.
      interface = {
        name = "Inter";
        package = "inter";
      };

      # Monospace / terminal font.
      terminal = {
        name = "JetBrains Mono Nerd Font";
        package = "nerd-fonts.jetbrains-mono";
      };

      # Emoji fallback.
      emoji = {
        name = "Noto Color Emoji";
        package = "noto-fonts-color-emoji";
      };

    };

    # Icons

    icons = {
      name = "Colloid-Dark";
      package = "colloid-icon-theme";
    };

    # Cursor

    cursor = {
      name = "phinger-cursors-dark";
      package = "phinger-cursors";
      size = 30;
    };

    # UI

    ui = {

      # Window border.
      borderWidth = 0;

      # Global corner radius.
      radius = 10;

      # Small UI radius.
      radiusSmall = 6;

      # Large popup / window radius.
      radiusLarge = 18;

      # Default icon size.
      iconSize = 16;

      # Global font sizes.
      fontSize = 13;
      fontSizeSmall = 10;
      fontSizeLarge = 15;

      # Quickshell glass panel opacity (bar + popups).
      glassOpacity = 0.80;

      # Shadow strength.
      shadowOpacity = 0.0;

      # Default application/window opacity.
      windowOpacity = 0.96;

      clock = {
        hour = "foreground";
        separator = "foregroundMuted";
        minute = "accent";
        second = "foregroundFaint";
      };

    };

  };

  # THEMES

  themes = {

    # AURORA  (custom)

    aurora = {

      name = "Aurora";

      description = "Charcoal and lavender";

      colors = {

        # Background

        background = "#181D25";
        backgroundDark = "#141920";

        # Surfaces

        surface = "#282E37";
        surfaceHover = "#303743";
        surfaceActive = "#363D49";

        # Borders

        border = "#4A5464";
        borderFocus = "#A970FF";
        separator = "#3E4755";

        # Text

        text = "#F2F3F7";
        textSecondary = "#B9BEC8";
        textMuted = "#8F96A2";

        # Accent

        accent = "#A970FF";
        accentHover = "#B98AFF";
        accentActive = "#C7A6FF";
        accentMuted = "#55406F";
        accentForeground = "#181D25";

        # Semantic States

        success = "#8FE3A5";
        warning = "#FFD479";
        error = "#FF7F96";
        info = "#8FB8FF";

        # Terminal ANSI

        terminalBlack = "#4C5767";
        terminalRed = "#FF7F96";
        terminalGreen = "#8FE3A5";
        terminalYellow = "#FFD479";
        terminalBlue = "#8FB8FF";
        terminalMagenta = "#B98AFF";
        terminalCyan = "#7DE8F0";
        terminalWhite = "#F2F3F7";

        terminalBrightBlack = "#858D9A";
        terminalBrightRed = "#FF9CAF";
        terminalBrightGreen = "#A5F2B8";
        terminalBrightYellow = "#FFE39A";
        terminalBrightBlue = "#A9C7FF";
        terminalBrightMagenta = "#C7A6FF";
        terminalBrightCyan = "#A6F2F7";
        terminalBrightWhite = "#FFFFFF";

      };

    };

    # GRUVBOX  (dark, medium contrast)

    gruvbox = {

      name = "Gruvbox";

      description = "Warm earthy tones";

      colors = {

        # Background

        background = "#282828"; # bg0
        backgroundDark = "#1D2021"; # bg0_hard

        # Surfaces

        surface = "#3C3836"; # bg1
        surfaceHover = "#504945"; # bg2
        surfaceActive = "#665C54"; # bg3

        # Borders

        border = "#635A55";
        borderFocus = "#D79921";
        separator = "#554F4D";

        # Text

        text = "#EBDBB2"; # fg1
        textSecondary = "#D5C4A1"; # fg2
        textMuted = "#ADA196"; # gray

        # Accent

        accent = "#D79921"; # yellow
        accentHover = "#FABD2F"; # bright yellow
        accentActive = "#FE8019"; # bright orange
        accentMuted = "#665C54";
        accentForeground = "#282828";

        # Semantic States

        success = "#B8BB26";
        warning = "#FABD2F";
        error = "#FB4934";
        info = "#83A598";

        # Terminal ANSI

        terminalBlack = "#665D58";
        terminalRed = "#CC241D";
        terminalGreen = "#98971A";
        terminalYellow = "#D79921";
        terminalBlue = "#458588";
        terminalMagenta = "#B16286";
        terminalCyan = "#689D6A";
        terminalWhite = "#A89984";

        terminalBrightBlack = "#928374";
        terminalBrightRed = "#FB4934";
        terminalBrightGreen = "#B8BB26";
        terminalBrightYellow = "#FABD2F";
        terminalBrightBlue = "#83A598";
        terminalBrightMagenta = "#D3869B";
        terminalBrightCyan = "#8EC07C";
        terminalBrightWhite = "#EBDBB2";

      };

    };

    # TOKYO NIGHT  (night)

    tokyo-night = {

      name = "Tokyo Night";

      description = "Deep blue and violet";

      colors = {

        # Background

        background = "#1A1B26";
        backgroundDark = "#16161E";

        # Surfaces

        surface = "#24283B";
        surfaceHover = "#292E42"; # bg_highlight
        surfaceActive = "#3B4261"; # fg_gutter

        # Borders

        border = "#485177";
        borderFocus = "#7AA2F7";
        separator = "#3A415D";

        # Text

        text = "#C0CAF5";
        textSecondary = "#A9B1D6";
        textMuted = "#888FB4"; # comment

        # Accent

        accent = "#7AA2F7";
        accentHover = "#8DB0FF";
        accentActive = "#BB9AF7";
        accentMuted = "#414868";
        accentForeground = "#1A1B26";

        # Semantic States

        success = "#9ECE6A";
        warning = "#E0AF68";
        error = "#F7768E";
        info = "#7DCFFF";

        # Terminal ANSI

        terminalBlack = "#4A537A";
        terminalRed = "#F7768E";
        terminalGreen = "#9ECE6A";
        terminalYellow = "#E0AF68";
        terminalBlue = "#7AA2F7";
        terminalMagenta = "#BB9AF7";
        terminalCyan = "#7DCFFF";
        terminalWhite = "#A9B1D6";

        terminalBrightBlack = "#414868";
        terminalBrightRed = "#FF899D";
        terminalBrightGreen = "#9FE044";
        terminalBrightYellow = "#FABA4A";
        terminalBrightBlue = "#8DB0FF";
        terminalBrightMagenta = "#C7A9FF";
        terminalBrightCyan = "#A4DAFF";
        terminalBrightWhite = "#C0CAF5";

      };

    };

    # MONOCHROME  (custom)

    monochrome = {

      name = "Monochrome";

      description = "Pure black and white";

      colors = {

        # Background

        background = "#0A0A0A";
        backgroundDark = "#000000";

        # Surfaces

        surface = "#151515";
        surfaceHover = "#202020";
        surfaceActive = "#2A2A2A";

        # Borders

        border = "#494949";
        borderFocus = "#FFFFFF";
        separator = "#303030";

        # Text

        text = "#F5F5F5";
        textSecondary = "#B8B8B8";
        textMuted = "#808080";

        # Accent

        accent = "#FFFFFF";
        accentHover = "#E5E5E5";
        accentActive = "#FFFFFF";
        accentMuted = "#505050";
        accentForeground = "#000000";

        # Semantic States

        success = "#C0C0C0";
        warning = "#D0D0D0";
        error = "#A8A8A8";
        info = "#B8B8B8";

        # Terminal ANSI

        terminalBlack = "#4C4C4C";
        terminalRed = "#A8A8A8";
        terminalGreen = "#B8B8B8";
        terminalYellow = "#C8C8C8";
        terminalBlue = "#A0A0A0";
        terminalMagenta = "#B0B0B0";
        terminalCyan = "#D0D0D0";
        terminalWhite = "#F5F5F5";

        terminalBrightBlack = "#505050";
        terminalBrightRed = "#C0C0C0";
        terminalBrightGreen = "#D0D0D0";
        terminalBrightYellow = "#D8D8D8";
        terminalBrightBlue = "#B8B8B8";
        terminalBrightMagenta = "#C8C8C8";
        terminalBrightCyan = "#E0E0E0";
        terminalBrightWhite = "#FFFFFF";

      };

    };

    # CATPPUCCIN MOCHA

    catppuccin-mocha = {

      name = "Catppuccin Mocha";

      description = "Soft pastel colors on a dark mocha background";

      colors = {

        background = "#1E1E2E"; # base
        backgroundDark = "#181825"; # mantle

        surface = "#313244"; # surface0
        surfaceHover = "#45475A"; # surface1
        surfaceActive = "#585B70"; # surface2

        border = "#51546A";
        borderFocus = "#CBA6F7";
        separator = "#484964";

        text = "#CDD6F4";
        textSecondary = "#BAC2DE"; # subtext1
        textMuted = "#989CAC"; # overlay0

        accent = "#CBA6F7"; # mauve
        accentHover = "#B4BEFE"; # lavender
        accentActive = "#F5C2E7"; # pink
        accentMuted = "#585B70";
        accentForeground = "#1E1E2E";

        success = "#A6E3A1";
        warning = "#F9E2AF";
        error = "#F38BA8";
        info = "#89B4FA";

        terminalBlack = "#54566D";
        terminalRed = "#F38BA8";
        terminalGreen = "#A6E3A1";
        terminalYellow = "#F9E2AF";
        terminalBlue = "#89B4FA";
        terminalMagenta = "#F5C2E7";
        terminalCyan = "#94E2D5";
        terminalWhite = "#BAC2DE";

        terminalBrightBlack = "#585B70";
        terminalBrightRed = "#F38BA8";
        terminalBrightGreen = "#A6E3A1";
        terminalBrightYellow = "#F9E2AF";
        terminalBrightBlue = "#89B4FA";
        terminalBrightMagenta = "#F5C2E7";
        terminalBrightCyan = "#94E2D5";
        terminalBrightWhite = "#A6ADC8";
      };
    };

    # NORD

    nord = {

      name = "Nord";

      description = "Arctic blue and cool gray";

      colors = {

        background = "#2E3440"; # nord0
        backgroundDark = "#242933";

        surface = "#3B4252"; # nord1
        surfaceHover = "#434C5E"; # nord2
        surfaceActive = "#4C566A"; # nord3

        border = "#5B677F";
        borderFocus = "#88C0D0";
        separator = "#505A6F";

        text = "#ECEFF4"; # nord6
        textSecondary = "#D8DEE9"; # nord4
        textMuted = "#A7B0C0"; # brightened nord3 (comment tone)

        accent = "#88C0D0"; # nord8
        accentHover = "#8FBCBB"; # nord7
        accentActive = "#81A1C1"; # nord9
        accentMuted = "#4C566A";
        accentForeground = "#2E3440";

        success = "#A3BE8C";
        warning = "#EBCB8B";
        error = "#BF616A";
        info = "#81A1C1";

        terminalBlack = "#5E6A83";
        terminalRed = "#BF616A";
        terminalGreen = "#A3BE8C";
        terminalYellow = "#EBCB8B";
        terminalBlue = "#81A1C1";
        terminalMagenta = "#B48EAD";
        terminalCyan = "#88C0D0";
        terminalWhite = "#E5E9F0";

        terminalBrightBlack = "#4C566A";
        terminalBrightRed = "#BF616A";
        terminalBrightGreen = "#A3BE8C";
        terminalBrightYellow = "#EBCB8B";
        terminalBrightBlue = "#81A1C1";
        terminalBrightMagenta = "#B48EAD";
        terminalBrightCyan = "#8FBCBB";
        terminalBrightWhite = "#ECEFF4";
      };
    };

    # DRACULA

    dracula = {

      name = "Dracula";

      description = "Dark purple with vivid neon accents";

      colors = {

        background = "#282A36";
        backgroundDark = "#21222C";

        surface = "#343746";
        surfaceHover = "#44475A"; # current line / selection
        surfaceActive = "#6272A4"; # comment

        border = "#595D75";
        borderFocus = "#BD93F9";
        separator = "#4B4E63";

        text = "#F8F8F2";
        textSecondary = "#D6D6CE";
        textMuted = "#97A1C3";

        accent = "#BD93F9"; # purple
        accentHover = "#D6ACFF"; # bright purple
        accentActive = "#FF79C6"; # pink
        accentMuted = "#44475A";
        accentForeground = "#282A36";

        success = "#50FA7B";
        warning = "#F1FA8C";
        error = "#FF5555";
        info = "#8BE9FD";

        terminalBlack = "#5C6079";
        terminalRed = "#FF5555";
        terminalGreen = "#50FA7B";
        terminalYellow = "#F1FA8C";
        terminalBlue = "#BD93F9";
        terminalMagenta = "#FF79C6";
        terminalCyan = "#8BE9FD";
        terminalWhite = "#F8F8F2";

        terminalBrightBlack = "#6272A4";
        terminalBrightRed = "#FF6E6E";
        terminalBrightGreen = "#69FF94";
        terminalBrightYellow = "#FFFFA5";
        terminalBrightBlue = "#D6ACFF";
        terminalBrightMagenta = "#FF92DF";
        terminalBrightCyan = "#A4FFFF";
        terminalBrightWhite = "#FFFFFF";
      };
    };

    # ONE DARK

    one-dark = {

      name = "One Dark";

      description = "Classic Atom-inspired developer theme";

      colors = {

        background = "#282C34";
        backgroundDark = "#21252B";

        surface = "#31353F";
        surfaceHover = "#393F4A";
        surfaceActive = "#4B5263";

        border = "#575F72";
        borderFocus = "#61AFEF";
        separator = "#464D5B";

        text = "#ABB2BF";
        textSecondary = "#9DA5B4";
        textMuted = "#989FAB"; # comment grey

        accent = "#61AFEF"; # blue
        accentHover = "#56B6C2"; # cyan
        accentActive = "#C678DD"; # purple
        accentMuted = "#3E4451";
        accentForeground = "#282C34";

        success = "#98C379";
        warning = "#E5C07B";
        error = "#E06C75";
        info = "#61AFEF";

        terminalBlack = "#5A6275";
        terminalRed = "#E06C75";
        terminalGreen = "#98C379";
        terminalYellow = "#E5C07B";
        terminalBlue = "#61AFEF";
        terminalMagenta = "#C678DD";
        terminalCyan = "#56B6C2";
        terminalWhite = "#ABB2BF";

        terminalBrightBlack = "#5C6370";
        terminalBrightRed = "#E06C75";
        terminalBrightGreen = "#98C379";
        terminalBrightYellow = "#D19A66"; # orange
        terminalBrightBlue = "#61AFEF";
        terminalBrightMagenta = "#C678DD";
        terminalBrightCyan = "#56B6C2";
        terminalBrightWhite = "#FFFFFF";
      };
    };

    # EVERFOREST  (dark, medium contrast)

    everforest = {

      name = "Everforest";

      description = "Calm green and earthy forest tones";

      colors = {

        background = "#2D353B"; # bg0
        backgroundDark = "#232A2E"; # bg_dim

        surface = "#343F44"; # bg1
        surfaceHover = "#3D484D"; # bg2
        surfaceActive = "#475258"; # bg3

        border = "#5B6971";
        borderFocus = "#A7C080";
        separator = "#4A575D";

        text = "#D3C6AA"; # fg
        textSecondary = "#9DA9A0"; # grey2
        textMuted = "#A2ABA5"; # grey1

        accent = "#A7C080"; # green
        accentHover = "#83C092"; # aqua
        accentActive = "#D699B6"; # purple
        accentMuted = "#475258";
        accentForeground = "#2D353B";

        success = "#A7C080";
        warning = "#DBBC7F";
        error = "#E67E80";
        info = "#7FBBB3";

        # Everforest's bright slots mirror the normal ones; the previous
        # bright values (#F85552, #8DA101, ...) were the LIGHT palette.
        terminalBlack = "#5E6C74";
        terminalRed = "#E67E80";
        terminalGreen = "#A7C080";
        terminalYellow = "#DBBC7F";
        terminalBlue = "#7FBBB3";
        terminalMagenta = "#D699B6";
        terminalCyan = "#83C092";
        terminalWhite = "#9DA9A0";

        terminalBrightBlack = "#859289";
        terminalBrightRed = "#E67E80";
        terminalBrightGreen = "#A7C080";
        terminalBrightYellow = "#DBBC7F";
        terminalBrightBlue = "#7FBBB3";
        terminalBrightMagenta = "#D699B6";
        terminalBrightCyan = "#83C092";
        terminalBrightWhite = "#D3C6AA";
      };
    };

    # ROSÉ PINE  (main)

    rose-pine = {

      name = "Rosé Pine";

      description = "Elegant muted rose and pine colors";

      colors = {

        background = "#191724"; # base
        backgroundDark = "#13111C";

        surface = "#1F1D2E"; # surface
        surfaceHover = "#26233A"; # overlay
        surfaceActive = "#403D52"; # highlight med

        border = "#514D68";
        borderFocus = "#C4A7E7";
        separator = "#393850"; # highlight low

        text = "#E0DEF4";
        textSecondary = "#908CAA"; # subtle
        textMuted = "#88849E"; # muted

        accent = "#C4A7E7"; # iris
        accentHover = "#D5BFF2";
        accentActive = "#EBBCBA"; # rose
        accentMuted = "#403D52";
        accentForeground = "#191724";

        success = "#9CCFD8"; # foam
        warning = "#F6C177"; # gold
        error = "#EB6F92"; # love
        info = "#31748F"; # pine

        # Upstream maps green -> pine, blue -> foam, cyan -> rose.
        terminalBlack = "#54506B";
        terminalRed = "#EB6F92";
        terminalGreen = "#31748F";
        terminalYellow = "#F6C177";
        terminalBlue = "#9CCFD8";
        terminalMagenta = "#C4A7E7";
        terminalCyan = "#EBBCBA";
        terminalWhite = "#E0DEF4";

        terminalBrightBlack = "#6E6A86";
        terminalBrightRed = "#EB6F92";
        terminalBrightGreen = "#31748F";
        terminalBrightYellow = "#F6C177";
        terminalBrightBlue = "#9CCFD8";
        terminalBrightMagenta = "#C4A7E7";
        terminalBrightCyan = "#EBBCBA";
        terminalBrightWhite = "#E0DEF4";
      };
    };

    # ROSÉ PINE MOON

    rose-pine-moon = {

      name = "Rosé Pine Moon";

      description = "Softer, warmer Rosé Pine variant";

      colors = {

        background = "#232136"; # base
        backgroundDark = "#1F1D30";

        surface = "#2A273F"; # surface
        surfaceHover = "#393552"; # overlay
        surfaceActive = "#44415A"; # highlight med

        border = "#585475";
        borderFocus = "#C4A7E7";
        separator = "#423F62"; # highlight low

        text = "#E0DEF4";
        textSecondary = "#908CAA";
        textMuted = "#938FA7";

        accent = "#C4A7E7"; # iris
        accentHover = "#D5BFF2";
        accentActive = "#EA9A97"; # rose
        accentMuted = "#44415A";
        accentForeground = "#232136";

        success = "#9CCFD8"; # foam
        warning = "#F6C177"; # gold
        error = "#EB6F92"; # love
        info = "#3E8FB0"; # pine

        terminalBlack = "#5B5779";
        terminalRed = "#EB6F92";
        terminalGreen = "#3E8FB0";
        terminalYellow = "#F6C177";
        terminalBlue = "#9CCFD8";
        terminalMagenta = "#C4A7E7";
        terminalCyan = "#EA9A97";
        terminalWhite = "#E0DEF4";

        terminalBrightBlack = "#6E6A86";
        terminalBrightRed = "#EB6F92";
        terminalBrightGreen = "#3E8FB0";
        terminalBrightYellow = "#F6C177";
        terminalBrightBlue = "#9CCFD8";
        terminalBrightMagenta = "#C4A7E7";
        terminalBrightCyan = "#EA9A97";
        terminalBrightWhite = "#E0DEF4";
      };
    };

    # CATPPUCCIN MACCHIATO

    catppuccin-macchiato = {

      name = "Catppuccin Macchiato";

      description = "Medium-dark pastel Catppuccin flavor";

      colors = {

        background = "#24273A"; # base
        backgroundDark = "#1E2030"; # mantle

        surface = "#363A4F"; # surface0
        surfaceHover = "#494D64"; # surface1
        surfaceActive = "#5B6078"; # surface2

        border = "#565B76";
        borderFocus = "#C6A0F6";
        separator = "#4C516F";

        text = "#CAD3F5";
        textSecondary = "#B8C0E0"; # subtext1
        textMuted = "#A2A5B7"; # overlay0

        accent = "#C6A0F6"; # mauve
        accentHover = "#B7BDF8"; # lavender
        accentActive = "#F5BDE6"; # pink
        accentMuted = "#5B6078";
        accentForeground = "#24273A";

        success = "#A6DA95";
        warning = "#EED49F";
        error = "#ED8796";
        info = "#8AADF4";

        terminalBlack = "#595E79";
        terminalRed = "#ED8796";
        terminalGreen = "#A6DA95";
        terminalYellow = "#EED49F";
        terminalBlue = "#8AADF4";
        terminalMagenta = "#F5BDE6";
        terminalCyan = "#8BD5CA";
        terminalWhite = "#B8C0E0";

        terminalBrightBlack = "#5B6078";
        terminalBrightRed = "#ED8796";
        terminalBrightGreen = "#A6DA95";
        terminalBrightYellow = "#EED49F";
        terminalBrightBlue = "#8AADF4";
        terminalBrightMagenta = "#F5BDE6";
        terminalBrightCyan = "#8BD5CA";
        terminalBrightWhite = "#A5ADCB";
      };
    };

    # CATPPUCCIN FRAPPÉ

    catppuccin-frappe = {

      name = "Catppuccin Frappé";

      description = "Warm, low-contrast pastel Catppuccin flavor";

      colors = {

        background = "#303446"; # base
        backgroundDark = "#292C3C"; # mantle

        surface = "#414559"; # surface0
        surfaceHover = "#51576D"; # surface1
        surfaceActive = "#626880"; # surface2

        border = "#606781";
        borderFocus = "#CA9EE6";
        separator = "#575C77";

        text = "#C6D0F5";
        textSecondary = "#B5BFE2"; # subtext1
        textMuted = "#B1B4C3"; # overlay0

        accent = "#CA9EE6"; # mauve
        accentHover = "#BABBF1"; # lavender
        accentActive = "#F4B8E4"; # pink
        accentMuted = "#626880";
        accentForeground = "#303446";

        success = "#A6D189";
        warning = "#E5C890";
        error = "#E78284";
        info = "#8CAAEE";

        terminalBlack = "#626A85";
        terminalRed = "#E78284";
        terminalGreen = "#A6D189";
        terminalYellow = "#E5C890";
        terminalBlue = "#8CAAEE";
        terminalMagenta = "#F4B8E4";
        terminalCyan = "#81C8BE";
        terminalWhite = "#B5BFE2";

        terminalBrightBlack = "#626880";
        terminalBrightRed = "#E78284";
        terminalBrightGreen = "#A6D189";
        terminalBrightYellow = "#E5C890";
        terminalBrightBlue = "#8CAAEE";
        terminalBrightMagenta = "#F4B8E4";
        terminalBrightCyan = "#81C8BE";
        terminalBrightWhite = "#A5ADCE";
      };
    };

    # CATPPUCCIN LATTE  (light)

    catppuccin-latte = {

      name = "Catppuccin Latte";

      description = "Light pastel Catppuccin flavor";

      colors = {

        background = "#EFF1F5"; # base
        backgroundDark = "#E6E9EF"; # mantle

        surface = "#CCD0DA"; # surface0
        surfaceHover = "#BCC0CC"; # surface1
        surfaceActive = "#ACB0BE"; # surface2

        border = "#9EA4B5";
        borderFocus = "#8839EF";
        separator = "#A6ADBF";

        text = "#4C4F69";
        textSecondary = "#5C5F77"; # subtext1
        textMuted = "#555768"; # overlay1

        accent = "#8839EF"; # mauve
        accentHover = "#7287FD"; # lavender
        accentActive = "#EA76CB"; # pink
        accentMuted = "#ACB0BE";
        accentForeground = "#EFF1F5";

        success = "#40A02B";
        warning = "#DF8E1D";
        error = "#D20F39";
        info = "#1E66F5";

        terminalBlack = "#5C5F77";
        terminalRed = "#D20F39";
        terminalGreen = "#40A02B";
        terminalYellow = "#DF8E1D";
        terminalBlue = "#1E66F5";
        terminalMagenta = "#EA76CB";
        terminalCyan = "#179299";
        terminalWhite = "#ACB0BE";

        terminalBrightBlack = "#6C6F85";
        terminalBrightRed = "#D20F39";
        terminalBrightGreen = "#40A02B";
        terminalBrightYellow = "#DF8E1D";
        terminalBrightBlue = "#1E66F5";
        terminalBrightMagenta = "#EA76CB";
        terminalBrightCyan = "#179299";
        terminalBrightWhite = "#BCC0CC";
      };
    };

    # TOKYO NIGHT STORM

    tokyo-night-storm = {

      name = "Tokyo Night Storm";

      description = "Lighter, bluer Tokyo Night variant";

      colors = {

        background = "#24283B";
        backgroundDark = "#1F2335";

        surface = "#292E42";
        surfaceHover = "#3B4261";
        surfaceActive = "#414868";

        border = "#515B85";
        borderFocus = "#7AA2F7";
        separator = "#3E4664";

        text = "#C0CAF5";
        textSecondary = "#A9B1D6";
        textMuted = "#8E96B8";

        accent = "#7AA2F7";
        accentHover = "#8DB0FF";
        accentActive = "#BB9AF7";
        accentMuted = "#414868";
        accentForeground = "#24283B";

        success = "#9ECE6A";
        warning = "#E0AF68";
        error = "#F7768E";
        info = "#7DCFFF";

        terminalBlack = "#545D89";
        terminalRed = "#F7768E";
        terminalGreen = "#9ECE6A";
        terminalYellow = "#E0AF68";
        terminalBlue = "#7AA2F7";
        terminalMagenta = "#BB9AF7";
        terminalCyan = "#7DCFFF";
        terminalWhite = "#A9B1D6";

        terminalBrightBlack = "#414868";
        terminalBrightRed = "#FF899D";
        terminalBrightGreen = "#9FE044";
        terminalBrightYellow = "#FABA4A";
        terminalBrightBlue = "#8DB0FF";
        terminalBrightMagenta = "#C7A9FF";
        terminalBrightCyan = "#A4DAFF";
        terminalBrightWhite = "#C0CAF5";
      };
    };

    # GRUVBOX LIGHT  (light, medium contrast)

    gruvbox-light = {

      name = "Gruvbox Light";

      description = "Warm cream paper with faded ink accents";

      colors = {

        background = "#FBF1C7"; # bg0
        backgroundDark = "#F2E5BC"; # bg0_soft

        surface = "#EBDBB2"; # bg1
        surfaceHover = "#D5C4A1"; # bg2
        surfaceActive = "#BDAE93"; # bg3

        border = "#B3A283";
        borderFocus = "#B57614";
        separator = "#D6B45F";

        text = "#3C3836"; # fg1
        textSecondary = "#504945"; # fg2
        textMuted = "#695E54"; # fg4

        accent = "#B57614"; # faded yellow
        accentHover = "#D79921"; # yellow
        accentActive = "#AF3A03"; # faded orange
        accentMuted = "#BDAE93";
        accentForeground = "#FBF1C7";

        success = "#79740E";
        warning = "#B57614";
        error = "#9D0006";
        info = "#076678";

        terminalBlack = "#B09E7E";
        terminalRed = "#CC241D";
        terminalGreen = "#98971A";
        terminalYellow = "#D79921";
        terminalBlue = "#458588";
        terminalMagenta = "#B16286";
        terminalCyan = "#689D6A";
        terminalWhite = "#7C6F64";

        terminalBrightBlack = "#928374";
        terminalBrightRed = "#9D0006";
        terminalBrightGreen = "#79740E";
        terminalBrightYellow = "#B57614";
        terminalBrightBlue = "#076678";
        terminalBrightMagenta = "#8F3F71";
        terminalBrightCyan = "#427B58";
        terminalBrightWhite = "#3C3836";
      };
    };

    # SOLARIZED DARK

    solarized-dark = {

      name = "Solarized Dark";

      description = "Precision teal base with sixteen fixed accents";

      colors = {

        background = "#002B36"; # base03
        backgroundDark = "#00212B";

        surface = "#073642"; # base02
        surfaceHover = "#0E4A56";
        surfaceActive = "#145E6C";

        border = "#146373";
        borderFocus = "#268BD2";
        separator = "#0A5062";

        text = "#93A1A1"; # base1
        textSecondary = "#839496"; # base0
        textMuted = "#899DA4"; # base00

        accent = "#268BD2"; # blue
        accentHover = "#2AA198"; # cyan
        accentActive = "#6C71C4"; # violet
        accentMuted = "#586E75"; # base01
        accentForeground = "#002B36";

        success = "#859900";
        warning = "#B58900";
        error = "#DC322F";
        info = "#268BD2";

        # Solarized's official ANSI mapping deliberately reuses the base greys for bright green/yellow/blue/cyan.
        terminalBlack = "#146677";
        terminalRed = "#DC322F";
        terminalGreen = "#859900";
        terminalYellow = "#B58900";
        terminalBlue = "#268BD2";
        terminalMagenta = "#D33682";
        terminalCyan = "#2AA198";
        terminalWhite = "#EEE8D5";

        terminalBrightBlack = "#002B36";
        terminalBrightRed = "#CB4B16";
        terminalBrightGreen = "#586E75";
        terminalBrightYellow = "#657B83";
        terminalBrightBlue = "#839496";
        terminalBrightMagenta = "#6C71C4";
        terminalBrightCyan = "#93A1A1";
        terminalBrightWhite = "#FDF6E3";
      };
    };

    # SOLARIZED LIGHT  (light)

    solarized-light = {

      name = "Solarized Light";

      description = "Warm parchment base with the same fixed accents";

      colors = {

        background = "#FDF6E3"; # base3
        backgroundDark = "#EEE8D5"; # base2

        surface = "#EEE8D5";
        surfaceHover = "#E4DDC8";
        surfaceActive = "#D9D2BD";

        border = "#93A1A1"; # base1
        borderFocus = "#268BD2";
        separator = "#D2C28F";

        text = "#586E75"; # base01
        textSecondary = "#657B83"; # base00
        textMuted = "#5B6A6C"; # base0

        accent = "#268BD2"; # blue
        accentHover = "#2AA198"; # cyan
        accentActive = "#6C71C4"; # violet
        accentMuted = "#93A1A1";
        accentForeground = "#FDF6E3";

        success = "#859900";
        warning = "#B58900";
        error = "#DC322F";
        info = "#268BD2";

        # Light mode mirrors the dark ANSI palette (black <-> white ends).
        terminalBlack = "#9AA7A7";
        terminalRed = "#DC322F";
        terminalGreen = "#859900";
        terminalYellow = "#B58900";
        terminalBlue = "#268BD2";
        terminalMagenta = "#D33682";
        terminalCyan = "#2AA198";
        terminalWhite = "#073642";

        terminalBrightBlack = "#FDF6E3";
        terminalBrightRed = "#CB4B16";
        terminalBrightGreen = "#93A1A1";
        terminalBrightYellow = "#839496";
        terminalBrightBlue = "#657B83";
        terminalBrightMagenta = "#6C71C4";
        terminalBrightCyan = "#586E75";
        terminalBrightWhite = "#002B36";
      };
    };

    # KANAGAWA  (wave)

    kanagawa = {

      name = "Kanagawa";

      description = "Inky sumi background with woodblock print accents";

      colors = {

        background = "#1F1F28"; # sumiInk3
        backgroundDark = "#16161D"; # sumiInk0

        surface = "#2A2A37"; # sumiInk4
        surfaceHover = "#363646"; # sumiInk5
        surfaceActive = "#54546D"; # sumiInk6

        border = "#54546D";
        borderFocus = "#7E9CD8"; # crystalBlue
        separator = "#424257";

        text = "#DCD7BA"; # fujiWhite
        textSecondary = "#C8C093"; # oldWhite
        textMuted = "#94938B"; # fujiGray

        accent = "#7E9CD8"; # crystalBlue
        accentHover = "#7FB4CA"; # springBlue
        accentActive = "#957FB8"; # oniViolet
        accentMuted = "#2D4F67"; # waveBlue2
        accentForeground = "#1F1F28";

        success = "#98BB6C"; # springGreen
        warning = "#E6C384"; # carpYellow
        error = "#E82424"; # samuraiRed
        info = "#7FB4CA"; # springBlue

        terminalBlack = "#56566F";
        terminalRed = "#C34043";
        terminalGreen = "#76946A";
        terminalYellow = "#C0A36E";
        terminalBlue = "#7E9CD8";
        terminalMagenta = "#957FB8";
        terminalCyan = "#6A9589";
        terminalWhite = "#C8C093";

        terminalBrightBlack = "#727169";
        terminalBrightRed = "#E82424";
        terminalBrightGreen = "#98BB6C";
        terminalBrightYellow = "#E6C384";
        terminalBrightBlue = "#7FB4CA";
        terminalBrightMagenta = "#938AA9";
        terminalBrightCyan = "#7AA89F";
        terminalBrightWhite = "#DCD7BA";
      };
    };

    # GITHUB DARK  (default)

    github-dark = {

      name = "GitHub Dark";

      description = "GitHub's default dark interface palette";

      colors = {

        background = "#0D1117"; # canvas.default
        backgroundDark = "#010409"; # canvas.inset

        surface = "#161B22"; # canvas.overlay
        surfaceHover = "#21262D";
        surfaceActive = "#30363D";

        border = "#444D56";
        borderFocus = "#58A6FF";
        separator = "#303742";

        text = "#E6EDF3"; # fg.default
        textSecondary = "#C9D1D9";
        textMuted = "#8B949E"; # fg.muted

        accent = "#58A6FF";
        accentHover = "#79C0FF";
        accentActive = "#A5D6FF";
        accentMuted = "#1F6FEB";
        accentForeground = "#0D1117";

        success = "#3FB950";
        warning = "#D29922";
        error = "#F85149";
        info = "#58A6FF";

        terminalBlack = "#484F58";
        terminalRed = "#FF7B72";
        terminalGreen = "#3FB950";
        terminalYellow = "#D29922";
        terminalBlue = "#58A6FF";
        terminalMagenta = "#BC8CFF";
        terminalCyan = "#39C5CF";
        terminalWhite = "#B1BAC4";

        terminalBrightBlack = "#6E7681";
        terminalBrightRed = "#FFA198";
        terminalBrightGreen = "#56D364";
        terminalBrightYellow = "#E3B341";
        terminalBrightBlue = "#79C0FF";
        terminalBrightMagenta = "#D2A8FF";
        terminalBrightCyan = "#56D4DD";
        terminalBrightWhite = "#F0F6FC";
      };
    };

    # MONOKAI PRO  (default filter)

    monokai-pro = {

      name = "Monokai Pro";

      description = "Muted plum background with candy syntax accents";

      colors = {

        background = "#2D2A2E";
        backgroundDark = "#221F22";

        surface = "#403E41"; # dimmed5
        surfaceHover = "#49474A";
        surfaceActive = "#5B595C"; # dimmed4

        border = "#5B595C";
        borderFocus = "#FFD866";
        separator = "#58555A";

        text = "#FCFCFA";
        textSecondary = "#C1C0C0"; # dimmed1
        textMuted = "#ABABAB"; # dimmed2

        accent = "#FFD866"; # yellow
        accentHover = "#FC9867"; # orange
        accentActive = "#FF6188"; # red
        accentMuted = "#5B595C";
        accentForeground = "#2D2A2E";

        success = "#A9DC76";
        warning = "#FFD866";
        error = "#FF6188";
        info = "#78DCE8";

        # Monokai has no blue, so upstream maps the blue slot to orange.
        terminalBlack = "#636164";
        terminalRed = "#FF6188";
        terminalGreen = "#A9DC76";
        terminalYellow = "#FFD866";
        terminalBlue = "#FC9867";
        terminalMagenta = "#AB9DF2";
        terminalCyan = "#78DCE8";
        terminalWhite = "#FCFCFA";

        terminalBrightBlack = "#727072";
        terminalBrightRed = "#FF6188";
        terminalBrightGreen = "#A9DC76";
        terminalBrightYellow = "#FFD866";
        terminalBrightBlue = "#FC9867";
        terminalBrightMagenta = "#AB9DF2";
        terminalBrightCyan = "#78DCE8";
        terminalBrightWhite = "#FCFCFA";
      };
    };

  };

}
