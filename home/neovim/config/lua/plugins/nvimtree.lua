vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local api = require("nvim-tree.api")

local icons = require("aurora.icons")


local function on_attach(bufnr)
	local function opts(desc)
		return {
			desc = "Explorer: " .. desc,
			buffer = bufnr,
			noremap = true,
			silent = true,
			nowait = true,
		}
	end

	api.config.mappings.default_on_attach(bufnr)


	vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))

	vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))

	vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close folder"))


	vim.keymap.set("n", "P", api.node.open.preview, opts("Preview"))


	vim.keymap.set("n", "s", api.node.open.vertical, opts("Open vertical split"))

	vim.keymap.set("n", "i", api.node.open.horizontal, opts("Open horizontal split"))


	vim.keymap.set("n", "a", api.fs.create, opts("Create"))

	vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))

	vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))


	vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))

	vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))

	vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))


	vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))

	vim.keymap.set("n", "u", api.tree.change_root_to_parent, opts("Parent directory"))

	vim.keymap.set("n", ".", api.tree.change_root_to_node, opts("Set root"))

	vim.keymap.set("n", "g?", api.tree.toggle_help, opts("Help"))
end


require("nvim-tree").setup({


	view = {
		side = "left",

		width = 34,

		preserve_window_proportions = true,

		number = false,

		relativenumber = false,

		signcolumn = "yes",

		float = {
			enable = false,
		},
	},


	renderer = {
		group_empty = true,

		highlight_git = "name",

		highlight_opened_files = "name",

		root_folder_label = false,


		indent_markers = {
			enable = true,

			inline_arrows = true,

			icons = {
				corner = "╰",
				edge = "│",
				item = "├",
				bottom = "─",
				none = " ",
			},
		},


		icons = {
			show = {
				file = true,
				folder = true,
				folder_arrow = true,
				git = true,
			},

			glyphs = {
				default = "󰈚",
				symlink = "",

				folder = {
					arrow_closed = "󰅂",
					arrow_open = "󰅀",

					default = "󰉋",
					open = "󰝰",

					empty = "󰉖",
					empty_open = "󰷏",

					symlink = "",
					symlink_open = "",
				},

				git = {
					unstaged = "●",
					staged = "✓",
					unmerged = "",
					renamed = "➜",
					untracked = "★",
					deleted = "",
					ignored = "◌",
				},
			},
		},
	},


	sort = {
		sorter = "case_sensitive",

		folders_first = true,
	},


	filters = {
		dotfiles = false,

		custom = {
			"^.git$",
			"^node_modules$",
			"^target$",
			"^dist$",
			"^build$",
			"^result$",
		},

		exclude = {
			".gitignore",
		},
	},


	git = {
		enable = true,

		ignore = false,

		timeout = 400,
	},


	actions = {
		use_system_clipboard = true,

		change_dir = {
			enable = true,
		},

		open_file = {
			quit_on_open = false,

			resize_window = true,

			window_picker = {
				enable = true,

				chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
			},
		},

		remove_file = {
			close_window = true,
		},
	},


	diagnostics = {
		enable = true,

		show_on_dirs = true,

		show_on_open_dirs = true,

		debounce_delay = 50,

		icons = {
			hint = icons.diagnostics.hint,
			info = icons.diagnostics.info,
			warning = icons.diagnostics.warn,
			error = icons.diagnostics.error,
		},
	},


	update_focused_file = {
		enable = true,

		update_root = false,

		ignore_list = {},
	},


	hijack_cursor = false,

	hijack_unnamed_buffer_when_opening = false,

	sync_root_with_cwd = true,

	prefer_startup_root = true,


	on_attach = on_attach,
})


local map = vim.keymap.set

map("n", "<leader>e", api.tree.toggle, {
	desc = "Explorer: Toggle",
})

map("n", "<leader>E", api.tree.focus, {
	desc = "Explorer: Focus",
})

map("n", "<leader>ef", api.tree.find_file, {
	desc = "Explorer: Find current file",
})

map("n", "<leader>ec", api.tree.collapse_all, {
	desc = "Explorer: Collapse all",
})

map("n", "<leader>er", api.tree.reload, {
	desc = "Explorer: Refresh",
})
