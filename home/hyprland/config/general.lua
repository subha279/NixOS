--------------------------------------------------
-- General Configuration
-- https://wiki.hypr.land/Configuring/Variables/
--------------------------------------------------

local home = os.getenv("HOME")

local runtime_colors = home .. "/.cache/wallust/colors.lua"

local ok, wallust = pcall(dofile, runtime_colors)

local colors

if ok and wallust then
	colors = wallust
else
	colors = require("stylix-colors")
end

local active_border = colors.color14
local inactive_border = colors.color8

hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 10,

		border_size = 2,

		["col.active_border"] = active_border,
		["col.inactive_border"] = inactive_border,

		resize_on_border = true,

		allow_tearing = false,

		layout = "dwindle",
	},
})
