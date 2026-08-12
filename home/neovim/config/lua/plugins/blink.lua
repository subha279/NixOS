-- ============================================================================
-- Blink Completion
-- ============================================================================

require("blink.cmp").setup({
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
	},

	appearance = {
		nerd_font_variant = "mono",
	},

	completion = {
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 300,
		},

		menu = {
			border = "rounded",
		},
	},

	sources = {
		default = {
			"lsp",
			"path",
			"buffer",
		},
	},

	fuzzy = {
		implementation = "prefer_rust_with_warning",
	},
})
