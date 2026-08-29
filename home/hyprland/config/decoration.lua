-- Decoration

-- Load Active Aurora Theme

local home = os.getenv("HOME")

local themePath = home .. "/.config/aurora/active-theme.lua"

local ok, theme = pcall(dofile, themePath)

if not ok or not theme then
	local fallback = home .. "/.config/aurora/themes/catppuccin-mocha.lua"

	ok, theme = pcall(dofile, fallback)
end

if not ok or not theme then
	error("Aurora: unable to load theme in decoration.lua")
end

local ui = theme.ui

local shadowAlpha = string.format("%02x", math.floor((ui.shadowOpacity or 0.20) * 255 + 0.5))

hl.config({

	decoration = {

		-- dim_inactive is off on purpose: inactive_opacity below already signals focus.
		dim_inactive = false,
		dim_around = 0.30,
		dim_special = 0.20,
		dim_strength = 0.1,

		-- Rounded Corners

		rounding = ui.radius or 10,

		rounding_power = 2,

		-- Window Opacity

		active_opacity = 1.0,

		inactive_opacity = ui.windowOpacity or 0.96,

		-- Shadows

		shadow = {
			enabled = true,
			range = 18,
			render_power = 4,
			sharp = false,
			color = "rgba(000000" .. shadowAlpha .. ")",
		},

		-- Blur

		blur = {
			enabled = true,
			size = 12,
			passes = 4,
			vibrancy = 0.35,
			vibrancy_darkness = 0.50,
			brightness = 0.35,
			contrast = 1.0,
			noise = 0.015,
			popups = true,
			special = 0,
			new_optimizations = true,
			ignore_opacity = true,
			xray = true,
		},
	},
})
