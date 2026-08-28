local M = {}


local aurora = require("aurora.theme")


function M.setup()
	local theme = aurora.get()

	if not theme then
		return
	end

	local c = theme.colors


	local ok, devicons = pcall(require, "nvim-web-devicons")

	if not ok then
		return
	end

	local icons = devicons.get_icons()

	if type(icons) ~= "table" then
		return
	end


	local palette = {
		c.accent,
		c.info,
		c.success,
		c.warning,
		c.terminalMagenta,
		c.terminalCyan,
		c.terminalBlue,
		c.terminalGreen,
		c.terminalYellow,
	}


	local group_names = {}

	for name, icon in pairs(icons) do
		if type(icon) == "table" then
			local group_name

			if type(icon.name) == "string" then
				group_name = "DevIcon" .. icon.name
			elseif type(name) == "string" then
				group_name = "DevIcon" .. name
			end

			if group_name then
				group_names[#group_names + 1] = group_name
			end
		end
	end

	table.sort(group_names)

	local index = 1

	for _, group_name in ipairs(group_names) do
		vim.api.nvim_set_hl(0, group_name, {
			fg = palette[index],
		})

		index = index + 1

		if index > #palette then
			index = 1
		end
	end


	local important = {

		DevIconNix = c.info,

		DevIconLua = c.terminalBlue,

		DevIconRs = c.warning,

		DevIconC = c.terminalBlue,
		DevIconCpp = c.terminalBlue,
		DevIconH = c.terminalBlue,
		DevIconHpp = c.terminalBlue,

		DevIconPy = c.terminalBlue,

		DevIconJs = c.warning,
		DevIconJsx = c.warning,

		DevIconTs = c.info,
		DevIconTsx = c.info,

		DevIconHtml = c.terminalRed,
		DevIconCss = c.terminalBlue,
		DevIconScss = c.terminalMagenta,

		DevIconJson = c.warning,
		DevIconJsonc = c.warning,
		DevIconYaml = c.warning,
		DevIconYml = c.warning,
		DevIconToml = c.warning,

		DevIconSh = c.success,
		DevIconBash = c.success,
		DevIconZsh = c.success,

		DevIconGit = c.error,
		DevIconGitIgnore = c.textMuted,

		DevIconDockerfile = c.info,

		DevIconMarkdown = c.info,
		DevIconMd = c.info,

		DevIconVim = c.success,
	}

	for group, color in pairs(important) do
		if color then
			vim.api.nvim_set_hl(0, group, {
				fg = color,
			})
		end
	end
end

return M
