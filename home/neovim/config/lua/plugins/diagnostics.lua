-- ============================================================================
-- Aurora Native Diagnostics
-- ============================================================================
--
-- Uses Neovim's built-in quickfix/location-list UI instead of Trouble.
-- The existing diagnostic keybindings are intentionally preserved.
--
-- ============================================================================

local M = {}

local function open_workspace_diagnostics()
	vim.diagnostic.setqflist({
		open = true,
		title = "Diagnostics",
	})
end

local function open_buffer_diagnostics()
	vim.diagnostic.setloclist({
		open = true,
		title = "Buffer diagnostics",
	})
end

local function open_document_symbols()
	local ok, builtin = pcall(require, "telescope.builtin")

	if not ok then
		vim.notify("Telescope is unavailable", vim.log.levels.WARN)
		return
	end

	builtin.lsp_document_symbols()
end

local function open_list(command, empty_message)
	local ok = pcall(vim.cmd, command)

	if not ok then
		vim.notify(empty_message, vim.log.levels.INFO)
	end
end

function M.setup()
	local map = vim.keymap.set
	local opts = {
		silent = true,
		noremap = true,
	}

	map(
		"n",
		"<leader>xx",
		open_workspace_diagnostics,
		vim.tbl_extend("force", opts, {
			desc = "Diagnostics",
		})
	)

	map(
		"n",
		"<leader>xX",
		open_buffer_diagnostics,
		vim.tbl_extend("force", opts, {
			desc = "Buffer diagnostics",
		})
	)

	map(
		"n",
		"<leader>xs",
		open_document_symbols,
		vim.tbl_extend("force", opts, {
			desc = "Symbols",
		})
	)

	map(
		"n",
		"<leader>xl",
		function()
			open_list("lopen", "The location list is empty")
		end,
		vim.tbl_extend("force", opts, {
			desc = "Location list",
		})
	)

	map(
		"n",
		"<leader>xq",
		function()
			open_list("copen", "The quickfix list is empty")
		end,
		vim.tbl_extend("force", opts, {
			desc = "Quickfix",
		})
	)

	return true
end

M.setup()

return M
