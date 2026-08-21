{
  # ==========================================================================
  # GLOBAL AURORA SETTINGS
  # ==========================================================================
  #
  # This section is the SINGLE SOURCE OF TRUTH for:
  #
  #   • Active theme
  #   • Interface font
  #   • Terminal font
  #   • Emoji font
  #   • Icon theme
  #   • Cursor
  #   • Font sizes
  #   • Window appearance
  #
  # Applications should consume these values rather than defining their own.
  #
  # ==========================================================================

  global = {

    # ------------------------------------------------------------------------
    # Active Theme
    # ------------------------------------------------------------------------
    #
    # Available:
    #
    #   aurora
    #   gruvbox
    #   tokyo-night
    #   monochrome
    #   catppuccin-mocha
    #   nord
    #   dracula
    #   one-dark
    #   everforest
    #   rose-pine
    # Change ONLY this value when you want to change the entire theme.
    #
    activeTheme = "aurora";

    # ------------------------------------------------------------------------
    # Fonts
    # ------------------------------------------------------------------------

    fonts = {

      # Main UI font.
      #
      # Used by:
      #   • Stylix
      #   • GTK
      #   • Qt
      #   • QuickShell
      #   • Fuzzel
      #   • desktop UI
      #
      interface = {
        name = "Inter";
        package = "inter";
      };

      # Monospace / terminal font.
      #
      # Used by:
      #   • Kitty
      #   • Neovim
      #   • terminal applications
      #   • CLI interfaces
      #
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

    # ------------------------------------------------------------------------
    # Icons
    # ------------------------------------------------------------------------

    icons = {
      name = "Colloid-Dark";
      package = "colloid-icon-theme";
    };

    # ------------------------------------------------------------------------
    # Cursor
    # ------------------------------------------------------------------------

    cursor = {
      name = "phinger-cursors-dark";
      package = "phinger-cursors";
      size = 30;
    };

    # ------------------------------------------------------------------------
    # UI
    # ------------------------------------------------------------------------

    ui = {

      # Window border.
      borderWidth = 2;

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

      # Shadow strength.
      shadowOpacity = 0.20;

      # Default application/window opacity.
      windowOpacity = 0.96;

    };

  };

  # ==========================================================================
  # THEMES
  # ==========================================================================
  #
  # These are STATIC themes.
  #
  # They are NOT generated from wallpapers.
  #
  # Wallust does not participate in this palette.
  #
  # ==========================================================================

  themes = {

    # ========================================================================
    # AURORA
    # ========================================================================

    aurora = {

      name = "Aurora";

      description = "Charcoal and lavender";

      colors = {

        # ----------------------------------------------------------------------
        # Background
        # ----------------------------------------------------------------------

        background = "#181D25";
        backgroundDark = "#141920";

        # ----------------------------------------------------------------------
        # Surfaces
        # ----------------------------------------------------------------------

        surface = "#282E37";
        surfaceHover = "#303743";
        surfaceActive = "#363D49";

        # ----------------------------------------------------------------------
        # Borders
        # ----------------------------------------------------------------------

        border = "#3B4350";
        borderFocus = "#A970FF";
        separator = "#343B47";

        # ----------------------------------------------------------------------
        # Text
        # ----------------------------------------------------------------------

        text = "#F2F3F7";
        textSecondary = "#B9BEC8";
        textMuted = "#858D9A";

        # ----------------------------------------------------------------------
        # Accent
        # ----------------------------------------------------------------------

        accent = "#A970FF";
        accentHover = "#B98AFF";
        accentActive = "#C7A6FF";
        accentMuted = "#55406F";
        accentForeground = "#181D25";

        # ----------------------------------------------------------------------
        # Semantic States
        # ----------------------------------------------------------------------

        success = "#8FE3A5";
        warning = "#FFD479";
        error = "#FF7F96";
        info = "#8FB8FF";

        # ----------------------------------------------------------------------
        # Terminal ANSI
        # ----------------------------------------------------------------------

        terminalBlack = "#141920";
        terminalRed = "#FF7F96";
        terminalGreen = "#8FE3A5";
        terminalYellow = "#FFD479";
        terminalBlue = "#8FB8FF";
        terminalMagenta = "#B98AFF";
        terminalCyan = "#7DD3FC";
        terminalWhite = "#F2F3F7";

        terminalBrightBlack = "#858D9A";
        terminalBrightRed = "#FF9CAF";
        terminalBrightGreen = "#A5F2B8";
        terminalBrightYellow = "#FFE39A";
        terminalBrightBlue = "#A9C7FF";
        terminalBrightMagenta = "#C7A6FF";
        terminalBrightCyan = "#9BE3FF";
        terminalBrightWhite = "#FFFFFF";

      };

    };

    # ========================================================================
    # GRUVBOX
    # ========================================================================

    gruvbox = {

      name = "Gruvbox";

      description = "Warm earthy tones";

      colors = {

        # ----------------------------------------------------------------------
        # Background
        # ----------------------------------------------------------------------

        background = "#282828";
        backgroundDark = "#1D2021";

        # ----------------------------------------------------------------------
        # Surfaces
        # ----------------------------------------------------------------------

        surface = "#3C3836";
        surfaceHover = "#504945";
        surfaceActive = "#665C54";

        # ----------------------------------------------------------------------
        # Borders
        # ----------------------------------------------------------------------

        border = "#504945";
        borderFocus = "#D79921";
        separator = "#45403D";

        # ----------------------------------------------------------------------
        # Text
        # ----------------------------------------------------------------------

        text = "#EBDBB2";
        textSecondary = "#D5C4A1";
        textMuted = "#928374";

        # ----------------------------------------------------------------------
        # Accent
        # ----------------------------------------------------------------------

        accent = "#D79921";
        accentHover = "#FABD2F";
        accentActive = "#FE8019";
        accentMuted = "#665C54";
        accentForeground = "#282828";

        # ----------------------------------------------------------------------
        # Semantic States
        # ----------------------------------------------------------------------

        success = "#B8BB26";
        warning = "#FABD2F";
        error = "#FB4934";
        info = "#83A598";

        # ----------------------------------------------------------------------
        # Terminal ANSI
        # ----------------------------------------------------------------------

        terminalBlack = "#1D2021";
        terminalRed = "#FB4934";
        terminalGreen = "#B8BB26";
        terminalYellow = "#FABD2F";
        terminalBlue = "#83A598";
        terminalMagenta = "#D3869B";
        terminalCyan = "#8EC07C";
        terminalWhite = "#EBDBB2";

        terminalBrightBlack = "#665C54";
        terminalBrightRed = "#FB4934";
        terminalBrightGreen = "#B8BB26";
        terminalBrightYellow = "#FABD2F";
        terminalBrightBlue = "#83A598";
        terminalBrightMagenta = "#D3869B";
        terminalBrightCyan = "#8EC07C";
        terminalBrightWhite = "#FBF1C7";

      };

    };

    # ========================================================================
    # TOKYO NIGHT
    # ========================================================================

    tokyo-night = {

      name = "Tokyo Night";

      description = "Deep blue and violet";

      colors = {

        # ----------------------------------------------------------------------
        # Background
        # ----------------------------------------------------------------------

        background = "#1A1B26";
        backgroundDark = "#16161E";

        # ----------------------------------------------------------------------
        # Surfaces
        # ----------------------------------------------------------------------

        surface = "#24283B";
        surfaceHover = "#2F334D";
        surfaceActive = "#3B4261";

        # ----------------------------------------------------------------------
        # Borders
        # ----------------------------------------------------------------------

        border = "#3B4261";
        borderFocus = "#7AA2F7";
        separator = "#303449";

        # ----------------------------------------------------------------------
        # Text
        # ----------------------------------------------------------------------

        text = "#C0CAF5";
        textSecondary = "#A9B1D6";
        textMuted = "#565F89";

        # ----------------------------------------------------------------------
        # Accent
        # ----------------------------------------------------------------------

        accent = "#7AA2F7";
        accentHover = "#89B4FA";
        accentActive = "#BB9AF7";
        accentMuted = "#414868";
        accentForeground = "#1A1B26";

        # ----------------------------------------------------------------------
        # Semantic States
        # ----------------------------------------------------------------------

        success = "#9ECE6A";
        warning = "#E0AF68";
        error = "#F7768E";
        info = "#7DCFFF";

        # ----------------------------------------------------------------------
        # Terminal ANSI
        # ----------------------------------------------------------------------

        terminalBlack = "#16161E";
        terminalRed = "#F7768E";
        terminalGreen = "#9ECE6A";
        terminalYellow = "#E0AF68";
        terminalBlue = "#7AA2F7";
        terminalMagenta = "#BB9AF7";
        terminalCyan = "#7DCFFF";
        terminalWhite = "#C0CAF5";

        terminalBrightBlack = "#565F89";
        terminalBrightRed = "#FF8FA3";
        terminalBrightGreen = "#B9E27C";
        terminalBrightYellow = "#F2C98B";
        terminalBrightBlue = "#89B4FA";
        terminalBrightMagenta = "#C7A5FF";
        terminalBrightCyan = "#8FE3FF";
        terminalBrightWhite = "#D5D9FF";

      };

    };

    # ========================================================================
    # MONOCHROME
    # ========================================================================

    monochrome = {

      name = "Monochrome";

      description = "Pure black and white";

      colors = {

        # ----------------------------------------------------------------------
        # Background
        # ----------------------------------------------------------------------

        background = "#0A0A0A";
        backgroundDark = "#000000";

        # ----------------------------------------------------------------------
        # Surfaces
        # ----------------------------------------------------------------------

        surface = "#151515";
        surfaceHover = "#202020";
        surfaceActive = "#2A2A2A";

        # ----------------------------------------------------------------------
        # Borders
        # ----------------------------------------------------------------------

        border = "#3A3A3A";
        borderFocus = "#FFFFFF";
        separator = "#303030";

        # ----------------------------------------------------------------------
        # Text
        # ----------------------------------------------------------------------

        text = "#F5F5F5";
        textSecondary = "#B8B8B8";
        textMuted = "#707070";

        # ----------------------------------------------------------------------
        # Accent
        # ----------------------------------------------------------------------

        accent = "#FFFFFF";
        accentHover = "#E5E5E5";
        accentActive = "#FFFFFF";
        accentMuted = "#505050";
        accentForeground = "#000000";

        # ----------------------------------------------------------------------
        # Semantic States
        # ----------------------------------------------------------------------

        success = "#C0C0C0";
        warning = "#D0D0D0";
        error = "#A8A8A8";
        info = "#B8B8B8";

        # ----------------------------------------------------------------------
        # Terminal ANSI
        # ----------------------------------------------------------------------

        terminalBlack = "#000000";
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
    # ========================================================================
    # CATPPUCCIN MOCHA
    # ========================================================================

    catppuccin-mocha = {

      name = "Catppuccin Mocha";

      description = "Soft pastel colors on a dark mocha background";

      colors = {

        background = "#1E1E2E";
        backgroundDark = "#11111B";

        surface = "#313244";
        surfaceHover = "#45475A";
        surfaceActive = "#585B70";

        border = "#45475A";
        borderFocus = "#CBA6F7";
        separator = "#313244";

        text = "#CDD6F4";
        textSecondary = "#BAC2DE";
        textMuted = "#6C7086";

        accent = "#CBA6F7";
        accentHover = "#D8B4FE";
        accentActive = "#F5C2E7";
        accentMuted = "#585B70";
        accentForeground = "#1E1E2E";

        success = "#A6E3A1";
        warning = "#F9E2AF";
        error = "#F38BA8";
        info = "#89B4FA";

        terminalBlack = "#11111B";
        terminalRed = "#F38BA8";
        terminalGreen = "#A6E3A1";
        terminalYellow = "#F9E2AF";
        terminalBlue = "#89B4FA";
        terminalMagenta = "#CBA6F7";
        terminalCyan = "#94E2D5";
        terminalWhite = "#CDD6F4";

        terminalBrightBlack = "#585B70";
        terminalBrightRed = "#F38BA8";
        terminalBrightGreen = "#A6E3A1";
        terminalBrightYellow = "#F9E2AF";
        terminalBrightBlue = "#89B4FA";
        terminalBrightMagenta = "#F5C2E7";
        terminalBrightCyan = "#94E2D5";
        terminalBrightWhite = "#FFFFFF";
      };
    };

    # ========================================================================
    # NORD
    # ========================================================================

    nord = {

      name = "Nord";

      description = "Arctic blue and cool gray";

      colors = {

        background = "#2E3440";
        backgroundDark = "#242933";

        surface = "#3B4252";
        surfaceHover = "#434C5E";
        surfaceActive = "#4C566A";

        border = "#4C566A";
        borderFocus = "#88C0D0";
        separator = "#434C5E";

        text = "#ECEFF4";
        textSecondary = "#D8DEE9";
        textMuted = "#81A1C1";

        accent = "#88C0D0";
        accentHover = "#8FBCBB";
        accentActive = "#81A1C1";
        accentMuted = "#4C566A";
        accentForeground = "#2E3440";

        success = "#A3BE8C";
        warning = "#EBCB8B";
        error = "#BF616A";
        info = "#81A1C1";

        terminalBlack = "#242933";
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

    # ========================================================================
    # DRACULA
    # ========================================================================

    dracula = {

      name = "Dracula";

      description = "Dark purple with vivid neon accents";

      colors = {

        background = "#282A36";
        backgroundDark = "#1E1F29";

        surface = "#343746";
        surfaceHover = "#44475A";
        surfaceActive = "#6272A4";

        border = "#44475A";
        borderFocus = "#BD93F9";
        separator = "#44475A";

        text = "#F8F8F2";
        textSecondary = "#D6D6CE";
        textMuted = "#6272A4";

        accent = "#BD93F9";
        accentHover = "#D0B4FF";
        accentActive = "#FF79C6";
        accentMuted = "#44475A";
        accentForeground = "#282A36";

        success = "#50FA7B";
        warning = "#F1FA8C";
        error = "#FF5555";
        info = "#8BE9FD";

        terminalBlack = "#21222C";
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

    # ========================================================================
    # ONE DARK
    # ========================================================================

    one-dark = {

      name = "One Dark";

      description = "Classic Atom-inspired developer theme";

      colors = {

        background = "#282C34";
        backgroundDark = "#21252B";

        surface = "#2C313C";
        surfaceHover = "#3A3F4B";
        surfaceActive = "#4B5263";

        border = "#3E4451";
        borderFocus = "#61AFEF";
        separator = "#353B45";

        text = "#ABB2BF";
        textSecondary = "#9DA5B4";
        textMuted = "#5C6370";

        accent = "#61AFEF";
        accentHover = "#82C7FF";
        accentActive = "#C678DD";
        accentMuted = "#3E4451";
        accentForeground = "#282C34";

        success = "#98C379";
        warning = "#E5C07B";
        error = "#E06C75";
        info = "#61AFEF";

        terminalBlack = "#1E2127";
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

    # ========================================================================
    # EVERFOREST
    # ========================================================================

    everforest = {

      name = "Everforest";

      description = "Calm green and earthy forest tones";

      colors = {

        background = "#2D353B";
        backgroundDark = "#232A2E";

        surface = "#343F44";
        surfaceHover = "#3D484D";
        surfaceActive = "#475258";

        border = "#475258";
        borderFocus = "#A7C080";
        separator = "#3D484D";

        text = "#D3C6AA";
        textSecondary = "#9DA9A0";
        textMuted = "#859289";

        accent = "#A7C080";
        accentHover = "#B5CC91";
        accentActive = "#D699B6";
        accentMuted = "#475258";
        accentForeground = "#2D353B";

        success = "#A7C080";
        warning = "#DBBC7F";
        error = "#E67E80";
        info = "#7FBBB3";

        terminalBlack = "#232A2E";
        terminalRed = "#E67E80";
        terminalGreen = "#A7C080";
        terminalYellow = "#DBBC7F";
        terminalBlue = "#7FBBB3";
        terminalMagenta = "#D699B6";
        terminalCyan = "#83C092";
        terminalWhite = "#D3C6AA";

        terminalBrightBlack = "#859289";
        terminalBrightRed = "#F85552";
        terminalBrightGreen = "#8DA101";
        terminalBrightYellow = "#DFA000";
        terminalBrightBlue = "#3A94C5";
        terminalBrightMagenta = "#DF69BA";
        terminalBrightCyan = "#35A77C";
        terminalBrightWhite = "#E4E1CD";
      };
    };

    # ========================================================================
    # ROSE PINE
    # ========================================================================

    rose-pine = {

      name = "Rosé Pine";

      description = "Elegant muted rose and pine colors";

      colors = {

        background = "#191724";
        backgroundDark = "#13111C";

        surface = "#26233A";
        surfaceHover = "#393552";
        surfaceActive = "#44415A";

        border = "#403D52";
        borderFocus = "#C4A7E7";
        separator = "#26233A";

        text = "#E0DEF4";
        textSecondary = "#908CAA";
        textMuted = "#6E6A86";

        accent = "#C4A7E7";
        accentHover = "#D5BFF2";
        accentActive = "#EBBCBA";
        accentMuted = "#403D52";
        accentForeground = "#191724";

        success = "#9CCFD8";
        warning = "#F6C177";
        error = "#EB6F92";
        info = "#31748F";

        terminalBlack = "#13111C";
        terminalRed = "#EB6F92";
        terminalGreen = "#9CCFD8";
        terminalYellow = "#F6C177";
        terminalBlue = "#31748F";
        terminalMagenta = "#C4A7E7";
        terminalCyan = "#9CCFD8";
        terminalWhite = "#E0DEF4";

        terminalBrightBlack = "#6E6A86";
        terminalBrightRed = "#EB6F92";
        terminalBrightGreen = "#9CCFD8";
        terminalBrightYellow = "#F6C177";
        terminalBrightBlue = "#31748F";
        terminalBrightMagenta = "#C4A7E7";
        terminalBrightCyan = "#9CCFD8";
        terminalBrightWhite = "#FFFFFF";
      };
    };

  };

}
