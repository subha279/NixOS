hl.on("hyprland.start", function()

	hl.exec_cmd(
		"dbus-update-activation-environment --systemd "
			.. "WAYLAND_DISPLAY "
			.. "XDG_CURRENT_DESKTOP "
			.. "XDG_SESSION_TYPE "
			.. "XDG_SESSION_DESKTOP "
			.. "HYPRLAND_INSTANCE_SIGNATURE "
			.. "&& systemctl --user start hyprland-session.target"
	)


	hl.exec_cmd("nm-applet --indicator")


	hl.exec_cmd("blueman-applet")


	hl.exec_cmd("sleep 1 && ~/.config/hypr/scripts/restore-wallpaper.sh")


end)
