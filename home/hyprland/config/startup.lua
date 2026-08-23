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

	hl.exec_cmd("nm-applet --indicator")

	-- Bluetooth

	hl.exec_cmd("blueman-applet")

	-- Wallpaper

	hl.exec_cmd("sleep 1 && ~/.config/hypr/scripts/restore-wallpaper.sh")

	-- Clipboard

	hl.exec_cmd("wl-paste --watch cliphist store")

	-- Future Startup Programs

	-- hl.exec_cmd("hypridle") hl.exec_cmd("fcitx5")
end)
