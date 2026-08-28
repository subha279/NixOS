local M = {}


local aurora = require("aurora.theme")

local icons = require("aurora.icons")

local colors = aurora.colors

local function transparent(foreground)
	return {
		fg = foreground,
		bg = "NONE",
	}
end


local function columns()
	return vim.o.columns
end

local function at_least(minimum)
	return function()
		return columns() >= minimum
	end
end

local function truncate(text, maximum)
	if text == nil or text == "" then
		return ""
	end

	if vim.fn.strdisplaywidth(text) <= maximum then
		return text
	end

	return vim.fn.strcharpart(text, 0, math.max(maximum - 1, 1)) .. "…"
end


local mode_labels = {
	normal = { short = "N", long = "NORMAL" },
	insert = { short = "I", long = "INSERT" },
	visual = { short = "V", long = "VISUAL" },
	replace = { short = "R", long = "REPLACE" },
	command = { short = "C", long = "COMMAND" },
	select = { short = "S", long = "SELECT" },
	terminal = { short = "T", long = "TERMINAL" },
}

local function mode_kind()
	local current = vim.fn.mode(1)
	local first = current:sub(1, 1)

	if first == "i" then
		return "insert"
	end

	if first == "v" or current == "V" or first == "\22" then
		return "visual"
	end

	if first == "R" then
		return "replace"
	end

	if first == "c" then
		return "command"
	end

	if first == "s" or current == "S" or first == "\19" then
		return "select"
	end

	if first == "t" then
		return "terminal"
	end

	return "normal"
end

local function mode_label()
	local label = mode_labels[mode_kind()] or mode_labels.normal

	if columns() < 72 then
		return label.short
	end

	return label.long
end

local function mode_color()
	local c = colors()
	local backgrounds = {
		normal = c.accent,
		insert = c.success,
		visual = c.info,
		replace = c.warning,
		command = c.accentHover or c.accent,
		select = c.info,
		terminal = c.success,
	}

	return {
		fg = c.accentForeground,
		bg = backgrounds[mode_kind()] or c.accent,
		gui = "bold",
	}
end


local function project_name()
	local directory = vim.fn.getcwd()

	if directory == "" then
		return ""
	end

	local home = vim.fn.expand("~")

	if directory == home then
		return "󰋜 ~"
	end

	local tail = vim.fn.fnamemodify(directory, ":t")
	return tail ~= "" and ("󱉭 " .. tail) or directory
end

