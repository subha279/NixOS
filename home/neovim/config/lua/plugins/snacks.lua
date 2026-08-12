-- ============================================================================
-- Snacks
-- ============================================================================

require("snacks").setup({
	bigfile = {
		enabled = true,
	},

	notifier = {
		enabled = true,
	},

	quickfile = {
		enabled = true,
	},

	scope = {
		enabled = true,
	},

	words = {
		enabled = true,
	},

	indent = {
		enabled = true,
	},
})

local snacks = require("snacks")

vim.keymap.set("n", "<leader>lg", function()
	snacks.lazygit()
end, {
	desc = "LazyGit",
})
