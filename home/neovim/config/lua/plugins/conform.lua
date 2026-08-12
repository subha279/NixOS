-- ============================================================================
-- Conform
-- ============================================================================

require("conform").setup({
	formatters_by_ft = {
		lua = {
			"stylua",
		},

		rust = {
			"rustfmt",
		},

		python = {
			"ruff_format",
		},

		javascript = {
			"prettier",
		},

		javascriptreact = {
			"prettier",
		},

		typescript = {
			"prettier",
		},

		typescriptreact = {
			"prettier",
		},

		html = {
			"prettier",
		},

		css = {
			"prettier",
		},

		json = {
			"prettier",
		},

		yaml = {
			"prettier",
		},

		markdown = {
			"prettier",
		},

		nix = {
			"nixfmt",
		},

		sh = {
			"shfmt",
		},

		bash = {
			"shfmt",
		},

		toml = {
			"taplo",
		},

		c = {
			"clang_format",
		},

		cpp = {
			"clang_format",
		},
	},

	format_on_save = {
		timeout_ms = 3000,
		lsp_format = "fallback",
	},
})

vim.keymap.set({ "n", "v" }, "<leader>gf", function()
	require("conform").format({
		async = false,
		lsp_format = "fallback",
	})
end, {
	desc = "Format",
})
