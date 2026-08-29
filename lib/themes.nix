{
  global = {

    # Active theme

    activeTheme = "catppuccin-mocha";

    # Fonts

    fonts = {
      interface = {
        name = "Inter";
        package = "inter";
      };

      terminal = {
        name = "JetBrainsMono Nerd Font Mono";
        package = "nerd-fonts.jetbrains-mono";
      };

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

      borderWidth = 0;

      radius = 15;
      radiusSmall = 10;
      radiusLarge = 18;

      iconSize = 16;

      fontSize = 12;
      fontSizeSmall = 10;
      fontSizeLarge = 15;

      # LIQUID GLASS

      glassOpacity = 0.55;
      surfaceOpacity = 0.18;
      glassLuminosity = 0.0;
      glassGradientOpacity = 0.055;

      # SHADOWS / WINDOWS

      shadowOpacity = 0.24;

      windowOpacity = 0.96;

      terminalOpacity = 0.52;

      editorFloatBlend = 12;

      # CLOCK

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

    # ==========================================================
    # CATPPUCCIN MOCHA
    # ==========================================================

    catppuccin-mocha = {

      name = "Catppuccin Mocha";

      description = "Soft pastel dark theme";

      colors = {

        # Base
        background = "#1E1E2E";
        backgroundDark = "#181825";

        # Surfaces
        surface = "#313244";
        surfaceHover = "#45475A";
        surfaceActive = "#585B70";

        # Borders
        border = "#45475A";
        borderFocus = "#CBA6F7";
        separator = "#3B3D52";

        # Text
        text = "#CDD6F4";
        textSecondary = "#BAC2DE";
        textMuted = "#9399B2";

        # Accent
        accent = "#CBA6F7";
        accentHover = "#B4BEFE";
        accentActive = "#F5C2E7";
        accentMuted = "#585B70";
        accentForeground = "#1E1E2E";

        # Semantic
        success = "#A6E3A1";
        warning = "#F9E2AF";
        error = "#F38BA8";
        info = "#89B4FA";

        # ANSI
        terminalBlack = "#45475A";
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
        terminalBrightWhite = "#CDD6F4";
      };
    };

    # ==========================================================
    # TOKYO NIGHT
    # ==========================================================

    tokyo-night = {

      name = "Tokyo Night";

      description = "Deep blue violet night theme";

      colors = {

        # Base
        background = "#1A1B26";
        backgroundDark = "#16161E";

        # Surfaces
        surface = "#24283B";
        surfaceHover = "#292E42";
        surfaceActive = "#3B4261";

        # Borders
        border = "#3B4261";
        borderFocus = "#7AA2F7";
        separator = "#292E42";

        # Text
        text = "#C0CAF5";
        textSecondary = "#A9B1D6";
        textMuted = "#7982A9";

        # Accent
        accent = "#7AA2F7";
        accentHover = "#8DB0FF";
        accentActive = "#BB9AF7";
        accentMuted = "#414868";
        accentForeground = "#1A1B26";

        # Semantic
        success = "#9ECE6A";
        warning = "#E0AF68";
        error = "#F7768E";
        info = "#7DCFFF";

        # ANSI
        terminalBlack = "#414868";
        terminalRed = "#F7768E";
        terminalGreen = "#9ECE6A";
        terminalYellow = "#E0AF68";
        terminalBlue = "#7AA2F7";
        terminalMagenta = "#BB9AF7";
        terminalCyan = "#7DCFFF";
        terminalWhite = "#7982A9";

        terminalBrightBlack = "#565F89";
        terminalBrightRed = "#FF899D";
        terminalBrightGreen = "#9FE044";
        terminalBrightYellow = "#FABA4A";
        terminalBrightBlue = "#8DB0FF";
        terminalBrightMagenta = "#C7A9FF";
        terminalBrightCyan = "#A4DAFF";
        terminalBrightWhite = "#C0CAF5";
      };
    };

    # ==========================================================
    # GRUVBOX DARK
    # ==========================================================

    gruvbox = {

      name = "Gruvbox";

      description = "Warm earthy dark theme";

      colors = {

        # Base
        background = "#282828";
        backgroundDark = "#1D2021";

        # Surfaces
        surface = "#3C3836";
        surfaceHover = "#504945";
        surfaceActive = "#665C54";

        # Borders
        border = "#504945";
        borderFocus = "#D79921";
        separator = "#45403D";

        # Text
        text = "#EBDBB2";
        textSecondary = "#D5C4A1";
        textMuted = "#A89984";

        # Accent
        accent = "#D79921";
        accentHover = "#FABD2F";
        accentActive = "#FE8019";
        accentMuted = "#665C54";
        accentForeground = "#282828";

        # Semantic
        success = "#B8BB26";
        warning = "#FABD2F";
        error = "#FB4934";
        info = "#83A598";

        # ANSI
        terminalBlack = "#282828";
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

    # ==========================================================
    # ONE DARK
    # ==========================================================

    one-dark = {

      name = "One Dark";

      description = "Classic Atom developer theme";

      colors = {

        # Base
        background = "#282C34";
        backgroundDark = "#21252B";

        # Surfaces
        surface = "#31353F";
        surfaceHover = "#393F4A";
        surfaceActive = "#4B5263";

        # Borders
        border = "#3E4451";
        borderFocus = "#61AFEF";
        separator = "#353B45";

        # Text
        text = "#ABB2BF";
        textSecondary = "#9DA5B4";
        textMuted = "#7F848E";

        # Accent
        accent = "#61AFEF";
        accentHover = "#56B6C2";
        accentActive = "#C678DD";
        accentMuted = "#3E4451";
        accentForeground = "#282C34";

        # Semantic
        success = "#98C379";
        warning = "#E5C07B";
        error = "#E06C75";
        info = "#61AFEF";

        # ANSI
        terminalBlack = "#282C34";
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
        terminalBrightYellow = "#E5C07B";
        terminalBrightBlue = "#61AFEF";
        terminalBrightMagenta = "#C678DD";
        terminalBrightCyan = "#56B6C2";
        terminalBrightWhite = "#FFFFFF";
      };
    };

    # ==========================================================
    # EVERFOREST
    # ==========================================================

    everforest = {

      name = "Everforest";

      description = "Calm green earthy dark theme";

      colors = {

        # Base
        background = "#2D353B";
        backgroundDark = "#232A2E";

        # Surfaces
        surface = "#343F44";
        surfaceHover = "#3D484D";
        surfaceActive = "#475258";

        # Borders
        border = "#4A575D";
        borderFocus = "#A7C080";
        separator = "#414B50";

        # Text
        text = "#D3C6AA";
        textSecondary = "#9DA9A0";
        textMuted = "#859289";

        # Accent
        accent = "#A7C080";
        accentHover = "#83C092";
        accentActive = "#D699B6";
        accentMuted = "#475258";
        accentForeground = "#2D353B";

        # Semantic
        success = "#A7C080";
        warning = "#DBBC7F";
        error = "#E67E80";
        info = "#7FBBB3";

        # ANSI
        terminalBlack = "#4B565C";
        terminalRed = "#E67E80";
        terminalGreen = "#A7C080";
        terminalYellow = "#DBBC7F";
        terminalBlue = "#7FBBB3";
        terminalMagenta = "#D699B6";
        terminalCyan = "#83C092";
        terminalWhite = "#9DA9A0";

        terminalBrightBlack = "#859289";
        terminalBrightRed = "#F85552";
        terminalBrightGreen = "#8DA101";
        terminalBrightYellow = "#DFA000";
        terminalBrightBlue = "#3A94C5";
        terminalBrightMagenta = "#DF69BA";
        terminalBrightCyan = "#35A77C";
        terminalBrightWhite = "#D3C6AA";
      };
    };

    # ==========================================================
    # ROSÉ PINE
    # ==========================================================

    rose-pine = {

      name = "Rosé Pine";

      description = "Elegant muted rose dark theme";

      colors = {

        # Base
        background = "#191724";
        backgroundDark = "#13111C";

        # Surfaces
        surface = "#1F1D2E";
        surfaceHover = "#26233A";
        surfaceActive = "#403D52";

        # Borders
        border = "#403D52";
        borderFocus = "#C4A7E7";
        separator = "#2A2739";

        # Text
        text = "#E0DEF4";
        textSecondary = "#908CAA";
        textMuted = "#6E6A86";

        # Accent
        accent = "#C4A7E7";
        accentHover = "#D5BFF2";
        accentActive = "#EBBCBA";
        accentMuted = "#403D52";
        accentForeground = "#191724";

        # Semantic
        success = "#9CCFD8";
        warning = "#F6C177";
        error = "#EB6F92";
        info = "#31748F";

        # ANSI
        terminalBlack = "#26233A";
        terminalRed = "#EB6F92";
        terminalGreen = "#9CCFD8";
        terminalYellow = "#F6C177";
        terminalBlue = "#31748F";
        terminalMagenta = "#C4A7E7";
        terminalCyan = "#EBBCBA";
        terminalWhite = "#E0DEF4";

        terminalBrightBlack = "#6E6A86";
        terminalBrightRed = "#F083A2";
        terminalBrightGreen = "#A6D5D9";
        terminalBrightYellow = "#FFD39E";
        terminalBrightBlue = "#65A6C4";
        terminalBrightMagenta = "#D7B9F2";
        terminalBrightCyan = "#F2C8C7";
        terminalBrightWhite = "#E0DEF4";
      };
    };

    # ==========================================================
    # KANAGAWA
    # ==========================================================

    kanagawa = {

      name = "Kanagawa";

      description = "Sumi ink woodblock dark theme";

      colors = {

        # Base
        background = "#1F1F28";
        backgroundDark = "#16161D";

        # Surfaces
        surface = "#2A2A37";
        surfaceHover = "#363646";
        surfaceActive = "#54546D";

        # Borders
        border = "#424257";
        borderFocus = "#7E9CD8";
        separator = "#363646";

        # Text
        text = "#DCD7BA";
        textSecondary = "#C8C093";
        textMuted = "#727169";

        # Accent
        accent = "#7E9CD8";
        accentHover = "#7FB4CA";
        accentActive = "#957FB8";
        accentMuted = "#54546D";
        accentForeground = "#1F1F28";

        # Semantic
        success = "#98BB6C";
        warning = "#E6C384";
        error = "#E82424";
        info = "#7FB4CA";

        # ANSI
        terminalBlack = "#16161D";
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
  };
}
