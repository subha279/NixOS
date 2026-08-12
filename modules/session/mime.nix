{ ... }:

{
  xdg.mime.defaultApplications = {

    # Browser
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";

    # Documents
    "application/pdf" = "firefox.desktop";

    # File manager
    "inode/directory" = "thunar.desktop";

    # Images
    "image/png" = "org.kde.gwenview.desktop";
    "image/jpeg" = "org.kde.gwenview.desktop";
    "image/webp" = "org.kde.gwenview.desktop";
    "image/gif" = "org.kde.gwenview.desktop";
    "image/tiff" = "org.kde.gwenview.desktop";
    "image/bmp" = "org.kde.gwenview.desktop";

    # Vector images
    "image/svg+xml" = "firefox.desktop";
  };
}
