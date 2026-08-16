-- ==========================================================
-- Aurora Hyprland Layer Rules
-- ==========================================================

-- ==========================================================
-- Fuzzel / Application + Wallpaper Launcher
-- ==========================================================

hl.layer_rule({
	name = "launcher-glass",

	match = {
		namespace = "^launcher$",
	},

	blur = true,
	blur_popups = true,

	-- Blur transparent regions without making the UI muddy.
	ignore_alpha = 0.20,

	-- Keep launcher above other layers.
	order = 10,
})

hl.layer_rule({
	name = "fuzzel",
	match = {
		namespace = "^launcher$",
	},

	blur = true,
	ignore_alpha = 0.20,
})
-- ==========================================================
-- Aurora Bar
-- ==========================================================

hl.layer_rule({
	name = "aurora-bar-glass",

	match = {
		namespace = "^aurora-bar$",
	},

	blur = true,
	blur_popups = true,

	ignore_alpha = 0.20,

	order = 5,
})

-- ==========================================================
-- Aurora Notifications
-- ==========================================================

hl.layer_rule({
	name = "aurora-notifications-glass",

	match = {
		namespace = "^aurora-notifications$",
	},

	blur = true,
	blur_popups = true,

	ignore_alpha = 0.20,

	order = 8,
})
