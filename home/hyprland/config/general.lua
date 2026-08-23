-- General Configuration

-- Load Active Aurora Theme

local home = os.getenv("HOME")

local themePath = home .. "/.config/aurora/active-theme.lua"

local ok, theme = pcall(dofile, themePath)

if not ok or not theme then
	local fallback = home .. "/.config/aurora/themes/aurora.lua"

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
