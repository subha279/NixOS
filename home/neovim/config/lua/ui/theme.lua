-- ============================================================================
-- Aurora UI Theme
-- ============================================================================

local ok, err = pcall(vim.cmd.colorscheme, "aurora")

if not ok then
	vim.notify("Aurora colorscheme could not be loaded\n" .. tostring(err), vim.log.levels.WARN)
end

-- Apply plugin-specific highlights after the colorscheme.
vim.schedule(function()
	require("ui.nvimtree-theme").setup()
end)
