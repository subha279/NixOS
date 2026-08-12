{ pkgs, config, ... }:

{
  programs.zsh = {
    enable = true;

    dotDir = "${config.xdg.configHome}/zsh";

    # Set this before Starship's Zsh integration initializes.
    envExtra = ''
      if [[ -f "$HOME/.cache/wallust/starship.toml" ]]; then
        export STARSHIP_CONFIG="$HOME/.cache/wallust/starship.toml"
      else
        export STARSHIP_CONFIG="$HOME/.config/starship.toml"
      fi
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
