-- Aurora Hyprland Theme

-- Paths

local home = os.getenv("HOME")

local activeThemePath = home .. "/.config/aurora/active-theme.lua"

local auroraThemePath = home .. "/.config/aurora/themes/aurora.lua"

-- Load Active Theme

local ok = false
local theme = nil

-- Prefer currently selected theme

local activeFile = io.open(activeThemePath, "r")

if activeFile then
	activeFile:close()

	ok, theme = pcall(dofile, activeThemePath)
end

-- Fallback to Aurora

if not ok or not theme then
	ok, theme = pcall(dofile, auroraThemePath)
end

-- Fail clearly if no theme is available

if not ok or not theme then
	error(
		"Aurora: unable to load theme.\n"
			.. "Active theme: "
			.. activeThemePath
			.. "\n"
			.. "Fallback theme: "
			.. auroraThemePath
	)
end

-- Color Helpers

local function stripHash(color)
	if color == nil then
		return "000000"
	end

	return color:gsub("^#", "")
end

-- Convert #RRGGBB -> rgba(RRGGBBAA)

local function rgba(color, alpha)
	return "rgba(" .. stripHash(color) .. alpha .. ")"
end

-- Theme Colors

local colors = theme.colors

-- Hyprland Theme

hl.config({

	general = {

		col = {

			-- Active Window Border

			active_border = {

				colors = {

					rgba(colors.accent, "ff"),

					rgba(colors.accentActive, "ff"),
				},

				angle = 45,
			},

			-- Inactive Window Border

			inactive_border = rgba(colors.border, "cc"),
		},
	},
})
