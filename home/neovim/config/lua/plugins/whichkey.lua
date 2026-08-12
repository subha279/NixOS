-- ============================================================================
-- Which-key
-- ============================================================================

require("which-key").setup({
	preset = "modern",

	delay = 300,

	win = {
		border = "rounded",
	},

	layout = {
		width = {
			min = 20,
			max = 50,
		},
	},
})

require("which-key").add({
	{
		"<leader>f",
		group = "Find",
	},

	{
		"<leader>b",
		group = "Buffers",
	},

	{
		"<leader>w",
		group = "Windows",
	},

	{
		"<leader>g",
		group = "Git",
	},

	{
		"<leader>x",
		group = "Diagnostics",
	},

	{
		"<leader>l",
		group = "LSP",
	},

	{
		"<leader>t",
		group = "Terminal",

		{
			"<leader>e",
			group = "Explorer",
		},
	},
})
