-- Aurora Native LSP

local M = {}

-- Aurora Theme

local aurora = require("aurora.theme")

local colors = aurora.colors

local function set_hl(name, opts)
	vim.api.nvim_set_hl(0, name, opts)
end

-- LSP Highlights

local function apply_highlights()
	local c = colors()

	-- Floating UI

	set_hl("LspFloatNormal", {
		fg = c.text,
		bg = "NONE",
	})

	set_hl("LspFloatBorder", {
		fg = c.borderFocus or c.border,
		bg = "NONE",
	})

	set_hl("LspFloatTitle", {
		fg = c.accent,
		bg = "NONE",
		bold = true,
	})

	-- Signature Help

	set_hl("LspSignatureActiveParameter", {
		fg = c.accent,
		bg = c.surfaceHover,
		bold = true,
	})

	-- Inlay Hints

	set_hl("LspInlayHint", {
		fg = c.textMuted,
		bg = "NONE",
		italic = true,
	})

	-- Code Lens

	set_hl("LspCodeLens", {
		fg = c.textMuted,
		bg = "NONE",
		italic = true,
	})

	set_hl("LspCodeLensSeparator", {
		fg = c.border,
		bg = "NONE",
	})

	-- References

	set_hl("LspReferenceText", {
		bg = c.surfaceHover,
	})

	set_hl("LspReferenceRead", {
		bg = c.surfaceHover,
	})

	set_hl("LspReferenceWrite", {
		bg = c.surfaceHover,
		bold = true,
	})

	set_hl("LspReferenceTarget", {
		bg = c.surfaceHover,
		underline = true,
	})

	-- Semantic Tokens

	set_hl("@lsp.type.namespace", {
		fg = c.info,
	})

	set_hl("@lsp.type.type", {
		fg = c.accent,
	})

	set_hl("@lsp.type.class", {
		fg = c.accent,
		bold = true,
	})

	set_hl("@lsp.type.interface", {
		fg = c.accent,
	})

	set_hl("@lsp.type.enum", {
		fg = c.accent,
	})

	set_hl("@lsp.type.enumMember", {
		fg = c.warning,
	})

	set_hl("@lsp.type.function", {
		fg = c.info,
		bold = true,
	})

	set_hl("@lsp.type.method", {
		fg = c.info,
	})

	set_hl("@lsp.type.variable", {
		fg = c.text,
	})

	set_hl("@lsp.type.parameter", {
		fg = c.textSecondary,
	})

	set_hl("@lsp.type.property", {
		fg = c.info,
	})

	set_hl("@lsp.type.keyword", {
		fg = c.accent,
		bold = true,
	})

	set_hl("@lsp.type.string", {
		fg = c.success,
	})

	set_hl("@lsp.type.number", {
		fg = c.warning,
	})

	set_hl("@lsp.type.comment", {
		fg = c.textMuted,
		italic = true,
	})
end

-- LSP Hover

local function hover()
	vim.lsp.buf.hover({
		border = "rounded",
		max_width = 90,
		max_height = 30,
		focusable = true,
		close_events = {
			"CursorMoved",
			"BufHidden",
			"InsertCharPre",
		},
	})
end

-- LSP Signature Help

local function signature_help()
	vim.lsp.buf.signature_help({
		border = "rounded",
		max_width = 90,
		max_height = 15,
		focusable = true,
		close_events = {
			"CursorMoved",
			"BufHidden",
			"InsertCharPre",
		},
	})
end

-- Diagnostics

local function configure_diagnostics()
	vim.diagnostic.config({
		-- Keep diagnostics native and predictable: no custom panel, header, prefix, or forced floating window.
		virtual_text = true,
		signs = true,
		underline = true,
		update_in_insert = false,
		severity_sort = true,
	})
end

local function configure_diagnostic_lists()
	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, {
			silent = true,
			noremap = true,
			desc = desc,
		})
	end

	local function open_list(command, empty_message)
		local ok = pcall(vim.cmd, command)

		if not ok then
			vim.notify(empty_message, vim.log.levels.INFO)
		end
	end

	map("n", "<leader>xx", function()
		vim.diagnostic.setqflist({
			open = true,
			title = "Diagnostics",
		})
	end, "Diagnostics")

	map("n", "<leader>xX", function()
		vim.diagnostic.setloclist({
			open = true,
			title = "Buffer diagnostics",
		})
	end, "Buffer diagnostics")

	map("n", "<leader>xs", function()
		local ok, builtin = pcall(require, "telescope.builtin")

		if ok then
			builtin.lsp_document_symbols()
		else
			vim.notify("Telescope is unavailable", vim.log.levels.WARN)
		end
	end, "Symbols")

	map("n", "<leader>xl", function()
		open_list("lopen", "The location list is empty")
	end, "Location list")

	map("n", "<leader>xq", function()
		open_list("copen", "The quickfix list is empty")
	end, "Quickfix")
