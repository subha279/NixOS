{ pkgs, ... }:

{
  fonts = {
    fontconfig.enable = true;

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      inter
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
  };
}
