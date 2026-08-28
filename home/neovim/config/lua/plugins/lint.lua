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

	-- Debounced, and no longer on InsertLeave.
	--
	-- try_lint() spawns a linter process per matching filetype -- eslint_d,
	-- shellcheck, ruff. Firing on InsertLeave meant a spawn every single time you
	-- left insert mode, which in normal editing is constant: dozens of processes
	-- a minute, each one able to stall the UI briefly while it starts.
	--
	-- Save and open are the points where linting is actually wanted. The debounce
	-- then collapses bursts, since BufWritePost fires per buffer and :wa on a
	-- handful of files would otherwise start a linter for each at once.
	local function lint_now()
		-- Only lint normal file buffers.
		if vim.bo.buftype ~= "" then
			return
		end

		if not vim.api.nvim_buf_is_valid(0) then
			return
		end

		lint.try_lint()
	end

	-- One reusable timer, restarted on each event, rather than a new handle per
	-- event that would need closing.
	local debounce = vim.uv.new_timer()

	local function schedule_lint()
		if not debounce then
			lint_now()
			return
		end

		debounce:stop()
		debounce:start(120, 0, vim.schedule_wrap(lint_now))
	end

	vim.api.nvim_create_autocmd({
		"BufWritePost",
		"BufReadPost",
	}, {
		group = group,

		callback = schedule_lint,
	})

	-- Manual lint

	vim.keymap.set("n", "<leader>ll", function()
		lint.try_lint()
	end, {
		desc = "Lint: Run",
	})

	return true
end

-- IMPORTANT

M.setup()

-- No theme subscriber: nvim-lint sets no highlights of its own (diagnostics are
-- coloured by lsp/init.lua). Its refresh_theme() only scheduled a redraw, which
-- aurora.refresh() now does once for the whole pass.

return M
