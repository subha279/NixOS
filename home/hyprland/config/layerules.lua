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
--
-- Bottom layer. Never blurred: it is the thing
-- everything else is blurring against.
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
--
-- This rule did not exist.
--
-- Every panel that drops out of the bar shares the
-- aurora-popup namespace, from PopupSurface.qml:
--
--   network
--   bluetooth
--   battery
--   audio
--   calendar
--   notification centre
--
-- With nothing matching them they were the only
-- Aurora surfaces rendering unblurred, which is why
-- they looked flat next to the bar they hang off.
--
-- Sits above the bar and below notifications.
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
--
-- Above the popups so a toast is never hidden behind
-- an open panel, below the launcher so it cannot
-- cover the search field.
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
--
-- Used by:
--   * Application launcher
--   * Wallpaper picker
--   * Colorscheme picker
--
-- All three share the aurora-launcher namespace.
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
--
-- grim, slurp and swappy are installed. Their
-- overlays must show the screen exactly as it is, so
-- blur is explicitly off and xray keeps windows
-- visible through the selection.
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
