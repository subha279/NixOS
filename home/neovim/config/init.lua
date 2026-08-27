-- Aurora Neovim

-- Leader

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Startup Timer

vim.g.aurora_startup_time = vim.uv.hrtime()

-- Core

require("core.options")
require("core.autocmds")

-- Aurora Theme Manager

require("ui.theme")

-- Native LSP

require("lsp")

-- Completion

require("plugins.blink")

-- Search / Navigation

require("plugins.telescope")

-- Syntax / Treesitter

require("plugins.treesitter")

-- Color Preview

local colorizer_ok, colorizer_error = pcall(function()
	require("colorizer").setup({
		filetypes = {
			"*",
			css = { parsers = { names = { enable = true } } },
			scss = { parsers = { names = { enable = true } } },
			sass = { parsers = { names = { enable = true } } },
			less = { parsers = { names = { enable = true } } },
			html = { parsers = { names = { enable = true } } },
			qml = {
				parsers = {
					names = { enable = true },
					hex = {
						default = true,
						rrggbbaa = false,
						hash_aarrggbb = true,
						aarrggbb = true,
					},
				},
			},
		},
		buftypes = {},
		user_commands = true,
		lazy_load = true,
		options = {
			parsers = {
				names = { enable = false },
				hex = {
					default = true,
					rrggbbaa = true,
					hash_aarrggbb = false,
					aarrggbb = false,
					no_hash = false,
				},
				rgb = { enable = true },
				hsl = { enable = true },
				hwb = { enable = true },
				lab = { enable = true },
				lch = { enable = true },
				oklch = { enable = true },
				css_color = { enable = true },
			},
			display = {
				mode = "background",
				disable_document_color = true,
			},
		},
	})
end)

if not colorizer_ok then
	vim.schedule(function()
		vim.notify("Aurora: Colorizer could not be loaded\n" .. tostring(colorizer_error), vim.log.levels.WARN)
	end)
end

-- File Explorer

require("plugins.nvimtree")

-- Git

require("plugins.gitsigns").setup()

-- Formatting

require("plugins.conform")

-- Linting

require("plugins.lint")

-- Key Discovery

require("plugins.whichkey")

-- Statusline

require("plugins.lualine").setup()

-- Utility UI

require("plugins.snacks")

-- Dashboard

require("plugins.alpha")

-- Core Keymaps

require("core.keymaps")
