{ ... }:

{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;

    audio.enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;

    pulse.enable = true;

    jack.enable = true;

    wireplumber = {
      enable = true;

      extraConfig = {
        "10-bluetooth" = {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
          };

          "monitor.bluez.rules" = [
            {
              matches = [
                {
                  "device.name" = "bluez_card.F4_4E_FC_42_90_A5";
                }
              ];

              actions = {
                update-props = {
                  "device.profile" = "a2dp-sink";
                  "bluez5.auto-connect" = [
                    "a2dp_sink"
                  ];
                };
              };
            }
          ];
        };

        "11-bluetooth-policy" = {
          "wireplumber.settings" = {
            "bluetooth.autoswitch-to-headset-profile" = false;
          };
        };
      };
    };
  };
}
