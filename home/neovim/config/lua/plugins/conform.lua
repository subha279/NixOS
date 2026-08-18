-- ============================================================================
-- Aurora Conform
-- ============================================================================
--
-- Formatting engine.
--
-- Conform owns:
--
--   • Formatting
--   • Formatter selection
--   • Manual formatting
--   • Optional format-on-save
--
-- Diagnostics/colors remain owned by:
--
--   • Native LSP
--   • nvim-lint
--   • Aurora theme
--
-- ============================================================================

local M = {}

-- ============================================================================
-- Setup
-- ============================================================================

function M.setup()
	local ok, conform = pcall(require, "conform")

	if not ok then
		vim.notify("Aurora: Conform could not be loaded\n" .. tostring(conform), vim.log.levels.WARN)

		return false
	end

	conform.setup({
		-- ======================================================================
		-- Formatters
		-- ======================================================================

		formatters_by_ft = {
			lua = {
				"stylua",
			},

			rust = {
				"rustfmt",
			},

			python = {
				"ruff_format",
			},

			javascript = {
				"prettier",
			},

			javascriptreact = {
				"prettier",
			},

			typescript = {
				"prettier",
			},

			typescriptreact = {
				"prettier",
			},

			html = {
				"prettier",
			},

			qml = {
				"qmlformat",
			},

			css = {
				"prettier",
			},

			json = {
				"prettier",
			},

			yaml = {
				"prettier",
			},

			markdown = {
				"prettier",
			},

			nix = {
				"nixfmt",
			},

			sh = {
				"shfmt",
			},

			bash = {
				"shfmt",
			},

			toml = {
				"taplo",
			},

			c = {
				"clang_format",
			},

			cpp = {
				"clang_format",
			},
		},

		-- ======================================================================
		-- Formatting behavior
		-- ======================================================================

		format_on_save = false,

		notify_on_error = true,

		notify_no_formatters = true,

		log_level = vim.log.levels.WARN,
	})

	-- ========================================================================
	-- Manual formatting
	-- ========================================================================

	vim.keymap.set({ "n", "v" }, "<leader>gf", function()
		conform.format({
			async = false,

			lsp_format = "fallback",
		})
	end, {
		desc = "Format",
	})

	return true
end

-- ============================================================================
-- Live Aurora Refresh
-- ============================================================================
--
-- Conform itself does not own theme colors.
-- This function exists so the Aurora refresh architecture can safely call:
--
--     require("plugins.conform").refresh_theme()
--
-- without errors.
--
-- ============================================================================

function M.refresh_theme()
	vim.schedule(function()
		vim.cmd("redraw!")
	end)

	return true
end

-- ============================================================================
-- IMPORTANT
-- ============================================================================
--
-- init.lua loads this module directly:
--
--     require("plugins.conform")
--
-- ============================================================================

M.setup()

return M
