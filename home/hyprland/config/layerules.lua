--------------------------------------------------
-- Layer Rules
-- Aurora Quickshell Desktop
--------------------------------------------------

--------------------------------------------------
-- Aurora Launcher
--------------------------------------------------
--
-- Used by:
--   • Application launcher
--   • Wallpaper picker
--   • Colorscheme picker
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

	-- Blur only the opaque launcher surface.
	--
	-- Transparent scrim remains sharp so the wallpaper
	-- does not become unnecessarily blurred.
	ignore_alpha = 0.20,

	-- Launcher must sit above the rest of the shell.
	order = 10,
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
