-- Aurora Dynamic Neovim Theme

local M = {}

-- Theme

local aurora = require("aurora.theme")

-- Highlight Helper

local function set(name, opts)
	vim.api.nvim_set_hl(0, name, opts)
end

-- Apply Aurora Theme

function M.apply()
	local theme = aurora.get()

	if not theme then
		return
	end

	local c = theme.colors

	-- Glass
	--
	-- Derived from the SAME knob kitty's background_opacity comes from, not a
	-- second boolean of our own: a separate flag could disagree with the
	-- terminal, giving either an editor with no background at all or an opaque
	-- slab over the wallpaper. Neither is reachable from one value.
	--
	-- < 0.999 rather than ~= 1.0 because this is a float printed by Nix and read
	-- back by Lua.
	local glass = (theme.ui and theme.ui.terminalOpacity or 1.0) < 0.999

	-- "NONE" means emit no background, so the cell keeps the terminal's -- which
	-- kitty draws at terminalOpacity. There is no transparency setting in neovim,
	-- only the choice not to paint.
	--
	-- Applied ONLY to groups that tile a whole window. In-buffer semantic
	-- highlights (CursorLine, Visual, Search, Folded, ColorColumn, Diff*) keep
	-- their real colours -- they exist to be seen against the background. Floats
	-- keep c.surface, which is also what puts them on a separate layer.
	local bg = glass and "NONE" or c.background

	-- Diagnostic virtual text is the one tiling case not painted with
	-- c.background, so it gets its own binding rather than borrowing bg, which
	-- would recolour it on the way back to opaque.
	local bgDark = glass and "NONE" or c.backgroundDark

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

	-- accentForeground is a near-background tone, so on accentMuted it sat at 1.4-2.8:1 depending on theme.
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

	-- Comments

	set("Comment", {
		fg = c.textMuted,
		italic = true,
	})

	-- Classic Vim Syntax

	set("Constant", {
		fg = c.terminalMagenta,
	})

	set("String", {
		fg = c.terminalGreen,
	})

	set("Character", {
		fg = c.terminalGreen,
	})

	set("Number", {
		fg = c.terminalYellow,
	})

	set("Float", {
		fg = c.terminalYellow,
	})

	set("Boolean", {
		fg = c.terminalYellow,
		bold = true,
	})

	set("Identifier", {
		fg = c.text,
	})

	set("Function", {
		fg = c.accent,
	})

	set("Statement", {
		fg = c.accent,
		bold = true,
	})

	set("Conditional", {
		fg = c.accent,
		bold = true,
	})

	set("Repeat", {
		fg = c.accent,
		bold = true,
	})

	set("Label", {
		fg = c.accentHover,
	})

	set("Operator", {
		fg = c.terminalCyan,
	})

	set("Keyword", {
		fg = c.accent,
		bold = true,
	})

	set("Exception", {
		fg = c.error,
		bold = true,
	})

	set("PreProc", {
		fg = c.terminalBlue,
	})

	set("Include", {
		fg = c.terminalBlue,
	})

	set("Define", {
		fg = c.terminalBlue,
	})

	set("Macro", {
		fg = c.terminalBlue,
	})

	set("Type", {
		fg = c.terminalBlue,
	})

	set("StorageClass", {
		fg = c.terminalBlue,
	})

	set("Structure", {
		fg = c.terminalBlue,
	})

	set("Typedef", {
		fg = c.terminalBlue,
	})

	set("Special", {
		fg = c.terminalCyan,
	})

	set("SpecialChar", {
		fg = c.terminalCyan,
	})

	set("Tag", {
		fg = c.accent,
	})

	set("Delimiter", {
		fg = c.textSecondary,
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

	-- Treesitter captures and LSP semantic tokens are NOT set here.
	--
	-- plugins/treesitter.lua owns every @* capture and lsp/init.lua owns
	-- @lsp.type.*. Both load after this file, so their values already won at
	-- startup and the ~50 assignments that used to sit here were dead on arrival --
	-- and actively harmful on a theme switch, because this file was refreshed while
	-- treesitter was not, so @* briefly took these colours instead.
	--
	-- @variable.member moved to plugins/treesitter.lua and @lsp.type.struct to
	-- lsp/init.lua; they were the only groups here that no other file set. The
	-- legacy captures @conditional, @repeat, @exception and @namespace are simply
	-- gone: Neovim stopped emitting them in 0.9, and their replacements
	-- (@keyword.conditional, @keyword.repeat, @keyword.exception, @module) are all
	-- set by plugins/treesitter.lua.

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
		bg = bgDark,
	})

	set("DiagnosticVirtualTextWarn", {
		fg = c.warning,
		bg = bgDark,
	})

	set("DiagnosticVirtualTextInfo", {
		fg = c.info,
		bg = bgDark,
	})

	set("DiagnosticVirtualTextHint", {
		fg = c.success,
		bg = bgDark,
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

	-- GitSigns groups are NOT set here.
	--
	-- plugins/gitsigns.lua owns them, loads later, and set the same three groups to
	-- the same three colours, so this was a verbatim duplicate.

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

	-- Which-Key

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

	-- BlinkCmp groups are NOT set here.
	--
	-- plugins/blink.lua owns them and loads earlier, but its values differ (menus
	-- transparent rather than filled with c.surface), so these seven assignments
	-- were silently reverting its choices whenever this file re-applied.
	--
	-- BlinkCmpLabelMatch and the base BlinkCmpKind moved to plugins/blink.lua; they
	-- were the only groups here it did not already set.

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

	-- Generic / Miscellaneous

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

-- Apply, and re-apply on theme switch
--
-- This file used to own the refresh for the whole config: a private
-- refresh_plugins() that knew about exactly four things (itself, devicons,
-- nvimtree, lualine), plus its own reader for the active-theme pointer and its
-- own 500ms uv timer.
--
-- Two problems with that. It duplicated plugins/alpha.lua's identical timer on
-- the same file, and the list was incomplete: treesitter, LSP, gitsigns and
-- blink all colour themselves and none were refreshed, so their groups kept the
-- previous theme's colours until Neovim restarted. Since treesitter owns most
-- @* captures, that is why syntax colours drifted out of step after a switch.
--
-- Now every module registers itself with aurora.theme, which owns the single
-- watcher and calls subscribers in registration order.

M.apply()

aurora.on_change(M.apply)

-- devicons-theme and nvimtree-theme are pure highlight modules with no setup of
-- their own, so this file drives them: once at startup, and again on change.

local function apply_icon_themes()
	pcall(function()
		require("ui.devicons-theme").setup()
	end)

	pcall(function()
		require("ui.nvimtree-theme").setup()
	end)
end

apply_icon_themes()

aurora.on_change(apply_icon_themes)

-- Return

return M
