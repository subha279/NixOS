-- Aurora Alpha Dashboard

-- Load Alpha

local ok_alpha, alpha = pcall(require, "alpha")

if not ok_alpha then
	return
end

local ok_dashboard, dashboard = pcall(require, "alpha.themes.dashboard")

if not ok_dashboard then
	return
end

-- Startup Timer

local function startup_time()
	if not vim.g.aurora_startup_time then
		return "󰅐  Ready"
	end

	local elapsed = (vim.uv.hrtime() - vim.g.aurora_startup_time) / 1000000

	if elapsed < 1000 then
		return string.format("󰅐  Ready in %.0f ms", elapsed)
	end

	return string.format("󰅐  Ready in %.2f s", elapsed / 1000)
end

-- Aurora Theme

local aurora = require("aurora.theme")

-- Apply Aurora Colors

local function apply_theme()
	local theme = aurora.get()

	if not theme then
		return
	end

	local c = theme.colors

	vim.api.nvim_set_hl(0, "AlphaHeader", {
		fg = c.accent,
		bold = true,
	})

	vim.api.nvim_set_hl(0, "AlphaButtons", {
		fg = c.text,
	})

	vim.api.nvim_set_hl(0, "AlphaShortcut", {
		fg = c.accent,
		bold = true,
	})

	vim.api.nvim_set_hl(0, "AlphaFooter", {
		fg = c.textMuted,
	})
end

-- NEOVIM ASCII ART

dashboard.section.header.val = {

	[[                                                                       ]],
	[[                                                                       ]],
	[[                                                                       ]],
	[[                                                                       ]],
	[[                                                                     ]],
	[[       ████ ██████           █████      ██                     ]],
	[[      ███████████             █████                             ]],
	[[      █████████ ███████████████████ ███   ███████████   ]],
	[[     █████████  ███    █████████████ █████ ██████████████   ]],
	[[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
	[[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
	[[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
	[[                                                                       ]],
	[[                                                                       ]],
	[[                                                                       ]],
}

-- Buttons

dashboard.section.buttons.val = {

	dashboard.button("e", "󰻭  󰅂  New File", "<cmd>ene<CR>"),

	dashboard.button("q", "󰈆  󰅂  Quit NVIM", "<cmd>qa<CR>"),
}

-- Footer

dashboard.section.footer.val = {

	"",
	"",
	startup_time(),
}

-- Highlights

dashboard.section.header.opts.hl = "AlphaHeader"

dashboard.section.buttons.opts.hl = "AlphaButtons"

dashboard.section.footer.opts.hl = "AlphaFooter"

-- Layout

dashboard.opts.layout = {

	{
		type = "padding",
		val = 3,
	},

	dashboard.section.header,

	{
		type = "padding",
		val = 2,
	},

	dashboard.section.buttons,

	{
		type = "padding",
		val = 2,
	},

	dashboard.section.footer,
}

-- Apply Theme

apply_theme()

-- Initialize Alpha

alpha.setup(dashboard.opts)

-- Alpha Buffer

vim.api.nvim_create_autocmd("FileType", {
	pattern = "alpha",

	callback = function(args)
		local win = vim.api.nvim_get_current_win()

		-- Buffer

		vim.bo[args.buf].buflisted = false
		vim.bo[args.buf].modifiable = false

		-- Window

		vim.wo[win].number = false
		vim.wo[win].relativenumber = false

		vim.wo[win].cursorline = false
		vim.wo[win].cursorcolumn = false

		vim.wo[win].signcolumn = "no"
		vim.wo[win].foldcolumn = "0"

		vim.wo[win].statuscolumn = ""

		vim.wo[win].winbar = ""
		vim.wo[win].statusline = ""

		vim.wo[win].wrap = false
		vim.wo[win].list = false
	end,
})

-- Live Aurora Theme Refresh
--
-- Registered with the shared watcher rather than running a second 500ms uv timer
-- against the same file, which is what this used to do alongside ui/theme.lua's
-- identical one.
--
-- Dropping the timer also stops the footer drifting: it recomputes elapsed time
-- from vim.g.aurora_startup_time, so polling it twice a second made the
-- "Ready in Xms" figure climb for as long as the dashboard stayed open.

aurora.on_change(function()
	apply_theme()

	if vim.bo.filetype == "alpha" then
		dashboard.section.footer.val = {
			"",
			"",
			startup_time(),
		}
	end
end)
