{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [


    zen-browser


    shared-mime-info
    ffmpegthumbnailer


    p7zip
    unar

    file-roller


    pavucontrol


    nwg-look
    qt6Packages.qt6ct
    kdePackages.qtstyleplugin-kvantum


    networkmanagerapplet


    grim
    slurp
    swappy


    kdePackages.gwenview
    imagemagick


    kdePackages.polkit-kde-agent-1


    awww


    libnotify


    xdg-utils


    (pkgs.obs-studio.override {
      cudaSupport = true;
    })

    ffmpeg
    vlc
    libreoffice-fresh
    gimp
    blender

  ];
}
