{ config, ... }:

{
  programs.zsh = {
    enable = true;

    dotDir = "${config.xdg.configHome}/zsh";

    # ==================================================
    # Shell Options
    # ==================================================

    setOptions = [
      "AUTO_CD"
      "AUTO_PUSHD"
      "PUSHD_IGNORE_DUPS"
      "PUSHD_SILENT"
      "EXTENDED_GLOB"
      "NO_BEEP"
      "INTERACTIVE_COMMENTS"
    ];

    # ==================================================
    # Shell Environment
    # ==================================================

    envExtra = ''
      # ------------------------------------------------
      # Wallust → Starship
      # ------------------------------------------------

      if [[ -f "$HOME/.cache/wallust/starship.toml" ]]; then
        export STARSHIP_CONFIG="$HOME/.cache/wallust/starship.toml"
      else
        export STARSHIP_CONFIG="$HOME/.config/starship.toml"
      fi
    '';
  };

  # ====================================================
  # Starship
  # ====================================================

  programs.starship = {
    enable = true;

    enableZshIntegration = true;
  };
}
