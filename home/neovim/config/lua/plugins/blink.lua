-- Aurora Blink Completion

local M = {}

-- Theme

local aurora = require("aurora.theme")

local colors = aurora.colors

-- Aurora Highlights

local function apply_highlights()
	local c = colors()

	-- Completion Menu

	vim.api.nvim_set_hl(0, "BlinkCmpMenu", {
		fg = c.text,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", {
		fg = c.borderFocus or c.border,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", {
		fg = c.text,
		bg = c.surfaceHover,
		bold = true,
	})

	vim.api.nvim_set_hl(0, "BlinkCmpLabel", {
		fg = c.text,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "BlinkCmpLabelDeprecated", {
		fg = c.textMuted,
		bg = "NONE",
		strikethrough = true,
	})

	vim.api.nvim_set_hl(0, "BlinkCmpLabelDetail", {
		fg = c.textMuted,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "BlinkCmpLabelDescription", {
		fg = c.textSecondary,
		bg = "NONE",
	})

	-- Kind Icons

	local kinds = {
		Text = c.textSecondary,
		Method = c.accent,
		Function = c.accent,
		Constructor = c.accentHover or c.accent,
		Field = c.info,
		Variable = c.warning,
		Class = c.accent,
		Interface = c.accent,
		Module = c.info,
		Property = c.info,
		Unit = c.success,
		Value = c.warning,
		Enum = c.accent,
		Keyword = c.error,
		Snippet = c.success,
		Color = c.accent,
		File = c.info,
		Reference = c.info,
		Folder = c.warning,
		EnumMember = c.accent,
		Constant = c.warning,
		Struct = c.accent,
		Event = c.error,
		Operator = c.textSecondary,
		TypeParameter = c.accent,
	}

	for kind, color in pairs(kinds) do
		if color then
			vim.api.nvim_set_hl(0, "BlinkCmpKind" .. kind, {
				fg = color,
				bg = "NONE",
			})
		end
	end

	-- Documentation

	vim.api.nvim_set_hl(0, "BlinkCmpDoc", {
		fg = c.text,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", {
		fg = c.borderFocus or c.border,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "BlinkCmpDocCursorLine", {
		bg = c.surfaceHover,
	})

	vim.api.nvim_set_hl(0, "BlinkCmpDocSignatureHelp", {
		fg = c.text,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "BlinkCmpDocSignatureHelpBorder", {
		fg = c.borderFocus or c.border,
		bg = "NONE",
	})

	-- Scrollbar

	vim.api.nvim_set_hl(0, "BlinkCmpScrollBarThumb", {
		fg = c.accent,
		bg = c.surfaceHover,
	})

	-- Ghost Text

	vim.api.nvim_set_hl(0, "BlinkCmpGhostText", {
		fg = c.textMuted,
		bg = "NONE",
		italic = true,
	})
end

-- Setup

function M.setup()
	local ok, blink = pcall(require, "blink.cmp")

	if not ok then
		vim.notify("Aurora: Blink could not be loaded\n" .. tostring(blink), vim.log.levels.WARN)

		return false
	end

	blink.setup({
		-- Keymap

		keymap = {
			preset = "default",

			["<C-space>"] = {
				"show",
				"show_documentation",
				"hide_documentation",
			},

			["<C-e>"] = {
				"hide",
			},

			["<CR>"] = {
				"accept",
				"fallback",
			},

			["<Tab>"] = {
				"select_next",
				"snippet_forward",
				"fallback",
			},

			["<S-Tab>"] = {
				"select_prev",
				"snippet_backward",
				"fallback",
			},

			["<C-n>"] = {
				"select_next",
			},

			["<C-p>"] = {
				"select_prev",
			},

			["<C-b>"] = {
				"scroll_documentation_up",
			},

			["<C-f>"] = {
				"scroll_documentation_down",
			},
		},

		-- Appearance

		appearance = {
			nerd_font_variant = "mono",

			use_nvim_cmp_as_default = false,

			kind_icons = {
				Text = "󰉿",
				Method = "󰆧",
				Function = "󰊕",
				Constructor = "󰒓",
				Field = "󰜢",
				Variable = "󰀫",
				Class = "󰠱",
				Interface = "󰜰",
				Module = "󰏗",
				Property = "󰜢",
				Unit = "󰑭",
				Value = "󰎠",
				Enum = "󰕘",
				Keyword = "󰌋",
				Snippet = "󰩫",
				Color = "󰏘",
				File = "󰈙",
				Reference = "󰈇",
				Folder = "󰉋",
				EnumMember = "󰕘",
				Constant = "󰏿",
				Struct = "󰙅",
				Event = "󱐋",
				Operator = "󰆕",
				TypeParameter = "󰊄",
			},
		},

		-- Completion

		completion = {
			-- Menu

			menu = {
				border = "rounded",

				draw = {
					columns = {
						{
							"kind_icon",
							gap = 1,
						},

						{
							"label",
							"label_description",
							gap = 1,
						},
					},

					components = {
						kind_icon = {
							text = function(ctx)
								return ctx.kind_icon .. " "
							end,

							highlight = function(ctx)
								return "BlinkCmpKind" .. ctx.kind
							end,
						},

						label = {
							text = function(ctx)
								return ctx.label
							end,

							highlight = "BlinkCmpLabel",
						},

						label_description = {
							text = function(ctx)
								if ctx.label_description == nil then
									return ""
								end

								return " " .. ctx.label_description
							end,

							highlight = "BlinkCmpLabelDescription",
						},
					},
				},
			},

			-- Documentation

			documentation = {
				auto_show = true,

				auto_show_delay_ms = 250,

				window = {
					border = "rounded",

					scrollbar = true,
				},
			},

			-- Ghost Text

			ghost_text = {
				enabled = true,
			},
		},

		-- Sources

		sources = {
			default = {
				"lsp",
				"path",
				"buffer",
			},

			providers = {
				lsp = {
					name = "LSP",
					module = "blink.cmp.sources.lsp",
				},

				path = {
					name = "Path",
					module = "blink.cmp.sources.path",
				},

				buffer = {
					name = "Buffer",
					module = "blink.cmp.sources.buffer",
				},
			},
		},

		-- Fuzzy Matching

		fuzzy = {
			implementation = "prefer_rust_with_warning",
		},
	})

	apply_highlights()

	return true
end

-- Live Aurora Theme Refresh

function M.refresh_theme()
	apply_highlights()

	vim.schedule(function()
		vim.cmd("redraw!")
	end)

	return true
end

-- IMPORTANT

M.setup()

-- Return

return M
