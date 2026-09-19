-- Core Keymaps

local map = vim.keymap.set

-- Search
map("n", "<Esc>", "<cmd>nohlsearch<cr>", {
	desc = "Clear search",
})

map("n", "n", "nzzzv", {
	desc = "Next search result",
})

map("n", "N", "Nzzzv", {
	desc = "Previous search result",
})

-- Window Navigation
map("n", "<C-h>", "<C-w>h", {
	desc = "Move left",
})

map("n", "<C-j>", "<C-w>j", {
	desc = "Move down",
})

map("n", "<C-k>", "<C-w>k", {
	desc = "Move up",
})

map("n", "<C-l>", "<C-w>l", {
	desc = "Move right",
})

-- Window Management
map("n", "<leader>ws", "<cmd>split<cr>", {
	desc = "Horizontal split",
})

map("n", "<leader>wv", "<cmd>vsplit<cr>", {
	desc = "Vertical split",
})

map("n", "<leader>wc", "<cmd>close<cr>", {
	desc = "Close window",
})

map("n", "<leader>we", "<C-w>=", {
	desc = "Equalize windows",
})

-- Scrolling
map("n", "<C-d>", "<C-d>zz", {
	desc = "Half-page down",
})

map("n", "<C-u>", "<C-u>zz", {
	desc = "Half-page up",
})

-- Visual Selection
map("v", "<", "<gv", {
	desc = "Indent left",
})

map("v", ">", ">gv", {
	desc = "Indent right",
})

map("v", "J", ":m '>+1<CR>gv=gv", {
	desc = "Move selection down",
})

map("v", "K", ":m '<-2<CR>gv=gv", {
	desc = "Move selection up",
})

-- Paste / Delete Without Yank
map("x", "<leader>p", '"_dP', {
	desc = "Paste without yank",
})

map("n", "<leader>dd", '"_dd', {
	desc = "Delete without yank",
})

-- Quickfix
map("n", "<leader>co", "<cmd>copen<cr>", {
	desc = "Quickfix open",
})

map("n", "<leader>cc", "<cmd>cclose<cr>", {
	desc = "Quickfix close",
})

map("n", "<leader>cn", "<cmd>cnext<cr>", {
	desc = "Quickfix next",
})

map("n", "<leader>cp", "<cmd>cprevious<cr>", {
	desc = "Quickfix previous",
})

-- Search / Replace Word Under Cursor
map("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {
	desc = "Replace word under cursor",
})
