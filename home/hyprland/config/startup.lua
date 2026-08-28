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

	-- Network
	--
	-- Guarded so a reload cannot stack a second copy.
	--
	-- `aurora-theme` ends with `hyprctl reload`, and depending on whether these
	-- land as `exec` or `exec-once` a reload can re-run this whole block. A
	-- second nm-applet means two secret agents registered against
	-- NetworkManager for the same session, which is a good way to make a
	-- perfectly healthy connection look like it is renegotiating every time the
	-- theme changes.
	--
	-- pgrep -x matches the exact process name. If it ever fails to match, the
	-- behaviour is simply the old behaviour, so this cannot stop the applet
	-- starting in the first place.

	hl.exec_cmd("pgrep -x nm-applet >/dev/null 2>&1 || nm-applet --indicator")

	-- Bluetooth

	hl.exec_cmd("pgrep -x blueman-applet >/dev/null 2>&1 || blueman-applet")

	-- Wallpaper

	hl.exec_cmd("sleep 1 && ~/.config/hypr/scripts/restore-wallpaper.sh")

end)
