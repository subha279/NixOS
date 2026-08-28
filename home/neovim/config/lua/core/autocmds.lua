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
		-- vim.hl replaced vim.highlight in 0.11; vim.highlight still works but is
		-- deprecated and emits a warning. Prefer the new name where present.
		local hl = vim.hl or vim.highlight

		hl.on_yank({
			timeout = 150,
		})
	end,
})

-- Remove trailing whitespace
--
-- Skipped for filetypes where trailing space is meaningful or expected:
-- markdown treats two trailing spaces as a hard line break, so stripping them
-- silently reflowed documents on save.
--
-- Also skipped for very large buffers. The substitute walks the whole file on
-- every write, which is fine for source but not for a multi-megabyte log or
-- dump that snacks.bigfile has already put into a stripped-down mode.

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
