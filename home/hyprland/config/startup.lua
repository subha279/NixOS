hl.on("hyprland.start", function()
	-- Session Environment

	hl.exec_cmd(
		"dbus-update-activation-environment --systemd "
			.. "WAYLAND_DISPLAY "
			.. "XDG_CURRENT_DESKTOP "
			.. "XDG_SESSION_TYPE "
			.. "XDG_SESSION_DESKTOP "
			.. "HYPRLAND_INSTANCE_SIGNATURE "
			.. "&& systemctl --user start hyprland-session.target"
	)

	-- nm-applet and blueman-applet used to be launched from here.
	--
	-- They are systemd user services now, in home/hyprland/default.nix, pulled
	-- in by desktop-services.target. The line above starts that target, so they
	-- come up as part of the same session, just with systemd owning them.
	--
	-- The reason is duplication. `aurora-theme` finishes with `hyprctl reload`,
	-- and anything started from this hook can be started again by a reload. Two
	-- nm-applets mean two secret agents registered against NetworkManager for
	-- one session, which is enough to make a healthy connection look like it is
	-- renegotiating every time the theme changes. systemd will only ever run one
	-- copy of a service, so the problem cannot occur.

	-- Wallpaper

	hl.exec_cmd("sleep 1 && ~/.config/hypr/scripts/restore-wallpaper.sh")

end)
