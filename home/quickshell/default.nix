{ pkgs, ... }:

let
  emojiSource = pkgs.fetchurl {
    url = "https://www.unicode.org/Public/17.0.0/emoji/emoji-test.txt";
    hash = "sha256-HYqUT4jXlS9+98UWf+88Z5lbyuJFQ5SXECMbA6IBrNo=";
  };

  emojiDatabase =
    pkgs.runCommand "aurora-emoji-database"
      {
        nativeBuildInputs = [ pkgs.python3 ];
      }
      ''
        python3 - "${emojiSource}" "$out" <<'PY'
        import json
        import re
        import sys

        source = sys.argv[1]
        output = sys.argv[2]

        items = []
        group = ""
        subgroup = ""

        with open(source, encoding="utf-8") as f:
            for line in f:
                line = line.rstrip()

                if line.startswith("# group:"):
                    group = line.split(":", 1)[1].strip()
                    continue

                if line.startswith("# subgroup:"):
                    subgroup = line.split(":", 1)[1].strip()
                    continue

                if not line or line.startswith("#"):
                    continue

                match = re.match(
                    r"^([0-9A-F ]+);\s+fully-qualified\s+#\s+(\S+)\s+(.+)$",
                    line
                )

                if not match:
                    continue

                emoji = "".join(
                    chr(int(cp, 16))
                    for cp in match.group(1).split()
                )

                items.append({
                    "emoji": emoji,
                    "name": match.group(3).strip().lower(),
                    "group": group.lower(),
                    "subgroup": subgroup.lower(),
                })

        with open(output, "w", encoding="utf-8") as f:
            json.dump(
                items,
                f,
                ensure_ascii=False,
                separators=(",", ":")
            )
        PY
      '';

  quickshellConfig = pkgs.runCommand "aurora-quickshell-config" { } ''
    mkdir -p "$out"

    cp -r ${./config}/. "$out/"

    chmod -R u+w "$out"

    mkdir -p "$out/assets"

    cp ${emojiDatabase} "$out/assets/emoji.json"

    chmod -R u-w "$out"
  '';
in
{
  home.packages = with pkgs; [
    quickshell
    libnotify
    wtype
    wl-clipboard
    cava
  ];

  xdg.configFile."quickshell".source = quickshellConfig;

  xdg.dataFile."dbus-1/services/org.freedesktop.Notifications.service".text = ''
    [D-BUS Service]
    Name=org.freedesktop.Notifications
    Exec=${pkgs.quickshell}/bin/qs
    SystemdService=quickshell.service
  '';

  dconf.settings = {
    "org/gnome/nm-applet" = {
      disable-connected-notifications = true;
      disable-disconnected-notifications = true;
      disable-vpn-notifications = true;
      suppress-wireless-networks-available = true;
    };

    "org/blueman/general" = {
      plugin-list = [ "!ConnectionNotifier" ];
    };
  };

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell desktop shell and notification daemon";

      PartOf = [ "graphical-session.target" ];

      After = [
        "graphical-session.target"
        "dbus.socket"
      ];

      Requires = [ "dbus.socket" ];

      ConditionEnvironment = "WAYLAND_DISPLAY";

      StartLimitBurst = 8;

      StartLimitIntervalSec = 60;
    };

    Service = {
      Type = "exec";

      ExecStart = "${pkgs.quickshell}/bin/qs";

      Restart = "on-failure";

      RestartSec = 2;

      Slice = "session.slice";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
