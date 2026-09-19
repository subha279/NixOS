-- Aurora Telescope

local telescope = require("telescope")
local actions = require("telescope.actions")
local builtin = require("telescope.builtin")

-- Telescope Setup

telescope.setup({

	-- Defaults

	defaults = {

		-- Layout

		layout_strategy = "horizontal",

		layout_config = {
			horizontal = {
				width = 0.90,
				height = 0.85,

				preview_width = 0.50,

				prompt_position = "bottom",
			},
		},

		winblend = 12,

		-- Borders

		border = true,

		borderchars = {

			prompt = {
				"─",
				"│",
				"─",
				"│",
				"╭",
				"╮",
				"╯",
				"╰",
			},

			results = {
				"─",
				"│",
				"─",
				"│",
				"╭",
				"╮",
				"╯",
				"╰",
			},

			preview = {
				"─",
				"│",
				"─",
				"│",
				"╭",
				"╮",
				"╯",
				"╰",
			},
		},

		-- Sorting

		sorting_strategy = "ascending",

		-- Prompt

		prompt_prefix = " 󰍉  ",

		selection_caret = " 󰜴 ",

		entry_prefix = "   ",

		initial_mode = "insert",

		-- Paths

		path_display = {
			"truncate",
		},

		-- Ignore noisy directories

		file_ignore_patterns = {
			"%.git/",
			"node_modules/",
			"target/",
			"dist/",
			"build/",
			"result/",
		},

		-- Mappings

		mappings = {

			-- Insert Mode

			i = {

				["<C-j>"] = actions.move_selection_next,

				["<C-k>"] = actions.move_selection_previous,

				["<C-q>"] = actions.send_selected_to_qflist,

				["<Esc>"] = actions.close,
			},

			-- Normal Mode

			n = {

				["q"] = actions.close,

				["<Esc>"] = actions.close,

				["j"] = actions.move_selection_next,

				["k"] = actions.move_selection_previous,

				["<C-q>"] = actions.send_selected_to_qflist,
			},
		},
	},

	-- Pickers

	pickers = {

		-- Find Files

		find_files = {
			hidden = false,
			no_ignore = false,
			follow = true,
		},

		-- Buffers

		buffers = {
			sort_lastused = true,
			ignore_current_buffer = false,
			theme = "dropdown",
		},

		-- Help

		help_tags = {
			theme = "dropdown",
		},

		-- Commands

		commands = {
			theme = "dropdown",
		},

		-- Diagnostics

		diagnostics = {
			theme = "ivy",
		},
	},

	-- Extensions

	extensions = {
		fzf = {
			fuzzy = true,

			override_generic_sorter = true,
			override_file_sorter = true,

			-- Matches the ignorecase + smartcase pair in core/options.lua.
			case_mode = "smart_case",
		},
	},
})

pcall(telescope.load_extension, "fzf")

-- Keymaps

local map = vim.keymap.set

map("n", "<leader>ff", builtin.find_files, {
	desc = "Find files",
})

map("n", "<leader>fg", builtin.live_grep, {
	desc = "Live grep",
})

map("n", "<leader>fb", builtin.buffers, {
	desc = "Buffers",
})

map("n", "<leader>fr", builtin.oldfiles, {
	desc = "Recent files",
})

map("n", "<leader>fd", builtin.diagnostics, {
	desc = "Diagnostics",
})

map("n", "<leader>fh", builtin.help_tags, {
	desc = "Help",
})

map("n", "<leader>fc", builtin.commands, {
	desc = "Commands",
})

map("n", "<leader>fo", builtin.current_buffer_fuzzy_find, {
	desc = "Search buffer",
})

-- Telescope Prompt

vim.api.nvim_create_autocmd("FileType", {
	pattern = "TelescopePrompt",
	callback = function(event)
		vim.bo[event.buf].buflisted = false
	end,
})
