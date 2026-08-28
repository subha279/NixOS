local group = vim.api.nvim_create_augroup("UserAutocmds", {
	clear = true,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	group = group,

	callback = function(event)
		local buf = event.buf

		if vim.bo[buf].buftype ~= "" then
			return
		end

		vim.wo.number = true
		vim.wo.relativenumber = true
		vim.wo.signcolumn = "yes"
	end,
})


vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	callback = function()
		local hl = vim.hl or vim.highlight

		hl.on_yank({
			timeout = 150,
		})
	end,
})


local keep_trailing_whitespace = {
	markdown = true,
	text = true,
	gitcommit = true,
	gitsendemail = true,
	diff = true,
	patch = true,
}

local whitespace_line_limit = 20000

vim.api.nvim_create_autocmd("BufWritePre", {
	group = group,
	callback = function(event)
		if keep_trailing_whitespace[vim.bo[event.buf].filetype] then
			return
		end

		if vim.api.nvim_buf_line_count(event.buf) > whitespace_line_limit then
			return
		end

		local view = vim.fn.winsaveview()

		vim.cmd([[keeppatterns %s/\s\+$//e]])

		vim.fn.winrestview(view)
	end,
})


vim.api.nvim_create_autocmd("BufReadPost", {
	group = group,
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')

		if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})


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
