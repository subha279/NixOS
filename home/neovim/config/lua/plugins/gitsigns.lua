-- Aurora Gitsigns

local M = {}

-- Theme

local function get_theme()
	local path = vim.fn.expand("~/.config/aurora/active-theme.lua")

	local ok, theme = pcall(dofile, path)

	if not ok then
		return nil
	end

	if type(theme) ~= "table" then
		return nil
	end

	if type(theme.colors) ~= "table" then
		return nil
	end

	return theme
end

local function colors()
	local theme = get_theme()

	if theme and theme.colors then
		return theme.colors
	end

	return {}
end

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

	vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", {
		fg = c.textMuted,
		italic = true,
	})

	vim.api.nvim_set_hl(0, "GitSignsAddLn", {
		bg = c.successMuted,
	})

	vim.api.nvim_set_hl(0, "GitSignsChangeLn", {
		bg = c.warningMuted,
	})

	vim.api.nvim_set_hl(0, "GitSignsDeleteLn", {
		bg = c.errorMuted,
	})

	vim.api.nvim_set_hl(0, "GitSignsAddLnInline", {
		bg = c.successMuted,
	})

	vim.api.nvim_set_hl(0, "GitSignsChangeLnInline", {
		bg = c.warningMuted,
	})

	vim.api.nvim_set_hl(0, "GitSignsDeleteLnInline", {
		bg = c.errorMuted,
	})

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
