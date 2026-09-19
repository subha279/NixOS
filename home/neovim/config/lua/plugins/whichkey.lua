local wk = require("which-key")

wk.setup({
	preset = "modern",
	delay = 300,
	notify = false,

	win = {
		border = "rounded",
		padding = { 1, 2 },
		no_overlap = true,
		title = true,
		title_pos = "center",
		zindex = 1000,
	},

	layout = {
		width = { min = 22, max = 68 },
		spacing = 3,
		align = "left",
	},

	icons = {
		breadcrumb = "»",
		separator = "➜",
		group = "󰉋 ",
		colors = true,
		rules = false,
	},

	sort = {
		"local",
		"order",
		"group",
		"alphanum",
		"mod",
	},
})

wk.add({
	{ "<leader>f", group = "Find" },
	{ "<leader>b", group = "Buffers" },
	{ "<leader>w", group = "Windows" },
	{ "<leader>t", group = "Tabs / Terminal" },
	{ "<leader>e", group = "Explorer" },
	{ "<leader>g", group = "Git" },
	{ "<leader>l", group = "LSP" },
	{ "<leader>x", group = "Diagnostics" },
	{ "<leader>c", group = "Quickfix" },
	{ "<leader>h", group = "Help" },
})
