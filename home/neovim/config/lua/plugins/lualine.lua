-- ============================================================================
-- Aurora Lualine
-- ============================================================================
--
-- Minimal • Information-rich • Glass-friendly • Aurora-native
--
-- Theme source:
--
--     ~/.config/aurora/active-theme.lua
--
-- Features:
--
--   • Live Aurora theme switching
--   • Git branch / diff
--   • Diagnostics
--   • LSP clients
--   • Project / file
--   • Search count
--   • Macro recording
--   • File encoding
--   • Filetype
--   • Progress / location
--   • Clock
--
-- IMPORTANT:
--
-- Lualine intentionally avoids a large opaque background.
-- Hyprland is responsible for the glass / blur effect.
--
-- ============================================================================

local M = {}

-- ============================================================================
-- Theme
-- ============================================================================

local function get_theme()
	local path = vim.fn.expand("~/.config/aurora/active-theme.lua")

	local ok, theme = pcall(dofile, path)

	if not ok then
		return nil
	end

	if type(theme) ~= "table" then
		return nil
	end

	if type(theme.colors) ~= "table" then
		return nil
	end

	return theme
end

local function colors()
	local theme = get_theme()

	if theme and theme.colors then
		return theme.colors
	end

	return {}
end

-- ============================================================================
-- Safe Color Helpers
-- ============================================================================

local function color(name, fallback)
	local c = colors()

	return c[name] or fallback
end

local function fg(name)
	return color(name, nil)
end

-- ============================================================================
-- Project
-- ============================================================================

