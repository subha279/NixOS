{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hardware.kreoRgb;

  kreoRgbTheme = pkgs.writeShellApplication {
    name = "kreo-rgb-theme";

    runtimeInputs = [
      kreoRgb
    ];

    text = ''
      set -euo pipefail

      if [ "$#" -ne 1 ]; then
        echo "Usage: kreo-rgb-theme <hex-color>" >&2
        exit 1
      fi

      kreo-rgb "$1"
    '';
  };

  kreoRgb = pkgs.writeShellApplication {
    name = "kreo-rgb";

    runtimeInputs = [
      pkgs.hidapitester
    ];

    text = ''
      set -euo pipefail

      VIDPID="320F/5055"
      USAGE_PAGE="0xFF1C"
      USAGE="0x0092"

      send_rgb() {
        local r="$1"
        local g="$2"
        local b="$3"

        hidapitester \
          --vidpid "$VIDPID" \
          --usagePage "$USAGE_PAGE" \
          --usage "$USAGE" \
          --open \
          -l 64 \
          --send-output \
          "0x04,0x3B,0x02,0x06,0x22,0x00,0x00,0x00,0x00,0x06,0x04,0x02,0x00,0x00,$(printf '0x%02X' "$r"),$(printf '0x%02X' "$g"),$(printf '0x%02X' "$b"),0x08,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00"
      }

      hex_to_rgb() {
        local hex="''${1#\#}"

        if [ "''${#hex}" -ne 6 ]; then
          echo "Invalid color: $1" >&2
          exit 1
        fi

        R=$((16#''${hex:0:2}))
        G=$((16#''${hex:2:2}))
        B=$((16#''${hex:4:2}))
      }

      case "''${1:-}" in
        red)    R=255; G=0;   B=0   ;;
        green)  R=0;   G=255; B=0   ;;
        blue)   R=0;   G=0;   B=255 ;;
        white)  R=255; G=255; B=255 ;;
        purple) R=128; G=0;   B=255 ;;
        pink)   R=255; G=0;   B=128 ;;
        cyan)   R=0;   G=255; B=255 ;;
        yellow) R=255; G=255; B=0 ;;
        orange) R=255; G=100; B=0 ;;
        off)    R=0;   G=0;   B=0 ;;
        \#*|[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])
          hex_to_rgb "$1"
          ;;
        *)
          echo "Usage: kreo-rgb <color>" >&2
          echo "Examples: kreo-rgb red" >&2
          echo "          kreo-rgb '#CBA6F7'" >&2
          echo "          kreo-rgb off" >&2
          exit 1
          ;;
      esac

      send_rgb "$R" "$G" "$B"
    '';
  };

in
{
  options.hardware.kreoRgb = {
    enable = lib.mkEnableOption "Kreo Hive RGB support";

    followTheme = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Make Kreo RGB follow the active desktop theme accent.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      kreoRgb
      kreoRgbTheme
    ];

    environment.etc."aurora/kreo-rgb.conf".text = ''
      enabled=1
      follow-theme=${if cfg.followTheme then "1" else "0"}
    '';

    services.udev.extraRules = ''
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="320f", ATTRS{idProduct}=="5055", MODE="0660", GROUP="input"
    '';
  };
}
