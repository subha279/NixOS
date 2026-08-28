local telescope = require("telescope")
local actions = require("telescope.actions")
local builtin = require("telescope.builtin")


telescope.setup({


	defaults = {


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


		sorting_strategy = "ascending",


		prompt_prefix = " 󰍉  ",

		selection_caret = " 󰜴 ",

		entry_prefix = "   ",

		initial_mode = "insert",


		path_display = {
			"truncate",
		},


		file_ignore_patterns = {
			"%.git/",
			"node_modules/",
			"target/",
			"dist/",
			"build/",
			"result/",
		},


		mappings = {


			i = {

				["<C-j>"] =
					actions.move_selection_next,

				["<C-k>"] =
					actions.move_selection_previous,

				["<C-q>"] =
					actions.send_selected_to_qflist,

				["<Esc>"] =
					actions.close,
			},


			n = {

				["q"] =
					actions.close,

				["<Esc>"] =
					actions.close,

				["j"] =
					actions.move_selection_next,

				["k"] =
					actions.move_selection_previous,

				["<C-q>"] =
					actions.send_selected_to_qflist,
			},
		},
	},


	pickers = {


		find_files = {
			hidden = false,
			no_ignore = false,
			follow = true,
		},


		buffers = {
			sort_lastused = true,
			ignore_current_buffer = false,
			theme = "dropdown",
		},


		help_tags = {
			theme = "dropdown",
		},


		commands = {
			theme = "dropdown",
		},


		diagnostics = {
			theme = "ivy",
		},
	},


	extensions = {
		fzf = {
			fuzzy = true,

			override_generic_sorter = true,
			override_file_sorter = true,

			case_mode = "smart_case",
		},
	},
})

pcall(telescope.load_extension, "fzf")


local map = vim.keymap.set

local opts = {
	noremap = true,
	silent = true,
}


map(
	"n",
	"<leader>ff",
	builtin.find_files,
	vim.tbl_extend("force", opts, {
		desc = "Find files",
	})
)


map(
	"n",
	"<leader>fg",
	builtin.live_grep,
	vim.tbl_extend("force", opts, {
		desc = "Live grep",
	})
)


map(
	"n",
	"<leader>fb",
	builtin.buffers,
	vim.tbl_extend("force", opts, {
		desc = "Buffers",
	})
)


map(
	"n",
	"<leader>fr",
	builtin.oldfiles,
	vim.tbl_extend("force", opts, {
		desc = "Recent files",
	})
)


map(
	"n",
	"<leader>fd",
	builtin.diagnostics,
	vim.tbl_extend("force", opts, {
		desc = "Diagnostics",
	})
)


map(
	"n",
	"<leader>fh",
	builtin.help_tags,
	vim.tbl_extend("force", opts, {
		desc = "Help",
	})
)


map(
	"n",
	"<leader>fc",
	builtin.commands,
	vim.tbl_extend("force", opts, {
		desc = "Commands",
	})
)


map(
	"n",
	"<leader>fo",
	builtin.current_buffer_fuzzy_find,
	vim.tbl_extend("force", opts, {
		desc = "Search buffer",
	})
)


vim.api.nvim_create_autocmd("FileType", {
	pattern = "TelescopePrompt",

	callback = function(args)
		vim.bo[args.buf].buflisted = false
	end,
})
