local M = {}


local aurora = require("aurora.theme")


function M.setup()
	local theme = aurora.get()

	if not theme then
		return
	end

	local c = theme.colors


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


	vim.api.nvim_set_hl(0, "NvimTreeCursorLine", {
		bg = c.surfaceHover,
	})

	vim.api.nvim_set_hl(0, "NvimTreeCursorLineNr", {
		fg = c.accent,
	})


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


	vim.api.nvim_set_hl(0, "NvimTreeFolderName", {
		fg = c.text,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})


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


	vim.api.nvim_set_hl(0, "NvimTreeRootFolder", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})


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


return M
