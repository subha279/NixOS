-- Aurora Conform

local M = {}

-- Setup

function M.setup()
	local ok, conform = pcall(require, "conform")

	if not ok then
		vim.notify("Aurora: Conform could not be loaded\n" .. tostring(conform), vim.log.levels.WARN)

		return false
	end

	conform.setup({
		-- Formatters

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

		-- Formatting behavior

		format_on_save = false,

		notify_on_error = true,

		notify_no_formatters = true,

		log_level = vim.log.levels.WARN,
	})

	-- Manual formatting

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

-- IMPORTANT

M.setup()

-- No theme subscriber: conform sets no highlights. Its refresh_theme() only
-- scheduled a redraw!, which aurora.refresh() now does once for the whole pass.

return M
