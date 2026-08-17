-- ============================================================================
-- Aurora Which-Key
-- ============================================================================
--
-- Key discovery UI for Aurora Neovim.
--
-- Which-Key is responsible ONLY for:
--
--   • keymap discovery
--   • group organization
--   • descriptions
--   • popup presentation
--
-- Theme colors are owned centrally by:
--
--     ui/theme.lua
--
-- ============================================================================

local wk = require("which-key")

-- ============================================================================
-- Setup
-- ============================================================================

wk.setup({
	-- ========================================================================
	-- Popup
	-- ========================================================================

	preset = "modern",

	delay = 300,

	notify = false,

	win = {
		border = "rounded",

		padding = {
			1,
			2,
		},

		no_overlap = true,

		title = true,
		title_pos = "center",

		zindex = 1000,
	},

	-- ========================================================================
	-- Layout
	-- ========================================================================

	layout = {
		width = {
			min = 22,
			max = 68,
		},

		spacing = 3,

		align = "left",
	},

	-- ========================================================================
	-- Icons
	-- ========================================================================

	icons = {
		breadcrumb = "»",
		separator = "➜",
		group = "󰉋 ",
		colors = true,
		rules = false,
	},

	-- ========================================================================
	-- Sorting
	-- ========================================================================

	sort = {
		"local",
		"order",
		"group",
		"alphanum",
		"mod",
	},

	expand = 1,

	-- ========================================================================
	-- Built-in groups
	-- ========================================================================

	plugins = {
		marks = true,

		registers = true,

		spelling = {
			enabled = true,
			suggestions = 20,
		},

		presets = {
			operators = false,
			motions = false,
			text_objects = false,
			w = true,
			g = true,
			z = true,
			y = true,
		},
	},
})

-- ============================================================================
-- Aurora Keymap Hierarchy
-- ============================================================================

wk.add({

	-- ========================================================================
	-- FIND
	-- ========================================================================

	{
		"<leader>f",
		group = "Find",
		icon = "󰍉",
	},

	{
		"<leader>ff",
		desc = "Find files",
	},

	{
		"<leader>fg",
		desc = "Live grep",
	},

	{
		"<leader>fb",
		desc = "Buffers",
	},

	{
		"<leader>fr",
		desc = "Recent files",
	},

	{
		"<leader>fd",
		desc = "Diagnostics",
	},

	{
		"<leader>fh",
		desc = "Help",
	},

	{
		"<leader>fc",
		desc = "Commands",
	},

	{
		"<leader>fo",
		desc = "Search buffer",
	},

	-- ========================================================================
	-- BUFFERS
	-- ========================================================================

	{
		"<leader>b",
		group = "Buffers",
		icon = "󰓩",
	},

	{
		"<leader>bn",
		desc = "Next buffer",
	},

	{
		"<leader>bp",
		desc = "Previous buffer",
	},

	{
		"<leader>bd",
		desc = "Delete buffer",
	},

	{
		"<leader>bb",
		desc = "Buffer picker",
	},

	-- ========================================================================
	-- WINDOWS
	-- ========================================================================

	{
		"<leader>w",
		group = "Windows",
		icon = "󰖲",
	},

	{
		"<leader>ws",
		desc = "Horizontal split",
	},

	{
		"<leader>wv",
		desc = "Vertical split",
	},

	{
		"<leader>wc",
		desc = "Close window",
	},

	{
		"<leader>we",
		desc = "Equalize windows",
	},

	-- ========================================================================
	-- TABS / TERMINAL
	-- ========================================================================

	{
		"<leader>t",
		group = "Tabs / Terminal",
		icon = "󰓩",
	},

	{
		"<leader>tn",
		desc = "New tab",
	},

	{
		"<leader>tc",
		desc = "Close tab",
	},

	{
		"<leader>tl",
		desc = "Next tab",
	},

	{
		"<leader>th",
		desc = "Previous tab",
	},

	{
		"<leader>tt",
		desc = "Terminal",
	},

	-- ========================================================================
	-- EXPLORER
	-- ========================================================================

	{
		"<leader>e",
		group = "Explorer",
		icon = "󰙅",
	},

	{
		"<leader>ef",
		desc = "Find current file",
	},

	{
		"<leader>ec",
		desc = "Collapse all",
	},

	{
		"<leader>er",
		desc = "Refresh explorer",
	},

	-- ========================================================================
	-- GIT
	-- ========================================================================

	{
		"<leader>g",
		group = "Git",
		icon = "󰊢",
	},

	{
		"<leader>gh",
		desc = "Preview hunk",
	},

	{
		"<leader>gb",
		desc = "Blame line",
	},

	{
		"<leader>gd",
		desc = "Diff hunk",
	},

	{
		"<leader>gD",
		desc = "Diff buffer",
	},

	{
		"<leader>gr",
		desc = "Reset hunk",
	},

	{
		"<leader>gR",
		desc = "Reset buffer",
	},

	{
		"<leader>gS",
		desc = "Stage hunk",
	},

	{
		"<leader>gU",
		desc = "Undo stage hunk",
	},

	{
		"<leader>lg",
		desc = "LazyGit",
		icon = "󰊢",
	},

	-- ========================================================================
	-- LSP
	-- ========================================================================

	{
		"<leader>l",
		group = "LSP",
		icon = "󰘦",
	},

	{
		"<leader>la",
		desc = "Code action",
	},

	{
		"<leader>ld",
		desc = "Line diagnostics",
	},

	{
		"<leader>lh",
		desc = "Toggle inlay hints",
	},

	{
		"<leader>lr",
		desc = "Rename symbol",
	},

	-- ========================================================================
	-- DIAGNOSTICS
	-- ========================================================================

	{
		"<leader>x",
		group = "Diagnostics",
		icon = "󰒡",
	},

	{
		"<leader>xx",
		desc = "Diagnostics",
	},

	{
		"<leader>xX",
		desc = "Buffer diagnostics",
	},

	{
		"<leader>xs",
		desc = "Symbols",
	},

	{
		"<leader>xl",
		desc = "Location list",
	},

	{
		"<leader>xq",
		desc = "Quickfix list",
	},

	-- ========================================================================
	-- QUICKFIX
	-- ========================================================================

	{
		"<leader>c",
		group = "Quickfix",
		icon = "󰁨",
	},

	{
		"<leader>co",
		desc = "Open quickfix",
	},

	{
		"<leader>cc",
		desc = "Close quickfix",
	},

	{
		"<leader>cn",
		desc = "Next quickfix",
	},

	{
		"<leader>cp",
		desc = "Previous quickfix",
	},

	-- ========================================================================
	-- FORMAT / LINT
	-- ========================================================================

	{
		"<leader>gf",
		desc = "Format",
		icon = "󰉿",
	},

	{
		"<leader>ll",
		desc = "Run lint",
		icon = "󰁨",
	},

	-- ========================================================================
	-- EDITING
	-- ========================================================================

	{
		"<leader>p",
		desc = "Paste without yank",
		icon = "󰆒",
	},

	{
		"<leader>dd",
		desc = "Delete without yank",
		icon = "󰆴",
	},

	-- ========================================================================
	-- HISTORY
	-- ========================================================================

	{
		"<leader>:",
		desc = "Command history",
	},

	{
		"<leader>/",
		desc = "Search history",
	},

	-- ========================================================================
	-- HELP
	-- ========================================================================

	{
		"<leader>h",
		group = "Help",
		icon = "󰋖",
	},

	{
		"<leader>hh",
		desc = "Help tags",
	},
})
