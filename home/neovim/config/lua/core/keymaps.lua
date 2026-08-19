-- ============================================================================
-- Aurora Core Keymaps
-- ============================================================================
--
-- Core/editor mappings only.
--
-- Plugin-specific mappings belong to their respective modules.
--
-- Examples:
--
--   Telescope  -> plugins/telescope.lua
--   NvimTree   -> plugins/nvimtree.lua
--   LSP        -> lsp/*
--   Which-Key  -> plugins/whichkey.lua
--
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

-- ============================================================================
-- Windows
-- ============================================================================

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
-- Window Resizing
-- ============================================================================

map("n", "<C-Up>", "<cmd>resize +2<cr>", {
	desc = "Increase height",
})

map("n", "<C-Down>", "<cmd>resize -2<cr>", {
	desc = "Decrease height",
})

map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", {
	desc = "Decrease width",
})

map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", {
	desc = "Increase width",
})

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

map("n", "<C-d>", "<C-d>zz", {
	desc = "Half-page down",
})

map("n", "<C-u>", "<C-u>zz", {
	desc = "Half-page up",
})

map("n", "n", "nzzzv", {
	desc = "Next search result",
})

map("n", "N", "Nzzzv", {
	desc = "Previous search result",
})

-- ============================================================================
-- Visual Editing
-- ============================================================================

map("v", "<", "<gv", opts)

map("v", ">", ">gv", opts)

map("v", "J", ":m '>+1<CR>gv=gv", {
	desc = "Move selection down",
})

map("v", "K", ":m '<-2<CR>gv=gv", {
	desc = "Move selection up",
})

-- ============================================================================
-- Paste / Delete Without Yank
-- ============================================================================

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
	desc = "Open terminal",
})

map("t", "<Esc><Esc>", "<C-\\><C-n>", {
	desc = "Exit terminal mode",
})

-- Terminal window navigation

map("t", "<C-h>", "<C-\\><C-n><C-w>h", {
	desc = "Move left",
})

map("t", "<C-j>", "<C-\\><C-n><C-w>j", {
	desc = "Move down",
})

map("t", "<C-k>", "<C-\\><C-n><C-w>k", {
	desc = "Move up",
})

map("t", "<C-l>", "<C-\\><C-n><C-w>l", {
	desc = "Move right",
})

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
-- Command History
-- ============================================================================

map("n", "<leader>:", "q:", {
	desc = "Command history",
})

map("n", "<leader>/", "q/", {
	desc = "Search history",
})

-- Others
map(
	"n",
	"<leader>rb",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Rename Same Many Words Together In the Cursor" }
)

-- Move selected lines up/down
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Selected Line Up" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Selected Line Down" })

-- Center screen on scroll
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Center screen on search
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

map("n", "<leader>m", "<cmd>NvimTreeFocus<CR>", { desc = "Focus file explorer" })
