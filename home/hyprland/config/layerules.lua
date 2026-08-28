hl.layer_rule({
	name = "wallpaper",

	match = {
		namespace = "^(awww-daemon|awww|swww-daemon|wallpaper)$",
	},

	blur = false,

	order = 1,
})


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


hl.layer_rule({
	name = "aurora-launcher",

	match = {
		namespace = "^aurora-launcher$",
	},

	blur = true,

	blur_popups = true,

	ignore_alpha = 0.20,

	order = 10,
})


hl.layer_rule({
	name = "screen-capture",

	match = {
		namespace = "^(selection|slurp|grim|hyprpicker|swappy)$",
	},

	blur = false,

	xray = true,

	order = 15,
})
