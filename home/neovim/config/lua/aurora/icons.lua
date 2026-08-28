local M = {}

M.diagnostics = {
	error = "󰅚",
	warn = "󰀪",
	info = "󰋽",
	hint = "󰌵",
}

M.diagnostic_severities = {
	{ key = "error", severity = vim.diagnostic.severity.ERROR },
	{ key = "warn", severity = vim.diagnostic.severity.WARN },
	{ key = "info", severity = vim.diagnostic.severity.INFO },
	{ key = "hint", severity = vim.diagnostic.severity.HINT },
}

return M
