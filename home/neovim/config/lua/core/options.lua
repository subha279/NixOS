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

opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4

opt.shiftround = true

-- Editing

opt.wrap = false
opt.linebreak = true
opt.breakindent = true
opt.autoindent = true
opt.inccommand = 'split'

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
	foldopen = "",
	foldclose = "",
	foldsep = " ",
}

-- Glass
--
-- ui/theme.lua leaves Normal unpainted when the terminal is translucent but
-- keeps floats tinted, so these soften what would be a solid slab on a
-- transparent buffer into thicker glass over thinner glass.
--
-- With Normal.bg unset, neovim has no colour of its own to blend against, so it
-- blends towards the TERMINAL's default background -- which kitty draws at
-- global.ui.terminalOpacity. That chain is kitty-specific, not a guarantee every
-- terminal makes.
--
-- 12 mirrors global.ui.editorFloatBlend. Hardcoded rather than read from
-- active-theme.lua because neovim must open on a machine where aurora has not
-- generated anything yet. Telescope sets its own -- see plugins/telescope.lua.

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
