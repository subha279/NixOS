-- Decoration

-- Load Active Aurora Theme

local home = os.getenv("HOME")

local themePath = home .. "/.config/aurora/active-theme.lua"

local ok, theme = pcall(dofile, themePath)

if not ok or not theme then
	-- Must name a theme that lib/themes.nix actually defines. This used to point
	-- at themes/aurora.lua, which is never generated, so the fallback missed too
	-- and the error() below took the whole Hyprland config down.
	local fallback = home .. "/.config/aurora/themes/catppuccin-mocha.lua"

	ok, theme = pcall(dofile, fallback)
end

if not ok or not theme then
	error("Aurora: unable to load theme in decoration.lua")
end

local ui = theme.ui

-- themes.nix declares shadowOpacity as 0-1; Hyprland wants an 8-digit rgba()
-- literal. Convert once rather than hardcoding a hex pair that drifts from it.
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
			size = 8,
			passes = 3,
			vibrancy = 0.18,
			vibrancy_darkness = 0.0,
			brightness = 1.0,
			contrast = 1.8,
			noise = 0.01,
			popups = true,
			special = 0,
			new_optimizations = true,
			ignore_opacity = true,
			xray = true,
		},
	},
})
