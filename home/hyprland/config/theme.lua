-- ==========================================
-- Hyprland Theme
-- ==========================================

local home = os.getenv("HOME")

local runtime_colors = home .. "/.cache/wallust/colors.lua"

local ok, wallust = pcall(dofile, runtime_colors)

local palette

if ok and wallust then
	palette = wallust
else
	palette = require("stylix-colors")
end

-- ==========================================
-- Theme Colors
-- ==========================================

local colors = {
	background = palette.background,
	foreground = palette.foreground,

	accent = palette.color14,
	accent2 = palette.color13,

	active_border = palette.color14,
	inactive_border = palette.color8,
}
