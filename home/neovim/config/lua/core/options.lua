local opt = vim.opt


opt.number = true
opt.relativenumber = true


opt.cursorline = true
opt.cursorcolumn = false

opt.signcolumn = "yes"

opt.showmode = false
opt.showcmd = false

opt.ruler = true

opt.laststatus = 3
opt.showtabline = 0

opt.termguicolors = true


opt.expandtab = true
opt.smartindent = true
opt.autoindent = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4

opt.shiftround = true


opt.wrap = false
opt.linebreak = true
opt.breakindent = true
opt.inccommand = "split"


opt.ignorecase = true
opt.smartcase = true

opt.hlsearch = true
opt.incsearch = true


opt.scrolloff = 8
opt.sidescrolloff = 8


opt.splitbelow = true
opt.splitright = true


opt.backup = false
opt.writebackup = false
opt.swapfile = false

opt.undofile = true


opt.updatetime = 250
opt.timeoutlen = 300
opt.ttimeoutlen = 10


opt.completeopt = {
	"menu",
	"menuone",
	"noselect",
}

opt.pumheight = 10


opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldmethod = "indent"


opt.clipboard = "unnamedplus"


opt.fillchars = {
	eob = " ",
	fold = " ",
	foldopen = "",
	foldclose = "",
	foldsep = " ",
}


opt.winblend = 12
opt.pumblend = 12


opt.mouse = "a"

opt.hidden = true
opt.confirm = true

opt.virtualedit = "block"

opt.shortmess:append("c")

opt.wildmode = {
	"longest",
	"full",
}

opt.wildignorecase = true
