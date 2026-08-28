-- Aurora Snacks

local M = {}

-- Setup

function M.setup()
	local ok, snacks = pcall(require, "snacks")

	if not ok then
		vim.notify("Aurora: Snacks could not be loaded\n" .. tostring(snacks), vim.log.levels.WARN)

		return false
	end

	-- Snacks LazyGit writes its generated theme here.
	vim.fn.mkdir(vim.fn.stdpath("cache"), "p")

	snacks.setup({
		-- Large Files

		bigfile = {
			enabled = true,

			notify = true,

			size = 1024 * 1024,
		},

		-- Notifications

		notifier = {
			-- Keep vim.notify on Neovim's default UI.
			enabled = false,
		},

		-- Fast File Opening

		quickfile = {
			enabled = true,
		},

		-- Scope

		scope = {
			enabled = true,

			cursor = true,

			treesitter = {
				enabled = true,
			},

			keys = {
				["[["] = {
					cursor = false,
					desc = "Previous scope",
				},

				["]]"] = {
					cursor = false,
					desc = "Next scope",
				},
			},
		},

		-- Words

		words = {
			enabled = true,

			debounce = 100,

			focus = true,
		},

		-- Indent

		indent = {
			enabled = true,

			indent = {
				char = "│",
			},

			scope = {
				enabled = true,

				char = "│",
			},

			animate = {
				enabled = false,
			},

			filter = function(buf)
				return vim.bo[buf].buftype == ""
			end,
		},
	})

	-- LazyGit

	vim.keymap.set("n", "<leader>lg", function()
		snacks.lazygit()
	end, {
		desc = "LazyGit",
	})

	return true
end

-- Initialize

M.setup()

-- No theme subscriber: snacks draws with its own linked highlight groups and
-- needs no recolouring here. Its refresh_theme() only scheduled a redraw, which
-- aurora.refresh() now does once for the whole pass.

return M
