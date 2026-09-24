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

hl.layer_rule({
	name = "sunflower-bar",
	match = {
		namespace = "^sunflower-bar$",
	},
	blur = true,
	blur_popups = true,
	ignore_alpha = 0.20,
	order = 10,
})

-- Sunflower Popups

hl.layer_rule({
	name = "sunflower-popup",
	match = {
		namespace = "^sunflower-popup$",
	},
	blur = true,
	blur_popups = true,
	ignore_alpha = 0.20,
	order = 6,
})

-- Sunflower Notifications

hl.layer_rule({
	name = "sunflower-notifications",
	match = {
		namespace = "^sunflower-notifications$",
	},
	blur = true,
	blur_popups = true,
	ignore_alpha = 0.20,
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
