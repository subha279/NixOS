local M = {}

local aurora = require("aurora.theme")

local function theme()
	local c = aurora.colors()

	-- Set transparent backgrounds for inner sections
	local shared = {
		b = { fg = c.text, bg = "NONE" },
		c = { fg = c.text, bg = "NONE" },
		x = { fg = c.textSecondary, bg = "NONE" },
		y = { fg = c.textSecondary, bg = "NONE" },
	}

	local function mode(bg)
		local hl = { fg = c.accentForeground, bg = bg, gui = "bold" }
		return vim.tbl_extend("force", shared, { a = hl, z = hl })
	end

	return {
		normal = mode(c.accent),
		insert = mode(c.success),
		visual = mode(c.info),
		replace = mode(c.warning),
		command = mode(c.accent),

		inactive = {
			a = { fg = c.textMuted, bg = "NONE" },
			b = { fg = c.textMuted, bg = "NONE" },
			c = { fg = c.textMuted, bg = "NONE" },
			x = { fg = c.textMuted, bg = "NONE" },
			y = { fg = c.textMuted, bg = "NONE" },
			z = { fg = c.textMuted, bg = "NONE" },
		},
	}
end

local function lsp()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		return ""
	end

	local names = {}
	for _, client in ipairs(clients) do
		names[#names + 1] = client.name
	end
	table.sort(names)

	return "󰒋 " .. table.concat(names, " · ")
end

function M.setup()
	local ok, lualine = pcall(require, "lualine")
	if not ok then
		return false
	end

	lualine.setup({
		options = {
			theme = theme(),
			globalstatus = true,
			icons_enabled = true,
			section_separators = { left = "", right = "" },
			component_separators = { left = "·", right = "·" },
			disabled_filetypes = {
				"alpha",
				"dashboard",
				"NvimTree",
				"TelescopePrompt",
				"TelescopeResults",
				"lazy",
				"mason",
			},
		},

		sections = {
			lualine_a = {
				{
					"mode",
					fmt = function(m)
						return m:sub(1, 1)
					end,
					separator = { left = vim.fn.nr2char(0xe0b6), right = vim.fn.nr2char(0xe0b4) },
				},
			},
			lualine_b = { "diagnostics" },
			lualine_c = {
				{
					"filename",
					symbols = {
						modified = " ●",
						readonly = " ",
						unnamed = "[No Name]",
						newfile = "[New]",
					},
				},
			},
			lualine_x = { lsp, "filetype" },
			lualine_y = { "progress" },
			lualine_z = {
				{
					"location",
					separator = { left = vim.fn.nr2char(0xe0b6), right = vim.fn.nr2char(0xe0b4) },
				},
			},
		},

		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = { "filename" },
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},

		tabline = {},
		winbar = {},
		extensions = {},
	})

	return true
end

aurora.on_change(function()
	M.setup()
	vim.cmd("redrawstatus!")
end)

return M
