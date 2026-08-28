-- Neovim Options

local opt = vim.opt

-- Numbers

opt.number = true
opt.relativenumber = true

-- Cursor / UI

opt.cursorline = true
opt.cursorcolumn = false

opt.signcolumn = "yes"

opt.showmode = false
opt.showcmd = false

opt.ruler = true

opt.laststatus = 3
opt.showtabline = 0

opt.termguicolors = true

-- Indentation

opt.expandtab = true
opt.smartindent = true
opt.autoindent = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4

opt.shiftround = true

-- Editing

opt.wrap = false
opt.linebreak = true
opt.breakindent = true
opt.inccommand = "split"

-- Search

opt.ignorecase = true
opt.smartcase = true

opt.hlsearch = true
opt.incsearch = true

-- Scrolling

opt.scrolloff = 8
opt.sidescrolloff = 8

-- Splits

opt.splitbelow = true
opt.splitright = true

-- Files

opt.backup = false
opt.writebackup = false
opt.swapfile = false

opt.undofile = true

-- Performance

opt.updatetime = 250
opt.timeoutlen = 300
opt.ttimeoutlen = 10

-- Completion

opt.completeopt = {
	"menu",
	"menuone",
	"noselect",
}

opt.pumheight = 10

-- Folding

opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldmethod = "indent"

-- Clipboard

opt.clipboard = "unnamedplus"

-- Appearance

opt.fillchars = {
	eob = " ",
	fold = " ",
	foldopen = "󰅀",
	foldclose = "󰅂",
	foldsep = " ",
}


opt.winblend = 12
opt.pumblend = 12

-- Misc

opt.mouse = "a"

opt.hidden = true
opt.confirm = true

opt.virtualedit = "block"

opt.shortmess:append("c")

-- Better command-line completion
opt.wildmode = {
	"longest",
	"full",
}

-- Case-insensitive filename completion
opt.wildignorecase = true
