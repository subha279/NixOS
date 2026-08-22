--------------------------------------------------
-- Layer Rules
-- Aurora Quickshell Desktop
--------------------------------------------------
--
-- Every namespace below is declared by a Quickshell
-- surface through WlrLayershell.namespace:
--
--   aurora-bar            modules/Bar.qml
--   aurora-popup          modules/PopupSurface.qml
--   aurora-notifications  modules/Notifications.qml
--   aurora-launcher       modules/LauncherSurface.qml
--
-- order        stacking order within the layer
-- ignore_alpha blur only the opaque part of the
--              surface, so a transparent scrim stays
--              sharp and the wallpaper is not blurred
--              for no reason
--------------------------------------------------

--------------------------------------------------
-- Wallpaper
--------------------------------------------------

hl.layer_rule({
	name = "wallpaper",

	match = {
		namespace = "^(awww-daemon|awww|swww-daemon|wallpaper)$",
	},

	blur = false,

	order = 1,
})

--------------------------------------------------
-- Aurora Bar
--------------------------------------------------

hl.layer_rule({
	name = "aurora-bar",

	match = {
		namespace = "^aurora-bar$",
	},

	blur = true,

	blur_popups = true,

	ignore_alpha = 0.20,

	order = 5,
})

--------------------------------------------------
-- Aurora Popups
--------------------------------------------------

hl.layer_rule({
	name = "aurora-popup",

	match = {
		namespace = "^aurora-popup$",
	},

	blur = true,

	blur_popups = true,

	ignore_alpha = 0.20,

	order = 6,
})

--------------------------------------------------
-- Aurora Notifications
--------------------------------------------------

hl.layer_rule({
	name = "aurora-notifications",

	match = {
		namespace = "^aurora-notifications$",
	},

	blur = true,

	blur_popups = true,

	ignore_alpha = 0.20,

	order = 8,
})

--------------------------------------------------
-- Aurora Launcher
--------------------------------------------------

hl.layer_rule({
	name = "aurora-launcher",

	match = {
		namespace = "^aurora-launcher$",
	},

	blur = true,

	blur_popups = true,

	ignore_alpha = 0.20,

	-- Launcher must sit above the rest of the shell.
	order = 10,
})

--------------------------------------------------
-- Screen Capture and Colour Picking
--------------------------------------------------

hl.layer_rule({
	name = "screen-capture",

	match = {
		namespace = "^(selection|slurp|grim|hyprpicker|swappy)$",
	},

	blur = false,

	xray = true,

	order = 15,
})
