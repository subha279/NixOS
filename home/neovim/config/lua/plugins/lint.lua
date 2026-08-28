local M = {}


function M.setup()
	local ok, lint = pcall(require, "lint")

	if not ok then
		vim.notify("Aurora: nvim-lint could not be loaded\n" .. tostring(lint), vim.log.levels.WARN)

		return false
	end


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


	local group = vim.api.nvim_create_augroup("AuroraNvimLint", {
		clear = true,
	})

	local function lint_now()
		if vim.bo.buftype ~= "" then
			return
		end

		if not vim.api.nvim_buf_is_valid(0) then
			return
		end

		lint.try_lint()
	end

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


	vim.keymap.set("n", "<leader>ll", function()
		lint.try_lint()
	end, {
		desc = "Lint: Run",
	})

	return true
end


M.setup()


return M
