-- Sunflower Conform

local M = {}

-- Setup

function M.setup()
	local ok, conform = pcall(require, "conform")

	if not ok then
		vim.notify("Sunflower: Conform could not be loaded\n" .. tostring(conform), vim.log.levels.WARN)

		return false
	end

	local formatters = {
		jq = {
			args = { "-c", "." },
		},
	}

	conform.setup({
		formatters = formatters,
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

			jsonl = {
				"jq",
			},

			ndjson = {
				"jq",
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
end

-- IMPORTANT

M.setup()

return M
