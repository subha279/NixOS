--------------------------------------------------
-- Decoration
-- https://wiki.hypr.land/Configuring/Variables/
--------------------------------------------------

hl.config({

	decoration = {

		dim_inactive = true,
		dim_around = 0.30,
		dim_special = 0.20,
		dim_strength = 0.1,

		--------------------------------------------------
		-- Rounded Corners
		--------------------------------------------------

		rounding = 10,

		rounding_power = 2,

		--------------------------------------------------
		-- Window Opacity
		--------------------------------------------------

		active_opacity = 1.0,

		inactive_opacity = 0.96,

		--------------------------------------------------
		-- Shadows
		--------------------------------------------------

		shadow = {
			enabled = true,
			range = 18,
			render_power = 4,
			sharp = false,
            color = "rgba(00000018)",
		},

		--------------------------------------------------
		-- Blur
		--------------------------------------------------

		blur = {
			enabled = true,
			size = 4,
			passes = 5,
			vibrancy = 0.1685,
			brightness = 0.88,
			noise = 0.02,
			contrast = 0.9,
			popups = 0,
			special = 0,
			new_optimizations = true,
			ignore_opacity = true,
			xray = true,
		},
	},
})

-- hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
