-- ============================================================================
-- Lualine
-- Aurora statusline
-- ============================================================================

local M = {}

-- ============================================================================
-- Aurora palette
-- ============================================================================

local colors = {
	bg = "#141218",
	bg_alt = "#1b1820",
	bg_soft = "#211d27",

	fg = "#e6e0e9",
	muted = "#9d99a5",

	purple = "#d0bcff",
	purple_dark = "#bca5f2",

	blue = "#7aa2f7",
	cyan = "#D0BCFF",

	green = "#7fff9a",
	yellow = "#ffda72",
	red = "#ff728f",
	orange = "#ffb86c",

	border = "#302b36",
}

-- ============================================================================
-- Mode component
-- ============================================================================

local function mode_icon()
	local mode = vim.fn.mode()

	local icons = {
		n = "󱄅 ",
		i = "󰏫",
		v = "󰈈",
		V = "󰈈",
		["\22"] = "󰈈",
		c = "󰘳",
		s = "󰒉",
		S = "󰒉",
		R = "󰑕",
		t = "󰆍",
	}

	return icons[mode] or "󰘳"
end

local function mode_name()
	local mode = vim.fn.mode()

	local names = {
		n = "NORMAL",
		i = "INSERT",
		v = "VISUAL",
		V = "V-LINE",
		["\22"] = "V-BLOCK",
		c = "COMMAND",
		s = "SELECT",
		S = "S-LINE",
		R = "REPLACE",
		t = "TERMINAL",
	}

	return names[mode] or mode
end

-- ============================================================================
-- File information
-- ============================================================================

local function filename()
	local name = vim.fn.expand("%:t")

	if name == "" then
		return "󰈔 No Name"
	end

	return "󰈔 " .. name
end

local function file_modified()
	if vim.bo.modified then
		return "●"
	end

	return ""
end

-- ============================================================================
-- Git
-- ============================================================================

local function git_branch()
	local branch = vim.b.gitsigns_head

	if not branch or branch == "" then
		return ""
	end

	return "󰊢 " .. branch
end

-- ============================================================================
-- Diagnostics
-- ============================================================================

local function diagnostics()
	local diagnostics = vim.diagnostic.get(0)

	if #diagnostics == 0 then
		return ""
	end

	local errors = 0
	local warnings = 0
	local hints = 0
	local info = 0

	for _, diagnostic in ipairs(diagnostics) do
		if diagnostic.severity == vim.diagnostic.severity.ERROR then
			errors = errors + 1
		elseif diagnostic.severity == vim.diagnostic.severity.WARN then
			warnings = warnings + 1
		elseif diagnostic.severity == vim.diagnostic.severity.HINT then
			hints = hints + 1
		elseif diagnostic.severity == vim.diagnostic.severity.INFO then
			info = info + 1
		end
	end

	local result = {}

	if errors > 0 then
		table.insert(result, "󰅚 " .. errors)
	end

	if warnings > 0 then
		table.insert(result, "󰀪 " .. warnings)
	end

	if info > 0 then
		table.insert(result, "󰋼 " .. info)
	end

	if hints > 0 then
		table.insert(result, "󰌵 " .. hints)
	end

	return table.concat(result, " ")
end

-- ============================================================================
-- LSP
-- ============================================================================

local function lsp()
	local clients = vim.lsp.get_clients({
		bufnr = vim.api.nvim_get_current_buf(),
	})

	if #clients == 0 then
		return "󰒎 No LSP"
	end

	local names = {}

	for _, client in ipairs(clients) do
		table.insert(names, client.name)
	end

	return "󰒋 " .. table.concat(names, ", ")
end

-- ============================================================================
-- Filetype
-- ============================================================================

local function filetype()
	local ft = vim.bo.filetype

	if ft == "" then
		return "󰈔 TEXT"
	end

	return "󰈔 " .. ft
end

-- ============================================================================
-- Git diff
-- ============================================================================

local function git_diff()
	if not vim.b.gitsigns_status_dict then
		return ""
	end

	local diff = vim.b.gitsigns_status_dict

	local result = {}

	if diff.added and diff.added > 0 then
		table.insert(result, " " .. diff.added)
	end

	if diff.changed and diff.changed > 0 then
		table.insert(result, " " .. diff.changed)
	end

	if diff.removed and diff.removed > 0 then
		table.insert(result, " " .. diff.removed)
	end

	return table.concat(result, " ")
