-- General Configuration

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
	error("Aurora: unable to load theme in general.lua")
end

local ui = theme.ui

-- General

hl.config({

	general = {

		-- Gaps

		-- Keep gaps_in >= rounding/2, otherwise the rounded corners of
		-- adjacent tiles pinch together and the two 2px borders sitting
		-- in a 2px gap visually collide.
		gaps_in = 5,

		gaps_out = 10,

		-- Borders

		border_size = ui.borderWidth,

		-- Resize

		resize_on_border = true,

		-- Tearing

		allow_tearing = false,

		-- Layout

		layout = "dwindle",
	},
})
