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

    # thunar, thunar-volman and tumbler are provided by
    # programs.thunar / services.tumbler in ./services.nix, and gvfs by
    # services.gvfs. Listing them here too shipped a second, unintegrated
    # copy with no plugins and no thumbnailer registration.
    shared-mime-info
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
    #
    # No package needed. The launcher, wallpaper picker and
    # colorscheme picker are Quickshell surfaces, in
    # home/quickshell/config/modules.
    #

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
