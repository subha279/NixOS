{ pkgs, ... }:

{
  xdg.mime.defaultApplications = {

    "text/html" = "firefox.desktop";

    "x-scheme-handler/http" = "firefox.desktop";

    "x-scheme-handler/https" = "firefox.desktop";

    "application/pdf" = "firefox.desktop";

    "inode/directory" = "thunar.desktop";

    "image/png" = "firefox.desktop";

    "image/jpeg" = "firefox.desktop";
  };
}
