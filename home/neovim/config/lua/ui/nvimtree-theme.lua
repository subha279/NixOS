-- ============================================================================
-- Aurora NvimTree Theme
-- ============================================================================
--
-- NvimTree-specific highlights only.
--
-- IMPORTANT:
--
-- NvimTree intentionally uses a TRANSPARENT background.
--
-- Hyprland handles the actual blur/transparency.
--
-- Do NOT give NvimTreeNormal a solid background color.
--
-- ============================================================================

local M = {}

-- ============================================================================
-- Theme Loader
-- ============================================================================

local function get_theme()
	local path = vim.fn.expand("~/.config/aurora/active-theme.lua")

	local ok, theme = pcall(dofile, path)

	if not ok then
		return nil
	end

	if type(theme) ~= "table" then
		return nil
	end

	if type(theme.colors) ~= "table" then
		return nil
	end

	return theme
end

-- ============================================================================
-- Apply NvimTree Theme
-- ============================================================================

function M.setup()
	local theme = get_theme()

	if not theme then
		return
	end

	local c = theme.colors

	-- ========================================================================
	-- Transparent Background
	-- ========================================================================
	--
	-- IMPORTANT:
	--
	-- bg = "NONE" allows the compositor to show the blurred background.
	--
	-- This is what gives NvimTree the same glass/blur appearance as the
	-- rest of the Neovim window.
	--
	-- ========================================================================

	vim.api.nvim_set_hl(0, "NvimTreeNormal", {
		fg = c.text,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeNormalNC", {
		fg = c.textSecondary,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", {
		fg = "NONE",
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", {
		fg = c.border,
		bg = "NONE",
	})

	-- ========================================================================
	-- Cursor / Selection
	-- ========================================================================

	vim.api.nvim_set_hl(0, "NvimTreeCursorLine", {
		bg = c.surfaceHover,
	})

	vim.api.nvim_set_hl(0, "NvimTreeCursorLineNr", {
		fg = c.accent,
	})

	-- ========================================================================
	-- Files
	-- ========================================================================

	vim.api.nvim_set_hl(0, "NvimTreeFileName", {
		fg = c.text,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeOpenedFile", {
		fg = c.text,
		bg = c.surfaceHover,
		bold = true,
	})

	vim.api.nvim_set_hl(0, "NvimTreeModifiedFile", {
		fg = c.warning,
		bg = "NONE",
	})

	-- ========================================================================
	-- Folder Names
	-- ========================================================================

	vim.api.nvim_set_hl(0, "NvimTreeFolderName", {
		fg = c.text,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	-- ========================================================================
	-- Folder Icons
	-- ========================================================================
	--
	-- NEVER link these to Directory.
	--
	-- They must have their own Aurora colors.
	--
	-- ========================================================================

	vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", {
		fg = c.accent,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderIcon", {
		fg = c.accentHover,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeSymlinkIcon", {
		fg = c.info,
		bg = "NONE",
	})

	-- ========================================================================
	-- Root Folder
	-- ========================================================================

	vim.api.nvim_set_hl(0, "NvimTreeRootFolder", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	-- ========================================================================
	-- Git
	-- ========================================================================

	vim.api.nvim_set_hl(0, "NvimTreeGitNew", {
		fg = c.success,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitNewIcon", {
		fg = c.success,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitDirty", {
		fg = c.warning,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitDirtyIcon", {
		fg = c.warning,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitDeleted", {
		fg = c.error,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitDeletedIcon", {
		fg = c.error,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitStaged", {
		fg = c.info,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitStagedIcon", {
		fg = c.info,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitMerge", {
		fg = c.error,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitMergeIcon", {
		fg = c.error,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitRenamed", {
		fg = c.info,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitRenamedIcon", {
		fg = c.info,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitIgnored", {
		fg = c.textMuted,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeGitIgnoredIcon", {
		fg = c.textMuted,
		bg = "NONE",
	})

	-- ========================================================================
	-- Diagnostics
	-- ========================================================================

	vim.api.nvim_set_hl(0, "NvimTreeLspDiagnosticsError", {
		fg = c.error,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeLspDiagnosticsWarning", {
		fg = c.warning,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeLspDiagnosticsInformation", {
		fg = c.info,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeLspDiagnosticsHint", {
		fg = c.success,
		bg = "NONE",
	})
end

-- ============================================================================
-- Return
-- ============================================================================

return M
