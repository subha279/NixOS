-- Layer Rules

-- Wallpaper

hl.layer_rule({
	name = "wallpaper",

	match = {
		namespace = "^(awww-daemon|awww|swww-daemon|wallpaper)$",
	},

	blur = false,

	order = 1,
})

-- Aurora Bar
--
-- This layer now carries the launcher popups too: Bar.qml owns the only panel
-- window for the pill and the dmenu-style surfaces, so there is no separate
-- `aurora-launcher` namespace any more. The order is the one the launcher used
-- to have, because an open launcher still has to sit above the notifications.

hl.layer_rule({
	name = "aurora-bar",

	match = {
		namespace = "aurora-bar",
	},

	blur = true,

	blur_popups = true,

	ignore_alpha = 0.01,

	order = 10,
})

-- Aurora Popups

hl.layer_rule({
	name = "aurora-popup",

	match = {
		namespace = "aurora-popup",
	},

	blur = true,

	blur_popups = true,

	ignore_alpha = 0.01,

	order = 6,
})

-- Aurora Notifications

hl.layer_rule({
	name = "aurora-notifications",

	match = {
		namespace = "aurora-notifications",
	},

	blur = true,

	blur_popups = true,

	ignore_alpha = 0.01,

	order = 8,
})

-- Screen Capture and Colour Picking

hl.layer_rule({
	name = "screen-capture",

	match = {
		namespace = "^(selection|slurp|grim|hyprpicker|swappy)$",
	},

	blur = false,

	xray = true,

	order = 15,
})
