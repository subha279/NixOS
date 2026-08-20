{ ... }:

{
  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
    };

    desktopEntries.davinci-resolve = {
      name = "DaVinci Resolve";
      genericName = "Video Editor";
      comment = "Professional video editing, color correction and audio post-production";
      exec = "env QT_QPA_PLATFORM=xcb QT_QPA_PLATFORMTHEME= QT_STYLE_OVERRIDE= QT_AUTO_SCREEN_SCALE_FACTOR=0 QT_SCREEN_SCALE_FACTORS=1 QT_SCALE_FACTOR=1 QT_FONT_DPI=96 nvidia-offload davinci-resolve";
      icon = "davinci-resolve";
      terminal = false;

      categories = [
        "AudioVideo"
        "AudioVideoEditing"
        "Video"
        "Graphics"
      ];
    };
  };
}
