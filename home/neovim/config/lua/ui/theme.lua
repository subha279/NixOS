local M = {}

local sunflower = require("sunflower.theme")

local function set(name, opts)
	vim.api.nvim_set_hl(0, name, opts)
end

function M.apply()
	local theme = sunflower.get()

	if not theme then
		return
	end

	local c = theme.colors

	local s = c.syntax

	if type(s) ~= "table" then
		return
	end

	local glass = (theme.ui and theme.ui.terminalOpacity or 1.0) < 0.999

	local bg = glass and "NONE" or c.background
	local bg_dark = glass and "NONE" or c.backgroundDark

	-- Editor

	set("Normal", {
		fg = c.text,
		bg = bg,
	})

	set("NormalNC", {
		fg = c.text,
		bg = bg,
	})

	set("NormalFloat", {
		fg = c.text,
		bg = c.surface,
	})

	set("FloatBorder", {
		fg = c.borderFocus,
		bg = c.surface,
	})

	set("Cursor", {
		fg = c.accentForeground,
		bg = c.accent,
	})

	set("CursorLine", {
		bg = c.surfaceHover,
	})

	set("CursorColumn", {
		bg = c.surfaceHover,
	})

	set("ColorColumn", {
		bg = c.surface,
	})

	set("LineNr", {
		fg = c.textMuted,
	})

	set("CursorLineNr", {
		fg = c.accent,
		bold = true,
	})

	set("SignColumn", {
		fg = c.textMuted,
		bg = bg,
	})

	set("FoldColumn", {
		fg = c.textMuted,
		bg = bg,
	})

	set("Folded", {
		fg = c.textSecondary,
		bg = c.surface,
	})

	set("EndOfBuffer", {
		fg = c.background,
	})

	-- Windows / Borders

	set("WinSeparator", {
		fg = c.border,
	})

	set("VertSplit", {
		fg = c.border,
	})

	set("StatusLine", {
		fg = c.text,
		bg = bg,
	})

	set("StatusLineNC", {
		fg = c.textMuted,
		bg = bg,
	})

	set("WinBar", {
		fg = c.textSecondary,
		bg = bg,
	})

	set("WinBarNC", {
		fg = c.textMuted,
		bg = bg,
	})

	-- Search / Selection

	set("Visual", {
		fg = c.text,
		bg = c.accentMuted,
	})

	set("VisualNOS", {
		fg = c.text,
		bg = c.accentMuted,
	})

	set("Search", {
		fg = c.accentForeground,
		bg = c.accent,
		bold = true,
	})

	set("IncSearch", {
		fg = c.accentForeground,
		bg = c.accentActive,
		bold = true,
	})

	set("CurSearch", {
		fg = c.accentForeground,
		bg = c.accentActive,
		bold = true,
	})

	set("MatchParen", {
		fg = c.text,
		bg = c.accentMuted,
		bold = true,
	})

	-- Popup Menu

	set("Pmenu", {
		fg = c.text,
		bg = c.surface,
	})

	set("PmenuSel", {
		fg = c.accentForeground,
		bg = c.accentMuted,
		bold = true,
	})

	set("PmenuSbar", {
		bg = c.surfaceHover,
	})

	set("PmenuThumb", {
		bg = c.accent,
	})

	set("PmenuBorder", {
		fg = c.borderFocus,
		bg = c.surface,
	})

	-- Tabline

	set("TabLine", {
		fg = c.textSecondary,
		bg = c.surface,
	})

	set("TabLineFill", {
		fg = c.textMuted,
		bg = bg,
	})

	set("TabLineSel", {
		fg = c.accentForeground,
		bg = c.accent,
		bold = true,
	})

	-- Messages

	set("ErrorMsg", {
		fg = c.error,
		bold = true,
	})

	set("WarningMsg", {
		fg = c.warning,
		bold = true,
	})

	set("ModeMsg", {
		fg = c.accent,
		bold = true,
	})

	set("MoreMsg", {
		fg = c.info,
	})

	set("Question", {
		fg = c.success,
		bold = true,
	})

	-- Classic Vim Syntax
	-- Keep these aligned with the Treesitter semantic palette.

	set("Comment", {
		fg = s.comment,
		italic = true,
	})

	set("Constant", {
		fg = s.constant,
	})

	set("String", {
		fg = s.string,
	})

	set("Character", {
		fg = s.string,
	})

	set("Number", {
		fg = s.number,
	})

	set("Float", {
		fg = s.number,
	})

	set("Boolean", {
		fg = s.boolean,
		bold = true,
	})

	set("Identifier", {
		fg = s.variable,
	})

	set("Function", {
		fg = s.func,
		bold = true,
	})

	set("Statement", {
		fg = s.keyword,
		bold = true,
	})

	set("Conditional", {
		fg = s.keywordControl,
		bold = true,
	})

	set("Repeat", {
		fg = s.keywordControl,
		bold = true,
	})

	set("Label", {
		fg = s.property,
	})

	set("Operator", {
		fg = s.operator,
	})

	set("Keyword", {
		fg = s.keyword,
		bold = true,
	})

	set("Exception", {
		fg = s.keywordControl,
		bold = true,
	})

	set("PreProc", {
		fg = s.namespace,
	})

	set("Include", {
		fg = s.namespace,
	})

	set("Define", {
		fg = s.macro,
	})

	set("Macro", {
		fg = s.macro,
	})

	set("Type", {
		fg = s.type,
		bold = true,
	})

	set("StorageClass", {
		fg = s.keyword,
	})

	set("Structure", {
		fg = s.type,
	})

	set("Typedef", {
		fg = s.type,
	})

	set("Special", {
		fg = s.special,
	})

	set("SpecialChar", {
		fg = s.special,
	})

	set("Tag", {
		fg = s.tag,
	})

	set("Delimiter", {
		fg = s.punctuation,
	})

	set("Error", {
		fg = c.error,
		bold = true,
	})

	set("Todo", {
		fg = c.accentForeground,
		bg = c.accentMuted,
		bold = true,
	})

	-- JSONL

	set("jsonlString", {
		fg = s.string,
	})

	set("jsonlNumber", {
		fg = s.number,
	})

	set("jsonlBoolean", {
		fg = s.boolean,
		bold = true,
	})

	set("jsonlNull", {
		fg = s.constant,
	})

	set("jsonlProperty", {
		fg = s.property,
	})

	set("jsonlDelimiter", {
		fg = s.punctuation,
	})

	set("jsonlBracket", {
		fg = s.punctuation,
	})

	set("jsonlEscape", {
		fg = s.special,
		bold = true,
	})

	-- Diagnostics

	set("DiagnosticError", {
		fg = c.error,
	})

	set("DiagnosticWarn", {
		fg = c.warning,
	})

	set("DiagnosticInfo", {
		fg = c.info,
	})

	set("DiagnosticHint", {
		fg = c.success,
	})

	set("DiagnosticOk", {
		fg = c.success,
	})

	set("DiagnosticUnderlineError", {
		sp = c.error,
		undercurl = true,
	})

	set("DiagnosticUnderlineWarn", {
		sp = c.warning,
		undercurl = true,
	})

	set("DiagnosticUnderlineInfo", {
		sp = c.info,
		undercurl = true,
	})

	set("DiagnosticUnderlineHint", {
		sp = c.success,
		undercurl = true,
	})

	set("DiagnosticVirtualTextError", {
		fg = c.error,
		bg = bg_dark,
	})

	set("DiagnosticVirtualTextWarn", {
		fg = c.warning,
		bg = bg_dark,
	})

	set("DiagnosticVirtualTextInfo", {
		fg = c.info,
		bg = bg_dark,
	})

	set("DiagnosticVirtualTextHint", {
		fg = c.success,
		bg = bg_dark,
	})

	-- Diff

	set("DiffAdd", {
		fg = c.success,
		bg = c.surface,
	})

	set("DiffChange", {
		fg = c.info,
		bg = c.surface,
	})

	set("DiffDelete", {
		fg = c.error,
		bg = c.surface,
	})

	set("DiffText", {
		fg = c.accentForeground,
		bg = c.accentMuted,
	})

	-- Telescope

	set("TelescopeNormal", {
		fg = c.text,
		bg = c.surface,
	})

	set("TelescopeBorder", {
		fg = c.borderFocus,
		bg = c.surface,
	})

	set("TelescopePromptNormal", {
		fg = c.text,
		bg = c.surfaceActive,
	})

	set("TelescopePromptBorder", {
		fg = c.accent,
		bg = c.surfaceActive,
	})

	set("TelescopePromptTitle", {
		fg = c.accentForeground,
		bg = c.accent,
		bold = true,
	})

	set("TelescopePreviewTitle", {
		fg = c.text,
		bg = c.surface,
	})

	set("TelescopeResultsTitle", {
		fg = c.textSecondary,
		bg = c.surface,
	})

	set("TelescopeSelection", {
		fg = c.text,
		bg = c.surfaceActive,
		bold = true,
	})

	-- WhichKey

	set("WhichKey", {
		fg = c.accent,
	})

	set("WhichKeyGroup", {
		fg = c.info,
	})

	set("WhichKeyDesc", {
		fg = c.text,
	})

	set("WhichKeySeparator", {
		fg = c.textMuted,
	})

	set("WhichKeyFloat", {
		bg = c.surface,
	})

	-- Trouble

	set("TroubleNormal", {
		fg = c.text,
		bg = c.surface,
	})

	set("TroubleText", {
		fg = c.text,
	})

	set("TroubleCount", {
		fg = c.accent,
		bold = true,
	})

	set("TroubleCode", {
		fg = c.textMuted,
	})

	-- Dashboard

	set("DashboardHeader", {
		fg = c.accent,
	})

	set("DashboardFooter", {
		fg = c.textMuted,
	})

	set("DashboardCenter", {
		fg = c.text,
	})

	set("DashboardShortcut", {
		fg = c.info,
	})

	-- Generic

	set("Title", {
		fg = c.accent,
		bold = true,
	})

	set("Directory", {
		fg = c.accent,
	})

	set("NonText", {
		fg = c.textMuted,
	})

	set("SpecialKey", {
		fg = c.textMuted,
	})

	set("Whitespace", {
		fg = c.border,
	})
end

M.apply()

sunflower.on_change(M.apply)

local function apply_icon_themes()
	pcall(function()
		require("ui.devicons-theme").setup()
	end)

	pcall(function()
		require("ui.nvimtree-theme").setup()
	end)
end

apply_icon_themes()

sunflower.on_change(apply_icon_themes)

return M
