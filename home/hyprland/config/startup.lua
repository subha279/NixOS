hl.on("hyprland.start", function()
	--------------------------------------------------
	-- Network
	--------------------------------------------------

	hl.exec_cmd("nm-applet --indicator")

	--------------------------------------------------
	-- Bluetooth
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
	hl.exec_cmd("systemctl --user start desktop-services.target")
	-- hl.exec_cmd("hypridle")
	-- hl.exec_cmd("hyprpaper")
	-- hl.exec_cmd("fcitx5")
end)
