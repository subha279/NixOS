{ pkgs, ... }:

{

  services.gvfs.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.udisks2.enable = true;


  programs.thunar = {
    enable = true;

    plugins = with pkgs; [
      thunar-volman
      thunar-archive-plugin
      thunar-media-tags-plugin
    ];
  };

  programs.xfconf.enable = true;

  services.tumbler.enable = true;
}
