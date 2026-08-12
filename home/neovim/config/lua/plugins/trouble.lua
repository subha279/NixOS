-- ============================================================================
-- Trouble
-- ============================================================================

require("trouble").setup({
	auto_close = true,

	focus = true,

	follow = true,

	indent_lines = true,

	modes = {
		diagnostics = {
			mode = "diagnostics",
			preview = {
				type = "float",
				relative = "editor",
				border = "rounded",
			},
		},
	},
})

local map = vim.keymap.set

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", {
	desc = "Diagnostics",
})

map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", {
	desc = "Buffer diagnostics",
})

map("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", {
	desc = "Symbols",
})

map("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", {
	desc = "Location list",
})

map("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", {
	desc = "Quickfix",
})
