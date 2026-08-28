local home = os.getenv("HOME")

local activeThemePath = home .. "/.config/aurora/active-theme.lua"

local fallbackThemePath = home .. "/.config/aurora/themes/catppuccin-mocha.lua"


local ok = false
local theme = nil


local activeFile = io.open(activeThemePath, "r")

if activeFile then
	activeFile:close()

	ok, theme = pcall(dofile, activeThemePath)
end


if not ok or not theme then
	ok, theme = pcall(dofile, fallbackThemePath)
end


if not ok or not theme then
	error(
		"Aurora: unable to load theme.\n"
			.. "Active theme: "
			.. activeThemePath
			.. "\n"
			.. "Fallback theme: "
			.. fallbackThemePath
	)
end


local function stripHash(color)
	if color == nil then
		return "000000"
	end

	return color:gsub("^#", "")
end


local function rgba(color, alpha)
	return "rgba(" .. stripHash(color) .. alpha .. ")"
end


local colors = theme.colors


hl.config({

	general = {

		col = {


			active_border = {

				colors = {

					rgba(colors.accent, "ff"),

					rgba(colors.accentActive, "ff"),
				},

				angle = 45,
			},


			inactive_border = rgba(colors.border, "cc"),
		},
	},
})
