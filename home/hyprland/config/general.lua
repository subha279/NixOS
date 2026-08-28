local home = os.getenv("HOME")

local themePath = home .. "/.config/aurora/active-theme.lua"

local ok, theme = pcall(dofile, themePath)

if not ok or not theme then
	-- Must be a theme id lib/themes.nix actually defines, or this file errors out.
	local fallback = home .. "/.config/aurora/themes/catppuccin-mocha.lua"

	ok, theme = pcall(dofile, fallback)
end

if not ok or not theme then
	error("Aurora: unable to load theme in general.lua")
end

local ui = theme.ui


hl.config({

	general = {


		gaps_in = 5,

		gaps_out = 10,


		border_size = ui.borderWidth,


		resize_on_border = true,


		allow_tearing = false,


		layout = "dwindle",
	},
})
