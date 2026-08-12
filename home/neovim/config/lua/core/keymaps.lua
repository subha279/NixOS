-- ============================================================================
-- Core Keymaps
-- ============================================================================

local map = vim.keymap.set

local opts = {
	silent = true,
	noremap = true,
}

-- ============================================================================
-- General
-- ============================================================================

map("n", "<Esc>", "<cmd>nohlsearch<cr>", {
	desc = "Clear search",
})

-- ============================================================================
-- Buffers
-- ============================================================================

map("n", "<leader>bn", "<cmd>bnext<cr>", {
	desc = "Next buffer",
})

map("n", "<leader>bp", "<cmd>bprevious<cr>", {
	desc = "Previous buffer",
})

map("n", "<leader>bd", "<cmd>bdelete<cr>", {
	desc = "Delete buffer",
})

map("n", "<leader>bb", "<cmd>Telescope buffers<cr>", {
	desc = "Buffers",
})

-- ============================================================================
-- Windows
-- ============================================================================

map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

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

-- ============================================================================
-- Window resizing
-- ============================================================================

map("n", "<C-Up>", "<cmd>resize +2<cr>", opts)
map("n", "<C-Down>", "<cmd>resize -2<cr>", opts)
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", opts)
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", opts)

-- ============================================================================
-- Tabs
-- ============================================================================

map("n", "<leader>tn", "<cmd>tabnew<cr>", {
	desc = "New tab",
})

map("n", "<leader>tc", "<cmd>tabclose<cr>", {
	desc = "Close tab",
})

map("n", "<leader>tl", "<cmd>tabnext<cr>", {
	desc = "Next tab",
})

map("n", "<leader>th", "<cmd>tabprevious<cr>", {
	desc = "Previous tab",
})

-- ============================================================================
-- Movement
-- ============================================================================

map("n", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)

map("n", "n", "nzzzv", opts)
map("n", "N", "Nzzzv", opts)

-- ============================================================================
-- Visual editing
-- ============================================================================

map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

map("v", "J", ":m '>+1<CR>gv=gv", opts)
map("v", "K", ":m '<-2<CR>gv=gv", opts)

map("x", "<leader>p", '"_dP', {
	desc = "Paste without yank",
})

map("n", "<leader>dd", '"_dd', {
	desc = "Delete without yank",
})

-- ============================================================================
-- Terminal
-- ============================================================================

map("n", "<leader>tt", "<cmd>botright split | terminal<cr>", {
	desc = "Terminal",
})

map("t", "<Esc><Esc>", "<C-\\><C-n>", {
	desc = "Exit terminal mode",
})

map("t", "<C-h>", "<C-\\><C-n><C-w>h", opts)
map("t", "<C-j>", "<C-\\><C-n><C-w>j", opts)
map("t", "<C-k>", "<C-\\><C-n><C-w>k", opts)
map("t", "<C-l>", "<C-\\><C-n><C-w>l", opts)

-- ============================================================================
-- Quickfix
-- ============================================================================

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

-- ============================================================================
-- Command history
-- ============================================================================

map("n", "<leader>:", "q:", {
	desc = "Command history",
})

map("n", "<leader>/", "q/", {
	desc = "Search history",
})

-- ============================================================================
-- Help
-- ============================================================================

map("n", "<leader>hh", "<cmd>Telescope help_tags<cr>", {
	desc = "Help",
})
