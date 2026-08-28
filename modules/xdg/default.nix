{ pkgs, ... }:

{

  xdg = {
    portal = {
      enable = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
    };

    mime.enable = true;

    autostart.enable = true;

    icons.enable = true;

    menus.enable = true;


    mime.defaultApplications =
      let
        browser = "zen.desktop";

        images = "org.kde.gwenview.desktop";

        video = "vlc.desktop";

        files = "thunar.desktop";

        archive = "org.gnome.FileRoller.desktop";
      in
      {
        "text/html" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/unknown" = browser;

        "application/pdf" = browser;

        "inode/directory" = files;

        "image/png" = images;
        "image/jpeg" = images;
        "image/webp" = images;
        "image/gif" = images;
        "image/tiff" = images;
        "image/bmp" = images;
        "image/avif" = images;

        "image/svg+xml" = browser;

        "video/mp4" = video;
        "video/x-matroska" = video;
        "video/webm" = video;
        "video/quicktime" = video;
        "video/x-msvideo" = video;

        "audio/mpeg" = video;
        "audio/flac" = video;
        "audio/x-wav" = video;
        "audio/ogg" = video;

        "application/zip" = archive;
        "application/x-7z-compressed" = archive;
        "application/x-tar" = archive;
        "application/gzip" = archive;
        "application/x-xz" = archive;
        "application/vnd.rar" = archive;
      };
  };
}
