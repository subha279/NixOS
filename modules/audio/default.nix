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
    wireplumber = {
      enable = true;
      extraConfig = {
        "10-bluetooth" = {
          "monitor.bluez.properties" = {
            # Keep the normal Bluetooth audio roles available.
            "bluez5.roles" = [
              "a2dp_sink"
              "a2dp_source"
              "hfp_hf"
              "hfp_ag"
            ];

            # Good-quality A2DP codecs.
            "bluez5.codecs" = [
              "sbc"
              "sbc_xq"
            ];

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
            # Never automatically downgrade music playback to HFP/HSP.
            "bluetooth.autoswitch-to-headset-profile" = false;

            # Prefer audio quality when choosing an A2DP configuration.
            "bluetooth.profile-preference" = "quality";
          };
        };
      };
    };
  };
}
