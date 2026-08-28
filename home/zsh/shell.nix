{ config, ... }:

{
  programs.zsh = {
    enable = true;

    dotDir = "${config.xdg.configHome}/zsh";

    # Shell Options

    setOptions = [
      "AUTO_CD"
      "AUTO_PUSHD"
      "PUSHD_IGNORE_DUPS"
      "PUSHD_SILENT"
      "EXTENDED_GLOB"
      "NO_BEEP"
      "INTERACTIVE_COMMENTS"
    ];

    # Environment

    envExtra = ''
      # ==================================================
      # Aurora → Starship
      # ==================================================

      export STARSHIP_CONFIG="$HOME/.config/aurora/active-starship.toml"
    '';

    # Session launcher
    #
    # This configuration has no display manager on purpose: nothing under
    # modules/ enables greetd, sddm or gdm, and programs.hyprland.enable only
    # installs the compositor, it does not start it. Without this the machine
    # boots to a text console and Hyprland has to be typed by hand, which also
    # means quickshell, the wallpaper daemon and the polkit agent never come up,
    # because they hang off graphical-session.target which
    # home/hyprland/config/startup.lua starts from inside Hyprland.
    #
    # .zprofile rather than .zshrc, because this must run once for a login shell
    # and not again for every terminal opened inside the session.
    #
    # Each guard is load bearing:
    #
    #   WAYLAND_DISPLAY unset   not already inside a Wayland session
    #   SSH_CONNECTION unset    never take over an ssh login
    #   XDG_VTNR = 1            only the first virtual console
    #
    # That last one is the recovery path. If Hyprland cannot start, exec means
    # the login shell is gone and tty1 returns to the login prompt, so tty2
    # through tty6 are deliberately left as plain text consoles to log into and
    # fix it from.
    profileExtra = ''
      # ==================================================
      # Aurora → Hyprland session
      # ==================================================

      if [[ -z "''${WAYLAND_DISPLAY:-}" ]] &&
        [[ -z "''${SSH_CONNECTION:-}" ]] &&
        [[ "''${XDG_VTNR:-0}" == "1" ]]; then
        exec Hyprland
      fi
    '';

    # Interactive Zsh Configuration

    initContent = ''
      # ==================================================
      # Aurora Live Starship Refresh
      # ==================================================
      #
      # Aurora changes active-starship.toml externally.
      #
      # This FIFO allows aurora-theme to notify every
      # running interactive Zsh session.
      #
      # ZLE watches the FIFO and safely redraws the
      # currently displayed Starship prompt.
      #
      # No SIGUSR1.
      # No SIGWINCH.
      # No pkill.
      # No exec zsh after switching.
      #
      # ==================================================

      if [[ -o interactive ]]; then

        # ------------------------------------------------
        # Runtime directory
        # ------------------------------------------------

        typeset -g AURORA_ZSH_REFRESH_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/aurora-zsh"

        mkdir -p "$AURORA_ZSH_REFRESH_DIR"


        # ------------------------------------------------
        # Unique FIFO for this Zsh process
        # ------------------------------------------------

        typeset -g AURORA_ZSH_REFRESH_FIFO="$AURORA_ZSH_REFRESH_DIR/zsh-$$"


        # ------------------------------------------------
        # Remove stale FIFO
        # ------------------------------------------------

        if [[ -e "$AURORA_ZSH_REFRESH_FIFO" ]]; then
          rm -f "$AURORA_ZSH_REFRESH_FIFO"
        fi


        # ------------------------------------------------
        # Create FIFO
        # ------------------------------------------------

        mkfifo "$AURORA_ZSH_REFRESH_FIFO"


        # ------------------------------------------------
        # Open FIFO read/write
        # ------------------------------------------------
        #
        # Read/write keeps the FIFO open and prevents the
        # writer from blocking.
        #
        # ------------------------------------------------

        exec {AURORA_ZSH_REFRESH_FD}<>"$AURORA_ZSH_REFRESH_FIFO"


        # ------------------------------------------------
        # ZLE refresh widget
        # ------------------------------------------------

        aurora-zsh-refresh-widget() {
          local fd="$1"
          local message
          read -r -t 0.05 -u "$fd" message 2>/dev/null || true
          zle reset-prompt
          zle -R
          }

        # ------------------------------------------------
        # Register as a ZLE widget
        # ------------------------------------------------

        zle -N aurora-zsh-refresh-widget


        # ------------------------------------------------
        # Attach FIFO to ZLE
        # ------------------------------------------------

        zle -F \
          -w \
          "$AURORA_ZSH_REFRESH_FD" \
          aurora-zsh-refresh-widget


        # ------------------------------------------------
        # Cleanup
        # ------------------------------------------------

        aurora-zsh-cleanup() {

          zle -F \
            "$AURORA_ZSH_REFRESH_FD" \
            2>/dev/null || true

          # IMPORTANT:
          #
          # The ''${...} escaping is required because this
          # file is generated by Nix.
          #
          eval "exec ''${AURORA_ZSH_REFRESH_FD}>&-" \
            2>/dev/null || true

          rm -f \
            "$AURORA_ZSH_REFRESH_FIFO" \
            2>/dev/null || true
        }

        zshexit_functions+=(
          aurora-zsh-cleanup
        )

      fi
    '';
  };

  # Starship

  programs.starship = {
    enable = true;

    enableZshIntegration = true;
  };
}
