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
	local s = c.syntax

	if type(s) ~= "table" then
		return
	end

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
	--
	-- Used only for icons that do not have an explicit
	-- language/filetype color below.

	local palette = {
		s.func,
		s.property,
		s.type,
		s.string,
		s.number,
		s.keyword,
		s.namespace,
		s.builtin,
		s.attribute,
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

	-- Important development files

	local important = {
		-- Nix
		DevIconNix = s.namespace,

		-- Lua
		DevIconLua = s.func,

		-- Rust
		DevIconRs = s.type,

		-- C / C++
		DevIconC = s.type,
		DevIconCpp = s.type,
		DevIconH = s.type,
		DevIconHpp = s.type,

		-- Python
		DevIconPy = s.func,

		-- JavaScript
		DevIconJs = s.constant,
		DevIconJsx = s.constant,

		-- TypeScript
		DevIconTs = s.type,
		DevIconTsx = s.type,

		-- Web
		DevIconHtml = s.tag,
		DevIconCss = s.property,
		DevIconScss = s.special,

		-- Data / config
		DevIconJson = s.number,
		DevIconJsonc = s.number,
		DevIconYaml = s.attribute,
		DevIconYml = s.attribute,
		DevIconToml = s.attribute,

		-- Shell
		DevIconSh = s.builtin,
		DevIconBash = s.builtin,
		DevIconZsh = s.builtin,

		-- Git
		DevIconGit = c.error,
		DevIconGitIgnore = s.comment,

		-- Docker
		DevIconDockerfile = s.namespace,

		-- Markdown
		DevIconMarkdown = s.keyword,
		DevIconMd = s.keyword,

		-- Vim
		DevIconVim = s.keyword,
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
