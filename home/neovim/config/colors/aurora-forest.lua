vim.cmd("highlight clear")

if vim.fn.exists("syntax_on") == 1 then
	vim.cmd("syntax reset")
end

vim.g.colors_name = "aurora-forest"

local c = {
	-- Main editor
	fg = "#E1ECE6",
	muted = "#84968D",
	dim = "#56665E",

	-- Borders
	border = "#2A4035",

	-- Accent colors
	green = "#A6E3A1",
	teal = "#7FDBCA",
	cyan = "#89DCEB",
	blue = "#89B4FA",
	yellow = "#F9E2AF",
	orange = "#FAB387",
	red = "#F38BA8",
	purple = "#CBA6F7",
	pink = "#F5C2E7",

	-- Floating UI
	float_bg = "#131C18",
	visual_bg = "#20352B",
}

local hi = vim.api.nvim_set_hl

-- ============================================================================
-- CORE
-- ============================================================================

hi(0, "Normal", {
	fg = c.fg,
	bg = "NONE",
})

hi(0, "NormalNC", {
	fg = c.fg,
	bg = "NONE",
})

hi(0, "EndOfBuffer", {
	fg = c.dim,
	bg = "NONE",
})

hi(0, "SignColumn", {
	fg = c.muted,
	bg = "NONE",
})

hi(0, "FoldColumn", {
	fg = c.dim,
	bg = "NONE",
})

-- ============================================================================
-- CURSOR
-- ============================================================================

hi(0, "CursorLine", {
	bg = "NONE",
})

hi(0, "CursorColumn", {
	bg = "NONE",
})

hi(0, "Cursor", {
	fg = "#0C1210",
	bg = c.fg,
})

-- ============================================================================
-- VISUAL
-- ============================================================================

hi(0, "Visual", {
	bg = c.visual_bg,
})

hi(0, "VisualNOS", {
	bg = c.visual_bg,
})

-- ============================================================================
-- LINE NUMBERS
-- ============================================================================

hi(0, "LineNr", {
	fg = c.dim,
	bg = "NONE",
})

hi(0, "CursorLineNr", {
	fg = c.green,
	bg = "NONE",
	bold = true,
})

-- ============================================================================
-- WINDOWS
-- ============================================================================

hi(0, "VertSplit", {
	fg = c.border,
	bg = "NONE",
})

hi(0, "WinSeparator", {
	fg = c.border,
	bg = "NONE",
})

-- ============================================================================
-- STATUSLINE
-- ============================================================================

hi(0, "StatusLine", {
	fg = c.fg,
	bg = "NONE",
})

hi(0, "StatusLineNC", {
	fg = c.muted,
	bg = "NONE",
})

-- ============================================================================
-- FLOATING WINDOWS
-- ============================================================================

hi(0, "NormalFloat", {
	fg = c.fg,
	bg = c.float_bg,
})

hi(0, "FloatBorder", {
	fg = c.green,
	bg = c.float_bg,
})

-- ============================================================================
-- COMPLETION
-- ============================================================================

hi(0, "Pmenu", {
	fg = c.fg,
	bg = c.float_bg,
})

hi(0, "PmenuSel", {
	fg = "#0C1210",
	bg = c.green,
	bold = true,
})

hi(0, "PmenuSbar", {
	bg = "#1E2B24",
})

hi(0, "PmenuThumb", {
	bg = c.green,
})

-- ============================================================================
-- SEARCH
-- ============================================================================

hi(0, "Search", {
	fg = "#0C1210",
	bg = c.yellow,
})

hi(0, "IncSearch", {
	fg = "#0C1210",
	bg = c.orange,
	bold = true,
})

hi(0, "CurSearch", {
	fg = "#0C1210",
	bg = c.green,
	bold = true,
})

-- ============================================================================
-- SYNTAX
-- ============================================================================

hi(0, "Comment", {
	fg = c.dim,
	italic = true,
})

hi(0, "Constant", {
	fg = c.orange,
})

hi(0, "String", {
	fg = c.green,
})

hi(0, "Character", {
	fg = c.green,
})

hi(0, "Number", {
	fg = c.orange,
})

hi(0, "Boolean", {
	fg = c.orange,
	bold = true,
})

hi(0, "Float", {
	fg = c.orange,
})

hi(0, "Identifier", {
	fg = c.fg,
})

hi(0, "Function", {
	fg = c.teal,
	bold = true,
})

hi(0, "Statement", {
	fg = c.green,
	bold = true,
})

hi(0, "Keyword", {
	fg = c.green,
	bold = true,
})

hi(0, "Operator", {
	fg = c.cyan,
})

hi(0, "Type", {
	fg = c.teal,
	bold = true,
})

hi(0, "Structure", {
	fg = c.teal,
})

hi(0, "Special", {
	fg = c.yellow,
})

hi(0, "Delimiter", {
	fg = c.muted,
})

hi(0, "PreProc", {
	fg = c.purple,
})

hi(0, "Include", {
	fg = c.purple,
})

hi(0, "Define", {
	fg = c.purple,
})

hi(0, "Macro", {
	fg = c.pink,
})

hi(0, "Exception", {
	fg = c.red,
	bold = true,
})

hi(0, "Todo", {
	fg = "#0C1210",
	bg = c.yellow,
	bold = true,
})

-- ============================================================================
-- DIAGNOSTICS
-- ============================================================================

hi(0, "DiagnosticError", {
	fg = c.red,
})

hi(0, "DiagnosticWarn", {
	fg = c.yellow,
})

hi(0, "DiagnosticInfo", {
	fg = c.blue,
})

hi(0, "DiagnosticHint", {
	fg = c.cyan,
})

hi(0, "DiagnosticOk", {
	fg = c.green,
})

hi(0, "DiagnosticUnderlineError", {
	undercurl = true,
	sp = c.red,
})

hi(0, "DiagnosticUnderlineWarn", {
	undercurl = true,
	sp = c.yellow,
})

hi(0, "DiagnosticUnderlineInfo", {
	undercurl = true,
	sp = c.blue,
})

hi(0, "DiagnosticUnderlineHint", {
	undercurl = true,
	sp = c.cyan,
})

-- ============================================================================
-- LSP REFERENCES
-- ============================================================================

hi(0, "LspReferenceText", {
	bg = c.visual_bg,
})

hi(0, "LspReferenceRead", {
	bg = c.visual_bg,
})

hi(0, "LspReferenceWrite", {
	bg = c.visual_bg,
	bold = true,
})

-- ============================================================================
-- DIFF
-- ============================================================================

hi(0, "DiffAdd", {
	fg = c.green,
	bg = "#122219",
})

hi(0, "DiffChange", {
	fg = c.yellow,
	bg = "#211E12",
})

hi(0, "DiffDelete", {
	fg = c.red,
	bg = "#25151B",
})

hi(0, "DiffText", {
	fg = c.blue,
	bg = "#182635",
})

-- ============================================================================
-- STATES
-- ============================================================================

hi(0, "Added", {
	fg = c.green,
})

hi(0, "Changed", {
	fg = c.yellow,
})

hi(0, "Removed", {
	fg = c.red,
})

-- ============================================================================
-- FOLDING
-- ============================================================================

hi(0, "Folded", {
	fg = c.muted,
	bg = "NONE",
})
