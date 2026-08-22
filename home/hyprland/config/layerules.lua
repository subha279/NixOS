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

-- Removed a duplicate rule that also matched namespace ^launcher$. It set
-- the same blur/ignore_alpha as launcher-glass above but omitted order and
-- blur_popups, so the later rule could clobber the layer ordering.
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
