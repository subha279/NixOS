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
    #
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
        name = "FiraCode Nerd Font";
        package = "nerd-fonts.fira-code";
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
      name = "Papirus-Dark";
      package = "papirus-icon-theme";
    };

    # ------------------------------------------------------------------------
    # Cursor
    # ------------------------------------------------------------------------

    cursor = {
      name = "Bibata-Modern-Classic";
      package = "bibata-cursors";
      size = 24;
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
      fontSize = 12;
      fontSizeSmall = 10;
      fontSizeLarge = 14;

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

  };

}
