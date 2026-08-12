------------------------------
---Layer Rules
------------------------------

-- Blur Rofi
hl.layer_rule({
	name = "rofi",
	match = {
		namespace = "rofi",
	},
	blur = true,
})

hl.exec_cmd("hyprctl keyword layerrule 'blur,aurora-bar'")
hl.exec_cmd("hyprctl keyword layerrule 'ignorezero,aurora-bar'")

--------------------------------------------------
-- Fuzzel
--------------------------------------------------

hl.layer_rule({
	name = "fuzzel-glass",
	match = {
		namespace = "^fuzzel$",
	},

	blur = true,
	blur_popups = true,

	-- Ignore completely transparent pixels.
	ignore_alpha = 0.35,

	-- Keep launcher above normal layers.
	order = 10,
})
