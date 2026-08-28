-- Aurora DevIcons Theme

local M = {}

-- Theme Loader

local aurora = require("aurora.theme")

-- Apply

function M.setup()
	local theme = aurora.get()

	if not theme then
		return
	end

	local c = theme.colors

	-- nvim-web-devicons

	local ok, devicons = pcall(require, "nvim-web-devicons")

	if not ok then
		return
	end

	local icons = devicons.get_icons()

	if type(icons) ~= "table" then
		return
	end

	-- Semantic Aurora icon palette

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

			-- Newer nvim-web-devicons versions provide the highlight name.
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

	-- Important development files

	local important = {

		-- Nix
		DevIconNix = c.info,

		-- Lua
		DevIconLua = c.terminalBlue,

		-- Rust
		DevIconRs = c.warning,

		-- C / C++
		DevIconC = c.terminalBlue,
		DevIconCpp = c.terminalBlue,
		DevIconH = c.terminalBlue,
		DevIconHpp = c.terminalBlue,

		-- Python
		DevIconPy = c.terminalBlue,

		-- JavaScript
		DevIconJs = c.warning,
		DevIconJsx = c.warning,

		-- TypeScript
		DevIconTs = c.info,
		DevIconTsx = c.info,

		-- Web
		DevIconHtml = c.terminalRed,
		DevIconCss = c.terminalBlue,
		DevIconScss = c.terminalMagenta,

		-- Data/config
		DevIconJson = c.warning,
		DevIconJsonc = c.warning,
		DevIconYaml = c.warning,
		DevIconYml = c.warning,
		DevIconToml = c.warning,

		-- Shell
		DevIconSh = c.success,
		DevIconBash = c.success,
		DevIconZsh = c.success,

		-- Git
		DevIconGit = c.error,
		DevIconGitIgnore = c.textMuted,

		-- Docker
		DevIconDockerfile = c.info,

		-- Markdown
		DevIconMarkdown = c.info,
		DevIconMd = c.info,

		-- Vim
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
