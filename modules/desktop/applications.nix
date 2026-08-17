{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # ==============================
    # Browser
    # ==============================

    firefox

    # ==============================
    # File Manager
    # ==============================

    thunar
    thunar-volman

    # Thunar / File integration
    shared-mime-info
    gvfs
    tumbler
    ffmpegthumbnailer

    # ==============================
    # Archives
    # ==============================

    p7zip
    unar

    # Archive Manager
    file-roller

    # ==============================
    # Audio
    # ==============================

    pavucontrol

    # ==============================
    # Theming
    # ==============================

    nwg-look
    qt6Packages.qt6ct
    kdePackages.qtstyleplugin-kvantum

    # ==============================
    # Network
    # ==============================

    networkmanagerapplet

    # ==============================
    # Screenshots
    # ==============================

    grim
    slurp
    swappy

    # ==============================
    # Image Viewer / Basic Editor
    # ==============================

    kdePackages.gwenview
    imagemagick

    # ==============================
    # Authentication
    # ==============================

    kdePackages.polkit-kde-agent-1

    # ==============================
    # Wallpaper
    # ==============================

    awww

    # ==============================
    # Launcher
    # ==============================

    fuzzel

    # ==============================
    # Notifications
    # ==============================

    libnotify

    # ==============================
    # Desktop Utilities
    # ==============================

    xdg-utils

    # ==============================
    # Content Creation
    # ==============================

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
