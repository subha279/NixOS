-- Shared glyph set.
--
-- Diagnostic severities were specified in three places that disagreed:
--
--   lsp/init.lua        not at all -- vim.diagnostic.config set `signs = true`,
--                       so the sign column fell back to Neovim's default E/W/I/H
--                       letters while the rest of the UI used glyphs
--   plugins/lualine.lua 󰅚 󰀪 󰋽 󰌵
--   plugins/nvimtree.lua 󰅚 󰀪 󰋼 󰌵   (note the different info glyph)
--
-- One definition, so a severity looks the same in the sign column, the
-- statusline and the file tree.

local M = {}

M.diagnostics = {
	error = "󰅚",
	warn = "󰀪",
	info = "󰋽",
	hint = "󰌵",
}

-- Ordered by severity, for callers that want to iterate.
M.diagnostic_severities = {
	{ key = "error", severity = vim.diagnostic.severity.ERROR },
	{ key = "warn", severity = vim.diagnostic.severity.WARN },
	{ key = "info", severity = vim.diagnostic.severity.INFO },
	{ key = "hint", severity = vim.diagnostic.severity.HINT },
}

return M
