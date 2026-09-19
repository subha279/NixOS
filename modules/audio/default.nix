{ pkgs, ... }:

{
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    easyeffects
  ];

  services.pipewire = {
    enable = true;
    audio.enable = true;

    alsa = {
      enable = true;
      support32Bit = true;
    };

    pulse.enable = true;
    jack.enable = true;

    wireplumber.enable = true;
  };
}
