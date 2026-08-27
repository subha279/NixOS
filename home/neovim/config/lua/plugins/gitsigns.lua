-- Aurora Gitsigns

local M = {}

-- Theme

local aurora = require("aurora.theme")

local colors = aurora.colors

-- Highlights

local function apply_highlights()
	local c = colors()

	vim.api.nvim_set_hl(0, "GitSignsAdd", {
		fg = c.success,
	})

	vim.api.nvim_set_hl(0, "GitSignsChange", {
		fg = c.warning,
	})

	vim.api.nvim_set_hl(0, "GitSignsDelete", {
		fg = c.error,
	})

	vim.api.nvim_set_hl(0, "GitSignsTopdelete", {
		fg = c.error,
	})

	vim.api.nvim_set_hl(0, "GitSignsChangedelete", {
		fg = c.warning,
	})

	-- No GitSigns*Ln / *LnInline groups here.
	--
	-- They used to be set from c.successMuted / c.warningMuted / c.errorMuted,
	-- which lib/themes.nix does not define -- accentMuted is the only *Muted
	-- colour there. Every one of them therefore resolved to bg = nil and cleared
	-- the highlight instead of setting it.
	--
	-- They are also unreachable as configured: gitsigns only uses them when
	-- `linehl` is on, and setup() below leaves it off. If you turn linehl on, add
	-- real muted variants to themes.nix (all seven themes, plus the colour list in
	-- home/theme/default.nix's themeToLua) and set them from there.

	vim.api.nvim_set_hl(0, "GitSignsAddPreview", {
		fg = c.success,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "GitSignsDeletePreview", {
		fg = c.error,
		bg = "NONE",
	})

	vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", {
		fg = c.textMuted,
		bg = "NONE",
		italic = true,
	})
end

-- Setup

function M.setup()
	local ok, gitsigns = pcall(require, "gitsigns")

	if not ok then
		return false
	end

	gitsigns.setup({
		signs = {
			add = {
				text = "│",
			},

			change = {
				text = "│",
			},

			delete = {
				text = "󰍵",
			},

			topdelete = {
				text = "‾",
			},

			changedelete = {
				text = "│",
			},
		},

		signs_staged = {
			add = {
				text = "│",
			},

			change = {
				text = "│",
			},

			delete = {
				text = "󰍵",
			},

			topdelete = {
				text = "‾",
			},

			changedelete = {
				text = "│",
			},
		},

		sign_priority = 6,

		current_line_blame = false,

		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = "eol",
			delay = 500,
			ignore_whitespace = false,
		},

		current_line_blame_formatter = " 󰊢 <author> • <summary>",

		preview_config = {
			border = "rounded",
			style = "minimal",
			relative = "cursor",
			row = 1,
			col = 1,
		},

		on_attach = function(buffer)
			local gs = package.loaded.gitsigns

			local function map(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, {
					buffer = buffer,
					silent = true,
					noremap = true,
					nowait = true,
					desc = desc,
				})
			end

			-- Hunk navigation

			map("n", "]g", gs.next_hunk, "Git: Next hunk")
			map("n", "[g", gs.prev_hunk, "Git: Previous hunk")

			-- Hunk actions

			map("n", "<leader>gh", gs.preview_hunk, "Git: Preview hunk")

			map("n", "<leader>gb", gs.blame_line, "Git: Blame line")

			map("n", "<leader>gd", gs.diffthis, "Git: Diff")

			map("n", "<leader>gr", gs.reset_hunk, "Git: Reset hunk")

			map("n", "<leader>gS", gs.stage_hunk, "Git: Stage hunk")

			-- Visual stage

			map("v", "<leader>gS", function()
				local start = vim.fn.line("v")
				local finish = vim.fn.line(".")

				if start > finish then
					start, finish = finish, start
				end

				gs.stage_hunk({
					start,
					finish,
				})
			end, "Git: Stage selection")

			-- Buffer actions

			map("n", "<leader>gR", gs.reset_buffer, "Git: Reset buffer")

			map("n", "<leader>gU", gs.undo_stage_hunk, "Git: Undo stage hunk")

			map("n", "<leader>gD", gs.diffthis, "Git: Diff buffer")
		end,
	})

	apply_highlights()

	return true
end

-- Live Aurora Theme Refresh

function M.refresh_theme()
	apply_highlights()

	local ok, gitsigns = pcall(require, "gitsigns")

	if ok then
		pcall(function()
			gitsigns.refresh()
		end)
	end

	vim.schedule(function()
		vim.cmd("redraw!")
	end)

	return true
end

-- Return

return M