local function lsp_status()
	local clients = vim.lsp.get_clients({ bufnr = 0 })

	if #clients == 0 then
		return ""
	end

	local names = {}
	local seen = {}

	for _, client in ipairs(clients) do
		if client.name and client.name ~= "" and not seen[client.name] then
			seen[client.name] = true
			names[#names + 1] = client.name
		end
	end

	if #names == 0 then
		return ""
	end

	table.sort(names)

	if columns() < 118 then
		return string.format("󰒋 %d", #names)
	end

	local progress = ""

	if type(vim.lsp.status) == "function" then
		local ok, value = pcall(vim.lsp.status)

		if ok and type(value) == "string" then
			progress = value
		end
	end

	if progress ~= "" and columns() >= 150 then
		return "󰚩 " .. truncate(progress, 28)
	end

	return "󰒋 " .. truncate(table.concat(names, " · "), columns() >= 155 and 34 or 20)
end

local function search_count()
	if vim.v.hlsearch == 0 then
		return ""
	end

	local ok, result = pcall(vim.fn.searchcount, {
		maxcount = 999,
		timeout = 50,
	})

	if not ok or type(result) ~= "table" or not result.total or result.total == 0 then
		return ""
	end

	return string.format("󰍉 %d/%d", result.current or 0, result.total)
end

local function has_search_count()
	return search_count() ~= ""
end

local function recording()
	local register = vim.fn.reg_recording()
	return register == "" and "" or ("󰑋 @" .. register)
end

local function is_recording()
	return vim.fn.reg_recording() ~= ""
end

local function encoding()
	local value = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding

	if value == "" then
		return ""
	end

	if value:lower() == "utf-8" and columns() < 150 then
		return ""
	end

	return "󰉿 " .. value:upper()
end

local function line_ending()
	local formats = {
		dos = "CRLF",
		mac = "CR",
	}

	local value = formats[vim.bo.fileformat]
	return value and ("󰌑 " .. value) or ""
end

local function compact_filetype(name)
	if columns() < 105 then
		return truncate(name, 8)
	end

	return name
end

local function has_diagnostics()
	return #vim.diagnostic.get(0) > 0
end


local function build_theme()
	local c = colors()
	local active = {
		a = mode_color(),
		b = transparent(c.text),
		c = transparent(c.textSecondary),
		x = transparent(c.textSecondary),
		y = transparent(c.text),
		z = transparent(c.textSecondary),
	}
	local inactive = {
		a = transparent(c.textMuted),
		b = transparent(c.textMuted),
		c = transparent(c.textMuted),
		x = transparent(c.textMuted),
		y = transparent(c.textMuted),
		z = transparent(c.textMuted),
	}

	return {
		normal = vim.deepcopy(active),
		insert = vim.deepcopy(active),
		visual = vim.deepcopy(active),
		replace = vim.deepcopy(active),
		command = vim.deepcopy(active),
		select = vim.deepcopy(active),
		terminal = vim.deepcopy(active),
		inactive = inactive,
	}
end


local function build_config()
	local c = colors()

	return {
		options = {
			icons_enabled = true,
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
			section_separators = { left = "", right = "" },
			component_separators = { left = "·", right = "·" },
			always_divide_middle = true,
			always_show_tabline = false,
			refresh = {
				statusline = 500,
				tabline = 1000,
				winbar = 1000,
			},
		},

		sections = {
			lualine_a = {
				{
					mode_label,
					color = mode_color,
					separator = { left = "", right = "" },
					padding = { left = 1, right = 1 },
				},
			},

			lualine_b = {
				{
					"branch",
					icon = "󰘬",
					cond = at_least(62),
					color = {
						fg = c.accent,
						bg = "NONE",
						gui = "bold",
					},
					padding = { left = 1, right = 1 },
				},
				{
					"diff",
					cond = at_least(108),
					symbols = {
						added = "+",
						modified = "~",
						removed = "-",
					},
					diff_color = {
						added = { fg = c.success },
						modified = { fg = c.warning },
						removed = { fg = c.error },
					},
					padding = { left = 0, right = 1 },
				},
				{
					"diagnostics",
					cond = has_diagnostics,
					sources = { "nvim_diagnostic" },
					symbols = {
						error = icons.diagnostics.error .. " ",
						warn = icons.diagnostics.warn .. " ",
						info = icons.diagnostics.info .. " ",
						hint = icons.diagnostics.hint .. " ",
					},
					diagnostics_color = {
						error = { fg = c.error },
						warn = { fg = c.warning },
						info = { fg = c.info },
						hint = { fg = c.success },
					},
					padding = { left = 0, right = 1 },
				},
			},

			lualine_c = {
				{
					project_name,
					cond = at_least(126),
					color = transparent(c.textMuted),
					padding = { left = 0, right = 1 },
				},
				{
					"filename",
					path = 1,
					shorting_target = 24,
					symbols = {
						modified = " ●",
						readonly = " ",
						unnamed = "[No Name]",
						newfile = "[New]",
					},
					color = {
						fg = c.text,
						bg = "NONE",
						gui = "bold",
					},
					padding = { left = 0, right = 1 },
				},
			},

			lualine_x = {
				{
					recording,
					cond = is_recording,
					color = {
						fg = c.error,
						bg = "NONE",
						gui = "bold",
					},
				},
				{
					search_count,
					cond = has_search_count,
					color = transparent(c.accent),
				},
				{
					lsp_status,
					cond = at_least(82),
					color = transparent(c.info),
				},
				{
					"filesize",
					cond = at_least(170),
					color = transparent(c.textMuted),
				},
				{
					line_ending,
					color = transparent(c.warning),
				},
				{
					encoding,
					color = transparent(c.textMuted),
				},
				{
					"filetype",
					colored = true,
					cond = at_least(68),
					fmt = compact_filetype,
					color = transparent(c.accent),
					padding = { left = 0, right = 1 },
				},
			},

			lualine_y = {
				{
					"progress",
					cond = at_least(94),
					fmt = function(value)
						return "󰦖 " .. value
					end,
					color = transparent(c.textSecondary),
					padding = { left = 1, right = 1 },
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
					padding = { left = 0, right = 1 },
				},
			},

			lualine_z = {
				{
					function()
						if columns() >= 182 then
							return os.date("%a %H:%M")
						end

						return os.date("%H:%M")
					end,
					icon = "󰥔",
					cond = at_least(145),
					color = transparent(c.textMuted),
					padding = { left = 1, right = 0 },
				},
			},
		},

		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = {
				{
					"filename",
					path = 1,
					color = transparent(c.textMuted),
				},
			},
			lualine_x = {
				{
					"location",
					color = transparent(c.textMuted),
				},
			},
			lualine_y = {},
			lualine_z = {},
		},

		tabline = {},
		winbar = {},
		inactive_winbar = {},
		extensions = {},
	}
end


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


aurora.on_change(function()
	M.setup()
end)

return M