end

-- ============================================================================
-- Mode colors
-- ============================================================================

local mode_colors = {
	n = colors.purple,
	i = colors.green,
	v = colors.blue,
	V = colors.blue,
	["\22"] = colors.blue,
	c = colors.yellow,
	s = colors.blue,
	S = colors.blue,
	R = colors.red,
	t = colors.cyan,
}

-- ============================================================================
-- Setup
-- ============================================================================

function M.setup()
	require("lualine").setup({
		options = {
			theme = "auto",

			globalstatus = true,

			component_separators = {
				left = "│",
				right = "│",
			},

			section_separators = {
				left = "",
				right = "",
			},

			disabled_filetypes = {
				"dashboard",
				"NvimTree",
				"snacks_dashboard",
				"lazy",
				"mason",
			},

			refresh = {
				statusline = 100,
				winbar = 100,
			},
		},

		sections = {

			-- ======================================================================
			-- LEFT
			-- ======================================================================

			lualine_a = {
				{
					mode_icon,
					color = function()
						return {
							fg = colors.bg,
							bg = mode_colors[vim.fn.mode()] or colors.purple,
							gui = "bold",
						}
					end,

					padding = {
						left = 1,
						right = 1,
					},
				},
			},

			lualine_b = {

				{
					mode_name,

					color = function()
						return {
							fg = mode_colors[vim.fn.mode()] or colors.purple,
							bg = colors.bg_alt,
							gui = "bold",
						}
					end,

					padding = {
						left = 1,
						right = 1,
					},
				},

				{
					filename,

					color = {
						fg = colors.fg,
						bg = colors.bg_alt,
					},

					padding = {
						left = 1,
						right = 1,
					},
				},

				{
					file_modified,

					color = {
						fg = colors.yellow,
						bg = colors.bg_alt,
					},

					padding = {
						left = 0,
						right = 1,
					},
				},
			},

			lualine_c = {

				{
					git_branch,

					color = {
						fg = colors.purple,
						bg = colors.bg,
					},

					padding = {
						left = 1,
						right = 1,
					},
				},

				{
					git_diff,

					color = {
						fg = colors.green,
						bg = colors.bg,
					},

					padding = {
						left = 1,
						right = 1,
					},
				},

				{
					diagnostics,

					color = {
						fg = colors.red,
						bg = colors.bg,
					},

					padding = {
						left = 1,
						right = 1,
					},
				},
			},

			-- ======================================================================
			-- RIGHT
			-- ======================================================================

			lualine_x = {

				{
					lsp,

					color = {
						fg = colors.cyan,
						bg = colors.bg,
					},

					padding = {
						left = 1,
						right = 1,
					},
				},

				{
					filetype,

					color = {
						fg = colors.blue,
						bg = colors.bg,
					},

					padding = {
						left = 1,
						right = 1,
					},
				},

				{
					"encoding",

					color = {
						fg = colors.muted,
						bg = colors.bg,
					},

					padding = {
						left = 1,
						right = 1,
					},
				},
			},

			lualine_y = {

				{
					"progress",

					color = {
						fg = colors.purple,
						bg = colors.bg_alt,
						gui = "bold",
					},

					padding = {
						left = 1,
						right = 1,
					},
				},
			},

			lualine_z = {

				{
					"location",

					color = function()
						return {
							fg = colors.bg,
							bg = mode_colors[vim.fn.mode()] or colors.purple,
							gui = "bold",
						}
					end,

					padding = {
						left = 1,
						right = 1,
					},
				},
			},
		},

		-- ========================================================================
		-- INACTIVE WINDOWS
		-- ========================================================================

		inactive_sections = {

			lualine_a = {},

			lualine_b = {
				{
					filename,

					color = {
						fg = colors.muted,
						bg = colors.bg,
					},
				},
			},

			lualine_c = {},

			lualine_x = {
				{
					filetype,

					color = {
						fg = colors.muted,
						bg = colors.bg,
					},
				},
			},

			lualine_y = {
				{
					"location",

					color = {
						fg = colors.muted,
						bg = colors.bg,
					},
				},
			},

			lualine_z = {},
		},

		extensions = {
			"nvim-tree",
			"quickfix",
			"fugitive",
			"lazy",
			"trouble",
		},
	})
end

return M
