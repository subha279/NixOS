-- ============================================================================
-- Aurora Trouble
-- ============================================================================
--
-- Minimal • Diagnostic-focused • Aurora-native
--
-- Theme source:
--
--     ~/.config/aurora/active-theme.lua
--
-- Features:
--
--   • Diagnostics
--   • Buffer diagnostics
--   • Symbols
--   • Location list
--   • Quickfix
--   • Aurora dynamic colors
--   • Live theme refresh
--
-- ============================================================================

local M = {}

-- ============================================================================
-- Theme
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

local function colors()
	local theme = get_theme()

	if theme and theme.colors then
		return theme.colors
	end

	return {}
end

-- ============================================================================
-- Highlights
-- ============================================================================

local function apply_highlights()
	local c = colors()

	-- ========================================================================
	-- Main
	-- ========================================================================

	vim.api.nvim_set_hl(0, "TroubleNormal", {
		fg = c.text,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroubleText", {
		fg = c.text,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroubleCount", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	vim.api.nvim_set_hl(0, "TroubleSource", {
		fg = c.textMuted,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroubleCode", {
		fg = c.textMuted,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroubleLocation", {
		fg = c.textSecondary,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroubleFoldIcon", {
		fg = c.accent,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroubleIndent", {
		fg = c.border,
		bg = "NONE",
	})

	-- ========================================================================
	-- Diagnostic Text
	-- ========================================================================

	vim.api.nvim_set_hl(0, "TroubleTextError", {
		fg = c.error,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroubleTextWarning", {
		fg = c.warning,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroubleTextInformation", {
		fg = c.info,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroubleTextHint", {
		fg = c.success,
		bg = "NONE",
	})

	-- ========================================================================
	-- Diagnostic Icons
	-- ========================================================================

	vim.api.nvim_set_hl(0, "TroubleIconError", {
		fg = c.error,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroubleIconWarning", {
		fg = c.warning,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroubleIconInformation", {
		fg = c.info,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroubleIconHint", {
		fg = c.success,
		bg = "NONE",
	})

	-- ========================================================================
	-- Diagnostic Groups
	-- ========================================================================

	vim.api.nvim_set_hl(0, "TroubleDiagnosticError", {
		fg = c.error,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroubleDiagnosticWarn", {
		fg = c.warning,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroubleDiagnosticInfo", {
		fg = c.info,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroubleDiagnosticHint", {
		fg = c.success,
		bg = "NONE",
	})

	-- ========================================================================
	-- Preview
	-- ========================================================================

	vim.api.nvim_set_hl(0, "TroublePreview", {
		fg = c.text,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroublePreviewBorder", {
		fg = c.borderFocus,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroublePreviewNormal", {
		fg = c.text,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "TroublePreviewTitle", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})
end

-- ============================================================================
-- Setup
-- ============================================================================

function M.setup()
	local ok, trouble = pcall(require, "trouble")

	if not ok then
		vim.notify("Aurora: Trouble could not be loaded\n" .. tostring(trouble), vim.log.levels.WARN)

		return false
	end

	trouble.setup({
		auto_close = true,

		auto_preview = false,

		focus = true,

		follow = true,

		indent_lines = true,

		use_diagnostic_signs = true,

		modes = {
			diagnostics = {
				mode = "diagnostics",

				focus = true,

				preview = {
					type = "float",

					relative = "editor",

					border = "rounded",

					size = {
						width = 0.6,
						height = 0.5,
					},
				},
			},

			diagnostics_buffer = {
				mode = "diagnostics",

				filter = {
					buf = 0,
				},

				preview = {
					type = "float",

					relative = "editor",

					border = "rounded",
				},
			},

			symbols = {
				mode = "symbols",

				focus = false,

				win = {
					position = "right",
				},
			},

			loclist = {
				mode = "loclist",
			},

			qflist = {
				mode = "qflist",
			},
		},

		keys = {
			["q"] = "close",
			["<Esc>"] = "close",
			["<CR>"] = "jump",
			["o"] = "jump",
			["r"] = "refresh",
			["R"] = "toggle_refresh",
			["K"] = "prev",
			["J"] = "next",
			["p"] = "preview",
			["P"] = "toggle_preview",
			["a"] = "jump_close",
		},
	})

	apply_highlights()

	return true
end

-- ============================================================================
-- Live Aurora Theme Refresh
-- ============================================================================

function M.refresh_theme()
	apply_highlights()

	vim.schedule(function()
		vim.cmd("redraw!")
		vim.cmd("redrawstatus!")
	end)

	return true
end

-- ============================================================================
-- Keymaps
-- ============================================================================

local map = vim.keymap.set

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", {
	desc = "Diagnostics",
})

map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", {
	desc = "Buffer diagnostics",
})

map("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", {
	desc = "Symbols",
})

map("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", {
	desc = "Location list",
})

map("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", {
	desc = "Quickfix",
})

-- ============================================================================
-- IMPORTANT
-- ============================================================================
--
-- init.lua loads this module as:
--
--     require("plugins.trouble")
--
-- Therefore setup MUST be executed here.
--
-- ============================================================================

M.setup()

-- ============================================================================
-- Return
-- ============================================================================

return M
