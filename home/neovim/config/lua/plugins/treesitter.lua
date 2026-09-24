-- Sunflower Treesitter

local M = {}

-- Theme

local sunflower = require("sunflower.theme")

local colors = sunflower.colors

-- Helper

local function set(name, opts)
	vim.api.nvim_set_hl(0, name, opts)
end

-- Treesitter Highlights

local function apply_highlights()
	local c = colors()
	local s = c.syntax

	if type(s) ~= "table" then
		vim.notify("Sunflower: syntax palette is unavailable", vim.log.levels.WARN)
		return
	end

	-- Comments

	set("@comment", {
		fg = s.comment,
		italic = true,
	})

	set("@comment.documentation", {
		fg = c.textSecondary,
		italic = true,
	})

	set("@comment.todo", {
		fg = c.warning,
		bold = true,
	})

	set("@comment.note", {
		fg = c.info,
		bold = true,
	})

	set("@comment.warning", {
		fg = c.warning,
		bold = true,
	})

	set("@comment.error", {
		fg = c.error,
		bold = true,
	})

	-- Constants / Literals

	set("@constant", {
		fg = s.constant,
	})

	set("@constant.builtin", {
		fg = s.builtin,
		bold = true,
	})

	set("@constant.macro", {
		fg = s.macro,
		bold = true,
	})

	set("@number", {
		fg = s.number,
	})

	set("@float", {
		fg = s.number,
	})

	set("@boolean", {
		fg = s.boolean,
		bold = true,
	})

	-- Strings

	set("@string", {
		fg = s.string,
	})

	set("@string.documentation", {
		fg = s.string,
		italic = true,
	})

	set("@string.regex", {
		fg = s.regex,
	})

	set("@string.escape", {
		fg = s.special,
		bold = true,
	})

	set("@string.special", {
		fg = s.special,
	})

	set("@character", {
		fg = s.string,
	})

	set("@character.special", {
		fg = s.special,
	})

	-- Keywords

	set("@keyword", {
		fg = s.keyword,
		bold = true,
	})

	set("@keyword.function", {
		fg = s.keyword,
		bold = true,
	})

	set("@keyword.operator", {
		fg = s.operator,
	})

	set("@keyword.return", {
		fg = s.keywordControl,
		bold = true,
	})

	set("@keyword.conditional", {
		fg = s.keywordControl,
		bold = true,
	})

	set("@keyword.repeat", {
		fg = s.keywordControl,
		bold = true,
	})

	set("@keyword.import", {
		fg = s.keyword,
		bold = true,
	})

	set("@keyword.exception", {
		fg = s.keywordControl,
		bold = true,
	})

	set("@operator", {
		fg = s.operator,
	})

	-- Functions

	set("@function", {
		fg = s.func,
		bold = true,
	})

	set("@function.builtin", {
		fg = s.builtin,
	})

	set("@function.call", {
		fg = s.func,
	})

	set("@function.method", {
		fg = s.method,
		bold = true,
	})

	set("@function.method.call", {
		fg = s.method,
	})

	set("@method", {
		fg = s.method,
		bold = true,
	})

	set("@method.call", {
		fg = s.method,
	})

	set("@constructor", {
		fg = s.type,
		bold = true,
	})

	-- Variables

	set("@variable", {
		fg = s.variable,
	})

	set("@variable.builtin", {
		fg = s.builtin,
	})

	set("@variable.parameter", {
		fg = s.parameter,
		italic = true,
	})

	set("@variable.parameter.builtin", {
		fg = s.builtin,
		italic = true,
	})

	-- Properties / Fields

	set("@property", {
		fg = s.property,
	})

	set("@field", {
		fg = s.property,
	})

	set("@variable.member", {
		fg = s.property,
	})

	-- Types

	set("@type", {
		fg = s.type,
		bold = true,
	})

	set("@type.builtin", {
		fg = s.builtin,
	})

	set("@type.definition", {
		fg = s.type,
		bold = true,
	})

	set("@type.qualifier", {
		fg = s.keyword,
	})

	set("@attribute", {
		fg = s.attribute,
	})

	set("@attribute.builtin", {
		fg = s.attribute,
		bold = true,
	})

	-- Modules / Namespaces

	set("@module", {
		fg = s.namespace,
	})

	set("@module.builtin", {
		fg = s.builtin,
	})

	set("@namespace", {
		fg = s.namespace,
	})

	-- Punctuation

	set("@punctuation.delimiter", {
		fg = s.punctuation,
	})

	set("@punctuation.bracket", {
		fg = s.punctuation,
	})

	set("@punctuation.special", {
		fg = s.special,
	})

	-- Tags

	set("@tag", {
		fg = s.tag,
		bold = true,
	})

	set("@tag.builtin", {
		fg = s.tag,
		bold = true,
	})

	set("@tag.attribute", {
		fg = s.attribute,
	})

	set("@tag.delimiter", {
		fg = s.punctuation,
	})

	-- Markup

	set("@markup.heading", {
		fg = s.keyword,
		bold = true,
	})

	set("@markup.heading.1", {
		fg = s.func,
		bold = true,
	})

	set("@markup.heading.2", {
		fg = s.type,
		bold = true,
	})

	set("@markup.heading.3", {
		fg = s.property,
		bold = true,
	})

	set("@markup.bold", {
		fg = c.text,
		bold = true,
	})

	set("@markup.italic", {
		fg = c.textSecondary,
		italic = true,
	})

	set("@markup.link", {
		fg = s.property,
		underline = true,
	})

	set("@markup.link.label", {
		fg = s.property,
		underline = true,
	})

	set("@markup.link.url", {
		fg = s.special,
		underline = true,
	})

	set("@markup.raw", {
		fg = s.string,
	})

	set("@markup.list", {
		fg = s.keyword,
	})

	-- Labels

	set("@label", {
		fg = s.property,
	})

	-- Includes / Imports

	set("@include", {
		fg = s.namespace,
		bold = true,
	})

	-- Regex / Special

	set("@string.regexp", {
		fg = s.regex,
	})

	set("@special", {
		fg = s.special,
	})

	set("@macro", {
		fg = s.macro,
		bold = true,
	})

	-- Diff

	set("@diff.plus", {
		fg = c.success,
	})

	set("@diff.minus", {
		fg = c.error,
	})

	set("@diff.delta", {
		fg = c.warning,
	})
end

-- Treesitter Setup

function M.setup()
	local ok, treesitter = pcall(require, "nvim-treesitter")

	if not ok then
		vim.notify("Sunflower: nvim-treesitter could not be loaded\n" .. tostring(treesitter), vim.log.levels.WARN)

		return false
	end

	treesitter.setup()

	vim.filetype.add({
		extension = {
			jsonl = "jsonl",
		},
	})

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("SunflowerTreesitterStart", {
			clear = true,
		}),

		callback = function(event)
			local buf = event.buf

			if vim.bo[buf].buftype ~= "" then
				return
			end

			if event.match == "jsonl" then
				return
			end

			local active = vim.treesitter.highlighter and vim.treesitter.highlighter.active

			if active and active[buf] then
				return
			end

			local lang = vim.treesitter.language.get_lang(event.match) or event.match

			-- language.add() throws when no parser is available.
			if not pcall(vim.treesitter.language.add, lang) then
				return
			end

			pcall(vim.treesitter.start, buf, lang)
		end,
	})

	apply_highlights()

	return true
end

-- IMPORTANT

M.setup()

sunflower.on_change(apply_highlights)

-- Return

return M
