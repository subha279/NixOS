{ pkgs, ... }:

{
  fonts = {
    fontconfig.enable = true;
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
