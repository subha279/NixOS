{ pkgs, ... }:

{
  fonts = {
    fontconfig = {
      enable = true;


      antialias = true;

      hinting = {
        enable = true;
        style = "slight";
      };

      # Assumes an RGB stripe panel. Set rgba = "none" if text shows fringing.
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
