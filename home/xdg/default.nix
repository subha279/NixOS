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
      exec = "env QT_QPA_PLATFORM=xcb nvidia-offload davinci-resolve";
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
