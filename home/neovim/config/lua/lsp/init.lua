local M = {}


local aurora = require("aurora.theme")

local icons = require("aurora.icons")

local colors = aurora.colors

local function set_hl(name, opts)
	vim.api.nvim_set_hl(0, name, opts)
end


local function apply_highlights()
	local c = colors()


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


	set_hl("LspSignatureActiveParameter", {
		fg = c.accent,
		bg = c.surfaceHover,
		bold = true,
	})


	set_hl("LspInlayHint", {
		fg = c.textMuted,
		bg = "NONE",
		italic = true,
	})


	set_hl("LspCodeLens", {
		fg = c.textMuted,
		bg = "NONE",
		italic = true,
	})

	set_hl("LspCodeLensSeparator", {
		fg = c.border,
		bg = "NONE",
	})


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

	set_hl("@lsp.type.struct", {
		fg = c.accent,
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


local function configure_diagnostics()
	local sign_text = {}

	for _, entry in ipairs(icons.diagnostic_severities) do
		sign_text[entry.severity] = icons.diagnostics[entry.key]
	end

	vim.diagnostic.config({
		virtual_text = {
			spacing = 2,
			prefix = "●",
		},

		signs = {
			text = sign_text,
		},

		underline = true,
		update_in_insert = false,
		severity_sort = true,

		float = {
			border = "rounded",
			header = "",

			source = "if_many",
		},
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


local function configure_capabilities()
	local ok, blink = pcall(require, "blink.cmp")

	if not ok or type(blink.get_lsp_capabilities) ~= "function" then
		return
	end

	vim.lsp.config("*", {
		capabilities = blink.get_lsp_capabilities(),
	})
end

configure_capabilities()


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


		map("n", "gd", vim.lsp.buf.definition, "LSP: Definition")

		map("n", "gD", vim.lsp.buf.declaration, "LSP: Declaration")

		map("n", "gi", vim.lsp.buf.implementation, "LSP: Implementation")

		map("n", "gr", vim.lsp.buf.references, "LSP: References")

		map("n", "gt", vim.lsp.buf.type_definition, "LSP: Type definition")


		map("n", "K", hover, "LSP: Hover")

		map("n", "gK", signature_help, "LSP: Signature help")


		map("n", "<leader>lr", vim.lsp.buf.rename, "LSP: Rename")

		map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, "LSP: Code action")


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


configure_diagnostic_lists()

configure_diagnostics()

apply_highlights()


aurora.on_change(function()
	apply_highlights()

	configure_diagnostics()
end)

return M
