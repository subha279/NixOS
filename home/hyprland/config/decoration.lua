-- Decoration

-- Load Active Aurora Theme

local home = os.getenv("HOME")

local themePath = home .. "/.config/aurora/active-theme.lua"

local ok, theme = pcall(dofile, themePath)

if not ok or not theme then
	local fallback = home .. "/.config/aurora/themes/aurora.lua"

	ok, theme = pcall(dofile, fallback)
end

if not ok or not theme then
	error("Aurora: unable to load theme in decoration.lua")
end

local ui = theme.ui

-- themes.nix declares shadowOpacity as 0-1, but Hyprland wants an 8-digit
-- rgba() literal. Convert once here instead of hardcoding "18" (= 0.094),
-- which silently halved the declared 0.20.
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

		-- Was hardcoded 0.96; themes.nix already declares windowOpacity.
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

			-- Fewer, wider passes: size 8 / 3 passes lands on roughly the same
			-- visual radius as size 4 / 5 passes for about half the fragment
			-- work, which matters on the laptop host with vrr = 2.
			size = 6,
			passes = 3,
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
