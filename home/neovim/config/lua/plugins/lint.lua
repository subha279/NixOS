-- Aurora nvim-lint

local M = {}

-- Setup

function M.setup()
	local ok, lint = pcall(require, "lint")

	if not ok then
		vim.notify("Aurora: nvim-lint could not be loaded\n" .. tostring(lint), vim.log.levels.WARN)

		return false
	end

	-- Linters

	lint.linters_by_ft = {
		python = {
			"ruff",
		},

		javascript = {
			"eslint_d",
		},

		javascriptreact = {
			"eslint_d",
		},

		typescript = {
			"eslint_d",
		},

		typescriptreact = {
			"eslint_d",
		},

		sh = {
			"shellcheck",
		},

		bash = {
			"shellcheck",
		},
	}

	-- Automatic linting

	local group = vim.api.nvim_create_augroup("AuroraNvimLint", {
		clear = true,
	})

	vim.api.nvim_create_autocmd({
		"BufWritePost",
		"BufReadPost",
		"InsertLeave",
	}, {
		group = group,

		callback = function()
			-- Only lint normal file buffers.
			if vim.bo.buftype ~= "" then
				return
			end

			if not vim.api.nvim_buf_is_valid(0) then
				return
			end

			lint.try_lint()
		end,
	})

	-- Manual lint

	vim.keymap.set("n", "<leader>ll", function()
		lint.try_lint()
	end, {
		desc = "Lint: Run",
	})

	return true
end

-- Live Aurora Refresh

function M.refresh_theme()
	vim.schedule(function()
		vim.cmd("redraw!")
		vim.cmd("redrawstatus!")
	end)

	return true
end

-- IMPORTANT

M.setup()

return M
