-- ============================================================================
-- nvim-lint
-- ============================================================================

local lint = require("lint")

lint.linters_by_ft = {
	python = {
		"ruff",
	},

	javascript = {
		"eslint_d",
	},

	javascriptreact = {
		"eslint_d",
	},

	typescript = {
		"eslint_d",
	},

	typescriptreact = {
		"eslint_d",
	},

	sh = {
		"shellcheck",
	},

	bash = {
		"shellcheck",
	},
}

local group = vim.api.nvim_create_augroup("NvimLint", {
	clear = true,
})

vim.api.nvim_create_autocmd({
	"BufWritePost",
	"BufReadPost",
	"InsertLeave",
}, {
	group = group,
	callback = function()
		lint.try_lint()
	end,
})
