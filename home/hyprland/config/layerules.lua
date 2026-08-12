------------------------------
---Layer Rules
------------------------------

-- ==========================================================
-- Fuzzel
-- ==========================================================

hl.layer_rule({
	name = "launcher-glass",

	match = {
		namespace = "^launcher$",
	},

	blur = true,
	blur_popups = true,

	-- Blur transparent regions while keeping the UI readable.
	ignore_alpha = 0.20,

	-- Keep launcher above other normal layers.
	order = 10,
})

-- ==========================================================
-- Quickshell
-- ==========================================================

hl.layer_rule({
	name = "quickshell-glass",

	match = {
		namespace = "^quickshell$",
	},

	blur = true,
	blur_popups = true,

	ignore_alpha = 0.20,

	order = 5,
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
-- Notifications
-- ==========================================================

hl.layer_rule({
	name = "notification-glass",

	match = {
		namespace = "^(swaync|notifications?)$",
	},

	blur = true,
	blur_popups = true,

	ignore_alpha = 0.20,

	order = 8,
})

-- ==========================================================
-- Existing Aurora Bar compatibility
-- ==========================================================

hl.exec_cmd("hyprctl keyword layerrule 'blur,aurora-bar'")
hl.exec_cmd("hyprctl keyword layerrule 'ignorezero,aurora-bar'")
