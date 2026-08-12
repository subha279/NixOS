-- ============================================================================
-- Telescope
-- ============================================================================

local telescope = require("telescope")

telescope.setup({
	defaults = {
		prompt_prefix = "  ",
		selection_caret = "  ",

		sorting_strategy = "ascending",

		layout_config = {
			horizontal = {
				prompt_position = "top",
				preview_width = 0.55,
			},
		},

		file_ignore_patterns = {
			"node_modules",
			"%.git/",
			"target/",
			"dist/",
			"build/",
			"%.cache/",
			"result/",
		},
	},
})

local builtin = require("telescope.builtin")

local map = vim.keymap.set

map("n", "<leader>ff", builtin.find_files, {
	desc = "Find files",
})

map("n", "<leader>fg", builtin.live_grep, {
	desc = "Live grep",
})

map("n", "<leader>fb", builtin.buffers, {
	desc = "Find buffers",
})

map("n", "<leader>fh", builtin.help_tags, {
	desc = "Find help",
})

map("n", "<leader>fr", builtin.oldfiles, {
	desc = "Recent files",
})

map("n", "<leader>fc", builtin.commands, {
	desc = "Commands",
})

map("n", "<leader>fk", builtin.keymaps, {
	desc = "Keymaps",
})

map("n", "<leader>fs", builtin.lsp_document_symbols, {
	desc = "Document symbols",
})

map("n", "<leader>fS", builtin.lsp_workspace_symbols, {
	desc = "Workspace symbols",
})

map("n", "<leader>fd", builtin.diagnostics, {
	desc = "Diagnostics",
})