end

-- Completion Capabilities

local function configure_capabilities()
	local ok, blink = pcall(require, "blink.cmp")

	if not ok or type(blink.get_lsp_capabilities) ~= "function" then
		return
	end

	-- Apply Blink's completion capabilities to every native LSP config, including local configs under config/lsp/.
	vim.lsp.config("*", {
		capabilities = blink.get_lsp_capabilities(),
	})
end

configure_capabilities()

-- Server Configuration
--
-- Per-server settings live in config/lsp/<name>.lua, which Neovim picks up off
-- the runtime path automatically. There are deliberately no vim.lsp.config()
-- calls for individual servers here.
--
-- lua_ls, rust_analyzer and qmlls used to be configured in BOTH places. Since the
-- runtime files are merged first and these calls overrode them, the files were
-- misleading: qmlls was a byte-identical copy, and rust_analyzer genuinely
-- disagreed (closureReturnTypeHints "with_block" in the file vs "always" here,
-- plus five hint categories that only existed here). Those inline values have
-- been folded into config/lsp/ so current behaviour is preserved with one source.
--
-- The one exception is the "*" config in configure_capabilities() above, which is
-- a cross-server default rather than per-server settings.

-- Enable Servers

vim.lsp.enable({
	"lua_ls",
	"rust_analyzer",
	"ts_ls",
	"pyright",
	"clangd",
	"nixd",
	"bashls",
	"jsonls",
	"html",
	"cssls",
	"eslint",
	"yamlls",
	"marksman",
	"tailwindcss",
	"dockerls",
	"taplo",
	"qmlls",
})

-- LSP Attach

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)

		if not client then
			return
		end

		local buf = event.buf

		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, {
				buffer = buf,
				silent = true,
				noremap = true,
				nowait = true,
				desc = desc,
			})
		end

		-- Navigation

		map("n", "gd", vim.lsp.buf.definition, "LSP: Definition")

		map("n", "gD", vim.lsp.buf.declaration, "LSP: Declaration")

		map("n", "gi", vim.lsp.buf.implementation, "LSP: Implementation")

		map("n", "gr", vim.lsp.buf.references, "LSP: References")

		map("n", "gt", vim.lsp.buf.type_definition, "LSP: Type definition")

		-- Documentation

		map("n", "K", hover, "LSP: Hover")

		-- gK, not <C-k>: core/keymaps.lua maps <C-k> to <C-w>k globally, and a
		-- buffer-local mapping wins, so binding it here silently broke
		-- "move to the window above" in every buffer with a language server.
		map("n", "gK", signature_help, "LSP: Signature help")

		-- Refactoring

		map("n", "<leader>lr", vim.lsp.buf.rename, "LSP: Rename")

		map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, "LSP: Code action")

		-- Diagnostics

		map("n", "<leader>ld", vim.diagnostic.open_float, "LSP: Line diagnostics")

		map("n", "[d", function()
			vim.diagnostic.jump({
				count = -1,
			})
		end, "Diagnostics: Previous")

		map("n", "]d", function()
			vim.diagnostic.jump({
				count = 1,
			})
		end, "Diagnostics: Next")

		-- Inlay Hints

		if vim.lsp.inlay_hint and client:supports_method("textDocument/inlayHint") then
			map("n", "<leader>lh", function()
				local enabled = vim.lsp.inlay_hint.is_enabled({
					bufnr = buf,
				})

				vim.lsp.inlay_hint.enable(not enabled, {
					bufnr = buf,
				})
			end, "LSP: Toggle inlay hints")
		end
	end,
})

-- Initialize

configure_diagnostic_lists()

configure_diagnostics()

apply_highlights()

-- Live Aurora Theme Refresh

function M.refresh_theme()
	apply_highlights()

	configure_diagnostics()

	vim.schedule(function()
		vim.cmd("redraw!")
		vim.cmd("redrawstatus!")
	end)

	return true
end

return M
