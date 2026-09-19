local M = {}

local aurora = require("aurora.theme")

local function theme()
	local c = aurora.colors()

	return {
		normal = {
			a = {
				fg = c.accentForeground,
				bg = c.accent,
				gui = "bold",
			},
			b = {
				fg = c.text,
				bg = c.surface,
			},
			c = {
				fg = c.text,
				bg = c.surface,
			},
			x = {
				fg = c.textSecondary,
				bg = c.surface,
			},
			y = {
				fg = c.textSecondary,
				bg = c.surface,
			},
			z = {
				fg = c.accentForeground,
				bg = c.accent,
				gui = "bold",
			},
		},

		insert = {
			a = {
				fg = c.accentForeground,
				bg = c.success,
				gui = "bold",
			},
			b = {
				fg = c.text,
				bg = c.surface,
			},
			c = {
				fg = c.text,
				bg = c.surface,
			},
			x = {
				fg = c.textSecondary,
				bg = c.surface,
			},
			y = {
				fg = c.textSecondary,
				bg = c.surface,
			},
			z = {
				fg = c.accentForeground,
				bg = c.success,
				gui = "bold",
			},
		},

		visual = {
			a = {
				fg = c.accentForeground,
				bg = c.info,
				gui = "bold",
			},
			b = {
				fg = c.text,
				bg = c.surface,
			},
			c = {
				fg = c.text,
				bg = c.surface,
			},
			x = {
				fg = c.textSecondary,
				bg = c.surface,
			},
			y = {
				fg = c.textSecondary,
				bg = c.surface,
			},
			z = {
				fg = c.accentForeground,
				bg = c.info,
				gui = "bold",
			},
		},

		replace = {
			a = {
				fg = c.accentForeground,
				bg = c.warning,
				gui = "bold",
			},
			b = {
				fg = c.text,
				bg = c.surface,
			},
			c = {
				fg = c.text,
				bg = c.surface,
			},
			x = {
				fg = c.textSecondary,
				bg = c.surface,
			},
			y = {
				fg = c.textSecondary,
				bg = c.surface,
			},
			z = {
				fg = c.accentForeground,
				bg = c.warning,
				gui = "bold",
			},
		},

		command = {
			a = {
				fg = c.accentForeground,
				bg = c.accent,
				gui = "bold",
			},
			b = {
				fg = c.text,
				bg = c.surface,
			},
			c = {
				fg = c.text,
				bg = c.surface,
			},
			x = {
				fg = c.textSecondary,
				bg = c.surface,
			},
			y = {
				fg = c.textSecondary,
				bg = c.surface,
			},
			z = {
				fg = c.accentForeground,
				bg = c.accent,
				gui = "bold",
			},
		},

		inactive = {
			a = {
				fg = c.textMuted,
				bg = "NONE",
			},
			b = {
				fg = c.textMuted,
				bg = "NONE",
			},
			c = {
				fg = c.textMuted,
				bg = "NONE",
			},
			x = {
				fg = c.textMuted,
				bg = "NONE",
			},
			y = {
				fg = c.textMuted,
				bg = "NONE",
			},
			z = {
				fg = c.textMuted,
				bg = "NONE",
			},
		},
	}
end

local function lsp()
	local clients = vim.lsp.get_clients({
		bufnr = 0,
	})

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

			section_separators = "",
			component_separators = "",

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
					fmt = function(mode)
						return mode:sub(1, 1)
					end,
				},
			},

			lualine_b = {
				"diagnostics",
			},

			lualine_c = {
				{
					"filename",
					path = 3,
					shorting_target = 0,
					symbols = {
						modified = " ●",
						readonly = " ",
						unnamed = "[No Name]",
						newfile = "[New]",
					},
				},
			},

			lualine_x = {
				lsp,
				"filetype",
			},

			lualine_y = {
				"progress",
			},

			lualine_z = {
				"location",
			},
		},

		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = {
				"filename",
			},
			lualine_x = {
				"location",
			},
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
