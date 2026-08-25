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
		--
		-- The backdrop half of the liquid glass. A QML item cannot sample what is
		-- behind a Wayland layer surface, so everything actually blurry about the
		-- shell -- and about kitty, now that it runs translucent -- happens here.

		blur = {
			enabled = true,

			-- Fewer, wider passes: size 6 / 3 passes lands on about the same
			-- visual radius as size 4 / 5 for half the fragment work, which
			-- matters on this host at vrr = 2.
			size = 6,
			passes = 3,

			-- The main lever between frosted and liquid: frost desaturates what it
			-- scatters, a lens carries colour through.
			vibrancy = 0.32,

			-- Holding the shadows down is the wrong lever when the complaint is
			-- that nothing shows through -- the muddiness was the dark backdrop
			-- itself.
			vibrancy_darkness = 0.0,

			-- Above 1.0 the blur returns more light than it received, which is what
			-- frosted glass does: it scatters forwards rather than swallowing. Also
			-- scales the transmitted structure, so the wallpaper's shape reads ~14%
			-- more strongly, not just brighter. Applies to every blurred surface, so
			-- kitty and the shell lighten together and stay matched.
			brightness = 1.05,
			contrast = 1.0,

			-- Down from 0.055: noise is the matte half of the material and now
			-- fights the gloss. Enough to keep wide gradients from banding and to
			-- cover the ungrained band inside each rounded corner, not enough to
			-- read as texture.
			noise = 0.02,

			-- xdg popups (kitty and GTK menus) were the one surface class left
			-- unblurred next to blurred ones. `true` not 1 -- hyprctl reports this
			-- as a bool.
			popups = true,

			special = 0,
			new_optimizations = true,
			ignore_opacity = true,
			xray = true,
		},
	},
})
