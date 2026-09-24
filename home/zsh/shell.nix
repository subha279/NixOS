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
      # Aurora → Starship
      export STARSHIP_CONFIG="$HOME/.config/aurora/active-starship.toml"
    '';

profileExtra = ''
      # Aurora → Hyprland session (only on TTY1, not SSH, not already in Wayland)
      if [[ -z "''${WAYLAND_DISPLAY:-}" ]] && [[ -z "''${SSH_CONNECTION:-}" ]] && [[ "''${XDG_VTNR:-0}" == "1" ]] && [[ "$(tty)" == "/dev/tty1" ]]; then
        exec start-hyprland
      fi
    '';

    # Interactive Zsh Configuration
    initContent = ''

      clear() {
        command clear
        printf '\033[3J'
      }

      if [[ -o interactive ]]; then

        typeset -g AURORA_ZSH_REFRESH_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/aurora-zsh"

        mkdir -p "$AURORA_ZSH_REFRESH_DIR"

        typeset -g AURORA_ZSH_REFRESH_FIFO="$AURORA_ZSH_REFRESH_DIR/zsh-$$"

        if [[ -e "$AURORA_ZSH_REFRESH_FIFO" ]]; then
          rm -f "$AURORA_ZSH_REFRESH_FIFO"
        fi

        mkfifo "$AURORA_ZSH_REFRESH_FIFO"

        exec {AURORA_ZSH_REFRESH_FD}<>"$AURORA_ZSH_REFRESH_FIFO"

        aurora-zsh-refresh-widget() {
          local fd="$1"
          local message
          read -r -t 0.05 -u "$fd" message 2>/dev/null || true
          zle reset-prompt
          zle -R
          }

        zle -N aurora-zsh-refresh-widget

        zle -F \
          -w \
          "$AURORA_ZSH_REFRESH_FD" \
          aurora-zsh-refresh-widget

        aurora-zsh-cleanup() {

          zle -F \
            "$AURORA_ZSH_REFRESH_FD" \
            2>/dev/null || true

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
