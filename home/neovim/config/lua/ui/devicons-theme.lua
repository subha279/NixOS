-- Aurora DevIcons Theme

local M = {}

-- Theme Loader

local function get_theme()
	local path = vim.fn.expand("~/.config/aurora/active-theme.lua")

	local ok, theme = pcall(dofile, path)

	if not ok or type(theme) ~= "table" then
		return nil
	end

	if type(theme.colors) ~= "table" then
		return nil
	end

	return theme
end

-- Apply

function M.setup()
	local theme = get_theme()

	if not theme then
		return
	end

	local c = theme.colors

	-- NvimTree Folder Icons

	vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", {
		fg = c.accent,
	})

	vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderIcon", {
		fg = c.accentHover,
	})

	vim.api.nvim_set_hl(0, "NvimTreeSymlinkIcon", {
		fg = c.info,
	})

	-- NvimTree Git Icons

	vim.api.nvim_set_hl(0, "NvimTreeGitNewIcon", {
		fg = c.success,
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitDirtyIcon", {
		fg = c.warning,
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitDeletedIcon", {
		fg = c.error,
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitStagedIcon", {
		fg = c.success,
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitRenamedIcon", {
		fg = c.info,
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitMergeIcon", {
		fg = c.error,
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitIgnoredIcon", {
		fg = c.textMuted,
	})

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

	-- Apply colors to every registered icon

	local index = 1

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
				vim.api.nvim_set_hl(0, group_name, {
					fg = palette[index],
				})

				index = index + 1

				if index > #palette then
					index = 1
				end
			end
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
