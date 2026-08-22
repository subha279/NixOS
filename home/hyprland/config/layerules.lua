-- ==========================================================
-- Aurora Hyprland Layer Rules
-- ==========================================================

-- ==========================================================
-- Aurora Launcher
-- ==========================================================
--
-- Covers all three Quickshell dmenu surfaces: the application
-- launcher, the wallpaper picker and the colorscheme picker. They
-- share the aurora-launcher namespace, so one rule styles them all.
--
-- ==========================================================

hl.layer_rule({
	name = "launcher-glass",

	match = {
		namespace = "^aurora-launcher$",
	},

	-- Blur the card, not the screen.
	--
	-- These surfaces are fullscreen so that clicking outside can
	-- dismiss them. ignore_alpha means Hyprland only blurs pixels
	-- whose alpha is at or above 0.20, so:
	--
	--   launcher card   glassOpacity 0.80  -> frosted
	--   dim scrim       scrimAlpha   0.12  -> left sharp
	--
	-- That is what keeps the blur inside the popup instead of
	-- smearing the whole desktop. The scrim value lives in
	-- LauncherSurface.qml and must stay below this threshold.
	--
	-- Same trick the bar already uses: a full-width layer where
	-- only the opaque pill is blurred.
	blur = true,
	blur_popups = true,

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