local function cwd()
	local dir = vim.fn.getcwd()

	if dir == "" then
		return ""
	end

	local home = vim.fn.expand("~")

	if dir == home then
		return "󰋜 ~"
	end

	if vim.startswith(dir, home .. "/") then
		dir = "~" .. dir:sub(#home + 1)
	end

	local tail = vim.fn.fnamemodify(dir, ":t")

	if tail == "" then
		return dir
	end

	return "󰉋 " .. tail
end

-- ============================================================================
-- LSP
-- ============================================================================

local function lsp_clients()
	local clients = vim.lsp.get_clients({
		bufnr = 0,
	})

	if #clients == 0 then
		return ""
	end

	local names = {}

	for _, client in ipairs(clients) do
		if client.name and client.name ~= "" then
			names[#names + 1] = client.name
		end
	end

	if #names == 0 then
		return ""
	end

	table.sort(names)

	return "󰒋 " .. table.concat(names, ", ")
end

-- ============================================================================
-- Search
-- ============================================================================

local function search_count()
	local ok, result = pcall(vim.fn.searchcount, {
		maxcount = 999,
		timeout = 100,
	})

	if not ok or type(result) ~= "table" then
		return ""
	end

	if not result.total or result.total == 0 then
		return ""
	end

	if not result.current or result.current == 0 then
		return ""
	end

	return string.format("󰍉 %d/%d", result.current, result.total)
end

-- ============================================================================
-- File State
-- ============================================================================

local function file_state()
	local parts = {}

	if vim.bo.modified then
		parts[#parts + 1] = "●"
	end

	if vim.bo.readonly then
		parts[#parts + 1] = ""
	end

	if vim.bo.modifiable == false then
		parts[#parts + 1] = "󰌾"
	end

	return table.concat(parts, " ")
end

-- ============================================================================
-- Macro Recording
-- ============================================================================

local function recording()
	local reg = vim.fn.reg_recording()

	if reg == "" then
		return ""
	end

	return "󰑋 @" .. reg
end

-- ============================================================================
-- Mode
-- ============================================================================

local mode_map = {
	n = "NORMAL",
	no = "NORMAL",
	nov = "NORMAL",
	noV = "NORMAL",
	["no\22"] = "NORMAL",

	i = "INSERT",
	ic = "INSERT",
	ix = "INSERT",

	v = "VISUAL",
	vs = "VISUAL",

	V = "V-LINE",
	Vs = "V-LINE",

	["\22"] = "V-BLOCK",
	["\22s"] = "V-BLOCK",

	c = "COMMAND",
	cv = "EX",
	ce = "EX",

	R = "REPLACE",
	Rv = "REPLACE",

	s = "SELECT",
	S = "S-LINE",
	["\19"] = "S-BLOCK",

	t = "TERMINAL",
}

local function mode()
	local current = vim.fn.mode()

	return mode_map[current] or current:upper()
end

-- ============================================================================
-- Mode Color
-- ============================================================================

local function mode_color()
	local current = vim.fn.mode()
	local c = colors()

	if current == "i" or current == "ic" or current == "ix" then
		return {
			fg = c.accentForeground,
			bg = c.success,
			gui = "bold",
		}
	end

	if current == "v" or current == "V" or current == "\22" or current == "vs" or current == "Vs" then
		return {
			fg = c.accentForeground,
			bg = c.info,
			gui = "bold",
		}
	end

	if current == "R" or current == "Rv" then
		return {
			fg = c.accentForeground,
			bg = c.warning,
			gui = "bold",
		}
	end

	if current == "c" or current == "cv" or current == "ce" then
		return {
			fg = c.accentForeground,
			bg = c.accentHover or c.accent,
			gui = "bold",
		}
	end

	return {
		fg = c.accentForeground,
		bg = c.accent,
		gui = "bold",
	}
end

-- ============================================================================
-- Dynamic Theme
-- ============================================================================

local function build_theme()
	local c = colors()

	return {
		normal = {
			a = mode_color(),

			b = {
				fg = c.text,
				bg = "NONE",
			},

			c = {
				fg = c.textSecondary,
				bg = "NONE",
			},

			x = {
				fg = c.textSecondary,
				bg = "NONE",
			},

			y = {
				fg = c.text,
				bg = "NONE",
			},

			z = {
				fg = c.textSecondary,
				bg = "NONE",
			},
		},

		insert = {
			a = mode_color(),

			b = {
				fg = c.text,
				bg = "NONE",
			},

			c = {
				fg = c.textSecondary,
				bg = "NONE",
			},
		},

		visual = {
			a = mode_color(),

			b = {
				fg = c.text,
				bg = "NONE",
			},

			c = {
				fg = c.textSecondary,
				bg = "NONE",
			},
		},

		replace = {
			a = mode_color(),

			b = {
				fg = c.text,
				bg = "NONE",
			},

			c = {
				fg = c.textSecondary,
				bg = "NONE",
			},
		},

		command = {
			a = mode_color(),

			b = {
				fg = c.text,
				bg = "NONE",
			},

			c = {
				fg = c.textSecondary,
				bg = "NONE",
			},
		},

		select = {
			a = mode_color(),

			b = {
				fg = c.text,
				bg = "NONE",
			},

			c = {
				fg = c.textSecondary,
				bg = "NONE",
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

-- ============================================================================
-- Configuration
-- ============================================================================

local function build_config()
	local c = colors()

	return {
		options = {
			theme = build_theme(),

			globalstatus = true,

			disabled_filetypes = {
				statusline = {
					"dashboard",
					"alpha",
					"starter",
					"NvimTree",
					"neo-tree",
					"TelescopePrompt",
					"TelescopeResults",
					"lazy",
					"mason",
				},
			},

			section_separators = {
				left = "",
				right = "",
			},

			component_separators = {
				left = "│",
				right = "│",
			},

			always_divide_middle = true,

			always_show_tabline = false,

			refresh = {
				statusline = 1000,
				tabline = 1000,
				winbar = 1000,
			},
		},

		-- ======================================================================
		-- LEFT
		-- ======================================================================

		sections = {
			lualine_a = {
				{
					mode,

					color = mode_color,

					padding = {
						left = 1,
						right = 1,
					},
				},
			},

			lualine_b = {
				{
					"branch",

					icon = "󰘬",

					color = {
						fg = c.accent,
						bg = "NONE",
						gui = "bold",
					},

					padding = {
						left = 1,
						right = 1,
					},
				},

				{
					"diff",

					symbols = {
						added = "＋",
						modified = "～",
						removed = "－",
					},

					diff_color = {
						added = {
							fg = c.success,
						},

						modified = {
							fg = c.warning,
						},

						removed = {
							fg = c.error,
						},
					},

					padding = {
						left = 0,
						right = 1,
					},
				},

				{
					"diagnostics",

					sources = {
						"nvim_diagnostic",
					},

					symbols = {
						error = "󰅚 ",
						warn = "󰀪 ",
						info = "󰋽 ",
						hint = "󰌵 ",
					},

					diagnostics_color = {
						error = {
							fg = c.error,
						},

						warn = {
							fg = c.warning,
						},

						info = {
							fg = c.info,
						},

						hint = {
							fg = c.success,
						},
					},

					padding = {
						left = 0,
						right = 1,
					},
				},
			},

			-- ==================================================================
			-- CENTER
			-- ==================================================================

			lualine_c = {
				{
					cwd,

					color = {
						fg = c.textMuted,
						bg = "NONE",
					},

					padding = {
						left = 0,
						right = 1,
					},
				},

				{
					"filename",

					path = 1,

					shorting_target = 40,

					symbols = {
						modified = " ●",
						readonly = " ",
						unnamed = "[No Name]",
					},

					color = {
						fg = c.text,
						bg = "NONE",
						gui = "bold",
					},

					padding = {
						left = 0,
						right = 1,
					},
				},

				{
					file_state,

					color = function()
						return {
							fg = vim.bo.modified and c.warning or c.textMuted,
							bg = "NONE",
						}
					end,

					padding = {
						left = 0,
						right = 0,
					},
				},
			},

			-- ==================================================================
			-- RIGHT
			-- ==================================================================

			lualine_x = {
				{
					lsp_clients,

					color = {
						fg = c.info,
						bg = "NONE",
					},

					padding = {
						left = 1,
						right = 1,
					},
				},

				{
					search_count,

					color = {
						fg = c.accent,
						bg = "NONE",
					},

					padding = {
						left = 0,
						right = 1,
					},
				},

				{
					recording,

					color = {
						fg = c.error,
						bg = "NONE",
						gui = "bold",
					},

					padding = {
						left = 0,
						right = 1,
					},
				},

				{
					"encoding",

					show_bomb = true,

					fmt = function(value)
						if value == "utf-8" then
							return "󰉿"
						end

						return "󰉿 " .. value
					end,

					color = {
						fg = c.textMuted,
						bg = "NONE",
					},

					padding = {
						left = 0,
						right = 1,
					},
				},

				{
					"filetype",

					colored = true,

					color = {
						fg = c.accent,
						bg = "NONE",
					},

					padding = {
						left = 0,
						right = 1,
					},
				},
			},

			-- ==================================================================
			-- POSITION
			-- ==================================================================

			lualine_y = {
				{
					"progress",

					fmt = function(value)
						return "󰦖 " .. value
					end,

					color = {
						fg = c.textSecondary,
						bg = "NONE",
					},

					padding = {
						left = 1,
						right = 1,
					},
				},

				{
					"location",

					fmt = function(value)
						return "󰍒 " .. value
					end,

					color = {
						fg = c.text,
						bg = "NONE",
						gui = "bold",
					},

					padding = {
						left = 0,
						right = 1,
					},
				},
			},

			-- ==================================================================
			-- CLOCK
			-- ==================================================================

			lualine_z = {
				{
					function()
						return os.date("%H:%M")
					end,

					icon = "󰥔",

					color = {
						fg = c.textMuted,
						bg = "NONE",
					},

					padding = {
						left = 1,
						right = 0,
					},
				},
			},
		},
	}
end

-- ============================================================================
-- Setup
-- ============================================================================

function M.setup()
	local ok, lualine = pcall(require, "lualine")

	if not ok then
		return false
	end

	lualine.setup(build_config())

	vim.schedule(function()
		vim.cmd("redrawstatus!")
	end)

	return true
end

-- ============================================================================
-- Live Theme Refresh
-- ============================================================================

function M.refresh_theme()
	local ok, lualine = pcall(require, "lualine")

	if not ok then
		return false
	end

	lualine.setup(build_config())

	vim.schedule(function()
		vim.cmd("redrawstatus!")
	end)

	return true
end

-- ============================================================================
-- Return
-- ============================================================================

return M
