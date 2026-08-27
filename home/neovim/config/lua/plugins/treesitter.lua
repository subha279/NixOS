-- Aurora Treesitter

local M = {}

-- Theme

local aurora = require("aurora.theme")

local colors = aurora.colors

-- Helper

local function set(name, opts)
	vim.api.nvim_set_hl(0, name, opts)
end

-- Treesitter Highlights

local function apply_highlights()
	local c = colors()

	-- Comments

	set("@comment", {
		fg = c.textMuted,
		bg = "NONE",
		italic = true,
	})

	set("@comment.documentation", {
		fg = c.textSecondary,
		bg = "NONE",
		italic = true,
	})

	set("@comment.todo", {
		fg = c.warning,
		bg = "NONE",
		bold = true,
	})

	set("@comment.note", {
		fg = c.info,
		bg = "NONE",
		bold = true,
	})

	set("@comment.warning", {
		fg = c.warning,
		bg = "NONE",
		bold = true,
	})

	set("@comment.error", {
		fg = c.error,
		bg = "NONE",
		bold = true,
	})

	-- Constants / Literals

	set("@constant", {
		fg = c.warning,
		bg = "NONE",
	})

	set("@constant.builtin", {
		fg = c.warning,
		bg = "NONE",
	})

	set("@constant.macro", {
		fg = c.warning,
		bg = "NONE",
	})

	set("@number", {
		fg = c.warning,
		bg = "NONE",
	})

	set("@float", {
		fg = c.warning,
		bg = "NONE",
	})

	set("@boolean", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	-- Strings

	set("@string", {
		fg = c.success,
		bg = "NONE",
	})

	set("@string.documentation", {
		fg = c.success,
		bg = "NONE",
	})

	set("@string.regex", {
		fg = c.info,
		bg = "NONE",
	})

	set("@string.escape", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	set("@string.special", {
		fg = c.accent,
		bg = "NONE",
	})

	set("@character", {
		fg = c.success,
		bg = "NONE",
	})

	set("@character.special", {
		fg = c.accent,
		bg = "NONE",
	})

	-- Keywords

	set("@keyword", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	set("@keyword.function", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	set("@keyword.operator", {
		fg = c.accent,
		bg = "NONE",
	})

	set("@keyword.return", {
		fg = c.accentHover or c.accent,
		bg = "NONE",
		bold = true,
	})

	set("@keyword.conditional", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	set("@keyword.repeat", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	set("@keyword.import", {
		fg = c.info,
		bg = "NONE",
		bold = true,
	})

	set("@keyword.exception", {
		fg = c.error,
		bg = "NONE",
		bold = true,
	})

	set("@operator", {
		fg = c.textSecondary,
		bg = "NONE",
	})

	-- Functions

	set("@function", {
		fg = c.info,
		bg = "NONE",
		bold = true,
	})

	set("@function.builtin", {
		fg = c.info,
		bg = "NONE",
	})

	set("@function.call", {
		fg = c.info,
		bg = "NONE",
	})

	set("@function.method", {
		fg = c.info,
		bg = "NONE",
		bold = true,
	})

	set("@function.method.call", {
		fg = c.info,
		bg = "NONE",
	})

	set("@constructor", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	-- Variables

	set("@variable", {
		fg = c.text,
		bg = "NONE",
	})

	set("@variable.builtin", {
		fg = c.accentHover or c.accent,
		bg = "NONE",
	})

	set("@variable.parameter", {
		fg = c.textSecondary,
		bg = "NONE",
	})

	set("@variable.parameter.builtin", {
		fg = c.accentHover or c.accent,
		bg = "NONE",
	})

	-- Properties / Fields

	set("@property", {
		fg = c.info,
		bg = "NONE",
	})

	set("@field", {
		fg = c.info,
		bg = "NONE",
	})

	-- Types

	set("@type", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	set("@type.builtin", {
		fg = c.accent,
		bg = "NONE",
	})

	set("@type.definition", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	set("@type.qualifier", {
		fg = c.accent,
		bg = "NONE",
	})

	set("@attribute", {
		fg = c.warning,
		bg = "NONE",
	})

	set("@attribute.builtin", {
		fg = c.warning,
		bg = "NONE",
	})

	-- Modules / Namespaces

	set("@module", {
		fg = c.info,
		bg = "NONE",
	})

	set("@module.builtin", {
		fg = c.info,
		bg = "NONE",
	})

	-- Punctuation

	set("@punctuation.delimiter", {
		fg = c.textSecondary,
		bg = "NONE",
	})

	set("@punctuation.bracket", {
		fg = c.textMuted,
		bg = "NONE",
	})

	set("@punctuation.special", {
		fg = c.accent,
		bg = "NONE",
	})

	-- Tags

	set("@tag", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	set("@tag.builtin", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	set("@tag.attribute", {
		fg = c.info,
		bg = "NONE",
	})

	set("@tag.delimiter", {
		fg = c.textSecondary,
		bg = "NONE",
	})

	-- Markup

	set("@markup.heading", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	set("@markup.heading.1", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	set("@markup.heading.2", {
		fg = c.info,
		bg = "NONE",
		bold = true,
	})

	set("@markup.heading.3", {
		fg = c.success,
		bg = "NONE",
		bold = true,
	})

	set("@markup.bold", {
		fg = c.text,
		bg = "NONE",
		bold = true,
	})

	set("@markup.italic", {
		fg = c.textSecondary,
		bg = "NONE",
		italic = true,
	})

	set("@markup.link", {
		fg = c.info,
		bg = "NONE",
		underline = true,
	})

	set("@markup.link.label", {
		fg = c.info,
		bg = "NONE",
		underline = true,
	})

	set("@markup.link.url", {
		fg = c.info,
		bg = "NONE",
		underline = true,
	})

	set("@markup.raw", {
		fg = c.success,
		bg = "NONE",
	})

	set("@markup.list", {
		fg = c.accent,
		bg = "NONE",
	})

	-- Labels

	set("@label", {
		fg = c.accent,
		bg = "NONE",
	})

	-- Includes / Imports

	set("@include", {
		fg = c.info,
		bg = "NONE",
		bold = true,
	})

	-- Diff

	set("@diff.plus", {
		fg = c.success,
		bg = "NONE",
	})

	set("@diff.minus", {
		fg = c.error,
		bg = "NONE",
	})

	set("@diff.delta", {
		fg = c.warning,
		bg = "NONE",
	})
end

-- Treesitter Setup

function M.setup()
	local ok, treesitter = pcall(require, "nvim-treesitter")

	if not ok then
		vim.notify("Aurora: nvim-treesitter could not be loaded\n" .. tostring(treesitter), vim.log.levels.WARN)

		return false
	end

	-- New nvim-treesitter API

	treesitter.setup({
		highlight = {
			enable = true,
		},

		indent = {
			enable = true,
		},
	})

	apply_highlights()

	return true
end

-- Live Aurora Theme Refresh

function M.refresh_theme()
	apply_highlights()

	vim.schedule(function()
		vim.cmd("redraw!")
	end)

	return true
end

-- IMPORTANT

M.setup()

-- Return

return M
