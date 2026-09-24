{
  lib,
  themeData,
  themeNames,
  ...
}:

let
  base16 = import ./generators/base16.nix {
    inherit lib themeData;
  };

  gtk = import ./generators/gtk.nix {
    inherit
      lib
      themeData
      themeNames
      base16
      ;
  };

  kvantum = import ./generators/kvantum.nix {
    inherit
      lib
      themeData
      themeNames
      base16
      ;
  };

  tmux = import ./generators/tmux.nix {
    inherit lib themeData themeNames;
  };

  starship = import ./generators/starship.nix {
    inherit lib themeData themeNames;
  };

in
{
  # Base16
  inherit (base16)
    hexToDec
    toBase16
    renderTemplate
    ;

  # GTK
  inherit (gtk)
    themeToGtk3
    themeToGtk4
    generatedGtk3Files
    generatedGtk4Files
    ;

  # Kvantum
  inherit (kvantum)
    toKvantumConfig
    toKvantumSvg
    generatedKvantumConfigFiles
    generatedKvantumSvgFiles
    ;

  # tmux
  inherit (tmux)
    themeToTmux
    tmuxThemeFiles
    generatedTmuxFiles
    ;

  # Starship
  inherit (starship)
    themeToStarship
    starshipThemeFiles
    generatedStarshipFiles
    ;
}
