{ pkgs, ... }:

let
  # Every file dropped in ./scripts is auto-deployed on rebuild.
  # - ~/.config/hypr/scripts/<name> for Hyprland (see scriptDir in config/variables.lua)
  # - ~/.local/bin/<name> on PATH for terminal use
  scriptNames = builtins.attrNames (builtins.readDir ./scripts);
  mkScriptAttrs =
    prefix:
    builtins.listToAttrs (
      map (name: {
        name = "${prefix}/${name}";
        value = {
          source = ./scripts + "/${name}";
          executable = true;
        };
      }) scriptNames
    );
in
{
  # Sunflower Hyprland
  xdg.configFile = {
    # Polkit Qt Environment Override
    "systemd/user/plasma-polkit-agent.service.d/environment.conf".text = ''
      [Service]
      Environment=QT_STYLE_OVERRIDE=
    '';

    # Hyprland Lua Configuration
    "hypr/hyprland.lua".source = ./hyprland.lua;

    # Hyprland Configuration Modules
    "hypr/config".source = ./config;
  }
  // mkScriptAttrs "hypr/scripts";

  # All scripts on PATH, no per-script entries needed.
  home.file = mkScriptAttrs ".local/bin";

  # Sunflower Desktop Services
  systemd.user.targets.hyprland-session = {
    Unit = {
      Description = "Hyprland compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
      Before = [ "graphical-session.target" ];
    };
  };

  systemd.user.targets.desktop-services = {
    Unit = {
      Description = "Sunflower desktop services";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Wants = [
        "quickshell.service"
        "awww-daemon.service"
        "plasma-polkit-agent.service"
        "nm-applet.service"
        "blueman-applet.service"
      ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.nm-applet = {
    Unit = {
      Description = "NetworkManager applet";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      Type = "exec";
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator";
      Restart = "on-failure";
      RestartSec = 2;
      Slice = "session.slice";
    };

    Install = {
      WantedBy = [ "desktop-services.target" ];
    };
  };

  # Bluetooth Applet
  systemd.user.services.blueman-applet = {
    Unit = {
      Description = "Blueman bluetooth applet";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      Type = "exec";
      ExecStart = "${pkgs.blueman}/bin/blueman-applet";
      Restart = "on-failure";
      RestartSec = 2;
      Slice = "session.slice";
    };

    Install = {
      WantedBy = [ "desktop-services.target" ];
    };
  };

  # Awww Wallpaper Daemon
  systemd.user.services.awww-daemon = {
    Unit = {
      Description = "Awww Wayland wallpaper daemon";
      PartOf = [
        "graphical-session.target"
      ];
      After = [
        "graphical-session.target"
      ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      Type = "exec";
      ExecStart = "${pkgs.awww}/bin/awww-daemon";
      Restart = "on-failure";
      RestartSec = 2;
      Slice = "session.slice";
    };

    Install = {
      WantedBy = [ "desktop-services.target" ];
    };
  };
}
