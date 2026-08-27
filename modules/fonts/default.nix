{ pkgs, ... }:

{
  fonts = {
    fontconfig = {
      enable = true;

      # Rendering, stated explicitly.
      #
      # The fallback chain itself (which family answers a request for sans, mono
      # or emoji) is owned by stylix via targets.fontconfig, driven from
      # lib/themes.nix -- deliberately not duplicated here, because
      # defaultFonts.* are list options and a second definition would merge into
      # stylix's with no guaranteed priority order.
      #
      # What stylix does not set is how glyphs are rasterised, which is this:

      antialias = true;

      # "slight" hints vertically only. It keeps the horizontal stems where the
      # designer put them, which matters for Inter and JetBrains Mono; full
      # hinting snaps them to the pixel grid and distorts the letterforms.
      hinting = {
        enable = true;
        style = "slight";
      };

      # Subpixel (LCD) rendering. This monitor is a 24" 1080p IPS panel -- about
      # 92 PPI, low enough that using the three subpixels as separate samples is
      # a real gain in apparent sharpness rather than a micro-optimisation.
      #
      # It assumes an RGB stripe, which IPS desktop panels effectively always
      # are. If text ever shows colour fringing on a different display, set
      # rgba = "none" to fall back to greyscale antialiasing.
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
    };

    fontDir.enable = true;

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.caskaydia-cove
      nerd-fonts.fira-code
      sf-mono-nerd
      nerd-fonts.comic-shanns-mono
      maple-mono.truetype
      inter
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
  };
}
