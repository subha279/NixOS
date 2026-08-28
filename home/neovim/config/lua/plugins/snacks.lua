local M = {}


function M.setup()
	local ok, snacks = pcall(require, "snacks")

	if not ok then
		vim.notify("Aurora: Snacks could not be loaded\n" .. tostring(snacks), vim.log.levels.WARN)

		return false
	end

	vim.fn.mkdir(vim.fn.stdpath("cache"), "p")

	snacks.setup({

		bigfile = {
			enabled = true,

			notify = true,

			size = 1024 * 1024,
		},


		notifier = {
			enabled = false,
		},


		quickfile = {
			enabled = true,
		},


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


		words = {
			enabled = true,

			debounce = 100,

			focus = true,
		},


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


	vim.keymap.set("n", "<leader>lg", function()
		snacks.lazygit()
	end, {
		desc = "LazyGit",
	})

	return true
end


M.setup()


return M
