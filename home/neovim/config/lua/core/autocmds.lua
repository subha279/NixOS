-- Autocommands

local group = vim.api.nvim_create_augroup("UserAutocmds", {
	clear = true,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	group = group,

	callback = function(event)
		local buf = event.buf

		-- Only normal editable buffers.
		if vim.bo[buf].buftype ~= "" then
			return
		end

		-- Normal editing view.
		vim.wo.number = true
		vim.wo.relativenumber = true
		vim.wo.signcolumn = "yes"
	end,
})

-- Highlight yanked text

vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	callback = function()
		vim.highlight.on_yank({
			timeout = 150,
		})
	end,
})

-- Remove trailing whitespace

vim.api.nvim_create_autocmd("BufWritePre", {
	group = group,
	callback = function()
		local view = vim.fn.winsaveview()

		vim.cmd([[%s/\s\+$//e]])

		vim.fn.winrestview(view)
	end,
})

-- Remember cursor position

vim.api.nvim_create_autocmd("BufReadPost", {
	group = group,
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')

		if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Close temporary windows with q

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = {
		"help",
		"qf",
		"query",
		"man",
		"notify",
		"lspinfo",
	},
	callback = function(event)
		vim.keymap.set("n", "q", "<cmd>close<cr>", {
			buffer = event.buf,
			silent = true,
		})
	end,
})
