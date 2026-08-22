hl.on("hyprland.start", function()
	--------------------------------------------------
	-- Session Environment
	--------------------------------------------------
	--
	-- This has to happen before anything else.
	--
	-- systemd user services and D-Bus activated services do not inherit
	-- the compositor environment. Without this handoff a service starts
	-- with no WAYLAND_DISPLAY, fails to connect to the compositor, and is
	-- restarted forever by Restart=on-failure.
	--
	-- That is exactly what was happening to the notification daemon.
	--
	-- Starting hyprland-session.target then pulls in graphical-session.target,
	-- which brings up quickshell.service, awww-daemon.service and the polkit
	-- agent in the correct order.
	--------------------------------------------------

	hl.exec_cmd(
		"dbus-update-activation-environment --systemd "
			.. "WAYLAND_DISPLAY "
			.. "XDG_CURRENT_DESKTOP "
			.. "XDG_SESSION_TYPE "
			.. "XDG_SESSION_DESKTOP "
			.. "HYPRLAND_INSTANCE_SIGNATURE "
			.. "&& systemctl --user start hyprland-session.target"
	)

	--------------------------------------------------
	-- Network
	--------------------------------------------------
	--
	-- nm-applet raises notifications for connect, disconnect and VPN
	-- state, so the daemon has to be reachable before it starts.
	--------------------------------------------------

	hl.exec_cmd("nm-applet --indicator")

	--------------------------------------------------
	-- Bluetooth
	--------------------------------------------------
	--
	-- Same for blueman-applet: pairing requests and device battery
	-- warnings are delivered as notifications.
	--------------------------------------------------

	hl.exec_cmd("blueman-applet")

	--------------------------------------------------
	-- Wallpaper
	--------------------------------------------------

	hl.exec_cmd("sleep 1 && ~/.config/hypr/scripts/restore-wallpaper.sh")

	--------------------------------------------------
	-- Clipboard
	--------------------------------------------------

	hl.exec_cmd("wl-paste --watch cliphist store")

	--------------------------------------------------
	-- Future Startup Programs
	--------------------------------------------------
	--
	-- desktop-services.target is no longer started by hand. It is
	-- WantedBy graphical-session.target, so systemd orders it for us.
	--------------------------------------------------

	-- hl.exec_cmd("hypridle")
	-- hl.exec_cmd("fcitx5")
end)
